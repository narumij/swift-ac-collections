# Taskの記録 V2

> 2026-10-14、ユーザーの接続指示により、現在のtask状態と依存関係の参照・更新先を本書へ切り替えた。使い方は[入口](PROGRESS_OVERVIEW_V2.md)、変更点と切替の経緯は[作成・接続記録](README.md)を参照する。

本文のコード表記のファイルパスは、すべてリポジトリ直下を基準とする。別ファイルへのMarkdownリンクは本書からの相対パスで示す。

## Task Registry

対象の分野・ID・仕事名から該当行を探し、必要な前提と後続を確認する。分野別の見出しは検索のための区分であり、優先順位や実行順ではない。未分類の既存taskは、再開・内容更新の際に判断一つかゼロへ整え、種別を記す。

- [協働と運用](#協働と運用)
- [公開とリリース](#公開とリリース)
- [RedBlackTreeと品質ゲート](#redblacktreeと品質ゲート)
- [Permutation](#permutation)
- [OptionalElementBuffer](#optionalelementbuffer)
- [ElementBuffer](#elementbuffer)
- [移行史](#移行史)

### 協働と運用

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `GRAPH-001` | `ACTIVE` | Claude | Claude用task graph DBの独立試験 | ready判定を維持する常設nodeとして`ACTIVE`を保つ。個別assignmentや実行中ジョブを意味せず、必要なときだけ現行Registryとの一致を確認 | `Maintanance/Graph/TASK_GRAPH_DB_EXPERIMENT.md` |
| `DOC-030` | `ACTIVE` | Codex | [EXECUTION] 文書整備の恒久管理 | 文書の役割・整備方法・参照関係を維持する常設node。リンク切れの点検・修正と移動・改名時の参照元確認を含み、対象と方法は詳細正本の「リンクと参照先の保守」に従う。個別の文書作業の完了だけではDONE・履歴化しない。常時実行中や読み手への編集委任を意味せず、具体的な作業は現在の依頼と権限に従う。維持文書は配置維持の指定に従い残す | `Maintanance/DOCUMENT.md` |
| `OPS-043` | `ACTIVE` | Codex / Claude / Astra（各自の記録） | [EXECUTION] 協働のふりかえりと知見の蓄積 | 具体的な出来事と、その時点の観察・受け止め方を残す常設node。一回の回答や個別作業の完了だけではDONE・履歴化しない。人物評の固定や担当適性の判定とは区別する。評価の追記・任意観察は各文書の記入条件と現在の依頼に従い、他者の声を代筆・改変しない。常時実行中・定期記入義務・読み手への担当任命を意味せず、過去の感想を現行の規則・権限へ昇格させない | `Maintanance/USER_MANAGEMENT_INTERVIEW_CODEX.md` / `Maintanance/USER_MANAGEMENT_INTERVIEW_CLAUDE.md` / `Maintanance/USER_MANAGEMENT_INTERVIEW_ASTRA.md` / `Maintanance/CODEX_OBSERVATIONS.md` / `Maintanance/CLAUDE_OBSERVATIONS.md` / `Maintanance/ASTRA_OBSERVATIONS.md` |
| `TEST-005` | `ACTIVE` | Claude（姫） | [EXECUTION] テスト整備の恒久管理 | Test as Specificationを中心にテストの構成・実行方法・fixture説明と整備の現在地を維持する常設node。個別試験・レビューの完了でDONE・履歴化しない。文書中の古い状態は現行Registry・品質要求・対象taskの詳細正本と照合し、記載だけで現行事実としない。具体的な作業は現在の依頼・受渡しと各文書の権限に従い、本行だけでは発注・再開・他担当による編集を認めない | `Tests/TESTING.md` / `Tests/CLAUDE.md` / `Tests/RedBlackTreeFixture/Fixtures.md` |
| `OPS-044` | `ACTIVE` | 現在委任された調整担当（Registry更新はCodex） | [EXECUTION] Task Registry運用の恒久管理 | 現在の目標・task状態・依存・採番・文書権限・履歴への経路を維持する常設node。個別の登録・受入・圧縮の完了でDONE・履歴化しない。維持文書と関連資料の範囲はProgressV2/README.mdを参照する。状態変更前に最新指示と正本を確認し、具体的な更新・圧縮は現在の委任と操作規則に従う。常時実行中・読み手への任命・上位規則の変更許可を意味しない | `Maintanance/ProgressV2/PROGRESS_OVERVIEW_V2.md` / `Maintanance/ProgressV2/TASK_REGISTRY_V2.md` / `Maintanance/ProgressV2/TASK_RULES_V2.md` / `Maintanance/ProgressV2/TASK_REGISTRY_ARCHIVE.md` / `Maintanance/ProgressV2/TASK_HISTORY_INDEX_MAINTENANCE.md` / `Maintanance/ProgressV2/README.md` |
| `OPS-045` | `ACTIVE` | Claude（姫） / Astra（受入） | [DISCOVERY] 圧縮後のタスク健全性検査 | ユーザーが圧縮後の検査を委任。既存の作業中scopeを終了・返却してから、task ID・状態・依存・採番・恒久文書の紐付け・履歴への経路と未完了条件の保存を読み取り検査し、根拠付きの指摘と未確認範囲を返す。登録・凍結解除・受入判断・本文修正はしない。返却とAstraの確認後、コミット判断をユーザーへ返す | `Maintanance/Current/MAINTENANCE_HEALTH_CHECK_2026-10-16.md` |
| `DOC-031` | `ACTIVE` | Claude（姫） / Astra（受入） | [DISCOVERY] 文書リンク健全性検査 | ユーザーが圧縮後の検査を委任。既存の作業中scopeを終了・返却してから、現行の管理文書とDOCUMENT.md掲載の外部文書を対象にローカル参照・見出し・移動先・外部URLの確認範囲を区別して検査する。今回移動した履歴と原文への経路も確認する。問題・根拠・修正候補・未確認を返すだけとし、資料の移動・本文修正・CIや重い生成処理は行わない。返却とAstraの確認後、コミット判断をユーザーへ返す | `Maintanance/Current/MAINTENANCE_HEALTH_CHECK_2026-10-16.md` |
| `DOC-032` | `USER_ONLY` | User | [DISCOVERY] ドキュメントValidation計画ドラフトのレビュー | ユーザーが計画の目的・対象・試行方法・判定境界をレビューし、指摘または修正不要の結果を残すことで完了する。計画の受け入れ・試行開始・既存taskの凍結解除とは分ける。AIは本体の着手・代行・委任・催促を行わず、明示依頼された補助だけを行う | `Maintanance/Current/DOCUMENTATION_VALIDATION_PLAN_DRAFT.md` |

### 公開とリリース

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `RELEASE-080` | `FROZEN` | Astra | [DISCOVERY] PRコメント起動CIのbaseline失敗調査と疎通確認 | 2026-10-16、実動run 38765855176で受付・Debug・Release・DocC成功、performanceのRun baseline benchmarks失敗、reportの候補試験失敗通知を確認。詳細log取得は403で原因未確定。ユーザー指示で後回しとし、明示再開後に対象SHA・baseline tag・失敗logを確認して原因と必要な修正範囲を特定する。修正と再実行は調査結果に基づき別途具体化し、性能基準の緩和や成功扱いで閉じない | `Maintanance/Current/Frozen/RELEASE-080_FROZEN_TASK.md`。既存資料：`Maintanance/Current/RELEASE_CANDIDATE_COMMENT_CI.md` |
| `RELEASE-072` | `USER_ONLY` | User | [EXECUTION] 人間向けリリース工程表の作成 | 一枚の工程表の原型は2026-10-12に作成され、その後、旧release資料の一本化、AGENTS.mdを残す区間、AI分担境界が実績に基づいて追記済み。残るのは、実際のreleaseで現在位置・次の操作・完了証拠・停止点を追えるかをユーザーが観測し、工程表として受け入れること。AIは完了を代行判断せず、依頼された整理・レビューだけを補助する | `Maintanance/User/RELEASE_PROCESS.md` |
| `RELEASE-075` | `USER_ONLY` | User | [EXECUTION] リリース工程の不足仕様充当 | 工程表には基本操作、CI確認、候補・最終tag、AI分担境界まで記載済み。定義した品質要求に対する判定基準、証拠取得方法、失敗時の停止・復旧手順など、V&Vに必要な未充当部分をユーザーが補う。AIは不足が解消したと代行判断せず、依頼された整理・レビューだけを補助する | `Maintanance/User/RELEASE_PROCESS.md` / `Maintanance/Current/QUALITY_REQUIREMENTS.md` |
| `RELEASE-076` | `USER_ONLY` | User | [EXECUTION] リリース工程のValidation & Verification | ユーザーが、充当後の工程仕様について、定義した品質要求を満たすことと、意図したリリース目的に適合することを確認する。AIは開始、代行、催促を行わず、依頼された場合だけ検証・レビューを補助する | `Maintanance/User/RELEASE_PROCESS.md` |
| `DOC-026` | `FROZEN` | User / Codex | [EXECUTION] Swift Package Indexへのpackage登録 | 0.9.x release後、`QUALITY-005`で対象版の登録可が判断され、ユーザーが明示的に再開してから、公式PackageListへ`https://github.com/narumij/swift-ac-collections.git`を追加する外部PRを準備・提出して、package page、互換性表示、module別DocC build結果を確認する | `Maintanance/Current/Frozen/DOC-026_FROZEN_TASK.md`。既存資料：`Maintanance/Current/DOCUMENTATION_CI_PLAN.md` / `Package.swift` |
| `DOC-027` | `FROZEN` | Codex | [EXECUTION] Swift Package Index公開導線のREADME・Pages反映 | `DOC-026`完了後、SPI package pageの`Do you maintain this package?`が提示するMarkdownを正として互換性badgeをREADMEへ追加し、確認できたmodule別DocC URLへの導線をREADMEまたはPagesへ接続する | `Maintanance/Current/Frozen/DOC-027_FROZEN_TASK.md`。既存資料：`Maintanance/Current/DOCUMENTATION_CI_PLAN.md` / `README.md` |
| `RELEASE-007` | `FROZEN` | User / Codex | [DECISION] 0.6.0の到達範囲とrelease検討開始 | `RELEASE-078`で、0.5.3後の公開面、現行品質区分、文書の完成状態、および旧開始条件の差を判断材料として揃えた後、ユーザーが0.6.0へ含める到達範囲とrelease工程へ進むかを一つに決定する。調査完了だけでは凍結を解除しない | `Maintanance/Current/Frozen/RELEASE-007_FROZEN_TASK.md`。既存資料：`Maintanance/Current/RELEASE_0_6_0.md` / `Maintanance/Current/QUALITY_REQUIREMENTS.md` / `Package.swift` |
| `RELEASE-078` | `PROPOSED` | Codex | [DISCOVERY] 0.6.0開始条件と現行提供区分の再照合 | `QUALITY-004`の品質棚卸し完了後、0.5.3後の公開面、利用者向け文書、`QUALITY_REQUIREMENTS.md`の1.0提供区分、および`RELEASE_0_6_0.md`の旧開始条件を照合し、0.6.0の対象候補、必要な文書入力、条件付き依存、残る一つずつのユーザー判断を整理する。release範囲、提供停止、名称、公開契約は決定せず、範囲・完了条件・担当・詳細正本・必須依存を確認して状態を更新するまで着手しない | `Maintanance/Current/RELEASE_0_6_0.md` / `Maintanance/Current/QUALITY_REQUIREMENTS.md` / `Package.swift` / `Maintanance/ProgressV2/TASK_REGISTRY_V2.md` |
| `RELEASE-079` | `FROZEN` | User / Codex | [DECISION] 0.7.0の到達範囲とrelease検討開始 | 0.6.0 releaseの完了と完了証拠の記録後、ユーザーの明示的な再開指示を受け、0.6.0後の公開面、残課題、品質・文書状態を判断材料として揃え、ユーザーが0.7.0へ含める到達範囲とrelease工程へ進むかを一つに決定する。0.6.0完了や前提整理だけでは自動再開しない | `Maintanance/Current/Frozen/RELEASE-079_FROZEN_TASK.md`。既存資料：`Maintanance/Current/RELEASE_0_7_0.md` / `Maintanance/User/RELEASE_PROCESS.md` / `Maintanance/Current/QUALITY_REQUIREMENTS.md` / `Package.swift` |

### RedBlackTreeと品質ゲート

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `RBT-036` | `DONE` | Astra | [DISCOVERY] 赤黒木Test as Spec：4型の初回横断 | 2026-10-15、Astraが4型を静的に概観し、Death Test判定・Map系value観測・共有寿命の対応・旧空testの説明の4課題候補、型別見取り図と未確認範囲を正本へ記録。実行検証・型別詳細レビュー・修正・発注なし。ユーザーのコミット許可により今回の記録を保存してDONE。契約・実装・testの修正は含めない | `Maintanance/Current/RED_BLACK_TREE_TEST_AS_SPEC_REVIEW.md` |
| `RBT-037` | `DONE` | Astra | [DISCOVERY] 赤黒木Test as Spec：RedBlackTreeSet | 2026-10-15、AstraがSetの静的仕様レビューを行い、hint付き参照置換・throwing predicate・集合演算CoWの元コピー観測・Death Test setup分離の4補完候補と受入条件を正本に記録。既存検証で足りる点と未検証範囲も明記。実行検証・修正なし。ユーザーが後続RBT-042発注とレビュー記録のコミットを許可したためDONE。契約・実装・testの修正は含めない | `Maintanance/Current/RED_BLACK_TREE_TEST_AS_SPEC_REVIEW.md` |
| `RBT-042` | `DONE` | Astra（修正・検証） | [EXECUTION] Set Test as SpecレビューS1〜S4反映・範囲erase修正 | ユーザー許可により4型の範囲eraseを修正。回帰8件の修正前SIGTRAP・修正後成功を確認。Debug 944＋133件、Release（debug情報なし）747＋120件成功。不正範囲停止を維持。2026-10-15ユーザーのコミット許可により修正・受入記録を保存しDONE。先行成果は7ed1cc6b | `Maintanance/Current/RED_BLACK_TREE_TEST_AS_SPEC_REVIEW.md` / `Maintanance/CLAUDE_TASK.md` |
| `RBT-038` | `DONE` | Astra | [DISCOVERY] 赤黒木Test as Spec：RedBlackTreeMultiSet | 仕様観点の静的レビューを完了し、補完候補M1〜M5を詳細正本へ記録。2026-10-15、ユーザーがコミットを許可したためレビュー記録を保存してDONE。test実行・契約/実装/test修正・補完作業の発注は未実施 | `Maintanance/Current/RED_BLACK_TREE_TEST_AS_SPEC_REVIEW.md` |
| `RBT-043` | `DONE` | Claude / Astra（受入） | [EXECUTION] MultiSet Test as SpecレビューM1〜M5反映 | 2026-10-16 Claude正式返却・占有返却後、AstraがM1〜M5の差分を照合し受入。独立実行でMultiSet Debug 178 XCTest＋30 Swift Testing、赤黒木全体Release 769＋120成功。ユーザーのcommit許可を受領。RBT-044の着手ゲートは通過済み | `Maintanance/Current/RED_BLACK_TREE_TEST_AS_SPEC_REVIEW.md` / `Maintanance/CLAUDE_TASK.md` |
| `RBT-039` | `DONE` | Astra | [DISCOVERY] 赤黒木Test as Spec：RedBlackTreeDictionary | 静的仕様レビューを完了し、D1〜D6の補完候補と既存検査による初回懸念の解消を詳細正本へ記録。2026-10-15ユーザーのコミット許可により記録を保存してDONE。test実行・契約/実装/test修正・発注は未実施 | `Maintanance/Current/RED_BLACK_TREE_TEST_AS_SPEC_REVIEW.md` |
| `RBT-040` | `DONE` | Astra | [DISCOVERY] 赤黒木Test as Spec：RedBlackTreeMultiMap | 静的仕様レビューを完了し、MM1〜MM4の補完候補と既存検査で足りる点を詳細正本へ記録。2026-10-15ユーザーのコミット許可により記録を保存してDONE。test実行・契約/実装/test修正・発注は未実施 | `Maintanance/Current/RED_BLACK_TREE_TEST_AS_SPEC_REVIEW.md` |
| `RBT-044` | `DONE` | Claude / Astra（受入） | [EXECUTION] Dictionary Test as SpecレビューD1〜D6反映 | 2026-10-16 Claude正式返却・占有返却後、AstraがD1〜D6を照合し受入。独立実行でDictionary Debug 179 XCTest＋29 Swift Testing、赤黒木全体Release 794＋120成功。ユーザーのcommit許可を受領。RBT-045着手ゲート通過済み | `Maintanance/Current/RED_BLACK_TREE_TEST_AS_SPEC_REVIEW.md` / `Maintanance/CLAUDE_TASK.md` |
| `RBT-045` | `ACTIVE` | Claude / Astra（受入） | [EXECUTION] MultiMap Test as SpecレビューMM1〜MM4反映 | 2026-10-16 RBT-044の正式返却・占有返却・独立検証・受入を確認し着手ゲート開放。一括発注済みのMM1〜MM4を現行差分へ照合してClaudeが開始可能。起動は未確認。反映とDebug/Release検証を受入条件とする。production変更は含めず不具合・未決仕様は返却する | `Maintanance/Current/RED_BLACK_TREE_TEST_AS_SPEC_REVIEW.md` / `Maintanance/CLAUDE_TASK.md` |
| `RBT-041` | `ACTIVE` | Astra | [DISCOVERY] 赤黒木Test as Spec：4型の最終横断 | ゲート待ち。RBT-042→RBT-043→RBT-044→RBT-045の型別補完・正式返却・独立検証・受入記録を確認してから着手。レビュー完了だけでは通過しない。4型の最終成果で型間不整合・共通実装の未検証・重複指摘・見落としを整理する。契約・実装・test修正は含めない | `Maintanance/Current/RED_BLACK_TREE_TEST_AS_SPEC_REVIEW.md` |
| `RBT-001` | `WAITING_EXTERNAL` | User / Codex | Index完了ゲート | 公開Index表現・完了範囲と`Comparable`採否を確定し、Index契約全体を閉じる。再開時は現行API・設計と外部要件を照合し、旧残task文書は経緯だけに使う | 現行確認：`Sources/RedBlackTreeCollections/Documentation/API-Matrix.md` / `Sources/RedBlackTreeCollections/Documentation/Design/Design-MemorySafety.md` / `Sources/RedBlackTreeCollections/Documentation/Quality-Profile.md`。履歴：`Maintanance/Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-011` | `WAITING_EXTERNAL` | User / Codex | Indexの`Comparable`採否 | `swift-collections`の要件が安定または正式化した後、現行API・設計と外部要件を照合して互換性を再評価し、採否を決定する。旧残task文書は経緯だけに使う | 現行確認：`Sources/RedBlackTreeCollections/Documentation/API-Matrix.md` / `Sources/RedBlackTreeCollections/Documentation/Design/Design-MemorySafety.md` / `Sources/RedBlackTreeCollections/Documentation/Quality-Profile.md`。履歴：`Maintanance/Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-014` | `WAITING_USER` | Codex | RedBlackTree文書workflowと4型outlineのAPI照合 | Permutation、OptionalElementBuffer、ElementBufferの利用者向け文書作業による方式習熟は完了済み。赤黒木の利用者向け文書作業へ進めるというユーザー指示を待ち、その後、workflowと4公開型のoutlineを現在のAPI、test、設計資料へ再照合し、本文作成へ渡せる状態を確認する。状態変更だけでは実作業を開始しない | `Sources/RedBlackTreeCollections/Documentation/Head/DOCUMENTATION_WORKFLOW.md` |
| `RBT-034` | `ACTIVE` | User / Codex | [EXECUTION] RedBlackTree 1.0品質アセスメント完成 | 2026-10-16、1.0ゲート復帰に伴い証拠準備の仕事として有効化。対象版と評価範囲を固定して、既存証拠・反証・未検証・残余リスクを接続する。0.6.0評価や型別test補完を最初からやり直さず、差分と不足を扱う。今回の棚卸しでは評価実行・合格判定を行わない。 | `Maintanance/RedBlackTreeModule/CurrentQualityAssessment.md` / `Sources/RedBlackTreeCollections/Documentation/Quality-Profile.md` |
| `RBT-035` | `FROZEN` | 姫 / 80ms | [DISCOVERY] RedBlackTreeチューニングの落ち穂拾い | ユーザーの明示的な再開指示後、過去の実装・benchmark・Git履歴・チューニング記録を現行コードと照合し、取りこぼした改善候補、未反映の知見、再検証が必要な仮説を発見する。性能変更は行わず、実測と判断が必要な後続taskへ分離する | `Maintanance/Current/Frozen/RBT-035_FROZEN_TASK.md`。既存資料：`Maintanance/RedBlackTreeModule/CurrentQualityAssessment.md` / `Sources/RedBlackTreeCollections/Documentation/Quality-Profile.md` / `Benchmarks/` |
| `RBT-026` | `FROZEN` | User / Codex | [DECISION] Mapped Values ViewのO(1)範囲契約再検討 | 利用者向け文書作業フェーズで、現行View APIと実装を確認し、View外だがbase treeでは有効なIndexを黙って読み書きし得る性質を踏まえ、O(1)と呼び出し側事前条件の契約を維持するか一つだけ再判断する。旧残task文書は論点の経緯だけに使う | `Maintanance/Current/Frozen/RBT-026_FROZEN_TASK.md`。既存資料：現行確認：`Sources/RedBlackTreeCollections/Documentation/API-Matrix-View.md` / `Sources/RedBlackTreeCollections/Documentation/API-Matrix.md`。履歴：`Maintanance/Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-004` | `FROZEN` | Codex | 残存するDebug限定Comparable群・Balanced群 | Debug限定`Result: Comparable`はユーザー介入で削除済み。`RBT-011`でIndexの`Comparable`採否が確定した後、残る`_LazyTieWrap`・`_NodePtrSealing`・`_LazyTie`の比較宣言とBalanced群について、ユーザーがこのtaskを明示的に再開 | `Maintanance/Current/Frozen/RBT-004_FROZEN_TASK.md`。既存資料：`Maintanance/Current/EXTERNAL_TYPE_EXTENSION_AUDIT.md` |
| `RBT-005` | `FROZEN` | Codex | Memoize群の公開終了／正式API化 | 外部consumer 2件の移行後、ユーザーがこのtaskを明示的に再開。consumer移行だけでは自動再開しない | `Maintanance/Current/Frozen/RBT-005_FROZEN_TASK.md`。既存資料：`Maintanance/Current/EXTERNAL_TYPE_EXTENSION_AUDIT.md` |
| `RBT-007` | `ACTIVE` | User / Codex | RedBlackTreeCollectionsのstrict memory safety全面適用 | 2026-10-15、ユーザー指示により有効化。現行readiness、対象範囲、必要な検証を照合して進める。状態変更だけでは実装操作を開始しない | `Maintanance/Current/StrictMemorySafetyReadiness.md` |
| `RBT-008` | `FROZEN` | User / Codex | `lazyDetach`等の並行初期化保証 | 性能と所有構造への影響から、ユーザー判断で最後の最後まで凍結。所有構造・生成コスト・アクセス性能を評価できる段階で、ユーザーの明示的な再開指示があった場合のみ再検討する。1.0必須ゲートや自動再開条件にはしない | `Maintanance/Current/Frozen/LAZY_INITIALIZATION_FREEZE_DECISION.md` |
| `RBT-009` | `ACTIVE` | User / Codex | [DECISION] runtime-check実装の再審査 | 2026-10-16のユーザー棚卸し指示で1.0前の判断ゲートとして有効化。Design-RuntimeChecksの再審査材料を揃え、現行実装を1.0へ受け入れるかユーザーが一つ判断する。検査の変更・弱化は今回行わず、現行防御を維持する。資料収集や測定は対象・範囲を具体化してから実施する。 | `Sources/RedBlackTreeCollections/Documentation/Design/Design-RuntimeChecks.md` |
| `QUALITY-001` | `ACTIVE` | User / Codex | [DECISION] 汎用基盤ライブラリとしての1.0採用品質ゲート | 2026-10-16のユーザー棚卸し指示でゲートを有効化。Index契約、runtime-check再審査、品質アセスメント、環境別証拠、SPI登録・公開導線を完了前に合流し、1.0として受け入れるかユーザーが判断する。Index待ちは並行可能な証拠整理を止めない。SPI後の人間レビュー方針は文書Validation計画を参照し、実施範囲は同計画のレビュー結果で具体化する。材料未充足のまま合格・公開しない。 | `Sources/RedBlackTreeCollections/Documentation/Quality-Profile.md` |
| `QUALITY-002` | `ACTIVE` | Codex | [EXECUTION] 1.0品質保証CIの構成・証拠化 | 2026-10-16、1.0ゲート復帰に伴い証拠準備の仕事として有効化。Ubuntu 24.04 LTS / x86_64の既存CI成功と保存済み証拠を先に照合し、不足する合意済み試験・環境情報・完全log・終了statusを補う。変動runnerの絶対性能判定は含めない。今回CI変更・起動は行わず、具体的な実行範囲は着手時に固定する。 | `Maintanance/Current/QUALITY_REQUIREMENTS.md` / `Tests/TESTING.md` / `.github/workflows/candidate.yml` |
| `QUALITY-003` | `ACTIVE` | Codex | [EXECUTION] Apple platforms 27提供境界のmanifest反映・build確認 | 2026-10-16、1.0ゲート復帰に伴い提供環境の整備として有効化。上位品質要求の暫定Apple platforms 27・64-bit方針に従い、manifest宣言とplatform別build・導入証拠の不足を照合して反映する。buildと実行品質を区別する。今回manifest変更・buildは実施せず、新しい提供範囲の判断は代行しない。 | `Maintanance/Current/QUALITY_REQUIREMENTS.md` / `Package.swift` |
| `QUALITY-004` | `PROPOSED` | Codex | [DISCOVERY] 品質評価棚卸し | 四対象の評価・証拠・現行提供区分と既存taskを照合し、残る品質課題、記録不整合、既存taskで扱う範囲と未充当部分を整理する。初期抽出結果は詳細正本へ保存済み。開始時に対象版・範囲・完了条件・必須依存を確認して有効化する。個別課題の解消、公開契約・提供方針の採用、凍結解除は含めない | `Maintanance/Current/QUALITY_ASSESSMENT_INVENTORY.md` |
| `QUALITY-005` | `ACTIVE` | User / Codex | [DECISION] SPI登録前の公開準備判定 | 2026-10-16のユーザー棚卸し指示でゲートを有効化。対象版の公開情報・品質証拠・不足を揃え、SPIへ登録してよいかをユーザーが一つ判断する。対象版未指定・判定未実施。登録可の判断、0.9.x release後という時期、DOC-026の明示実行指示を維持し、今回登録を開始しない。 | `Maintanance/Current/SPI_REGISTRATION_GATE.md` |

### Permutation

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `PERM-070` | `DONE` | User | [DECISION] PermutationModule公開API名の最終決定 | 2026-10-15、ユーザーが通常入口`nextPermutations()`、通常owner`NextPermutations`、borrowed入口`borrowedNextPermutations()`、borrowed owner`BorrowedNextPermutations`、通常ownerのgeneric parameter`Element`を暫定確定。`PERM-069`の三者採点・Round 4統合と`PERM-072`の最終提案への三者回答を確認後、module名`NextPermutationModule`と通常一時view名`NextPermutations.Permutation`維持を正式採用し、先の暫定確定を含む名称family全体を名称決定正本へ記録して完了した。`Element`は実sourceのcompile・DocC確認をrename実装時の受入条件とする。旧module名`PermutationModule`を残すかを含む移行方式は、名称の採否ではなく後続の移行プランで扱う。正式採用だけでrename、実装変更を開始しない | `Maintanance/Current/PERMUTATION_PUBLIC_API_NAMING_REVIEW.md` / `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_SCORE_ROUND1_REPORT.md` / `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_SCORE_ROUND2_REPORT.md` / `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_SCORE_ROUND3_REPORT.md` / `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_SCORE_ROUND4_REPORT.md` / `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_FINAL_PROPOSAL.md` / `Maintanance/Current/PUBLIC_API_NAMING_DECISIONS.md` |
| `PERM-062` | `PROPOSED` | User / Codex | [EXECUTION] Permutation利用理解Validation試行 | API設計非参加者に利用者向け本文と公開surfaceだけを渡し、類似API選択、即時消費、永続保存、失効説明、View copyと要素copyの区別を無誘導で観測する。参加者選定と外部接触はユーザーが行い、Codexは課題提示と記録整理を担う | `Maintanance/PermutationModule/GeneralSwiftValidationScenario.md` / `Maintanance/PermutationModule/UserDocumentationDraft.md` |
| `PERM-063` | `FROZEN` | Codex | [EXECUTION] Permutation benchmark task名移行互換の先行導入 | ユーザーの明示再開後、CI登録中の旧`Permutations.SubSequenceN` 2 taskを現行`NextPermutationsSequence.Permutation`名へ対応付けるbaseline入力・結果名正規化をworkflowへ先に追加し、remote performance CIのgreenを確認 | `Maintanance/Current/Frozen/PERM-063_FROZEN_TASK.md`。既存資料：`Maintanance/PermutationModule/BENCHMARK_TASK_NAME_MIGRATION.md` / `Maintanance/Current/PERFORMANCE_CI_CHANGE_GUIDE.md` / `.github/workflows/ci.yml` |
| `PERM-064` | `FROZEN` | Codex | [EXECUTION] Permutation benchmark表示名の現行型名への移行 | `PERM-063`のmerge後、benchmark sourceの旧内部型名を含む4 titleとCI library登録2件を`NextPermutationsSequence.Permutation`へ変更し、task列挙、base / current比較、remote performance CIのgreenを確認 | `Maintanance/Current/Frozen/PERM-064_FROZEN_TASK.md`。既存資料：`Maintanance/PermutationModule/BENCHMARK_TASK_NAME_MIGRATION.md` / `Benchmarks/Sources/Benchmarks/PermutationBenchmarks.swift` / `Benchmarks/Libraries/CI.json` |
| `PERM-065` | `DONE` | Codex | [EXECUTION] runtime-check版Permutationコメントドック回復 | 2026-10-15のユーザー指示により登録・実施。`9ff515c9`で喪失した公開APIコメントを過去差分から回収し、現行runtime-check契約へ照合して、後続順列、所有buffer、手動反復、一時Viewの失効・保存方法、index境界、複雑度を復元した。borrowed Span固有の寿命説明は持ち込んでいない。source診断0件、Xcode build成功、現行`NextPermutations` 44 test成功、`PermutationModule` DocCを`--warnings-as-errors`で生成成功 | `Maintanance/DOCUMENT.md` / `Maintanance/PermutationModule/UserDocumentationDraft.md` / `Maintanance/PermutationModule/RuntimeCheckedPermutationTestPlan.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` / `Sources/PermutationModule/NextPermutations.swift` |
| `PERM-043` | `FROZEN` | User | [DECISION] C++標準に匹敵すると判定する性能比の上限 | 2026-10-11、ユーザー指示により比較水準の判断を保留。明示的な再開指示後、28要素中7要素を選ぶ最大ケースでSwiftの全体処理時間を`std::next_permutation`の何倍以内なら「匹敵」と受け入れるか一つだけ決定する | `Maintanance/Current/Frozen/PERM-043_FROZEN_TASK.md`。既存資料：`Maintanance/PermutationModule/CurrentQualityAssessment.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` |
| `PERM-044` | `FROZEN` | Codex | [EXECUTION] Permutation外部性能アセスメントの実測・判定 | 2026-10-11、比較水準の判断とともにユーザー指示で保留。`PERM-043`の明示的な再開・完了後、macOS上で専用scriptを実行し、環境情報、生JSON、PNG chartを保存して判定する | `Maintanance/Current/Frozen/PERM-044_FROZEN_TASK.md`。既存資料：`Maintanance/PermutationModule/CurrentQualityAssessment.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` |
| `PERM-051` | `FROZEN` | Claude | [EXECUTION] borrowed Span版PermutationのTest as Specification | runtime仕様test 25件を受け入れ、2026-10-13にも対象25件成功を再確認。一時clientによるcompile-pass／compile-fail結果は返却記録にあるが、repository内の再実行可能なfixtureではないため、ユーザーの明示的な再開まで残作業を凍結 | `Maintanance/Current/Frozen/PERM-051_FROZEN_TASK.md`。既存資料：`Maintanance/PermutationModule/BorrowedPermutationTestPlan.md` / `Sources/PermutationModule/BorrowedNextPermutations.swift` / `Tests/PermutationTests/BorrowedNextPermutations/` |
| `PERM-060` | `FROZEN` | User | [DECISION] NextPermutationsのSequence表面を製品候補として検討するか | 2026-10-13、`Array(sequence)`が要素配列ではなく失効可能なViewを収集する事実を新しい判断材料として、採用・不採用を決めず延期。ユーザーの明示的な再開後、View Sequenceの有効な操作範囲と誤用防止、所有配列を返す別Sequence、copy・性能costを追試してから一つ選ぶ | `Maintanance/Current/Frozen/PERM-060_FROZEN_TASK.md`。既存資料：`Maintanance/PermutationModule/NextPermutationsSequenceExperiment.md` |

### OptionalElementBuffer

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `OPT-064` | `FROZEN` | User / Codex | [EXECUTION] OptionalElementBuffer一般利用理解Validation試行 | 一般Swift向け提供方式の採用判断と、検証する公開surface・説明がそろうまで凍結を保つ。明示再開後、設計非参加者が本文と公開surfaceから用途、座標順、nil遷移、所有・並行利用境界を理解できるか観測する。再開に向けて不足する判断・実行は別taskへ分ける | `Maintanance/Current/Frozen/OPT-064_FROZEN_TASK.md`。既存資料：`Maintanance/OptionalElementBufferModule/GeneralSwiftValidationScenario.md` / `Maintanance/OptionalElementBufferModule/UserDocumentationDraft.md` / `Maintanance/OptionalElementBufferModule/OptionalElementBufferAudit.md` |
| `OPT-065` | `PROPOSED` | User / Codex | [EXECUTION] OptionalElementBuffer競技利用Validation試行 | ユーザーが問題・judge・提出可否を決めた後、未計算状態を持つ固定shapeの多次元メモ化問題で提出source、正否、実行時間、メモリを記録する。C++級性能や一般Swift利用へ一般化しない | `Maintanance/OptionalElementBufferModule/GeneralSwiftValidationScenario.md` / `Tests/OptionalElementBufferModuleTests/EDPC-J.swift` / `Tests/OptionalElementBufferModuleTests/EDPC-L.swift` |

### ElementBuffer

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |

### 移行史

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `HIST-001` | `ACTIVE` | V3オーサー | [DISCOVERY] AtCoder 2025移行史 | 移行史へ接続すべき新しい事実・証拠が見つかったときに受け入れる常設nodeとして`ACTIVE`を保つ。個別調査や追記が常時実行中であることを意味せず、必要な範囲が具体化したときだけ本紙または証拠別紙へ反映する | `Maintanance/RefactoringFromAtCoder2025/README.md` / `Maintanance/RefactoringFromAtCoder2025/EVIDENCE.md` |

## Task precedence

内部task間の必須AND前提を記録する。`SEQUENCE`は前提成果がそろうまで後続を開始・継続しない。`PARALLEL_JOIN`は独立部分を並行でき、後続の完了までに合流する。いずれも状態・委任・再開条件を上書きしない。

| 後続task | 前提task | Flow | 制約 |
| --- | --- | --- | --- |
| `RBT-044` | `RBT-043` | `SEQUENCE` | MultiSet補完の正式返却・独立検証・受入完了が着手ゲート（一括発注済み） |
| `RBT-044` | `RBT-039` | `SEQUENCE` | DictionaryレビューD1〜D6を入力とする |
| `RBT-045` | `RBT-044` | `SEQUENCE` | Dictionary補完の正式返却・独立検証・受入完了が着手ゲート（一括発注済み） |
| `RBT-045` | `RBT-040` | `SEQUENCE` | MultiMapレビューMM1〜MM4を入力とする |
| `RBT-041` | `RBT-045` | `SEQUENCE` | 型別補完の直列ゲートを通り、4型の受入記録がそろってから最終横断 |
| `RBT-043` | `RBT-038` | `SEQUENCE` | MultiSetレビューM1〜M5を入力とする |
| `RBT-043` | `RBT-042` | `SEQUENCE` | Set補完の受入と4型の範囲erase修正後に進む |
| `RBT-042` | `RBT-037` | `SEQUENCE` | SetレビューS1〜S4の固定した指摘と受入条件を入力にする |
| `RBT-037` | `RBT-036` | `SEQUENCE` | ユーザー指定の順序。先行段階のレビュー結果を記録してから次段階へ進む |
| `RBT-038` | `RBT-037` | `SEQUENCE` | ユーザー指定の順序。先行段階のレビュー結果を記録してから次段階へ進む |
| `RBT-039` | `RBT-038` | `SEQUENCE` | ユーザー指定の順序。先行段階のレビュー結果を記録してから次段階へ進む |
| `RBT-040` | `RBT-039` | `SEQUENCE` | ユーザー指定の順序。先行段階のレビュー結果を記録してから次段階へ進む |
| `RBT-041` | `RBT-040` | `SEQUENCE` | 個別レビューを入力とする。これだけでは着手せず、RBT-045までの補完受入ゲートも必要 |
| `RBT-001` | `RBT-011` | `PARALLEL_JOIN` | Comparable採否の外部依存は判断task側に残し、親ゲートの完了前に合流する |
| `RBT-004` | `RBT-011` | `SEQUENCE` | IndexのComparable採否を確定してから、残存するDebug限定比較宣言とBalanced群の処遇を扱う |
| `QUALITY-001` | `RBT-001` | `PARALLEL_JOIN` | 品質調査は並行できるが、1.0品質判定を確定する前にIndex契約完了と合流する |
| `QUALITY-001` | `RBT-009` | `PARALLEL_JOIN` | 他の1.0品質作業は並行できるが、最終判定前にruntime-check実装の採否と合流する |
| `QUALITY-001` | `RBT-034` | `PARALLEL_JOIN` | 1.0採用品質を判定する前に、再現可能な証拠を備えた品質アセスメントの完成と合流する |
| `QUALITY-001` | `QUALITY-002` | `PARALLEL_JOIN` | 1.0採用品質を判定する前に、Linux代表環境の品質保証CIと再現可能な実行証拠を合流する |
| `QUALITY-001` | `QUALITY-003` | `PARALLEL_JOIN` | 1.0採用品質を判定する前に、Apple platforms 27のmanifest境界とplatform別build証拠を合流する |
| `QUALITY-001` | `DOC-026` | `PARALLEL_JOIN` | 1.0採用品質を判定する前に、0.9.xをSwift Package Indexへ登録し、外部build・互換性表示・module別DocC生成の結果を合流する |
| `QUALITY-001` | `DOC-027` | `PARALLEL_JOIN` | 1.0採用品質を判定する前に、SPIが生成した互換性badgeと確認済みmodule別API referenceへの公開導線を合流する |
| `RBT-026` | `RBT-014` | `SEQUENCE` | 現行APIとの照合を判断材料として揃えてからMapped Values契約を再判断する |
| `PERM-044` | `PERM-043` | `SEQUENCE` | C++標準に匹敵すると判定する性能比上限を確定してから、保存したmacOS測定証拠へ適用する |
| `PERM-064` | `PERM-063` | `SEQUENCE` | 旧名baselineと新名HEADを対応付けるworkflowを先にmergeしてgreenを確認してから、benchmark titleを変更する |
| `PERM-062` | `PERM-065` | `SEQUENCE` | 公開surfaceだけを渡す利用理解Validationの前に、喪失した公開APIコメントを現行契約に合わせて回復する |
| `RELEASE-078` | `QUALITY-004` | `SEQUENCE` | 現行提供区分に照らした品質課題と証拠の棚卸しを揃えてから、0.6.0開始条件と対象候補を再照合する |
| `RELEASE-007` | `RELEASE-078` | `SEQUENCE` | 0.5.3後の公開面、現行提供区分、文書状態、および旧0.6.0開始条件の差を判断材料として揃えてから、0.6.0の範囲とrelease開始を決定する |
| `RELEASE-076` | `RELEASE-075` | `SEQUENCE` | 不足仕様を充当して検証可能な工程にしてから、Validation & Verificationを行う |
| `DOC-026` | `QUALITY-005` | `SEQUENCE` | 対象版についてSPI登録可の判断を得てから登録する。ゲートtaskのDONEだけでは登録可を意味せず、0.9.x release後・明示再開の条件も維持する |
| `DOC-027` | `DOC-026` | `SEQUENCE` | SPI登録と実在するpackage page・module別DocC URLを確認してから、badgeと公開導線をrepositoryへ反映する |

「AまたはB」の条件はANDの辺二本に変えず、task行に残す。`RBT-004`は現行行と辺に従い`RBT-011`を待つ。旧資料のOR例を再開根拠にしない。また、1.0品質ゲートの「再開」と「完了」は異なる。`QUALITY-002`・`QUALITY-003`をゲート完了まで待たせる逆向きの辺は作らない。

## 目標の記録

現在選択中の目標は[入口](PROGRESS_OVERVIEW_V2.md#現在の目標)に置く。以下の記録だけでは、後続目標の選択や凍結解除は成立しない。中間ゴールはtaskではなく、独自のID・状態を付けない。

### 直近達成した目標

- 2026-10-09、三対象のTest as Specification整理を受け、0.5.1の製品上の到達範囲とrelease検討開始を決定した（`RELEASE-005`）。同日、全公開対象のコメントドック・レビュー用ドラフトを0.5.2の製品上の到達範囲として採用し、release検討開始を決定した（`RELEASE-006`）。判断の記録は`Maintanance/Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-11.md`、各版の詳細は`Maintanance/Archived/Canonical/RELEASE_0_5_1.md`と`Maintanance/Archived/Canonical/RELEASE_0_5_2.md`にある。
- 2026-10-13、Permutation、OptionalElementBuffer（当時OptionalArray）、ElementBuffer（当時BareArray）の利用者向け内部本文ドラフトを、ユーザーがドラフトとして受け入れた（`PERM-058`・`OPT-059`・`BARE-040`）。公開可能な初版の完成は含まない。受入記録は`Maintanance/Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-13.md`にある。
- Array系benchmark・OptionalElementBuffer opt-in・ElementBuffer系名称移行を完了した。詳細は`Maintanance/Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-14.md`に保存されている。

以上は当時の対象と範囲についての達成記録である。その後の変更を含む現在の仕様・文書・品質まで検証済みとは扱わない。

### 後続の中間ゴール

提供範囲と必要な品質は`Maintanance/Current/QUALITY_REQUIREMENTS.md`の「1.0に向けた開発対象」に従う。

- 三対象の文書ドラフト作業を通じて作業方式を習熟した後、RedBlackTreeに見えていない残作業を確認し、
  Codexのユーザードキュメント作業フェーズへ渡せる状態にする。
- 全公開対象の利用者向けドキュメントが公開可能な初版として揃った時点で、0.6.0の製品上の到達範囲を
  決め、release工程へ進むか判断できる状態にする。
- ユーザードキュメント作業後、OptionalElementBufferのISO/IEC 25010観点の品質評価を再評価し、
  留保付きの実験的提供に必要な品質境界に照らして、不足をtaskへ分離できる状態にする。
- 再評価後、OptionalElementBufferを留保付きの実験的提供として1.0へ含めるための品質境界が
  成立しているか判断可能な状態にする。
- RedBlackTreeのユーザードキュメント作業後、汎用基盤ライブラリの1.0として採用できるか判断可能な
  状態にする。この段階でruntime-check実装を再審査し、その結論とIndex契約を1.0品質ゲートへ渡す。
- SPI登録前ゲートで公開準備を判定し、登録可となった対象版について、0.9.x release後、Swift Package Indexへpackageを登録し、module別DocCの生成と互換性表示を確認する。登録後に
  SPIが提供するbadgeとmodule別API referenceへの導線をREADMEまたはPagesへ接続し、結果を1.0品質gateへ渡す。
- 保留中の運用playbookをユーザー指示で再開した後、このrepositoryで得たtask運用知見を、
  別projectでもCodexが同程度の管理品質を再現できる移植可能な形へ整理する。

- ElementBufferについて、Swift 6.2の1.0競技供用とSwift 6.4の1.0一般供用を区別し、それぞれの用途・アクセス方式に対応する品質を判断可能な状態にする。

### 目標の訂正履歴

ElementBuffer（旧BareArray）の1.0に向けた目標は、2026-10-15の整理で「1.0提供対象外」を理由に取り下げていた。同日のユーザー訂正に基づき、上記の供用区分別の目標として訂正した。現在選択中の目標への昇格や、個別taskの再開・完了を意味しない。元の目標文は[修正前原文](../Archived/PROGRESS_V2_GOALS_BEFORE_2026-10-15.md)に保存している。

### 遠い将来の目標候補

- 1.0 releaseより後の段階で、対象judgeが必要なSwift toolchainを採用した場合、Permutationを含む
  現行版の競技環境向け構成、性能、単一file経路、および実提出を検証し、judge搭載を目指す。
  現在の中間ゴールとの依存関係、着手順、および具体的な受入条件はまだ定めない。

### 対象を復元する必要がある判断の記録

基準版には、以下を「今回の作業taskへ含めない」とする記録があるが、「今回」の対象taskは明記されていない。決定済みとも、すべての新しい依頼への一律の禁止とも扱わない。関係する仕事で必要になったときに、対象範囲と既決事項を詳細正本・現在の依頼で照合し、残る判断をユーザーへ返す。

- 利用者向け文書の形（Markdown、DocC、documentation commentのみのいずれにするか）
- 性能の数値を利用者向け文書へ掲載するか
- 1.0ゲート（`QUALITY-001`）との境界
- RedBlackTreeのデバッグ用memberを`#if DEBUG`へ揃えるか

## 過去の記録への入口

完了・除外・判断の経緯を調べる必要が生じたときだけ、対象IDや変更を絞って参照する。

- `Maintanance/Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-07.md`
- `Maintanance/Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-09.md`
- `Maintanance/Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-11.md`
- `Maintanance/Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-12.md`
- `Maintanance/Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-13.md`
- `Maintanance/Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-14.md`
- [V2切替後に失効・退役した旧進捗全文（2026-10-15移動）](../Archived/PROGRESS_OVERVIEW_RETIRED_2026-10-15.md)：旧task表・制度・説明を含む履歴。現在の状態や着手条件には使わない。
- [判断座標関連資料](../Archived/JudgmentCoordinates/README.md)、[ElementBuffer系名称移行記録](../Archived/ArrayModuleMigration/README.md)、[task棚卸しsnapshot](../Archived/TaskInventory/README.md)、[協働ポスター](../Archived/Posters/README.md)：2026-10-15に直下から移動した完了記録・参考資料。
- [目標の記録の修正前原文（2026-10-15）](../Archived/PROGRESS_V2_GOALS_BEFORE_2026-10-15.md)：0.5.1・0.5.2、三対象の本文ドラフト、旧提供方針による目標を含む。現在の目標や実行指示としては扱わない。
- [V2切替後の完了・除外20件（2026-10-15圧縮）](../Archived/TASK_REGISTRY_ARCHIVED_2026-10-15.md)：`OPS-001`・`OPS-028`・`OPS-030`・`OPS-031`〜`OPS-040`・`RELEASE-020`・`RBT-010`・`RBT-032`・`OPT-045`・`OPT-072`・`BARE-042`・`BARE-043`の原文。現在の仕事へ復活させない。
- [完了13件と完了済み後続の依存辺4本（2026-10-15・第2回圧縮）](../Archived/TASK_REGISTRY_ARCHIVED_2026-10-15_2.md)：`BARE-044`・`BARE-045`・`BARE-046`・`DOC-028`・`DOC-029`・`OPS-041`・`OPS-042`・`OPT-073`・`PERM-066`・`PERM-067`・`PERM-068`・`PERM-069`・`PERM-072`の原文。未完了taskの前提である`PERM-065`・`PERM-070`は現行表に残す。
- [文書整備手引きの整理前全文（2026-10-16）](../Archived/MAINTENANCE_BEFORE_2026-10-16.md)：MAINTENANCE.mdの旧dashboard・handoffと整備規則の原文。現行の状態・着手条件は本Registryと詳細正本で確認する。
- [完了8件（2026-10-16圧縮）](../Archived/TASK_REGISTRY_ARCHIVED_2026-10-16.md)：`RBT-033`・`PERM-073`〜`PERM-078`・`OPT-074`の原文。[Permutation移行文書](../Archived/PermutationMigration_2026-10-16/README.md)は対応表から辿る。赤黒木の未完了ゲートに必要な完了行と辺、恒久taskは現行に残す。

- [凍結26件と関連重複の棚卸し結果](../Current/FROZEN_TASK_RECONCILIATION_2026-10-16.md)：2026-10-16、6件を有効化。`DOC-010`・`BARE-035`・`PERM-046`と関連する`PERM-071`を除外し、[原文と除外理由](../Archived/FROZEN_TASKS_BEFORE_RECONCILIATION_2026-10-16.md)へ保存。残る17件は凍結を維持。
