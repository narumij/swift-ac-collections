> Archived on 2026-10-16 by user instruction. Original document: `Maintanance/PermutationModule/ImplementationPlan.md`. The full record of carrying out the public API reduction is saved. The following is the judgment and result of its time, not to be used as current contracts, instructions or start conditions. Only relative links were adjusted to the new location.

# PermutationModule 削減実施記録

## TL;DR（人間向け）

ユーザーの最終決定（2026-10-03、バリアント削減）に基づいて、`PermutationModule`の公開APIを削除した実施記録。swift-algorithmsとの等価性を先に確かめてから削除し、テスト・ドキュメントを現行APIへ合わせた。ABC328Eの実提出確認も記録している。2026-10-16にアーカイブした当時の記録で、現行の契約・指示ではない。

This document records the deletion of `PermutationModule`'s public APIs, carried out based on the user's final decision (variant reduction, 2026-10-03) in `Maintanance/CLAUDE_TASK.md`.
The investigation findings before the deletion remain in
`Maintanance/Quality/Unversioned/PermutationModule/ProductReadinessAssessment.md`. The current public contract is canonical in
`Sources/NextPermutationModule/Documentation/Quality-Profile.md`, and the state of the Test as Specification reconstruction in
`Maintanance/Quality/CrossVersion/PermutationModule/RuntimeCheckedPermutationTestPlan.md` and [the past test record](../../Quality/0.6.0-1/PermutationModule/BorrowedPermutationTestPlan.md). The old COW contract's
`Tests/PermutationTests/NextPermutationsSequence/` is historical material and is not used as grounds for current conformance.

<a id="実施したこと2026-10-03完了"></a>
## What was done (2026-10-03, complete)

<a id="phase-1a--削除ゲートswift-algorithms等価性poc"></a>
### Phase 1A — deletion gate (swift-algorithms equivalence PoC)

Before deleting `unsafePermutations()` / `Permutations.All`, the deletion ground itself — "replaceable by `swift-algorithms`'
`permutations()`" — was verified.

- Temporarily enabled the `Algorithms` dependency and the
  `USING_ALGORITHMS` definition in the `PermutationTests` target in `Package.swift`.
- Added
  `testPhase1A_unsafePermutationsEquivalentToAlgorithmsPermutations` to `Tests/PermutationTests/PermutationTests.swift`, and in 7 cases — empty collection, single element, no duplicates ascending / non-ascending, descending, with duplicate values, and a
  `Collection` other than `Array` (`Range<Int>`, `Index == Int`) — compared the results, immediately turned into `Array`, with
  `Algorithms.permutations()`.
- Ran `swift test --filter PermutationTests` and confirmed a complete match in every case, including the number of results, the order and how duplicates appear
  (no counterexample).
- The temporary PoC changes (enabling the dependency, the comparison test) were removed after passing the deletion gate, together with the deletion work of Phase 1B below,
  and `Package.swift` was restored to its original state (`Algorithms` dependency commented out). The evidence remains in the commit history.

<a id="phase-1b--削除の実施"></a>
### Phase 1B — carrying out the deletion

1. First added tests for the kept `nextPermutations()` contract
   (`Tests/PermutationTests/PermutationTests.swift`):
   empty collection, single element, continuation from a start position that is not the head of a descending order, and immutability of
   already obtained results through CoW (`testNextPermutationsRetainedResultsRemainStable`).
2. Deleted the following from `Sources/PermutationModule/NextPermutations.swift`:
   - `unsafePermutations()` (Collection extension method)
   - `Permutations.All`, `.init(safe:)` / `.init(unsafe:)`, `IteratorA`, `SubSequenceA`
   - `unsafeNextPermutations()` (Collection extension method)
   - The `_unsafe` flag and aliasing path of `Permutations.Nexts` / `IteratorN`.
     `Nexts` was simplified to a single path that always does CoW, and `init` was made `internal`
     (reachable only from `nextPermutations()`).
   - `Permutations.Buffer.prepare(count:)` (used only to initialize `All`'s position index sequence, and
     deleted because it became unreferenced after deleting `All`).
3. Deleted from `Tests/PermutationTests/PermutationTests.swift` the tests that target only the deleted APIs:
   `testUnsafePermutations`, `testUnsafeNextPermutations`, the Phase 1A PoC test, and
   `testPerformance1` (which measured `unsafePermutations()`).
4. Fully rewrote the documentation to match the current APIs
   (`Specification.md`, this document, `ProductReadinessAssessment.md`). The deleted variants are recorded
   not as "options being handled" but as deleted history.

<a id="検証"></a>
## Verification

- `swift test --filter PermutationTests` — all cases succeed (2 tests after the deletion).
- `swift build` / `swift test` (repository root, normal mode) — success, no regression in existing tests.
- Temporarily enabled `COMPATIBLE_ATCODER_2025` and ran
  `swift test --filter 'AcCollectionsTests|PermutationTests'` — success
  (including the route in which `AcCollections` re-exports `PermutationModule` in compatibility mode);
  `Package.swift` restored to its original state.
- `git diff --check` — clean.

<a id="追加の削減2026-10-03完了"></a>
## Additional reduction (2026-10-03, complete)

Deleted `Tests/PermutationTests/NextPermutation.swift` (a different-generation implementation not referenced from the main `PermutationModule`, containing
its own protocol `Array: NextPermutation`, `NextPermutationUnsafeHandle`, and an algorithm operating
`UnsafeMutableBufferPointer` directly), and deleted from `PermutationTests.swift` `testPerformance00` (under `ENABLE_PERFORMANCE_TESTING`), the only user of it.
Based on the user's policy of further reducing the implementation variants to one path (via `Sources/PermutationModule/NextPermutationProtocol.swift`).

<a id="abc328e実提出確認2026-10-13完了"></a>
## Real ABC328E submission check (2026-10-13, complete)

- The user submitted to AtCoder by hand and confirmed Accepted.
- For the search results gone back and forth through real submissions, the performance history, the branches adopted and rejected, and the boundary with the product version,
  `../Technical/HumanAITuningReport.md` is canonical.
- The experiment source after convergence is saved in `Maintanance/User/PermutationBorrowedSpanExperiment.swift`.
- The purpose of a real submission in the AtCoder environment was achieved, so the user-only item is complete. The fastest 80ms branch is
  an unsafe upper-bound experiment and is not treated as grounds for adopting the product version of Permutation or as a formal external performance assessment.

<a id="当時の判断対応記録"></a>
## Record of the judgments and responses of the time

The following are judgments and results recorded for the old implementation, and do not show the current freeze state. For the current work state see the [Task Registry](../../ProgressV2/TASK_REGISTRY_V2.md).

- Support for `Sendable` was settled as a policy needed for Swift 6 and later and done for all public types.
  `IteratorN` / `SubSequenceN` conform to `@unchecked Sendable where C.Element: Sendable` on the grounds of making the shared CoW buffer `final` and detaching before mutation.
  For details see
  `Maintanance/Quality/StrictMemorySafetyReadiness.md` §9. Doc comments of the public APIs are also in place.
- `.strictMemorySafety()` is also applied permanently to `PermutationModule`. Unsafe operations of the internal Buffer were
  organized into scoped `unsafe` per ownership boundary, and 0 warnings under the strict setting were confirmed.
