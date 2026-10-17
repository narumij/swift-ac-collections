# OPS-074 第2区切り：浅い点検の明細・訂正・更新条件

2026-10-17 / 姫（Opus 5.5）/ 入力版 `1bdbbd4f`。依頼：`CANONICAL_INVENTORY_APPEND.md`「姫への依頼：第2区切り」。

## 再実行

```sh
python3 Maintanance/Current/Evidence/OPS-074/shallow_check.py > /tmp/out.json   # repository根で
```

- 対象：`Maintanance/Current/*.md`（直下のみ、Evidence配下は含まない）。
- 抽出：Markdownリンク `](…)`、および`../` `Maintanance/` `Sources/` `Tests/` `Benchmarks/` `.github/` `Documentation/`で始まるバッククォート内パス。URL・glob・`<…>`・`…`を含むものは除外。末尾の`:行番号`は外して判定。
- 解決：リンクと`../`は**文書のディレクトリ基準のみ**。それ以外のバッククォートはrepository根→`Maintanance/`→文書ディレクトリの順。
- 判定は存在のみ（`os.path.exists`）。見つからないものは、主候補パスで`git log --all`の最終commitと削除commitを記録。
- hash：バッククォート内の7〜40桁16進（数字と英字を両方含む）を`git cat-file -t`で種別判定。
- 結果：`shallow_check_result.json`（全明細）。

## 集計（入力版 `1bdbbd4f`）

| 項目 | 件数 |
| --- | --- |
| 対象文書 | 76 |
| 参照（文書内で重複を除く） | 272 |
| 　存在 | 249 |
| 　存在（`:行番号`付き） | 2 |
| 　不在・gitに履歴あり | 15 |
| 　不在・gitに履歴なし（主候補パスで） | 6 |
| hash | 100 |
| 　commit | 83 |
| 　blob | 3 |
| 　gitのobjectでない | 14 |

**第1区切りとの差**：第1区切りは72文書・97 hash（入力版`d6e6fab6`）。今回は76文書・100 hash。差の4文書は第1区切り後に作られた`OPS_072_ACCEPTANCE.md`・`RECORD_LIFETIME_STUDY.md`・`CANONICAL_INVENTORY_APPEND.md`ほか（commit hashが3件増）。第1区切りの「23件」は、今回の「不在21＋`:行番号`付き2」に相当（第1区切りは`:行番号`を外さずに判定していた）。

## 不在21件の明細と仕分け

「機械判定」列はスクリプトの出力。「仕分け」列は姫の解釈（未確認を含む）。

