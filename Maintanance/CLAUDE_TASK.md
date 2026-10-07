# Codex-to-Claude Work Request

Status: Active through 2026-10-10 JST

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

## Standing assignment: primary user support during Codex leave

From now through 2026-10-10 JST, act as the primary repository assistant for the user while Codex
is on leave. This is a temporary operating role, not authorization to expand project scope or to
restart frozen work.

This standing assignment records only the operational performance rules needed for safe work.
The rationale, discovery history, and generalized tuning knowledge remain private and must not be
added to this file or another public repository document.

The current branch is `develop/misc/50`. `try/index/1` was merged by PR #158 at `a6c8a474`.
Verify the current branch before editing; do not rely on this line alone.

### Communication

- Respond directly to the user. There is no active Codex integrator to receive hidden detail.
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

### Handoff for Codex return

Maintain exactly one concise dated `Current handoff` in the Result section below. This is an
overwrite-only dashboard, not a chronological log. Keep it to at most 10 bullet items and replace
superseded state instead of appending another dated result block. Record only durable state:

- user decisions;
- commits and whether they were pushed;
- validation performed and failures still open;
- worktree/branch state;
- frozen items explicitly resumed or newly frozen; and
- questions still requiring the user or Codex.

Do not paste routine command output or duplicate existing canonical documents. Before replacing
the dashboard, move only non-duplicated durable history that is still worth preserving to
`Maintanance/Archived/CLAUDE_TASK_HISTORY.md`; otherwise remove superseded handoff text. Do not keep
a chronological log below `Current handoff`.

On or after 2026-10-10, do not assume this temporary primary role continues; follow the user's
current instruction and prepare the handoff for Codex if requested.

### Result / handoff

#### Current handoff (2026-10-08)

完了済みの項目は`Archived/CLAUDE_TASK_HISTORY.md`末尾（2026-10-06〜07の圧縮前全文と、2026-10-07〜08の完了分）にある。

- 現在の律速は外部（swift-collections `Container.Index`の`Comparable`要件）。2026-10-07のupstream確認でも
  `Equatable, Comparable, Hashable`のまま（最終変更`b2424210`、削除検討のFIXMEあり）。`RBT-001` / `010` / `011`は外部待ち。
- Index完了ゲートは、Comparable依存（`RBT-011`、`RedBlackTreeSet_9`の`test_index_comparable`、`==` / `<` / hashの意味）と
  ドキュメントを除き、検証で閉じられることを確認した（根拠は履歴の圧縮前全文）。ゲートのチェック付け替えはCodex。
- push / worktree: `develop/misc/50`の未pushは`ee258340`だけ。作業ツリーにCodexの`RBT-018`〜`RBT-025`登録と
  このhandoff・履歴の更新があり、未commit。性能jobの未確認: Permutation `next()`の変更（`4eae63f9`、`PERM-013`で確認する
  ユーザー判断）と`__construct_node`への`@inlinable`（`19a894c3`）。
- `RBT-008`: ユーザー判断で現行3案は不採用。超ホットパスなので、再提案は性能試験の結果を添えて判断が冴えているときに行う。
  完了条件は「ユーザーが納得できるコードの提示」。
- `RBT-017`〜`RBT-025`は不要として閉じる依頼（2026-10-08夜、ユーザー了承、Registry反映はCodex）: `211ca2fc`（2026-10-05、
  ユーザーcommit）と`API-Matrix-View.md`で「部分Viewの`subscript` / `swapAt`はO(1)、範囲所属は標準Collection同様の呼び出し側
  事前条件、必要なら`isElement(at:)`を明示的に使う」と確定済みで、仕様test`test_subrangeValuesSingleIndexOperations_doNotCompareKeys`
  が固定している。発端の`RBT-013`報告「文書は範囲内前提なのに実装が検査しない＝不一致」はClaudeの誤認（事前条件を実装で検査しない
  のは不一致ではない）で、`RBT-018`も履歴・仕様test・API Matrixを見ずに判断点なしとした調査不足。F-1〜F-4の判断は無効。
  コード変更なし（`RBT-024`の試行は元に戻した）。`RED_BLACK_TREE_REMAINING_TASKS.md`の「文書を緩めず、実装側へ範囲検査を追加して
  解消する」節と`RBT-014` ← `RBT-024`の依存も外す。
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
- `GRAPH-005`: 共有面はtrackedな`GRAPH_DB_EXCHANGE.md`を使う（2026-10-07、ユーザー了承）。
- 10/10以降: task fit協議を予定（ユーザー）。この一時的な主担当の役割はその時点で見直す。
