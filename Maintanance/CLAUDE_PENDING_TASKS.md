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

### `CP-20261016-001` — テスト再建の記録（2026年秋）の作成

- queue状態: `AWAITING_CODEX`
- 発見元・ユーザー指示: 2026-10-16 05時台の会話。`MILESTONES.md`の画像を見たあと、ユーザーが「ひめもテスト再構築の歩みみたいなのつくるかい？」と提案した。続けて次の指示があった。
  - 置き場所：`Tests/`ではなく`Maintanance/`内のフォルダ。`Maintanance/`外のmdは徐々に減らしたい。
  - 形：`RefactoringFromAtCoder2025`のようなリファクタリング記録。
  - 中身は姫に任せる。`Fixtures.md`の移動は「まだいい」。queueで記録し、正本は作る。
- 種別候補: `EXECUTION`
- 対象範囲: `Maintanance/TestRebuild2026/`の新設（`README.md`説明正本、`EVIDENCE.md`事実正本、`Data/`、`Images/`）と、このentry。
- 対象外: `Fixtures.md`等の移動、`DOCUMENT.md`・Registry・採番表・配置維持例外の変更、source・testの変更。
- 完了条件: 説明と事実の正本、集計データ、図がそろい、件数と記述がgit履歴・保存資料・実行結果と照合できる。
- 前提・既存task候補: 恒久task `TEST-005`の関連記録。`DOC-030`（文書の入口・参照）と`HIST-001`（移行史）に隣接する。
- 担当候補・受入担当: 姫（Claude）作成 / Codex・Astra（入口への接続・受入）。
- 停止条件: 作業主体や作者を記録から確かめられない場合は、推測で埋めず「確認していない」と書く。
- 成果・検証: 2026-10-16 / Claude Opus 5.5。4ファイル（README、EVIDENCE、CSV、SVG・PNG）を作成した。
  - 宣言数の数え方を、既存の`repository-test-counts.csv`の`165c81aa`（1739件）と照合し、一致した。
  - 不具合8件は、各commitのdiffと、変更ファイルにtestが含まれることを確認した。
  - パレット検証scriptはNode.jsがないため実行していない。理由と代わりの措置は`EVIDENCE.md`の6.に書いた。
  - commitしていない。`DOCUMENT.md`や`MILESTONES.md`など入口からのリンクは張っていない（Codex・Astraの判断）。
- Codex reconciliation: 未処理

過去のreconciliation済みentryは次を参照する。

- `Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-13.md`
- `Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-14.md`
- `Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-15.md`
- `Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-15_2.md`（`CP-20261015-006`→`OPS-042`）

- [2026-10-16の照合記録](Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-16.md)（CP-20261015-007 → PERM-072）