| # | 文書 | 参照 | 機械判定 | 仕分け（解釈） |
| --- | --- | --- | --- | --- |
| 1 | AI_TECHNICAL_ORIENTATION | `../Package.swift` | 履歴なし | 文書基準では不在、repository根基準なら実在。書き手の基準が文書ディレクトリでない可能性（未確認） |
| 2 | AI_TECHNICAL_ORIENTATION | `../README.ja.md` | 履歴なし | 同上 |
| 3 | AtCoder2025CompatibilityPlan | `Sources/PermutationModule/Compatibility/AtCoder2025/` | 履歴あり・削除`1f87e37a` | モジュール移動。現行の対応先は`Sources/NextPermutationModule/`配下（中身の対応は未確認） |
| 4 | AtCoder2025CompatibilityPlan | `Sources/PermutationModule/NextPermutations.swift` | 履歴あり・削除`1f87e37a` | モジュール移動。現行`Sources/NextPermutationModule/NextPermutations.swift`が実在 |
| 5 | EXTERNAL_TYPE_EXTENSION_AUDIT | `Sources/PermutationModule/NextPermutations.swift` | 同上 | 同上 |
| 6 | MAINTENANCE_HEALTH_CHECK_2026-10-16 | `Maintanance/Current/PERMUTATION_MODULE_MIGRATION_ACCEPTANCE.md` | 履歴あり・削除`504b143b` | 日付つき点検の当時の参照 |
| 7 | 同上 | `Tests/TESTING.md:32` | 履歴あり・削除`35a27b30` | 同上（TESTING.mdは`Maintanance/Testing/`へ移動、メモリ上の知識・未確認） |
| 8 | 同上 | `Maintanance/QUALITY_REQUIREMENTS.md` | 履歴あり・削除`9d36da92` | 同上 |
| 9 | 同上 | `Sources/PermutationModule/` | 履歴あり・削除`1f87e37a` | 同上 |
| 10 | 同上 | `Maintanance/PROGRESS_OVERVIEW.md` | 履歴あり・削除`f0781092` | 同上 |
| 11 | 同上 | `Maintanance/MAINTENANCE.md` | 履歴あり・削除`e30eddcf` | 同上 |
| 12 | 同上 | `../../Current/PERMUTATION_MODULE_MIGRATION_PLAN.md` | 履歴なし | 文書基準の解決先（repository外寄り）が不正。書かれた当時の置き場を基準にした相対パスと推定（未確認）。`Current/PERMUTATION_MODULE_MIGRATION_PLAN.md`は現存 |
| 13 | MAPPED_VALUES_VIEW_CONTRACT_DECISION | `DOCUMENTATION_MILESTONES.md`（リンク） | 履歴あり・削除`e2dd63d6` | 2026-10-17のマイルストーン再編で削除。現行の接続先は担当判断（RBT-026 ACTIVE、追記しない） |
| 14 | PROVISIONAL_AGREEMENT_JUDGMENT_INVENTORY_PILOT | `Sources/PermutationModule/` | 履歴あり・削除`1f87e37a` | 姫の試行記録が旧パスを例として引用 |
| 15 | REGISTRY_STUDIO_MILESTONE_CONNECT | `Maintanance/RegistryApp/index.html` | 履歴あり・削除`bbddb7ff` | 生成物を`index.template.html`と`Cache/RegistryStudio/`へ移動 |
| 16 | RELEASE_CANDIDATE_BASELINE_INVESTIGATION | `Benchmarks/Scripts/filter_library_for_baseline.py` | 履歴なし | 調査時の提案名と推定（実施されたかは未確認） |
| 17 | 同上 | `Benchmarks/Libraries/CI-baseline-new-tasks.txt` | 履歴なし | 同上 |
| 18 | RELEASE_SHAPING_WORKER_REQUEST_DRAFT | `Maintanance/User/RELEASE_SHAPING_WORKER_REQUEST_DRAFT.md` | 履歴なし | 完成後の移動先として書かれた予定 |
| 19 | StrictMemorySafetyReadiness | `Tests/PermutationTests/PermutationDeathTests.swift` | 履歴あり・削除`5efc1a9c` | PERM-012で削除（RBT-007 ACTIVE、追記しない） |
| 20 | TASK_REGISTRY_LAYOUT_ADVICE | `Maintanance/RegistryApp/index.html` | 履歴あり・削除`bbddb7ff` | #15と同じ |
| 21 | 同上 | `Maintanance/RegistryApp/registry.json` | 履歴あり・削除`bbddb7ff` | 同上 |

仕分けの件数（解釈）：基準の違いと推定 3（#1・2・12）、モジュール移動 3（#3〜5）、日付つき点検の当時の参照 6（#6〜11）、作業中文書の古い参照 2（#13・19）、自分の試行記録の例示 1（#14）、生成物の移動 3（#15・20・21）、提案・予定のまま 3（#16〜18）。計21。

## hash 14件（gitのobjectでない）

`ASAN_STRIP_ENV_FIXED_REVISION_VALIDATION`の`50b1c281`（llvm-projectの版）、`GATE_DECISION_DIGEST_PROPOSAL`の`4b8468e7c6c7`（registry.jsonのSHA-256先頭と本文に明記）、`MAINTENANCE_HEALTH_CHECK_2026-10-16`の11件と`TASK_REGISTRY_APP_CLAUDE_ADVICE`の1件（ファイルSHA-256先頭）。blob 3件は`HIST_002_EXPLORATION`。commitを指すつもりで存在しないものは見つからなかった（14件の種別は本文の文脈による解釈、未確認を含む）。

## 限界

- 存在しか見ていない。参照先が意味上正しいか（リンクの意図・内容の対応）は判定していない。
- 抽出規則に当たらない書き方（裸のパス、別の接頭辞）は対象外。
- 「履歴なし」は主候補パスでの結果で、別基準で書かれた参照は誤って「履歴なし」になりうる（#1・2・12）。
