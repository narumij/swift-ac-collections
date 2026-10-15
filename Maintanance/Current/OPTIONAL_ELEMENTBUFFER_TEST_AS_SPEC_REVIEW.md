# OptionalElementBuffer Test as Spec — 仕様観点レビュー

作成者：Astra。2026-10-15。レビュー基準：`f6c87a6c`のsource・test。反映task：`OPT-074`。

## 結論と範囲

現行1D〜4Dの公開契約に対して、下記A〜Eの検出力を補う。製品不具合を確認したという報告ではない。
今回はsourceとtestの静的レビューであり、テスト再実行・mutation実験は行っていない。
一般供用方式、並行安全性、性能評価、storage再設計、旧View復活、公開API変更は含めない。

## 読んだ根拠

- `Sources/OptionalElementBufferModule/OptionalElementBuffer.swift`：公開契約と1D〜4Dの実装全文。
- `Sources/OptionalElementBufferModule/Documentation/Quality-Profile.md`。
- `Tests/OptionalElementBufferModuleTests/OptionalArray_0_PublicSurfaceTests.swift`、`_1_InitializationTests.swift`、`_2_ElementAccessTests.swift`、`_4_IndicesTests.swift`、`_5_RemoveAllTests.swift`、`_6_ReferenceLifetimeTests.swift`、`_7_CoordinateValueAccessTests.swift`、`_97_CoordinateValueAccessDeathTests.swift`、`_99_DeathTests.swift`（共通prefixは`OptionalArray`）。
- `Utilities/Maintenance/CompilerDiagnostics/`を検索し、OptionalElementBuffer専用の所有型compiler fixtureは見つからなかった。

## 既存で押さえられている仕様

非対称shapeの全座標読み書き、選択座標と近隣の分離、各次元のnon-nil上書きとnilによる破棄、
外側軸のindices、全軸の負値・上限のread/write拒否、負寸法とゼロの組合せ、次元積overflow、
ゼロがある場合の途中積overflow回避は既存の検証対象になっている。これらを未実施扱いに戻さない。
公開操作の往復で一貫した座標対応を確認できる一方、同じ全単射でread/writeを置換する内部配置変更は
検出できない。それだけを理由にraw storageを公開仕様testへ持ち込む必要はない。

## 反映指摘と受入条件

### A：未設定と、設定済みのOptional.nilの区別（優先度：高）

現在はInt・参照型中心で、`Element == Int?`のtestがない。APIの戻り値と入力は`Element?`なので、
未設定の`.none`と、設定済みの`.some(.none)`、`.some(.some(value))`を区別する必要がある。
1D〜4Dでこの三状態を明示的なpattern match等で検査し、上書き・外側nilへの解除・再設定・removeAllを通す。
単なる`XCTAssertNil`だけで内外のOptionalを混同しない。これは既存generic APIの状態区別を固定する仕事である。

### B：返された値と共有参照の寿命（優先度：高）

既存の`_6`・`_7`は主にbufferだけが持つ別々のBoxの破棄数を確認する。
同じBoxを複数slotへ格納した場合、一つの解除だけで他slotが壊れないこと、`element(at:)`で取得した参照が
slotの解除・removeAll・buffer破棄後も生存すること、その最後の外部参照を解放したときだけdeinitすることを
1D〜4Dで確認する。弱参照と識別可能なdeinit記録を用い、保持期間を明示して偶然のARC寿命に依存しない。
値型の取得結果も、後のslot更新で書き換わらないことを確認する。参照先のdeep copyは要求しない。

### C：removeAllの反復・全位置再利用（優先度：中）

`_5`は単回消去、`_6`の3D・4Dは一位置の再利用を確認するが、各次元の空状態での反復と全位置再利用が不足。
1D〜4Dの小さな非対称shapeについて、初期空状態での消去、疎な設定、消去、再消去、全位置への再設定と読出しを
確認する。各段階で全座標の状態とindicesの保持を確認し、参照要素で二重解放・解放漏れも検出する。
既存testを重ねて大量複製せず、既存ケースの拡張でよい。allocation回数や内部pointer同一性の新規保証は足さない。

### D：要素ゼロの配列への操作（優先度：中）

`_1`で各ゼロ寸法の構築は確認するが、空領域へのread/write拒否とremoveAllの安全な反復は確認していない。
1Dのcapacityゼロ、および2D〜4Dで各軸だけゼロのshapeについて、removeAllを反復してindicesが維持されることを確認する。
座標を全て0にしたread/write（nil書込みも含む）がSwiftのprecondition trapになることをDeath Testで確認する。
範囲外を未設定のnilとして返す変更や、nil書込みだけ検査を省く変更を検出する。SIGSEGVや任意の失敗を成功に数えない。

### E：非コピー所有型の否定的契約（優先度：中）

`_0`は1DのSendable肯定例だけで、`~Copyable`が失われても失敗しない。
1D〜4Dの所有型について、借用・consumeによる移送が成立する正常例と、Copyable要求への適合が拒否される例を
再実行可能なcompiler fixtureで固定する。コンパイル失敗だけでなく期待する所有型制約の診断を確認する。
未決の並行共有契約は追加しない。ElementBufferの借用参照APIをOptional側へ要求しない。

## 姫への反映範囲と返却

A〜Eを既存契約のtest・compiler fixtureへ反映する。productionの変更は含めない。
仕様との食い違いや新しい判断が必要になった場合は、該当ケースの期待値・最小再現を残して停止し、
テストを実装へ合わせて弱めない。無関係な残件・凍結taskを再開しない。

Debug／Releaseの対象test（Death Testの実行有無も明記）、compiler fixtureの正常・拒否双方を確認する。
対象が実際に発見・実行されたことを確かめ、command・toolchain・対象版・件数・結果・未実施範囲を返す。
Astraの指摘本文は固定し、姫は下の返却欄と指定されたtest／fixtureのみ編集する。
Codexによる独立確認後、記録保存のコミット許可待ちをWAITING_USERとし、保存確認後にDONEとする。

## Claude返却欄

未返却。

## Astra受入確認欄

未確認。
