# Registry閲覧編集試作

## TL;DR（人間向け）

Registryを閲覧・編集してJSONで返す単一HTMLの試作（OPS-051）の作業記録。ユーザーの逐次の配置・表示指定と、JSON取込による正本への反映の往復を記録し、初期の利用を受け入れて完了した。Registryへの直接書き戻しはせず状態の正本はRegistryのまま。後続の改善は恒久OPS-048で扱い、Safari実機の全組合せは検証していない。

2026-10-16, Astra. OPS-051, parent OPS-048.

The user indicated using Safari and requested a prototype. A local prototype of a single HTML + JSON is made: edit states, owners, fields, conditions and explicit dependencies, save as JSON, and ask the AI to apply it. Keep the original, the source hash, and before/after. No writing back to the real Registry and no automatic judgment of starting.

The prototype is placed in Maintanance/RegistryApp/. The snapshot from the current Registry is a copy at the time of capture, not live synchronization. Version drift must be shown, including state changes from registration and acceptance.

<a id="検証と返却"></a>
## Verification and return

Placed in [the prototype and usage](../RegistryApp/README.md). The HTML embeds a snapshot of 38 tasks and 11 edges and implements a list, a graph, editing of conditions etc., adding/removing dependencies, a change view, and JSON load/save. No external packages, communication or server needed.

verify.cjs confirmed JS syntax, the data model, before/after changes, keeping the baseline, JSON round trips, rejection of invalid dependencies and keeping unknown values. There was no permission to operate Safari's screen, so no device test could be done. Playwright's WebKit was not installed either, so the UI, downloads and appearance are unverified. Therefore it is "prototype implemented, waiting for user trial", not completed behavioural acceptance.

The JSON is a fixed snapshot captured from the Registry being implemented. OPS-051's work state is also as of capture. The app shows the version and does not do live synchronization or direct application to the source Markdown. The procedure and data format for AI application are in the README.

2026-10-16: the user preferred a launch-snippet method. Launch steps were written in the README. This commit instruction is taken as saving the work; OPS-051 stays WAITING_USER, waiting for the Safari trial.

2026-10-16 user request: added item titles of up to 2 lines to map nodes and adjusted width, height and spacing. Hover and keyboard focus show the full title, state, owner and conditions. Saved data unchanged; the distributed HTML synchronized too. The real Safari display is still not checked.

2026-10-16 user request: the task list on the left is hidden initially and can be toggled by a button at the top. When hidden, the map and details use the full width. Search and selection are kept across toggling.

2026-10-16 user request: changed placement to put independent tasks on the left and tasks with explicit dependencies toward the gates on the right. Columns are placed by the longest distance from the final gate, and independent tasks go into left columns of 8 each. Horizontal scrolling is kept. Verified the D/E | A/B/C → F fixture and that all current edges have correct direction and no overlaps. The on-screen order is not execution order or a new dependency.

2026-10-16 user correction: independent tasks were removed from the graph and shown in a separate horizontally scrolling row. The list, graph and independent row use a common selection linked to the details. The horizontal scroll position of the independent row is kept on redraw. Replaces the earlier proposal of left columns for independent tasks.

2026-10-16 user instruction: show milestones as the skeleton and tasks as branches and leaves. Captured the canonical's explicit relations with quotations. Added 6 displayed nodes and 13 relations, using the existing QUALITY-001 as the 1.0 decision node. Distinguished required, material, stage, after-arrival and resume-decision. The independent-row judgment also follows the integrated graph. Milestones are read-only and are not treated as achieved by guessing the canonical state. Verified all edge directions and no overlaps in the integrated graph, rejection of invalid references, and the specified resume decision / Validation gate. The Safari screen check still waits for the user's trial.

2026-10-16 user request: split independent tasks into two horizontally scrolling rows, ordinary and permanent, with permanent below. Uses the existing permanent flag and keeps each row's selection, detail linkage and scroll position. Verified no missing or duplicate items in the split.

2026-10-16 user request: unified the state of the graph, independent row, permanent row and left list into a lower band with a common colour scheme. ACTIVE green, waiting for user yellow, waiting for external blue, frozen grey-blue, user-only purple, candidate orange, done a deeper pale green, excluded/history greys. The state is also written as text; unknown states use a neutral colour and keep their value.

2026-10-16 user designation: show PERM-079 between MS-060 and MS-070. A display-only placement constraint; no required dependency on 0.7.0 or execution deadline is added. Verified left/right positions.

