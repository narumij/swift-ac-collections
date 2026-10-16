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
| `DOC-030` | `ACTIVE` | Codex | [EXECUTION] 文書整備の恒久管理 | 文書の役割・整備方法・参照関係を維持する常設node。リンク切れの点検・修正と移動・改名時の参照元確認を含み、対象と方法は詳細正本の「リンクと参照先の保守」に従う。個別の文書作業の完了だけではDONE・履歴化しない。常時実行中や読み手への編集委任を意味せず、具体的な作業は現在の依頼と権限に従う。維持文書は配置維持の指定に従い残す | `Maintanance/DOCUMENT.md`（配置維持; 区分=既存指定; 付与日=不明; 記録日=2026-10-16; 記録者=Astra; 理由=旧配置維持例外から継承） / `Maintanance/Current/DOCUMENTATION_WORKFLOW.md` / `Maintanance/UserDocuments/SnippetSurvey/README.md` |
| `OPS-043` | `ACTIVE` | Codex / Claude / Astra（各自の記録） | [EXECUTION] 協働のふりかえりと知見の蓄積 | 具体的な出来事と、その時点の観察・受け止め方を残す常設node。一回の回答や個別作業の完了だけではDONE・履歴化しない。人物評の固定や担当適性の判定とは区別する。評価の追記・任意観察は各文書の記入条件と現在の依頼に従い、他者の声を代筆・改変しない。常時実行中・定期記入義務・読み手への担当任命を意味せず、過去の感想を現行の規則・権限へ昇格させない | `Maintanance/USER_MANAGEMENT_INTERVIEW_CODEX.md`（配置維持; 区分=既存指定; 付与日=不明; 記録日=2026-10-16; 記録者=Astra; 理由=旧配置維持例外から継承） / `Maintanance/USER_MANAGEMENT_INTERVIEW_CLAUDE.md`（配置維持; 区分=既存指定; 付与日=不明; 記録日=2026-10-16; 記録者=Astra; 理由=旧配置維持例外から継承） / `Maintanance/USER_MANAGEMENT_INTERVIEW_ASTRA.md`（配置維持; 区分=既存指定; 付与日=不明; 記録日=2026-10-16; 記録者=Astra; 理由=旧配置維持例外から継承） / `Maintanance/CODEX_OBSERVATIONS.md`（配置維持; 区分=既存指定; 付与日=不明; 記録日=2026-10-16; 記録者=Astra; 理由=旧配置維持例外から継承） / `Maintanance/CLAUDE_OBSERVATIONS.md`（配置維持; 区分=既存指定; 付与日=不明; 記録日=2026-10-16; 記録者=Astra; 理由=旧配置維持例外から継承） / `Maintanance/ASTRA_OBSERVATIONS.md`（配置維持; 区分=既存指定; 付与日=不明; 記録日=2026-10-16; 記録者=Astra; 理由=旧配置維持例外から継承） |
| `TEST-005` | `ACTIVE` | Claude（姫） | [EXECUTION] テスト整備の恒久管理 | Test as Specificationを中心にテストの構成・実行方法・fixture説明と整備の現在地を維持する常設node。個別試験・レビューの完了でDONE・履歴化しない。文書中の古い状態は現行Registry・品質要求・対象taskの詳細正本と照合し、記載だけで現行事実としない。具体的な作業は現在の依頼・受渡しと各文書の権限に従い、本行だけでは発注・再開・他担当による編集を認めない | `Maintanance/Testing/TESTING.md`（配置維持; 区分=既存指定; 付与日=不明; 記録日=2026-10-16; 記録者=Astra; 理由=旧配置維持例外から継承） / `Tests/CLAUDE.md`（配置維持; 区分=既存指定; 付与日=不明; 記録日=2026-10-16; 記録者=Astra; 理由=旧配置維持例外から継承） / `Maintanance/Testing/Fixtures.md`（配置維持; 区分=既存指定; 付与日=不明; 記録日=2026-10-16; 記録者=Astra; 理由=旧配置維持例外から継承） / `Maintanance/Testing/JudgmentCoordinates/README.md` / `Maintanance/Testing/TEST_WORKFLOW.md` |
| `OPS-044` | `ACTIVE` | 現在委任された調整担当（Registry更新はCodex） | [EXECUTION] Task Registry運用の恒久管理 | 現在の目標・task状態・依存・採番・文書権限・履歴への経路を維持する常設node。個別の登録・受入・圧縮の完了でDONE・履歴化しない。維持文書と関連資料の範囲はProgressV2/README.mdを参照する。状態変更前に最新指示と正本を確認し、具体的な更新・圧縮は現在の委任と操作規則に従う。常時実行中・読み手への任命・上位規則の変更許可を意味しない | `Maintanance/ProgressV2/PROGRESS_OVERVIEW_V2.md`（配置維持; 区分=既存指定; 付与日=不明; 記録日=2026-10-16; 記録者=Astra; 理由=旧配置維持例外から継承） / `Maintanance/ProgressV2/TASK_REGISTRY_V2.md`（配置維持; 区分=既存指定; 付与日=不明; 記録日=2026-10-16; 記録者=Astra; 理由=旧配置維持例外から継承） / `Maintanance/ProgressV2/TASK_RULES_V2.md`（配置維持; 区分=既存指定; 付与日=不明; 記録日=2026-10-16; 記録者=Astra; 理由=旧配置維持例外から継承） / `Maintanance/ProgressV2/TASK_REGISTRY_ARCHIVE.md`（配置維持; 区分=既存指定; 付与日=不明; 記録日=2026-10-16; 記録者=Astra; 理由=旧配置維持例外から継承） / `Maintanance/ProgressV2/TASK_HISTORY_INDEX_MAINTENANCE.md`（配置維持; 区分=既存指定; 付与日=不明; 記録日=2026-10-16; 記録者=Astra; 理由=旧配置維持例外から継承） / `Maintanance/ProgressV2/README.md`（配置維持; 区分=既存指定; 付与日=不明; 記録日=2026-10-16; 記録者=Astra; 理由=旧配置維持例外から継承） / `Maintanance/ProgressV2/COMMONS.md` |
| `OPS-047` | `ACTIVE` | 現在委任された調整担当 | [EXECUTION] マイルストーン管理の恒久維持 | 到達点・成立条件・関連task・ユーザー判断と証拠への参照を維持する常設node。人間用資料とAI用キャッシュの対を維持し、後続の操作・判断変更で前提が変わったとき必要な範囲を更新する。既存ゲートへの適用は作業対象になった時に行う。個々の到達や更新でDONE・履歴化しない。作業状態はRegistry、到達条件と判断は版別・SPI正本へ置く。定期実行・読み手への任命・公開や判断の代行を意味しない | `Maintanance/MILESTONES.md`（配置維持; 区分=既存指定; 付与日=不明; 記録日=2026-10-16; 記録者=Astra; 理由=旧配置維持例外から継承） / `Maintanance/Cache/AI_GATE.md` |
| `OPS-046` | `ACTIVE` | 現在委任された調整担当（初回記録：Astra） | [EXECUTION] 調整ノウハウの継続蓄積 | 調整実務の発見・失敗・訂正を、根拠と適用範囲付きで蓄積する常設node。個別追記の完了ではDONE・履歴化しない。人物評のふりかえり、Registryの制度維持とは区別する。定期記入・毎回通読・読み手への任命を意味しない。知見を規則やユーザー決定へ自動昇格させない | `Maintanance/ProgressV2/COORDINATION_KNOW_HOW.md`（配置維持; 区分=既存指定; 付与日=不明; 記録日=2026-10-16; 記録者=Astra; 理由=旧配置維持例外から継承） |
| `OPS-048` | `ACTIVE` | Astra | [EXECUTION] Task Registry閲覧・編集アプリの継続整備 | ユーザー指定の独立した恒久node。中間データ化、グラフ・条件の閲覧編集、差分確認とRegistryへの反映を段階的に整備する。個別工程完了でDONE・履歴化しない。初期試作OPS-051は2026-10-16ユーザー受入で完了。今後の表示・操作・照合反映の改善と残課題は本taskで継続管理する。具体的実行は現在の依頼に従い、0.6.0・0.7.0の必須ゲートにはしない。個別実施はその都度の依頼範囲に従う | `Maintanance/Current/TASK_REGISTRY_APP.md` |
| `OPS-051` | `DONE` | Astra | [EXECUTION] Safari向けRegistry閲覧編集の初期試作 | 恒久OPS-048配下。2026-10-16ユーザーが初期試作を受入・完了とし、残る改善は親OPS-048で扱うよう指示。HTML閲覧編集とJSON返却・正本反映の往復を確認済み。全環境・全UIの網羅検証を意味しない。受入範囲と継続事項は詳細正本を参照 | `Maintanance/Current/TASK_REGISTRY_APP_PROTOTYPE.md` |


