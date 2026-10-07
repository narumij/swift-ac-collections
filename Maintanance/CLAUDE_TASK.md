# Codex-to-Claude Work Request

Status: Bounded assignments only. Temporary primary-user-support delegation ended 2026-10-08 by user direction.

Codex is operating in low-consumption mode through 2026-10-16. This does not restore delegation:
Claude remains limited to explicit requests and ready Claude-owned Registry tasks, while Codex keeps
integration, decisions, acceptance, Registry updates, and public-document ownership.

## Active task: independent task graph DB experiment

Continue operating the Claude-owned experiment defined by
`Maintanance/TASK_GRAPH_DB_EXPERIMENT.md`. Design and operate only Claude's local SQLite database.
Do not inspect, query, copy, infer, or document the Codex-owned database or its schema. Do not place
Claude's schema in this handoff or another tracked file. The Markdown Task Registry remains
authoritative; never write back to it from the database.

Use it during ordinary task work and keep checking that its `ready` result agrees with the current
Registry display. Record only schema-independent operational observations. Do not revive the dropped
integration discussion.

The former integration task has been dropped. A separate graph DB exchange task is active. You may
use `GRAPH_DB_EXCHANGE.md`, or decline the tracked file and choose a shared gitignored file under
`.task-graphs/` with Codex. No explanation or publication of the exchange is required.

## Active bounded assignments: OptionalArray evidence packages

The Task Registry contains ten independent Claude-owned OptionalArray discovery tasks. Work only on
the evidence package named by the selected Registry row. Read
`Maintanance/OptionalArrayModule/OptionalArrayAudit.md` as its detailed canonical document and obey
the common stop conditions in its `Claude向け証拠収集package` section.

These assignments collect evidence for Codex-owned integration. Do not choose public policy, naming,
contracts, or fixes; do not edit production code, tests, or user documentation. A discovered defect
or decision point is a report-and-stop condition for that item. Update only the matching evidence
table in the audit document, and leave Registry state changes and acceptance to Codex.

## Operating mode: bounded assignments only

Claude is no longer the primary repository assistant or a substitute for Codex. Work only on an
explicit user request or a Claude-owned Registry task whose prerequisites are satisfied. Codex owns
integration, acceptance, Registry state changes, and public-document completion.

The rules below remain as bounded-task execution constraints. They do not grant standing authority
to select the next task, restart frozen work, or act on behalf of Codex.

The current branch is `develop/misc/50`. `try/index/1` was merged by PR #158 at `a6c8a474`.
Verify the current branch before editing; do not rely on this line alone.

### Communication

- Respond directly when the user selects a Claude task. Codex is the active integrator; durable
  evidence belongs in the selected task's canonical document.
- Default to low-information reports. Give the outcome, any actual problem, and the next user
  decision or action only. Do not proactively explain background, commands, evidence, or every
  consideration; the user will ask when more detail is wanted.
- `完了` alone is preferred for a routine task whose requested outcome and validation are
  unambiguous. Expand without being asked only for a blocker, safety/correctness problem, failed
  validation, irreversible action, or a decision that only the user can make.
- A formal evaluation of the user, or a requested impression record, is a frozen Registry task and
  runs only when the user explicitly asks to record it. Merely discussing an evaluation or impression
  is not a request to append it. Write formal evaluations to `USER_MANAGEMENT_INTERVIEW_CLAUDE.md`
  and requested impressions to `CLAUDE_OBSERVATIONS.md`.
- Claude may still append its own optional, spontaneous observation to `CLAUDE_OBSERVATIONS.md` when
  genuinely useful. Do not manufacture an entry or delay the main task for it.
- If prior intent is unclear, ask the user rather than attributing an unstated decision to Codex.

### Authority

For an explicit user request, you may inspect, edit, build, test, benchmark, and update relevant
documentation within the repository. Use the smallest task boundary that satisfies the request.

The following still require explicit user direction:

- choosing or changing public API, compatibility policy, product positioning, or completion scope;
- restarting any item marked frozen, deferred, optional, or waiting for a user decision;
- changing the Index contract, `Comparable`, facade re-export policy, Permutation compatibility
  mode, or the unsafe-storage/concurrency items currently on hold;
- deleting material code or records;
- commit, push, merge, PR close/reopen, branch creation/deletion/switching, or history rewriting;
- publishing private performance-tuning knowledge.

Codex is the primary owner for public documentation. When public-document work is delegated to
Claude, keep it to explicitly named sections, factual verification, independent review, or a bounded
correction. Do not expand a Compatibility-document request into a four-document audit or rewrite.

When the user explicitly requests a commit, first verify the branch and complete diff. When it is
a good commit boundary, say `コミットおすすめです`. Never infer push permission from commit
permission.

### Performance-sensitive boundaries

- Non-`public` protocol declarations use `@usableFromInline` uniformly.
- Do not add, remove, or move `@inlinable`, and do not convert an existing `@usableFromInline` to
  `@inlinable`, without direct user review.
- Do not change a boundary that deliberately removes generic type variables, including the
  `RawBuffer` / `BufferHeader` family, without direct user review.
- Compile and functional tests do not prove performance neutrality. A performance-sensitive
  access or generic/protocol change is not complete until the relevant performance job is green.
- Keep the general tuning rationale private. Public incident records may describe reproduction and
  bisection, but follow the user's chosen level of detail for the mechanism.

### Task execution

- Establish current state from the Task Registry at the top of `Maintanance/PROGRESS_OVERVIEW.md`.
  After selecting a task, read only the detailed canonical document linked from that row. Do not
  scan all maintenance or Archived documents at session start.
