# ElementBuffer Test as Specification レビュー反映

## 目的・担当・開始条件

- 作成者: Astra（レビュー原案・依頼正本）
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
5. Codexが結果を照合し、残る判断待ちがなければ、作業・検証完了を記録して`WAITING_USER`でコミット許可を尋ねる（2026-10-15からの試行）。許可後のコミット確認、またはユーザーのコミット不要判断を記録して`DONE`とする。既にコミット済みの成果を未完了へ戻さず、追加記録のコミット待ちと区別する。レビュー反映完了を1.0品質全体の受け入れとは扱わない。

## 返却欄（Claudeが記入）

2026-10-15 17:19 JST / Claude Opus 5.5（姫）。production・公開API・品質文書・DocC・Registryは変更していない。commitしていない。

### A〜Eの対応

| 項目 | 対応 | 内容と検出する仕様違反 |
| --- | --- | --- |
| A | 追加 | compiler fixtureに`BareArrayMutableRefConflict` targetを追加。1D〜4Dそれぞれで、借用参照の生存中に所有者へのread（`element(at:)`）、set（`setElement`）、二つ目の`reference(at:)`、`consume`、置換代入を行う20関数。各関数が参照生成位置で`overlapping accesses to 'array', but modification requires exclusive access`を1件ずつ出し、他のerrorが0件であることを検証scriptで確認する。正常例として同じ20操作を参照の最終使用後に行う関数を`BareArrayMutableRefValid`へ追加し、compileできることを確認する。参照が所有者への排他借用を保たなくなる変更を検出する |
| B | 追加 | `BareArray_7`に1D〜4Dの全座標試験を4件追加。非対称寸法（2×3×4×5まで）と座標ごとに異なる初期値（storage順の値）を使い、参照で全座標の初期値を読み、各座標への書込みが`element(at:)`という別経路で当該要素だけに反映されることを、毎回全要素について確認する。期待値は座標から独立に計算し、自己比較を避けた。参照の座標→位置の写像の誤りを検出する |
| C | 追加 | `BareArray_99`に、各軸だけを負にして他を正にした初期化をrepeating版・closure版で6関数18ケース（2D 2+2、3D 3+3、4D 4+4）、ゼロ軸と負軸の共存を2D〜4Dで3関数追加。いずれもSwift precondition trapのsignal（`expectedSwiftTrapSignal`）を要求し、allocation失敗など別の失敗を成功に数えない。単一軸の非負検査漏れと、空領域の早期処理による検査の迂回を検出する |
| D | 追加 | `BareArray_1`に、各軸を一つずつゼロにした場合をrepeating版・closure版で確認する試験を追加（closureが呼ばれないこと、`indices`が最外軸の範囲であること）。`BareArray_4`に内側ゼロでも`indices`が最外軸を保つ試験を追加。`BareArray_97`に空領域の座標0へのread／setの拒否（1D〜4D）、`BareArray_96`に参照取得の拒否（1D〜4D）を追加。既存の「途中積がoverflowしてもゼロ次元なら空」の例は保持した |
| E | 追加 | `BareArray_5`に3件追加。`element(at:)`で得た参照がbuffer破棄後も生き、最後の参照で一度だけ破棄されること。外部参照があるとslotの上書きでは破棄されないこと。repeating初期化の全slotが同一オブジェクトを保持し、最後の参照を手放したときに一度だけ破棄されること。観測点は`withExtendedLifetime`で固定した |

### 変更ファイル

- `Tests/ElementBufferModuleTests/BareArray_1_InitializationTests.swift`（D）
- `Tests/ElementBufferModuleTests/BareArray_4_IndicesTests.swift`（D）
- `Tests/ElementBufferModuleTests/BareArray_5_ReferenceLifetimeTests.swift`（E）
- `Tests/ElementBufferModuleTests/BareArray_7_BorrowedReferenceTests.swift`（B）
- `Tests/ElementBufferModuleTests/BareArray_96_BorrowedReferenceDeathTests.swift`（D）
- `Tests/ElementBufferModuleTests/BareArray_97_CoordinateValueAccessDeathTests.swift`（D）
- `Tests/ElementBufferModuleTests/BareArray_99_DeathTests.swift`（C）
- `Utilities/Maintenance/CompilerDiagnostics/BareArrayMutableRefLifetime/Package.swift`（A、target追加）
- `Utilities/Maintenance/CompilerDiagnostics/BareArrayMutableRefLifetime/Sources/BareArrayMutableRefConflict/BareArrayMutableRefConflict.swift`（A、新規）
- `Utilities/Maintenance/CompilerDiagnostics/BareArrayMutableRefLifetime/Sources/BareArrayMutableRefValid/BareArrayMutableRefValid.swift`（A、正常例20関数を追加）
- `Utilities/Maintenance/VerifyBareArrayCompilerDiagnostics.sh`（A、下記の既存不具合の修正と新target検証）

### 既存の検証scriptの不具合（発見・修正）