| `OPS-053` | `DONE` | Astra（実施・受入） / Claude（独立確認済み） | [DISCOVERY] 文書保存管理の二重化解消の検討 | 2026-10-16 R2受入、一覧抽出・理由・日付・記録日の指摘対応と検証を完了。ユーザー指示で完了。恒久決定時の記法確認は詳細正本へ留保。OPS-054の前提充足 | `Maintanance/Current/PLACEMENT_EXCEPTION_SIMPLIFICATION_REVIEW.md` |
| `OPS-054` | `DONE` | Astra | [DISCOVERY] Claude起動系文書の見直し検討 | 2026-10-16ユーザー受入・終了指示。起動経路の参照・矛盾修正、テスト入口の簡素化、承認済み日本語原稿の英語反映を完了。共通の一時作業物管理はOPS-055で整備済み | `Maintanance/Current/CLAUDE_STARTUP_DOCUMENT_REVIEW.md` |

| `OPS-055` | `DONE` | Astra（作成・受入） / Claude（レビュー済み） | [EXECUTION] 共通作業規則と一時作業物の掃除手順を整備 | 2026-10-16ユーザー指示。COMMONS.mdを作成し、一時作業物の記録・引継ぎ・日終わりの掃除を共通化。作成・必要時の参照接続・リンク確認済み。Claude返却・Astra受入、指摘4点の対応済み。2026-10-16ユーザーが終了・commitを承認。実際の掃除や自動定期実行の開始は含まない | `Maintanance/ProgressV2/COMMONS.md` |
| `OPS-056` | `ACTIVE` | Claude（姫：試作・評価） / Astra（受入） | [DISCOVERY] Astraの判断追跡負荷を軽くする限定試作 | 2026-10-16ユーザー依頼。OPS-048配下。CP-20261016-006を正式化し、スニペット固定の判断一件でゲート・task別の一覧と原文追跡を試す。判断待ちと作業待ちを分離し、部分変更・適用範囲を保持。方式の採用や現行UI・制度の変更は含めない。依頼票作成済み、返却待ち | `Maintanance/Current/ASTRA_DECISION_TRACE_SUPPORT.md` |
| `OPS-057` | `ACTIVE` | Claude（姫：実装・検証） / Astra（受入） | [EXECUTION] Registry Studio同期の一コマンド化 | 2026-10-16ユーザー依頼。CP-20261016-007のsync.py試作を仕上げ、生成・差分確認・既存検証・利用手順を接続する。マイルストーン自動導出と判断運用の変更は対象外。OPS-048配下、正式依頼済み・返却待ち | `Maintanance/Current/REGISTRY_STUDIO_SYNC.md` |

