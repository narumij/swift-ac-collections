# Claude起動系文書の見直し検討

## TL;DR（人間向け）

Claudeの起動系文書（ルートCLAUDE.md・Tests/CLAUDE.mdなど）のリンク切れ・矛盾・古い案内を整理した検討と改訂の記録。テスト入口の簡素化、作業領域規則の見直し、ルート文書の英訳反映を経て、ユーザーの受入で完了した。起動先の切替や文書移動、AGENTS.md全般の編集解禁は含まない。

2026-10-16, Astra. OPS-054. Registration of a review task at the user's request. Owner: Astra. Started 2026-10-16.

<a id="目的範囲"></a>
## Purpose and scope

After receiving the OPS-053 review result, check Claude's current startup route and referenced documents, and organize duplicates, outdated guidance, and places where authority or handover can be misread. Present the current state and improvement proposals, the targets of change, and the scope needing approval.

<a id="入力"></a>
## Input

Follow only the current references explicitly named from CLAUDE.md. Old versions and history are limited to the necessary checks.

<a id="順序と完了条件"></a>
## Order and completion condition

Proceed in the order: review of the placement-exception table (OPS-053) → review of Claude's startup documents (OPS-054). OPS-054 starts after the OPS-053 review result is accepted. Completing the changes proposed in the earlier stage is not required.

Until the current grounds, whether there are problems, the boundaries to keep, the options and recommendation, and the needed user decisions are recorded and the review result is accepted. A "no change needed" conclusion is possible. At registration, no investigation or revision had been done. By the additional delegation below, it goes as far as fixing links and contradictions.

<a id="境界"></a>
## Boundaries

The review result alone does not lift placement protection, move or expire documents, switch the startup target, or delete permanent tasks. Revision and execution require a separately confirmed delegation. AGENTS.md is not edited. No request to Claude is issued this time.

<a id="調査返却2026-10-16astra"></a>
## Investigation and return (2026-10-16, Astra)

By the user's 「OPS-054に着手」 and 「まずリンク切れ修正と矛盾点の解消」, revision within this scope was explicitly delegated. OPS-053 is DONE, so the prerequisite is satisfied. The startup target is not switched and documents are not moved.

The checked scope: the root CLAUDE.md, Tests/CLAUDE.md, the current rules of CLAUDE_TASK.md, the rules of CLAUDE_PENDING_TASKS.md, TESTING.md, and Progress V2's entry, Registry and Rules. No direct Markdown links or explicit repository-relative paths were missing. The following semantic reference defects and contradictions were fixed.

- Removed the English-required instruction that existed only on the Tests side, and consolidated in the root CLAUDE.md, based on the user's supplement, the policy that internal requests are in English by default to reduce usage. Japanese for the user and exact quotations are kept.
- Changed the guidance that made a task current just because a request file marked it active, to explicit selection, a fixed ID, and checking the current state and conditions. Connected the canonicals of request routes, occupancy and handover from the root.
- Aligned the custom priority order and undelegated optional maintenance with AGENTS' latest instruction → Registry → detailed canonical and the permission to start.
- Changed abbreviated API Matrix paths to existing full repository-relative paths.
- Fixed guidance to report to a nonexistent 「保留中の判断・懸念」 so that it goes to the request's Return or the direct-request queue. The current section name on the dashboard is 「判断待ち」.
- Removed a reference to an overall completion gate that does not exist on the dashboard, aligning with the recorded acceptance conditions of the selected task. Distinguished from completion of the whole permanent maintenance.
- Fixed the red-black tree return guidance in TESTING.md from the current request file to the actual saved history. Test results and user policies are unchanged.

The existing external-access restriction, the handling of scratch, and test-run conditions are not changed this time. Accepting outputs in the numbering queue is out of scope. Checked the existence of links and references and did a diff check. Document changes only; no Swift tests run. This part waits for confirmation. It does not certify a redesign of all startup documents or completion of OPS-054 as a whole.

<a id="テスト入口の簡素化2026-10-16astra"></a>
## Simplifying the test entry point (2026-10-16, Astra)

The user checked the proposed branching between coordinator requests and direct requests and instructed 「テスト直下はそのように修正して」. Changed Tests/CLAUDE.md into a thin entry point. It states that coordinator requests follow the request file, direct user requests follow the explicit scope of the conversation, and unregistered concrete execution requests follow the root queue rules.

The existing Working Rules, Validation and Finish and Handoff were moved to Maintanance/Testing/TEST_WORKFLOW.md and linked to TEST-005. Only the reporting destination was split into direct and coordinator requests, referring to the root communication rules so that the one-word 「完了」 restriction is not applied to every direct request. Test-specific technical rules are kept. TESTING.md is also connected to the procedure canonical. The placement-protection designation of the startup files is unchanged.

<a id="作業領域の規則見直し2026-10-16ユーザー決定astra反映"></a>
## Revising work-area rules (2026-10-16, user decision / applied by Astra)

The user approved the proposal on using temporary areas. Revised the root CLAUDE.md's blanket ban on external access and its obligation to create a dedicated directory every time and delete it before finishing. /tmp and the like may be used as needed: identify work items to avoid collisions, do not touch files of other tasks or processes, and clean up only what one created. Do not leave necessary outputs and verification evidence only in temporary areas; record them in the canonical or the designated evidence location.

Allowed: limited reading of external tools, SDKs, dependencies and build results needed for the work, and output to .build, DerivedData and standard caches by ordinary builds and tests. Unrelated exploration and manual changes or cleanup of shared caches and the like are not allowed. Intentional external edits are limited to targets the user designates and one's own temporary work items, and the environment's access permissions continue to be respected. The earlier 「外部アクセス・scratchは今回は変更しない」 was updated for the scope of this additional delegation.

Common management of temporary work items was split out, by user instruction, as a separate task OPS-055 into ProgressV2/COMMONS.md. The duplicated procedure in the root CLAUDE.md was replaced with an as-needed reference. This is not completion of OPS-054 as a whole.

<a id="ルート起動文書の原稿承認2026-10-16"></a>
## Approval of the root startup document draft (2026-10-16)

The user checked the Japanese draft and approved: 「それ英語で反映して」. Astra applied the English translation to CLAUDE.md. Separated coordinator requests from direct user requests, did not limit the numbering queue to times when the coordinator is absent, and tidied wording that fixed the coordinator to Codex. Registry updates are left to the current rules, and the one-word 「完了」 restriction is not applied to direct requests. The as-needed references to the work area and COMMONS.md are kept as in the approved draft. Checked link existence and did a diff check. Not committed.

<a id="ユーザー受入完了2026-10-16"></a>
## User acceptance and completion (2026-10-16)

The user stated 「ユーザーが受け入れしたってことで、閉じよう」 and OPS-054 was updated to DONE. By the following explicit request, an as-needed reference to COMMONS.md was added to AGENTS.md. This editing delegation is limited to adding this cleanup item and does not lift the general ban on editing AGENTS.md. No actual cleanup was done.
