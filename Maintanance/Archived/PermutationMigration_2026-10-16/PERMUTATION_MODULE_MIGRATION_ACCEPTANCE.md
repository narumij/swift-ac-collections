# Permutation module移行：Astra受入記録

## TL;DR（人間向け）

Permutation module移行の実装（PERM-076）をAstraが独立照合して受け入れ、PR #196の全11 job成功とmain到達（`3ef37fc2`）まで確かめた記録。受入時に文書の誤りを直し、ワーカーの範囲外の変更は必要な追随差分として限定的に受け入れた。candidate CI経路は未実行で、benchmark名の整理・旧入口の削除・releaseは含まない。

Written by Astra. 2026-10-15. Target: PERM-076. Base HEAD: `cc87b5b8` plus the returned working diff.

<a id="結果"></a>
## Result

Received the return in which the worker stated the end of work and the return of occupancy, and accepted the implementation and local verification. This includes Astra's document corrections below. The user's commit permission on 2026-10-15 was received. The implementation and verification are saved in `1f87e37a`, and the documents, acceptance record and the Registry's DONE in `4cd0ebc2`. After that, the PR CI success and reaching main below were confirmed, completing this module migration with the new name as the main entry and the old name as the compatibility entry.

Original answer: [worker return](PERMUTATION_MODULE_MIGRATION_IMPLEMENTATION_RESULT.md). The original answer was not edited.

<a id="独立確認"></a>
## Independent checks

- Checked the manifest's new implementation target, the old re-export target and the facade dependencies. Compared the implementation Swift files with before the move and confirmed no implementation changes other than the normal owner's generic parameter `Value` → `Element` and the corresponding typealias tidy-up. The existing test diffs are import switches, with no assertions deleted.
- Confirmed by string comparison that the benchmark diff is only one import line. The CI diff only adds the new target to the DocC matrix. The benchmark library, titles and measurement are kept.
- `swift test --disable-sandbox --filter PermutationTests`: 61 normal tests and 17 Death Tests succeeded.
- `sh Utilities/Maintenance/VerifyPermutationCompilerDiagnostics.sh`: 4 normal entries and 3 expected rejections succeeded.
- Re-verified the 4 normal targets of the same fixture with `swift build --disable-sandbox --package-path Utilities/Maintenance/CompilerDiagnostics/PermutationPublicSurface --target <target>` using the scratch path `.build/permutation-surface-compiler-diagnostics-2025b` and `-Xswiftc -DCOMPATIBLE_ATCODER_2025`; all succeeded.
- Imported the new and old modules together and confirmed, with `swiftc -typecheck` on a temporary source, a function returning `PermutationModule.NextPermutations<Int>` as the same type on the new module side, and that the nested type's `Element` is Int. The module cache was in `/tmp`, and the imports came from the normal fixture's Debug output. Succeeded.
- Re-running normal Release failed with `Operation not permitted` in dSYM generation of another target. With `swift test --disable-sandbox -c release -debug-info-format none --filter PermutationTests`, 61 normal tests and 17 Death Tests succeeded. The worker's report of a successful normal Release is distinguished from the configuration difference in Astra's environment.
- `swift package --disable-sandbox generate-documentation --target <新旧各module> --warnings-as-errors` (each new and old module): both succeeded. Also checked each module identifier in the generated JSON.
- `git diff --check` succeeded. Local run logs are saved in `.build/astra-perm076-acceptance/` (regenerable untracked files). This covers macOS arm64 / Swift 6.4 only and does not mean success on Linux remote.

<a id="受入時の修正境界"></a>
## Fixes and boundaries at acceptance

- In `DOCUMENTATION_CI_PLAN.md`, the new module names had leaked into the evidence obtained on 2026-10-13. The original record of the 5 old-name targets was restored, and this time's addition of 6 continuous targets was separated into another paragraph.
- Aligned 「旧名互換は未決」 remaining in the quality profile, and 「実装配置は旧名」「名称familyは暫定」 in the current quality assessment, with the current decisions, the work diff and the verified scope.
- The worker had also changed `Utilities/Permutation/GenerateAtCoder2025Permutation.swift`, which was outside the request's editing scope. This was a scope deviation that should have been stopped and declared, and is not treated as having been permitted. In this acceptance check Astra confirmed that the change was only 2 input paths following the move, and that the generator's processing and the input source text are identical, and accepted it as a necessary follow-up diff that does not break the generation route. This confirmation is not generalized into permission to extend scope in the future.
- The benchmark release build and task list, the Xcode build, and the 5 runtime 2025-compatibility checks are the worker's reports; the same operations were not independently re-run this time. The independent checks are limited to the scope above.

<a id="後続"></a>
## Follow-up

The candidate CI route was not run this time and is not treated as a success. The benchmark-name tidy-up is left to a later stage as the user-confirmed policy says, and the old compatibility entry is kept.

On 2026-10-15 the user advised that having workers commit changes per unit makes isolating failures easier. Do not confuse one consistent PR with one commit. In the next request, make the change breaks and commit permission clear in advance. No additional operations were requested of this returner.

Original answer SHA-256: `dc3f48284193f92608b815cc0447fe520cad90128edc8b7187fad4dee9758377`.

<a id="pr-cimain到達確認2026-10-15"></a>
## PR CI and reaching main (2026-10-15)

- For head `4cd0ebc24965cf9cea3962fcbe1f9c1629875959` of [PR #196](https://github.com/narumij/swift-ac-collections/pull/196), Astra confirmed via GitHub check-runs that all 11 jobs are `completed / success`.
- Breakdown: debug, release, address-sanitizer, performance, documentation, and 6 per-target DocC jobs (AcCollections, RedBlackTreeModule, NextPermutationModule, PermutationModule, OptionalElementBufferModule, ElementBufferModule). For DocC, the success of each individual job was confirmed, not only the overall green.
- After the user's merge, origin was fetched and `3ef37fc2` (Merge pull request #196) on `origin/main` was confirmed. It was also confirmed that the PR head above is its ancestor. This is CI evidence for the PR head, not a re-run of CI on the merge commit.
- After reaching main, `develop/misc/67` was created from the same commit by user instruction. The change keeping the new-name implementation, the old-name compatibility entry and the benchmark names reached main.
- The candidate CI route was not run. The benchmark-name tidy-up, deleting the old entry, and release are not in this completion scope.
