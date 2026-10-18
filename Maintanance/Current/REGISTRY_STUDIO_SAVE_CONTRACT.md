# Studio保存機構の試行契約・仕様化

## TL;DR（人間向け）

Studioの保存・再開・履歴・AI取込・失敗時の約束を、実装方式から分けてまとめた試行保存契約。末尾の仕様化完了記録では、既決6項目を実装と受入証拠へ照合し、未決と保証外を分離している。恒久採用、新機能の実装、通信断や強制終了への完全な復旧保証を決めたものではない。

2026-10-18 / OPS-087 / Parent OPS-048 / Owner Astra.

<a id="目的委任"></a>
## Purpose and delegation

At user direction, specify stable save promises separately from implementation. After specification, request usability proposals from 姫 (OPS-088). At this initial stage specification is in progress; the following are items to organize, not automatic permanent adoption/new guarantees.

<a id="対象"></a>
## Topics

1. Save unit: editing base and applied edits; unapplied input is not saved.
2. Edits during saving: distinguish request snapshot from later unsaved changes.
3. Refresh/resume: canonical regeneration must not delete user edits; resume saved versions.
4. History: append, not overwrite; saves from older screens must not delete existing saves.
5. Import: distinguish save/reflection, compare base/edited/current canonical, preserve conflicts; record save IDs/draft mappings/partial import to prevent duplicates.
6. Failure: no false success, retain local edits; disclose unverified guarantees such as lost responses.

<a id="調べる範囲と成果"></a>
## Investigation scope and outputs

Inputs: OPS-082/086 assignments/acceptance/evidence, RegistryApp save/resume/refresh/import implementation and guide. Compare only relevant portions; document applicability, success/failure, evidence and unknowns for each promise. Retest only gaps in existing evidence.

Write specification here and link README. Keep prior assignments/Returns as evidence; organize duplicate rules only as needed. No implementation changes; do not mandate JSON/SQLite internals.

Separate decided/unresolved handling for persistent unapplied-input recovery, choosing multiple branches, history deletion and post-partial-import resumption. Leaving explicit unresolved items can complete specification; do not invent answers.

<a id="完了条件"></a>
## Completion criteria

Six boundaries/evidence are traceable; trial contract, implementation and unresolved matters distinguishable. Define user/AI-import responsibilities so 姫 can separate permitted UI changes from protected promises. Record specification completion, fix OPS-088 inputs and issue formal assignment. Commit needs separate permission.

<a id="作業記録"></a>
## Work record

- Registered 2026-10-18; specification/evidence comparison initially incomplete.

<a id="試行保存契約-v12026-10-18--astra"></a>
## Trial save contract v1 (2026-10-18 / Astra)

Applies to Studio on the local server. This section collects saving/restoration/import promises extracted from current trial decisions, not permanent adoption. file:// download is a separate legacy path, not server-save success.

<a id="用語と状態"></a>
### Terms and states

- **Canonical source**: formal Registry/Milestones documents; screen is a projection.
- **Base**: source/baseline at edit start. Fetching current canonicals does not rewrite a saved base.
- **Unapplied input**: form content not yet applied/added to the editing document.
- **Unsaved edits**: applied edits without a successful save response.
- **Saved version**: edited result and base with save ID, not canonical reflection.
- **Imported**: save compared/processed against canonicals with import record. Partial reflection differs from whole import.

<a id="s1-保存単位と成功"></a>
### S1 Save unit and success

Save request-time base and applied edits as one unit. Exclude unapplied input and tell users. Identify successful save ID/version. Protecting unapplied input in the screen is not a persistence guarantee.

<a id="s2-応答待ち中の編集"></a>
### S2 Edits while awaiting response

Do not mark edits added during a pending save as part of the sent version. Retain them unsaved. Keep later unapplied input and explain it is unsaved too.

<a id="s3-更新再開"></a>
### S3 Refresh and resume

