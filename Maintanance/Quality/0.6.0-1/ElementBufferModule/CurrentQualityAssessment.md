# ElementBufferModule Current Quality Assessment

## TL;DR（人間向け）
本書はElementBufferの品質評価と後続test・性能検証の記録をまとめ、提供区分の訂正、仕様testの受入、未確認範囲を保存する。複数時点の記録が含まれるため、各判断の日時と証拠範囲を区別する。

このアーカイブ記録だけから現行の品質状態や未完了作業を推定しない。過去のtask指示は再開条件ではなく、現行判断は現在の品質正本とTask Registryによる。

## 文書の役割

This document was the detailed source for the ElementBufferModule quality-assessment task at the time. The higher-level requirements are governed by `Maintanance/Quality/QUALITY_REQUIREMENTS.md`; module-specific application and evidence boundaries are governed by `Maintanance/Quality/Profiles/ElementBufferModule.md`. This document does not change those sources; it records the recency check for the Quality Profile, assessment scope, completion conditions, and results.


> 2026-10-16、進捗表示を整理。以下の評価日・実行結果・当時の型名は、その時点の記録として保持する。現在の作業状態は[Task Registry](../../../ProgressV2/TASK_REGISTRY_V2.md)、提供方針は上記の品質要求・Quality Profileを参照する。

## 現行の供用区分の訂正（2026-10-15）

The user reconfirmed ElementBuffer as a 1.0 offering, distinguishing Swift 6.2 as “1.0 competitive use” (competition only) and Swift 6.4 as “1.0 general use.” The release classes are recorded in `Maintanance/Quality/QUALITY_REQUIREMENTS.md`; access methods, design rationale, and qualitative performance wording are recorded in the current Quality Profile. Decisions below that assume “not a 1.0 offering” or a “maintenance module” describe earlier history and must not be used as current release status or grounds to exclude assessment. Historical task states and run results were left unchanged; this correction is not evidence of quality completion or successful verification.

## Deprecated公開面の削除（2026-10-13）

The former chained subscripts on owning one- through four-dimensional types and `BareArray1DView` through `BareArray3DView` were removed from production source. Tests specific to the retired Views, writeback Death Tests, and the retired contract represented by the old compiler fixture are not current acceptance evidence. Existing initialization, element-access, clone, and element-lifetime tests were moved to `element` / `setElement`; the Swift 6.4 `MutableRef` / `reference(at:)` contract and its runtime tests and compiler fixture were retained as current.

The BareArrayModule Xcode Build for Testing, 34 current ordinary tests, 26 Death Tests, and benchmark package build succeeded. The first selected Xcode run retained five removed View tests in its cached test list and marked them not run. Current test discovery was therefore repeated with SwiftPM, confirming that all 60 tests (34 + 26) passed.

## 標準MutableRefへの移行（2026-10-13）

The project-owned type also named `MutableRef` and its `Reference` alias were removed, and the API moved to returning the standard-library `MutableRef<Element>` directly on Apple OS 27 or later. `reference(at:)` became `mutating` to meet the standard initializer's owner requirements; callers obtain a reference from a mutable owner and read or write its standard `value` property. No same-named compatibility type is provided for older OS releases or toolchains.

After migration, Xcode Build for Testing, seven runtime / Death Test / facade tests, one compile-pass, four compile-fail cases rejecting escape beyond the owner, and the benchmark package build succeeded. Reference-based benchmark workloads are registered only on macOS 27 or later; value-access workloads remain available on their previous supported environments. These results show that the migration to the standard type retained the existing borrow lifetime and reflection into owner storage; they do not authorize renaming the owner type.

The following records of the former View's introduction, audit, and acceptance are retained as history. For the current assessment, public surface, and checks required for changes, this section and the current Quality Profile take precedence.

## Test as Specification原状回復確認（2026-10-13）

The execution task left marked in progress during introduction of non-escapable Views was checked against commit history, current source, fixtures, numbered specification tests, and current rerun results. Xcode build-for-testing succeeded; Debug ordinary tests (35) and Death Tests (39), Release ordinary tests (28) and Death Tests (39), and compiler diagnostic fixtures for three View-lifetime escapes and three owning-array writeback exclusivity violations all succeeded. On that basis, the lifetime dependency of the three View types, the executable View path, and rejection contracts moved from runtime Death Tests to compiler diagnostics were accepted as results of the former non-escapable-View work.

After that acceptance, `element(at:)`, `setElement(_:at:)`, `reference(at:)` and its multidimensional variants for Swift 6.4 or later, and deprecation annotations for the old subscripts and Views were added in a separate commit. The current eight numbered specification groups pass through the old subscript/View paths, but do not directly specify the new coordinate-access APIs; the build also emits numerous deprecation warnings. Treat these later changes as a separate API-difference audit rather than mixing them with incomplete work on the retired View contract or preempting an adopt/revert decision.

### 座標access API差分監査（BARE-036）

