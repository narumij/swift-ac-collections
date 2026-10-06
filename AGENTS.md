# Codex session entry point

## Startup

1. Read only the Task Registry at the top of
   `Maintanance/PROGRESS_OVERVIEW.md` to establish the current task state.
2. Treat that Registry as the sole source of truth for remaining tasks, status,
   ownership, and restart conditions.
3. After a task is selected, read only the detailed canonical document linked
   from that task row.
4. Do not scan all maintenance documents or Archived records at session start.
   Do not reconstruct or revive tasks from older checklists, handoffs, or logs.
5. Priority order is: the user's latest instruction, the Task Registry, the
   selected task's detailed canonical document, then Archived records and old
   logs.

## Stable task IDs

- Registry IDs such as `RBT-001` and `PERM-002` are persistent repository task
  IDs. Never rename, renumber, or reuse them when status or classification
  changes.
- Registry state names are agent-facing bookkeeping. The user does not need to
  remember or use them; translate the user's ordinary wording into the matching
  state.
- Registry IDs are also agent-facing bookkeeping. Do not expose them in routine
  user reports or require the user to refer to them. Prefer plain task names and,
  for a multi-point report, temporary conversation reference IDs. Show a Registry
  ID only when the user asks for it or when it is necessary to resolve genuine
  ambiguity across records or sessions.
- `FROZEN` tasks require explicit restart direction. Do not start them because
  an old document describes unfinished work.
- `USER_ONLY` tasks must not be started, performed, delegated, or prompted by an
  agent.

## Conversation reference IDs

For a report with multiple independently actionable points, follow
`Maintanance/CONVERSATION_REFERENCE_IDS.md`.

- Display complete hierarchical IDs such as `(A)`, `(A-1)`, and `(A-1-a)`.
- Keep existing IDs when updating the same report. Do not close gaps or renumber
  later items after deletion, resolution, or reorganization.
- When a report refers to an earlier report in the same conversation, continue
  with unused top-level letters instead of starting again at `(A)`.
- Conversation IDs are temporary coordinates. Do not use them as replacements
  for persistent Registry IDs.

## Ownership boundaries

- Codex owns final updates to the Task Registry and is the primary owner of
  public documentation.
- Claude-specific communication, authority, and handoff rules remain in
  `CLAUDE.md` and `Maintanance/CLAUDE_TASK.md`; do not duplicate or override them
  here.
