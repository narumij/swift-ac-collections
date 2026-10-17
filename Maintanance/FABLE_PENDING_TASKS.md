# Fable採番待ちqueue

正式なRegistry IDへの照合・登録前に、ユーザーとFableが発見・整理・明示実行した作業を
一時的に受け渡す。このfileはTask Registryではなく、Fableが自律的に次作業を選ぶbacklogでもない。

現在の入口は[進捗 V2](ProgressV2/PROGRESS_OVERVIEW_V2.md)、正式なtaskの状態・担当・依存・再開条件は
[Task Registry V2](ProgressV2/TASK_REGISTRY_V2.md)、制度・採番・文書権限は
[Task制度 V2](ProgressV2/TASK_RULES_V2.md)を参照する。調整担当からFableへの個別依頼と返却は
[FABLE_TASK.md](FABLE_TASK.md)で扱う。

## 規則

2026-10-17：代理期間中は[ユーザーの明示委任](Current/FABLE_COORDINATOR_DEPUTY.md)により、Fable自身が正式採番・照合・Registry更新を行える。調整担当としての現在の割当。原返却と自身の成果の独立受入は区別する。

- 仮IDは`FP-YYYYMMDD-NNN`とする。同日の末尾番号を増やし、再利用しない。Claudeのqueue（`CP-`）とは別系列。
- ユーザーが「記録」「分解」「採番待ち」を依頼しただけなら、候補を記録して着手しない。
- ユーザーがFableへ具体的で境界のある実行を明示依頼した場合、その範囲だけ採番前に実行できる。
- 仮IDはTask precedence、正式な完了報告、別taskの依存、commit messageのstable IDとして使わない。
- FableはRegistryの状態、最終受入、公開方針、他担当の完成判定を、明示的な委任なしに代行しない。
- 一件を終えても、別の採番待ち候補へ自動的に移らない。
- ユーザーから委任された調整担当は照合依頼や成果の返却を受けて関係するentryを読み、重複・衝突を確認し、正式登録、既存taskへの統合、却下のいずれかを判断する。通常起動時の一括読みに加えない。
- 正式採番後も仮IDを消さず、正式IDと処理結果を記録して追跡可能にする。
- reconciliation済みentryは、[圧縮・アーカイブ手順](ProgressV2/TASK_REGISTRY_ARCHIVE.md)に従い、原文と追跡経路を残して`Archived/`へ移し、現役queueから除く。
- 委任された調整担当による照合・統合済みのentryの圧縮は、上記手順の範囲で、ユーザーの常設の委任としてFableが都度の確認なしで行ってよい。未処理のentryは動かさない。
- 履歴文書（過去のreconciliation済みentryを含む）の効力は、[AGENTS.mdの「現在の仕事と正本」](../AGENTS.md#現在の仕事と正本)に従う。


旧フィールド名`Codex reconciliation`と状態名`AWAITING_CODEX`は互換のため保持する。処理担当をCodexに限定する意味ではなく、委任された調整担当が実際の担当名を添えて照合結果を記録する。

## entry template

### `FP-YYYYMMDD-NNN` — <短い名称>

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

現在、採番待ちのentryはない。

過去のreconciliation済みentryは次を参照する。

- [2026-10-17の圧縮記録](Archived/FABLE_PENDING_TASKS_RECONCILED_2026-10-17.md)（FP-20261017-001 → OPS-048、FP-20261017-002 → OPS-044）

圧縮時は`Archived/FABLE_PENDING_TASKS_RECONCILED_<日付>.md`へ移し、ここにリンクを残す。
