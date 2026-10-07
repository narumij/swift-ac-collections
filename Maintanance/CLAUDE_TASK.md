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

#### Current handoff (2026-10-07)

圧縮前の全文は`Archived/CLAUDE_TASK_HISTORY.md`末尾（2026-10-06〜07）にある。

- 現在の律速は外部（swift-collections `Container.Index`の`Comparable`要件）。2026-10-07のupstream確認でも
  `Equatable, Comparable, Hashable`のまま（最終変更`b2424210`、削除検討のFIXMEあり）。`RBT-001` / `010` / `011`は外部待ち。
- Index完了ゲートは、Comparable依存（`RBT-011`、`RedBlackTreeSet_9`の`test_index_comparable`、`==` / `<` / hashの意味）と
  ドキュメントを除き、検証で閉じられることを確認した（根拠は圧縮前全文）。ゲートのチェック付け替えはCodex。
- 2026-10-06〜07のClaude実施（commit済み）: `RBT-003`（特殊化`Result`の比較とtypealiasの縮小、`6dea75d7`。
  性能job成功を確認し`DONE`）、`RBT-002`（Index-range eraseの空でのCoW回避、`11817dfe`、`DONE`）、
  Debug限定`Result: Comparable`削除（`d239a903`）、PR #158前のIndex向け未使用宣言のテスト側待避（`2fce4782`）、
  走査比較回数・KeyValue View CoWの仕様テスト追加とDebug限定APIテストの`_98`移動。いずれも通常／互換×Debug／Releaseの
  ビルドと`swift test`で成功。LinuxのCIと性能jobはpush後に確認。
- push: `develop/misc/50`は`39360dd8`以降が未push。`4eae63f9`でPermutationのheader二重破棄を修正し、共有中の終端で
  無駄なコピーをしないよう`next()`を変更。その性能確認はユーザー判断で`PERM-013`のチューニング時に行う。
  `filter` / `mapValues`の特殊化版が未特殊化の`UnsafeTreeV2BufferHeader.__construct_node<A>`を要素ごとに呼んでいた件は、
  ユーザーが`__construct_node` / `__construct_raw_node`へ`@inlinable`を付与（未commit時点でRelease機械語の解消と`swift test`成功を確認、性能jobはpush後）。
- `RBT-012`: ユーザー指示で前倒し実施（2026-10-07）。4型の値セマンティクス仕様に、両側をassertion内で変更するテストを追加。
  Permutationでは同じ形が今もReleaseで赤だが、赤黒木はRelease/Debugとも緑で再現せず、テストは有効のまま残した。Registryの更新はCodex。
- `RBT-008`: 現状コード（`lazyDetach` / `tiedRawBuffer`の遅延生成と`@unchecked Sendable`による初回並行アクセスの競合）と
  TODO記載の3案を提示し、ユーザー判断で不採用（Codexも以前に不採用）。超ホットパスなので、再提案は性能試験の結果を添えて
  判断が冴えているときに行う。完了条件は「ユーザーが納得できるコードの提示」。
- Codexへの残依頼: `RED_BLACK_TREE_REMAINING_TASKS.md`の「Indexが`Result`のtypealiasなのでComparableにできない」は
  PR #158で古い。`OPT-001` / `BARE-001`（体系・名称）と`ARRAY-001`（storage再設計）はレベルが違うので整理を見直す。
  `RBT-013`完了（2026-10-07）: grepの27件は、TODOコメント26件と未使用の`Message.keyMismatch`の仮文字列"TODO"1件。
  文書に影響: (1) `RedBlackTreeKeyValueRangeView.values`（RangeView+KeyValue.swift:203）は「範囲内の添字」を前提条件と文書化しているが、
  `RedBlackTreeMappedValuesView`の`subscript(position:)`の`set`と`swapAt`は範囲を検査しない。検査するか文書を変えるかの決定とその実装がtask候補。
  (2) 「名前の再検討」4件（Set / MultiMapの`index(inserting:)`と`erase(exactly:)`）。文書化前に現名で確定するかのユーザー判断がtask候補。
  (3) `BalancedSequence`の3件は`#if DEBUG`限定で`RBT-004`の範囲。内部だけ17件のうち4件は`PERF-001` / `RBT-008` / `RBT-011` / `RBT-006`で既に覆われる。
  古い2件（コメント削除のみ、ユーザーの「消して」待ち）: `RedBlackTreeMappedValuesView.swift:23`「Implement This」、`RedBlackTreeMultiMap+Sequence.swift:181`（`values`は既にView）。
  `RBT-017`（2026-10-07夜）: 範囲外Indexでの`values[i] = x`と`swapAt`が止まらないことをDeath Testで赤確認済み。
  実装はClaudeが相談すべき点を独断で決めたため取り下げ（未commit、作業ツリーは元に戻した）。着手前にユーザーと決める点:
  全体viewで検査を省くか / 部分範囲での計算量O(log n)化を許すか / 停止メッセージ（`outOfRange`は凍結中） /
  新helperへの`@inlinable` / `get`も検査するか / 要素を指さないIndexと別の木のIndexの扱い / MultiMapのtest。
  `PERM-016`完了（2026-10-07夜、未commit）: 品質評価を`c64116e0`時点の事実へ更新。`swapAt`の懸念を削除し、header二重破棄の修正、
  終端の不要コピー回避（未計測を明記）、走査の共有、`#if DEBUG`の`package`検査member、行数（254行）を反映。判定と§6の問いは変えていない。`PERM-017`へ渡せる。
  `PERM-018`完了（2026-10-07夜、ユーザー了承で`PermutationTests`へswift-algorithms依存を追加、未commit）: `_4_CoexistenceTests`で
  両moduleの同時importと使い分けを固定。品質評価の共存性の判定（部分）は変えていない（判定の更新は`PERM-017`のreview側）。`PERM-019`へ進める。
  `RBT-016`は不要（ユーザー了承、2026-10-07）: `RedBlackTreePair`は型ごと`@_documentation(visibility: internal)`で、
  入口も`subscript(_pair:)`だけ。graphのspec-gapsが型側の属性を見ていなかった誤検知で、道具を直して0件を確認。閉じる処理はCodex。
- `GRAPH-001`（試験運用継続）: Registryのprojectionとコード依存graphに、taskと対象コードの対応を加え、手書きの辺を
  コード上の結合で検査できるようにした。古い辺（`RBT-003` ← `RBT-001`）と未使用コードの発見に効いた。
  観測: 対象を型・ファイル単位で登録すると結合が過大に出る（`RBT-008`の誤結合）。「そのtaskが実際に変えるもの」で登録する。
  確定判定は常にコンパイラ（無効化して多構成ビルド）で行い、DBは候補出しに使う。
  2026-10-07夕の新しい使い方: 中間ゴール → 作業taskだけを出す → 必須依存とsoft order（推奨順）に分けて仮組み。
  DBの着手判定は必須依存だけで行い、Registryと一致した（`PERM-017` / `RBT-014` / `PERM-019`が正しく待ち）。soft orderは文章なのでDBには見えない。
- `GRAPH-005`: 共有面はtrackedな`GRAPH_DB_EXCHANGE.md`を使う（2026-10-07、ユーザー了承）。
- 10/10以降: task fit協議を予定（ユーザー）。この一時的な主担当の役割はその時点で見直す。
