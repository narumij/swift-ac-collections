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
| `OPS-001` | `FROZEN` | Codex | [DISCOVERY] Codex task運用playbookの移植可能化 | 2026-10-08、ユーザー指示により保留。明示的な再開指示後、当時のV2による試行目的と、再開時の現行playbookへの更新要否を再確認して再現性検証へ進む。旧V2・V3と旧templateは当時の経緯を確かめる資料として扱う。完成済みRegistryを移植する旧templateは2026-10-13に履歴化 | 起点（現行playbook）：`Maintanance/OrientationV5/CODEX_TASK_OPERATION_PLAYBOOK_V5.md`。経緯資料：`Maintanance/Archived/Orientation/CODEX_TASK_OPERATION_PLAYBOOK_V2.md` / `Maintanance/Orientation/CODEX_TASK_OPERATION_PLAYBOOK_V3.md` / `Maintanance/Archived/Orientation/PROGRESS_OVERVIEW_TEMPLATE.md` |
| `OPS-028` | `WAITING_USER` | Codex | [EXECUTION] 作業Codex用ブートストラップの作成 | 固定bootstrapとtask契約templateの未採用初稿を作成し、独立レビューで読み取り、operation権限、workspace、返却経路、実証境界の修正点を抽出。ユーザーレビュー後に候補を再構成する | `Maintanance/Orientation/WORKER_CODEX_BOOTSTRAP_TASK.md` / `Maintanance/Orientation/WORKER_CODEX_BOOTSTRAP.md` / `Maintanance/Orientation/WORKER_CODEX_TASK_CONTRACT_TEMPLATE.md` |
| `OPS-030` | `USER_ONLY` | User | [DECISION] 作業Codex用ブートストラップ候補のレビュー | 任意の時点で未採用初稿とレビュー論点を読み、Codexが候補を再構成してよいか、追加または変更する設計意図があるかを一つのレビュー結果として返す。AIは着手・代行・催促しない | `Maintanance/Orientation/WORKER_CODEX_BOOTSTRAP_TASK.md` / `Maintanance/Orientation/WORKER_CODEX_BOOTSTRAP.md` / `Maintanance/Orientation/WORKER_CODEX_TASK_CONTRACT_TEMPLATE.md` |

### 公開とリリース

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `RELEASE-020` | `FROZEN` | Codex | [EXECUTION] 0.6.0でGitHub Pages更新元をrelease tagへ一本化 | 0.5.xではmain pushとrelease tag pushの双方によるdeploy競合を許容。0.6.0のrelease工程でmain由来のdeployを停止し、tag commitから生成・検証した利用者向け文書だけがPagesを更新することを確認 | `Maintanance/Current/RELEASE_0_6_0.md` |
| `RELEASE-072` | `USER_ONLY` | User | [EXECUTION] 人間向けリリース工程表の作成 | 一枚の工程表の原型は2026-10-12に作成され、その後、旧release資料の一本化、AGENTS.mdを残す区間、AI分担境界が実績に基づいて追記済み。残るのは、実際のreleaseで現在位置・次の操作・完了証拠・停止点を追えるかをユーザーが観測し、工程表として受け入れること。AIは完了を代行判断せず、依頼された整理・レビューだけを補助する | `Maintanance/User/RELEASE_PROCESS.md` |
| `RELEASE-075` | `USER_ONLY` | User | [EXECUTION] リリース工程の不足仕様充当 | 工程表には基本操作、CI確認、候補・最終tag、AI分担境界まで記載済み。定義した品質要求に対する判定基準、証拠取得方法、失敗時の停止・復旧手順など、V&Vに必要な未充当部分をユーザーが補う。AIは不足が解消したと代行判断せず、依頼された整理・レビューだけを補助する | `Maintanance/User/RELEASE_PROCESS.md` / `Maintanance/Current/QUALITY_REQUIREMENTS.md` |
| `RELEASE-076` | `USER_ONLY` | User | [EXECUTION] リリース工程のValidation & Verification | ユーザーが、充当後の工程仕様について、定義した品質要求を満たすことと、意図したリリース目的に適合することを確認する。AIは開始、代行、催促を行わず、依頼された場合だけ検証・レビューを補助する | `Maintanance/User/RELEASE_PROCESS.md` |
| `DOC-010` | `FROZEN` | Codex | [DISCOVERY] ElementBufferの定性的性能表現の再検討 | 2026-10-09に確認した`[[Element]]`との比較意図は、当時の連鎖subscript・非所有Viewを含む設計の履歴である。その公開面は削除され、現行は単一連続storageの座標value accessと借用参照であるため、旧根拠から現行文言を確定しない。ユーザーの明示再開後、現在の操作、比較対象、測定証拠に照らして「C言語の配列に近いアクセス性能」を維持できるか再検討する | `Maintanance/Archived/Canonical/RELEASE_0_5_2.md` / `Maintanance/ElementBufferModule/ElementBufferAudit.md` / `Sources/ElementBufferModule/Documentation/Quality-Profile.md` |
| `DOC-026` | `FROZEN` | User / Codex | [EXECUTION] Swift Package Indexへのpackage登録 | 0.9.x release後にユーザーが明示的に再開し、公式PackageListへ`https://github.com/narumij/swift-ac-collections.git`を追加する外部PRを準備・提出して、package page、互換性表示、module別DocC build結果を確認する | `Maintanance/Current/DOCUMENTATION_CI_PLAN.md` / `Package.swift` |
| `DOC-027` | `FROZEN` | Codex | [EXECUTION] Swift Package Index公開導線のREADME・Pages反映 | `DOC-026`完了後、SPI package pageの`Do you maintain this package?`が提示するMarkdownを正として互換性badgeをREADMEへ追加し、確認できたmodule別DocC URLへの導線をREADMEまたはPagesへ接続する | `Maintanance/Current/DOCUMENTATION_CI_PLAN.md` / `README.md` |
| `RELEASE-007` | `FROZEN` | User / Codex | [DECISION] 0.6.0の到達範囲とrelease検討開始 | `RELEASE-078`で、0.5.3後の公開面、現行品質区分、文書の完成状態、および旧開始条件の差を判断材料として揃えた後、ユーザーが0.6.0へ含める到達範囲とrelease工程へ進むかを一つに決定する。調査完了だけでは凍結を解除しない | `Maintanance/Current/RELEASE_0_6_0.md` / `Maintanance/Current/QUALITY_REQUIREMENTS.md` / `Package.swift` |
| `RELEASE-078` | `PROPOSED` | Codex | [DISCOVERY] 0.6.0開始条件と現行提供区分の再照合 | 0.5.3後の公開面、利用者向け文書、`QUALITY_REQUIREMENTS.md`の1.0提供区分、および`RELEASE_0_6_0.md`の旧開始条件を照合し、0.6.0の対象候補、必要な文書入力、条件付き依存、残る一つずつのユーザー判断を整理する。release範囲、提供停止、名称、公開契約は決定せず、範囲・完了条件・担当・詳細正本・必須依存を確認して状態を更新するまで着手しない | `Maintanance/Current/RELEASE_0_6_0.md` / `Maintanance/Current/QUALITY_REQUIREMENTS.md` / `Package.swift` / `Maintanance/ProgressV2/TASK_REGISTRY_V2.md` |

