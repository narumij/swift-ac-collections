# RedBlackTree Test as Spec 仕様レビュー

## TL;DR（人間向け）

赤黒木4型（Set・MultiSet・Dictionary・MultiMap）のTest as Specを、初回横断→型順のレビューと補完→最終横断の順でAstraが確認した記録（RBT-036〜046、すべてDONE）。各型の不足（参照identity、throwの伝播、Bound公開動作のRelease検査、参照寿命など）をClaudeが補い、Astraが独立実行で受け入れた。途中で範囲eraseがpredicateのエラーをtrapにする製品不具合が見つかり、4型とも修正済み。製品品質全体の合格ではなく、Linux・Swift 6.2・ASan・互換構成の全面検査は範囲外。

Written by Astra. 2026-10-15. The detailed canonical record of the user's 「4型をざっと横断 → 型順 → 最後に再横断」 (a quick pass across the 4 types → type by type → a final pass across them).
The canonical source of states and dependencies is `Maintanance/ProgressV2/TASK_REGISTRY_V2.md`. The first pass, the specification reviews of the 4 types and acceptance of the per-type supplements are complete. The final pass on 2026-10-16 recorded 2 additional verification gaps. The review is complete. The additional supplements X1 and X2 were also independently accepted on 2026-10-16, the user's commit permission was received, and RBT-046 is DONE.

<a id="目的と境界"></a>
## Purpose and boundaries

Check, against the current public contract, what the existing Test as Spec guarantees and what it does not. Emphasize missing specifications, boundary conditions and checks that a wrong implementation would also pass, rather than test counts.
Owner: Astra. Type order: Set → MultiSet → Dictionary → MultiMap. Record each stage before moving to the next.
This delegation is a review; it does not include fixing production, existing tests or the public contract, placing further orders with Claude, or resuming frozen tasks. Needed fixes are split out from the results.

<a id="入力と確認方法"></a>
## Inputs and method

- Read, as needed, `Sources/RedBlackTreeCollections/Documentation/API-Matrix.md`, `API-Matrix-View.md`, `Quality-Profile.md`, the related Design documents and current public API comments.
- Starting from `Sources/RedBlackTreeCollections/RedBlackTreeSet/`, `RedBlackTreeMultiSet/`, `RedBlackTreeDictionary/`, `RedBlackTreeMultiMap/` and `Tests/RedBlackTreeTests/`, trace to the actual contracts, tests and shared implementation. Do not fill discrepancies between documents with new specification decisions.
- Look at order, duplicates, search boundaries, insertion/removal, empty state, the valid range of Index/View, CoW and value semantics, and lifetimes of reference elements, according to the contracts each type actually has. Do not expand all combinations in advance.
- Static comparison is the basis; where it is unclear whether something holds, confirm only the needed targets by running or with the compiler. When running, check the relevant test procedure and distinguish run from not run and the target configuration.
- At each stage record the base commit and uncommitted diffs of the related files. If there are concurrent changes, re-check the affected conclusions. Do not edit Permutation's working scope.

<a id="工程と受入条件"></a>
## Stages and acceptance conditions

| ID | Scope | Goal |
| --- | --- | --- |
| RBT-036 | First pass over the 4 types | Overview shared and type-specific contracts and the placement of existing tests, and leave a map for the per-type reviews and the unchecked scope. Do not conclude quality pass/fail from the first pass alone. |
| RBT-037 | RedBlackTreeSet | Taking the first pass as input, compare Set's public contract and tests, and record gaps, false positives and boundary conditions with grounds. |
| RBT-038 | RedBlackTreeMultiSet | Carry over the shared points of the Set review and compare MultiSet-specific duplicate, order and operation contracts with tests. Do not reuse Set's results as guarantees as-is. |
| RBT-039 | RedBlackTreeDictionary | Taking the preceding reviews as input, compare Dictionary's current public contract, including key/value, updates and Views, with tests. |
| RBT-040 | RedBlackTreeMultiMap | Taking the preceding reviews as input, compare MultiMap's current public contract, including duplicate keys and values, updates and Views, with tests. |
| RBT-041 | Final pass over the 4 types | Re-check the 4 types' individual results, organize inconsistencies between types, unverified shared implementation, duplicate findings and oversights of individual reviews, and separate fix candidates from items awaiting judgment. |

The acceptance condition of each stage is to leave the target contract, the path to the tests checked, the guaranteed scope, unchecked items, and findings with grounds. If there is no problem, state the checked scope and record no findings. Do not widen the meaning to completion of implementation or a pass of overall quality.
If a new product judgment is needed, separate that point and return it to the user; do not make an undecided answer into a test specification. For findings overlapping existing tasks, give the existing ID and do not register the same work twice.
The final pass does not merely concatenate the individual reviews; it re-compares the handling of shared contracts and type-specific differences.

<a id="レビュー結果"></a>
## Review results

<a id="初回横断rbt-0362026-10-15astra"></a>
### First pass (RBT-036, 2026-10-15, Astra)

Base HEAD: `c98a0908`. No uncommitted changes in the red-black tree source and tests. Claude is concurrently changing Permutation tests, returns and Tests/TESTING.md, but those were not edited this time. Static overview only. No test runs, mutation verification or exhaustive review of all APIs.

All 4 types have numbered groups for creation, traversal, search, insertion/removal, ranges, protocols and value semantics, plus internal CoW, Index and Death Test groups. Views have an independent shared test group. It is not a situation without a shared foundation; next we narrow down the strength of checks and the guaranteed scope per configuration.

<a id="課題候補修正発注はまだ行わない"></a>
#### Issue candidates (no fixes or orders yet)

1. **Strength of Death Test exit judgments (4 types, check first)**. Each `*_99_DeathTests.swift` mixes examples that specify an exact Swift trap signal with examples that accept `.failure` and exclude SIGSEGV/SIGBUS/AddressSanitizer. Examples are MultiSet's reversed range and removed Index. The latter can also pass failures other than the intended contract check. In the per-type reviews, compare the expected stop contract and setup, and make only the needed ones candidates for stronger judgments or negative controls. This does not mean a product defect or that all Death Tests are invalid.
2. **Value observation in Map-type CoW tests (Dictionary/MultiMap)**. `test_copyOnWrite_mutatingCopyPreservesOriginal` in both types' `*_13_ValueSemanticsTests.swift` compares the final result only by key sequence. This case alone does not detect values being mixed up or changed. In the per-type reviews, check the supplement by the existing `*_98_CopyOnWriteTests.swift` and the MappedValues View tests, and make only missing public operation paths candidates. Checks of internal copy counts and independence of public values are treated as separate evidence.
3. **Correspondence of CoW and lifetimes between types (an item to check)**. Set's `*_15_ValueSemanticsTests.swift` has a case tracking sharing and divergence of reference elements and release after both copies are destroyed. The other 3 types' `*_13_ValueSemanticsTests.swift` lack the same case, but each RemovalTests has reference release tests. This alone does not establish a gap. In the per-type reviews, check how far existing tests look at holding while shared, release by the last owner, Map key/value and duplicate elements. No deep copy of reference elements is required.
4. **Empty old tests and explanation of current evidence (a confirmed documentation problem)**. Dictionary's `*_0_InitializationTests.swift` `testInitWithDuplicateKeysShouldCauseFatalError` has only comments in its body and says 「実テスト不可」 (cannot actually be tested), but `duplicateKeysInUniqueKeysInitializer_terminateProcess` exists in `*_99_DeathTests.swift`. A candidate for sorting out the old explanation and misreading of run counts, not for adding new tests as a verification gap. Set's empty removeFirst/Last tests have explanations pointing to Death Tests and, treated the same way, are not counted as gaps.

