# 文書保存管理の二重化解消の検討

## TL;DR（人間向け）

文書の保存・配置維持の指定が配置維持例外表とTask Registryで二重管理になっていたのを、Registryの「（配置維持）」印へ一本化した記録。暫定保護・恒久希望の区分と付与日・記録者・理由を印に持たせ、Claudeの再確認と指摘対応を経てユーザー指示で完了した。恒久決定はユーザーに留保し、文書本体や恒久taskは削除・移動していない。

2026-10-16, Astra. OPS-053. Registration of a review task at the user's request. Owner: Astra. Not started.

<a id="目的範囲"></a>
## Purpose and scope

User supplement (2026-10-16): the designations of document storage structure and maintained targets seem to be managed twice, in the placement-exception table and the Task Registry, and the user wants to unify them by deleting, from the duplicate side, designations that the Registry can satisfy.

The aim is not shortening the table itself but examining duplication in the responsibility for the grounds for keeping documents, the maintained targets and the storage locations. Split each designation into those the Registry can satisfy and those needing their own protection or authority boundary, and show the items that can be deleted from the duplicate side and the rules that have a reason to stay. Distinguish merely having a link in the Registry from having the force to restrict moving, renaming or archiving. If a common rule is needed for the unification, present it as a minimal proposal.

What is deleted is duplicated management statements, not document bodies or permanent tasks. For each deletion candidate, map where the needed meaning of storage and authority remains.

<a id="入力"></a>
## Input

TASK_RULES_V2.md's 「正本整理時の配置維持例外」, and the rows and detailed canonicals of permanent tasks. This is not treated as a request to delete permanent tasks themselves.

<a id="順序と完了条件"></a>
## Order and completion condition

Proceed in the order: review of the placement-exception table (OPS-053) → review of Claude's startup documents (OPS-054). OPS-054 starts after the OPS-053 review result is accepted. Completing the changes proposed in the earlier stage is not required.

Until the current grounds, whether there are problems, the boundaries to keep, the options and recommendation, and the needed user decisions are recorded and the review result is accepted. A "no change needed" conclusion is possible. This time is registration only; no investigation or revision.

<a id="境界"></a>
## Boundaries

The review result alone does not lift placement protection, move or expire documents, switch the startup target, or delete permanent tasks. Revision and execution require a separately confirmed delegation. AGENTS.md is not edited. No request to Claude is issued this time.

<a id="調査返却"></a>
## Investigation and return

Not filled in.


<a id="2026-10-16-実施結果--astra"></a>
## Result, 2026-10-16 / Astra

By the user's 「自走で対処してほしい」, tidying the duplicated statements, following the review, was delegated. The earlier boundary "review only; revision separately" was updated for this tidy-up scope.

Every target in the placement-exception table except CONCEPT_DEFINITION.md already existed in the detailed-canonical column of a permanent task. However, a reference link alone cannot keep the force of the ban on moving, so 「（配置維持）」 was added to the existing paths of the targets, unifying the canonical of the target set in the Registry. Rules keep only the force of that mark and the conditions for changing it. Fixing the placement of every link of every permanent task was not generalized.

The placement and authority protection of CONCEPT_DEFINITION.md is already stated in a higher section of Rules, so only the duplicate in the exception table was removed. Other higher restrictions are also kept, and absence from the Registry is not a ground for lifting.

The full text of the old section is saved in Maintanance/Archived/PLACEMENT_EXCEPTIONS_BEFORE_OPS_053_2026-10-16.md. Compared the old target paths with the Registry marks as sets and confirmed they match. Also confirmed that every target file exists. No deletion or move of document bodies or permanent tasks and no numbering changes. No remaining mismatches or decision items were found. WAITING_USER, waiting for result confirmation and commit. The order "OPS-054 after acceptance" is kept, and it was not started this time.


<a id="独立確認後の追加決定2026-10-16"></a>
## Additional decision after the independent check (2026-10-16)

Claude's completion check was saved in the OPS-053 Return of CLAUDE_TASK.md and accepted by Astra. Then the user stated an operation in which AI grants provisional protection or permanent wishes, and they are examined later by looking at dates and elapsed days. Permanent decisions are reserved for the user. This was reflected in Rules; the Registry marks were given a kind, a granted date, a recorder and a reason, and the third tab is generated from the same marks. The existing 18 keep their force as existing designations. Their start date is unconfirmed, so it is "unknown", not to be confused with the transfer date 2026-10-16. New grants count the day as day 1. Astra confirmed model verification of the added specification (extracting 18, same day / next day / unknown date, switching the 3 tabs). It is not treated as Claude having verified this added specification. Waiting for user confirmation and commit.


<a id="追加仕様の再確認依頼2026-10-16"></a>
## Re-check request for the added specification (2026-10-16)

By the user's 「姫に戻しかな。でこみっと」, a re-check was requested as OPS-053 R2 in CLAUDE_TASK.md. The first answer and its acceptance are kept. Until the re-check return is accepted, OPS-053 is ACTIVE and OPS-054 does not start. This commit saves the added specification and the request; it does not certify that the re-check is complete.


<a id="r2受入指摘対応2026-10-16astra"></a>
## R2 acceptance and handling of findings (2026-10-16, Astra)

Accepted by the user's acceptance instruction, keeping Claude's original answer. The confirmation of the rules and of keeping the existing 18 holds. Findings 1–4 were fixed by Astra: extraction targets are not limited by extension or directory, the reason is the last field and keeps brackets and semicolons, malformed or nonexistent dates become 「日付要確認」, and a record-date column was added. The notation is also stated in Rules.

With Node's verify.cjs, in addition to the existing checks, confirmed HTML paths, root paths, multiple marks, brackets and semicolons in reasons, invalid dates, future dates, leap days and the record-date column. No visual check in a browser. It is not treated as Claude having re-verified after the fixes.

Finding 5, the kind and decision-record format after a permanent decision, is checked at the user's first permanent decision. No permanent designation is added this time, and permanent wishes are not automatically promoted. This does not prevent completing the current unification and provisional-protection operation.

By the user's 「それ済んだら完了にしよう」 and 「コミットしてね」, OPS-053 is DONE. OPS-054's prerequisite is satisfied, but it was not started this time.