### RedBlackTreeと品質ゲート

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `RBT-001` | `WAITING_EXTERNAL` | User / Codex | Index完了ゲート | 公開Index表現・完了範囲と`Comparable`採否を確定し、Index契約全体を閉じる。再開時は現行API・設計と外部要件を照合し、旧残task文書は経緯だけに使う | 現行確認：`Sources/RedBlackTreeCollections/Documentation/API-Matrix.md` / `Sources/RedBlackTreeCollections/Documentation/Design/Design-MemorySafety.md` / `Sources/RedBlackTreeCollections/Documentation/Quality-Profile.md`。履歴：`Maintanance/Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-010` | `WAITING_EXTERNAL` | User / Codex | Index完了ゲートのうち公開Index表現と完了範囲 | Container要件の安定後、現行API・設計と外部要件を照合し、公開Indexと内部`SealError`の分離、1.0での完了範囲を決定する。旧残task文書は経緯だけに使う | 現行確認：`Sources/RedBlackTreeCollections/Documentation/API-Matrix.md` / `Sources/RedBlackTreeCollections/Documentation/Design/Design-MemorySafety.md` / `Sources/RedBlackTreeCollections/Documentation/Quality-Profile.md`。履歴：`Maintanance/Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-011` | `WAITING_EXTERNAL` | User / Codex | Indexの`Comparable`採否 | `swift-collections`の要件が安定または正式化した後、現行API・設計と外部要件を照合して互換性を再評価し、採否を決定する。旧残task文書は経緯だけに使う | 現行確認：`Sources/RedBlackTreeCollections/Documentation/API-Matrix.md` / `Sources/RedBlackTreeCollections/Documentation/Design/Design-MemorySafety.md` / `Sources/RedBlackTreeCollections/Documentation/Quality-Profile.md`。履歴：`Maintanance/Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-014` | `FROZEN` | Codex | RedBlackTree文書workflowと4型outlineのAPI照合 | Permutation、OptionalElementBuffer、ElementBufferの利用者向け文書作業による方式習熟は完了済み。ユーザーの明示的な再開後、workflowと4公開型のoutlineを現在のAPI、test、設計資料へ再照合し、本文作成へ渡せる状態を確認する | `Sources/RedBlackTreeCollections/Documentation/Head/DOCUMENTATION_WORKFLOW.md` |
| `RBT-032` | `FROZEN` | Codex | [DISCOVERY] RedBlackTree 0.6.0現行品質アセスメント | 2026-10-13、Codex復旧中の中断taskとして凍結。ユーザーの明示的な再開指示後、既存の試験結果と不足する再現証拠を照合してから継続する | `Maintanance/RedBlackTreeModule/CurrentQualityAssessment.md` |
| `RBT-033` | `PROPOSED` | Codex | [DISCOVERY] macOS ASan＋Swift Testing Death Test実行経路の成立確認 | lifetime balance検査をtraitで除外しても子プロセスでASan runtimeが遅延ロードされる事象について、Swift Testing実行基盤、macOS環境、Linux CIとの差を切り分け、製品不具合と検証経路不成立を区別する | `Maintanance/RedBlackTreeModule/CurrentQualityAssessment.md` / `Package.swift` |
| `RBT-034` | `FROZEN` | User / Codex | [EXECUTION] RedBlackTree 1.0品質アセスメント完成 | 1.0品質ゲートの再開後、再現可能な証拠一式を備え、要求・主張・反証・未検証領域・残余リスクを接続した品質アセスメントを完成させる | `Maintanance/RedBlackTreeModule/CurrentQualityAssessment.md` / `Sources/RedBlackTreeCollections/Documentation/Quality-Profile.md` |
| `RBT-035` | `FROZEN` | Claude / Codex | [DISCOVERY] RedBlackTreeチューニングの落ち穂拾い | ユーザーの明示的な再開指示後、過去の実装・benchmark・Git履歴・チューニング記録を現行コードと照合し、取りこぼした改善候補、未反映の知見、再検証が必要な仮説を発見する。性能変更は行わず、実測と判断が必要な後続taskへ分離する | `Maintanance/RedBlackTreeModule/CurrentQualityAssessment.md` / `Sources/RedBlackTreeCollections/Documentation/Quality-Profile.md` / `Benchmarks/` |
| `RBT-026` | `FROZEN` | User / Codex | [DECISION] Mapped Values ViewのO(1)範囲契約再検討 | 利用者向け文書作業フェーズで、現行View APIと実装を確認し、View外だがbase treeでは有効なIndexを黙って読み書きし得る性質を踏まえ、O(1)と呼び出し側事前条件の契約を維持するか一つだけ再判断する。旧残task文書は論点の経緯だけに使う | 現行確認：`Sources/RedBlackTreeCollections/Documentation/API-Matrix-View.md` / `Sources/RedBlackTreeCollections/Documentation/API-Matrix.md`。履歴：`Maintanance/Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-004` | `FROZEN` | Codex | 残存するDebug限定Comparable群・Balanced群 | Debug限定`Result: Comparable`はユーザー介入で削除済み。残る`_LazyTieWrap`・`_NodePtrSealing`・`_LazyTie`の比較宣言とBalanced群について、Index契約またはexecutable API Matrix方針の確定後、ユーザーがこのtaskを明示的に再開 | `Maintanance/Current/EXTERNAL_TYPE_EXTENSION_AUDIT.md` |
| `RBT-005` | `WAITING_EXTERNAL` | Codex | Memoize群の公開終了／正式API化 | 外部consumer 2件の移行後 | `Maintanance/Current/EXTERNAL_TYPE_EXTENSION_AUDIT.md` |
| `RBT-007` | `FROZEN` | User / Codex | RedBlackTreeCollectionsのstrict memory safety全面適用 | ユーザーが段階3を承認し、このtaskを明示的に再開 | `Maintanance/Current/StrictMemorySafetyReadiness.md` |
| `RBT-008` | `FROZEN` | User / Codex | `lazyDetach`等の並行初期化保証 | concurrency契約を扱う明示的な再開指示後、現行の非thread-safe契約、外部同期要件、実装上の一度だけの初期化TODOを照合して、必要な保証を改めて定める。旧残task文書は論点の経緯だけに使う | 現行確認：`Sources/RedBlackTreeCollections/Documentation/Design/Design-MemorySafety.md` / `Maintanance/RedBlackTreeModule/CurrentQualityAssessment.md` / `Sources/RedBlackTreeCollections/Implements/UnsafeTreeV2/Buffer/UnsafeTreeV2+BufferHeader.swift`。履歴：`Maintanance/Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-009` | `FROZEN` | User / Codex | [DECISION] runtime-check実装の再審査 | ユーザードキュメント作業後、1.0中間ゴールへ移行した時点、または`-Ounchecked`が主要構成と判明した時点で再開し、現行実装を1.0へ採用するか一つだけ判断 | `Sources/RedBlackTreeCollections/Documentation/Design/Design-RuntimeChecks.md` |
| `QUALITY-001` | `FROZEN` | User / Codex | 汎用基盤ライブラリとしての1.0採用品質ゲート | Index契約確定後、ユーザーが明示的に再開 | `Sources/RedBlackTreeCollections/Documentation/Quality-Profile.md` |
| `QUALITY-002` | `FROZEN` | Codex | [EXECUTION] 1.0品質保証CIの構成・証拠化 | 1.0品質ゲートの再開後、Ubuntu 24.04 LTS / x86_64のGitHub-hosted runnerで合意済みの品質試験を実行し、commit、workflow run、runner image、kernel、architecture、CPU、Swift、依存解決、選択試験、完全log、終了statusを証拠として残す。変動するrunner上の絶対性能は判定対象に含めない | `Maintanance/Current/QUALITY_REQUIREMENTS.md` / `Tests/TESTING.md` / `.github/workflows/candidate.yml` |
| `QUALITY-003` | `FROZEN` | Codex | [EXECUTION] Apple platforms 27提供境界のmanifest反映・build確認 | 1.0品質ゲートの再開後、対象Apple platformごとの最低deployment versionをmanifestへ反映し、64-bitのplatform別build・導入経路を確認する。macOS 27 / arm64以外はbuild証拠と実行品質を区別する | `Maintanance/Current/QUALITY_REQUIREMENTS.md` / `Package.swift` |