<a id="次の型別レビューへ渡す見取り図"></a>
#### Map handed to the per-type reviews

- Set: start from shared Index/Bound/View boundaries, Death Tests and observation of value semantics.
- MultiSet: in addition to points shared with Set, check duplicate counts, updates of equivalent elements and lifetimes.
- Dictionary: starting from 2 and 4 above, check value updates, the default subscript and the normal/failure paths of the duplicate-merging closure. Do not create unstated contracts such as restoring the original state on exceptions.
- MultiMap: check holding, updating and removing values per duplicate key, the MappedValues View and CoW.
- Final pass: re-compare the scope really guaranteed by shared tests, type-specific differences and configuration conditions.

The CoW tests inside closures for the 4 types make the same change to both sides, but in Set/Dictionary checking the return values, and in the Multi types also changes in counts, contribute to detection. So do not uniformly assert that "independence cannot be verified because the final results are the same". Check per type whether observation of the non-mutated side midway needs to be supplemented.
The range-membership check of MappedValues respects API-Matrix-View's current precondition and the existing RBT-026; this issue listing does not change the contract or lift a freeze. Internal CoW has conditions such as `AC_COLLECTIONS_INTERNAL_CHECKS` and Death Tests `DEATH_TEST && !COMPATIBLE_ATCODER_2025`, so distinguish the existence of tests from guarantees of running in each configuration.

The goal of the first pass — recording the map, issue candidates and the unchecked scope — is complete. Per-type detailed reviews and fixes have not started. RBT-036 is WAITING_USER, waiting for commit permission.

On 2026-10-15 the user permitted the commit. The first-pass record is saved and RBT-036 is DONE. Per-type reviews have not started.

<a id="set仕様レビューrbt-0372026-10-15astra"></a>
### Set specification review (RBT-037, 2026-10-15, Astra)

Base HEAD: `eb1d5d69`; the working tree was clean at the start. Again only issue listing: no production/test changes, test runs, mutation testing or orders to Claude. The per-type review is a static comparison of the public specification and check contents, not certification of passing in all configurations.

Checked scope: confirmed the list of Set's numbered tests and compared the bodies of Insertion, Removal, Search, RangeView, ValueSemantics, SetAlgebra, Codable and DeathTests/AdditionalDeathTests, and the internal SetAlgebraStress/Fuzz. The public Set body, Combining, SetAlgebra, Sequence and API-Matrix were the grounds for the contract. Index/Bound/traversal/protocol groups were checked mainly for test placement and existing cases; not an exhaustive verification of all assertions or all trait combinations.

<a id="s1ヒント付き挿入置換を等価だが別の参照で区別する優先"></a>
#### S1: distinguish hinted insert/replace with equivalent but distinct references (priority)

Grounds: `test_insert_withHint` (line 202) and `test_update_withHint` (line 222) in `Tests/RedBlackTreeTests/RedBlackTreeSet/RedBlackTreeSet_5_InsertionTests.swift` use only Int. Around lines 268–318 of `Sources/RedBlackTreeCollections/RedBlackTreeSet/RedBlackTreeSet.swift`, the contract is that insert returns the existing element and update replaces and returns the old element. The unhinted versions have identity checks using ComparableReference.

Gap: even if hinted update only returns the old element and skips replacing, the test passes because it is the same Int. The test also does not distinguish insert replacing an existing reference with a new reference of the same key.

Candidate: using the existing ComparableReference, check with `===` that a duplicate insert keeps the existing reference, and that update returns the old reference and replaces the stored reference. Also handle a valid but badly placed hint and endIndex, and confirm that when a shared copy is kept, the original stored reference does not change. Do not create new fixtures/APIs or an invalid-hint contract.
Acceptance: assertions that can detect a wrong implementation skipping replacement; counts, order and return values; run evidence for Debug/Release.

<a id="s2throwするpredicateの失敗経路優先"></a>
#### S2: the failure path of a throwing predicate (priority)

Grounds: Set's `filter` (`RedBlackTreeSet+Sequence.swift`), `erase(where:)` and erase over IndexRange/Bound ranges take throwing closures. Searching Set/View tests for throw, XCTAssertThrowsError and the like, no case was found that actually throws a custom error and verifies propagation (commented-out trap checks and XCTSkip are separate).

Candidate: with normal-configuration Set.filter and Set.erase(where:) as minimal targets, throw a specific error and check that the error reaches the caller and that the predicate is not continued after the throw. For filter, confirm the original Set is unchanged, and also check release of temporarily created held references. For erase, keep a copy and check that the non-mutated side's contents are kept. Do not require an unspecified full rollback or a particular intermediate state of the failed mutated side. For range versions, check during application whether they are covered by the same path, and supplement only what differs.
Acceptance: a normal control and throwing cases, identification of the expected error, applicable lifetime checks, Debug/Release. If a product defect or an exception-guarantee judgment is needed, leave a reproduction and stop.

<a id="s3集合演算のcowで非変更側のコピーを直接観測する中"></a>
#### S3: directly observe the non-mutated copy in set-operation CoW (medium)

Grounds: `testFormOperationsMutateReceiverOnly` (line 57) in `RedBlackTreeSet_98_SetAlgebraStressTests.swift` makes mutation copies from lhs and compares the results and rhs, but does not directly compare the original lhs right after each operation with the reference model sL. `assertEquiv(rhs, rhs)` is a self-comparison and is distinguished as evidence from the later sR comparison. The numbered `_10_SetAlgebraTests.swift` has content checks, but no case explicitly holding the shared original to check independence for the form operations was found.

Candidate: for each of formUnion/formIntersection/formSymmetricDifference/formDifference, hold the mutation copy, the original shared copy and rhs, and compare the expected contents of all three right after the operation. Use inputs where each operation actually changes the contents. No need to enlarge the whole existing stress test or create a new copy-count contract.
Acceptance: directly check holding of the original copy and rhs, not only the result; Debug/Release. Keep the existing reference-model comparisons and algebraic-law tests of set operations.

<a id="s4削除済みindexのdeath-testでsetup失敗を分離する中"></a>
#### S4: separate setup failure in the removed-Index Death Test (medium)

Grounds: `removed index cannot be subscripted` (line 66) in `RedBlackTreeSet_99_AdditionalDeathTests.swift` uses `firstIndex(of: 2)!` inside the child process. If the search returns nil, it becomes a Swift trap without reaching the intended reference of the removed Index, and can satisfy `.failure` and the memory-error exclusion. This is a finding about a static detection path; no negative control was run.

