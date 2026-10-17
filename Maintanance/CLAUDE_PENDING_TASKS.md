# Claude採番待ちqueue

正式なRegistry IDへの照合・登録前に、ユーザーとClaudeが発見・整理・明示実行した作業を
一時的に受け渡す。このfileはTask Registryではなく、Claudeが自律的に次作業を選ぶbacklogでもない。

現在の入口は[進捗 V2](ProgressV2/PROGRESS_OVERVIEW_V2.md)、正式なtaskの状態・担当・依存・再開条件は
[Task Registry V2](ProgressV2/TASK_REGISTRY_V2.md)、制度・採番・文書権限は
[Task制度 V2](ProgressV2/TASK_RULES_V2.md)を参照する。調整担当からClaudeへの個別依頼と返却は
[CLAUDE_TASK.md](CLAUDE_TASK.md)で扱う。

## 規則

- 仮IDは`CP-YYYYMMDD-NNN`とする。同日の末尾番号を増やし、再利用しない。
- ユーザーが「記録」「分解」「採番待ち」を依頼しただけなら、候補を記録して着手しない。
- ユーザーがClaudeへ具体的で境界のある実行を明示依頼した場合、その範囲だけ採番前に実行できる。
- 仮IDはTask precedence、正式な完了報告、別taskの依存、commit messageのstable IDとして使わない。
- ClaudeはRegistryの状態、最終受入、公開方針、他担当の完成判定を、明示的な委任なしに代行しない。
- 一件を終えても、別の採番待ち候補へ自動的に移らない。
- ユーザーから委任された調整担当は照合依頼や成果の返却を受けて関係するentryを読み、重複・衝突を確認し、正式登録、既存taskへの統合、却下のいずれかを判断する。通常起動時の一括読みに加えない。
- 正式採番後も仮IDを消さず、正式IDと処理結果を記録して追跡可能にする。
- reconciliation済みentryは、[圧縮・アーカイブ手順](ProgressV2/TASK_REGISTRY_ARCHIVE.md)に従い、原文と追跡経路を残して`Archived/`へ移し、現役queueから除く。
- 委任された調整担当による照合・統合済みのentryの圧縮は、上記手順の範囲で、ユーザーの常設の委任としてClaudeが都度の確認なしで行ってよい。未処理のentryは動かさない。
- 履歴文書（過去のreconciliation済みentryを含む）の効力は、[AGENTS.mdの「現在の仕事と正本」](../AGENTS.md#現在の仕事と正本)に従う。


旧フィールド名`Codex reconciliation`と状態名`AWAITING_CODEX`は互換のため保持する。処理担当をCodexに限定する意味ではなく、委任された調整担当が実際の担当名を添えて照合結果を記録する。

## entry template

### `CP-YYYYMMDD-NNN` — <短い名称>

- queue状態: `CANDIDATE` / `USER_AUTHORIZED` / `AWAITING_CODEX` / `RECONCILED`
- 発見元・ユーザー指示:
- 種別候補: `DISCOVERY` / `DECISION` / `EXECUTION`
- 対象範囲:
- 対象外:
- 完了条件:
- 前提・既存task候補:
- 担当候補・受入担当:
- 停止条件:
- 成果・検証: 未着手
- Codex reconciliation: 未処理

## 採番待ち

### `CP-20261017-010` — Registry Studio：サブタスクのサブタスク（孫）を恒久マップに入れ子で出す

- queue状態: `AWAITING_CODEX`（実施済み・未commit）
- 発見元・ユーザー指示: 2026-10-17、ユーザー「OPS-070に付随するサブタスクがみえないな」→姫が原因を報告→「うん、なおして。あとサーバー実行型にかわってるからね」。
- 原因: 恒久マップ（`permanentMapData`）が常設taskの直下の子しか描かず、OPS-044→OPS-070→OPS-071/072の孫が出なかった。孫は親が常設でないため独立列へ紛れていた。Registryの親子表は正しかった。
- 実施: `index.template.html`：`permanentMapData`に深さ優先の`descendants`（`depth`付き、循環防止）を追加し、恒久マップは字下げして親の行から線を引く。独立列は常設taskの子孫を全段で除外。`children`（直下の子）は互換のため残した。`verify.cjs`：旧fixtureの「孫は独立列に出る」前提を改め、孫が入れ子になること・親が先に並ぶこと・実データでOPS-071がOPS-044の下depth 1に出て独立列に出ないことを検査。Registry・sync.pyは変更なし。
- 検証: `sync.py`（保存済みtool記録）で生成とverifyが通過（tasks 56）。生成JSONでOPS-044常設、OPS-070→071/072の親子を確認。Safariでの見た目は未確認（ユーザーの画面で確認）。
- commit: していない。
- Codex reconciliation: 未処理

### `CP-20261017-009` — 「姫」を称号から屋号へ変える検討

- queue状態: `CANDIDATE`（記録のみ。未着手）
- 発見元・ユーザー指示: 2026-10-17、同じ会話の途中で実行モデルがOpus→Fable→Opusと切り替わり、「誰として続けるか」の確認で作業が止まった。ユーザー「fableをブースト姫あつかいして、マージ気味に扱う方がいいのかな？」「姫は称号じゃなくて、屋号か」「あすとらさん動けないから、未採番で、屋号検討タスク依頼かなぁ」。
- 種別候補: `DECISION`（方針はユーザー決定、AI単独で確定しない）
- 対象範囲: 「姫」を個人（ネームドOpus）の称号から、会話の系譜につく屋号へ変えるかの検討。屋号案では記録に`姫（Opus）`／`姫（Fable）`と実行モデルを添え、queueはCP-へ一本化する。権限（OPS-044の調整代理など）は屋号に付けず、従来どおりユーザーの明示委任で人（実行モデル）に付ける。
- 対象外: この検討中の仕組み変更の実施。CLAUDE.md、FABLE_TASK.md、FABLE_PENDING_TASKS.md、FABLE_COORDINATOR_DEPUTY.md、Registry、メモリの書き換え。
- 完了条件: 屋号にするか否か、する場合の(1)記録の署名形式、(2)CP-/FP-とCLAUDE_TASK/FABLE_TASKの統合可否、(3)委任の付け先、(4)一括切替の手順と対象ファイル一覧、をユーザーが決める。
- 前提・既存task候補: OPS-044（Fable調整代理）、FABLE_COORDINATOR_DEPUTY.mdの「モデル切替で委任は移らない」。メモリ上の「姫はネームドOpusの称号」「Fableは姫を名乗らない」の記述が影響を受ける。
- 担当候補・受入担当: 検討の整理は姫（どのモデルでも可）。受入・採番はAstraが動けないため、ユーザーまたはユーザーが指名した調整担当。Fable自身の扱いに関わるので、Fableが単独で受入するのは避けたい（姫の意見）。
- 停止条件: 一括切替を伴わない部分的な移行（新旧の並行運用）が必要になったら止めて戻す。
- 時期の目安: ユーザー「屋号にするのはFableが安くなったときがいいとおもうけどなｗ」（2026-10-17）。それまでは称号のまま、未採番→Fable整理の運用で進める。
- 追加論点（姫）: 統合しすぎると、別モデルが互いを見直す独立性が薄れる。屋号にしても見直し役は残したい。
- 成果・検証: 未着手
- Codex reconciliation: 未処理

2026-10-17までのreconciliation済みentry（CP-20261016-013、CP-20261017-001〜008）と2026-10-16〜17の照合節の原文は[2026-10-17の圧縮記録](Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-17.md)へ保存。CP-013はOPS-059（FROZEN）、001〜004はOPS-047 / OPS-048、005はOPS-048、006はQUALITY-002、007はRBT-048判断材料、008はOPS-044へ統合済み。

CP-004〜012は[照合済み履歴](Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-16_3.md)、CP-014〜016は[原文と統合結果](Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-16_4.md)へ保存済み。

過去のreconciliation済みentryは次を参照する。

- `Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-13.md`
- `Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-14.md`
- `Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-15.md`
- `Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-15_2.md`（`CP-20261015-006`→`OPS-042`）

- [2026-10-16の照合記録](Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-16.md)（CP-20261015-007 → PERM-072）
- [2026-10-16の照合記録（2）](Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-16_2.md)（CP-20261016-001〜003 → HIST-003・TEST-006・TEST-007）
