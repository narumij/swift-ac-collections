# Fable temporary coordinator deputy

2026-10-17 / OPS-044 / Recorded by Codex. Status: delegated; startup acknowledgement pending.

## User authorization and identity

The user requested a deputy until Astra returns, then explicitly extended the scope:
「レジストリ更新や掃除も任せる必要があるな。記憶共有してるようなので、モデルで識別してもらうしかない。」

This is a separate delegation, not an automatic promotion from the completed management trial. Registry operations belong to the coordinator explicitly delegated by the user, not permanently to a model family. Fable currently holds this temporary delegation. The authority is this explicit user instruction; this document records it and does not grant general permission to amend AGENTS.md or other protected documents.

Identify Fable by the actual runtime model designated by the user (Fable), not a remembered persona, shared memory, prior author signature, or the fact that this file was read. At startup record the model identifier shown by the environment, date, and active conversation identification if available. Do not invent a model identifier or infer it from generated self-description. If the environment does not expose it, ask the user to confirm the selected model. A model match identifies the participant, not permission for multiple conversations to edit concurrently. Hand off occupied files explicitly. A model switch does not silently transfer this delegation.

## Role-neutral Registry policy (2026-10-17)

User follow-up: 「れじすとりはCodexって記述はどうにかしたいな」。Operational rules now identify the explicitly delegated coordinator instead of Codex. The user subsequently explicitly authorized this AGENTS.md edit: its Registry final-update and reconciliation clauses now name the explicitly delegated coordinator rather than reserving those operations to Codex. Its other governance clauses and general AI-edit restriction remain unchanged. The explicit user delegation recorded here is the basis for current operations, not an inferred authority from a lower document.

## Delegated operations

Within the current user-selected work, Fable may:

- Reconcile Claude and Fable pending queues, check duplicates, allocate fixed IDs using Task Rules, and update Registry states, owners, conditions and dependencies with evidence.
- Maintain related canonical records, prepare registered assignments and coordinate handoffs. Inspect current task state immediately before a change. Do not start a second copy of occupied work.
- Verify and accept another participant's returned work against the existing acceptance conditions, recording evidence and limits. For Fable's own product or implementation output, record verification and leave independent acceptance to the user or another assigned reviewer. Routine bookkeeping does not require waiting for Astra to countersign every edit.
- Compress completed/reconciled records and archive eligible documents under [the archive procedure](../ProgressV2/TASK_REGISTRY_ARCHIVE.md), preserving originals, live conditions and links. Respect placement protections.
- Clean recorded disposable work under [COMMONS](../ProgressV2/COMMONS.md), including other participants' items already marked deletable. Unknown, in-use or retained files are not disposable merely because Astra is absent.
- Regenerate and verify Registry Studio after relevant changes using its existing procedure.

No new product-policy authority, automatic FROZEN resumption, USER_ONLY execution, or automatic PROPOSED activation is granted. Commit, branch and external operations retain their existing operation-specific authorization requirements. This delegation does not authorize autonomous pursuit of all remaining tasks or changes to product code/CI without a corresponding assignment. Report a genuinely new decision to the user; do not make a new user gate out of routine fact checking.

Queue field names such as `Codex reconciliation` and `AWAITING_CODEX` are retained for compatibility. During this delegation, Fable may fill reconciliation results with the actual actor/model and evidence; the field name does not require waiting for Codex. Preserve original Returns and append reconciliation separately.

## Entry and return to Astra

Start from [Progress V2](../ProgressV2/PROGRESS_OVERVIEW_V2.md), the current milestone HEAD and selected task records. Shared memory and caches are aids, not proof of authority or current state. Do not reconstruct all historical work.

At handback, record current occupied work, uncommitted changes and ownership, unresolved user decisions, evidence paths and the next permitted step. The user directs the return to Astra; Astra's mere reappearance does not start concurrent coordination. Release the scope and record the new owner before the next coordinator edits it. Preserve this delegation as history when it ends.

## Startup / handback record

### Startup acknowledgement — 2026-10-17 Fable

- Model identifier shown by the environment: `claude-fable-5-1` (Claude Fable 5.1, Claude Code in Xcode). Conversation identifier: not exposed by the environment. The user designated Fable in this conversation and issued the start instruction 「FABLE_TASK.mdの調整代理を開始して」.
- Entry: Progress V2 → milestone HEAD `0.5.4` → Registry at HEAD `bc50f176` (43 tasks: 21 ACTIVE, 10 PROPOSED, 5 USER_ONLY, 2 DONE, 2 FROZEN, 2 WAITING_EXTERNAL, 1 WAITING_USER). Working tree: `Maintanance/User/MEMO.md` modified (user-owned, untouched).
- Queue state at startup: every entry in `CLAUDE_PENDING_TASKS.md` (CP-20261016-013, CP-20261017-001〜008) and `FABLE_PENDING_TASKS.md` (FP-20261017-001・002) is `RECONCILED` by Astra. No open proposal or unreconciled return.
- First actions under this delegation: compress the reconciled queue entries to `Archived/` under the archive procedure, archive the completed trial section of `FABLE_TASK.md`, point the RBT-048 decision document's CP-007 link at the archive, regenerate Studio. Registry task rows and states are not changed (DONE rows RBT-049・RELEASE-084 stay per the user's 「タスク圧縮はすぐはしない」). No commit without the user's instruction.
- Occupied by Fable from this point: `CLAUDE_PENDING_TASKS.md`, `FABLE_PENDING_TASKS.md`, `FABLE_TASK.md`, new `Archived/*_2026-10-17.md`, Registry「過去の記録への入口」, Studio generated files. `CLAUDE_TASK.md` is not edited in this pass.
- Result of the first pass (same day, uncommitted): both queues compressed to `Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-17.md` / `Archived/FABLE_PENDING_TASKS_RECONCILED_2026-10-17.md` (verbatim; only link targets rewritten, verified by link-insensitive comparison; all links resolve). Trial request section moved to `Archived/FABLE_TASK_HISTORY_2026-10-17.md`. Registry「過去の記録への入口」gained one bullet; no task row changed. RBT-048 decision document's CP-007 link repointed to the archive. Studio regenerated, verify.cjs passed, `--check` no drift, pending seed 0 entries. No new coordination know-how recorded (nothing new found). Next permitted steps: compress accepted sections of `CLAUDE_TASK.md` (RBT-049・RELEASE-083/084 all accepted) when asked; DONE rows stay until the user asks for compression.
