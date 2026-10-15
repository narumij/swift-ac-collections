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

### `CP-20261015-007` — `PERM-072` Astra最終提案への姫回答

- queue状態: `AWAITING_CODEX`
- 発見元・ユーザー指示: 2026-10-15 18:30頃の会話。ユーザーが`Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_FINAL_PROPOSAL.md`を示し、
  CLAUDE_TASK.mdでの依頼を経ずに「未採番タスクで処理して」と指示した。
- 種別候補: `EXECUTION`
- 対象範囲: 同文書の「Claude姫回答欄」2行の記入だけ。
- 対象外: 提案本文、ユーザー・V3の回答欄、集約欄、Registry、名称決定正本、source・test・DocC。
- 完了条件: 2対象に回答と理由・条件がある。
- 前提・既存task候補: Registry ID`PERM-072`（`ACTIVE`）が既に存在する。このentryは依頼票の代わりに、権限と範囲を残すためのもの。
- 担当候補・受入担当: 姫（Claude）回答 / Codex集約。
- 停止条件: 提案本文の変更が必要に見えた場合は、回答欄に書かず報告する。
- 成果・検証: 2026-10-15 18:33 JST / Claude Opus 5.5。`NextPermutationModule`は同意、`Permutation`維持は判断保留。
  `Permutation`型の宣言は、`Sources`・`Tests`・`.build/checkouts`の依存10件を検索して、`NextPermutations.swift:186`の一つだけだった。
  独立性への影響: 回答前にユーザー回答欄（module名は同意、`Permutation`は不同意）を読んでいる。V3回答欄は未回答の状態だった。commitしていない。
- 追加回答: 2026-10-15 18:45 JST、Astraが追加した「一時View名の訂正・追加回答」欄へ、ユーザーの「こんくらーべー」の求めで回答。
  `NextPermutations.Permutation`維持に同意。根拠は現行の型説明（一時view・失効・`Array`へのcopy）とprecondition messageの確認。
  回答前にユーザーの追加回答（同意）とV3の既存回答（判断保留）を読んでいる。
- Codex reconciliation: 未処理

過去のreconciliation済みentryは次を参照する。

- `Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-13.md`
- `Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-14.md`
- `Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-15.md`
- `Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-15_2.md`（`CP-20261015-006`→`OPS-042`）
