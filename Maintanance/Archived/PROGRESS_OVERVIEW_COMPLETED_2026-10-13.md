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
| `PERM-002` | `DONE` | User | ABC328E実提出確認 | 2026-10-13、AtCoderへの手作業による実提出探索を完了。203msから最速80msまでの推移を確認し、80ms枝は製品候補ではないunsafeな上限実験として分離 | `PermutationModule/ImplementationPlan.md` / `PermutationModule/HumanAITuningReport.md` / `User/PermutationBorrowedSpanExperiment.swift` |
| `BARE-020` | `DONE` | Codex | [EXECUTION] BareArray Viewノンエスケーパブル実装の整合化 | 2026-10-13、後続の品質検証記録と現行buildを照合し、View 3型、lifetime dependency、Package設定の整合とcompile成立を確認 | `BareArrayModule/CurrentQualityAssessment.md` |
| `BARE-021` | `DONE` | Codex | [EXECUTION] BareArray compiler診断Verificationへの移行 | 所有配列writeback 3件をDeath Testからcompiler診断fixtureへ移行済み。2026-10-13、View escape 3件と合わせた6診断を再実行して成功 | `BareArrayModule/CurrentQualityAssessment.md` / `Utilities/Maintenance/VerifyBareArrayCompilerDiagnostics.sh` |
| `BARE-022` | `DONE` | Codex | [EXECUTION] BareArray有効利用経路の回帰確認 | 2026-10-13、現行sourceでDebug通常35件・Death Test 39件、Release通常28件・Death Test 39件が成功 | `BareArrayModule/CurrentQualityAssessment.md` / `Tests/BareArrayModuleTests/` |
| `BARE-028` | `EXCLUDED` | Codex | [EXECUTION] BareArray Claude手直し後の差分再検証 | 前提としていたClaudeの手直しを受け入れた事実がなく、後発の座標access API追加は別変更であるため、この条件付きtaskを実行せず除外 | `BareArrayModule/CurrentQualityAssessment.md` |
| `BARE-018` | `DONE` | Codex | [EXECUTION] BareArray Viewノンエスケーパブル化の完了ゲート | storage境界、安全性分類、strict memory safety、品質検証と分割実行を履歴・現物・2026-10-13再検証で照合し、旧View契約の完了を受入。後発の座標access APIとdeprecated指定は別taskへ分離 | `BareArrayModule/CurrentQualityAssessment.md` |

## Satisfied precedence removed from the active Registry

| 後続task | 前提task | Flow | 制約 |
| --- | --- | --- | --- |
| `RELEASE-036` | `RELEASE-035` | `SEQUENCE` | checklist移行を検証してから実行正本をactive Registryへ切り替える |
| `OPT-053` | `OPT-052` | `SEQUENCE` | 暫定結果を確認してから、必要な性能比上限を判断する |
| `BARE-021` | `BARE-020` | `SEQUENCE` | 正式実装のcompile成立後に、拒否される利用をcompiler診断のVerificationへ移す |
| `BARE-022` | `BARE-020` | `SEQUENCE` | 正式実装のcompile成立後に、有効な利用経路をDebug・Releaseで回帰確認する |
| `BARE-018` | `BARE-022` | `PARALLEL_JOIN` | 有効利用経路の回帰結果を完了ゲートへ合流する |