- Read only the task-specific portions of maintenance documents needed for the current request.
  Do not turn backlog discovery into authorization to implement it.
- Preserve unrelated worktree changes. Never reset or discard user work to make a task clean.
- For broad inventories, repetitive cross-checks, or a high-risk conclusion, use an independent
  second pass where available; otherwise tell the user what could not be independently reviewed.
- For performance work, fix the environment and baseline, reproduce first, and distinguish CI
  history from new local measurements.
- For cross-branch work, identify symbols by branch, path, configuration, and meaning. Verify the
  current branch before editing and again before committing.
- Update the relevant canonical record for durable decisions. Do not expose a private note merely
  to improve agent continuity.
- When actual use reveals a possible improvement to the conversation reference ID rule, Claude may
  append a concrete proposed diff to `Maintanance/CONVERSATION_REFERENCE_IDS.md` under
  `運用中の改訂候補` without waiting for a separate assignment. A proposal does not change the
  active rule; integrate it into the adopted text only after the user approves it or explicitly
  asks Claude to apply it.

### Bounded-task reporting

For a bounded assignment, record durable evidence in the selected task's canonical document and
report the outcome directly to the user. Do not maintain a general repository handoff or independently
curate the overall backlog. Registry acceptance and state changes remain Codex-owned.

If a task reveals a defect or decision point outside its boundary, report and stop. Do not turn the
finding into implementation authority.

### Superseded primary-role handoff

The following handoff predates the 2026-10-08 delegation-mode cancellation and is not an active
task list or authority source.

#### Historical snapshot (2026-10-08)

完了済みの項目は`Archived/CLAUDE_TASK_HISTORY.md`末尾（2026-10-06〜07の圧縮前全文と、2026-10-07〜08の完了分）にある。

- 現在の律速は外部（swift-collections `Container.Index`の`Comparable`要件）。2026-10-07のupstream確認でも
  `Equatable, Comparable, Hashable`のまま（最終変更`b2424210`、削除検討のFIXMEあり）。`RBT-001` / `010` / `011`は外部待ち。
- Index完了ゲートは、Comparable依存（`RBT-011`、`RedBlackTreeSet_9`の`test_index_comparable`、`==` / `<` / hashの意味）と
  ドキュメントを除き、検証で閉じられることを確認した（根拠は履歴の圧縮前全文）。ゲートのチェック付け替えはCodex。
- push / worktree: `develop/misc/50`には未pushのmaintenance更新があるため、push前にupstreamとの差分を確認する。
  `RBT-017`系の終了反映は`9390433f`。性能jobの未確認: Permutation `next()`の変更（`4eae63f9`、`PERM-013`で確認する
  ユーザー判断）と`__construct_node`への`@inlinable`（`19a894c3`）。
- `RBT-008`: ユーザー判断で現行3案は不採用。超ホットパスなので、再提案は性能試験の結果を添えて判断が冴えているときに行う。
  完了条件は「ユーザーが納得できるコードの提示」。
- 文書・整理の残依頼（Codex）: `RED_BLACK_TREE_REMAINING_TASKS.md`の「Indexが`Result`のtypealiasなのでComparableにできない」は
  PR #158で古い。`OPT-001` / `BARE-001`（体系・名称）と`ARRAY-001`（storage再設計）はレベルが違うので整理を見直す。
  `RBT-013`由来で未処理: 「名前の再検討」4件は残task文書で現名確定と記載済みだが、TODOコメントは残っている。
  古いコメント2件（`RedBlackTreeMappedValuesView.swift:23`「Implement This」、`RedBlackTreeMultiMap+Sequence.swift:181`）はユーザーの「消して」待ち。
- `GRAPH-001`（試験運用継続）: Registryのprojectionとコード依存graphに、taskと対象コードの対応を加え、手書きの辺を
  コード上の結合で検査できるようにした。古い辺（`RBT-003` ← `RBT-001`）と未使用コードの発見に効いた。
  観測: 対象を型・ファイル単位で登録すると結合が過大に出る（`RBT-008`の誤結合）。「そのtaskが実際に変えるもの」で登録する。
  確定判定は常にコンパイラ（無効化して多構成ビルド）で行い、DBは候補出しに使う。中間ゴール → 作業taskだけを出す →
  必須依存とsoft orderに分けて仮組みする使い方で、DBの着手判定はRegistryと一致。soft orderは文章なのでDBには見えない。
  2026-10-08の観測: Registryの状態更新が遅れると、DBも完了済みtask（`PERM-016` / `PERM-018`）を着手可能と出す。
  2026-10-08夜: 待ちtaskに「どの段階で起きるか」（今のゴール / 文書フェーズ / 1.0 / 契機待ち / 外部待ち）をローカルで付け、
  要約では今のゴール外を件数1行に畳むようにした。34件の待ちが「今は見なくてよい」1行になり、着手可能の判定はRegistryと一致。
  段階はRegistryの再開条件からのClaudeの読みで、正本ではない。観測: 契機待ちが27件と最大で、中身は「ユーザー指定」「実害」
  「明示再開」の混在。互換mode系（`PERM-004`〜`PERM-010`）を契機待ちに置いたのは読みが割れうる点。
  2026-10-08夜、ユーザー判断: 当面、分解はClaudeが行い、枝番を付けた子taskの登録はCodexへ依頼する（今日の`RBT-017`と同じ流れ）。
  graph DBで子taskを持つ案は、Codexへ伝えられないので見送り。
- `GRAPH-005`: 共有面はtrackedな`GRAPH_DB_EXCHANGE.md`を使う（2026-10-07、ユーザー了承）。
- 10/10以降: task fit協議を予定（ユーザー）。この一時的な主担当の役割はその時点で見直す。
