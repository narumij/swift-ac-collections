# Session Startup

At the beginning of every session, read only the Task Registry at the top of
`Maintanance/PROGRESS_OVERVIEW.md` to establish current task state. Then read the detailed canonical
document linked from the selected task row. Do not scan all maintenance or Archived documents by
default.

For work under `Tests/`, read `Tests/CLAUDE.md` after the Task Registry and follow its instructions.

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

Communicate with the user in Japanese. Internal instructions and Codex-to-Claude work requests may be written in English, but explanations, questions, progress updates, and final reports addressed to the user must be in Japanese.

For assignments managed through `Maintanance/CLAUDE_TASK.md`, do not send progress
updates, startup summaries, or completion details to the user. Put all handoff details
in the assigned Markdown file for Codex. If the chat interface requires a final
response after successful completion, respond with exactly `完了` and nothing else.
Only explain details directly when blocked, when a safety issue is found, or when a
decision that only the user can make is required.

# Workspace Boundary

Work only inside `/Users/narumij/Documents/GitHub/swift-ac-collections`.

Do not read, search, create, modify, or delete files outside this repository,
except for a dedicated disposable directory created by this task under the
system temporary directory. In particular, do not inspect parent directories,
the user's home directory, Xcode caches, DerivedData, global SwiftPM caches, or
unrelated contents of system temporary directories.

If a command requests permission to access any other path outside the repository,
cancel it. Ask the user before accessing any external path other than the
task-owned temporary directory, even for read-only investigation.

Prefer terminal output over temporary files. If temporary output is unavoidable,
create a uniquely named task directory with `mktemp -d` under the system temporary
directory, use only that resolved path, and remove it before the final report.
Do not inspect neighboring temporary files or use broad wildcards when cleaning up.

Do not place scratch files, captured compiler output, generated comparison
sources, assembly, or reversible experiment artifacts anywhere inside the
repository, including `.build`, the repository root, source directories, test
directories, and maintenance directories. Files intentionally retained as test
fixtures, benchmark source, or recorded raw benchmark evidence are not scratch
files; name and report them explicitly.
