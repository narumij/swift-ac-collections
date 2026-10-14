# Claude採番待ちqueue

CodexがstableなRegistry IDを採番できない間に、ユーザーとClaudeが発見・整理・明示実行した作業を
一時的に受け渡す。このfileはTask Registryではなく、Claudeが自律的に次作業を選ぶbacklogでもない。

## 規則

- 仮IDは`CP-YYYYMMDD-NNN`とする。同日の末尾番号を増やし、再利用しない。
- ユーザーが「記録」「分解」「採番待ち」を依頼しただけなら、候補を記録して着手しない。
- ユーザーがClaudeへ具体的で境界のある実行を明示依頼した場合、その範囲だけ採番前に実行できる。
- 仮IDはTask precedence、正式な完了報告、別taskの依存、commit messageのstable IDとして使わない。
- ClaudeはRegistryの状態、最終受入、公開方針、Codex担当の完成判定を代行しない。
- 一件を終えても、別の採番待ち候補へ自動的に移らない。
- Codex復帰後、重複・衝突を確認し、正式登録、既存taskへの統合、却下のいずれかを判断する。
- 正式採番後も仮IDを消さず、正式IDと処理結果を記録して追跡可能にする。
- reconciliation済みentryは、まとまりごとに`Archived/`へ移して現役queueから除く。

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

### `CP-20261014-002` — 副作用の勾配とタスクリファクタリングの参考資料化

- queue状態: `AWAITING_CODEX`
- 発見元・ユーザー指示: 2026-10-14の会話。ユーザーが「それ、参考資料化したいな」と明示依頼した。
- 種別候補: `EXECUTION`（文書作成のみ）
- 対象範囲: `Maintanance/EFFECT_GRADIENT_REFERENCE.md`の新規作成。
- 対象外: `AGENTS.md`、`User/`、Orientation文書、Task Registryへの反映。規則化や正本採用。
- 完了条件: 会話で整理した副作用の勾配、タスクリファクタリング改訂版、Haskell対応、注意点、由来を、
  正本を上書きしない参考資料として一つの文書にまとめる。
- 前提・既存task候補: なし。Orientation V4草案（作業中）との関係づけはCodexとユーザーが判断する。
- 担当候補・受入担当: 姫（Claude）実行 / Codex受入。
- 停止条件: 既存正本との矛盾が見つかった場合は、参考資料側を直し、正本は触らない。
- 成果・検証: 作成済み。V4草案4件に同じ内容がないことをgrepで確認した（`User/MEMO.md`にユーザー自身の自己紹介文があるだけ）。
- Codex reconciliation: 未処理

過去のreconciliation済みentryは次を参照する。

- `Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-13.md`
- `Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-14.md`