On 2026-10-13, current source, eight numbered specification groups, compiler diagnostic fixtures, benchmarks, and additional commit `4b023333` were compared. The old Views and chained subscripts are deprecated and are not treated as indirect coverage for the new coordinate-access APIs. Keep the existing tests as regression evidence until the old contract is retired, and put specification tests for the new APIs in a separate group.

#### 直接coverage

The following table is a snapshot from the `BARE-036` audit. The gaps identified there were resolved by the later acceptance results for `BARE-037` and `BARE-038`; use those results and “Current Assessment” below for the present state.

| Subject | Production declarations | Test as Specification at the `BARE-036` audit snapshot | Finding |
| --- | ---: | --- | --- |
| `element(at:)` | Four owning types, dimensions 1D–4D | No direct calls | Unverified |
| `setElement(_:at:)` | Four owning types, dimensions 1D–4D | No direct calls | Unverified |
| `reference(at:)` (Swift 6.4+) | Four owning types, dimensions 1D–4D | No direct calls | Unverified |
| `MutableRef.pointee` (Swift 6.4+) | Read / nonmutating write | No direct calls | Unverified |
| Out-of-bounds trap per coordinate | Every axis in dimensions 1D–4D | No Death Tests | Unverified |
| Owner-dependent lifetime of `MutableRef` (Swift 6.4+) | `~Escapable` and `@_lifetime(borrow self)` | No compile-pass / compile-fail fixtures | Unverified |

Benchmarks execute some paths in dimensions 1D–3D for performance exploration and checksum checks. Their workloads are finite, so they are not evidence specifying public contracts, all dimensions, all-axis bounds, element lifetime, or compiler rejection.

#### 後継仕様群

This audit does not decide to lock the new APIs into the implementation under their current names. The following units were identified for successor Test as Specification work as behavioral intentions to preserve even if names change.

1. For the Swift 6.2+ value-access group, confirm that `element(at:)` maps every coordinate in asymmetric shapes for owning types in dimensions 1D–4D to the correct linear position.
2. For the Swift 6.2+ value-access group, observe `setElement(_:at:)` changes through a storage-check path independent of `element(at:)`, and confirm that replacing a reference-type element destroys the old element exactly once.
3. For the Swift 6.4+ borrowed-reference group, confirm that `pointee` reads and writes through `reference(at:)` affect the same owner storage and preserve replacement lifetime for reference-type elements.
4. For every coordinate in dimensions 1D–4D, reject negative and upper-bound values for reads and writes; on Swift 6.4+, reject them for reference acquisition as well.
5. On Swift 6.4+, use a compiler fixture to confirm that `MutableRef` cannot escape beyond its owner but can be used within a valid scope.
6. Confirm that the new public surface can be reached through the `AcCollections` reexport path.

Do not add assertions for the new APIs to old View/chained-subscript tests. Do not remove old tests before replacement coverage is accepted. Decide when to remove the deprecated surface separately from release and migration decisions.

#### 付随して見つかった文書不整合

The deprecation messages on `BareArray2DView` and `BareArray3DView` extensions point users to `mutable(at:...)`, which does not exist in current source. The actual replacement candidate on Swift 6.4+ is `reference(at:)`; keep this as a correction for when naming is reflected, without preempting a public-name decision or toolchain-specific migration guidance.

#### 現行suiteの基準点

`swift test --disable-sandbox --filter BareArrayModuleTests` ran successfully: 35 XCTest cases and 39 Swift Testing Death Tests passed. These results cover the current suite, which focuses on old Views and chained subscripts; they do not resolve the unverified coordinate-access APIs in the table. The environment warning that the user-level SwiftPM cache was read-only did not affect the results.

#### 監査で確定した後続task境界

- `BARE-037`: Directly specify the value-access group for `element(at:)` and `setElement(_:at:)`. `DIRECT` to the current intermediate goal.
- `BARE-038`: Directly specify the Swift 6.4+ borrowed-reference group for `reference(at:)` and `MutableRef` with runtime tests and compiler fixtures. It can be executed and accepted independently from the value-access group and is `DIRECT` to the current intermediate goal.

Neither task decides to adopt the current names; both specify behavior to preserve if names change. They do not include removal of old Views, migration timing, or finalizing deprecation messages.

#### 値access群の受入結果（BARE-037）

`BareArray_6_CoordinateValueAccessTests.swift` added tests for all-coordinate mapping in asymmetric shapes across dimensions 1D–4D, changing only a selected position, and destruction counts when replacing reference-type elements. `BareArray_97_CoordinateValueAccessDeathTests.swift` checks negative and upper-bound values for reads and writes on every axis in every dimension, 40 cases total, against the exact Swift trap signal. The facade reachability test in `AcCollectionsTests` was also moved from deprecated subscripts to the value-access group.

