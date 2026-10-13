# AI Collaboration Bootstrap

## 目的

このfolderは、このrepositoryで成立した管理文書を別projectへそのまま複製するためのものではない。
WorkerとReceiverが、最小限の共通境界から協働を始め、実際の経験を通じて自分たちに合う管理方法を
ユーザーと育てられるか試すための未採用候補を置く。

このrepositoryのTask Registry、Routine、安定ID、Claude handoff、release規則は、特定の協働関係と
問題へ応答して発達した。その完成形を模範解答として移植しない。

旧方式の`Archived/Orientation/PROGRESS_OVERVIEW_TEMPLATE.md`は、完成済みのRegistry、状態、ID、依存、
起動規則を一式で別projectへ移植する候補だった。現在の候補とは前提が異なるため履歴として参照し、
このfolderの初期構成や導入手順には含めない。

## 初期構成

- `AGENTS_CANDIDATE.md`: WorkerとReceiverに共通する最小限の権限境界。
- `RECEIVER_CODEX_BOOTSTRAP.md`: Receiverの固定役割候補。
- `RECEIVER_CODEX_INTAKE_CONTRACT_TEMPLATE.md`: 一回の仕事の切り出しと受入に使う局所契約候補。

Worker用bootstrapと作業契約は、別projectでの試行範囲が定まったときに、このfolder向けの候補を作る。
現行repositoryの`Orientation/WORKER_CODEX_*`を自動的に正本または移植元としない。

## 境界

- このfolderの文書は現行operationへ未採用である。
- 候補の完成、別projectへの配置、試行開始、試行結果の受入は別の境界とする。
- `Prime`や`Queen`は役割または権限ではなく、ユーザーが実績を見て個体へ与える称号である。
- 初期状態では一回の契約だけを局所的な正本とする。
- 管理負荷が現れたら、Receiverが自分たちのための改善案を作り、ユーザーと対話して管理方法を育てる。
- `Maintanance/User/`相当のユーザー専有領域は、明示された対象と操作以外では変更しない。

## 観測すること

- Workerが全体管理を背負わず、局所作業へ集中できるか。
- Receiverが仕事の入口、独立検収、統合、完了判定を担えるか。
- 二役を上下関係へ変えず、差し戻しを契約と証拠の差として扱えるか。
- conversation喪失後に、契約、成果、証拠から復帰できるか。
- 管理上の問題を発見したとき、既存方式のコピーではなく、そのprojectに合う構造を育てられるか。

一回の成功だけで、役割設計の妥当性、能力獲得、能力定着を証明したとは扱わない。
