# ElementBuffer Test as Specification レビュー反映

## TL;DR（人間向け）
ElementBufferの既存契約に対する仕様test不足をA〜Eに整理し、借用競合、全座標access、寸法検査、空領域、参照型要素の寿命を対象とした。返却・受入・確認記録には実装と検証範囲、未実施事項が残されている。

これは完了済みのレビュー反映を記録したアーカイブ資料である。本文中の当時の依頼や停止条件は現行の作業指示ではなく、ElementBuffer全体の品質受入を示すものでもない。

## 目的・担当・開始条件

- Author: Astra (review draft and assignment source)
- Fixed ID: `BARE-046`
- Type: `EXECUTION`
- Planned assignee: Claude (Hime). Codex would check the returned evidence and update the Registry.
- On 2026-10-15, the user requested a specification-focused review, particularly for missing tests. After the review, the user instructed that a review-implementation task be assigned to Hime and added as a canonical document.
- On 2026-10-15, following the user's additional instruction, Claude was formally assigned through `Maintanance/CLAUDE_TASK.md`.
- The current state is governed by the relevant row in `Maintanance/ProgressV2/TASK_REGISTRY_V2.md`.

At the time of this record, ElementBuffer was designated for 1.0 competitive use with Swift 6.2 and 1.0 general use with Swift 6.4. Refer to `Maintanance/Current/QUALITY_REQUIREMENTS.md` for release policy and `Sources/ElementBufferModule/Documentation/Quality-Profile.md` for design decisions. This work does not remove nonmutating value updates or introduce guarantees for concurrency that is currently unsupported.

## レビューの範囲と証拠

The review statically compared the public source, `Tests/ElementBufferModuleTests/`, `Utilities/Maintenance/CompilerDiagnostics/BareArrayMutableRefLifetime/`, and `Utilities/Maintenance/VerifyBareArrayCompilerDiagnostics.sh`. At review time, tests were not rerun and implementation defects were not reproduced. The items below are candidate specification violations that existing tests might fail to detect. Do not add tests for requirements already adequately covered; identify the existing test and explain why it suffices.

## 反映事項

### A — 借用継続中の排他アクセス拒否（優先）

The current compiler fixture checks escape beyond the owner in four dimensions but does not check conflicting access during a borrow. Construct examples that use the reference after a conflicting operation so that the borrow remains live.

- Reject direct owner reads or writes, acquisition of a second borrowed reference, and consuming or replacing the owner when those operations violate the current exclusive-borrow contract.
- Pair these with valid examples where the same operations are allowed after the borrow ends.
- Verify the intended compiler diagnostic; do not count an incidental, unrelated error as success.
- Check the relationship between references returned by this module and their owner, not the standard `MutableRef` type exhaustively.

起点: `Tests/ElementBufferModuleTests/BareArray_7_BorrowedReferenceTests.swift`、上記compiler fixtureと検証script。

### B — 借用参照の全座標対応と更新の局所性（優先）

Current positive tests focus on one coordinate per dimension and writing to and reading back zero-initialized values.

- Use asymmetric dimensions and coordinate-specific initial values to read every position through borrowed references in one through four dimensions.
- Observe through a separate path, such as public value access, that updates affect only the intended element and leave all others unchanged.
- Avoid self-comparisons that could pass when both reads and writes use the same incorrect position.

起点: `Tests/ElementBufferModuleTests/BareArray_7_BorrowedReferenceTests.swift`。

### C — 初期化時の軸別非負条件（優先）

Current negative-dimension examples for two through four dimensions make the first two axes negative at once, so they cannot identify a missing check on an individual axis.

- For both repeating and closure initializers, check rejection when each axis is negative individually and all other axes are positive.
- Check rejection when a zero axis coexists with a negative axis. This ensures early handling of an empty region does not bypass the nonnegative-dimension requirement.
- Observe the intended precondition violation; do not use unrelated failures such as allocation failure as evidence.

起点: `Tests/ElementBufferModuleTests/BareArray_99_DeathTests.swift`。

### D — ゼロ寸法と空領域

Current tests cover only a limited zero-dimension arrangement for the closure initializer.

- Cover each zero-axis position for both repeating and closure initializers, and verify that the closure is not called.
- Verify that `indices` still spans the outermost axis when an inner dimension is zero.
- Verify that reads, writes, and reference acquisition at coordinate zero are rejected for an empty region.
- Retain the existing case where an intermediate product overflows but a zero dimension still makes the region empty. Choose representative inputs for distinct specification behavior rather than enumerating every combination.

起点: `BareArray_1_InitializationTests.swift`、`BareArray_4_IndicesTests.swift`、`BareArray_96_BorrowedReferenceDeathTests.swift`、`BareArray_97_CoordinateValueAccessDeathTests.swift`（いずれも`Tests/ElementBufferModuleTests/`）。