Debug passed 38 ordinary tests and 47 Death Tests; Release passed 31 ordinary tests and 47 Death Tests. Release has seven fewer ordinary tests because existing internal `clone()` tests are guarded by `#if DEBUG`. Deprecation warnings from old Views remain, consistent with the decision not to remove old tests before replacement coverage is accepted; they are not failures of the value-access group. The current branch uses Swift tools version 6.4, so these results are not build evidence for a Swift 6.2 configuration.

#### 借用参照群の受入結果（BARE-038）

For Swift 6.4+ `reference(at:)` and `MutableRef.pointee`, direct specification tests cover reads and writes to owner storage in dimensions 1D–4D, destruction counts when replacing reference-type elements, 20 negative/upper-bound cases across every axis and dimension, and the `AcCollections` facade path. Death Tests require the same exact Swift trap signal as the value-access group.

`Utilities/Maintenance/CompilerDiagnostics/BareArrayMutableRefLifetime/` contains one compile-pass case within a valid owner scope and four compile-fail cases returning a reference in dimensions 1D–4D beyond its owner. They were integrated into the diagnostic script, which confirmed all four are rejected with `lifetime-dependent value escapes its scope`. The three old View-escape fixtures and three owned-writeback exclusivity fixtures were retired when their deprecated public surfaces were removed.

Debug passed 40 ordinary tests and 51 Death Tests; Release passed 33 ordinary tests and 51 Death Tests. Facade reachability also passed. This completed direct Test as Specification coverage for the value-access group and the Swift 6.4 borrowed-reference group separated by the audit.

## Task

- ID: `BARE-016`
- 種別: `DISCOVERY`
- 担当: Codex
- 現在の中間ゴールへの近さ: `DIRECT`

The Task Registry is authoritative for current status, ownership, and resumption conditions.

### 実行内訳

| 内訳 | 内容 | 状態 |
| --- | --- | --- |
| A | Quality Profileの現在性監査と必要なリフレッシュ | 完了（リフレッシュ不要） |
| B | 公開契約・実装・Test as Specificationの照合 | 完了 |
| C | 現行test・build・安全性証拠の取得 | 完了 |
| D | 性能証拠・CI構成・利用経路の照合 | 完了 |
| E | QR-01〜QR-06の評価と後続task候補の分離 | 完了 |

## 目的

Make the current implementation quality of BareArrayModule assessable against higher-level requirements QR-01–QR-06, using current specifications and independent evidence.

At the start of the assessment, check whether the Quality Profile itself is current. If its higher-level requirements, public contracts, scope, or evidence boundaries have a problem, refresh the Profile before beginning the assessment. Do not treat the Profile as a fixed premise; if the assessment refutes it, return to reviewing the Profile.

Do not carry forward conclusions from the previous assessment. Classify each quality claim as one of the following:

- 確認済み
- 未達
- 未検証
- 対象外
- 受容済みの残余リスク

## 対象

- Public APIs, implementation, Test as Specification, and documentation comments for owning 1D–4D types and non-owning 1D–3D Views
- Boundaries for storage, initialization, dimensions, offsets, subscripts, writeback, element lifetime, View lifetime, and Sendable
- Benchmark targets, ongoing measurement configuration, and currently available performance evidence
- SwiftPM, `AcCollections` reexports, and the single-file path for competitive programming
- Toolchains, platforms, build configurations, traits, and tests actually used by CI
- Current evidence boundaries for strict memory safety, Sanitizers, Death Tests, and `-Ounchecked`

## 対象外

- New decisions about public contracts, performance targets, comparison thresholds, or residual-risk tolerance
- Incorporating unresolved matters into product contracts based on an agent's judgment
- Implementing fixes for gaps discovered during the assessment
- Quality assessment of modules other than BareArray
- Implicitly resuming frozen performance measurements, View-lifetime work, storage redesign, or strict-memory-safety work

## Quality Profile現在性監査

The assessment began on 2026-10-11 on branch `develop/misc/55`.

### 結果

It was determined that the current Quality Profile did not need refreshing.

- Its mapping to QR-01–QR-06 matches the current higher-level quality requirements.
- The four owning types, three non-owning View types, and `BareArray.swift` listed in scope match the current source.
- The eight numbered Test as Specification groups match the current test layout.
- Performance measurement, View lifetime, concurrent use, strict memory safety, and `-Ounchecked` are separated as unresolved areas; this does not preempt the current Registry or audit records.
- Since the Profile-preparation commit `74deff9e`, there have been no semantic changes to BareArray source or Test as Specification. Feedback after the assessment began added `.strictMemorySafety()` to the BareArrayModule target for observation. This does not change the strict-memory-safety evidence boundary already set by the Profile; it updates only the result of the current assessment.
- The Profile does not contain the current assessment; it defines only assessment categories and required evidence items. Therefore, these results do not need to be added to the Profile.

This finding does not make the Profile permanently fixed. If later review refutes its scope, contracts, or evidence boundaries, stop the assessment and return to this section.

## 作業