作業前の`VerifyBareArrayCompilerDiagnostics.sh`は、この環境で「expected 4 … found 0」で失敗していた。compilerが出力を
redirectしても色付き診断（ANSI escape）を出し、`error: lifetime-dependent …`の文字列照合が一致しないためで、escape fixture自体は
期待どおり4件の診断を出していた。照合前にANSI escapeとterminal hyperlinkを除くよう修正し、あわせて期待件数以外のerrorが
出た場合も失敗にした（偶然の別エラーを成功に数えない）。

### 実行環境と結果

- toolchain: Apple Swift version 6.4 (swiftlang-6.4.0.34.1)。OS: macOS 27.0.1 (26A434)、arm64。Swift 6.2 toolchainでは実行していない（6.2の成功として扱わない）。
- `sh Utilities/Maintenance/VerifyBareArrayCompilerDiagnostics.sh`: 成功。compile-pass 1 target（21関数）、escape診断4件、borrow-conflict診断20件、他のerror 0件。
  試験として1関数を正常な順序へ変えると「found 19 of 19」で失敗することを確認し、元へ戻した。
- `swift test --filter ElementBufferModuleTests`（Debug）: XCTest 43件、Swift Testing 38件（Death Test）すべて成功。追加した各testの実行をログの名前で確認した。
- `swift test -c release --filter ElementBufferModuleTests`: XCTest 36件、Swift Testing 38件すべて成功。
- `swift test`（Debug、全体）: exit 0。XCTest 1267件（作業前1258件、+9）、Swift Testing 209件（同197件、+12）、失敗0件。
- 検出力の確認（repositoryの一時copyで実施、copyは削除済み）: 2D初期化のheight検査を外すと、追加した`negativeSingleAxis_traps_2DRepeating`は
  SIGABRT（allocation失敗）を検出して失敗し、`zeroAndNegativeAxes_traps_2D`は正常終了を検出して失敗した。両軸同時に負の既存testは通過した。
  3D参照の位置計算のy・zを入れ替えると、追加した`testReference3DReachesEveryPositionAndUpdatesOnlyThatElement`が失敗した。

### 未実施・残る判断点

- D・Eの検出力（mutationでの確認）は未実施。Linuxでの実行は未実施（Death TestはLinuxではopt-in）。
- 契約上の判断待ちはなし。期待値を弱めた箇所、production変更はない。
- 作業時点で`Sources/ElementBufferModule/ElementBuffer.swift`ほかに他者の未commit変更（ドキュメントコメントのみ）があった。触れておらず、test結果はその状態での結果である。

## Codex受入

2026-10-15、返却差分とA〜Eの対応を照合し、production変更がないことを確認した。
`VerifyBareArrayCompilerDiagnostics.sh`を独立に再実行し、正常例21関数、escape診断4件、borrow-conflict診断20件、その他のerror 0件で成功した。
Xcodeのactive test plan `swift-ac-collections`から`ElementBufferModuleTests` 81件を指定して再実行し、81件成功、失敗0件、skip 0件、未実行0件を確認した。
直接の`swift test --filter ElementBufferModuleTests`は実行環境の`sandbox-exec: sandbox_apply: Operation not permitted`で開始できなかったため、その失敗をtest failureとは扱わず、Xcode実行結果を受入証拠とした。
未実施として返却されたD・Eのmutation検査、Linux、Swift 6.2 toolchainは受入範囲外のまま残す。A〜Eの既存契約を検出するtest補強として受け入れ、1.0品質全体の受入とは扱わない。


## Astra確認（2026-10-15）

- 確認者: Astra。
- 対象: 反映commit `4b44e758c8a1ce455b4b37f319686c2f2a6a5f95`の仕様テスト・compiler fixture・検証scriptと、現行のClaude返却・Codex受入記録。
- 判定: A〜Eのレビュー反映を、既存契約のテスト補強として確認した。Aは借用継続中の5操作×4次元の拒否例と借用終了後の正常例、Bは非対称寸法の全座標と更新対象以外の保持、Cは各軸単独の負寸法とゼロ・負の共存、Dは各ゼロ軸の初期化・最外軸indices・空領域access拒否、Eは外部参照・取得済み参照・複数slotによる共有寿命に対応している。反映commitにproduction実装の変更はない。
- 検証範囲: 今回はソース・差分・記録の静的照合。テストの再実行はしていない。81件成功とcompiler診断再実行の結果は上記「Codex受入」の証拠として参照し、Astra自身の実行結果とはしない。Swift 6.2・Linux・D/Eのmutation検査は引き続き未実施。
- 診断scriptの限定: `all_errors`は指定fixtureファイルに紐づくerrorだけを数える。「他のerror 0件」はこの範囲であり、ビルド出力全体の別ファイル・driver由来errorを排除する検査にはなっていない。A〜Eのテスト追加を否定する問題ではないが、全出力のerrorを拒否する保証とは区別する。Claudeの原返却は改変せず、この確認欄で補足する。
- コミット状態: テスト反映と従来の受入記録は上記commitで保存済み。今回の作成者・完了手順・Astra確認の追記、および対応するRegistry更新は、2026-10-15のユーザー許可に基づき本記録のコミットへ含める。
