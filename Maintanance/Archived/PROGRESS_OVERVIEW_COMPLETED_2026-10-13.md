# Task Registry completed history — 2026-10-13

This file preserves task rows and precedence edges removed when the active Registry was compressed.
Detailed evidence remains in each row's archived document. IDs remain permanent and must not be reused.

## Completed and excluded tasks

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `RELEASE-011` | `EXCLUDED` | Codex | [DISCOVERY] `prepare/release/template`の構成設計と試行 | 2026-10-13、ユーザー判断により方式を採用せず、残存設計を参考資料としてArchivedへ移動 | `Archived/RELEASE_TEMPLATE_BRANCH_DESIGN.md` / `Archived/RELEASE_CHECKLIST.md` |
| `RELEASE-009` | `EXCLUDED` | Codex | [DISCOVERY] 0.5.1実績に基づくrelease checklist見直し | 2026-10-13、旧checklistを今後の正本として改訂せずArchivedへ移動。人間向け工程は`User/RELEASE_PROCESS.md`へ一本化 | `Archived/RELEASE_CHECKLIST.md` / `Archived/Canonical/RELEASE_0_5_1.md` / `User/RELEASE_PROCESS.md` |
| `RELEASE-035` | `EXCLUDED` | Codex | [EXECUTION] release checklistのRegistry templateへの移行 | 2026-10-13、release専用Task Registry方式を採用せず、templateと設計をArchivedへ移動したため除外 | `Archived/RELEASE_TASK_REGISTRY_TEMPLATE.md` / `Archived/RELEASE_TASK_REGISTRY_DESIGN.md` / `Archived/RELEASE_CHECKLIST.md` |
| `RELEASE-036` | `EXCLUDED` | Codex | [EXECUTION] release専用Registryへの正本切替 | 2026-10-13、移行元方式を採用しない判断により後続切替も不要となったため除外 | `Archived/RELEASE_TASK_REGISTRY_DESIGN.md` / `Archived/RELEASE_TASK_REGISTRY_TEMPLATE.md` |
| `OPT-052` | `DONE` | Codex | [DISCOVERY] OptionalArray macOS外部性能アセスメントへのアレンジ | 2026-10-12、専用library、生JSON、macOS環境記録、比較chartを保存し、後続のdirect method CI登録とは別の性能アセスメント成果として成立 | `OptionalArrayModule/CurrentQualityAssessment.md` / `Sources/OptionalArrayModule/Documentation/Quality-Profile.md` |

## Satisfied precedence removed from the active Registry

| 後続task | 前提task | Flow | 制約 |
| --- | --- | --- | --- |
| `RELEASE-036` | `RELEASE-035` | `SEQUENCE` | checklist移行を検証してから実行正本をactive Registryへ切り替える |
| `OPT-053` | `OPT-052` | `SEQUENCE` | 暫定結果を確認してから、必要な性能比上限を判断する |