### Permutation

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `PERM-062` | `PROPOSED` | User / Codex | [EXECUTION] Permutation利用理解Validation試行 | API設計非参加者に利用者向け本文と公開surfaceだけを渡し、類似API選択、即時消費、永続保存、失効説明、View copyと要素copyの区別を無誘導で観測する。参加者選定と外部接触はユーザーが行い、Codexは課題提示と記録整理を担う | `Maintanance/PermutationModule/GeneralSwiftValidationScenario.md` / `Maintanance/PermutationModule/UserDocumentationDraft.md` |
| `PERM-063` | `FROZEN` | Codex | [EXECUTION] Permutation benchmark task名移行互換の先行導入 | ユーザーの明示再開後、CI登録中の旧`Permutations.SubSequenceN` 2 taskを現行`NextPermutationsSequence.Permutation`名へ対応付けるbaseline入力・結果名正規化をworkflowへ先に追加し、remote performance CIのgreenを確認 | `Maintanance/PermutationModule/BENCHMARK_TASK_NAME_MIGRATION.md` / `Maintanance/Current/PERFORMANCE_CI_CHANGE_GUIDE.md` / `.github/workflows/ci.yml` |
| `PERM-064` | `FROZEN` | Codex | [EXECUTION] Permutation benchmark表示名の現行型名への移行 | `PERM-063`のmerge後、benchmark sourceの旧内部型名を含む4 titleとCI library登録2件を`NextPermutationsSequence.Permutation`へ変更し、task列挙、base / current比較、remote performance CIのgreenを確認 | `Maintanance/PermutationModule/BENCHMARK_TASK_NAME_MIGRATION.md` / `Benchmarks/Sources/Benchmarks/PermutationBenchmarks.swift` / `Benchmarks/Libraries/CI.json` |
| `PERM-043` | `FROZEN` | User | [DECISION] C++標準に匹敵すると判定する性能比の上限 | 2026-10-11、ユーザー指示により比較水準の判断を保留。明示的な再開指示後、28要素中7要素を選ぶ最大ケースでSwiftの全体処理時間を`std::next_permutation`の何倍以内なら「匹敵」と受け入れるか一つだけ決定する | `Maintanance/PermutationModule/CurrentQualityAssessment.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` |
| `PERM-044` | `FROZEN` | Codex | [EXECUTION] Permutation外部性能アセスメントの実測・判定 | 2026-10-11、比較水準の判断とともにユーザー指示で保留。`PERM-043`の明示的な再開・完了後、macOS上で専用scriptを実行し、環境情報、生JSON、PNG chartを保存して判定する | `Maintanance/PermutationModule/CurrentQualityAssessment.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` |
| `PERM-046` | `FROZEN` | Codex | [DISCOVERY] Swift 6.2向けmanifest構成の必要性再評価 | runtime-check View通常版がSwift 6.2で成立したため、旧「PermutationModuleなしの縮小manifest」案はそのまま実行しない。ユーザーの明示的な再開指示後、package全体の6.2成立条件を調べ、version-specific manifest自体が必要かから再評価する | `Maintanance/PermutationModule/CurrentQualityAssessment.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` |
| `PERM-051` | `FROZEN` | Claude | [EXECUTION] borrowed Span版PermutationのTest as Specification | runtime仕様test 25件を受け入れ、2026-10-13にも対象25件成功を再確認。一時clientによるcompile-pass／compile-fail結果は返却記録にあるが、repository内の再実行可能なfixtureではないため、ユーザーの明示的な再開まで残作業を凍結 | `Maintanance/PermutationModule/BorrowedPermutationTestPlan.md` / `Sources/PermutationModule/BorrowedNextPermutations.swift` / `Tests/PermutationTests/BorrowedNextPermutations/` |
| `PERM-060` | `FROZEN` | User | [DECISION] NextPermutationsのSequence表面を製品候補として検討するか | 2026-10-13、`Array(sequence)`が要素配列ではなく失効可能なViewを収集する事実を新しい判断材料として、採用・不採用を決めず延期。ユーザーの明示的な再開後、View Sequenceの有効な操作範囲と誤用防止、所有配列を返す別Sequence、copy・性能costを追試してから一つ選ぶ | `Maintanance/PermutationModule/NextPermutationsSequenceExperiment.md` |