| `DOC-033` | `ACTIVE` | Astra | [DISCOVERY] 赤黒木4型アウトラインと現行契約の照合 | 2026-10-16ユーザー指示で構築。登録のみ・未実行。既存4型アウトラインを実装・API Matrix・Test as Specへ照合し、技術訂正と不足を整理する。既決の構成は維持し、構成・必須事項の変更判断が必要なら一つずつユーザーへ返す。本文へ渡せる確定範囲と保留を記録する。 今回は既存スニペットの構成・掲載数を固定し、追加・削除しない。拡充と文書全体の再検討は0.8.0へ送る。 | `Maintanance/UserDocuments/RedBlackTreeCollections/Head/Outlines/OUTLINE_ADJUSTMENT_PLAN.md` |
| `DOC-034` | `ACTIVE` | Astra | [EXECUTION] 赤黒木4型の本文完成と派生成果の同期 | 2026-10-16ユーザー指示で構築。登録のみ・未実行。DOC-033の照合済み・構成確定範囲から既存本文を補完し、4型の日本語・英語本文・公開コメントを同期。必須例を検証し、最終横断レビューの指摘を閉じる。未確定の公開契約を創作しない。 今回は既存スニペットの構成・掲載数を固定し、追加・削除しない。拡充と文書全体の再検討は0.8.0へ送る。 | `Maintanance/Current/RED_BLACK_TREE_DOCUMENT_COMPLETION.md` |
| `DOC-035` | `ACTIVE` | Astra | [EXECUTION] 0.6.0全公開対象の文書初版確認 | 2026-10-16ユーザー指示で構築。登録のみ・未実行。DOC-037のユーザー受入可を確認し、RELEASE-078で整理した対象・不足とDOC-034の成果を用い、4モジュールの現行公開文書・導線・例・DocC診断を照合。必要な文書修正と再確認、未解決の公開阻害事項を記録する。生成成功だけで初版完成としない。 今回は既存スニペットの構成・掲載数を固定し、追加・削除しない。拡充と文書全体の再検討は0.8.0へ送る。 | `Maintanance/Current/PUBLIC_DOCUMENTATION_INITIAL_EDITION_CHECK.md` |
| `DOC-036` | `USER_ONLY` | User | [DECISION] 文書Validation計画の受入判断 | 2026-10-16ユーザー指示で構築。登録のみ・未実行。0.7.0前に既存Validation計画の対象・方法・判定境界をレビューし、計画を受け入れるか判断する。旧DOC-032のマイルストーンを実行可能な判断記録へ接続。人間レビュー実施や参加者接触とは別。AIは依頼された準備・整理だけを補助する。 | `Maintanance/Current/DOCUMENTATION_MILESTONES.md` |

| `DOC-037` | `WAITING_USER` | User | [DECISION] 赤黒木本文の受入判断 | 2026-10-16ユーザー指定。DOC-034の本文・同期・検証結果を受け、赤黒木本文を受け入れるか判断する。受入可の明示記録後にDOC-035へ進む。差戻し・保留なら進めない。DOC-034は未完了のため判断材料待ち | `Maintanance/Current/RED_BLACK_TREE_DOCUMENT_COMPLETION.md` |

| `DOC-038` | `PROPOSED` | Astra | [EXECUTION] 0.8.0ドキュメントのコードスニペット追加 | 2026-10-16ユーザー指定で0.8.0へ配置。追加箇所・対象版・検証条件を確定して有効化後に実施する。過去アンケートは現行契約へ照合して利用。今回の0.6.0では既存スニペットを増減しない。未実行 | `Maintanance/Current/RELEASE_0_8_0.md` |
| `DOC-039` | `PROPOSED` | Astra | [DISCOVERY] 0.8.0ドキュメントの再検討 | 2026-10-16ユーザー指定で0.8.0へ配置。構成・説明・導線の見直し範囲と入力を確定して有効化後、改善案と判断点を整理する。方針変更や未決の反映を先取りしない。未実行 | `Maintanance/Current/RELEASE_0_8_0.md` |