1. Compare the Quality Profile's scope, quality claims, and evidence boundaries against higher-level requirements, source, tests, and the Registry.
2. Extract the claims to assess for each of QR-01–QR-06.
3. Connect each claim to the relevant public contract, design contract, Test as Specification, measurements, and CI configuration.
4. Check the evidence's currency, configuration, execution results, counterevidence, and what it can establish.
5. Classify each claim and distinguish Verification from Validation.
6. Separate gaps into `DISCOVERY`, one-decision `DECISION` tasks, post-policy `EXECUTION` tasks, or existing tasks.
7. Show each follow-up candidate's necessity and proximity to the current intermediate goal, and present only necessary items as Registry candidates.

## 成果物

Record the current assessment here. If lengthy investigation logs or rerun data are needed, separate them into appendices referenced from this document; do not establish the same conclusion as authoritative in multiple places.

At minimum, record the quality claim, corresponding higher-level requirement, authoritative specification, evidence and configuration, assessment category, rationale, counterevidence or unverified scope, residual risk, and necessary follow-up candidates.

## 完了条件

- The Quality Profile's currency has been checked and, if needed, refreshed before assessment.
- At least one current assessment is recorded for each area QR-01–QR-06.
- Validation of competitive use, C/C++-level performance, or adoption in general Swift development is not inferred from Verification.
- Unresolved matters involving View lifetime, Sendable, strict memory safety, and `-Ounchecked` have not been closed based on an agent's judgment.
- Unmet, unverified, decision-pending, and execution-insufficient items are distinguished and separated into follow-up candidates under the one-decision-per-task rule.
- The user can review the assessment results and follow-up candidates.

## 現行評価

The assessment date was 2026-10-13. It did not inherit conclusions from the previous quality assessment; it evaluated the source, Test as Specification, package configuration, benchmarks, workflow, and run results after checking their currency.

| Higher-level requirement | Quality claim | Assessment | Current evidence | Unverified scope / residual risk |
| --- | --- | --- | --- | --- |
| QR-01 Correctness | Initialization, dimensions, offsets, coordinate value access, borrowed references, and destruction follow the public contract | Confirmed | After removing deprecated public surfaces, 34 current ordinary tests and 26 Death Tests passed. Direct specification groups for coordinate value access and Swift 6.4 borrowed references are retained. | Confirmed only for finite inputs/configurations; not a mathematical proof for arbitrary dimensions or element types. |
| QR-02 Performance efficiency | Implementation complexity and contiguous-storage rationale match the public contract | Confirmed | The four owning types allocate space for the element count in one operation. Coordinate value access and borrowed-reference creation use a constant number of offset calculations; initialization and destruction scale with element count. The benchmark package built successfully. | Checks of implementation structure and build do not establish runtime, allocation cost, or optimization results. |
| QR-02 Performance efficiency | Performance is comparable to C/C++ standards | Unverified | BareArray-specific two- and three-dimensional sequential-access benchmarks are registered in CI. | External comparison with C++ nested vectors and an accepted performance ratio remain undecided. |
| QR-03 Safety | Owned storage, element lifetime, coordinate bounds rejection, and borrow lifetime behave as specified | Confirmed | Element lifetime, bounds on every axis and dimension, and owner-dependent lifetime are directly specified for coordinate value access and borrowed references. The current 60 tests passed after deprecated surfaces were removed. | Evidence covers finite tested paths, not arbitrary element types, dimensions, or operation sequences. |
| QR-03 Safety | Public API safety boundaries hold under strict memory safety | Confirmed | The four owning types and `MutableRef` are classified as `@safe`; `.strictMemorySafety()` is applied to BareArrayModule. Build and runtime tests passed, and the borrow-lifetime compiler fixture is retained. | Compiler diagnostics and finite execution paths do not prove semantic safety for concurrent use. |
| QR-03 Safety | Guarantee boundaries for concurrency, including `@unchecked Sendable`, and `-Ounchecked` are acceptable | Unverified | Unresolved scope is separated in the Quality Profile and public comments. | Concurrent-use Validation involving data races and behavior with precondition checks omitted remain unevaluated. |
| QR-04 Comprehensibility | Users can understand coordinate order, initialization, value access, borrowed references, and failure conditions from public documentation | Partially confirmed | The public Quality Profile and source comments were synchronized with the public surface after deprecated APIs were removed. | DocC regeneration and user-comprehension Validation with general users have not been performed. |
| QR-05 Usability | The package can be installed through SwiftPM and `AcCollections` and used in supported environments | Confirmed | Debug and Release builds, one facade reexport test, standalone typecheck of `BareArray.swift`, and DocC generation succeeded. A temporary external SwiftPM consumer built and ran direct module import, `AcCollections` import, coexistence with `PermutationModule`, and the standard `MutableRef` path. | The current package exposes only `AcCollections` as a library product; direct module import demonstrates transitive visibility. A permanent fixture and other platforms/toolchains remain unchecked. |
| QR-05 Usability | Useful for competitive programming | Unverified | The source includes permission for copy-and-paste use and a single-file candidate. | Validation evidence for a real problem, submission, runtime, and memory use was not checked. |
| QR-06 Sustainability | The public surface, correctness, lifetime, and termination contracts can be rechecked after changes | Partially confirmed | Numbered Test as Specification, direct coordinate-access groups, compiler diagnostic fixtures, and Debug, Release, and ASan CI jobs exist. Four BareArray performance workloads are registered in the ordinary CI library. Remote CI for PR #192, including these jobs, was all green; BareArrayModule DocC generation also succeeded individually. | The CI documentation job covers only RedBlackTreeCollections; no automated path continues to regenerate DocC after changes to BareArray documentation comments. |

