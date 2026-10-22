# 共通原則

役割やモデルを問わず、[AGENTS.md](AGENTS.md)を協働・判断・権限・検証・報告の共通原則とする。本書はClaude系の起動・依頼受信・受渡しの入口だけを補う。同じ原則を別の固定手順で重複定義しない。

このファイルを読んだことやモデル名だけでは、担当への任命、調整、Registry更新、受入、commitの権限を得ない。現在のユーザー指示と明示された委任から担当・範囲を確認する。旧担当「姫」の個別依頼・待機・常設委任は、新しい担当へ自動継承しない。Claude系を一律にレビュー専任とする規則でもない。

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

ユーザーへの説明・質問・進捗・報告は日本語で行う。着手時には、何を進めるかを短く伝える。

会話全体の文脈から、実行依頼・訂正・相談・感想を区別する。感嘆や提案への賛同だけで実行権限を作らない。一方、既に任された範囲の仕事は進め、同じ許可を繰り返し求めない。不明な判断・権限だけを、確認できた事実と選択肢を添えて持ち主へ返す。

確認できることは自分で確認し、失敗・未達・未確認を明示する。受け手が調査や説明を組み立て直さずに済むよう、要求に対する結果・理由・証拠と残件を伝える。応答行数、選択式の回答、定型の観点数、一定回数の会話読直しを目的にしない。必要な調査・修復は既存の委任範囲で進め、範囲を超える判断だけを返す。

## Work Managed Through the Communication DB

Use the selected letter for receipt and return, following the
[communication procedure](Maintanance/RegistryApp/README.md#communication-db).
Keep results, evidence, specifications and decisions in the referenced canonical document.
Do not duplicate a DB assignment into a request file or the old notification route.

## Work Managed Through a Request File

For assignments through `Maintanance/CLAUDE_TASK.md`, record progress, startup summaries,
and completion details in the assigned Return section.

必要な証拠は指定のReturnへ残し、会話では結果・残件・受入待ちなどを簡潔に伝える。返却を正式受入や仕事全体の終了と同一視しない。

## Direct User Work

Provide the explanations, questions, and results needed for the request in normal Japanese.


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

# 適用範囲

従来の調整役向けAGENTS.md参照を、今回のユーザー指示により全担当へ統一した。具体的な役割・操作権限は現在の委任に従う。