### 公開とリリース

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `RELEASE-072` | `USER_ONLY` | User | [EXECUTION] 人間向けリリース工程表の作成 | 0.7.0の工程準備へ配置（2026-10-16ユーザー決定）。0.6.0の前提にはしない。一枚の工程表の原型は2026-10-12に作成され、その後、旧release資料の一本化、AGENTS.mdを残す区間、AI分担境界が実績に基づいて追記済み。残るのは、実際のreleaseで現在位置・次の操作・完了証拠・停止点を追えるかをユーザーが観測し、工程表として受け入れること。AIは完了を代行判断せず、依頼された整理・レビューだけを補助する | `Maintanance/User/RELEASE_PROCESS.md` / `Maintanance/Current/RELEASE_0_7_0.md` |
| `RELEASE-075` | `USER_ONLY` | User | [EXECUTION] リリース工程の不足仕様充当 | 0.7.0の工程準備へ配置（2026-10-16ユーザー決定）。0.6.0の前提にはしない。工程表には基本操作、CI確認、候補・最終tag、AI分担境界まで記載済み。定義した品質要求に対する判定基準、証拠取得方法、失敗時の停止・復旧手順など、V&Vに必要な未充当部分をユーザーが補う。AIは不足が解消したと代行判断せず、依頼された整理・レビューだけを補助する | `Maintanance/User/RELEASE_PROCESS.md` / `Maintanance/Quality/QUALITY_REQUIREMENTS.md` / `Maintanance/Current/RELEASE_0_7_0.md` |
| `RELEASE-076` | `USER_ONLY` | User | [EXECUTION] リリース工程のValidation & Verification | 0.7.0の工程準備へ配置（2026-10-16ユーザー決定）。0.6.0の前提にはしない。ユーザーが、充当後の工程仕様について、定義した品質要求を満たすことと、意図したリリース目的に適合することを確認する。AIは開始、代行、催促を行わず、依頼された場合だけ検証・レビューを補助する | `Maintanance/User/RELEASE_PROCESS.md` / `Maintanance/Current/RELEASE_0_7_0.md` |
| `DOC-026` | `ACTIVE` | User / Codex | [EXECUTION] Swift Package Indexへのpackage登録 | 2026-10-16、マイルストーン整理で有効化。0.7.0 release後、QUALITY-005の対象版登録可判断と登録実行の明示委任を確認して登録PRを準備・提出し、package page・互換性表示・module別DocC結果を確認する。重ねて凍結解除を求めない。登録は未実施 | `Maintanance/Current/SPI_PUBLICATION_MILESTONE.md` / `Maintanance/Current/DOCUMENTATION_CI_PLAN.md` |
| `DOC-027` | `ACTIVE` | Codex | [EXECUTION] Swift Package Index公開導線のREADME・Pages反映 | 2026-10-16、マイルストーン整理で有効化。DOC-026完了後、SPIが提示する互換性badgeと確認済みmodule別DocC URLをREADME・Pagesへ反映する。依存条件で待ち、重ねて凍結解除を求めない。反映は未実施 | `Maintanance/Current/SPI_PUBLICATION_MILESTONE.md` / `Maintanance/Current/DOCUMENTATION_CI_PLAN.md` |
| `RELEASE-078` | `PROPOSED` | Codex | [DISCOVERY] 0.6.0開始条件と現行提供区分の再照合 | 旧棚卸しtaskの完了を待たず、着手時点の品質課題・証拠と0.5.3後の公開面、利用者向け文書、`QUALITY_REQUIREMENTS.md`の1.0提供区分、および`RELEASE_0_6_0.md`の旧開始条件を照合し、文書初版を重点とする0.6.0の対象候補、必要な文書入力、条件付き依存、残る一つずつのユーザー判断を整理する。工程整備・自動化とSPI公開は0.7.0へ置き、0.6.0には対象版の品質確認を残す。release範囲、提供停止、名称、公開契約は決定せず、範囲・完了条件・担当・詳細正本・必須依存を確認して状態を更新するまで着手しない | `Maintanance/Current/RELEASE_0_6_0.md` / `Maintanance/Quality/QUALITY_REQUIREMENTS.md` / `Package.swift` / `Maintanance/ProgressV2/TASK_REGISTRY_V2.md` |

