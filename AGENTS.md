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

## Claude work awaiting a stable ID

`Maintanance/CLAUDE_PENDING_TASKS.md` is a temporary handoff queue, not a second
Task Registry. Claude may record an unnumbered candidate there without starting
it. When the user explicitly directs Claude to execute a concrete bounded item,
that latest instruction authorizes only the named scope before stable ID
assignment; Claude records the authorization and evidence under a temporary ID.

Codex owns reconciliation when it returns: check for duplicates and conflicts,
assign or merge into a stable Registry ID, review the result, and update the
Registry. Temporary IDs must not be added to Task precedence or treated as
completion acceptance. Do not scan the queue at startup; read it when the user
asks for reconciliation or a queued result is handed back.

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

## Routine shorthand

When the user says `ルーティーン`, treat it as a request for this cycle:

1. Review the reported completed work. When it satisfies its acceptance
   conditions, update its detailed canonical document and the Task Registry.
2. Commit only the accepted work and its corresponding progress updates,
   preserving unrelated worktree changes.
3. Recompute the ready work from task dependencies. Decompose the next
   in-scope work when necessary, keeping each task appropriately bounded
   and separating user decisions from agent execution.
4. Assign Claude only bounded, decision-free tasks whose prerequisites are
   satisfied and whose ownership fits Claude. If no such task exists, do not
   manufacture an assignment.
5. Commit any resulting task-management and handoff changes.

Any phase may be a no-op. The user's latest instruction still takes priority.
This shorthand does not make a non-ready task ready, restart `FROZEN` work,
activate `PROPOSED` work, or authorize action on `USER_ONLY` tasks.

## Japanese sentence markers

The markers below classify only the single sentence immediately following the
marker, not the response as a whole. When the function changes within one
response, a later sentence may use a different marker. Choose by the function of
that sentence rather than by a global priority, and do not add markers to every
sentence or to ordinary conversation.

- Use `了。` before a sentence that acknowledges an instruction or request as
  understood and accepted for execution. It is not a completion claim.
- Use `是。` before a sentence that explicitly affirms a premise, understanding,
  or proposed direction as correct. It is not a casual acknowledgement.
- Use `否。` before a sentence that explicitly rejects or corrects a mistaken
  premise, factual misunderstanding, or unsafe framing. It is not for mild
  disagreement or stylistic preference.
- Use `解。` before a sentence that interprets evidence, explains a reason or
  relationship, or states what can be inferred.
- Use `告。` before a sentence that reports an observed status, established
  result, progress conclusion, or routine completion. It is not for intended
  work that has not yet been performed.

## Ownership boundaries

- Codex owns final updates to the Task Registry and is the primary owner of
  public documentation.
- Claude-specific communication, authority, and handoff rules remain in
  `CLAUDE.md` and `Maintanance/CLAUDE_TASK.md`; do not duplicate or override them
  here.
