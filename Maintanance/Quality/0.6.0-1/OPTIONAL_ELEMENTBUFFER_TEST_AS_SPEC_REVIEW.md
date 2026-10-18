# OptionalElementBuffer Test as Spec — 仕様観点レビュー

## TL;DR（人間向け）

OptionalElementBufferの1D〜4Dの公開契約に対し、Test as Specの検出力を補うA〜E（未設定と設定済み`nil`の区別、共有参照の寿命、removeAllの反復、要素ゼロの配列、非コピー所有型の否定的契約）をAstraがレビューし、姫が反映した記録（OPT-074、DONE）。製品コードは変えていない。いったんDONEにした後、担当の終了・占有返却の確認を待つ形へ訂正し、正式返却を確かめてから完了とした。Linux・Swift 6.2・ASan・mutation試験は未実施。

Written by Astra. 2026-10-15. Review base: source and tests at `f6c87a6c`. Application task: `OPT-074`.

<a id="結論と範囲"></a>
## Conclusion and scope

Supplement the detection power of A–E below against the current 1D–4D public contract. This is not a report confirming product defects.
This time it is a static review of source and tests; no test re-runs or mutation experiments were done.
General provision method, concurrency safety, performance evaluation, storage redesign, reviving the old View, and public API changes are not included.

<a id="読んだ根拠"></a>
## Grounds read

- `Sources/OptionalElementBufferModule/OptionalElementBuffer.swift`: the public contract and the full 1D–4D implementation.
- `Maintanance/Quality/Profiles/OptionalElementBufferModule.md`.
- `Tests/OptionalElementBufferModuleTests/OptionalArray_0_PublicSurfaceTests.swift`, `_1_InitializationTests.swift`, `_2_ElementAccessTests.swift`, `_4_IndicesTests.swift`, `_5_RemoveAllTests.swift`, `_6_ReferenceLifetimeTests.swift`, `_7_CoordinateValueAccessTests.swift`, `_97_CoordinateValueAccessDeathTests.swift`, `_99_DeathTests.swift` (common prefix `OptionalArray`).
- Searched `Utilities/Maintenance/CompilerDiagnostics/`; no owned-type compiler fixture dedicated to OptionalElementBuffer was found.

<a id="既存で押さえられている仕様"></a>
## Specifications already covered

Reading and writing all coordinates of asymmetric shapes, separation of the selected coordinate from its neighbours, overwriting with non-nil and discarding with nil in each dimension,
outer-axis indices, rejecting reads/writes of negative values and upper bounds on every axis, combinations of negative dimensions and zero, overflow of the dimension product,
and avoiding intermediate-product overflow when there is a zero are already verification targets. Do not turn these back into "not done".
Round trips of public operations confirm a consistent coordinate mapping, while internal layout changes that replace read/write with the same bijection
cannot be detected. That alone is no reason to bring raw storage into public specification tests.

<a id="反映指摘と受入条件"></a>
## Findings to apply and acceptance conditions

<a id="a未設定と設定済みのoptionalnilの区別優先度高"></a>
### A: distinguishing unset from a set Optional.nil (priority: high)

Currently tests centre on Int and reference types, and there is no test with `Element == Int?`. The API's return values and inputs are `Element?`, so
unset `.none` must be distinguished from set `.some(.none)` and `.some(.some(value))`.
Check these three states in 1D–4D with explicit pattern matching or the like, going through overwrite, release to outer nil, setting again and removeAll.
Do not confuse inner and outer Optional with a mere `XCTAssertNil`. This is work to fix the state distinction of the existing generic API.

<a id="b返された値と共有参照の寿命優先度高"></a>
### B: lifetimes of returned values and shared references (priority: high)

The existing `_6` and `_7` mainly check the destruction counts of separate Boxes held only by the buffer.
When the same Box is stored in several slots, confirm in 1D–4D that releasing one does not break the other slots, that a reference obtained by `element(at:)`
survives the slot's release, removeAll and buffer destruction, and that deinit happens only when that last external reference is released.
Use weak references and identifiable deinit records, state the holding periods explicitly, and do not depend on accidental ARC lifetimes.
Also confirm that results obtained for value types are not rewritten by later slot updates. No deep copy of the referenced objects is required.

<a id="cremoveallの反復全位置再利用優先度中"></a>
### C: repeated removeAll and reuse of all positions (priority: medium)

`_5` checks a single clearing, and `_6`'s 3D and 4D check reuse of one position, but repetition in each dimension's empty state and reuse of all positions are missing.
For small asymmetric shapes in 1D–4D, check clearing in the initial empty state, sparse setting, clearing, clearing again, and setting and reading all positions again.
At each stage check the state of all coordinates and that indices are kept, and also detect double release or leaks with reference elements.
Extending existing cases is enough, without piling up and mass-copying existing tests. Do not add new guarantees about allocation counts or internal pointer identity.

<a id="d要素ゼロの配列への操作優先度中"></a>
### D: operations on arrays with zero elements (priority: medium)

`_1` checks construction with each zero dimension, but not rejecting reads/writes to the empty region or safely repeating removeAll.
For a 1D capacity of zero, and for shapes in 2D–4D with only one axis zero, confirm that indices are kept while repeating removeAll.
Confirm with Death Tests that reads/writes with all coordinates 0 (including writing nil) are Swift precondition traps.
Detect changes that return out-of-range as unset nil, or that skip the check only for nil writes. Do not count SIGSEGV or arbitrary failures as success.

