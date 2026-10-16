# Session Startup

At the beginning of every session, use [Progress V2](Maintanance/ProgressV2/PROGRESS_OVERVIEW_V2.md)
as the entry point. Read the relevant rows in [Task Registry V2](Maintanance/ProgressV2/TASK_REGISTRY_V2.md)
and the detailed canonical document linked from the selected task row. Consult only the necessary sections of
[Task Rules V2](Maintanance/ProgressV2/TASK_RULES_V2.md) before an operation that requires them.
Do not scan all maintenance or Archived documents by default.

For the authority of historical records, including `Maintanance/Archived/PROGRESS_OVERVIEW_RETIRED_2026-10-15.md`,
follow [AGENTS.md — 現在の仕事と正本](AGENTS.md#現在の仕事と正本).

For work under `Tests/`, read `Tests/CLAUDE.md` after the Task Registry and follow its instructions.

# Task selection and start authority

Readiness and Claude ownership do not authorize autonomous task selection or start. Begin work only
after the user or a coordinator acting within the user's delegation selects the task for Claude. For coordinator assignments, follow the ownership and handoff rules in
[CLAUDE_TASK.md](Maintanance/CLAUDE_TASK.md); the task must already be registered and the request must name its stable ID.
Check the selected task's current state and conditions before starting or changing it. A recorded active assignment does not override the user's current request or grant authority to resume frozen work. A direct user request before stable Registry ID
assignment is governed by the bounded exception below.

# Work awaiting a Registry ID

`Maintanance/CLAUDE_PENDING_TASKS.md` is a temporary handoff queue for work discussed while Codex is
unavailable to assign a stable Registry ID. It is not a second Task Registry and must not be scanned
at session startup or used to select work autonomously.

- If the user asks only to record, decompose, or prepare a candidate, add it to the queue and do not
  execute it.
- If the user explicitly asks Claude to perform a concrete bounded task, Claude may execute that
  exact request before stable ID assignment. Record the user's authorization, scope, evidence,
  validation, and stopping points under a temporary queue ID.
- A temporary ID never replaces a Registry ID, never appears in Task precedence, and grants no
  authority beyond the user's explicit request.
- Existing ownership and safety boundaries remain in force. A `USER_ONLY` task requires explicit
  reassignment, not merely a request to record it. Public policy, final acceptance, Registry state,
  and completion remain with their recorded owner unless the user explicitly changes ownership.
- Do not continue from one queued item to another without a new user request. Do not mark queued
  work accepted or complete on Codex's behalf.
- When Codex returns, leave the result for duplicate checking, stable ID assignment or merge,
  acceptance, and Registry reconciliation. After reconciliation, retain the stable ID and outcome in
  the queue entry so temporary references remain traceable.

# Communication

Communicate with the user in Japanese. To reduce usage, use English by default for internal instructions and coordinator-to-Claude work requests. This is a project-wide writing convention, not a test-only requirement; preserve Japanese quotations and canonical terms when needed for accuracy. Explanations, questions, progress updates, and final reports addressed to the user must be in Japanese.

For assignments managed through `Maintanance/CLAUDE_TASK.md`, do not send progress
updates, startup summaries, or completion details to the user. Put all handoff details
in the assigned Markdown file for Codex. If the chat interface requires a final
response after successful completion, respond with exactly `完了` and nothing else.
Only explain details directly when blocked, when a safety issue is found, or when a
decision that only the user can make is required.

# Workspace Boundary

Keep intentional edits within `/Users/narumij/Documents/GitHub/swift-ac-collections`,
except for external files explicitly designated by the user and task-owned temporary
files. Access remains subject to the environment's permissions.

Read tools, SDKs, dependencies, and build results outside the repository when needed
for the assigned work. Keep searches scoped to that purpose; do not explore the
user's home directory, unrelated documents, or other tasks' temporary files broadly.

Normal build and test output in `.build`, DerivedData, and standard tool caches is
allowed. This does not authorize manual modification or cleanup of shared caches,
SDKs, dependencies, or other projects' output.

For temporary work files, handoff, or end-of-day cleanup, consult only the relevant
section of [COMMONS.md](Maintanance/ProgressV2/COMMONS.md). It is shared by all agents
and is not mandatory startup reading. Record task-owned temporary paths and retention
state so end-of-day cleanup can collect them without touching other work.

Intentionally retained fixtures, benchmark sources, and raw evidence belong in their
assigned repository locations and must be identified in the report. Do not scatter
disposable experiment files through source, test, or maintenance directories.
