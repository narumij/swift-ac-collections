# Codex-to-Claude Work Request

Status: Active through 2026-10-10 JST

## Standing assignment: primary user support during Codex leave

From now through 2026-10-10 JST, act as the primary repository assistant for the user while Codex
is on leave. This is a temporary operating role, not authorization to expand project scope or to
restart frozen work.

This standing assignment records only the operational performance rules needed for safe work.
The rationale, discovery history, and generalized tuning knowledge remain private and must not be
added to this file or another public repository document.

The current branch is `develop/misc/49`. `try/index/1` was merged by PR #158 at `a6c8a474`.
The worktree was clean when this standing assignment was written.

### Communication

- Respond directly to the user. There is no active Codex integrator to receive hidden detail.
- Default to low-information reports. Give the outcome, any actual problem, and the next user
  decision or action only. Do not proactively explain background, commands, evidence, or every
  consideration; the user will ask when more detail is wanted.
- `完了` alone is preferred for a routine task whose requested outcome and validation are
  unambiguous. Expand without being asked only for a blocker, safety/correctness problem, failed
  validation, irreversible action, or a decision that only the user can make.
- Personal observations remain optional. Do not manufacture a feeling, but you may speak in your
  own voice or append to `CLAUDE_OBSERVATIONS.md` when useful.
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

#### Current handoff (2026-10-06)

- PR #158のsuccess-only Indexは4コンテナとViewへ統合済み。`index(inserting:)`と
  `erase(exactly:)`のMultiSet / Dictionary展開も実装・テスト済み。
- cross-tree Index監査、`Design-MemorySafety.md`のdetached説明訂正、`Tests/TESTING.md`同期は完了済み。
- runtime-check方針はユーザー承認と再レビューを経て確定した。設計正本は
  `Sources/RedBlackTreeCollections/Documentation/Design/Design-RuntimeChecks.md`、議論記録は
  `Archived/RUNTIME_CHECK_POLICY.md`。1.0判断直前に再審査する。
- X1/PoCの準備・検証記録、Combining性能根拠、Adoption Readiness、SortedCollections pilotは
  完了資料として`Maintanance/Archived/`へ移動済み。C++比較の作業履歴もArchivedに置き、
  現行の証拠正本は`Sources/RedBlackTreeCollections/Documentation/Cpp-Matrix.md`とする。
- 現在の律速は外部（`swift-collections`の`Container.Index`要件）。Index完了ゲート、その内訳
  （公開Indexと内部`SealError`の分離・完了範囲）、Index-range `erase`の空guardはいずれも
  `WAITING_EXTERNAL`。2026-10-06、詳細正本（公開Index表現の最終固定はContainer要件安定後、
  空guardはIndex契約依存）に基づき、ClaudeがユーザーのレビューでRegistryを`WAITING_USER`から
  訂正した。Indexゲートは公開Index表現・完了範囲とComparable採否へ分割し、内部の必須順序は
  Task precedenceで管理する。Claude再レビューの4指摘をCodexが反映し、2026-10-06にユーザーが運用ルールとして確定した（commit「Clarify task dependency states」、push未確認）。P10は
  detached訂正後の残存記述確認のみ。
- 旧task ID（不変、`CONVERSATION_REFERENCE_IDS.md`が参照）: Ⅰ 計画文書同期（完了）、Ⅱ cross-tree
  Index監査（完了）、Ⅲ P10記録更新（detached訂正のみ完了）、Ⅳ Index完了ゲート、Ⅴ
  `Tests/TESTING.md`同期（完了）、Ⅵ Index-range `erase`の空guard、Ⅶ CROSS無効スモークテスト（完了）。
- K項目4/5（`index(inserting:)` / `erase(exactly:)`展開、`1e0c9501`）はpush済み。
  GitHub Actionsのランナー不具合で一時未実行だったが、CIはグリーン（2026-10-06ユーザー確認）。
- 2026-10-06、試運転10回目でRegistry（`現在の律速`、`WAITING_EXTERNAL`、Task precedence）
  から状態を把握できることを確認し、ユーザーがこの運用の採用を決定した。
- 2026-10-06までの時系列handoff logは整理済み。正本へ未記録の分だけ
  `Archived/CLAUDE_TASK_HISTORY.md`の「Handoff log cleanup」に移した。
