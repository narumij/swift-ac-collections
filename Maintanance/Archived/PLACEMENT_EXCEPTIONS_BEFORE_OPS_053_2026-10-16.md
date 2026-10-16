# OPS-053 配置維持例外の整理前原文

2026-10-16、Astra。TASK_RULES_V2.mdの該当節を原文保存。現行規則ではなく整理前の証拠。コード表記のパスはrepository直下基準。

## 正本整理時の配置維持例外

正本整理、役割別のfolder分け、またはArchivedへの移動を行う場合でも、次のMarkdownは現在位置から
移動または改名しない。この表は配置だけの例外を定め、各文書の権限、正本性、内容の更新規則は変更しない。配置変更はユーザーの明示指示に従う。文書内の履歴整理は、各文書の権限と圧縮手順に従って別に扱う。

| Markdown | 現在位置に残す理由 |
| --- | --- |
| `Maintanance/Testing/TESTING.md` / `Tests/CLAUDE.md` / `Maintanance/Testing/Fixtures.md` | テスト整備の恒久task `TEST-005` の維持文書。個別作業の完了を理由に移動・改名・アーカイブしない |
| `Maintanance/ProgressV2/PROGRESS_OVERVIEW_V2.md` / `Maintanance/ProgressV2/TASK_REGISTRY_V2.md` / `Maintanance/ProgressV2/TASK_RULES_V2.md` / `Maintanance/ProgressV2/TASK_REGISTRY_ARCHIVE.md` / `Maintanance/ProgressV2/TASK_HISTORY_INDEX_MAINTENANCE.md` / `Maintanance/ProgressV2/README.md` | Task Registry運用の恒久task `OPS-044` の維持文書。個別作業や圧縮の完了を理由に移動・改名・アーカイブしない |
| `Maintanance/ProgressV2/COORDINATION_KNOW_HOW.md` / `Maintanance/MILESTONES.md` | 恒久task OPS-046・OPS-047の維持文書。個別作業の完了によって移動・履歴化しない。配置変更はユーザーの明示指示に従う |
| `Maintanance/DOCUMENT.md` | 文書整備の恒久task `DOC-030` の維持文書。個別作業の完了や文書整理で移動・改名・アーカイブせず、配置変更はユーザーの明示指示に従う |
| `Maintanance/USER_MANAGEMENT_INTERVIEW_ASTRA.md` | 協働のふりかえりの恒久task `OPS-043` に紐付くAstraの評価記録 |
| `Maintanance/ASTRA_OBSERVATIONS.md` | 同taskに紐付くAstra本人の任意の観察を本人の声のまま保持する場所 |
| `Maintanance/USER_MANAGEMENT_INTERVIEW_CODEX.md` | Codexによるマネジメント継続性の記録 |
| `Maintanance/USER_MANAGEMENT_INTERVIEW_CLAUDE.md` | Claudeによる独立したマネジメント評価の記録 |
| `Maintanance/CLAUDE_OBSERVATIONS.md` | Claude本人の任意の観察を本人の声のまま保持する場所 |
| `Maintanance/CODEX_OBSERVATIONS.md` | Codex本人の任意の観察を本人の声のまま保持する場所 |
| `Maintanance/Quality/CONCEPT_DEFINITION.md` | ユーザーが定める製品目的の最上位正本であり、ユーザー専有の現在位置と権限境界を保持する |