<a id="e非コピー所有型の否定的契約優先度中"></a>
### E: negative contract of the noncopyable owned type (priority: medium)

`_0` has only a 1D Sendable positive example and does not fail if `~Copyable` is lost.
For the 1D–4D owned types, fix with re-runnable compiler fixtures both normal examples in which borrowing and transfer by consume work, and examples in which conformance to a Copyable requirement
is rejected. Confirm not just a compile failure but the diagnostic of the expected owned-type constraint.
Do not add the undecided concurrent sharing contract. Do not require ElementBuffer's borrowed-reference API on the Optional side.

<a id="姫への反映範囲と返却"></a>
## Application scope for Hime and return

Apply A–E to the tests and compiler fixtures of the existing contract. No production changes are included.
If a discrepancy with the specification or a new decision is needed, leave the expected value and a minimal reproduction for that case and stop;
do not weaken tests to match the implementation. Do not resume unrelated remaining items or frozen tasks.

Check the target tests in Debug / Release (stating whether Death Tests ran) and both the success and rejection of compiler fixtures.
Make sure the targets were actually discovered and run, and return the commands, toolchain, target version, counts, results and the scope not run.
Astra's finding text is fixed; Hime edits only the return field below and the specified tests/fixtures.
After Codex's independent check, waiting for commit permission to save the record is WAITING_USER, and after confirming the save it becomes DONE.

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

<a id="astra受入確認欄"></a>
## Astra acceptance check field

2026-10-15, acceptance check by Astra. Checked the working tree against base HEAD `9d0a25c4` (Claude's formal return not yet confirmed).
A–E are applied in 1D–4D. Nested Optional distinguishes the three states with pattern matching, and shared references check lifetimes with weak references, explicit consume and releasing the last external reference.
Confirmed clearing everything and reusing all coordinates, clearing with each axis zero and rejecting reads / value writes / nil writes, and normal transfer of the owned type and its rejection diagnostics.
No changes to production source or the root manifest.

Independent execution environment: macOS arm64, Apple Swift 6.4 (swiftlang-6.4.0.34.1).

- `swift test --disable-sandbox --filter OptionalElementBufferModuleTests`: exit 0. XCTest 49, Death Tests 25 (2 suites), all succeeded.
- `swift test --disable-sandbox -c release --filter OptionalElementBufferModuleTests`: build failure with `Operation not permitted` in dSYM generation of an unrelated target. Not included as evidence of test success.
- `swift test --disable-sandbox -c release -debug-info-format none --filter OptionalElementBufferModuleTests`: exit 0. XCTest 49, Death Tests 25, all succeeded. A configuration keeping Release optimization and omitting only debug information generation.
- `sh Utilities/Maintenance/CompilerDiagnostics/OptionalElementBufferPublicSurface/verify.sh`: exit 0. Confirmed the normal targets (1D–4D), 4 rejections of Copyable requirements, and 4 rejections of use after consume.
- `git diff --check HEAD`: no problems.

Claude's return field was empty at the time of checking, so the person's run report was not written on their behalf; the actual check above and Astra's own runs were the grounds for acceptance.
This acceptance scope is supplementing the A–E specification tests. Linux, Swift 6.2, ASan, mutation testing, general-use Validation and performance were not done this time, and this is not extended to a guarantee of overall quality.
The implementation and verification are accepted, and by the user's commit instruction on 2026-10-15 the application and acceptance record are saved in the same commit and the task becomes `DONE`.

<a id="完了扱いの訂正2026-10-15astra"></a>
## Correction of the completion handling (2026-10-15, Astra)

The DONE judgment above is corrected. The user indicated that Claude may have paused midway and instructed returning to waiting for confirmation of the end and return.
Success of independent verification is separate from the end of the owner's work and the return of occupancy.
The test application and verification record are saved in `427b155a`, and this does not cancel that evidence.
The current state is `ACTIVE`. It is not complete until Claude's remaining work, unrecorded concerns, the end of the work and the return of occupancy are confirmed.
The original return field is kept empty. If the return has additional diffs, verify their impact again.

<a id="返却後のastra確認2026-10-15"></a>
## Astra check after the return (2026-10-15)

Checked Claude's formal return saved in `92b65db8`. There are no remaining work, concerns, pending specification decisions or product defects, and the return of occupancy of the assigned scope is stated.
Checked that there are no diffs in `Tests/OptionalElementBufferModuleTests/` and `Utilities/Maintenance/CompilerDiagnostics/OptionalElementBufferPublicSurface/` from `427b155a` to the current HEAD.
The target is the same as Astra's existing independent verification, so tests were not re-run this time. Claude's normal Release success is treated as the person's returned evidence, and the difference from Astra's own run configuration stays as previously recorded.

This resolves the waiting for confirmation of the end and return left in the correction above. Acceptance of A–E is complete. Waiting for commit permission to save this completion check record, it is `WAITING_USER`, and after confirming the save it moves to `DONE`.
Following the user's instruction, after confirming the return of occupancy, PERM-078 was requested first and then this record was closed. Claude's original return and past correction records were not changed.

On 2026-10-15 the user permitted the commit. Waiting for commit permission is resolved, and the completed acceptance is saved as `DONE` in the same commit as this check record.
