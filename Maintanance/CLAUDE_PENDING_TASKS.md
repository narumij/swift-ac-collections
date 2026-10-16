# Claude採番待ちqueue

CodexがstableなRegistry IDを採番できない間に、ユーザーとClaudeが発見・整理・明示実行した作業を
一時的に受け渡す。このfileはTask Registryではなく、Claudeが自律的に次作業を選ぶbacklogでもない。

現在の入口は[進捗 V2](ProgressV2/PROGRESS_OVERVIEW_V2.md)、正式なtaskの状態・担当・依存・再開条件は
[Task Registry V2](ProgressV2/TASK_REGISTRY_V2.md)、制度・採番・文書権限は
[Task制度 V2](ProgressV2/TASK_RULES_V2.md)を参照する。CodexからClaudeへの個別依頼と返却は
[CLAUDE_TASK.md](CLAUDE_TASK.md)で扱う。

## 規則

- 仮IDは`CP-YYYYMMDD-NNN`とする。同日の末尾番号を増やし、再利用しない。
- ユーザーが「記録」「分解」「採番待ち」を依頼しただけなら、候補を記録して着手しない。
- ユーザーがClaudeへ具体的で境界のある実行を明示依頼した場合、その範囲だけ採番前に実行できる。
- 仮IDはTask precedence、正式な完了報告、別taskの依存、commit messageのstable IDとして使わない。
- ClaudeはRegistryの状態、最終受入、公開方針、Codex担当の完成判定を代行しない。
- 一件を終えても、別の採番待ち候補へ自動的に移らない。
- Codexは照合依頼や成果の返却を受けて関係するentryを読み、重複・衝突を確認し、正式登録、既存taskへの統合、却下のいずれかを判断する。通常起動時の一括読みに加えない。
- 正式採番後も仮IDを消さず、正式IDと処理結果を記録して追跡可能にする。
- reconciliation済みentryは、[圧縮・アーカイブ手順](ProgressV2/TASK_REGISTRY_ARCHIVE.md)に従い、原文と追跡経路を残して`Archived/`へ移し、現役queueから除く。
- Codexによる照合・統合済みのentryの圧縮は、上記手順の範囲で、ユーザーの常設の委任としてClaudeが都度の確認なしで行ってよい。未処理のentryは動かさない。
- 履歴文書（過去のreconciliation済みentryを含む）の効力は、[AGENTS.mdの「現在の仕事と正本」](../AGENTS.md#現在の仕事と正本)に従う。

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

### `CP-20261016-004` — 判断座標の草案の改訂（`TEST-007`の本文修正）

- queue状態: `USER_AUTHORIZED`
- 発見元・ユーザー指示: 2026-10-16 13時頃の会話。ユーザーが「ひめ、採番すんだから、判断座標の更新したがってたやつ未採番でやっちゃって」と指示し、
  中断後に「つづけて」と再開した。`TEST-007`の照合記録が「本文修正は配置と分け、ユーザー判断へ返す」としていた部分への、ユーザーの判断である。
- 種別候補: `EXECUTION`
- 対象範囲: `Maintanance/Testing/JudgmentCoordinates/`を新設し、原本の写し`JUDGMENT_COORDINATES.md`に`CP-20261016-003`の所見7点を反映。
  由来・預かり・共有の扱いを書いた`README.md`を置く。
- 対象外: Archivedの原本（改変しない）。統合元・補足の5文書の写し。`TASK_RULES_V2.md`・Registry・`DOCUMENT.md`・`TESTING.md`からのリンク（Astra）。規則への昇格。
- 前提・既存task候補: `TEST-007`（配置・紐付け、Astra）。`TEST-005`。
- 担当候補・受入担当: 姫（改訂）/ Astra（`TEST-007`への統合・入口接続・受入）。
- 成果・検証: 2026-10-16 / Claude Opus 5.5。
  - 7点を反映した。原本のパス`User/CONCEPT_DEFINITION.md`は現行の`Maintanance/Quality/CONCEPT_DEFINITION.md`に直した。
  - 所見6のcommit件数は再集計した（10-15 00:00以降、`ff209700`まで155件中、件名にtask番号の形があるもの5件）。所見作成時の「149件中2件」から更新。
  - 所見4の`RBT-042`の記述は、当時の作業記録との照合をしていない（姫の記憶と会話の要約による）。
  - 訂正（同日）: 作業中にAstraが`ff209700`で6文書の写しと`README.md`を回収・commitしていた。姫はそれを確かめずに`README.md`を
    上書きし、`c3b0259a`でcommitした。誤りなので、Astraの`README.md`を`ff209700`の内容へ戻した。改訂版`JUDGMENT_COORDINATES.md`への
    案内をREADMEへ足すかはAstraに任せる。
- Codex reconciliation: 未処理

過去のreconciliation済みentryは次を参照する。

- `Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-13.md`
- `Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-14.md`
- `Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-15.md`
- `Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-15_2.md`（`CP-20261015-006`→`OPS-042`）

- [2026-10-16の照合記録](Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-16.md)（CP-20261015-007 → PERM-072）
- [2026-10-16の照合記録（2）](Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-16_2.md)（CP-20261016-001〜003 → HIST-003・TEST-006・TEST-007）