### RedBlackTreeと品質ゲート

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `RBT-001` | `WAITING_EXTERNAL` | User / Codex | Index完了ゲート | 公開Index表現・完了範囲と`Comparable`採否を確定し、Index契約全体を閉じる。再開時は現行API・設計と外部要件を照合し、旧残task文書は経緯だけに使う | 現行確認：`Sources/RedBlackTreeCollections/Documentation/API-Matrix.md` / `Sources/RedBlackTreeCollections/Documentation/Design/Design-MemorySafety.md` / `Maintanance/Quality/Profiles/RedBlackTreeCollections.md`。履歴：`Maintanance/Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-011` | `WAITING_EXTERNAL` | User / Codex | Indexの`Comparable`採否 | `swift-collections`の要件が安定または正式化した後、現行API・設計と外部要件を照合して互換性を再評価し、採否を決定する。旧残task文書は経緯だけに使う | 現行確認：`Sources/RedBlackTreeCollections/Documentation/API-Matrix.md` / `Sources/RedBlackTreeCollections/Documentation/Design/Design-MemorySafety.md` / `Maintanance/Quality/Profiles/RedBlackTreeCollections.md`。履歴：`Maintanance/Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-034` | `ACTIVE` | User / Codex | [EXECUTION] RedBlackTree 1.0品質アセスメント完成 | 2026-10-16、1.0ゲート復帰に伴い証拠準備の仕事として有効化。対象版と評価範囲を固定して、既存証拠・反証・未検証・残余リスクを接続する。0.6.0評価や型別test補完を最初からやり直さず、差分と不足を扱う。今回の棚卸しでは評価実行・合格判定を行わない。 | 保存済み参照資料：`Maintanance/Quality/0.6.0-1/RedBlackTreeModule/CurrentQualityAssessment.md` / `Maintanance/Quality/Profiles/RedBlackTreeCollections.md` |
| `RBT-026` | `ACTIVE` | User（判断） / Astra・Claude（姫）（議論・材料整理） | [DECISION] Mapped Values ViewのO(1)範囲契約再検討 | 2026-10-16、ユーザーが姫との議論を経て決める課題として復帰を指示。関連する現行APIの照合結果（旧RBT-014から保持、未確認）を入力に、範囲外Indexの動作・呼び出し側前提・性能と互換性の影響を議論し、現行契約を維持するかユーザーが判断して理由と範囲を記録する。正式発注・議論は未実施。実装変更は後続へ分ける | `Maintanance/Current/MAPPED_VALUES_VIEW_CONTRACT_DECISION.md` |
| `RBT-007` | `ACTIVE` | User / Codex | RedBlackTreeCollectionsのstrict memory safety全面適用 | 2026-10-15、ユーザー指示により有効化。現行readiness、対象範囲、必要な検証を照合して進める。状態変更だけでは実装操作を開始しない | `Maintanance/Current/StrictMemorySafetyReadiness.md` |
| `RBT-008` | `FROZEN` | User / Codex | `lazyDetach`等の並行初期化保証 | 性能と所有構造への影響から、ユーザー判断で最後の最後まで凍結。所有構造・生成コスト・アクセス性能を評価できる段階で、ユーザーの明示的な再開指示があった場合のみ再検討する。1.0必須ゲートや自動再開条件にはしない | `Maintanance/Current/Frozen/LAZY_INITIALIZATION_FREEZE_DECISION.md` |
| `RBT-009` | `ACTIVE` | User / Codex | [DECISION] runtime-check実装の再審査 | 2026-10-16のユーザー棚卸し指示で1.0前の判断ゲートとして有効化。Design-RuntimeChecksの再審査材料を揃え、現行実装を1.0へ受け入れるかユーザーが一つ判断する。検査の変更・弱化は今回行わず、現行防御を維持する。資料収集や測定は対象・範囲を具体化してから実施する。 | `Sources/RedBlackTreeCollections/Documentation/Design/Design-RuntimeChecks.md` |
| `QUALITY-001` | `ACTIVE` | User / Codex | [DECISION] 汎用基盤ライブラリとしての1.0採用品質ゲート | 2026-10-16のユーザー棚卸し指示でゲートを有効化。Index契約、runtime-check再審査、品質アセスメント、環境別証拠を完了前に合流し、1.0として受け入れるかユーザーが判断する。Index待ちは並行可能な証拠整理を止めない。SPI登録・公開導線はSPI公開→人間レビューの経路で扱い、DOC-026・027からの直接依存は置かない（2026-10-16ユーザー編集）。SPI後の人間レビュー方針は文書Validation計画を参照し、実施範囲は同計画のレビュー結果で具体化する。材料未充足のまま合格・公開しない。 | `Maintanance/Quality/Profiles/RedBlackTreeCollections.md` |
| `QUALITY-002` | `ACTIVE` | Codex | [EXECUTION] 1.0品質保証CIの構成・証拠化 | 2026-10-16、1.0ゲート復帰に伴い証拠準備の仕事として有効化。Ubuntu 24.04 LTS / x86_64の既存CI成功と保存済み証拠を先に照合し、不足する合意済み試験・環境情報・完全log・終了statusを補う。変動runnerの絶対性能判定は含めない。今回CI変更・起動は行わず、具体的な実行範囲は着手時に固定する。 | `Maintanance/Quality/QUALITY_REQUIREMENTS.md` / `Maintanance/Testing/TESTING.md` / `.github/workflows/candidate.yml` |
| `QUALITY-003` | `ACTIVE` | Codex | [EXECUTION] Apple platforms 27提供境界のmanifest反映・build確認 | 2026-10-16、1.0ゲート復帰に伴い提供環境の整備として有効化。上位品質要求の暫定Apple platforms 27・64-bit方針に従い、manifest宣言とplatform別build・導入証拠の不足を照合して反映する。buildと実行品質を区別する。今回manifest変更・buildは実施せず、新しい提供範囲の判断は代行しない。 | `Maintanance/Quality/QUALITY_REQUIREMENTS.md` / `Package.swift` |
| `QUALITY-005` | `ACTIVE` | User / Codex | [DECISION] SPI登録前の公開準備判定 | 2026-10-16のユーザー棚卸し指示でゲートを有効化。対象版の公開情報・品質証拠・不足を揃え、SPIへ登録してよいかをユーザーが一つ判断する。対象は0.7.0の公開版（tag・commitはrelease後に特定）、判定未実施。0.7.0 release完了を本判定の前提とする（2026-10-16ユーザーのグラフ編集）。登録可の判断、0.7.0 release後という時期、DOC-026の明示実行指示を維持し、今回登録を開始しない。 | `Maintanance/Current/SPI_REGISTRATION_GATE.md` |