Separate canonical regeneration from resuming the user editing document. Refresh must not replace base/results with current canonicals. Block refresh with unsaved/unapplied input; if edits arrive while waiting, do not reload. Saved versions resume after server restart. Explicitly start anew from canonicals, retaining saved history.

<a id="s4-履歴"></a>
### S4 History

Each save adds an identifiable version, never overwriting old ones. Saving from an old parent keeps later saves and creates another branch. No expiry/import-triggered deletion. This covers ordinary saving, not complete durability against media failure or forced process termination.

<a id="s5-aiへの取込"></a>
### S5 AI import

At user request, compare saved base, edited data and current canonicals. changes is guidance; recompute differences from data. Do not silently overwrite conflicts; clear independent portions may apply first. Do not reinterpret state/connection edits as undelegated execution permission.

Check proposal duplicates and record draft→formal mappings, including merges into existing IDs. Record partial application and deferred items in work canonicals; do not mark whole save imported before all processing finishes. Then record save ID, mappings and deliberate treatment of unreflected intent; do not change original save.

Duplicate prevention relies on both responsible comparison and save-ID records. Rejecting one ID twice alone does not automatically detect duplicates across IDs/resubmitted proposals.

<a id="s6-失敗不明"></a>
### S6 Failure and uncertainty

Retain local edits on save/refresh failure; no success display. No response after disconnection does not prove no server save. Compare before/after resend to establish saved versions. Current implementation does not guarantee exactly-once handling after lost response.

<a id="実装状況証拠の境界"></a>
### Implementation and evidence boundaries

Checked revision `18e881e8` (save implementation `291d38a6`, list changes `eb15c98c`). Record-only `47cf771b` did not change implementation. At fixed revision:

| Contract | Implementation / accepted evidence | Limits |
| --- | --- | --- |
| S1/S2/S6 | RegistryApp/index.template.html save handler; serve.py save; OPS-082 acceptance; Evidence/OPS-082/smoke_v2.cjs; OPS-086/smoke_form.cjs | Primarily post-response screen behavior; no exhaustive power/capacity/disconnection tests |
| S3 | Same HTML refresh/resumeWorkspace/restart; Evidence/OPS-082/smoke_v3.cjs; OPS-086 repair acceptance | Safari unverified; forced termination does not restore unsaved input |
| S4 | RegistryApp/inbox.py append_save/latest; Evidence/OPS-082/server_trial.sh and server_trial_result.txt; OPS-082 acceptance | Single server; multiprocess exclusion/atomic fault-tolerant writes not guaranteed |
| S5 | RegistryApp/README import guide; inbox.py record_import; TASK_REGISTRY_APP.md 2026-10-18 import record | Human/AI comparison; canonical changes/import record are not one transaction |

Compared code for current scope, reused accepted evidence; no product changes/new device tests in this specification work.

<a id="未決改善余地契約を勝手に拡大しない"></a>
### Unresolved matters and improvement room (do not expand contract)

- Persistent unapplied-input restoration, autosave, branch-selection UI, permitted history deletion.
- Resume currently uses latest save across all branches, including imported versions; completed import does not switch to current canonicals. Clarifying when to start a new base after import is an improvement topic.
- Remaining differences after partial reflection and effects on other saved versions are not tracked automatically.
- Disconnection save confirmation, corrupt-save guidance, forced-exit recovery and multiprocess operation require decisions to expand guarantees.

<a id="更新条件"></a>
### Update triggers

Review when save/resume/refresh/import promises, saved input scope or history lifetime change. For presentation/internal changes, verify contract retention; do not weaken wording to match implementation casually. Compare implementation changes with fixed revision above and update evidence. README is operating guidance, this section contract, past assignments/Returns evidence.

<a id="仕様化完了2026-10-18"></a>
## Specification complete (2026-10-18)

Astra compared six decided items with implementation/acceptance evidence and separated unresolved/unsupported guarantees. OPS-087 specification complete, awaiting commit; hand to OPS-088. No new feature implementation or approval of unresolved policy.