## 実行記録

- On 2026-10-11, ran `swift test --disable-sandbox --filter BareArrayModuleTests`.
- All 35 ordinary XCTest cases passed with zero failures.
- All 42 Swift Testing Death Tests passed with zero failures.
- The build emitted an environment warning that the SwiftPM user cache was not writable, but the product build and tests succeeded.
- `swift test -c release --disable-sandbox --filter BareArrayModuleTests` passed 28 ordinary tests and 42 Death Tests.
- `swift test --disable-sandbox --sanitize address --filter BareArrayModuleTests` passed 35 ordinary tests and 42 Death Tests. Build warnings came from known tests in another module; no BareArray sanitizer failure occurred.
- `AcCollectionsTests.test_importAcCollections_exposesBareArray` passed.
- BareArrayModule DocC generation succeeded.
- Standalone Swift 6 typechecking of `BareArray.swift` succeeded.
- Standalone typechecking with strict memory safety exited with code 0 but reported 27 warnings: unsafe storage in seven types and 20 unsafe expressions. The previous investigation's count of 22 is not the current count.
- Following assessment feedback, `.strictMemorySafety()` was added to the BareArrayModule target for observation. Its adoption status was not classified.
- Explicit `unsafe` scopes were added for allocation, pointer passing, and pointer comparison during writeback, resolving 20 unsafe-expression warnings. Strict typechecking and a Debug build through the Package path then retained warnings only for seven public types.
- After this change, 35 ordinary tests and 42 Death Tests still passed.
- No BareArray-specific workload or library registration was found under `Benchmarks/`.
- After reopening the 0.6.0 quality assessment, the current implementation passed 35 Debug ordinary tests, 28 Release ordinary tests, 39 Death Tests in each configuration, and compiler diagnostic fixtures for three View-lifetime escapes and three owning-array writeback exclusivity cases.
- Under Address Sanitizer, 35 ordinary tests and 39 Death Tests passed; there was no sanitizer failure attributable to BareArray.
- One facade reexport test passed, and BareArrayModule DocC generation succeeded.
- An external SwiftPM consumer using candidate `693b1bab` as a local-path dependency was run with Apple Swift 6.4, macOS 27.0.1, arm64, and Debug configuration. Four executables checked direct module import, `AcCollections` reexport, coexistence with `PermutationModule`, and multiple in-scope updates to standard `MutableRef.value` reflected in owner storage. Because inner dimensions are not available as public properties, the consumer had to retain the shape; this was left as a candidate issue for comprehensibility validation.
- View lifetime under Swift 6.4's experimental Lifetimes feature and strict memory safety were treated as confirmed. Concurrent use, including `@unchecked Sendable`, `-Ounchecked`, general Swift use, competitive use, and external performance remain unverified; success was not inferred from this Verification.

### 外部性能判定taskの見直し（2026-10-14・当時の判断）

> 現在の供用区分は冒頭の2026-10-15訂正を参照。この節の対象外という前提を現行評価へ適用しない。

At that time, BareArray became a maintenance module outside the 1.0 offering. Under that offering class, there was no need to define a fixed performance ratio against C++ nested vectors and run a formal assessment as a prerequisite for 1.0 conformance. Accordingly, `BARE-032` and `BARE-007` were marked `EXCLUDED`.

This did not mean that external performance had been verified. Existing benchmarks and CI regression workloads were retained as evidence for observing performance changes in the maintained implementation. If returning to an offering is considered in the future, design a new assessment based on the implementation, usage purpose, workload, and comparison target at that time; do not reuse the fixed-threshold task from this record.

## 後続task候補

| ID | 種別 | 近さ | 内容 | 必要性 |
| --- | --- | --- | --- | --- |
| `BARE-006` | 既存`DISCOVERY` | `DIRECT` | BareArray多次元access性能測定設計 | 2D・3Dの連鎖accessをC++ nested vectorと同一条件で測るworkloadと、CI回帰・外部assessmentの境界を確定済み |
| `DOC-010` | 既存`DISCOVERY` | `NEAR` | ElementBufferの定性的性能表現の再検討 | 旧連鎖subscript・非所有Viewを含む比較意図を履歴として分離し、現行の座標value access・借用参照と未測定の外部性能を混同せず、利用者向け表現を再検討する |
| `BARE-017` | `DISCOVERY` | `DIRECT` | BareArray利用Validation scenario設計 | QR-04・QR-05について、一般Swift利用と競技利用の代表scenario、導入経路、観測方法、必要な後続判断を整理する |
| `BARE-028` | `EXECUTION` | `DIRECT` | Claude手直し後の差分再検証 | Claudeのレビューと手直しが受け入れられた後、変更影響範囲の検証を再実行して完了ゲートへ渡す |