### OptionalElementBuffer

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `OPT-045` | `EXCLUDED` | User | [DECISION] OptionalElementBuffer次元名体系の再判断 | 後発の横断命名判断へ吸収。2026-10-15、名称決定時に次元名も同時に決定済みだったことをユーザー確認。2D・3Dの`width`・`height`・`depth`と4Dの`size0`〜`size3`を両moduleで維持し、連鎖subscript・View削除後の座標accessとも整合するため、旧判断taskを独立に実行せずrelease前提にも残さない | `Maintanance/Current/PUBLIC_API_NAMING_DECISIONS.md` / `Maintanance/OptionalElementBufferModule/OptionalElementBufferAudit.md` / `Maintanance/ArrayObjectAndAPINamingDraft.md` |
| `OPT-072` | `FROZEN` | User / Codex / Claude | [DISCOVERY] Swift 6.4以降向けOptionalElementBuffer一般提供方式 | split storageを維持する案と、`Element?` storage・標準`MutableRef`を使う案について、性能測定を含む成立条件、証拠、未確定の判断を整理する。調査の完了に方式の採用や再設計の実施は含めない。現在の競技用途向けopt-in提供を妨げず、ユーザーの明示再開まで着手しない | `Maintanance/OptionalElementBufferModule/CurrentQualityAssessment.md` / `Sources/OptionalElementBufferModule/Documentation/Quality-Profile.md` |
| `OPT-064` | `FROZEN` | User / Codex | [EXECUTION] OptionalArray一般利用理解Validation試行 | `OPT-072`の調査結果を必要とするが、その完了だけでは開始しない。一般Swift向け提供方式の採用判断と、検証する公開surface・説明がそろうまで凍結を保つ。明示再開後、設計非参加者が本文と公開surfaceから用途、座標順、nil遷移、所有・並行利用境界を理解できるか観測する。再開に向けて不足する判断・実行は別taskへ分ける | `Maintanance/OptionalElementBufferModule/GeneralSwiftValidationScenario.md` / `Maintanance/OptionalElementBufferModule/UserDocumentationDraft.md` / `Maintanance/OptionalElementBufferModule/OptionalElementBufferAudit.md` |
| `OPT-065` | `PROPOSED` | User / Codex | [EXECUTION] OptionalArray競技利用Validation試行 | ユーザーが問題・judge・提出可否を決めた後、未計算状態を持つ固定shapeの多次元メモ化問題で提出source、正否、実行時間、メモリを記録する。C++級性能や一般Swift利用へ一般化しない | `Maintanance/OptionalElementBufferModule/GeneralSwiftValidationScenario.md` / `Tests/OptionalElementBufferModuleTests/EDPC-J.swift` / `Tests/OptionalElementBufferModuleTests/EDPC-L.swift` |