Candidate: distinguish this case's setup with, for example, a normal control on the parent side, and do not count search failure or failed removal as success of the intended stop. If `.failure` is kept, "just make it exit(86)" also succeeds and is not acceptable. Distinguish while keeping the existing broad stop contract, for example by explicitly rejecting the setup's specific exit code. Confirm that a temporary negative control using a broken setup fails, and restore it.
Acceptance: the normal case succeeds, the test reliably fails when setup breaks, and the existing SIGSEGV/SIGBUS/ASan exclusions are kept. Do not change the implementation's signal contract.

<a id="今回追加課題にしないもの"></a>
#### Not made additional issues this time

- The first-pass candidate about "broad Death Test exit judgments" has an intended contract. Following Tests/CLAUDE.md and AdditionalDeathTests' explanation, do not unify all cases to a specific signal. Set's staleIndex case also checks the reason string.
- Set's shared reference lifetimes have concrete checks in `_15_ValueSemanticsTests.swift`. Do not add the same content again.
- Cases doing the same insert on both sides inside a closure also check the returned inserted, and simple sharing breakage would make the later one false. Do not treat this as an invalid check.
- Set operations are supplemented by content comparisons, fixed-seed reference models and algebraic laws, and basic mutations by Fuzz. Do not claim "no verification of set operations" based only on weak smoke tests.
- The empty removeFirst/Last tests explicitly refer to Death Tests; do not double-count the gap.
- Index's external requirements, the MappedValues contract, performance re-evaluation, frozen tasks and public API changes are not included in this round's candidates.

S1–S4 are recorded as a scope from which a test-supplement request can be made concrete, but no implementation task has yet been numbered or delegated. The assignee re-checks the current diff and contract, and if it is a defect, returns it without fixing production. The review record is complete, and RBT-037 is waiting for commit permission. MultiSet and later not done.

On 2026-10-15 the user permitted committing after ordering S1–S4. RBT-042 was registered and the request posted in CLAUDE_TASK.md. RBT-037 is saved as DONE. The request input for S1–S4 is fixed, and future reviews of other types are appended in separate sections.


<a id="multiset仕様レビューrbt-0382026-10-15astra"></a>
### MultiSet specification review (RBT-038, 2026-10-15, Astra)

Base HEAD: `2fc2dc66`. The working tree was clean at the start and just before recording. Statically compared the public MultiSet body, Combining, SetAlgebra, Sequence, RangeExpression and BoundsExpression with MultiSet's Insertion, Removal, Search, Utility, SetAlgebra, ValueSemantics, RangeView, BoundExpression, Fuzz and Death Tests, and the MultiSet comparisons in CppBehaviorReferenceTests. Not an exhaustive verification of all assertions and all configurations; no test runs or mutation verification. The following are test-supplement candidates, not confirmations of product defects. Set's S1–S4 and the request input to Claude were not changed.

Unless otherwise noted, the test file names below are suffixes following `RedBlackTreeMultiSet` in `Tests/RedBlackTreeTests/RedBlackTreeMultiSet/`.

<a id="m1削除済みindexへのupdateがnilを返す契約優先"></a>
#### M1: the contract that update on a removed Index returns nil (priority)

Grounds: `update(_:at:)` in `Sources/RedBlackTreeCollections/RedBlackTreeMultiSet/RedBlackTreeMultiSet.swift` returns nil for an invalid Index or a non-equivalent element. `_5_InsertionTests.swift` checks replacement with an equivalent distinct reference, rejection of endIndex and non-equivalent elements, and holding of shared copies, but update on a removed Index was not found.

Candidate: remove one element of a duplicate group, confirm that its Index has become invalid, then update with an equivalent distinct reference. Confirm the nil return and that remaining elements and counts are unchanged. Do not make the handling of another tree's Index or internal copy counts on rejection into a new contract.

<a id="m2位置指定削除が指定した等価要素そのものを取り除く優先"></a>
#### M2: positional removal removes the specified equivalent element itself (priority)

Grounds: `test_removeAt_removesOnlyTheSelectedDuplicate` and `test_erase_returnsTheFollowingIndex` in `_6_RemovalTests.swift` check contents and return values with Int. `Tests/CppBehaviorReferenceTests/MultiSetBehaviorComparisonTests.swift` also compares positional removal, but equivalent Int64 elements have no individuality. `_5_InsertionTests.swift` has a check of `erase(exactly:)` using references, but it is a different API and conditional on configuration.

Candidate: line up three references with equal values but distinct identities, and confirm with `===` the reference returned by remove(at:) on the middle Index and the remaining references. For erase, distinguish the removal target from the returned following reference. Do not add an unstated guarantee about which individual the key-based eraseUnique chooses.

<a id="m3boundの公開動作をreleaseでも検査する中"></a>
#### M3: check public Bound behavior in Release too (medium)

Grounds: the main part of `_16_BoundExpressionTests.swift` is enclosed in `DEBUG && !COMPATIBLE_ATCODER_2025`, and public behaviors such as nil for an unresolved Bound, the empty result and no predicate call for a reversed range, and duplicate ranges are limited to Debug. Part of distance is also targeted in Release under a different condition. `_8_RangeViewTests.swift` has Index-range and equalRange checks, so range checking as a whole is not missing.

Candidate: split Bound cases that can be checked from public results alone into a part that can compile and run in Release. Keep the original conditions for internal copy counts and Debug-only validity checks, and do not remove DEBUG wholesale. Focus on duplicate ranges, unresolved Bounds and not calling the predicate for reversed ranges, and confirm what actually runs in Release.

<a id="m4throwするpredicateの失敗経路優先"></a>
#### M4: the failure path of a throwing predicate (priority)

Grounds: MultiSet's filter, erase(where:) and range erase take throwing closures, but no case intentionally throwing a custom error was found in the MultiSet tests examined. Supplementing Set's S2 does not automatically make MultiSet's public entry points verified.

Candidate: check propagation of a specific error, no predicate call after the throw, holding of the original container for filter, and holding of the shared original for mutating operations. Including duplicate elements, also confirm as needed that no temporary reference holding remains. Do not require full rollback or a particular intermediate state of the mutated side that threw. For range versions, compare implementation paths and supplement only parts differing from the shared path.

<a id="m5重複を持つ共有コピーの保持と参照寿命中"></a>
#### M5: holding of shared copies with duplicates and reference lifetimes (medium)

Grounds: `_10_SetAlgebraTests.swift` has content checks for union's duplicate count a+b, intersection's min, difference's max(a-b,0) and symmetricDifference's absolute difference, but no case directly checking the shared original right after a form operation was found. `_6_RemovalTests.swift` has release checks for distinct references, but holding and final release when the same reference is stored multiple times and shared copies diverge were not found.

Candidate: for form operations, hold the mutation copy, the shared original and rhs and check the expected contents of all three. For lifetimes, in a small case storing the same reference multiple times, check that the remaining occurrences and shared copies keep it after some occurrences are removed, and that it is released when the last holder goes away. No deep copy of reference elements or internal copy counts are required.

<a id="追加課題にしないものと反映範囲"></a>
#### Not made additional issues, and application scope

- Positions within a duplicate group for hinted insert and update to an equivalent distinct reference already have concrete checks. Do not copy Set's S1 as-is.
- meld/melding have checks of holding the shared original lhs. Do not add the same check in M5.
- Positional removal, duplicate counts and the reference-model Fuzz of basic operations remain as existing evidence. Do not say "MultiSet's duplicate handling is unverified".
- The same setup false positive as Set's S4 was not confirmed for MultiSet. Do not uniformly change the broad failure judgment of Death Tests.