2026-10-16 user designation: to reduce line crossings, moved RELEASE-078 to the top of the same column, above RELEASE-075. Dependencies unchanged; verified vertical positions.

2026-10-16 user designation: placed PERM-079 above the skeleton. Shifted milestones and ordinary task rows down to make room. Kept the horizontal position between MS-060 and MS-070 and the dependencies; verified vertical positions.

2026-10-16 user designation: placed RELEASE-075, 076 and 072 vertically under MS-VALIDATION. The existing dependency 075 → 076 in the same column is shown as a vertical line. No new dependency is made from placement order. Verified the specified order and no overlaps in the integrated graph.

2026-10-16 user request: instead of a toggle for showing lines, added an operation to remove a relation. Click a solid or dotted line (Enter/Space with the keyboard), check both ends and the condition, and remove it. Both task dependencies and milestone relations are saved as JSON changes, and the original relations are kept in the baseline. Nothing is written directly to the Markdown canonical. Real Safari operation is unconfirmed.

<a id="初回json取込2026-10-16astra"></a>
## First JSON import (2026-10-16, Astra)

Checked the baseline of the user-provided `registry-edited-2026-10-16T05-21-49-758Z.json` (SHA-256 `0dc2ff838d9ead4e47b8ee0f6a48b2a49864b4b7fa053f35a12b76dcc1b7e76f`) against the distributed snapshot and recomputed the diff. There were no task edits or milestone relation edits; only two direct dependencies, DOC-026 → QUALITY-001 and DOC-027 → QUALITY-001, had been removed. The target original text in the current Registry also matched, so it was applied. The route SPI publication → human review → 1.0 decision is kept, and the Registry's explanation and the milestone diagram were aligned. Confirmed one round trip of removal, save and return by user operation. No task completion is judged.

2026-10-16 user request: closed up the empty columns from MS-070 to MS-SPI. The registration and public-route tasks in between remain, dependencies are unchanged, and later display positions also move left by the amount closed.

2026-10-16 user request: clicking a line opens an edit dialog showing before/after, where the prerequisite and successor can be selected to rewire. Removal is also possible from the same screen. Before applying, the candidate model is verified, rejecting cycles, self-dependencies, duplicates and invalid references. Task edges are between tasks; milestone relations can be chosen from all nodes. Kind, condition, old source and baseline are kept, and the JSON diff records changes of both ends. When applying to the canonical, the consistency of condition text is checked separately. Real Safari operation waits for the user's trial.

2026-10-16, Astra: checked the user-provided `registry-edited-2026-10-16T05-28-29-032Z.json` (SHA-256 `876c575324e882333618bb86624ee901d702dc50cbb53100996639b6b979c6bb`) against the distributed baseline. Only one change: MS-070 → DOC-026 rewired to MS-070 → QUALITY-005. It matches the order of the existing release plan, so it was applied to the pre-registration gate, Registry conditions, milestone diagram and distributed snapshot. Confirmed rewiring, save and return by the user. Task states are not changed.

2026-10-16 user request: halved the basic horizontal spacing. The ordinary 590px between columns becomes 295px, and occupied columns keep at least 295px so that 250px-wide nodes do not overlap. Dependencies unchanged.

2026-10-16 user designation: placed PERM-079 147.5px (half the basic spacing) to the left of MS-070. Keeps the height above the skeleton and the existing dependencies.

2026-10-16 user designation: removed the margin of the dedicated column that remained after floating PERM-079. If there are no other nodes between MS-060 and MS-070, close to the basic spacing 295px and move MS-070 onward to the left. PERM-079 keeps half spacing to the left of MS-070, above the skeleton.

2026-10-16 user correction: loosened the previous closing; MS-060 to MS-070 becomes 442.5px. PERM-079 is placed 60px right of MS-060, above the skeleton. Replaces the earlier half-spacing placement based on MS-070.

2026-10-16 user concrete designation: put PERM-079's left edge 20px right of MS-060's right edge, and MS-070's left edge half a node width (125px) right of that. With width 250px, these are 270px and 395px from MS-060's left edge. Replaces the previous 60px-right proposal.

2026-10-16 user fine adjustment: widened the edge gap MS-060 to PERM-079 to 45px, the same as the basic columns (295px between left edges). MS-070 keeps 125px right of PERM-079's left edge, and later nodes also move 25px right.

2026-10-16 user designation: aligned the left edges of RELEASE-075, 076 and 072 with PERM-079. Vertical order and height are kept, replacing the earlier designation of the same column as MS-VALIDATION. Dependencies unchanged.

