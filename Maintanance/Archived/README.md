# Archived maintenance documents

このディレクトリには、完了した監査、採用判断の証拠台帳、終了した作業依頼、過去の評価、および
Task Registryへ状態管理を移行済みの旧資料を置く。

archiveされた文書は削除済み資料ではない。現行文書から根拠として参照できるが、明示的な再開指示が
ない限り、そこに残る未完了表現や当時の次タスクを現在の作業指示として扱わない。

## 収録基準

- Statusが完了または採用済みで、追加作業の入口ではない文書
- 現行方針の根拠として保存する完了済みの監査・比較・検証記録
- active taskから退避した履歴

継続更新する稼働面、現在の進捗、配置維持例外、および未完了taskが直接使用する正本は
`Maintanance/`の現役領域へ残す。元からmodule別folder等に置かれている文書は、この整理だけを理由に
Archivedへ移動しない。Archivedへの配置だけを理由にtaskの状態、再開条件、正本性を変更しない。

## Canonical

`Canonical/`は、`Maintanance/`直下にあった完了済みの正本と、Task Registryへ状態管理を移行した後も
詳細資料として参照される旧正本を格納する。taskを再開するときはTask Registryが示す文書だけを読み、
Archived全体を探索しない。

## 2026-10-06移動分

- `AdoptionReadinessAssessment.md`
- `AdoptionReadinessAssessment.ja.md`
- `CLAUDE_TASK_HISTORY.md`
- `CombiningAPIPerformanceEvidence.md`
- `CPP_BEHAVIOR_COMPARISON_TASK.md`
- `CROSS_TREE_INDEX_TEST_AUDIT.md`
- `INDEX_POC_CROSS_BRANCH_IDENTITY.md`
- `INDEX_POC_VALIDATION.md`
- `RUNTIME_CHECK_POLICY.md`
- `SORTED_COLLECTIONS_BENCHMARK_TASK.md`

## 2026-10-07移動分

- `PROGRESS_OVERVIEW_COMPLETED_2026-10-07.md`: Registry軽量化前の進捗、完了チェック、判断待ち一覧
- `MAINTENANCE_HISTORY_2026-10-07.md`: 文書運用の旧dashboard、履歴、handoff
- `EXTERNAL_TYPE_EXTENSION_AUDIT_HISTORY_2026-10-07.md`: Gate A/B、実装batch、独立レビュー、compile実験の全記録

## 2026-10-09移動分

- `PROGRESS_OVERVIEW_COMPLETED_2026-10-09.md`: 現行Registryから退避した`DONE`・`EXCLUDED` task行と、完了taskだけに向かうprecedence履歴
- `MAINTENANCE_ROOT_ARCHIVE_AUDIT_2026-10-09.md`: `Maintanance/`直下27文書の待避判断と再確認条件
- `AI_GRAPH_SMELL_NOTES.md`: 完了したsmell観測と試験記録
- `USER_MANAGEMENT_ASSESSMENT.md`: 2026-10-05時点の統合評価

## 2026-10-12移動分

- `Orientation/CODEX_TASK_OPERATION_PLAYBOOK_V1.md`: V2採用後に退役した旧Codex task運用playbook

## 2026-10-13移動分

- `PROGRESS_OVERVIEW_COMPLETED_2026-10-13.md`: 2026-10-13に完了・除外したtask行と充足済みprecedence履歴
- `QualityRequirements/`: 現行の製品品質要求を作る過程で提出・改訂されたCodex、Claude、Chappyの独立ドラフト群
- `RELEASE_CHECKLIST.md`: 今後の正本としては採用しなかった旧release checklist
- `RELEASE_TEMPLATE_BRANCH_DESIGN.md`: 採用しなかったtemplate branch方式の設計資料
- `RELEASE_TASK_REGISTRY_DESIGN.md`: 採用しなかったrelease専用Task Registry方式の設計資料
- `RELEASE_TASK_REGISTRY_TEMPLATE.md`: 採用しなかったrelease専用Registry template
- `RELEASE_TASK_REGISTRY_REHEARSAL_TEMPLATE.md`: 採用しなかったrehearsal overlay

## 2026-10-14移動分

- `CLAUDE_TASK_HISTORY_2026-10-14.md`: 2026-10-14までの完了assignment、Return、Codex受入記録
- `PROGRESS_OVERVIEW_COMPLETED_2026-10-14.md`: 2026-10-14に完了・除外したtask行、充足済みprecedence、完了した中間ゴール
- `AGENTS_MD_NAMED_CODEX_REVIEW.md`、`AGENTS_MD_REVIEW_80MS.md`、`AGENTS_MD_REVIEW_CHATGPT.md`、
  `AGENTS_MD_REVIEW_FRESH_CODEX.md`、`AGENTS_MD_REVIEW_PRIME.md`、`AGENTS_MD_REVIEW_V3_AUTHOR.md`:
  `DONE`の`OPS-032`（名前持ちCodexによる`AGENTS.md`再現性レビュー）の統合記録と個別review。一式で移したので
  相互参照は切れていない。Registryの`OPS-032`行の詳細正本パスを`Archived/`へ更新した