When supplementing M1–M5, confirm Debug/Release runs of the related cases and leave the reasons for configuration limits. If defects or undecided specifications appear, return the grounds without changing production. At this stage no test fixes, new numbering or orders to Claude have been made. The review record is complete, and RBT-038 is WAITING_USER, waiting for commit permission.

On 2026-10-15 the user permitted committing the review record. RBT-038 is saved as DONE. The supplement work for M1–M5 has not been ordered.


<a id="dictionary仕様レビューrbt-0392026-10-15astra"></a>
### Dictionary specification review (RBT-039, 2026-10-15, Astra)

Base HEAD: `926271e1`. Five Set test files have Claude's in-progress diffs and were not changed. Compared Dictionary's public contracts in Initialize, Subscript, Combining and Sequence with the bodies of the numbered Initialization, Insertion, Removal, Utility, ValueSemantics and RangeView, internal CopyOnWrite and Fuzz, and the shared MappedValuesView. Also checked BoundExpression's configuration conditions and cases, the Death Test for duplicate initialization and the operations covered by the Cpp comparison. A static review; no test runs, mutation verification or exhaustive check of all APIs/configurations. The following are candidates for supplementing checks and do not certify product defects.

Unless otherwise noted, test suffixes indicate file names following `Tests/RedBlackTreeTests/RedBlackTreeDictionary/RedBlackTreeDictionary`.

<a id="d1default付きsubscriptの遅延評価と共有元保持優先"></a>
#### D1: lazy evaluation of the defaulted subscript and holding of the shared original (priority)

`+Subscript.swift` has the contract that reading an unregistered key evaluates the default without inserting it, and inserts on mutation. `_5_InsertionTests.swift` already has reading, append and left/right single and double rotations. On the other hand, the evaluation count via side effects of default generation, and mutation of existing/unregistered keys while keeping a shared copy, were not found. The Cpp comparison has default addition, but it does not substitute for these two points.

Candidate: with a counting default, check that no unnecessary evaluation happens for existing keys, that reading an unregistered key evaluates but does not register, and that the first mutation generates it once. Using a value-type Value and keeping the shared original, check both sides' key/value after mutating existing and unregistered keys. Internal copy counts and deep copy of reference-type Values are not required. Do not add more of the existing rotation cases.

<a id="d2throwing-closureの伝播と途中生成物の寿命優先"></a>
#### D2: propagation of throwing closures and lifetimes of intermediate products (priority)

Duplicate merging and grouping in `+Initialize.swift`, merge/merging in `+Combining.swift`, and mapValues/compactMapValues/filter in `+Sequence.swift` accept throws. Searching Dictionary tests, no case throwing a custom error into these was found. A test function's throws specification and the Cpp runner's errors are not propagation checks of the target closure.

Candidate: first target Dictionary-specific duplicate merging and value transformation, and check error identification, no closure call after the throw, and holding of the original input's key/value. Also check that reference values created midway are released. For merge, keep the shared original, but do not require full rollback of the mutated side. Check the shared and differing paths of the Sequence and Dictionary versions of merge, grouping and filter/erase and supplement what is needed. Do not expand all combinations; separate the scope that the Set/MultiSet throw checks can substitute from the scope specific to Dictionary's entry points.

<a id="d3optional-valueのnilとキー不在を区別する中"></a>
#### D3: distinguish a nil Optional Value from an absent key (medium)

`subscript(key:)` returns Value? and assigning an outer nil means removal. Existing Insertion/Utility/Fuzz mainly use Int, String and arrays, and no case where Value itself is Optional was found in the search.

Candidate: with `RedBlackTreeDictionary<Int, Int?>`, distinguish unregistered, registered nil and registered with a value by the outer Optional pattern and count/key presence. Confirm that assigning `.some(nil)` keeps the registration, that outer nil removes it, and that the defaulted read does not mistake a registered nil for unregistered. Do not treat the three states as the same with an ambiguous XCTAssertNil alone.

<a id="d4共有した参照valueの置換削除後の寿命中"></a>
#### D4: lifetimes after replacing/removing shared reference Values (medium)

`_6_RemovalTests.swift` has reference release checks for pop/removeAll/nil assignment/overwrite, and basic release with sole ownership is already checked. On the other hand, replacing/removing reference Values while keeping a shared copy, and the lifetime while the old value is held as a return value, were not found.

Candidate: share a small dictionary of reference Values, updateValue or remove on one side, and check the reference identity and contents on the other. Observe separately survival while the shared original or the extracted old value holds it, and release after the last hold is released. Control holding by the test's own local variables; do not require deep copy.

<a id="d5bound公開動作のrelease検査中"></a>
#### D5: Release checks of public Bound behavior (medium)

The main part of `_16_BoundExpressionTests.swift` is inside a DEBUG condition, so unresolved Bounds and no predicate calls for reversed ranges are Debug-only too. Separate checks of distance and IndexRange exist in Release, so do not say "no range checks at all".

Candidate: with the same policy as MultiSet's M3, separate checks of public results only from Debug-only internal observation. For Dictionary, check the corresponding values in addition to keys. Changes to shared fixtures for commonization are not ordered by this review alone.

<a id="d6空の重複初期化testの説明整理軽微"></a>
#### D6: tidying the explanation of the empty duplicate-initialization test (minor)

`testInitWithDuplicateKeysShouldCauseFatalError` in `_0_InitializationTests.swift` says 「実テスト不可」 with only comments, but `duplicateKeysInUniqueKeysInitializer_terminateProcess` in `_99_DeathTests.swift` exists. Do not count the empty test function as a run guarantee; tidy it into a reference to the actual Death Test and its enabling conditions. No need to add a new duplicate-initialization test.

<a id="初回懸念の解消と追加しない課題"></a>
#### Resolution of first-pass concerns and issues not added

- `_13_ValueSemanticsTests.swift` alone looks only at keys, but `_7_UtilityTests.swift` directly checks the original and changed values after ordinary subscript updates. The first pass's "Dictionary's CoW does not observe values" is resolved as a general gap.
- `RedBlackTreeView/RedBlackTreeView_0_MappedValuesViewTests.swift` checks values' replacement, swap, range operations and holding of the shared original's values. Do not add the same checks again. Do not change the range-membership contract or resume the frozen item.
- merging has a case using non-commutative string concatenation that checks the order of old/new values and holding of both inputs. Do not say there is no check of the merging order.
- Fuzz compares key/value with Swift Dictionary. Do not duplicate and enlarge content checks for ordinary assignment, merge, mapValues and removal.

When applying, confirm the needed Debug/Release cases and configuration conditions. If new specification judgments or defects are found, return them without changing production. This time only the review record was updated; no test fixes, numbering or orders. RBT-039 is WAITING_USER, waiting for commit permission.

On 2026-10-15 the user permitted committing the Dictionary review record and continuing to the next stage. RBT-039 is saved as DONE. The supplement work has not been ordered.


<a id="multimap仕様レビューrbt-0402026-10-15astra"></a>
### MultiMap specification review (RBT-040, 2026-10-15, Astra)

