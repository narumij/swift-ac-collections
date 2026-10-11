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

- `PROGRESS_OVERVIEW_HISTORY_2026-10-07.md`: Registry軽量化前の進捗、完了チェック、判断待ち一覧
- `MAINTENANCE_HISTORY_2026-10-07.md`: 文書運用の旧dashboard、履歴、handoff
- `EXTERNAL_TYPE_EXTENSION_AUDIT_HISTORY_2026-10-07.md`: Gate A/B、実装batch、独立レビュー、compile実験の全記録

## 2026-10-09移動分

- `PROGRESS_OVERVIEW_COMPLETED_2026-10-09.md`: 現行Registryから退避した`DONE`・`EXCLUDED` task行と、完了taskだけに向かうprecedence履歴
- `MAINTENANCE_ROOT_ARCHIVE_AUDIT_2026-10-09.md`: `Maintanance/`直下27文書の待避判断と再確認条件
- `AI_GRAPH_SHARED_SCHEMA.md`: 完了した共有schema最小fixtureの正本
- `AI_GRAPH_IN_MEMORY_FIXTURE.md`: 完了したSQLiteインメモリfixtureの正本
- `USER_MANAGEMENT_ASSESSMENT.md`: 2026-10-05時点の統合評価