### E — 参照型要素の共有と寿命

Current checks focus on overwriting and destroying elements solely owned by the buffer.

- If a reference obtained through `element(at:)` is retained, verify that the element remains usable after the buffer is destroyed.
- If an external reference also exists, verify that overwriting a slot alone does not destroy the object.
- Verify that multiple slots initialized with the repeating initializer can retain the same object and that it is destroyed exactly once when the final reference is released.
- Use `withExtendedLifetime` or similar to make observation timing explicit and distinguish release of slot ownership from the object's `deinit`.

起点: `Tests/ElementBufferModuleTests/BareArray_5_ReferenceLifetimeTests.swift`、`BareArray_6_CoordinateValueAccessTests.swift`、`BareArray_7_BorrowedReferenceTests.swift`。

## 作業範囲・停止条件

The assigned changes were limited to the specification tests above, compiler fixture and verification script, and a return section assigned through a formal request. The assignee was not authorized to change production implementation, public API, performance criteria, release policy, or Registry. Treat the work as tests that strengthen checks for existing contracts. If a new or changed contract or an implementation fix is needed, return the relevant facts and reproduction instead. Do not weaken expectations merely to pass tests or change implementation unilaterally.

The current package requires Swift 6.4, so success of value-access tests on 6.4 must not be reported as success on the Swift 6.2 toolchain. Building a new 6.2 verification environment is not implicitly included in this implementation task.

## 完了・返却条件

1. For each of A–E, identify whether it was added, already adequately covered, or awaits a contract decision, with supporting evidence.
2. Run added ordinary tests, Death Tests, and compiler diagnostics in the required configurations. Record toolchain, OS, Debug/Release, commands, and results, distinguishing unrun checks from successes.
3. Check regressions in related existing tests. Pair compiler rejection cases with valid examples and the expected diagnostic.
4. Show that production code was unchanged and identify the specification violation each test detects.
5. Codex checks the results and, if no contract decisions remain, records implementation and verification completion and asks for commit permission in `WAITING_USER` (a trial started on 2026-10-15). After permission and commit confirmation, or the user's decision that no commit is needed, record `DONE`. Do not mark an already committed result incomplete; distinguish it from a pending commit for additional records. Completion of this review implementation is not acceptance of overall 1.0 quality.

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

On 2026-10-15, Codex compared the returned diff with the A–E mapping and confirmed that production code was unchanged.
Codex independently reran `VerifyBareArrayCompilerDiagnostics.sh`; it passed with 21 valid functions, four escape diagnostics, 20 borrow-conflict diagnostics, and zero other errors.
Using the active Xcode test plan `swift-ac-collections`, Codex reran all 81 `ElementBufferModuleTests` and confirmed 81 passed, zero failed, zero skipped, and zero not run.
The direct `swift test --filter ElementBufferModuleTests` invocation could not start because the environment reported `sandbox-exec: sandbox_apply: Operation not permitted`. This was not treated as a test failure; the Xcode run was used as acceptance evidence.
The unperformed D/E mutation checks, Linux run, and Swift 6.2 toolchain run remain outside acceptance. The work was accepted as test reinforcement for existing A–E contracts, not as acceptance of overall 1.0 quality.


## Astra確認（2026-10-15）

- Reviewer: Astra.
- Scope: The specification tests, compiler fixture, and verification script in implementation commit `4b44e758c8a1ce455b4b37f319686c2f2a6a5f95`, together with the current Claude return and Codex acceptance record.
- Finding: Confirmed the A–E review work as test reinforcement for existing contracts. A covers rejection of five operations across four dimensions while a borrow remains active, plus valid examples after the borrow ends. B covers all coordinates in asymmetric dimensions and confirms that other positions remain unchanged. C covers each axis being negative by itself and the coexistence of zero and negative dimensions. D covers initialization for each zero axis, outermost-axis `indices`, and rejection of accesses to empty regions. E covers shared lifetime involving external references, retained references, and multiple slots. The implementation commit contains no production-code changes.
- Verification scope: This was a static comparison of source, diff, and records; tests were not rerun. The 81 passing tests and compiler-diagnostic rerun are cited from the Codex acceptance above, not presented as Astra's own executions. Swift 6.2, Linux, and D/E mutation checks remain unperformed.
- Diagnostic-script limitation: `all_errors` counts only errors associated with the specified fixture files. “Zero other errors” applies only to that scope and does not exclude errors from other files or the driver in the full build output. This does not invalidate the A–E test additions, but it is narrower than a guarantee that the entire output contains no errors. The original Claude return is preserved; this confirmation adds the limitation.
- Commit status: The test changes and previous acceptance records were saved in the commit above. This confirmation, the author/completion procedure, and the corresponding Registry update were included in a record commit under the user's 2026-10-15 authorization.