Base HEAD: `7e9960d8`. Claude's in-progress Set diffs were not edited. Compared the MultiMap body's updateValue and the Combining and Sequence contracts with the bodies of the numbered Insertion, Removal, Utility, RangeView, TransformingAndCombining, ValueSemantics and Fuzz. As auxiliary checks, looked at BoundExpression's configuration conditions and reversed ranges, Index checks, internal CoW and the relevant parts of the Cpp comparison. Static review only; not run verification, mutation verification or an exhaustive check of all APIs/configurations.

The test suffixes below indicate files following `Tests/RedBlackTreeTests/RedBlackTreeMultiMap/RedBlackTreeMultiMap`. Recorded as test-supplement candidates, not product defects.

<a id="mm1削除済みindexへのupdatevalue優先"></a>
#### MM1: updateValue on a removed Index (priority)

The body's `updateValue(_:at:)` has the contract of returning nil for an invalid Index. `_5_InsertionTests.swift` has replacing the middle of a duplicate-key group, rejecting endIndex and holding the shared original's values, but updating via a removed Index was not found. Invalidation checks of the Index itself and the nil return of this public operation are separate observations.

Candidate: from a group with the same key and different values, remove the middle, confirm the saved Index is invalid, then check that updateValue returns nil and does not change the remaining key/values. Do not transfer the normal mode's contract to another tree's Index or compatibility mode.

<a id="mm2値変換predicateがthrowする経路優先"></a>
#### MM2: paths where value transformation or a predicate throws (priority)

mapValues/compactMapValues/filter in `+Sequence.swift` and the body's and range erase take throwing closures. No intentional throw case was found in the MultiMap tests in the search. The Cpp comparison runner's throws are not a substitute.

Candidate: with inputs that distinguish each value of duplicate keys, check propagation of a specific error and no closure call after the throw. Check, on the needed paths, the original input of non-mutating operations, holding of the shared original's key/values for mutating operations, and release of temporarily created reference Values. Full rollback of the mutated side is not required. Compare implementation paths with D2/M4, and do not duplicate shared fixtures or add all combinations.

<a id="mm3重複エントリと共有コピーによる参照valueの保持中"></a>
#### MM3: holding of reference Values via duplicate entries and shared copies (medium)

`_6_RemovalTests.swift` puts distinct reference Values in duplicate keys and checks release on removal, but storing the same reference in several entries, and lifetimes held by the shared original or a returned old value, were not found.

Candidate: store the same reference in several entries and keep a shared copy; check that needed references survive removing or replacing some of them, and that they are released when the last hold is released. Also distinguish the period of holding updateValue's old value. Do not make deep copy of references or internal copy counts a contract. Ordinary positional removal with strings already distinguishes different values; do not treat that check as invalid.

<a id="mm4boundの公開動作をreleaseでも観測中"></a>
#### MM4: observe public Bound behavior in Release too (medium)

The main part of `_16_BoundExpressionTests.swift` is inside a DEBUG condition, so the public contract of no change and no predicate call for a reversed range in a duplicate-key group is also Debug-only. IndexRange, equalRange and distance have separate checks, so ranges as a whole are not unchecked.

Candidate: as with M3/D5, separate public-result checks from Debug-only internal observation. Check the value sequence and count of duplicate keys, and do not lift internal check conditions wholesale.

<a id="既存の検査で足りる点"></a>
#### Points where existing checks suffice

- The first-pass concern that "CoW looks only at keys" is resolved as a general gap by `_7_UtilityTests.swift`'s holding of the value sequence after insertion, `_5_InsertionTests.swift`'s updateValue, and `_8_RangeViewTests.swift`'s swap of the values range of the same key.
- Ordinary insertion order, hinted insertion into an equal group, remove(at:) of the middle and erase's following value are checked with distinct strings. Do not mechanically add MultiSet's M2.
- `_11_TransformingAndCombiningTests.swift` checks mapValues/compactMapValues, inserting and meld/melding holding values for duplicate keys. melding also directly checks the values of the left and right inputs.
- Fuzz checks value==key in addition to key multiplicity. It does not guarantee the order of arbitrary distinct values, but it is evaluated together with the numbered concrete examples and not simply treated as invalid.
- In addition to the shared MappedValuesView Dictionary checks, MultiMap-specific key-based ranges and swap/CoW checks of duplicate values exist. No need to change the range-membership contract.

When applying, confirm the related Debug/Release cases, and return defects or undecided specifications without changing production. No test fixes, numbering or orders this time. The review record is complete, and RBT-040 is WAITING_USER, waiting for commit permission. The final pass will compare the shared issues of M/D/MM and sort out the scope substitutable by other types' evidence and the checks of type-specific entry points.

On 2026-10-15 the user permitted committing the MultiMap review record. RBT-040 is saved as DONE. The supplement work for MM1–MM4 has not been ordered.


<a id="set返却の独立確認と範囲eraseの問題rbt-0422026-10-15astra"></a>
### Independent check of the Set return and the range-erase problem (RBT-042, 2026-10-15, Astra)

Base HEAD `f029ab36`. Confirmed Claude's Return and explicit return of occupancy. The original return text, the 5 Set tests and Tests/TESTING.md were not rewritten. Compared with the diff S1's reference identity, S2's filter/whole erase, S3's shared original and rhs, and S4's rejection of the setup exit code and the normal control. S4 is structured so that `.failure` alone does not make 86 a success. The negative control and compatibility configuration are Claude's reports, not re-runs by Astra.

Astra's independent runs: Apple Swift 6.4 (swiftlang-6.4.0.34.1), macOS arm64. With the normal lifetime checks enabled, `swift test --disable-sandbox --build-system native --filter '<4追加XCTest名>|removed index'` succeeded with 4 XCTests and 2 Swift Testing tests. The subsequent `swift test --disable-sandbox --build-system native --filter RedBlackTreeTests` succeeded with 944 XCTests and 125 Swift Testing tests / 13 suites. The first normal run failed with a manifest sandbox permission, and the retry with only disable-sandbox failed with a working-directory permission of the default build system, so it was switched to native. This is distinguished from test failures.

**Remaining problem**: Claude reproduced in a separate copy that a custom predicate error in Set.erase with a valid IndexRange/IndexRangeExpression becomes SIGTRAP. Astra read the 4 types' `+RangeExpression.swift` and the internal `UnsafeTreeV2+Erase.swift` and confirmed the same catch-all path. The internal `___erase_validate_range_if` separates range errors into `Result<UnsafeIndexV3, SealError>` and predicate errors into throws, but the public wrapper puts the call and `.get()` in the same do/catch and makes both fatalError. Run reproduction for the other 3 types, and Astra's own crash reproduction, were not done.

Fix proposal: do the internal call's `try` outside the catch-all, and convert only the failure of the returned Result to the existing invalid-range stop. Do not sort catches by error type name alone; separate the paths of occurrence. Let predicate errors propagate as they are, and keep the stop contract for invalid ranges. Regression-check propagation of a specific error for valid IndexRange and IndexRangeExpression in the 4 types, and keep the existing invalid-range Death Tests. Do not rewrite the Bound and View versions uniformly.