2026-10-16 user correction: placed RELEASE-075, 076 and 072 half a width (125px) right of MS-060's left edge. Replaces horizontal alignment with PERM-079; vertical order kept.

2026-10-16 user designation: placed MS-DOC's left edge 125px left of RELEASE-078's left edge. Height and dependencies kept; if it sticks out to the left, the whole figure's margin is corrected.

2026-10-16 user designation: changed the half-width offset of branches under the skeleton to a common golden-ratio short side (node width × about 0.382, about 95.5px for 250px). Applied to RELEASE-075, 076 and 072 rightward from MS-060's left edge, and to MS-DOC leftward from RELEASE-078's left edge. The upper PERM-079 and the skeleton placement are kept.

2026-10-16 user designation: changed the shift from PERM-079's left edge to MS-070's left edge to the golden-ratio short side (about 95.5px) as well. The 45px edge gap MS-060 to PERM-079 is kept.

2026-10-16 user designation: moved RELEASE-075, 076 and 072 together 60px up. The golden-ratio horizontal offset, vertical order and row spacing are kept.

2026-10-16 user designation: placed RELEASE-075's top edge below by twice the vertical spacing from MS-060 to MS-VALIDATION, followed by 076 and 072 at 116px spacing. Replaces the previous 60px move with relative placement. This designation takes priority over the earlier placement below 078.

2026-10-16 user fine adjustment: lowered the group of 3 release tasks by 20px to widen the upper margin. Horizontal position, vertical order and the spacing among the 3 are kept.

2026-10-16 user designation: aligned the vertical spacing MS-DOC → RELEASE-078 with MS-VALIDATION → RELEASE-075. Only RELEASE-078's height is adjusted; horizontal position kept.

2026-10-16 user designation: unified the vertical spacing MS-070 → QUALITY-005 with MS-VALIDATION → RELEASE-075. DOC-026 and 027 move by the same amount, keeping the relative placement among the 3 and their horizontal positions.

2026-10-16 user designation: placed RBT-011 under MS-SPI, and RBT-001, 034, 009, QUALITY-002 and 003 under MS-HUMAN, a golden-ratio short side right of the skeleton's left edge and a common 136px below its top edge. Several follow at 116px spacing. Dependencies and the placement of the 3 SPI registration tasks are kept.

2026-10-16 user adjustment: widened the left-edge spacing of the skeleton MS-SPI → MS-HUMAN → QUALITY-001 from 295px to 442.5px (1.5×). The task groups under them follow, keeping the golden-ratio horizontal shift and vertical spacing.

<a id="現行レイアウトの整理2026-10-16astra"></a>
## Tidying the current layout (2026-10-16, Astra)

At the user's request, the successive coordinate corrections above were reorganized into 4 common rules and 6 display groups. For the current specification see 「配置の共通ルール」 in RegistryApp/README.md. The earlier individual designations are kept as history.
Comparing coordinates with the previous commit: except that the gap MS-DOC → MS-060 widens by about 52px, every node's height and the mutual placement of later groups are kept. Verified card rectangle overlaps, all edge directions, automatic placement when each edge is removed one at a time, when a new node is added and when rewired in reverse, and determinism on re-run. The Safari display waits for user confirmation.

2026-10-16, rules reorganized at the user's request. The fixed branch membership of the 6 groups was abolished; it is derived from the merge target, merge stage and serial relations. Only the skeleton order and the horizontal arrangement of 3 tasks remain as display designations. Stated that upper placement is separation from merging lines, not the work's meaning. Crossing-count optimization is not implemented. Verified the main conditions of the current coordinates and automatic membership of new branches.

2026-10-16 user designation: changed the task detail's fields and conditions from edit fields to read-only display. Editing applies only to state and owner. Keeping the original JSON, diff detection and dependency editing are kept.

2026-10-16 user request: added a dialog that shows formatted Markdown from canonical links. 55 documents are bundled as display copies, showing the capture time and that they do not update automatically. Rebuilt with allowed elements, showing no executable code or dangerous URLs. Images and heading jumps are out of scope. The Safari screen waits for the user's trial.

2026-10-16 user request: added canonical links to the map, list and independent/permanent cards. Multiple canonicals are shown as a choice, and the link operation is independent of card selection. Can also be opened by keyboard.

2026-10-16 user request: added a dedicated map for permanent tasks. Shows 9 permanent tasks and references to their detailed canonicals, separating meaning from the dependency graph. Linked with the existing selection and document viewing. Real display waits for user confirmation.

2026-10-16 additional instruction: made the dependency/permanent maps tab-switched and abolished the left task list. The initial tab is dependency; selection and details are shared. Verified tab keyboard operation and that the 9 permanent tasks are included.

