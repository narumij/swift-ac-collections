# 0.5.0 release task

## TL;DR（人間向け）
0.5.0の到達範囲、release gate、tag、互換準備branchへの統合を記録します。互換modeを製品上の到達点とし、CI上の問題を解消してtagとbranch統合を完了しました。これは当時のrelease記録で、現在の操作許可ではありません。

最終更新: 2026-10-09 / Codex

## 目的

Define the scope specific to `0.5.0` and tag a reproducible milestone. Keep the tag point, release gate, and tag creation separate; do not implicitly treat unfinished tasks as complete.

The reusable procedure learned from this release, including the final double-check by Codex and Claude, is governed by `RELEASE_CHECKLIST.md`. This document records decisions and evidence specific to `0.5.0`.

## tag地点の判断

On 2026-10-08, by user decision, handoff of the OptionalArray audit and user-documentation work was determined to be unrelated to `0.5.0`. Do not automatically include that milestone or the related reorganization of Permutation, OptionalArray, and task-management workflow in the basis or scope of the tag point.

On 2026-10-08, by user decision, the product milestone for `0.5.0` was set to completion of Permutation's AtCoder 2025 compatibility mode. Do not proceed to the release gate until the established compatibility-mode sequence is complete.

## release gate

After reaching the tag point, Codex fixes the target commit and checks:

- Full-package Debug tests.
- Full-package Release tests.
- Death Tests needed for the `0.5.0` change contract that do not run in ordinary CI.
- Unintended changes to public API, re-export surface, or Package configuration.
- A summary of changes in the tag range and known items deferred to external dependencies, frozen, or left for 1.0.
- That all tracked files are committed and the target commit is uniquely identified.

Performance comparison is mandatory only if the `0.5.0` scope is explicitly defined to include a performance-change assessment. A successful release gate does not resolve unmeasured questions.

### 2026-10-09 初回実施結果と再検証

The product, Package, and test verification target was fixed at `faad4760` (`Document permutation compatibility mode`). The following was confirmed. A final tag candidate would add only gate results, Registry/handoff state, and CHANGELOG; the product diff would remain unchanged from `faad4760`.

- `swift test --disable-sandbox -c debug`: exit 0.
- `swift test --disable-sandbox -c release`: exit 0, including 5 Permutation, 21 OptionalArray, and 11 BareArray Death Tests.
- Compatibility configuration was initially tested using a Package trait, but the user decided it was unnecessary for the public `0.5.0` configuration, so the trait was removed. Compatibility source and specification tests would instead use a branch define in the later `prepare/compatible/2` branch.
- Product differences from `origin/main` were reviewed. The default public surface for `0.5.0` would be regular Permutation only; no Package trait would be added.
- The range since prior tag `0.4.4` contained 950 commits. `CHANGELOG.md` `Unreleased` is the summary record for product additions, changes, fixes, and removals; the compatibility mode was added there.
- The worktree was clean when verification began, and the target commit was uniquely confirmed.

Known items were retained as non-blocking for the release gate:

- The `Container.Index` requirement awaited stability in external `swift-collections`.
- Further strict memory safety review for Permutation was frozen for later work; current warnings were not treated as resolved.
- CI job separation for regular and compatibility modes would happen after tagging, once integrated into `prepare/compatible/2`. No compatibility performance measurement was planned.
- An actual ABC328E submission check remained user-only work. The official sample `33` was verified locally.
- Registry items frozen or reserved for later goals—including 1.0 quality decisions, BareArray restart, and OptionalArray quality reassessment—were not marked complete by `0.5.0`.

After the initial gate, CI showed that adding a Package trait caused the DocC plugin's symbol extraction to enable all traits, making regular DocC fail when connected to the compatibility RedBlackTree symbol graph. Keep the final tag-eligibility decision on hold until regular Debug, Release, and documentation CI, and the final diff, are rechecked after removing the trait.

After removing the trait, the CI-matching `generate-documentation --warnings-as-errors` succeeded in a clean scratch directory. A test reaching the regular Permutation API through `AcCollections` also succeeded. Re-run remote CI to make the final check of regular Debug, Release, and documentation.

Remote CI passed regular Debug, Release, documentation, and Address Sanitizer, but performance showed Permutation sequential subscript at `0.7247` versus baseline, exceeding the 30% threshold. The only regular-source product diff was `#if !COMPATIBLE_ATCODER_2025` around the public entry point, so that condition was also removed from `0.5.0`, restoring unconditional compilation matching `origin/main`. Recheck the full CI, including performance, after repushing.

Claude's independent generated-code comparison under identical macOS arm64 / Swift 6.4 Release conditions found identical hot-path instruction sequences in the baseline, conditional, and post-revert versions, with no protocol/value-witness-table references or failed specialization. This was not a Linux benchmark, so it does not establish the regression's cause; treat it only as evidence against the hypothesis that conditional compilation caused a witness-table path.

In subsequent benchmark repetitions, known green and red revisions were alternated three times each on macOS arm64. The task's median green/red score was `1.0053`, and the comparison tool found no difference in all three pairs. Per-size results varied from `0.5` to `2.024`; because the regression did not reproduce, commit bisection stopped. Check remote CI after removing the regular-source condition first; if it is red again, investigate only the recorded Linux candidate sequence.

Finally, optimizer intent was made explicit by marking the buffer-header and debug-probe initializers `@inlinable` and the buffer subscript getter `@inline(__always)`. All Debug, Release, documentation, Address Sanitizer, and performance jobs passed on PR #175 head `f01c66a6`. The release gate was completed on the `main` merge commit `0dc1bd26`, which has the same tree.

## tag作成

After the release gate succeeds, Codex presents the target commit, verification results, and known items concisely for user review. Create tag `0.5.0` after confirmation. Remote push, release-page creation, and distribution are not included automatically; obtain separate approval if needed.

On 2026-10-09, after user confirmation, annotated tag `0.5.0` with message `Release 0.5.0` was created at `0dc1bd26`. The tag was not pushed to the remote at that point.

## 互換準備branchへの統合

After creating tag `0.5.0`, merge the target commit into the existing `prepare/compatible/2` branch. Treat branch switching, merge, conflict resolution, and push as distinct externally consequential operations; immediately before execution, confirm the target commit and branch with the user. Approval to merge does not include remote push.

On 2026-10-09, after user confirmation, `main` commit `dc32159d` was integrated into `prepare/compatible/2` and merge commit `0b9de44e` was created. The older README on the compatibility branch was retained, the audited empty `EtcTests.swift` was adopted, and `COMPATIBLE_ATCODER_2025` was enabled as a package-wide define. Debug and Release tests for the full package then passed, including 21 OptionalArray and 11 BareArray Death Tests.

The DocC catalog and benchmark source for `main` do not work with the compatibility API, so the compatibility branch skips documentation and performance jobs and continues to run functional tests in Release. Internal management, design, and DocC documents were removed from the compatibility branch; branch-specific acceptance conditions were consolidated into `COMPATIBILITY_CHECKLIST.md`. The final commit through `24dfb40f` was pushed to the remote, completing the `0.5.0` compatibility-preparation branch integration.