Following the request's prohibition on production changes, the product code was not fixed this time. The completed part is limited to S1/S3/S4 and S2's filter/whole erase, and range erase is left as unfinished. RBT-042 as a whole is not DONE; it awaits confirmation of the fix scope. No new numbering, additional orders or commit.

Independent Release check: `swift test --disable-sandbox --build-system native -c release -debug-info-format none --filter RedBlackTreeTests` exit 0. 747 XCTests and 112 Swift Testing tests / 7 suites succeeded. A configuration not generating debug information, distinguished from Claude's report of a normal Release success. The completed part is accepted within this scope, but because the range-erase problem remains, it is not treated as complete overall.

On 2026-10-15, following the user's instruction 「修正前に一度コミット」 (commit once before the fix), Claude's test additions and return and Astra's partial acceptance and problem investigation record are saved. The range-erase product code is not yet fixed, and this does not mean RBT-042 as a whole is DONE.


<a id="範囲eraseのpredicateエラー伝播修正rbt-0422026-10-15astra"></a>
### Fix of predicate error propagation in range erase (RBT-042, 2026-10-15, Astra)

The user explicitly delegated 「バグの修正」 (fixing the bug). Base HEAD `7ed1cc6b`. In the 4 types' `+RangeExpression.swift`, moved the call of the internal `___erase_validate_range_if` out of the catch-all and converted only the failure of the returned Result to fatalError. Predicate throws propagate to the caller. Range checks, the removal algorithm, the Bound/View paths and public signatures were not changed.

Added `RangePredicatePropagationTests` to each type's existing `_99_DeathTests.swift`, checking 8 cases in total for IndexRange and IndexRangeExpression. In a child process, it throws a specific error after one removal, and exits 0 only if it catches the expected error and confirms the call count and the shared original's count. A normal return that swallows the error, or a different error, fails with nonzero. The child process is used so that the pre-fix trap does not terminate the test runner. Full rollback is not required, and the child process's exit is not treated as verification of reference lifetimes.

Independent runs (Apple Swift 6.4, macOS arm64): before the fix, `swift test --disable-sandbox --build-system native --filter RangePredicatePropagationTests` failed all 8 with SIGTRAP against the expected exit 0. After the fix all 8 succeeded. This updates the other 3 types from static suspicion to run-reproduced. The subsequent `--filter RedBlackTreeTests` with the same configuration also succeeded. No trait disabling the normal lifetime checks was used. Verified including the existing invalid-range stop checks.

The cause of the stop in S2's Index-range erase is fixed. The other throwing APIs, reference lifetimes and supplements across all configurations listed in M4/D2/MM2 are not treated as complete. In compatibility mode, the changed normal APIs and new tests are conditionally excluded. Linux, Swift 6.2, ASan and compatibility configuration were not run this time. Claude's original return text is kept, and the record of this fix and verification is placed in this section.

Final verification: Debug 944 XCTests + 133 Swift Testing tests; Release, with `swift test --disable-sandbox --build-system native -c release -debug-info-format none --filter RedBlackTreeTests`, 747 XCTests + 120 Swift Testing tests; both exit 0. The existing invalid-range Death Tests were kept. Fix and verification complete; RBT-042 is WAITING_USER, waiting for commit permission.

On 2026-10-15, with the user's commit permission, the 4 types' range-erase fix, regression tests and verification record are saved and RBT-042 is DONE.


<a id="型別補完の継続とmultiset発注2026-10-15astra"></a>
### Continuing per-type supplements and ordering MultiSet (2026-10-15, Astra)

By the user's confirmation, per-type test supplements and acceptance proceed in the order Set → MultiSet → Dictionary → MultiMap, followed by the final pass. Do not mistake the earlier completion of reviews for completion of per-type supplements. Set is accepted in RBT-042. MultiSet's M1–M5 were registered as RBT-043 and ordered in CLAUDE_TASK.md. Dictionary/MultiMap supplements not ordered.

Of M4, error propagation for IndexRange/IndexRangeExpression is confirmed by the 31aa2f07 fix and regression. The new request keeps this and supplements the remaining filter/whole erase, reference holding and so on. The original review text of M1–M5 and the new request are fixed inputs. No commit permission received this time.


<a id="型別補完の直列ゲート2026-10-15ユーザー指示"></a>
### Serial gates of the per-type supplements (2026-10-15, user instruction)

Set supplement RBT-042 → MultiSet supplement RBT-043 → Dictionary supplement RBT-044 → MultiMap supplement RBT-045 → final pass RBT-041.

Each type's gate is confirmed by the formal return, the return of occupancy, independent verification and the acceptance record. Mere completion of a review or the assignee's report that "it's done" does not pass it. If unresolved items affect the completion conditions, do not order the next type until their handling is settled. Commit is distinguished as an operation requiring separate user permission.

Dictionary covers D1–D6 and MultiMap MM1–MM4; after accepting the preceding stage, the requests are made concrete by comparing with the current diff and existing evidence. Do not add duplicates of the already-fixed range-erase regression. Production and public-contract changes are not included in any supplement request. Defects are returned with evidence. Return the target Debug/Release verification, configuration differences and the unverified scope, and Astra checks independently. At registration neither type has been ordered. ACTIVE indicates valid follow-up work, not passing the gate or starting work.

The goal of the final pass is to re-compare the 4 types after supplementing and record what is resolved, remaining issues and the applicable scope of shared evidence. This registration does not change the fixed request to MultiSet.


<a id="一括発注への変更2026-10-15ユーザー指示"></a>
### Change to a batch order (2026-10-15, user instruction)

RBT-043–045 were prepared and posted as one request set in CLAUDE_TASK.md. Dictionary D1–D6 and MultiMap MM1–MM4 also have concrete scope, verification and return fields prepared. From here on, read the previous section's 「未発注」 (not ordered) and 「次型を発注」 (order the next type) as "ordered in a batch, waiting at the start gate" and "start the next type", respectively. The serial acceptance gates are kept; Astra confirms the preceding type's formal return, return of occupancy, independent verification and acceptance and opens the gate in CLAUDE_TASK. No need to write an order each time. The work content of MultiSet's M1–M5 is unchanged. The final pass is still after acceptance of the 4 types.


<a id="multiset補完の独立受入rbt-0432026-10-16astra"></a>
### Independent acceptance of the MultiSet supplement (RBT-043, 2026-10-16, Astra)

Confirmed Claude's formal Return and return of occupancy, and compared the diffs of 6 test files with M1–M5. nil for a removed Index, positional removal of equivalent distinct individuals, public Bound in Release, throw propagation and holding of the shared original, and form operations and final release of the same reference correspond to the requested scope. Existing Debug internal checks are kept, and no undecided rollback or deep-copy guarantees were added. No production changes. No points needing further fixes were found; accepted.

Astra's independent runs (Apple Swift 6.4, macOS arm64, normal lifetime checks enabled, no ASan):

