# Permutation module移行計画

## TL;DR（人間向け）

Permutation moduleを、新名`NextPermutationModule`を主入口、旧名`PermutationModule`を互換入口とする構成へ移した計画と完了記録。工程1〜5はローカル受入・PR #196の全job成功・main到達で完了した。candidate CI経路は未実行で、benchmark名の整理は後段に残し、旧入口の削除もしない。

Written by Astra. 2026-10-15. Base: `6f101a27`.
Input: [investigation acceptance and merge record](../Archived/PermutationMigration_2026-10-16/PERMUTATION_MIGRATION_INVESTIGATION_ACCEPTANCE.md), [naming decision](PUBLIC_API_NAMING_DECISIONS.md), [performance CI change guide](PERFORMANCE_CI_CHANGE_GUIDE.md).
Stage: plan. The user-confirmed policy below is distinguished from the step plan Astra made concrete. This document is not a record of implementation completion or CI success.

<a id="ユーザー確認済みの方針"></a>
## User-confirmed policy

On 2026-10-15 the user confirmed 「旧名は互換用」 (the old name is for compatibility) and 「2はギリギリまで遅らせる」 (delay 2 as long as possible) and instructed continuing the plan.

- The main entry is `NextPermutationModule`. The old `PermutationModule` stays in main as a compatibility entry.
- The implementation lives under the new name; the old name is a thin entry re-exporting the same implementation. Do not define implementation or types twice.
- Tidying benchmark names is delayed to a later stage. It is not a prerequisite or completion condition of the module migration. No date or release deadline is set yet.
- Do not delete the old entry or existing CI compatibility. The naming decision does not change the public contract or whether to adopt Sequence.

<a id="具体構成案"></a>
## Concrete structure proposal

Keep the `AcCollections` product. Make the target dependencies as follows; the facade source re-exports the new name.

```text
AcCollections target → NextPermutationModule（実装）
                    → PermutationModule（互換）→ NextPermutationModule
```

Proposal: move the implementation and DocC to `Sources/NextPermutationModule/`, and make the old entry a small target in `Sources/_PermutationModule/` with an explicit path. The old entry's source is basically `@_exported import NextPermutationModule`. There is no step that first adds the new name as a temporary re-export target and later reverses the dependency.

The normal version and the conditional implementation for `COMPATIBLE_ATCODER_2025` stay in the same implementation target. Keep the current compiler conditions and settings. Compatibility of the new/old module names and the 2025 compatibility mode are verified separately.

That external clients' new/old imports and type identity hold with this structure is a measured condition of the next step. Do not treat it as holding while unconfirmed.

<a id="module移行の工程案"></a>
## Step plan for the module migration

| Step | Work and grouping | Evidence to proceed / stop conditions |
| --- | --- | --- |
| 1. Fix the target before implementing | Check the current HEAD and diff, the naming decision, the normal version's generic parameter `Element`, and the guaranteed scope of the new/old entries. Reshape the current wording 「互換未決」 into a distinction between the decision to keep it and the concrete method | If there were changes after the investigation, re-check their impact. If a new specification decision is needed, stop at that point |
| 2. Make one consistent change | Align the manifest, implementation placement, old shim, facade, the normal version's generic parameter, related imports, test/compiler fixtures, the DocC catalog and headings, the DocC matrix and the current quality explanation. Also move benchmark sources' imports to the new name, but keep registered titles, libraries and measurement | One implementation, no target cycles or source duplication. New, old and facade usable at the same time. Do not put a broken intermediate state into main |
| 3. Local acceptance | Check the target tests, compiler success and expected rejections, external clients via the new name, old name and facade, passing types across, normal / 2025 compatibility mode, the benchmark release build and the list of registered tasks, and DocC generation | Keep the number, conditions and results of the checks run. Do not substitute failures or non-runs for success. Stop and fix on type splitting, contract changes or title differences |
| 4. Confirm the continuous route in a PR | Submit the above as a consistent PR unit. Confirm normal tests, per-target DocC, and that performance CI using the old baseline measures and compares to completion | Check each job's actual result. DocC has `continue-on-error`, so a green PR as a whole is not success. Confirm the candidate route with a candidate ref and run conditions suited to that workflow; state it if not run |
| 5. Check and hand over after reaching main | After the user's merge, record the reached commit, entries, verification evidence, current documents and remaining issues | The new name works as the main entry and the old as the compatibility entry, and comparisons keeping benchmark names continue. Deleting the old name or tidying benchmark names is not required |