### Permutation

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `PERM-062` | `PROPOSED` | User / Codex | [EXECUTION] Permutation利用理解Validation試行 | API設計非参加者に利用者向け本文と公開surfaceだけを渡し、類似API選択、即時消費、永続保存、失効説明、View copyと要素copyの区別を無誘導で観測する。参加者選定と外部接触はユーザーが行い、Codexは課題提示と記録整理を担う | 保存済み参照資料：`Maintanance/Quality/0.6.0-1/PermutationModule/GeneralSwiftValidationScenario.md` / `Maintanance/UserDocuments/NextPermutationModule/UserDocumentationDraft.md` |
| `PERM-064` | `ACTIVE` | Codex | [EXECUTION] Permutation benchmark表示名の現行型名への移行 | 2026-10-16、ユーザーの明示指示で復帰。移行先表示名を現行名称と照合し、本task内の先行互換工程のmain merge・remote performance CIのgreen後に4 titleとCI登録2件を変更する。task列挙・base/current比較・remote performance CIのgreenで受入。PERM-063は除外して工程を統合。実装は未着手 | `Maintanance/Current/PERMUTATION_BENCHMARK_TITLE_MIGRATION.md` |
| `PERM-060` | `ACTIVE` | Codex（調査・整理） | [DISCOVERY] Sequenceによる失効View収集バグの再現と修正範囲整理 | 2026-10-16、ユーザーがバグとして課題復帰を指示。実験adapterのArray収集時の失効を現行条件で再現し、公開面への影響と必要な修正範囲を整理する。公開契約・所有方式・性能許容の新しい判断は分離してユーザーへ返す。未解決の修正・判断の引継ぎ先を残して調査結果を受け入れるまで。登録時点で再実行・修正は未実施 | `Maintanance/Current/PERMUTATION_SEQUENCE_INVALID_VIEW_ISSUE.md` |
| `PERM-079` | `WAITING_USER` | User（再開判断） / Codex（判断後の調査・手順案） | [DECISION] 0.6.0リリース完了後のAtCoder 2025互換調査再開判断 | 2026-10-16ユーザー指定。0.6.0のリリース完了を確認した後、prepare/compatible/2の統合手順再構築調査を再開するかユーザーが判断する。リリース完了だけでは調査を自動開始しない。再開可の場合に調査範囲・完了条件・担当を更新して着手する。mergeの許可・時期・送り先は別判断。0.6.0リリースの前提にはしない | `Maintanance/Current/AtCoder2025CompatibilityPlan.md` / `Maintanance/Current/RELEASE_0_6_0.md` |

### OptionalElementBuffer

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `OPT-065` | `PROPOSED` | User / Codex | [EXECUTION] OptionalElementBuffer競技利用Validation試行 | ユーザーが問題・judge・提出可否を決めた後、未計算状態を持つ固定shapeの多次元メモ化問題で提出source、正否、実行時間、メモリを記録する。C++級性能や一般Swift利用へ一般化しない | 保存済み参照資料：`Maintanance/Quality/0.6.0-1/OptionalElementBufferModule/GeneralSwiftValidationScenario.md` / `Tests/OptionalElementBufferModuleTests/EDPC-J.swift` / `Tests/OptionalElementBufferModuleTests/EDPC-L.swift` |

### ElementBuffer

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |

### 移行史

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `HIST-001` | `ACTIVE` | V3オーサー | [DISCOVERY] AtCoder 2025移行史 | 移行史へ接続すべき新しい事実・証拠が見つかったときに受け入れる常設nodeとして`ACTIVE`を保つ。個別調査や追記が常時実行中であることを意味せず、必要な範囲が具体化したときだけ本紙または証拠別紙へ反映する | `Maintanance/History/RefactoringFromAtCoder2025/README.md` / `Maintanance/History/RefactoringFromAtCoder2025/EVIDENCE.md` |

| `HIST-003` | `ACTIVE` | Claude（作成） / Astra（受入・接続） | [DISCOVERY] テスト再建史の記録・維持（常設） | 常設node。個別assignmentではない。2026-10-16ユーザー指示で恒久化。初回の作成・Astra受入・入口接続は完了済みで、その完了記録は維持する | `Maintanance/Current/CLAUDE_QUEUE_RECONCILIATION_2026-10-16.md` / `Maintanance/History/TestRebuild2026/README.md` / `Maintanance/History/TestRebuild2026/EVIDENCE.md` |

## Task precedence

内部task間の必須AND前提を記録する。`SEQUENCE`は前提成果がそろうまで後続を開始・継続しない。`PARALLEL_JOIN`は独立部分を並行でき、後続の完了までに合流する。いずれも状態・委任・再開条件を上書きしない。

| 後続task | 前提task | Flow | 制約 |
| --- | --- | --- | --- |
| `RBT-001` | `RBT-011` | `PARALLEL_JOIN` | Comparable採否の外部依存は判断task側に残し、親ゲートの完了前に合流する |
| `QUALITY-001` | `RBT-001` | `PARALLEL_JOIN` | 品質調査は並行できるが、1.0品質判定を確定する前にIndex契約完了と合流する |
| `QUALITY-001` | `RBT-009` | `PARALLEL_JOIN` | 他の1.0品質作業は並行できるが、最終判定前にruntime-check実装の採否と合流する |
| `QUALITY-001` | `RBT-034` | `PARALLEL_JOIN` | 1.0採用品質を判定する前に、再現可能な証拠を備えた品質アセスメントの完成と合流する |
| `QUALITY-001` | `QUALITY-002` | `PARALLEL_JOIN` | 1.0採用品質を判定する前に、Linux代表環境の品質保証CIと再現可能な実行証拠を合流する |
| `QUALITY-001` | `QUALITY-003` | `PARALLEL_JOIN` | 1.0採用品質を判定する前に、Apple platforms 27のmanifest境界とplatform別build証拠を合流する |
| `RELEASE-076` | `RELEASE-075` | `SEQUENCE` | 不足仕様を充当して検証可能な工程にしてから、Validation & Verificationを行う |
| `DOC-026` | `QUALITY-005` | `SEQUENCE` | 対象版についてSPI登録可の判断を得てから登録する。ゲートtaskのDONEだけでは登録可を意味せず、0.7.0 release後・登録実行の明示委任も確認する |
| `DOC-027` | `DOC-026` | `SEQUENCE` | SPI登録と実在するpackage page・module別DocC URLを確認してから、badgeと公開導線をrepositoryへ反映する |