`BARE-006` was resumed under a later user instruction and the design below was finalized. This assessment does not unfreeze `DOC-010`. `BARE-017` does not settle any decisions; if general use and competitive use have different execution or decision boundaries, separate them into follow-up tasks. `BARE-028` remains frozen until Claude's review and fixes are accepted.

## 多次元access性能測定設計

- ID: `BARE-006`
- 種別: `DISCOVERY`
- 担当: Codex
- 現在の中間ゴールへの近さ: `DIRECT`

### 測定対象

The measurement targets chained-subscript access that reads and writes every element in storage order in two- and three-dimensional dynamic programming, a common competitive-programming workload. Measure `array[y][x]` and `array[z][y][x]`, the public BareArray access paths through non-owning Views. One dimension does not expose differences between nested containers, and four dimensions would add a dimension without adding a representative usage scenario, so neither is included.

Define two workloads for each dimension.

| Workload | Operations inside measurement | Operations outside measurement |
| --- | --- | --- |
| Sequential read checksum | Read all elements in storage order using chained subscripts and accumulate into `Int` | Shape construction, initialization with sequential values starting at zero, checksum verification |
| Sequential write | Write sequential values starting at zero to all elements in storage order using chained subscripts | Shape construction, zero initialization, checksum verification over all elements |

Do not include allocation, initialization, shape construction, or post-run verification in the measured time. Separating reads and writes helps localize which access path changed when a regression occurs.

### inputとshape

Treat the benchmark's positive `size` as the total element count and distribute its prime factors as evenly as possible among the axes. Use two axes in 2D and three in 3D, growing from the innermost axis, and keep their product exactly equal to `size`. For prime `size`, some axes will be 1; do not round the input. This compares paths with different dimensionality at the same element count and avoids cubing the CI input limit.

Define the checksum as the sum of `0 ..< n` for `n` elements, and verify the same result for Swift and C++. Use `std::intptr_t` in C++ to match the word width of Swift `Int`.

### 比較境界

- For CI regression checks, register only the four Swift BareArray workloads in the existing `CI.json` and detect regressions between base and current.
- For external assessment, add corresponding C++ nested `std::vector` workloads with the same shapes, element values, traversal order, and checksum as Swift. Do not include C++ workloads in ordinary CI.
- Limit assessment to macOS and store the dedicated library, environment details, raw JSON, and PNG charts under `Benchmarks/QualityAssessment/macOS/BareArray/`.
- Do not make a performance ratio for “comparable to C++ standards” an input to the measurement design. After preliminary measurements of corresponding workloads, provide the observed differences and variability as evidence for a user-decision task.

### 完了結果

The target operations, shapes, measured and unmeasured work, checksum, Swift/C++ correspondence, and boundaries between CI regression and external assessment were finalized. This design did not require a user decision; the next step was registering the Swift workloads for CI regression.

### CI回帰Benchmark登録結果

- ID: `BARE-029`
- 種別: `EXECUTION`
- 担当: Codex
- 現在の中間ゴールへの近さ: `DIRECT`

Four workloads were added to `BareArrayBenchmarks.swift`: two- and three-dimensional sequential read checksum and sequential write. They were registered with the benchmark tool and `CI.json`. To keep generated benchmark sizes between powers of two equal to the total element count, each positive size is factored and distributed as evenly as possible among the axes.

The following run evidence was recorded:

- The Benchmarks package Release build succeeded.
- The four workloads ran directly at sizes 1, 3, and 16, with checksum validation, and succeeded.
- All 26 tasks in `CI.json` completed across 60 sizes from 1 to 64k, with zero failures.
- The output JSON recorded each of the four workloads exactly once.

Because these workloads did not exist in 0.5.3, a base/current comparison in the introducing PR was not a valid acceptance condition. The merge commit aligning BareArray and OptionalArray workloads was to serve as the initial baseline; regression comparisons would start with subsequent PRs.

### C++ nested vector workloadと暫定チャート

Four C++ nested `std::vector<intptr_t>` workloads were added to match the Swift version's exact-product two- and three-dimensional shapes, contiguous traversal from the innermost axis, and checksum. They are excluded from the ordinary CI library and selectable only through the dedicated library in `BareArrayAssessment.json`.

After a Release build, the four workloads across BareArray, Swift nested Array, and C++ nested vector were run for three iterations at sizes 1, 3, and 16, including checksum validation. In addition, 12 workloads were run over 60 sizes from 1 to 64k for five cycles. Raw JSON and four PNGs containing the three series were saved under `Benchmarks/QualityAssessment/macOS/BareArray/` as provisional evidence. This confirms that the comparison path and visualization work; it is not an acceptance decision on performance ratios or a formal assessment.

