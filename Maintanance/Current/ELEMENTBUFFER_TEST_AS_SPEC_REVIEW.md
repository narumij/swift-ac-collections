# ElementBuffer Test as Specification レビュー反映

## 目的・担当・開始条件

- 固定ID: `BARE-046`
- 種別: `EXECUTION`
- 実施予定: Claude（姫）。Codexが返却された証拠を照合してRegistryを更新する。
- 2026-10-15、ユーザーが仕様観点、特にテスト不足のレビューを依頼。レビュー後に「アサイン予定姫のレビュー反映タスクと正本追加」を指示した。
- 2026-10-15、ユーザーの依頼追加指示により、`Maintanance/CLAUDE_TASK.md`でClaudeへ正式に実行依頼した。
- 現行の状態は `Maintanance/ProgressV2/TASK_REGISTRY_V2.md` の該当行を正とする。

ElementBufferはSwift 6.2で1.0競技供用、Swift 6.4で1.0一般供用である。提供方針は
`Maintanance/Current/QUALITY_REQUIREMENTS.md`、設計判断は
`Sources/ElementBufferModule/Documentation/Quality-Profile.md`を参照する。
非mutating値更新の廃止や、未保証の並行利用を新たに保証する仕事ではない。

## レビューの範囲と証拠

公開source、`Tests/ElementBufferModuleTests/`、
`Utilities/Maintenance/CompilerDiagnostics/BareArrayMutableRefLifetime/`と
`Utilities/Maintenance/VerifyBareArrayCompilerDiagnostics.sh`を静的に照合した。
レビュー時点では再実行も実装不具合の再現もしていない。以下はテストで検出できない仕様違反の候補である。
既存テストで十分な項目は追加せず、該当テストと理由を返す。

## 反映事項

### A — 借用継続中の排他アクセス拒否（優先）

現在のcompiler fixtureは所有者外へのescapeを4次元分検査するが、借用中の競合を検査しない。
参照を競合操作の後にも使用して借用が生存している例を作る。

- 所有者への直接read／set、二つ目の借用参照の取得、所有者の消費・置換について、現行の排他借用契約に反する操作を拒否すること。
- 借用終了後には同種の操作を許す正常例を対にする。
- 偶然の別エラーで失敗したものを成功に数えず、目的のcompiler診断を確認する。
- 標準MutableRef自体の網羅試験ではなく、本moduleが返す参照と所有者の関係を検査する。

起点: `Tests/ElementBufferModuleTests/BareArray_7_BorrowedReferenceTests.swift`、上記compiler fixtureと検証script。

### B — 借用参照の全座標対応と更新の局所性（優先）

現在の正常系は各次元1座標、ゼロ初期値への書込みと読戻しが中心である。

- 非対称寸法と座標ごとに異なる初期値を使い、1D〜4Dの借用参照で全座標の初期値を読む。
- 各座標への更新が意図した要素だけに反映され、他の要素を変えないことを、公開値アクセス等の別経路でも観測する。
- readとwriteが同じ誤った位置を参照しても通る自己比較を避ける。

起点: `Tests/ElementBufferModuleTests/BareArray_7_BorrowedReferenceTests.swift`。

### C — 初期化時の軸別非負条件（優先）

現行の2D〜4Dの負寸法例は最初の2軸を同時に負にしており、各軸の検査漏れを区別できない。

- repeating版とclosure版で、各軸を一つずつ負にし、他の軸を正にした場合の拒否を確認する。
- ゼロ軸と負軸が共存しても拒否することを確認する。空領域の早期処理が非負条件を迂回しないことが目的。
- 意図した事前条件違反を観測する。allocation失敗など別の失敗を証拠にしない。

起点: `Tests/ElementBufferModuleTests/BareArray_99_DeathTests.swift`。

### D — ゼロ寸法と空領域

現行はclosure版の限られたゼロ配置を検査している。

- repeating版・closure版で各軸がゼロの場合を扱い、closureが呼ばれないことを確認する。
- 内側がゼロでも`indices`は最外軸の範囲であることを確認する。
- 空領域の座標0へのread／set／referenceを拒否することを確認する。
- 既存の「途中積がoverflowしてもゼロ次元なら空」の例を保持する。仕様上の違いを代表する入力を選び、全組合せを展開しない。

起点: `BareArray_1_InitializationTests.swift`、`BareArray_4_IndicesTests.swift`、`BareArray_96_BorrowedReferenceDeathTests.swift`、`BareArray_97_CoordinateValueAccessDeathTests.swift`（いずれも`Tests/ElementBufferModuleTests/`）。

### E — 参照型要素の共有と寿命

現行の検査はbufferが単独所有する要素の上書き・破棄が中心である。

- `element(at:)`で得た参照を保持すれば、buffer破棄後も要素を利用できること。
- 外部にも参照があれば、slot上書きだけではオブジェクトが破棄されないこと。
- repeating初期化の複数slotが同じオブジェクトを保持し、最後の参照を手放すと一度だけ破棄されること。
- `withExtendedLifetime`等で観測時点を明確にし、slotの所有解放とオブジェクトのdeinitを区別する。

起点: `Tests/ElementBufferModuleTests/BareArray_5_ReferenceLifetimeTests.swift`、`BareArray_6_CoordinateValueAccessTests.swift`、`BareArray_7_BorrowedReferenceTests.swift`。

## 作業範囲・停止条件

変更対象は上記の仕様テスト、compiler fixtureと検証script、および正式依頼時に割り当てる返却欄。
production実装・公開API・性能基準・供用方針・Registryは実施担当の変更対象に含めない。
既存契約を検査するテスト補強として実施し、契約の新設・変更や実装修正が必要になったら、該当項目の事実と再現を返す。
テストを通すために期待値を弱めたり、独断で実装を変更したりしない。
現行packageはSwift 6.4を要求するため、6.4上で値アクセスの試験が通ったことを6.2 toolchainでの成功と記録しない。
新しい6.2検証基盤の構築はこの反映taskへ暗黙に含めない。

## 完了・返却条件

1. A〜Eそれぞれに、追加・既存で充足・契約上の判断待ちのいずれかと根拠を対応づける。
2. 追加した通常テスト・Death Test・compiler診断を必要な構成で実行し、toolchain、OS、Debug／Release、実行コマンド、結果を残す。未実施と成功を区別する。
3. 関連する既存テストの回帰を確認する。compilerの拒否例には正常例と期待診断を対応づける。
4. production変更がないこと、各テストがどの仕様違反を検出するかを示す。
5. Codexが結果を照合し、残る判断待ちがないことを確認してDONEとする。レビュー反映完了を1.0品質全体の受け入れとは扱わない。

## 返却欄（Claudeが記入）

返却待ち。A〜Eの対応、変更ファイル、実行環境と結果、残る判断点を記入する。