| `OPS-054` | `OPS-053` | `SEQUENCE` | 配置維持例外表の検討結果を受け入れてからClaude起動系文書を検討する。前段の提案実施完了は条件にしない |
| `DOC-034` | `DOC-033` | `SEQUENCE` | 現行契約と構成の照合済み範囲を受け取って本文を仕上げる。構成判断未決箇所は確定しない |
| `DOC-037` | `DOC-034` | `SEQUENCE` | 本文・同期・検証結果を揃えてユーザーへ受入判断を渡す |
| `DOC-035` | `DOC-037` | `SEQUENCE` | ユーザーの受入可が明示された後に進む。判断taskのDONEだけで受入可とみなさない |
| `DOC-035` | `RELEASE-078` | `SEQUENCE` | 対象版の提供区分と必要文書入力の整理を受ける。PROPOSEDの有効化やリリース開始を自動認定しない |

### 受入済みの前提成果

以下は上記の未完了依存と区別する。前提の受入済みは後続の自動開始を意味しない。

- `PERM-062`の受入済み入力：`PERM-065`。公開surfaceだけを渡す利用理解Validationの前に、喪失した公開APIコメントを現行契約に合わせて回復する。証拠は[完了行と元の依存辺](../Archived/TASK_REGISTRY_COMPLETED_AFTER_RECONCILIATION_2026-10-16.md)および該当行の詳細正本を参照。

「AまたはB」の条件はANDの辺二本に変えず、task行に残す。整理済みの`RBT-004`の旧依存・旧資料のOR例を再開根拠にしない。また、1.0品質ゲートの「再開」と「完了」は異なる。`QUALITY-002`・`QUALITY-003`をゲート完了まで待たせる逆向きの辺は作らない。

## 目標の記録

2026-10-16のユーザー決定：0.6.0はドキュメント初版整備、0.7.0はリリース工程準備・公開運用整備とrelease後のSPI公開、0.8.0はコードスニペット追加と文書の再検討を重点とする。品質は各0.x.0で差分と残課題に応じて改善する。版別の配置は`Maintanance/MILESTONES.md`を参照し、1.0の全ゲートを各版へ一括で前倒ししない。