2026-10-16 user designation: removed the horizontal permanent-task row and gathered permanent tasks into the dedicated map. The ordinary independent-task row is kept.

2026-10-16 user designation: removed the background and arrow from the canonical link on map cards, leaving only the text 「正本」. Click area kept.

2026-10-16 user designation: moved 「正本」 on map cards from the state band to the top right. Still no background or arrow.

2026-10-16 user designation: reduced the right margin of the 「正本」 link to about half. The click area also stays inside the card.

2026-10-16 user decision: dependency conditions are decided in consultation with the AI. Removed condition input when adding; new connections and rewirings are saved in JSON as waiting for consultation. Old conditions are not reused as settled content; consult at import before applying to the canonical.

2026-10-16, limited application of the OPS-052 advice: the skeleton's longest path and horizontal arrangement of inter-skeleton routes are derived from structure. Verified regression match of all coordinates and invariance under ID replacement. For details and holds see the Astra acceptance field in TASK_REGISTRY_LAYOUT_ADVICE.md.


<a id="2026-10-16-恒久タスクと独立タスク表示"></a>
## 2026-10-16 Permanent tasks and independent-task display

By user instruction HIST-003 was changed to a standing ACTIVE task. Completion of the first writing, acceptance and entry connection is kept. The permanent map shows the Registry's explicit parent/child relations (OPS-049 to 052 under OPS-048). Parent/child is not a dependency or start condition. Archived children are not revived automatically. Independent tasks are stably sorted with non-DONE on the left and DONE on the right, keeping the original order within each category. Snapshot updated to 39. Model verification passes; the Safari display waits for user confirmation.


2026-10-16, at the user's request, Astra provisionally rated interest on 5 levels from the conversation and saved it, with reasons, in the display-only displayInterest. Permanent tasks put high interest on the left; children put unfinished and high interest on top; independent tasks keep DONE on the right and put high interest on the left within each category. Ties keep the original order. This is not a decision changing priority, authority, dependencies or state in the Registry. The structure of the dependency map is kept. The card tooltip shows the reason for the provisional rating.


<a id="2026-10-16-初期試作の受入完了"></a>
## 2026-10-16 Acceptance of the initial prototype completed

By the user's 「OPS-051は完了にして、のこりは親タスクでの処理でいい」, the initial prototype is accepted and DONE. The initial uses were accepted: checking the current state, selecting tasks, viewing canonicals, editing dependencies, and returning JSON to apply to the canonical. Remaining improvements are handled in the permanent OPS-048, and this task is not held waiting for acceptance.

The README in RegistryApp is canonical for usage. Read-only Markdown display of the numbering queue, task-number selection and closing the canonical view by clicking the background are also implemented. Model checks pass. This does not certify verification of every combination of the real UI and every browser, or solving crossing optimization and complex horizontal/vertical mixing. It is not permission to start later improvements automatically.


<a id="根拠と更新条件の追記2026-10-17--姫opus-55--ops-076第4区切り"></a>
## Grounds and update conditions, appended (2026-10-17 / Hime, Opus 5.5 / OPS-076 break 4)

Input version `1175e583b1857819e9e0b07b83a1cb5fc8be657a`. The body and original returns were not changed. Checked only by reading the fixed tree with `git show <版>:…` and the like; no runs or re-review.

| Claim | Check method and result (scope of validity) | Trigger for update |
| --- | --- | --- |
| Lines 5 and 7: 「単一HTML＋JSONのローカル試作、`Maintanance/RegistryApp/`に置く」 (a single HTML + JSON local prototype placed in `Maintanance/RegistryApp/`) | In that version, `Maintanance/RegistryApp/` has `index.template.html`, `serve.py`, `sync.py`, `build-pending.py`, `build-documents.mjs`, `verify.cjs` and others. `index.html` was renamed to `index.template.html` in `bbddb7ff3d9261500da0f8fd3abcacc241f330df`. The generated outputs are in `Maintanance/Cache/RegistryStudio/` (`/Maintanance/Cache/**` in `.gitignore`). The prototype's form has changed as a fact | Changes to Studio's structure |
| Line 11: 「38 task・11辺のsnapshot」 | The value at prototype time. Current counts change with every generation, and the fixed tree has no generated outputs | Do not use the counts as grounds |

The policy 「Registryへの書き戻しなし・状態の正本はRegistry」 (no writing back to the Registry; the Registry is canonical for state), a judgment of the prototype, is not changed by this.