`Benchmarks/run-bare-array-assessment.sh` was added to save raw JSON, four PNGs, and environment details (commit, macOS, hardware, Swift, and Clang) under one measurement ID derived from the timestamp and commit for a formal run. The script's shell syntax and the four chart input paths generated from existing provisional JSON were checked. Running the formal measurement and deciding performance ratios were left to later user decisions and execution tasks.

## Viewノンエスケーパブル化

- ID: `BARE-018`
- 種別: `EXECUTION`
- 担当: Codex
- 現在の中間ゴールへの近さ: `DIRECT`

The task was to make the three View types `~Escapable` and add the necessary lifetime dependencies to initializers returning them from owners and to chained subscripts. BareArray Views are designed as non-owning, noncopyable Views that refer to part of the storage without copying the owned storage. As ordinary `Escapable` values, the type system cannot prevent them from being retained beyond their owner; making them owning would undermine the noncopying design. Therefore, `~Escapable` was not a new option to decide in this task but an established policy whose implementation awaited Swift 6.4 availability.

Using Swift 6.4's experimental Lifetimes feature, verify that the compiler rejects Views escaping their owner, that chained subscripts and writeback still work, and how existing tests are affected. Move existing contracts that are now rejected at compile time from runtime Death Tests to appropriate compiler-diagnostic Verification.

This task itself does not decide whether public types are `@safe` or `@unsafe`. However, that classification, the storage boundary, and whether to apply strict memory safety are all prerequisites to resuming quality Verification and must not be deferred until after it.

### 完了条件

- View 3種が`~Escapable`となり、所有元と多段Viewに必要なlifetime dependencyが過不足なく付いている。
- 対応する既存subscript、連鎖アクセス、およびwritebackの有効な利用がDebug・Releaseで成立する。
- 所有元を越える保持などの無効な利用がcompiler診断で拒否され、そのVerification方法が定まっている。
- コンパイル不能となったDeath Testを、compiler診断による検証、残すruntime test、または失効したtestへ
  棚卸しし、単に`#if false`で退避した状態を残さない。
- 現在の途中差分を整理し、既存契約への影響と未確認範囲を記録する。

### 2026-10-11 途中結果と再停止点

- The three View types were made `~Escapable`; initializers borrowing the owner and initializers copying the parent View's dependency were added, along with lifetime dependencies for chained subscripts.
- The BareArrayModule production module compiled with Swift 6.4's experimental Lifetimes feature.
- The existing test expression `array[2] = array[1]` was rejected as overlapping access because the left-hand setter accesses the same owner exclusively while the right-hand View borrows it.
- Previously, the expression compiled and a runtime Death Test trapped for a writeback-position violation. Since the rejection contract was unchanged and only Verification moved from runtime Death Test to compile-time diagnostic, the temporary decision task `BARE-019` was excluded as not being a product decision.
- Implementation stopped when the user directly edited source during this work; the diff was preserved as an in-progress implementation. After the user explicitly instructed a restart, the task graph was rebuilt and work resumed through split tasks.
- Distinguish factual corrections in conversation, confirmation of existing contracts, temporary `#if false`, and product decisions. Do not register corrections of misunderstandings or changes in Verification method as new product decisions.
- An in-progress implementation made all three Views `~Escapable`; owning-array subscript results borrow the owner and chained View results copy the parent View's dependency. The BareArrayModule production target compiled.
- Two independent compile-fail fixtures were added and verified: three cases returning a View beyond its owner are rejected with `lifetime-dependent value escapes its scope`; three simultaneous reads/writes on an owning array are rejected as overlapping accesses.
- Three owning-array writeback cases were moved from Death Tests to compiler-diagnostic fixtures, removing the temporary `#if false`. The remaining 39 Death Tests passed in Debug and Release.
- Ordinary tests passed: 35 in Debug and 28 in Release. The BareArray public-surface test through the facade also passed in both configurations.
- Warnings remained for seven public types under strict memory safety. Acceptance of this in-progress implementation and verification as a formal deliverable, including its safety classification, had not been decided.
- Because treating implementation and local-check success as completion of the quality assessment was premature, `BARE-018` and its split tasks were frozen. The user would decide whether to resume quality Verification after independently closing storage, public-type safety classification, and strict memory safety as prerequisites.

### 再開までのtask graph

`BARE-018` was defined as a completion gate for accepting split results and closing the assessment record, not as a task containing its own implementation. Before resuming quality Verification, close storage, public-type safety classification, and strict memory safety as independent parallel tracks. View lifetime is part of non-escapable conversion and does not need a separate task.

