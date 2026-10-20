# Studio品質改善：Test as Spec（OPS-186）

## TL;DR
ユーザーが使う操作の約束を試験で読めるようにし、実サーバーから画面までつながる品質を段階的に確かめる。姫は小さいパッチを返し、Astraが検収する。最初の依頼は[OPS-187](STUDIO_LETTERS_E2E_PATCH.md)のみ。

## 方針・到達点
2026-10-20ユーザー依頼。「Test as Specおおめ」「パッチで用意」「タスク化して、サブタスク切って、姫に…とりあえず1件」。後続の「3000件ぐらい」は十分な試験への希望として残す。3000件を受入ノルマにはせず、件数より要求・境界と実接続の証拠を評価する。
対象はStudioの利用経路。既存実装の振る舞いを無条件に正解にしない。精読報告の疑いは再現してから修正し、既決の制限を新しい不具合として扱わない。

## Astraの優先観点
1. 実出力→ViewModel→実画面→操作結果の接続。初回は連絡、承認は次の候補。
2. 応答喪失と再試行、保存再取込、更新中断、二重起動など、利用を損なう失敗と回復。
3. 試験名と対象、重複、baseline同等性と要求適合の区別。全域の整理を初回に混ぜない。

## 根拠
精読報告は調査材料であり、全件の不具合認定・受入ではない。
- [表示との接続](DISPLAY_CONNECTION_TESTS_CLOSE_READING.md)
- [連絡](LETTER_TESTS_CLOSE_READING.md)、[承認](COMMIT_APPROVAL_TESTS_CLOSE_READING.md)
- [保存・再開・取込](SAVE_RESUME_IMPORT_TESTS_CLOSE_READING.md)、[起動・更新](STARTUP_REFRESH_TESTS_CLOSE_READING.md)
- [Registry V3](REGISTRY_V3_TESTS_CLOSE_READING.md)、[判断DB](DECISION_DB_TESTS_CLOSE_READING.md)

## 分割・完了
現在の子taskはOPS-187の1件だけ。後続は初回結果と影響で具体化し、未依頼の範囲へ連続展開しない。親の全体完了は初回合格だけでは認定しない。残る候補を実施・保留・対象外に整理し、合意した対象の利用上の約束と回復経路の証拠を揃える。

## 2026-10-20 次の区切り
OPS-187は旧起動モードでの連絡一巡のパッチ成果を受入済み（本体未適用）。ユーザー「じゃ、つぎやろう」により、[OPS-188：承認の個別・一括操作](STUDIO_APPROVALS_E2E_PATCH.md)を追加。今回の新規依頼はこの1件のみ。連絡DBで受渡しする。
