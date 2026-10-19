# Permutation benchmark task名の現行型名への移行

## TL;DR（人間向け）

Permutationのbenchmark titleに旧内部型名`Permutations.SubSequenceN`が残る問題を、workflow互換の先行導入（PERM-063）とtitle移行（PERM-064）の二段で直す当初計画の記録。2026-10-16にPERM-063はEXCLUDEDとなり、必要な互換処理はPERM-064へ統合された。本文の凍結・再開条件や新名称案は当時のもので、現行の工程は現行正本に従う。

<a id="工程統合-2026-10-16"></a>
## Process merge 2026-10-16

By user instruction PERM-063 is EXCLUDED. The needed workflow compatibility processing was merged into a preceding step within PERM-064. The statements below about PERM-063 being frozen or waiting for resumption are past organization, not current conditions. Follow [the current canonical](PERMUTATION_BENCHMARK_TITLE_MIGRATION.md). The two-stage merge and verification boundary is kept.


<a id="統合前の扱い2026-10-16の履歴"></a>
## Handling before the merge (history of 2026-10-16)

The following is the record before the process merge and is not applied as freeze or resumption conditions. For the current state and steps see the current canonical at the top.

Organized by Astra. This is a benchmark display-name tidy-up deferred to a later stage, separate from the confirmation that the completed module migration reached main. The current source's 4 titles and 2 CI registrations still contain `Permutations.SubSequenceN`. This check does not treat it as complete, and the freeze of PERM-063 is kept. PERM-064 returned to ACTIVE the same day by the user's additional instruction. Keep the preceding dependency and follow [the current canonical](PERMUTATION_BENCHMARK_TITLE_MIGRATION.md).

The proposal below to make the old type name into a new name was the plan of its time. The display name consistent with the current naming decision is settled together with the targets at resumption. Do not implement the old proposal's strings as they are. The two stages — first merging workflow compatibility and getting green, then changing titles — are kept.

The "completion of the PR deleting the old facade target" of that time is not used as a current resumption condition. Following [the module migration plan](PERMUTATION_MODULE_MIGRATION_PLAN.md), it is made concrete when, at a later stage, the user settles the timing and targets and explicitly resumes it. Completing the module migration alone does not resume it.

<a id="当初の計画"></a>
## Original plan


<a id="目的"></a>
## Purpose

Resolve the gap in which the current workload measures `NextPermutationsSequence.Permutation.subscript(position:)`, while the benchmark titles and
the normal CI display carry the old internal type name `Permutations.SubSequenceN`. Workloads, measurement boundaries, iteration counts,
performance thresholds and the implementation method are not changed.

<a id="当初計画時点の事実"></a>
## Facts at the time of the original plan

- `PermutationBenchmarks.swift` has 4 titles containing the old internal type name.
- The normal CI's `CI.json` registers 2 of them, batched sequential / shuffled.
- The top of the source explains that the old name was kept for continuity of results.
- The type actually measured is `NextPermutationsSequence.Permutation`; only the display name is old.
- `Maintanance/Current/PERFORMANCE_CI_CHANGE_GUIDE.md` requires, when changing task names, a two-stage boundary: first merge workflow compatibility and confirm green, then rename the titles
  in an independent change.

<a id="当時の新名称案現行採用名ではない"></a>
## New-name proposal of the time (not the currently adopted name)

Replace the old prefix `Permutations.SubSequenceN` with `NextPermutationsSequence.Permutation`. Keep the operation names and
the `(batched)` suffix.

The target titles are the following 4.

- sequential access
- shuffled access
- sequential access (batched)
- shuffled access (batched)

<a id="perm-063-workflow互換の先行導入"></a>
## `PERM-063`: introducing workflow compatibility first

1. Only if the baseline's benchmark source does not have the new prefix, convert the 2 tasks of HEAD's CI library to the old prefix.
2. After the baseline measurement, normalize the old prefix in the result JSON to the new prefix.
3. Check the current task enumeration and full titles, the old baseline input, and the full titles after normalization.
4. Merge only the workflow change, and make a green remote CI, including performance, the start condition of the next stage.

<a id="perm-064-titleとci-libraryの移行"></a>
## `PERM-064`: migrating titles and the CI library

1. Change the benchmark source's 4 titles to the new prefix.
2. Update the 「旧名を維持する」 explanation at the top of the source to the current state.
3. Change the 2 batched tasks in `CI.json` to the new prefix.
4. Confirm the 4 titles with the benchmark release build and task enumeration.
5. Confirm that measurement and comparison of the main baseline and HEAD complete and that the remote performance CI is green.

<a id="境界"></a>
## Boundaries

- Do not change or mix the performance contracts of the runtime-check version and the borrowed version.
- Do not add the 2 unbatched tasks to the normal CI.
- Do not change the workload's processing, input size, batch count, result verification or CI regression thresholds.
- Do not revive the type `Permutations.SubSequenceN`.
- Ending workflow compatibility is not a completion condition of this migration. Even after it becomes a no-op on the baseline, treat it as general compatibility processing usable for comparisons with past commits and future renames.

<a id="当時の再開条件工程統合により失効"></a>
## Resumption condition of the time (expired by the process merge)

Resume from `PERM-063` after the current PR deleting the old facade target is completed and the user explicitly states the start of the benchmark display-name migration.
There is no need to let it cut in ahead of the current intermediate goal of document drafts.
