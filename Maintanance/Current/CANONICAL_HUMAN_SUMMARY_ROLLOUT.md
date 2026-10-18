# 人間向け要約の全体適用

## TL;DR（人間向け）
Registryが参照する現行正本のうち未記載のものをSol、古い資料をLunaが担当する。既存要約は維持し、本文を変えずに入口を追加する。制度・他者の声・作業中の資料は除外して報告する。

<a id="依頼"></a>
## Request
OPS-140 / 2026-10-19 / Astra. The user designated Sol, and Luna for the old material. Target manifests: Evidence/OPS-140/current.json and historical.json. Documents that already have a summary, and reserved / authority-caution documents, are in separate manifests. This applies summaries to canonical documents reachable from the Registry, not indiscriminate edits of every past file.
The heading follows the existing one: `## TL;DR（人間向け）`. One or two short paragraphs, stating the body's purpose, conclusion and the extent of its current force. Adding judgments, changing the body, or changing states is forbidden. For old material, state that it is a record of its time and not a current instruction. If unclear, report rather than forcing a conclusion. Keep leading images and existing placement rules. If another assignee is editing a file, skip it. Per-model returns go to Evidence/OPS-140/SOL_RETURN.md and LUNA_RETURN.md. No commit. Astra accepts the diffs and the grounds for each summary.

<a id="astra受入--2026-10-19"></a>
## Astra acceptance — 2026-10-19

Of the fixed manifest of 147 files, summaries were added to 72 (Sol first half 36, Sol second half 32, Luna history 4). The 42 existing summaries were kept; the 15 reserved files and the 18 excluded by the assignees were left out, following the ownership and institutional boundaries of their bodies. This was not an indiscriminate revision of historical material across the repository.

For the 68 current files, the recomputed result that bytes match except for the saved original and the inserted part was received (Evidence/OPS-140/ACCEPTANCE_CHECK.md). For the 4 history files, Astra confirmed byte equality between the HEAD original and the file with the addition removed. For meaning, the grounds and summary in each Return were checked; for the 4 history files Hime's read-only review was also received. Corrections were added: 「ユーザーの証言」 was supplied in the history EVIDENCE summary, and the remaining items of the old UI and multiple milestones were stated as the state of their time. This was not a job of re-investigating the bodies' judgments and states and updating them to the present.

Accepted as complete as the addition of summary entry points. Exclusions such as institutional documents and personal records are not automatically resumed as missing work. Commit is done separately after checking a valid approval and its scope.

Each assignee has cleaned up its dedicated temporary backups. Confirmed Hime's own ACK to WAKE-20261019-H (2026-10-18T19:03:48Z) and the end of the continuous wait. The additional summaries were not mixed into the already-approved Studio change; they were registered separately in the commit approval lane.

## Scope correction — user-owned History (2026-10-19)

The user clarified that History is for the user and the rollout is only for canonical documents. Removed the four added TL;DR blocks from History, preserving the original bodies. The earlier 72 additions are therefore 68 retained additions. Registry references alone do not authorize adding summaries to user-owned historical material. Earlier returns remain as historical records of the work, not approval to restore these additions.