| ID | 種別 | 内容 | 完了条件 |
| --- | --- | --- | --- |
| `BARE-020` | `EXECUTION` | View 3種、lifetime dependency、Package設定の整合化 | 現在の途中差分を必要最小限の正式実装へ整え、production moduleがcompileする |
| `BARE-021` | `EXECUTION` | compiler診断Verificationへの移行 | 所有配列writeback Death Test 3件を棚卸しし、暫定的な`#if false`を残さない |
| `BARE-022` | `EXECUTION` | 有効利用経路の回帰確認 | subscript、連鎖アクセス、View、writebackの有効な利用がDebug・Releaseで成功する |
| `BARE-023` | `DECISION` | storage境界の扱い | 品質検証の前提として現行storage境界を維持するか一つだけ決定する |
| `BARE-024` | `DECISION` | 公開7型の安全性分類 | 公開所有型4・View型3の`@safe`／`@unsafe`分類を一つだけ決定する |
| `BARE-025` | `DECISION` | strict memory safety採否 | `.strictMemorySafety()`適用状態を品質検証の対象とするか一つだけ決定する |
| `BARE-026` | `DECISION` | 品質検証の再開判断 | 3系統の決定後、保存した途中成果を対象として品質検証を再開するか一つだけ決定する |
| `BARE-027` | `EXECUTION` | ノンエスケーパブル化の品質検証 | 確定した前提でVerification、Validation、残余リスク、未検証領域を評価する |
| `BARE-028` | `EXECUTION` | Claude手直し後の差分再検証 | 受け入れた変更の影響範囲を再検証し、現行証拠との差分を確認する |
| `BARE-018` | `EXECUTION` | 完了ゲート | 分割成果を受け入れ、既存契約への影響と未確認範囲を本書へ記録する |

The three tracks—storage, safety classification, and strict memory safety—converge through `PARALLEL_JOIN` at the decision to resume quality Verification. Run the assessment only if resumption is decided, then pass the results to the `BARE-018` completion gate. Do not place later work such as storage redesign on the current mandatory path; organize it as a separate task only if it is shown to be necessary.

### 公開7型の安全性分類

On 2026-10-11, the four owning types and three non-escapable View types were classified as `@safe`. Raw pointers remain inside the implementation; owning types manage initialization, bounds, and destruction; and Views are treated as safe abstractions whose `~Escapable` and lifetime dependencies reject use beyond their owners. The `@unsafe` classification, which would propagate unsafe authorization to callers merely using a public type, was not adopted.

After applying `@safe` to the seven declarations, Xcode's test build succeeded and strict-memory-safety warnings for the seven public types were resolved. BareArray ordinary tests passed: 35 Debug and 28 Release; Death Tests passed: 39 in both configurations. Compiler diagnostic fixtures continued to reject three View-lifetime escapes and three owning-array writeback exclusivity cases. This completion covers only classification of the seven public types and does not decide classifications for individual members or conformances.

### strict memory safety適用

After classification of the seven public types, enabling `.strictMemorySafety()` for BareArrayModule produced no warnings indicating unapproved unsafe use; existing Debug, Release, and compiler-diagnostic fixtures also succeeded. There was no counterevidence requiring removal of the setting, and retaining it supports the higher-level quality requirement to keep checking unsafe boundaries, so it remains part of quality Verification.

This conclusion followed resolution of an apparent adoption decision that had arisen from the unresolved classification of the seven public types. No independent user decision remained; the work was completed by confirming facts and applying existing quality requirements.

On 2026-10-11, `BARE-020`, `BARE-021`, and `BARE-022` had interim evidence for implementation, diagnostics, and regression checks, but acceptance of those results and convergence into `BARE-018` had not been decided. The related tasks remained frozen until the three tracks—storage, safety classification, and strict memory safety—and the decision to resume quality Verification were completed.

### 0.6.0品質検証の結果

On 2026-10-11, quality Verification for non-escapable conversion resumed with the storage boundary, `@safe` classification of seven public types, and strict-memory-safety application established as prerequisites.

- Verification succeeded for valid-use paths in Debug and Release, Death Tests in both configurations, compiler-diagnostic fixtures rejecting invalid lifetime escapes and overlapping accesses, Address Sanitizer, facade reexport, and DocC generation.
- With the three View types made `~Escapable`, the implementation goal—rejecting escapes beyond the owner through the type system while preserving noncopying chained subscripts and writeback—held in the tested Swift 6.4 configuration.
- Under strict memory safety, no warnings for unapproved unsafe use remained after classifying the seven public types.
- Validation did not establish comprehension or adoption by general Swift users, successful real competitive-programming problems/submissions, or external performance. Do not infer these from the Verification results.
- Semantic safety of concurrent use, including `@unchecked Sendable`, `-Ounchecked`, and arbitrary element types, dimensions, or operation sequences remain unverified. The experimental status of Lifetimes in Swift 6.4 is also a toolchain-dependent residual risk.

This completed the current quality Verification required for non-escapable conversion in 0.6.0. If Claude's review and fixes are accepted, a separate task will recheck the affected scope before deciding whether `BARE-018` is complete.