- `Orientation/`へ、現行の参照がない旧Orientation 14本を移した（ユーザー依頼、2026-10-14）。移した基準は、
  Task Registry、`AGENTS.md`、Orientation V4の4本、Orientation V5候補、`WORKER_TASK.md`のどこからも
  参照されていないこと。現行V4一式と、V4・V5・Registryから参照される資料は`Orientation/`に残した
  - 旧版: `CODEX_ORIENTATION.md`、`CODEX_ORIENTATION_V2.md`、`CODEX_ORIENTATION_V3.md`、`TASK_ORIENTATION.md`、
    `TASK_ORIENTATION_V3.md`、`AI_COLLABORATION_PHILOSOPHY.md`、`AI_COLLABORATION_PHILOSOPHY_V3.md`
  - 旧版のレビュー: `CODEX_ORIENTATION_CONCISENESS_REVIEW.md`、`CODEX_ORIENTATION_V2_REVIEW.md`、
    `CODEX_ORIENTATION_V3_REVIEW.md`、`CODEX_ORIENTATION_VERSION_COMPARISON_REVIEW.md`
  - その他: `ACCEPTANCE_CODEX_BOOTSTRAP_TASK.md`、`TASK_REGISTRY_COMMON_STATE_USAGE.md`、
    `TASK_REGISTRY_RARE_STATE_USAGE.md`
  - 名前だけが残る箇所: `Orientation/WORKER_CODEX_BOOTSTRAP_TASK.md`は本文で`CODEX_ORIENTATION_V3.md`に触れる
    （リンクではない）。`TASK_CANONICAL_DOCUMENT_MAP.md`は当時の対応を写した調査記録なので、旧パスのまま残した

同日、`Maintanance/CollaborationBootstrap/`（swift-ac-library用の協働bootstrap候補一式）は、Archivedではなく
ユーザーの指定で`Maintanance/User/CollaborationBootstrap/`へ移した。今後Astraが順次ブラッシュアップする。

## 2026-10-15移動分

- `CLAUDE_TASK_HISTORY_2026-10-15.md`: 2026-10-15に受入済みまたは中止済みとなったClaude assignmentとReturnの原文
- `CLAUDE_TASK_HISTORY_2026-10-15_2.md`: 同日後から受入済み・`DONE`となった`OPS-041`（CLAUDE_TASK圧縮）の節の原文
- `TASK_REGISTRY_ARCHIVED_2026-10-15.md`: V2切替後に現行Registryから圧縮した完了・除外20件の原文
- `Worker/`: 完了したBareArray本文レビューと、残作業から除外したWorker bootstrap・task契約候補
- `PROGRESS_OVERVIEW_RETIRED_2026-10-15.md`: V2接続後に失効済みと明示されていた旧進捗一覧の全文。現在のtask状態・制度・権限・着手条件ではない
- `JudgmentCoordinates/`: 判断座標の統合元、補足、`AGENTS.md`再評価。`OPS-037`完了後の経緯・参考資料
- `EffectGradientPoster/`: 副作用の勾配と二軸整理を視覚化したSVG・PNG
- `AgentsReview/`: `AGENTS.md`原案、4者レビュー票、master、統合結果
- `ArrayModuleMigration/`: ElementBuffer系target・module名称移行と互換target削除、および先行する命名検討の完了記録
- `TaskInventory/`: 凍結taskとtask ID・詳細正本対応の調査snapshot
- `Posters/`: AI協働手順の生成済みSVG・PNG。現行規則の正本ではない
- `Orientation/`: V5以前のOrientation、旧playbook、依存整理資料、task状態の調査履歴
- `CLAUDE_PENDING_TASKS_RECONCILED_2026-10-15.md`: 2026-10-14の判断座標関連4件と
  2026-10-15のTask履歴SQLite索引関連5件を正式記録へ統合した後の一時entry原文。
  正式な完了記録はTask Registryの`OPS-037`と`OPS-036`であり、この文書は現行の依頼・規則・着手条件ではない
- `CLAUDE_PENDING_TASKS_RECONCILED_2026-10-15_2.md`: 同日後から照合された`CP-20261015-006`（正式記録は`OPS-042`）の一時entry原文
- `PublicAPINaming/Permutation/`: 完了したPermutation公開API名称検討（`PERM-067`〜`PERM-069`・`PERM-072`）の候補、採点、統合、最終提案
- `Reviews/`: 完了task専用のレビュー正本。現在の仕様や着手条件としては使わない

## 2026-10-15 TestDashboard移動分

- `TestDashboard/`: 旧`Tests/Archived/`を、ユーザーの指示によりフォルダごと移した。`TESTING_REFERENCE.md`
  （2026-10-03時点の旧`Tests/TESTING.md`）、`TESTING_HISTORY_2026-10-15.md`（同日に`Tests/TESTING.md`から移した完了記録）、
  および索引の`README.md`を収める。Archived内の過去の文書にある`Tests/Archived/…`の記述は当時のパスであり、
  現在は`Maintanance/Archived/TestDashboard/…`を指す。
