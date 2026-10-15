# Task Registryから圧縮した完了・除外記録（2026-10-15）

> 移動日：2026-10-15  
> 元文書：`Maintanance/ProgressV2/TASK_REGISTRY_V2.md`  
> 対象：V2切替後に現行Registryへ残っていた`DONE`・`EXCLUDED` 20件

以下は移動時点の履歴であり、現在の状態、権限、着手条件、依存関係として使わない。本文中のファイルパスはリポジトリ直下を基準とする。

## 協働と運用

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `OPS-001` | `EXCLUDED` | Codex | [DISCOVERY] Codex task運用playbookの移植可能化 | 2026-10-15、ユーザー判断により残作業から除外。現行V5 playbookと旧版・旧templateは現在の効力区分を変えず、必要になった場合も本taskを自動復活させない | 起点（現行playbook）：`Maintanance/OrientationV5/CODEX_TASK_OPERATION_PLAYBOOK_V5.md`。経緯資料：`Maintanance/Archived/Orientation/CODEX_TASK_OPERATION_PLAYBOOK_V2.md` / `Maintanance/Archived/Orientation/CODEX_TASK_OPERATION_PLAYBOOK_V3.md` / `Maintanance/Archived/Orientation/PROGRESS_OVERVIEW_TEMPLATE.md` |
| `OPS-028` | `EXCLUDED` | Codex | [EXECUTION] 作業Codex用ブートストラップの作成 | 2026-10-15、ユーザー判断により候補の再構成を含む残作業から除外。作成済みの未採用初稿とレビュー記録は採用せず、履歴として保持する | `Maintanance/Archived/Worker/WORKER_CODEX_BOOTSTRAP_TASK.md` / `Maintanance/Archived/Worker/WORKER_CODEX_BOOTSTRAP.md` / `Maintanance/Archived/Worker/WORKER_CODEX_TASK_CONTRACT_TEMPLATE.md` |
| `OPS-030` | `EXCLUDED` | User | [DECISION] 作業Codex用ブートストラップ候補のレビュー | 2026-10-15、ユーザー判断によりレビューを不要として残作業から除外。未採用初稿の採用や、別taskの完了を意味しない | `Maintanance/Archived/Worker/WORKER_CODEX_BOOTSTRAP_TASK.md` / `Maintanance/Archived/Worker/WORKER_CODEX_BOOTSTRAP.md` / `Maintanance/Archived/Worker/WORKER_CODEX_TASK_CONTRACT_TEMPLATE.md` |

## 公開とリリース

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `RELEASE-020` | `EXCLUDED` | Codex | [EXECUTION] 0.6.0でGitHub Pages更新元をrelease tagへ一本化 | 2026-10-15、Pages更新元を扱う時期が0.6.0 release工程からSwift Package Index登録時へ変わったため、旧境界のtaskを残作業から除外。SPI登録時の具体的な仕事への統合・採番・着手は行わない | `Maintanance/Current/RELEASE_0_6_0.md` / `Maintanance/Current/DOCUMENTATION_CI_PLAN.md` |

## RedBlackTreeと品質ゲート

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `RBT-010` | `EXCLUDED` | User / Codex | Index完了ゲートのうち公開Index表現と完了範囲 | 2026-10-15、ユーザー判断により`RBT-011`と同じ仕事として残作業から除外。外部条件の充足やIndex契約の完了を意味せず、残る判断は`RBT-011`と親ゲート`RBT-001`で扱う | 現行確認：`Sources/RedBlackTreeCollections/Documentation/API-Matrix.md` / `Sources/RedBlackTreeCollections/Documentation/Design/Design-MemorySafety.md` / `Sources/RedBlackTreeCollections/Documentation/Quality-Profile.md`。履歴：`Maintanance/Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-032` | `DONE` | Codex | [DISCOVERY] RedBlackTree 0.6.0現行品質アセスメント | 2026-10-15、commit `36f821a4`をmacOS 27.0.1 / arm64 / Apple Swift 6.4で再評価。Debug・Release・process-exit系2 suiteを除くASan本体・DocCは成功。ASan＋Death Testは子プロセスのruntime注入経路が成立せず、製品不具合と区別して未検証のまま残した。環境、依存、選択条件、完全log、終了statusを証拠packageへ保存し、0.6.0で主張できる範囲と未確定領域を分離して完了 | `Maintanance/RedBlackTreeModule/CurrentQualityAssessment.md` / `Maintanance/RedBlackTreeModule/Evidence/RBT-032-2026-10-15/README.md` |