### ElementBuffer

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `BARE-035` | `FROZEN` | Codex | [DISCOVERY] ElementBuffer提供停止の実施境界整理 | 1.0提供対象外という現行区分だけからpackage上の提供停止を導かない。ユーザーが提供停止の検討を明示的に再開した場合に限り、package、facade、文書、移行、release、既存利用への影響を現在の公開面へ再照合し、局所的な後続taskへ分解する | `Maintanance/Current/QUALITY_REQUIREMENTS.md` / `Sources/ElementBufferModule/Documentation/Quality-Profile.md` / `Package.swift` |
| `BARE-042` | `EXCLUDED` | User / Codex | [EXECUTION] ElementBuffer利用理解Validation試行 | 2026-10-15、ElementBufferは1.0提供対象外となり、現行目標は実装・仕様・test・benchmark・安全性・既存利用影響の保守であるため、一般利用者向け提供を前提にした理解Validationは現在の成果に不要として残作業から外した。将来、一般提供を再検討する場合は当時の公開面と目的から新しいtaskとして組み直す | `Maintanance/ElementBufferModule/GeneralSwiftValidationScenario.md` / `Maintanance/ElementBufferModule/UserDocumentationDraft.md` / `Maintanance/Current/QUALITY_REQUIREMENTS.md` |
| `BARE-043` | `EXCLUDED` | User / Codex | [EXECUTION] ElementBuffer競技利用Validation試行 | 2026-10-15、ElementBufferは1.0提供対象外で、現行目標に実問題への外部提出による採用Validationを必要としないため残作業から外した。既存利用の保守証拠や将来の提供再検討が具体化した場合は、問題・環境・必要な判断を現在の目的から新しく定める | `Maintanance/ElementBufferModule/GeneralSwiftValidationScenario.md` / `Maintanance/Current/QUALITY_REQUIREMENTS.md` |

