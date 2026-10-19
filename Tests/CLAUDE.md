# Test Work Entry

Follow root [CLAUDE.md](../CLAUDE.md) for start authority, language, workspace
boundaries, and handoff. This file does not authorize task selection or start.

Before test work:

1. Check the selected task's current state, scope, conditions, and detailed canonical
   document in [Task Registry](../Maintanance/ProgressV2/TASK_REGISTRY_V2.md), if registered.
2. Identify the request route:
   - Coordinator assignment: follow the [current request route](../Maintanance/ProgressV2/PROGRESS_OVERVIEW_V2.md#現在の依頼を受け取る).
     Read the selected DB letter (or explicitly designated file request), stable ID,
     editing scope and canonical document. The occupancy rules in
     [CLAUDE_TASK.md](../Maintanance/CLAUDE_TASK.md) still apply.
   - Direct user request: follow the scope explicitly delegated in the conversation.
     No CLAUDE_TASK entry is required. For a concrete execution request before Registry
     registration, follow root CLAUDE.md's queue rules and record authorization,
     results, and validation in [CLAUDE_PENDING_TASKS.md](../Maintanance/CLAUDE_PENDING_TASKS.md)
     for later reconciliation. A request to discuss or record alone is not execution authority.
3. Read the relevant [test work procedure](../Maintanance/Testing/TEST_WORKFLOW.md).
4. Consult the relevant [test dashboard](../Maintanance/Testing/TESTING.md) sections
   when current results or handoff context are needed.

Historical documents are evidence only, not current start instructions.

For an explicitly assigned Fable session, use FABLE_TASK.md and FABLE_PENDING_TASKS.md
in Maintanance/ instead of the Claude-specific request and queue above, as defined
by root CLAUDE.md. Test scope and authority still come from the selected assignment.
