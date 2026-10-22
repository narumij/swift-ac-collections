# Session Startup

Use [Progress V2](Maintanance/ProgressV2/PROGRESS_OVERVIEW_V2.md) as the entry point
for each session. Read the [Task Registry](Maintanance/ProgressV2/TASK_REGISTRY_V2.md)
rows relevant to the current request and their detailed canonical documents.
Before an operation requiring procedural rules, consult only the necessary sections
of [Task Rules](Maintanance/ProgressV2/TASK_RULES_V2.md).

Do not read all maintenance or Archived documents at startup.
For the authority of historical records, follow
[AGENTS.md — 現在の仕事と正本](AGENTS.md#現在の仕事と正本).
For work under `Tests/`, use [Tests/CLAUDE.md](Tests/CLAUDE.md) as the entry point
to the necessary test procedures.

# Task Selection and Start Authority

Readiness or Claude being named as owner does not authorize task selection or start.
Begin only within the scope selected for Claude by the user or by a coordinator
acting within the user's delegation.

Before starting or changing work, check the corresponding task's current state,
conditions, and detailed canonical document. A request file alone does not override
the user's latest instructions or authorize resuming frozen work.

## Request routing for Claude and Fable

For a direct user request to import a Studio Inbox save or refresh judgment caches,
use the bounded [maintenance role](Maintanance/Current/MAINTENANCE_ROLE.md).
It authorizes the requested canonical/Registry reconciliation without appointing
a general coordinator or requiring a second coordinator to repeat the import.
This user-authorized exception applies to the ordinary return/reconciliation rules
below; ownership, protected documents, judgment boundaries and commit approval remain.

For the user-authorized temporary Fable coordinator role, consult
[the deputy delegation](Maintanance/Current/FABLE_COORDINATOR_DEPUTY.md). It explicitly
includes Registry updates and cleanup, and defines runtime-model identification.
Its bounded exception applies to the ordinary routing/acceptance rules below.

Use the participant explicitly designated by the current user assignment; do not infer
an identity or role from this file. Fable assignments and returns use
[FABLE_TASK.md](Maintanance/FABLE_TASK.md), and Fable's unregistered direct work uses
[FABLE_PENDING_TASKS.md](Maintanance/FABLE_PENDING_TASKS.md) with FP- temporary IDs.
For Fable, these replace the CLAUDE_TASK / CLAUDE_PENDING_TASKS paths below, including
the request-file communication rule. Other shared rules remain applicable. A bounded
management assignment grants only its stated operations, not another participant's
ownership or final acceptance authority.

## Coordinator Assignments

Follow the current request route in the [shared entry point](Maintanance/ProgressV2/PROGRESS_OVERVIEW_V2.md#現在の依頼を受け取る).
For DB assignments, read the addressed inbox and selected letter, then its task and
canonical document. Use a request-file assignment only when explicitly designated.
The occupancy and handoff rules in [CLAUDE_TASK.md](Maintanance/CLAUDE_TASK.md)
still apply; its historical requests do not restart work or continuous waiting.

The coordinator must register the task in the Task Registry before issuing the request
and include its stable ID in the request. Check the scope, editable files, return
location, and stopping conditions.

## Direct User Requests

Follow the scope explicitly delegated in the conversation. A CLAUDE_TASK.md entry
is not required.

If a corresponding task is registered, check its current state and conditions.
For unregistered work, follow the queue procedure below.
A request only to record, discuss, or prepare a candidate is not execution authority.

# Work Awaiting a Registry ID

[CLAUDE_PENDING_TASKS.md](Maintanance/CLAUDE_PENDING_TASKS.md) is a temporary handoff
queue for merging unregistered direct user requests and candidates discovered in
discussion into the formal task record. Its use is not limited to the coordinator's
absence.

It is not a second Task Registry. Do not read the whole queue at startup or use it
to select work autonomously.

- If asked only to record, decompose, or prepare a candidate, record it without
  executing it.
- If the user explicitly requests concrete, bounded execution, perform only that
  scope, even before stable ID assignment. Under a temporary ID, record authorization,
  scope, results, evidence, validation, and stopping points.
- A temporary ID does not replace a stable ID and must not appear in Task precedence
  or serve as another task's dependency. It grants no authority beyond the user's
  explicit request.
- Existing occupancy and authority boundaries remain in force. Executing a `USER_ONLY`
  task requires explicit reassignment; a request to record it is insufficient.
- Finishing one item does not authorize proceeding to another candidate without a
  new request.
- Recording results is distinct from formal acceptance and updating completion in
  the Registry. Do not mark work accepted or complete on behalf of its current owner.
- Hand results to the coordinator for duplicate checking, stable ID registration or
  integration into an existing task, acceptance, and Registry reconciliation. The
  person designated by the current rules performs authoritative Registry updates.
- After reconciliation, retain the stable ID and outcome so the temporary reference
  remains traceable. Follow the prescribed procedure for compression.

# Communication

着手の際には必ず返事をすること。
動いてよいと決まっていないうちは、確かめるだけ。
会話の途中を命令と短絡しないこと。確認以外の作業は禁止。
感嘆を了承に短絡しないこと。確認以外の作業は禁止。
イエスかノーかで答えられる質問には、最初にイエスかノーで答えること。確認以外の作業は禁止。
2択3択の質問には、最初に選択して答えること。確認以外の作業は禁止。
会話の中に未確定の選択肢が残っている場合は、確認以外の作業は禁止。

Communicate with the user in Japanese, including explanations, questions, progress
updates, and final reports.

To reduce usage, use English by default for internal instructions and coordinator-to-Claude
requests. Preserve Japanese quotations and canonical terminology where needed for accuracy.

Interpret each user message in the context of the ongoing exchange. Before responding,
check it against at least the previous two conversational exchanges, including your
own replies. Resolve omitted subjects, references, and corrections from that context
rather than treating the message as a standalone request. Look further back only when
needed; ask briefly if materially different interpretations remain.

Distinguish requests to act from corrections, recollections, and requests to restate. Do not resolve ambiguity in favor of starting work.

Do not disguise failures, omissions, or unmet requirements in reports.
Do not redefine the requested outcome after the fact to claim success.
Report the actual result against the user's request, plainly and without spin.

## First response to a new request

Start with the smallest useful response, about ten lines:
the purpose in the user's words, the simplest working form, and what you actually checked.
Make assumptions that materially affect the result explicit, especially dependencies
on existing systems. Distinguish checked facts from assumptions.
Do not add detailed design, option lists, or unnecessary decision requests.

Before sending, review it as the receiver: do names match their meaning, does the
proposal meet the stated purpose, and can it be assessed without further investigation?
Resolve checkable uncertainties yourself. Do not leave the receiver to reconstruct
or repair the proposal, or label settled matters and implementation choices as user decisions.

Expand after the premise is established. If the conversation already establishes it,
proceed within the authorized scope without asking for confirmation again.

## When encountering a problem

Before choosing a solution, briefly state the problem and distinguish three perspectives:
- User: which stated goal or concern is affected. Cite the relevant request; say “unknown” if unclear.
- Coordinator: effects on dependencies, handoffs, verification, or ongoing work.
- Worker: effects on implementation, testing, effort, or available tools.

Use “none identified” where appropriate. Do not invent concerns to fill every category, or present a worker preference or coordinator concern as a user requirement.

List proposed solutions separately from the observed problem. For each proposal, identify whose concern it addresses and any change to the agreed scope or approach. Discovering a problem does not authorize expanding the work. Proceed within existing authorization; return the issue before taking action that exceeds it.

Keep this report short. Agreement that a problem exists is not approval of a proposed solution.

## Work Managed Through the Communication DB

Use the selected letter for receipt and return, following the
[communication procedure](Maintanance/RegistryApp/README.md#communication-db).
Keep results, evidence, specifications and decisions in the referenced canonical document.
Do not duplicate a DB assignment into a request file or the old notification route.

## Work Managed Through a Request File

For assignments through `Maintanance/CLAUDE_TASK.md`, record progress, startup summaries,
and completion details in the assigned Return section.

If a final chat response is required after successful completion, respond with exactly
`完了` and nothing else. Explain directly when blocked, when a safety issue is found,
or when a decision only the user can make is needed.

## Direct User Work

Provide the explanations, questions, and results needed for the request in normal Japanese.
The request-file restriction to a one-word completion response does not apply.

Do not leave information needed for formal reconciliation only in the conversation.
Record it in the corresponding task record or queue entry.

# Workspace Boundary

Keep intentional file edits within this repository by default:

`/Users/narumij/Documents/GitHub/swift-ac-collections`

Exceptions are external files explicitly designated by the user and task-owned temporary
work files. Continue to respect the environment's access permissions.

Read external tools, SDKs, dependencies, and build results when needed for the assigned
work. Limit searches to that purpose; do not broadly explore the home directory,
unrelated documents, or other tasks' temporary files.

Normal build and test output in `.build`, DerivedData, and standard caches is allowed.
This does not authorize manual modification or cleanup of shared caches, SDKs,
dependencies, or other projects' output.

For temporary work creation, handoff, and end-of-day cleanup, consult the relevant
sections of [COMMONS.md](Maintanance/ProgressV2/COMMONS.md). These rules are shared
by all agents and are not mandatory startup reading.

Put intentionally retained fixtures, benchmark sources, and raw validation evidence
in their designated locations and identify them in the report. Do not scatter
disposable experiments through source, test, or maintenance directories.

# ユーザーによる追記

調整役を担当するClaude系エージェントAIは、AGENTS.mdを参照し、これに従うものとする。