Step 2 may be split into finer editing orders, but not into public states that do not hold midway, such as merging only the manifest first. Commit, push and merge follow the repository's operation permissions. They are not done in writing this plan.

<a id="入口ごとの確認"></a>
## Checks per entry

- From a small external client package depending only on the `AcCollections` product, check a direct import of the new name, a direct import of the old name, and a facade import.
- In a client importing both new and old, check that a value via the old entry can be passed as the new entry's type and that extensions are not ambiguous.
- Keep, with existing checks, the normal version's noncopyable / no direct initialization / non-Sequence contract, invalidation of temporary Views, and the borrowed version's lifetime constraints. Do not reuse the normal version's evidence for the 2025 compatibility mode.
- Proposal: the new module is DocC's main API explanation, and the old shim has a compatibility entry and guidance to the new module. Include both targets in the DocC matrix and check for duplicate symbols and unresolved links. Do not add a removal schedule or deprecated attribute for the old entry.
- Keep the README's ordinary example `import AcCollections` and explain the roles of the new and old entries. Do not create the SPI URL until its existence is confirmed after registration.
- Past build, DocC and performance results stay under the names of their time. Update only the current explanations and future execution paths.

<a id="benchmark名整理の後段"></a>
## Later stage: tidying benchmark names

Not started for now, and it does not block this module migration. When it becomes necessary later, settle the timing and targets with the user. This plan does not lift the freeze of the old PERM-063 and 064.

When done: check full titles and identical workloads, and first put input conversion and result normalization into both the PR `ci.yml` and the release-candidate `candidate.yml`. After that change is green, change the source registration names and library specifications together, and confirm that comparison with the old baseline completes. Do not port the current source into the baseline. Keep the existing Array-family compatibility.

<a id="次に具体化する作業"></a>
## Work to make concrete next

Turn the step plan into execution units and, after checking the current state and numbering table, prepare owners, editing scopes, verification and return destinations. Do not multiply the verification items listed in the plan into separate tasks as they are. No order to an implementer has been placed yet.

<a id="実行への接続2026-10-15"></a>
## Connection to execution (2026-10-15)

On the user's 「では、すすもう」, steps 2 and 3 were registered together as one local implementation task, `PERM-076`. [The worker request](../Archived/PermutationMigration_2026-10-16/PERMUTATION_MODULE_MIGRATION_IMPLEMENTATION.md) is handed to one worker. The 3 investigation workers have finished and are not restarted. Remote CI and reaching main are not in this worker's scope and are handled after accepting the return.

<a id="工程完了記録2026-10-15"></a>
## Step completion record (2026-10-15)

Steps 1–3 by local acceptance, step 4 by all 11 jobs of PR #196 succeeding, and step 5 by checking the main commit reached, `3ef37fc2`, are complete. The implementation is saved in `1f87e37a`, and the documents and local acceptance records in `4cd0ebc2`. The evidence and checked scope are in [the acceptance record](../Archived/PermutationMigration_2026-10-16/PERMUTATION_MODULE_MIGRATION_ACCEPTANCE.md#pr-cimain到達確認2026-10-15).

This module migration, with the new name as the main entry and the old name as the compatibility entry, is complete. The candidate CI route was not run, and its success is not included. Tidying benchmark names stays in the later stage; this completion does not start it or lift its freeze.


<a id="根拠と更新条件の追記2026-10-17--姫opus-55--ops-076第4区切り"></a>
## Grounds and update conditions, appended (2026-10-17 / Hime, Opus 5.5 / OPS-076 break 4)

Input version `1175e583b1857819e9e0b07b83a1cb5fc8be657a`. The body and original returns were not changed. Checked only by reading the fixed tree with `git show <版>:…` and the like; no runs or re-review.

| Claim | Check method and result (scope of validity) | Trigger for update |
| --- | --- | --- |
| The structure in lines 11 and 21–22 (main entry `NextPermutationModule`, compatibility `PermutationModule` → `NextPermutationModule`) | `Package.swift` line 335 has `name: "NextPermutationModule"`. Lines 346–348 have `name: "PermutationModule"`, `dependencies: ["NextPermutationModule"]`, `path: "Sources/_PermutationModule"`. This structure holds in that version | Changes to the Permutation-family targets |

Scope of validity: only the target structure matched; completion of the whole plan (the steps, CI and benchmark-name migration of line 5's 「段階：計画」) is not judged. The benchmark-name migration is within PERM-064 (ACTIVE, Codex).
