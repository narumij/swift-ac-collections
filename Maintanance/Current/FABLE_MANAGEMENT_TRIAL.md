# Fable管理試験：採番待ちの照合案を一巡作る

2026-10-17 / 作成・受入Astra / 調査Fable。ユーザーが提案を承認し、依頼作成とcommitを指示。既存の恒久タスクOPS-044の限定試験として扱う。恒久タスクはACTIVEを維持し、本試験の完了でDONEにしない。

## Assignment — one bounded trial

Produce a reconciliation proposal for exactly these entries:

1. CP-20261017-007 in ../CLAUDE_PENDING_TASKS.md: RBT-048 decision material. Preserve USER_ONLY and deferred judgment; do not decide the API, implement it, or investigate its technical design anew.
2. CP-20261017-008 in ../CLAUDE_PENDING_TASKS.md: Fable request/queue setup.
3. FP-20261017-001 in ../FABLE_PENDING_TASKS.md: Studio pending-queue support.

These temporary IDs select inputs only; they are not dependencies or new stable task IDs. Check the current Registry rows and relevant canonical records before proposing changes. Queue text may have stale “uncommitted” statements: inspect relevant Git history and distinguish a commit from acceptance. Do not reconcile other entries just because they are nearby.

For each entry, return: current factual state and evidence paths/commits; an existing stable task to integrate into, or why a new task may be needed; duplicate/conflict findings; exact proposed edits with file/section and before/after text; unresolved user decisions. Do not allocate a new ID. If no edit is needed, explain briefly. For your own prior work, disclose authorship and provide evidence; do not accept your own result.

This is a management trial, not a technical re-review of the product or an implementation task. Read only what resolves the specified reconciliation questions. Do not run full tests, rebuild Studio, access external services, or repair unrelated findings. Record an out-of-scope finding briefly and stop pursuing it.

## Output ownership and limits

Write only in the Return section below. If necessary, create small supporting text files under Evidence/FABLE_MANAGEMENT_TRIAL/ and link them from Return. The existing optional personal-observations delegation remains separate.

Do not edit Registry, Rules, either queue, request files, existing evidence, product code, CI, or another agent's return. No compression, moving files, commit, branch, push, message dispatch or final acceptance is delegated. Do not promote PROPOSED, resume FROZEN, or execute USER_ONLY work. Being assigned this trial does not appoint you coordinator or give authority over Claude.

If input has changed since inspection, identify the affected proposal and recheck it. If authority is missing or records conflict, return the concrete question and evidence; do not invent a decision. Continue independent items within these three inputs if possible.

## Acceptance and evaluation

Astra will review and apply accepted proposals. Success means the reviewer can understand and apply the result from saved evidence without reconstructing the conversation. Assess factual accuracy, preservation of user judgment and ownership, minimal necessary investigation, and how much correction the reviewer needs. More proposals or longer reports are not better. This trial does not automatically authorize broader or direct Registry editing; any extension needs a separate delegation.

Finish with work completed / incomplete, blockers, changed files, and scope release. The assignment is fixed at handoff; Astra will not edit the Return while Fable is working. After Return, record acceptance here and maintain the parent task ACTIVE.

## Return — Fable

Awaiting Fable.

## Acceptance — Astra

Pending. No final reconciliation has been performed by issuing this trial.