現在選択中の目標は[入口](PROGRESS_OVERVIEW_V2.md#現在の目標)に置く。以下の記録だけでは、後続目標の選択や凍結解除は成立しない。中間ゴールはtaskではなく、独自のID・状態を付けない。

### 直近達成した目標

- 2026-10-09、三対象のTest as Specification整理を受け、0.5.1の製品上の到達範囲とrelease検討開始を決定した（`RELEASE-005`）。同日、全公開対象のコメントドック・レビュー用ドラフトを0.5.2の製品上の到達範囲として採用し、release検討開始を決定した（`RELEASE-006`）。判断の記録は`Maintanance/Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-11.md`、各版の詳細は`Maintanance/Archived/Canonical/RELEASE_0_5_1.md`と`Maintanance/Archived/Canonical/RELEASE_0_5_2.md`にある。
- 2026-10-13、Permutation、OptionalElementBuffer（当時OptionalArray）、ElementBuffer（当時BareArray）の利用者向け内部本文ドラフトを、ユーザーがドラフトとして受け入れた（`PERM-058`・`OPT-059`・`BARE-040`）。公開可能な初版の完成は含まない。受入記録は`Maintanance/Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-13.md`にある。
- Array系benchmark・OptionalElementBuffer opt-in・ElementBuffer系名称移行を完了した。詳細は`Maintanance/Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-14.md`に保存されている。

以上は当時の対象と範囲についての達成記録である。その後の変更を含む現在の仕様・文書・品質まで検証済みとは扱わない。

### 後続の中間ゴール

提供範囲と必要な品質は`Maintanance/Quality/QUALITY_REQUIREMENTS.md`の「1.0に向けた開発対象」に従う。

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
- SPI登録前ゲートで公開準備を判定し、登録可となった対象版について、0.7.0 release後、Swift Package Indexへpackageを登録し、module別DocCの生成と互換性表示を確認する。登録後に
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

- [完了6件とアプリ親子関係の圧縮前記録](../Archived/TASK_REGISTRY_COMPLETED_VIEWER_2026-10-16.md)：`OPS-049`・`OPS-050`・`OPS-052`・`TEST-006`・`TEST-007`・`RBT-005`。調査・助言・受入の原文と証拠への経路を保存。圧縮時点ではOPS-051の受入待ちを維持（その後の受入は現行行を参照）。

- [完了5件・除外1件と旧前提説明（品質資料整理後の圧縮）](../Archived/TASK_REGISTRY_ARCHIVED_2026-10-16_QUALITY_ROUND.md)：`OPS-045`・`DOC-031`・`RBT-041`・`RBT-046`・`HIST-002`・`QUALITY-004`。元の状態・受入範囲・証拠への参照を保存。

- [Permutation公開API削減の実施記録](../Archived/PermutationImplementation_2026-10-16/ImplementationPlan.md)：2026-10-16、ユーザー指示で旧ImplementationPlanを全文保存。旧実装の判断・検証の経緯として参照する。

- [借用版試験の計画・返却](../Quality/0.6.0-1/PermutationModule/BorrowedPermutationTestPlan.md)（PERM-047・051）と[旧COW版文書引継ぎ監査](../Quality/0.6.0-1/PermutationModule/DocumentationHandoffAudit.md)（PERM-020〜023）：2026-10-16、独立作業の整理・引継ぎ完了により全文を保存。品質側の残課題を完了扱いにはしない。

- [完了10件と関連依存辺の原文](../Archived/TASK_REGISTRY_COMPLETED_AFTER_RECONCILIATION_2026-10-16.md)：RBT-036〜040・042〜044、PERM-065・070。受入済み入力は上記に接続。

- [RBT-005の整理前記録](../Archived/RBT-005_BEFORE_USER_DECISION_2026-10-16.md)：Memoize群の扱いをユーザー専任の判断へ変更。

- [RBT-004の整理前記録](../Archived/RBT-004_BEFORE_USER_DECISION_2026-10-16.md)：ユーザー専任の判断へ変更。既存依存は維持。

- [PERM-063除外・工程統合記録](../Archived/PERM-063_EXCLUDED_2026-10-16.md)：独立taskをEXCLUDEDとし、必要な互換工程をPERM-064へ統合。

- [マイルストーン整理前の記録](../Archived/MILESTONE_REORGANIZATION_2026-10-16.md)：RELEASE-007・079はEXCLUDED、DOC-026・027は依存待ちのACTIVEへ整理。

- [RELEASE-080解決記録と旧正本](../Archived/RELEASE-080_RESOLVED_2026-10-16.md)：2026-10-16、ユーザーが `/test release` の件は解決済みと確認し、追跡不要の指示によりEXCLUDED。過去runを成功へ読み替えない。

- [RBT-035整理前の原文](../Archived/RBT-035_BEFORE_USER_DECISION_2026-10-16.md)：2026-10-16、再探索の実施をユーザーが決めるUSER_ONLY課題へ整理。

- [RBT-026復帰前の記録](../Archived/RBT-026_BEFORE_REACTIVATION_2026-10-16.md)：姫との議論を経てユーザーが決める判断課題へ復帰。

- [OPT-064の品質移行・除外記録](../Archived/OPT-064_EXCLUDED_2026-10-16.md)：2026-10-16、利用理解の観点を品質側の文書Validation計画へ引き継ぎ、独立taskを除外。

- [PERM-064復帰前の原文](../Archived/PERM-064_BEFORE_REACTIVATION_2026-10-16.md)：表示名移行をユーザー指示でACTIVEへ復帰。先行依存は維持。

- [PERM-060の復帰前記録](../Archived/PERM-060_BEFORE_REACTIVATION_2026-10-16.md)：2026-10-16、ユーザー指示で失効View収集バグの調査へ復帰。

- [PERM-043・044の除外と旧正本](../Archived/PERM-043_044_EXCLUDED_2026-10-16.md)：2026-10-16、ユーザー指示で次回品質評価へ集約。実測成果物は保持し、旧判断・実測taskとその依存辺を除外。

- [PERM-051の除外と凍結正本の保存](../Archived/PERM-051_EXCLUDED_2026-10-16.md)：2026-10-16、ユーザー判断により品質側へ移行済みの重複taskとして除外。旧taskの再開は不要。

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

- [凍結26件と関連重複の棚卸し結果](../Archived/FROZEN_TASK_RECONCILIATION_2026-10-16.md)：2026-10-16、6件を有効化。`DOC-010`・`BARE-035`・`PERM-046`と関連する`PERM-071`を除外し、[原文と除外理由](../Archived/FROZEN_TASKS_BEFORE_RECONCILIATION_2026-10-16.md)へ保存。残る17件は凍結を維持。

- [RBT-004の分割・除外記録](../Archived/RBT-004_EXCLUDED_2026-10-16.md)：比較演算類の経緯とBalanced系の保存意図を分離し、一括処遇taskを整理。

- [RBT-005の依存調査への訂正記録](../Archived/RBT-005_BEFORE_DEPENDENCY_DISCOVERY_2026-10-16.md)：ユーザー判断待ちを訂正し、二つのGitHubリポジトリの依存調査としてACTIVEへ変更。

- [RBT-035のマイルストーン移行記録](../Archived/RBT-035_BEFORE_MILESTONE_2026-10-16.md)：実施判断待ちを除外し、マイルストーン管理へ接続。

- [DOC-032・RBT-014のマイルストーン移行前記録](../Archived/DOC-032_RBT-014_BEFORE_MILESTONES_2026-10-16.md)：ユーザー待ちtaskを整理。RBT-026に必要なAPI照合は入力条件として保持。

- [再分類後の圧縮記録](../Archived/TASK_REGISTRY_AFTER_USER_RECLASSIFICATION_2026-10-16.md)：RBT-004・014・035、DOC-032をEXCLUDEDとして履歴化。RBT-045は受入済み・commit許可を受けDONE。RBT-041の必須入力RBT-045は充足済みで、原行・依存辺と検証証拠を本記録から辿れる。

## 恒久タスクの親子関係

親子関係は所属を表し、依存・着手許可を追加しない。履歴化したサブタスクを復活させない。

| 親 | サブタスク |
| --- | --- |
| `OPS-048` | `OPS-051` |

| `OPS-048` | `OPS-056` |

| `OPS-048` | `OPS-057` |