## OptionalElementBuffer

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `OPT-045` | `EXCLUDED` | User | [DECISION] OptionalElementBuffer次元名体系の再判断 | 後発の横断命名判断へ吸収。2026-10-15、名称決定時に次元名も同時に決定済みだったことをユーザー確認。2D・3Dの`width`・`height`・`depth`と4Dの`size0`〜`size3`を両moduleで維持し、連鎖subscript・View削除後の座標accessとも整合するため、旧判断taskを独立に実行せずrelease前提にも残さない | `Maintanance/Current/PUBLIC_API_NAMING_DECISIONS.md` / `Maintanance/OptionalElementBufferModule/OptionalElementBufferAudit.md` / `Maintanance/Archived/ArrayModuleMigration/ArrayObjectAndAPINamingDraft.md` |
| `OPT-072` | `EXCLUDED` | User | [DISCOVERY] Swift 6.4以降向けOptionalElementBuffer一般提供方式 | 2026-10-15、AI独走で生じた調査taskであるため、ユーザー判断により残作業から除外。現在の競技用途向けopt-in提供を維持し、split storageと`Element?` storage・標準`MutableRef`の比較調査を、このtaskから再開・実行しない | `Maintanance/OptionalElementBufferModule/CurrentQualityAssessment.md` / `Sources/OptionalElementBufferModule/Documentation/Quality-Profile.md` |

## ElementBuffer

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `BARE-042` | `EXCLUDED` | User / Codex | [EXECUTION] ElementBuffer利用理解Validation試行 | 2026-10-15、ElementBufferは1.0提供対象外となり、現行目標は実装・仕様・test・benchmark・安全性・既存利用影響の保守であるため、一般利用者向け提供を前提にした理解Validationは現在の成果に不要として残作業から外した。将来、一般提供を再検討する場合は当時の公開面と目的から新しいtaskとして組み直す | `Maintanance/ElementBufferModule/GeneralSwiftValidationScenario.md` / `Maintanance/ElementBufferModule/UserDocumentationDraft.md` / `Maintanance/Current/QUALITY_REQUIREMENTS.md` |
| `BARE-043` | `EXCLUDED` | User / Codex | [EXECUTION] ElementBuffer競技利用Validation試行 | 2026-10-15、ElementBufferは1.0提供対象外で、現行目標に実問題への外部提出による採用Validationを必要としないため残作業から外した。既存利用の保守証拠や将来の提供再検討が具体化した場合は、問題・環境・必要な判断を現在の目的から新しく定める | `Maintanance/ElementBufferModule/GeneralSwiftValidationScenario.md` / `Maintanance/Current/QUALITY_REQUIREMENTS.md` |

## 履歴へ移す前の完了記録