### 移行史

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `HIST-001` | `FROZEN` | V3オーサー | [DISCOVERY] AtCoder 2025移行史 | 2026-10-13、現時点の整理を一段落として凍結。ユーザーの明示的な再開指示後、本紙の説明または証拠別紙へ追加する必要がある範囲だけを再開する | `Maintanance/RefactoringFromAtCoder2025/README.md` / `Maintanance/RefactoringFromAtCoder2025/EVIDENCE.md` |

## Task precedence

内部task間の必須AND前提を記録する。`SEQUENCE`は前提成果がそろうまで後続を開始・継続しない。`PARALLEL_JOIN`は独立部分を並行でき、後続の完了までに合流する。いずれも状態・委任・再開条件を上書きしない。

| 後続task | 前提task | Flow | 制約 |
| --- | --- | --- | --- |
| `RBT-001` | `RBT-010` | `PARALLEL_JOIN` | 公開Index表現・完了範囲の判断は、Comparable採否と分離したまま親ゲートの完了前に合流する |
| `RBT-001` | `RBT-011` | `PARALLEL_JOIN` | Comparable採否の外部依存は判断task側に残し、親ゲートの完了前に合流する |
| `QUALITY-001` | `RBT-001` | `PARALLEL_JOIN` | 品質調査は並行できるが、1.0品質判定を確定する前にIndex契約完了と合流する |
| `QUALITY-001` | `RBT-009` | `PARALLEL_JOIN` | 他の1.0品質作業は並行できるが、最終判定前にruntime-check実装の採否と合流する |
| `QUALITY-001` | `RBT-034` | `PARALLEL_JOIN` | 1.0採用品質を判定する前に、再現可能な証拠を備えた品質アセスメントの完成と合流する |
| `QUALITY-001` | `QUALITY-002` | `PARALLEL_JOIN` | 1.0採用品質を判定する前に、Linux代表環境の品質保証CIと再現可能な実行証拠を合流する |
| `QUALITY-001` | `QUALITY-003` | `PARALLEL_JOIN` | 1.0採用品質を判定する前に、Apple platforms 27のmanifest境界とplatform別build証拠を合流する |
| `QUALITY-001` | `DOC-026` | `PARALLEL_JOIN` | 1.0採用品質を判定する前に、0.9.xをSwift Package Indexへ登録し、外部build・互換性表示・module別DocC生成の結果を合流する |
| `QUALITY-001` | `DOC-027` | `PARALLEL_JOIN` | 1.0採用品質を判定する前に、SPIが生成した互換性badgeと確認済みmodule別API referenceへの公開導線を合流する |
| `RBT-026` | `RBT-014` | `SEQUENCE` | 現行APIとの照合を判断材料として揃えてからMapped Values契約を再判断する |
| `OPT-064` | `OPT-072` | `SEQUENCE` | 調査結果を利用検証の前提とする。調査完了は方式の採用・再設計完了を意味しない。必要な判断と検証対象の整備は、再開時に独立したtaskと依存へ具体化する |
| `PERM-044` | `PERM-043` | `SEQUENCE` | C++標準に匹敵すると判定する性能比上限を確定してから、保存したmacOS測定証拠へ適用する |
| `PERM-064` | `PERM-063` | `SEQUENCE` | 旧名baselineと新名HEADを対応付けるworkflowを先にmergeしてgreenを確認してから、benchmark titleを変更する |
| `OPS-028` | `OPS-030` | `SEQUENCE` | ユーザーが未採用初稿とレビュー論点を確認してから、Codexが候補を再構成する |
| `RELEASE-020` | `RELEASE-007` | `SEQUENCE` | 0.6.0の到達範囲とrelease開始を決定してから、Pages更新元の一本化をrelease工程として実施する |
| `RELEASE-007` | `RELEASE-078` | `SEQUENCE` | 0.5.3後の公開面、現行提供区分、文書状態、および旧0.6.0開始条件の差を判断材料として揃えてから、0.6.0の範囲とrelease開始を決定する |
| `RELEASE-076` | `RELEASE-075` | `SEQUENCE` | 不足仕様を充当して検証可能な工程にしてから、Validation & Verificationを行う |
| `DOC-027` | `DOC-026` | `SEQUENCE` | SPI登録と実在するpackage page・module別DocC URLを確認してから、badgeと公開導線をrepositoryへ反映する |

