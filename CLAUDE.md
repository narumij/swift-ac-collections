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

## Coordinator Assignments

Follow the selected request and the occupancy and handoff rules in
[CLAUDE_TASK.md](Maintanance/CLAUDE_TASK.md).

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

Communicate with the user in Japanese, including explanations, questions, progress
updates, and final reports.

To reduce usage, use English by default for internal instructions and coordinator-to-Claude
requests. Preserve Japanese quotations and canonical terminology where needed for accuracy.

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