以下は完了済みであり、残作業・着手候補に含めない。

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `OPS-031` | `DONE` | User / Codex | [EXECUTION] Orientation V4正本採用とplaybook参照切替 | 2026-10-14、ユーザーの採用指示を受け、V4三文書とTask Operation Playbook V4の冒頭へ正本採用を明記し、V4から辿るplaybook参照をV4へ統一。後にV5へ切り替え、2026-10-15にV4一式を履歴化した | `Maintanance/Archived/Orientation/CODEX_ORIENTATION_V4.md` / `Maintanance/Archived/Orientation/TASK_ORIENTATION_V4.md` / `Maintanance/Archived/Orientation/AI_COLLABORATION_PHILOSOPHY_V4.md` / `Maintanance/Archived/Orientation/CODEX_TASK_OPERATION_PLAYBOOK_V4.md` |
| `OPS-032` | `DONE` | Prime Codex / 80ms Codex / V3オーサー / ChatGPT | [DISCOVERY] 名前持ちCodexによる`AGENTS.md`再現性レビュー | 2026-10-14、4者の個別reviewを統合。全員が既存議論へ露出済みのためblindな独立再現とはせず、既知所見の適用再現、Routine commit許可の共通追加所見、Xcode handoffのPrime固有所見を証拠種別つきで分離した。このtaskの完了時点ではAGENTS変更は未承認であり、後の採用は`OPS-035`に記録 | `Maintanance/Archived/AGENTS_MD_NAMED_CODEX_REVIEW.md` |
| `OPS-033` | `DONE` | Prime Codex | [EXECUTION] `AGENTS.md`原案R1の4者レビュー配布準備 | 2026-10-14、draft・master・4票のR1本文hash一致、4票が識別番号以外byte一致、一枚ごとの共通依頼・対象本文・返却欄を確認。01〜04をPrime Codex、80ms Codex、V3オーサー、ChatGPTへ割り当て、各票を渡せる状態にした。このtaskは配布準備までを完了範囲とし、返却・統合は`OPS-034`、後の採用は`OPS-035`に記録 | `Maintanance/Archived/AgentsReview/AGENTS_REVIEW_MASTER.md` |
| `OPS-034` | `DONE` | Prime Codex / 80ms Codex / V3オーサー / ChatGPT | [DISCOVERY] `AGENTS.md`原案R1の4者初読レビューと統合 | 2026-10-14、4票の返却と事前接触記録を確認し、文言、具体場面、反証を照合して統合。R1は協働の入口として骨格を保てるが実効性は未観測。必須修正は確定せず、依頼と合意、許可範囲、権限返還、俯瞰対象を任意の表現改善候補として分離した。このtaskの完了時点では現行`AGENTS.md`への採用・反映は未実施であり、後の採用は`OPS-035`に記録 | `Maintanance/Archived/AgentsReview/AGENTS_REVIEW_MASTER.integrated.md` |
| `OPS-035` | `DONE` | User / Codex | [EXECUTION] 現行`AGENTS.md`とOrientation V5の正本採用・参照切替 | 2026-10-14、ユーザーが現行`AGENTS.md`を採用・修正し、続く正式採用指示によりV5の4文書を一組の正本として採用。`AGENTS.md`の明示的なオリエンテーション参照先を`Maintanance/OrientationV5/CODEX_ORIENTATION_V5.md`へ切り替え、各文書の状態欄と採用記録を整合した。旧V4は履歴として現在位置に残す | `AGENTS.md` / `Maintanance/OrientationV5/README.md` / `Maintanance/OrientationV5/CODEX_ORIENTATION_V5.md` / `Maintanance/OrientationV5/TASK_ORIENTATION_V5.md` / `Maintanance/OrientationV5/AI_COLLABORATION_PHILOSOPHY_V5.md` / `Maintanance/OrientationV5/CODEX_TASK_OPERATION_PLAYBOOK_V5.md` |
| `OPS-036` | `DONE` | User / Claude / Codex | [EXECUTION] Task履歴SQLite索引の試作・採用・初回作成 | 2026-10-15、Astraの手順案を基にClaudeが抽出器、Registry行変化、通常・アーカイブ・介入後メンテ操作を試作し、ユーザーが規則と実装を採用。Codexが既定DBを現在HEADまで更新して整合を確認し、一時entry 5件を一つの成果として受け入れた。索引はtask IDとcommitの探索を助ける参考資料であり、介入・完了・採用の意味判断やRegistryを代替しない | `Utilities/Maintenance/TaskHistoryIndex.py` / `Maintanance/ProgressV2/TASK_HISTORY_INDEX_MAINTENANCE.md` / `Maintanance/ProgressV2/TASK_HISTORY_INDEX_PROTOTYPE_NOTES.md` / `Maintanance/ProgressV2/TASK_RULES_V2.md` |
| `OPS-037` | `DONE` | User / Claude / ChatGPT / Codex | [EXECUTION] 判断座標の参考資料化・統合と`AGENTS.md`再評価 | 2026-10-14、副作用の勾配、最小orientation、変化・知識・時間差を参考資料と草案へまとめ、判断座標へ統合。ユーザーの確定とChatGPTレビューを経て`AGENTS.md`を再評価し、この成果を後続の4者レビューとV5採用へ渡した。一時entry 4件はこの成果へ統合するが、各草案・参考資料を現行規則や指示として復活させない | `Maintanance/Archived/JudgmentCoordinates/EFFECT_GRADIENT_REFERENCE.md` / `Maintanance/Archived/JudgmentCoordinates/MINIMAL_ORIENTATION_DRAFT.md` / `Maintanance/Archived/JudgmentCoordinates/CHANGE_KNOWLEDGE_LAG_DRAFT.md` / `Maintanance/Archived/JudgmentCoordinates/JUDGMENT_COORDINATES_DRAFT.md` / `Maintanance/Archived/JudgmentCoordinates/JUDGMENT_COORDINATES_BUDDHISM_NOTE.md` / `Maintanance/Archived/JudgmentCoordinates/AGENTS_MD_COORDINATE_REVIEW.md` / `Maintanance/Archived/AgentsReview/AGENTS_REVIEW_MASTER.integrated.md` |
| `OPS-038` | `DONE` | User / Codex | [EXECUTION] 現行横断資料の`Maintanance/Current/`集約 | 2026-10-15、ユーザーの配置指示により、直下に散在していた現行の正本・運用資料9件を`Maintanance/Current/`へ集約し、Registry、品質文書、関連する現行資料の参照を追従した。明示された8文書と、`AGENTS.md`が固定パスで参照する`CONVERSATION_REFERENCE_IDS.md`は現在位置を維持。この時点では失効した旧進捗、完了作業記録、未採用草案を対象外とし、後続の`OPS-039`・`OPS-040`でArchivedへ移した。文書の権限・task状態・凍結条件は変更していない | `Maintanance/Current/README.md` / `Maintanance/ProgressV2/TASK_RULES_V2.md` |
| `OPS-039` | `DONE` | User / Codex | [EXECUTION] 失効済み旧進捗一覧のアーカイブ | 2026-10-15、ユーザーの指示により、V2接続後は履歴としてだけ残っていた旧`Maintanance/PROGRESS_OVERVIEW.md`全文をArchivedへ移し、V2の履歴入口とアーカイブ索引から辿れるようにした。現在の品質文書とtest作業入口に残っていた旧Registry参照はV2へ更新。旧task・制度を復活させず、現在のtask状態・依存・権限は変更していない | `Maintanance/Archived/PROGRESS_OVERVIEW_RETIRED_2026-10-15.md` / `Maintanance/ProgressV2/TASK_REGISTRY_ARCHIVE.md` |
| `OPS-040` | `DONE` | User / Codex | [EXECUTION] メンテナンス直下と旧Orientationの役割別整理 | 2026-10-15、ユーザーの指示により、直下に残っていた完了資料・snapshot・ポスターと、完了済み`AgentsReview/`・`EffectGradientPoster/`・旧`Orientation/`を役割別にArchivedへ移した。未完了だったWorker候補3件は当時`Maintanance/Worker/`へ分離し、後に除外記録とともに履歴化した。現行の技術補助とtask-fit資料はそれぞれ`Current/`と`ProgressV2/`へ分離し、状態と効力を保った。現行文書と完了記録の参照を追従し、履歴資料を現行規則やtaskへ復活させていない | `Maintanance/Archived/README.md` / `Maintanance/Archived/Worker/README.md` / `Maintanance/Current/README.md` / `Maintanance/ProgressV2/AGENT_TASK_FIT_INTERVIEW.md` |