- `swift test --disable-sandbox --build-system native --filter RedBlackTreeMultiSet`: exit 0, 178 XCTests + 30 Swift Testing tests succeeded.
- `swift test --disable-sandbox --build-system native -c release -debug-info-format none --filter RedBlackTreeTests`: exit 0, 769 XCTests + 120 Swift Testing tests succeeded. Confirmed that 16 MultiSet public Bound tests ran.
- Both commands used `CLANG_MODULE_CACHE_PATH=/tmp/astra-asan-module-cache`. Logs are `/tmp/astra-multiset-accept-debug.log` and `/tmp/astra-multiset-accept-release.log`.
- Claude's reported Debug total of 954 + 133 and 12 compatibility tests are treated as return evidence, not as Astra having made the same runs. Linux, Swift 6.2, ASan, compatibility Release and mutation testing not checked this time.

RBT-043 is accepted and WAITING_USER, waiting for commit permission. The start gate of RBT-044 was opened. The gates of RBT-045 and the final pass are kept.

On 2026-10-16 the user's commit instruction was received. The accepted RBT-043 is saved as DONE. RBT-044 can start; RBT-045 still waits at its gate.


<a id="dictionary補完の独立受入rbt-0442026-10-16astra"></a>
### Independent acceptance of the Dictionary supplement (RBT-044, 2026-10-16, Astra)

Confirmed Claude's formal return and return of occupancy, and compared the diffs of 5 test files with D1–D6. Default evaluation counts and value-type CoW, throw propagation and lifetimes of intermediate products, the three Optional states, lifetimes of shared references and return values, public Bound behavior in Release, and turning the empty test into a reference to the actual Death Test correspond to the request. Debug internal checks are kept and no undecided rollback guarantee is required. No points needing further fixes were found; accepted.

Independent verification on Apple Swift 6.4/macOS arm64, normal lifetime checks enabled, no ASan.

- `swift test --disable-sandbox --build-system native --filter RedBlackTreeDictionary`: exit 0, 179 XCTests + 29 Swift Testing tests succeeded.
- `swift test --disable-sandbox --build-system native -c release -debug-info-format none --filter RedBlackTreeTests`: exit 0, 794 XCTests + 120 Swift Testing tests succeeded. The 16 Dictionary public Bound tests also ran.
- Both used `CLANG_MODULE_CACHE_PATH=/tmp/astra-asan-module-cache`. Logs are `/tmp/astra-dictionary-accept-debug.log` and `/tmp/astra-dictionary-accept-release.log`.
- Claude's reported Debug total of 968 + 133 and the success of 9 new compatibility cases are return evidence, distinguished from Astra's re-runs. Linux, Swift 6.2, ASan, compatibility Release and mutation testing not checked this time.
- The static concern Claude noted about node destruction on throw is not made into a general safety proof beyond the success scope of the reference release and lifetime checks here.

RBT-044 is accepted and WAITING_USER, waiting for commit permission. The start gate of RBT-045 was opened. The final pass RBT-041 does not start until MultiMap's return and independent acceptance. The original Return was not changed.

On 2026-10-16 the user's commit instruction was received. The accepted RBT-044 is saved as DONE. By the user's wish, the request to continue with MultiMap waits until after 3:00 JST and is not started automatically.


<a id="multimap補完の独立受入rbt-0452026-10-16astra"></a>
### Independent acceptance of the MultiMap supplement (RBT-045, 2026-10-16, Astra)

Base HEAD is `8053683a`; the targets are MultiMap's 4 test files and the handoff that Claude returned along with occupancy. Compared the MM1–MM4 diffs with the request. Confirmed nil return and surviving elements for a removed Index, no calls after a throw, the shared original unchanged and release of temporary references, lifetimes of duplicate entries and returned old values, and public Bound results in Release. Debug-only internal observation and normal-mode conditions are kept. No production changes.

Astra's independent runs (Apple Swift 6.4, macOS arm64, normal lifetime checks enabled):

- `swift test --disable-sandbox --build-system native -c debug --filter RedBlackTreeTests`: exit 0, 979 XCTests and 133 Swift Testing tests / 17 suites succeeded.
- `swift test --disable-sandbox --build-system native -c release -Xswiftc -gnone --filter RedBlackTreeTests`: exit 0, 817 XCTests and 120 Swift Testing tests / 11 suites succeeded. The MultiMap Bound public checks also ran.
- The normal launch hit the environment's sandbox restriction, and the next attempt with the default build system failed to build, so it was switched to the native build. These are not counted as product defects or as successful verification.
- The compatibility configuration rests on Claude's returned run report and static comparison of configuration conditions; Astra did not re-run it. Linux, Swift 6.2, ASan, all targets and mutation verification are outside this independent check.

For `.lessThanOrEqual(k)`, both DSL.md's resolution rule and UnsafeTreeV2+BoundsExpression.swift use the position when find succeeds. There is no ground for requiring the last value of a duplicate group as a contract, and a key-only check is appropriate. The concern about wording is kept in the original return text, but it is not an undecided specification or product defect in this acceptance. The public contract was not changed.

MM1–MM4 accepted. RBT-045 is WAITING_USER, waiting for commit confirmation. With the formal returns and independent acceptance of the 4 types in place, the start condition of the final pass RBT-041 is met. The final pass itself has not yet been done.

On 2026-10-16 the user instructed a commit after compression and archiving. The accepted RBT-045 was moved to history as DONE. The final pass RBT-041 can start and has not been done.


<a id="4型の最終横断rbt-0412026-10-16astra"></a>
### Final pass over the 4 types (RBT-041, 2026-10-16, Astra)

Base HEAD: `cfd6c137`. The working tree was clean at the start. The only diff since the recent `813b286b` is Claude's 2 retrospective documents, with no changes to the target source/tests. This review is a static comparison; tests, production and public contracts were not changed, and no additional orders or numbering were made.

<a id="照合範囲と証拠"></a>
#### Compared scope and evidence

Taking the 4 types' per-type supplement and acceptance records as input, went across the numbered Insertion/Removal/Sequence, Transforming/ValueSemantics/BoundExpression/RangeView and the subprocess regressions for range predicates. Compared the related contracts in API-Matrix, API-Matrix-View and DSL with the erase implementations of the 3 shared Views and UnsafeTreeV2's Bound resolution. File names can be traced from the table and findings below. Not an exhaustive audit of all APIs and all configurations.

| Aspect | Result and grounds |
| --- | --- |
| Type-specific update/removal contracts | Each type's `*_5_InsertionTests.swift` distinguishes Set's hinted insert/update of equivalent references, MultiSet's equal-valued individuals and removed Index, Dictionary's default evaluation and the three Optional states, and MultiMap's removed Index and duplicate values. Type-specific APIs are not mechanically required of all types |
| Error propagation | Set/MultiSet's `*_1_SequenceTests.swift`, the 4 types' `*_6_RemovalTests.swift`, Dictionary's Insertion/Utility and MultiMap's TransformingAndCombining have checks of the error, stopping calls, and holding of the input or shared original. `predicateErrorPropagatesFromIndexRange` and `...IndexRangeExpression` in the 4 types' `*_99_DeathTests.swift` protect 8 paths. The gap in the shared Views is split out into X2 |
| Reference lifetimes | Set's ValueSemantics, MultiSet's multiple storage of the same reference and Dictionary/MultiMap's Removal have evidence distinguishing shared copies, returned old values and release by the last owner. Deep copy and full rollback on exceptions are not added contracts |
| Value observation in Map types | The basic case in `_13_ValueSemanticsTests.swift` is still key-centred, but it is supplemented by the shared original values in the added Removal tests, value comparisons of setter/swap in the shared `RedBlackTreeView_0_MappedValuesViewTests.swift`, and the duplicate-value swap and shared-original comparison in MultiMap `_8_RangeViewTests.swift`. Do not re-register the same gap based only on the appearance of the basic case |
| Bound configuration differences | MultiSet/Dictionary/MultiMap expose public behavior classes in Release too, with internal observation on the Debug side. Only Set remains as X1 |
| MappedValues boundary | The shared View tests check setter/swap with valid Indexes, CoW and the non-comparison path. API-Matrix-View's treatment of range membership as a caller precondition is kept. No new requirement that a valid Index outside the range always traps; left to the existing RBT-026 |
| Duplicate Bound | The explanation that `.lessThanOrEqual(k)` uses the position on successful find in DSL matches the shared implementation. MultiMap's check not requiring a specific value is appropriate. No contract of "the last of the duplicate group" is added |