「AまたはB」の条件はANDの辺二本に変えず、task行に残す。例えば`RBT-004`の再開条件はORである。また、1.0品質ゲートの「再開」と「完了」は異なる。`QUALITY-002`・`QUALITY-003`をゲート完了まで待たせる逆向きの辺は作らない。

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
- 0.9.x release後、Swift Package Indexへpackageを登録し、module別DocCの生成と互換性表示を確認する。登録後に
  SPIが提供するbadgeとmodule別API referenceへの導線をREADMEまたはPagesへ接続し、結果を1.0品質gateへ渡す。
- 保留中の運用playbookをユーザー指示で再開した後、このrepositoryで得たtask運用知見を、
  別projectでもCodexが同程度の管理品質を再現できる移植可能な形へ整理する。

### 取り下げた目標

ElementBuffer（旧BareArray）の「1.0として採用できるか判断可能な状態にする」という目標は、現行品質要求で1.0提供対象外となっているため、2026-10-15の整理で取り下げた。代替の中間ゴールは設けず、既存の保守方針は品質要求に従う。元の目標文は[修正前原文](../Archived/PROGRESS_V2_GOALS_BEFORE_2026-10-15.md)に保存している。

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

## 履歴へ移す前の完了記録

以下は完了済みであり、残作業・着手候補に含めない。履歴へ移すときは、[圧縮・アーカイブ手順](TASK_REGISTRY_ARCHIVE.md)に従う。

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `OPS-031` | `DONE` | User / Codex | [EXECUTION] Orientation V4正本採用とplaybook参照切替 | 2026-10-14、ユーザーの採用指示を受け、V4三文書とTask Operation Playbook V4の冒頭へ正本採用を明記し、V4から辿るplaybook参照をV4へ統一。旧版の移動・アーカイブは行わない | `Maintanance/Orientation/CODEX_ORIENTATION_V4.md` / `Maintanance/Orientation/TASK_ORIENTATION_V4.md` / `Maintanance/Orientation/AI_COLLABORATION_PHILOSOPHY_V4.md` / `Maintanance/Orientation/CODEX_TASK_OPERATION_PLAYBOOK_V4.md` |
| `OPS-032` | `DONE` | Prime Codex / 80ms Codex / V3オーサー / ChatGPT | [DISCOVERY] 名前持ちCodexによる`AGENTS.md`再現性レビュー | 2026-10-14、4者の個別reviewを統合。全員が既存議論へ露出済みのためblindな独立再現とはせず、既知所見の適用再現、Routine commit許可の共通追加所見、Xcode handoffのPrime固有所見を証拠種別つきで分離した。このtaskの完了時点ではAGENTS変更は未承認であり、後の採用は`OPS-035`に記録 | `Maintanance/Archived/AGENTS_MD_NAMED_CODEX_REVIEW.md` |
| `OPS-033` | `DONE` | Prime Codex | [EXECUTION] `AGENTS.md`原案R1の4者レビュー配布準備 | 2026-10-14、draft・master・4票のR1本文hash一致、4票が識別番号以外byte一致、一枚ごとの共通依頼・対象本文・返却欄を確認。01〜04をPrime Codex、80ms Codex、V3オーサー、ChatGPTへ割り当て、各票を渡せる状態にした。このtaskは配布準備までを完了範囲とし、返却・統合は`OPS-034`、後の採用は`OPS-035`に記録 | `Maintanance/AgentsReview/AGENTS_REVIEW_MASTER.md` |
| `OPS-034` | `DONE` | Prime Codex / 80ms Codex / V3オーサー / ChatGPT | [DISCOVERY] `AGENTS.md`原案R1の4者初読レビューと統合 | 2026-10-14、4票の返却と事前接触記録を確認し、文言、具体場面、反証を照合して統合。R1は協働の入口として骨格を保てるが実効性は未観測。必須修正は確定せず、依頼と合意、許可範囲、権限返還、俯瞰対象を任意の表現改善候補として分離した。このtaskの完了時点では現行`AGENTS.md`への採用・反映は未実施であり、後の採用は`OPS-035`に記録 | `Maintanance/AgentsReview/AGENTS_REVIEW_MASTER.integrated.md` |
| `OPS-035` | `DONE` | User / Codex | [EXECUTION] 現行`AGENTS.md`とOrientation V5の正本採用・参照切替 | 2026-10-14、ユーザーが現行`AGENTS.md`を採用・修正し、続く正式採用指示によりV5の4文書を一組の正本として採用。`AGENTS.md`の明示的なオリエンテーション参照先を`Maintanance/OrientationV5/CODEX_ORIENTATION_V5.md`へ切り替え、各文書の状態欄と採用記録を整合した。旧V4は履歴として現在位置に残す | `AGENTS.md` / `Maintanance/OrientationV5/README.md` / `Maintanance/OrientationV5/CODEX_ORIENTATION_V5.md` / `Maintanance/OrientationV5/TASK_ORIENTATION_V5.md` / `Maintanance/OrientationV5/AI_COLLABORATION_PHILOSOPHY_V5.md` / `Maintanance/OrientationV5/CODEX_TASK_OPERATION_PLAYBOOK_V5.md` |
| `OPS-036` | `DONE` | User / Claude / Codex | [EXECUTION] Task履歴SQLite索引の試作・採用・初回作成 | 2026-10-15、Astraの手順案を基にClaudeが抽出器、Registry行変化、通常・アーカイブ・介入後メンテ操作を試作し、ユーザーが規則と実装を採用。Codexが既定DBを現在HEADまで更新して整合を確認し、一時entry 5件を一つの成果として受け入れた。索引はtask IDとcommitの探索を助ける参考資料であり、介入・完了・採用の意味判断やRegistryを代替しない | `Utilities/Maintenance/TaskHistoryIndex.py` / `Maintanance/ProgressV2/TASK_HISTORY_INDEX_MAINTENANCE.md` / `Maintanance/ProgressV2/TASK_HISTORY_INDEX_PROTOTYPE_NOTES.md` / `Maintanance/ProgressV2/TASK_RULES_V2.md` |
| `OPS-037` | `DONE` | User / Claude / ChatGPT / Codex | [EXECUTION] 判断座標の参考資料化・統合と`AGENTS.md`再評価 | 2026-10-14、副作用の勾配、最小orientation、変化・知識・時間差を参考資料と草案へまとめ、判断座標へ統合。ユーザーの確定とChatGPTレビューを経て`AGENTS.md`を再評価し、この成果を後続の4者レビューとV5採用へ渡した。一時entry 4件はこの成果へ統合するが、各草案・参考資料を現行規則や指示として復活させない | `Maintanance/EFFECT_GRADIENT_REFERENCE.md` / `Maintanance/MINIMAL_ORIENTATION_DRAFT.md` / `Maintanance/CHANGE_KNOWLEDGE_LAG_DRAFT.md` / `Maintanance/JUDGMENT_COORDINATES_DRAFT.md` / `Maintanance/JUDGMENT_COORDINATES_BUDDHISM_NOTE.md` / `Maintanance/AGENTS_MD_COORDINATE_REVIEW.md` / `Maintanance/AgentsReview/AGENTS_REVIEW_MASTER.integrated.md` |
| `OPS-038` | `DONE` | User / Codex | [EXECUTION] 現行横断資料の`Maintanance/Current/`集約 | 2026-10-15、ユーザーの配置指示により、直下に散在していた現行の正本・運用資料9件を`Maintanance/Current/`へ集約し、Registry、品質文書、関連する現行資料の参照を追従した。明示された8文書と、`AGENTS.md`が固定パスで参照する`CONVERSATION_REFERENCE_IDS.md`は現在位置を維持。失効した旧進捗、完了作業記録、未採用草案は集約対象外とし、文書の権限・task状態・凍結条件を変更していない | `Maintanance/Current/README.md` / `Maintanance/ProgressV2/TASK_RULES_V2.md` |
| `OPS-039` | `DONE` | User / Codex | [EXECUTION] 失効済み旧進捗一覧のアーカイブ | 2026-10-15、ユーザーの指示により、V2接続後は履歴としてだけ残っていた旧`Maintanance/PROGRESS_OVERVIEW.md`全文をArchivedへ移し、V2の履歴入口とアーカイブ索引から辿れるようにした。現在の品質文書とtest作業入口に残っていた旧Registry参照はV2へ更新。旧task・制度を復活させず、現在のtask状態・依存・権限は変更していない | `Maintanance/Archived/PROGRESS_OVERVIEW_RETIRED_2026-10-15.md` / `Maintanance/ProgressV2/TASK_REGISTRY_ARCHIVE.md` |

## 過去の記録への入口

完了・除外・判断の経緯を調べる必要が生じたときだけ、対象IDや変更を絞って参照する。

- `Maintanance/Archived/PROGRESS_OVERVIEW_HISTORY_2026-10-07.md`
- `Maintanance/Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-09.md`
- `Maintanance/Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-11.md`
- `Maintanance/Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-12.md`
- `Maintanance/Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-13.md`
- `Maintanance/Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-14.md`
- [V2切替後に失効・退役した旧進捗全文（2026-10-15移動）](../Archived/PROGRESS_OVERVIEW_RETIRED_2026-10-15.md)：旧task表・制度・説明を含む履歴。現在の状態や着手条件には使わない。
- [目標の記録の修正前原文（2026-10-15）](../Archived/PROGRESS_V2_GOALS_BEFORE_2026-10-15.md)：0.5.1・0.5.2、三対象の本文ドラフト、旧提供方針による目標を含む。現在の目標や実行指示としては扱わない。
