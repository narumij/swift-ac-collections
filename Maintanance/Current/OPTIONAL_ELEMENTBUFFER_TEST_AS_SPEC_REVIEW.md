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

2026-10-15、姫が返却。前セッションの作業は`427b155a`に保存済みで、その後の追加差分はない。返却に当たり、前セッションの記憶に頼らず保存済みの差分を読み直し、下記を自分で再実行した。

- 反映：A＝`_2`のnested Optional三状態（1D〜4D）、B＝`_6`の共有参照・取得参照の寿命と値型取得結果の独立（1D〜4D）、C＝`_5`の反復removeAllと全位置再利用（1D〜4D）、D＝`_5`のゼロ寸法での反復removeAllと`_97`の座標0へのread／値write／nil write拒否（各軸ゼロ）、E＝`Utilities/Maintenance/CompilerDiagnostics/OptionalElementBufferPublicSurface/`の正常target・Copyable要求拒否4件・consume後使用拒否4件。共通の補助は`OptionalBufferProbe.swift`（公開APIへの転送だけ）。
- 環境：macOS arm64、Apple Swift 6.4（swiftlang-6.4.0.34.1）、基準HEAD `4750431f`。
- `swift test --filter OptionalElementBufferModuleTests`：終了0。XCTest 49件、Death Test 25件（2 suites）、全件成功。
- `swift test -c release --filter OptionalElementBufferModuleTests`：終了0。XCTest 49件、Death Test 25件、全件成功。姫の環境では通常ReleaseのdSYM生成は失敗しなかった（Astra記録の権限制限は環境差）。
- `sh Utilities/Maintenance/CompilerDiagnostics/OptionalElementBufferPublicSurface/verify.sh`：終了0。期待した診断文の件数と全error件数の一致まで確認。
- production・manifest・`Tests/TESTING.md`は変更していない。
- 懸念・残作業：なし。仕様判断が必要な点や製品不具合は見つかっていない。未実施はLinux・Swift 6.2・ASan・mutation試験で、Astraの受入範囲と同じ。
- 占有返却：OPT-074の編集範囲（上記test・fixture・本欄・依頼票の返却欄）を手放す。

## Astra受入確認欄

2026-10-15、Astraが受入確認。基準HEAD `9d0a25c4`に対する作業ツリーを確認した（Claudeからの正式返却は未確認）。
A〜Eは1D〜4Dで反映されている。nested Optionalはpattern matchで三状態を区別し、共有参照は弱参照・明示consume・最後の外部参照解放で寿命を検査する。
全消去・全座標再利用、各軸ゼロ時の消去とread／値write／nil write拒否、所有型の正常移送と拒否診断を確認した。
production sourceとroot manifestに変更はない。

独立実行環境：macOS arm64、Apple Swift 6.4（swiftlang-6.4.0.34.1）。

- `swift test --disable-sandbox --filter OptionalElementBufferModuleTests`：終了0。XCTest 49件、Death Test 25件（2 suites）、全件成功。
- `swift test --disable-sandbox -c release --filter OptionalElementBufferModuleTests`：関連外targetのdSYM生成で`Operation not permitted`となりbuild失敗。テスト成功の証拠に含めない。
- `swift test --disable-sandbox -c release -debug-info-format none --filter OptionalElementBufferModuleTests`：終了0。XCTest 49件、Death Test 25件、全件成功。Release最適化のままdebug情報の生成だけを省いた構成。
- `sh Utilities/Maintenance/CompilerDiagnostics/OptionalElementBufferPublicSurface/verify.sh`：終了0。正常target（1D〜4D）、Copyable要求拒否4件、consume後使用拒否4件を確認。
- `git diff --check HEAD`：問題なし。

Claude返却欄は確認時点で未記入だったため、本人の実行報告を代筆せず、上記の実物照合とAstra自身の実行を受入根拠とした。
今回の受入範囲はA〜Eの仕様test補完。Linux・Swift 6.2・ASan・mutation試験・一般利用Validation・性能は今回未実施であり、品質全体の保証には広げない。
実装・検証を受け入れ、2026-10-15のユーザーのコミット指示により、反映と受入記録を同じコミットに保存してtaskを`DONE`とする。

## 完了扱いの訂正（2026-10-15、Astra）

上記のDONE判断を訂正する。ユーザーからClaudeが途中で休止した可能性が示され、
終了・返却確認待ちへ戻す指示を受けた。独立検証の成功と、担当者の仕事の終了・占有返却は別である。
テスト反映と検証記録は`427b155a`に保存済みであり、その証拠を取り消すものではない。
現在の状態は`ACTIVE`。Claudeの残作業、未記録の懸念、作業終了および占有返却を確認するまで完了としない。
原返却欄は未記入のまま保持する。返却に追加差分がある場合は、その影響範囲を改めて検証する。

## 返却後のAstra確認（2026-10-15）

`92b65db8`に保存されたClaudeの正式返却を確認した。残作業・懸念・仕様判断待ち・製品不具合はなく、担当範囲の占有返却が明記されている。
`427b155a`から現在のHEADまで、`Tests/OptionalElementBufferModuleTests/`と`Utilities/Maintenance/CompilerDiagnostics/OptionalElementBufferPublicSurface/`に差分がないことを照合した。
既存のAstra独立検証と対象が同一なので、今回テストの再実行はしていない。Claudeの通常Release成功は本人の返却証拠として扱い、Astra自身の実行構成との差は従来記録のまま残す。

これにより、上の訂正で残した終了・返却確認待ちは解消した。A〜Eの受け入れは完了。今回の完了確認記録を保存するコミット許可待ちとして`WAITING_USER`とし、保存確認後に`DONE`へ移す。
ユーザー指示に従い、占有返却確認後、先にPERM-078を依頼してから本記録を閉じた。Claudeの原返却と過去の訂正記録は変更していない。

2026-10-15、ユーザーがコミットを許可。コミット許可待ちは解消し、受入完了を`DONE`として今回の確認記録と同じコミットへ保存する。