<a id="x1setのbound公開動作がdebug限定のまま補完候補"></a>
#### X1: Set's public Bound behavior remains Debug-only (supplement candidate)

Grounds: `DEBUG && !COMPATIBLE_ATCODER_2025` at `Tests/RedBlackTreeTests/RedBlackTreeSet/RedBlackTreeSet_16_BoundExpressionTests.swift:8` also encloses the public-result-only `testEraseBounds`, `testEraseBoundsWhere`, `testEraseReversedBoundsRemovesNothing`, `testEraseReversedBoundsWhereRemovesNothingAndSkipsPredicate` and others. The Release-target class later in the file is distance and does not substitute for these removal checks.

Set has existing checks of ordinary lower/upperBound search in `_4_SearchTests.swift` and of Index ranges and reversed Views in `_17_RangeViewTests.swift`, so this is not a finding that Set's ranges as a whole are unchecked. The "separation of public Bound results from internal observation" done in the other 3 types is not reflected in Set, and Release-only defects cannot be detected by these cases.

Proposed supplement: as in the other 3 types, split the public-result checks into a class that can also run in Release. Do not lift conditions of internal observation such as `isValid` and `_copyCount` wholesale. Without adding new API contracts or many duplicate cases, confirm in Release especially that reversed ranges are unchanged and the predicate is not called.

<a id="x2共通view三種のthrowing-eraseに常設の例外経路テストがない補完候補"></a>
#### X2: no permanent exception-path tests for throwing erase in the 3 shared Views (supplement candidate)

Grounds: `Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeRangeView+KeyOnly.swift:274`, `RedBlackTreeRangeView+KeyValue.swift:343` and `RedBlackTreeMappedValuesView.swift:308` all have a `rethrows` `erase(where:)`. KeyValue inserts Element conversion and MappedValues inserts value extraction in their own wrappers, which do not go through the container body's `erase(_safeRange:where:)`.

The 3 normal test files in `Tests/RedBlackTreeTests/RedBlackTreeView/` have checks of normal predicates, removal and lifetimes, but no intentional throws. Searching the 4 types' RangeViewTests and related calls also found no corresponding permanent exception check. There is a record of temporarily trying a throw in the Set View during the earlier investigation, but it is not a kept regression test nor evidence for the other two wrappers.

Proposed supplement: rather than all combinations of the 4 types, prepare small cases representing the KeyOnly / KeyValue / MappedValues entry points. In a nonempty subrange, process partway and throw a specific error, and observe the error's identity, no subsequent predicate calls, not touching outside the range, and the shared original's contents unchanged. For Map types, compare values as well as keys. Do not fix rollback of the mutated side or unstated intermediate states. For needed reference lifetimes, use existing fixtures and lifetime checks, and if a product defect appears, separate the fix decision.

<a id="完了範囲と次へ渡すもの"></a>
#### Completed scope and handover

X1 and X2 are additional Test as Spec supplement candidates and do not demonstrate product defects. No new judgment of the public contract is thought to be needed, but if undecided contracts or product defects appear during supplementing, they are handled separately. No new task or Claude request has been created.

At the most recent acceptance, Debug 979 XCTests + 133 Swift Testing tests and Release 817 + 120 succeeded on the same red-black tree source/tests. Those runs were not redone this time. Success counts are not treated as filling the X1/X2 gaps. Linux, Swift 6.2, a full re-check of ASan and compatibility configuration, mutation verification of all APIs and concurrent-initialization guarantees are outside this check.

This round's review process — first pass → per-type review and supplement in order → final pass — is complete. RBT-041 is WAITING_USER (waiting for commit confirmation). This is not a pass of overall product quality or completion of the additional supplements.

On 2026-10-16 the user instructed requesting X1 and X2 from Hime and committing. RBT-046 was pre-registered and a limited request posted in CLAUDE_TASK.md. RBT-041 is DONE as a completed review. The supplement has not been executed or accepted.


<a id="最終横断の追加補完の独立受入rbt-0462026-10-16astra"></a>
### Independent acceptance of the additional supplements from the final pass (RBT-046, 2026-10-16, Astra)

Target commit `f2aa435e` (base `48a71417`). Confirmed Claude's return and return of occupancy and compared the diffs of 4 test files with X1 and X2. No product code changes.

- X1: 14 Set public Bound tests also run in Release. Existing public assertions were moved, keeping no change and no predicate calls for reversed ranges. Internal isValid, copy count and the like remain inside the Debug condition.
- X2: in subranges of KeyOnly, KeyValue and MappedValues, checks propagation of a specific error, no calls after the throw, holding outside the range, and the shared original's contents unchanged. Map types also observe values. Rollback of the mutated side and particular intermediate states within the range are not added to the contract.

Astra's independent runs: Apple Swift 6.4 (swiftlang-6.4.0.34.1), macOS arm64. Normal lifetime checks and Death Tests enabled.

- `swift test --disable-sandbox --build-system native -c debug --filter RedBlackTreeTests`: exit 0, 986 XCTests + 133 Swift Testing tests / 17 suites succeeded.
- `swift test --disable-sandbox --build-system native -c release -Xswiftc -gnone --filter RedBlackTreeTests`: exit 0, 834 XCTests + 120 Swift Testing tests / 11 suites succeeded. Also confirmed the 14 Set public Bound tests and the 3 added View tests ran and succeeded.
- Logs: `/tmp/astra-rbt046-debug.log`, `/tmp/astra-rbt046-release.log`.
- Statically confirmed the guards that exclude the changed targets in the compatibility configuration. The compatibility build success is Claude's return evidence; Astra did not re-run it. Linux, Swift 6.2, ASan, all targets and mutation verification are outside this independent check.

X1 and X2 accepted. No further fixes, undecided contracts or product defects were found. This round's 4-type review process, through the additional supplements of its final pass, is complete. This is distinguished from a pass of overall product quality. The implementation was committed by Claude on the user's direct instruction. RBT-046 is WAITING_USER, waiting for commit confirmation of this acceptance record.

On 2026-10-16 the user's commit instruction was received. The acceptance record and the standing permission for adding impressions are saved, and RBT-046 is DONE. Editing and committing the impressions document itself is done by the user.
