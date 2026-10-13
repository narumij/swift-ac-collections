# 開発・メンテナンス進捗一覧

最終更新: 2026-10-13 / Codex

この文書のTask Registryを、CodexとClaudeが作業を再開するときの唯一の入口とする。まずRegistry
だけを読み、選択したtask行が示す詳細正本だけを追加で読む。2026-10-07までの完了チェック、判断待ち、
旧サマリーは`Archived/PROGRESS_OVERVIEW_HISTORY_2026-10-07.md`へ移した。
2026-10-09までの`DONE`・`EXCLUDED` task行と、それらだけに向かう完了済みprecedence辺は
`Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-09.md`へ移した。以後2026-10-11までに完了・除外した行と
充足済みprecedence辺は`Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-11.md`へ移した。
現行Registryには状態が変わり得るtaskだけを残す。2026-10-12までに完了・除外した行と
充足済みprecedence辺は`Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-12.md`へ移した。
2026-10-13に完了・除外した行と充足済みprecedence辺は
`Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-13.md`へ移した。

## 正本整理時の配置維持例外

正本整理、役割別のfolder分け、またはArchivedへの移動を行う場合でも、次のMarkdownは現在位置から
移動または改名しない。この表は配置だけの例外を定め、各文書の権限、正本性、内容の更新規則は変更しない。

| Markdown | 現在位置に残す理由 |
| --- | --- |
| `USER_MANAGEMENT_INTERVIEW_CODEX.md` | Codexによるマネジメント継続性の記録 |
| `USER_MANAGEMENT_INTERVIEW_CLAUDE.md` | Claudeによる独立したマネジメント評価の記録 |
| `CLAUDE_OBSERVATIONS.md` | Claude本人の任意の観察を本人の声のまま保持する場所 |
| `CODEX_OBSERVATIONS.md` | Codex本人の任意の観察を本人の声のまま保持する場所 |
| `User/CONCEPT_DEFINITION.md` | ユーザーが定める製品目的の最上位正本であり、ユーザー専有の現在位置と権限境界を保持する |

## 文書ランクと変更権限

文書を読めること、編集へ参加できること、正本として採用できること、および配置を変更できることを
同じ権限として扱わない。上位文書の変更統制は、下位taskの実行権限から自動的には導かれない。

### `Maintanance/User/`

`Maintanance/User/`は、ユーザーが作成、所有、または配置先として明示した文書の領域である。
AIは、自ら作成した成果物をこのfolderへ独自判断で新規作成、配置、または移動しない。既存文書の参照や、
ユーザーが対象と操作を明示して依頼した編集は、この配置禁止だけを理由には妨げない。taskの実行権限や
文書整理の委任は、このfolderをAI成果物の配置先として選ぶ権限を含まない。

### `AGENTS.md`

`AGENTS.md`はrepository内で最上位の統治文書であり、AIの編集対象外とする。下位文書、task、または
実装上の都合によって変更、迂回、失効、移動、改名、またはアーカイブしない。

### `User/CONCEPT_DEFINITION.md`

`User/CONCEPT_DEFINITION.md`は、ユーザーが定める製品目的の最上位正本であり、AIの編集対象外とする。
AIは品質要求、設計、評価、task、およびrelease判断の前提として参照できるが、内容を変更、補完、再解釈して
上書き、移動、改名、またはアーカイブしない。変更が必要な場合は、ユーザーだけが判断して反映する。

### `Maintanance/Orientation/`

Orientation文書は、AIがrepositoryの目的、責任境界、および実務へ入るための上位正本群である。
ユーザーから委任された範囲では、AIも草案作成、レビュー、および内容編集へ参加できる。

ただし、次の操作はそれぞれ独立した境界として扱い、ユーザーの明示的な承認なしに実行しない。

- 新版または草案を現行正本として採用する。
- 現行版を失効させる、または参照先を新版へ切り替える。
- 文書を移動、改名、またはArchivedへ送る。

新版候補の作成や内容上の完成は、採用、正本切替、または旧版のアーカイブを意味しない。必要な場合は、
完成候補の作成、採用判断、配置判断、および移動・参照切替の実行を別taskまたは別受入境界として扱う。

### 下位の正本と記録

各moduleの品質プロファイル、設計文書、task詳細正本、および評価記録は、担当する上位正本とTask Registryに
従い、委任されたtaskの範囲で更新する。評価、観察、作業記録、およびArchived資料は、現行の上位規則や
製品判断を独自に上書きしない。

## Task Registry

**現在の律速:** 外部（`swift-collections` ContainersPreviewの`Container.Index`要件）。
Index契約と関連taskは、この外部条件が安定するまで最終確定できない。

**中間ゴールの取り扱い**

**直近達成した中間ゴール:** 0.5.3を完成させる。

2026-10-10、main merge commit `139ffef8`のCI greenを確認し、annotated tag `0.5.3`を同commitへ作成・pushして
remote到達を確認した。release後の記録用branchとして、同tagから`develop/misc/55`を作成した。

**今回達成した中間ゴール:** BareArrayとOptionalArrayの多次元access workloadをBenchmarkへ追加し、
実装を先にmergeした後、通常CI libraryへの登録だけを独立PRで合流した。登録PR #190でperformance jobの
greenを確認し、PR #191でも両moduleのbase / current測定自体は成立した。PR #191のjob全体はPermutationの
borrowed版からruntime-check版への方式切替を回帰として検出して赤となったため、同PRのmerge commitを
方式切替後のbaselineとした。PR #193では方式差を通常回帰から分離した比較契約でperformance jobの
all greenを確認した。C++とのmacOS外部assessmentは後続とし、性能比の受入判断は暫定実測後まで発生させない。

**凍結中の中間ゴール（前任conversationの残存記録）:**


**後続の中間ゴール:**

- Permutation、OptionalArray、BareArrayのTest as Specification整理が完了した時点で、0.5.1の
  製品上の到達範囲を決め、release工程へ進むか判断できる状態にする。
- Permutationの利用者向け文書ドラフトを、公開契約と品質評価に接続し、ユーザーが本文をレビューできる
  状態にする。公開可能な初版の完成はこのゴールに含めない。
- OptionalArrayの利用者向け文書ドラフトを、公開契約と品質評価に接続し、ユーザーが本文をレビューできる
  状態にする。公開可能な初版の完成はこのゴールに含めない。
- BareArrayの利用者向け文書ドラフトを、監査で確定した公開契約に接続し、ユーザーが本文をレビューできる
  状態にする。公開可能な初版の完成はこのゴールに含めない。
- 三対象の文書ドラフト作業を通じて作業方式を習熟した後、RedBlackTreeに見えていない残作業を確認し、
  Codexのユーザードキュメント作業フェーズへ渡せる状態にする。
- 全公開対象のコメントドックについて、公開契約に接続したドラフトが揃った時点で、0.5.2の製品上の
  到達範囲を決め、release工程へ進むか判断できる状態にする。
- 全公開対象の利用者向けドキュメントが公開可能な初版として揃った時点で、0.6.0の製品上の到達範囲を
  決め、release工程へ進むか判断できる状態にする。
- ユーザードキュメント作業後、OptionalArrayのISO/IEC 25010観点の品質評価を再評価し、
  1.0判断前に解消する不足をtaskへ分離できる状態にする。
- 再評価後、OptionalArrayを1.0として採用できるか判断可能な状態にする。
- BareArrayのユーザードキュメント作業後、性能基準、View寿命、storage再設計、strict memory safetyを
  再評価し、BareArrayを1.0として採用できるか判断可能な状態にする。
- RedBlackTreeのユーザードキュメント作業後、汎用基盤ライブラリの1.0として採用できるか判断可能な
  状態にする。この段階でruntime-check実装を再審査し、その結論とIndex契約を1.0品質ゲートへ渡す。
- 1.0 release後、Swift Package Indexへpackageを登録し、module別DocCの生成を確認する。登録後にSPIが提供する
  互換性badgeとmodule別API referenceへの導線をREADMEまたはPagesへ接続する。
- 保留中の運用playbookをユーザー指示で再開した後、このrepositoryで得たtask運用知見を、
  別projectでもCodexが同程度の管理品質を再現できる移植可能な形へ整理する。

**遠い将来の目標候補:**

- 1.0 releaseより後の段階で、対象judgeが必要なSwift toolchainを採用した場合、Permutationを含む
  現行版の競技環境向け構成、性能、単一file経路、および実提出を検証し、judge搭載を目指す。
  現在の中間ゴールとの依存関係、着手順、および具体的な受入条件はまだ定めない。

中間ゴールは、複数taskをまたぐ現在の到達点をカンバン上で共有し、着手可能なtaskから何を優先するかを
判断するために使う。taskそのものではないためIDや状態は持たず、Task Registryの状態、担当、依存、
再開条件を上書きしない。特に、中間ゴールに含まれることだけを理由に`FROZEN`または`USER_ONLY`のtaskを
開始しない。達成または方針変更時は、ユーザーの指示に基づいて現在の中間ゴールを更新する。

task出しでは、複数のユーザー判断を一つのtaskへ束ねない。ユーザー判断を含むtaskは判断点を一つだけ
明示し、ノー判断taskは方針と境界が確定済みの実装、検証、または事実確認だけを含める。実行中に新しい
判断点が見つかった場合、agentは自分で埋めて実装を続けず、現在taskを止めてtask分割へ戻す。

taskを新規登録または次に更新するときは、項目名の先頭へ次の種別を明記する。既存taskは一括で
推測分類せず、再開または内容更新の時点で分類する。

- `DECISION`: ユーザー判断を一つだけ閉じ、結論を後続taskの入力にする。
- `EXECUTION`: 必要な判断がすべて確定済みで、実装、文書反映、または検証を行う。
- `DISCOVERY`: 事実、選択肢、依存、判断task候補を発見する。公開契約や実装方針は確定しない。

三種は同じtask graphのnodeとして扱い、Task precedenceの必須依存を使ってトポロジカルに着手可能性を
判定する。`DISCOVERY`が新しい判断点を見つけた場合は、一判断ごとの`DECISION`へ分ける。その結論を
必要とする`EXECUTION`は、対応する`DECISION`を前提taskにする。soft orderは同時に着手可能なnode間の
推奨順にだけ使い、必須依存へ読み替えない。

次の判断は今回の作業taskへ含めない。必要になった時点でユーザーと別途決定する。

- 利用者向け文書の形（Markdown、DocC、documentation commentのみのいずれにするか）
- 性能の数値を利用者向け文書へ掲載するか
- 1.0ゲート（`QUALITY-001`）との境界
- RedBlackTreeのデバッグ用memberを`#if DEBUG`へ揃えるか

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `RBT-001` | `WAITING_EXTERNAL` | User / Codex | Index完了ゲート | 公開Index表現・完了範囲と`Comparable`採否を確定し、Index契約全体を閉じる | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-010` | `WAITING_EXTERNAL` | User / Codex | Index完了ゲートのうち公開Index表現と完了範囲 | Container要件の安定後、公開Indexと内部`SealError`の分離、1.0での完了範囲を決定 | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-011` | `WAITING_EXTERNAL` | User / Codex | Indexの`Comparable`採否 | `swift-collections`の要件が安定または正式化した後、互換性を再評価して決定 | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` |
| `GRAPH-001` | `ACTIVE` | Claude | Claude用task graph DBの独立試験 | ready判定を維持する常設nodeとして`ACTIVE`を保つ。個別assignmentや実行中ジョブを意味せず、必要なときだけ現行Registryとの一致を確認 | `Graph/TASK_GRAPH_DB_EXPERIMENT.md` |
| `OPS-001` | `FROZEN` | Codex | [DISCOVERY] Codex task運用playbookの移植可能化 | 2026-10-08、ユーザー指示により保留。明示的な再開指示後、当時のV2による試行目的と現行V3への更新要否を再確認して再現性検証へ進む。完成済みRegistryを移植する旧templateは2026-10-13に履歴化 | `Archived/Orientation/CODEX_TASK_OPERATION_PLAYBOOK_V2.md` / `Orientation/CODEX_TASK_OPERATION_PLAYBOOK_V3.md` / `Archived/Orientation/PROGRESS_OVERVIEW_TEMPLATE.md` |
| `OPS-028` | `WAITING_USER` | Codex | [EXECUTION] 作業Codex用ブートストラップの作成 | 固定bootstrapとtask契約templateの未採用初稿を作成し、独立レビューで読み取り、operation権限、workspace、返却経路、実証境界の修正点を抽出。ユーザーレビュー後に候補を再構成する | `Orientation/WORKER_CODEX_BOOTSTRAP_TASK.md` / `Orientation/WORKER_CODEX_BOOTSTRAP.md` / `Orientation/WORKER_CODEX_TASK_CONTRACT_TEMPLATE.md` |
| `OPS-030` | `USER_ONLY` | User | [DECISION] 作業Codex用ブートストラップ候補のレビュー | 任意の時点で未採用初稿とレビュー論点を読み、Codexが候補を再構成してよいか、追加または変更する設計意図があるかを一つのレビュー結果として返す。AIは着手・代行・催促しない | `Orientation/WORKER_CODEX_BOOTSTRAP_TASK.md` / `Orientation/WORKER_CODEX_BOOTSTRAP.md` / `Orientation/WORKER_CODEX_TASK_CONTRACT_TEMPLATE.md` |
| `RELEASE-020` | `FROZEN` | Codex | [EXECUTION] 0.6.0でGitHub Pages更新元をrelease tagへ一本化 | 0.5.xではmain pushとrelease tag pushの双方によるdeploy競合を許容。0.6.0のrelease工程でmain由来のdeployを停止し、tag commitから生成・検証した利用者向け文書だけがPagesを更新することを確認 | `RELEASE_0_6_0.md` |
| `RELEASE-072` | `USER_ONLY` | User | [EXECUTION] 人間向けリリース工程表の作成 | ユーザーがゴールを定め、人間だけでも現在位置、次の操作、完了証拠、停止点を追える一枚の工程表を作成する。0.5.xで実際に使って観測し、0.6.xで磨く。AIは開始、代行、催促を行わず、依頼された場合だけ整理・レビューを補助する | `User/RELEASE_PROCESS.md` |
| `RELEASE-075` | `USER_ONLY` | User | [EXECUTION] リリース工程の不足仕様充当 | ユーザーが、定義した品質要求に対して不足する工程仕様、判定基準、証拠取得方法、停止・復旧手順を補い、V&V可能な状態にする。AIは開始、代行、催促を行わず、依頼された場合だけ整理・レビューを補助する | `User/RELEASE_PROCESS.md` |
| `RELEASE-076` | `USER_ONLY` | User | [EXECUTION] リリース工程のValidation & Verification | ユーザーが、充当後の工程仕様について、定義した品質要求を満たすことと、意図したリリース目的に適合することを確認する。AIは開始、代行、催促を行わず、依頼された場合だけ検証・レビューを補助する | `User/RELEASE_PROCESS.md` |
| `DOC-010` | `FROZEN` | Codex | [DISCOVERY] BareArrayの定性的性能表現の再検討 | 2026-10-09、比較対象はSwiftの`[[Element]]`であり、COWと連鎖subscriptによる深刻な性能劣化を単一連続storageと非所有Viewで迂回する設計意図があると確認。アンカリングを避けるため、ユーザー指示による再訪まで文言判断を保留 | `Archived/Canonical/RELEASE_0_5_2.md` / `BareArrayModule/BareArrayAudit.md` |
| `DOC-026` | `FROZEN` | User / Codex | [EXECUTION] Swift Package Indexへのpackage登録 | 1.0 release後にユーザーが明示的に再開し、公式PackageListへ`https://github.com/narumij/swift-ac-collections.git`を追加する外部PRを準備・提出して、package pageとmodule別DocC build結果を確認する | `DOCUMENTATION_CI_PLAN.md` / `Package.swift` |
| `DOC-027` | `FROZEN` | Codex | [EXECUTION] Swift Package Index公開導線のREADME・Pages反映 | `DOC-026`完了後、SPI package pageの`Do you maintain this package?`が提示するMarkdownを正として互換性badgeをREADMEへ追加し、確認できたmodule別DocC URLへの導線をREADMEまたはPagesへ接続する | `DOCUMENTATION_CI_PLAN.md` / `README.md` |
| `RELEASE-007` | `FROZEN` | User / Codex | [DECISION] 0.6.0の到達範囲とrelease検討開始 | 全公開対象の利用者向けドキュメント初版完成後、0.6.0へ含める到達範囲を一つに定め、release工程へ進むか判断 | `RELEASE_0_6_0.md` |
| `RBT-014` | `FROZEN` | Codex | RedBlackTree文書workflowと4型outlineのAPI照合 | Permutation、OptionalArray、BareArrayのユーザードキュメント作業で方式を習熟した後、ユーザーが再開。workflowと4公開型のoutlineを現在のAPI、test、設計資料と照合し、本文作成へ渡せる状態を確認 | `Sources/RedBlackTreeCollections/Documentation/Head/DOCUMENTATION_WORKFLOW.md` |
| `RBT-032` | `FROZEN` | Codex | [DISCOVERY] RedBlackTree 0.6.0現行品質アセスメント | 2026-10-13、Codex復旧中の中断taskとして凍結。ユーザーの明示的な再開指示後、既存の試験結果と不足する再現証拠を照合してから継続する | `RedBlackTreeModule/CurrentQualityAssessment.md` |
| `RBT-033` | `PROPOSED` | Codex | [DISCOVERY] macOS ASan＋Swift Testing Death Test実行経路の成立確認 | lifetime balance検査をtraitで除外しても子プロセスでASan runtimeが遅延ロードされる事象について、Swift Testing実行基盤、macOS環境、Linux CIとの差を切り分け、製品不具合と検証経路不成立を区別する | `RedBlackTreeModule/CurrentQualityAssessment.md` / `Package.swift` |
| `RBT-034` | `FROZEN` | User / Codex | [EXECUTION] RedBlackTree 1.0品質アセスメント完成 | 1.0品質ゲートの再開後、再現可能な証拠一式を備え、要求・主張・反証・未検証領域・残余リスクを接続した品質アセスメントを完成させる | `RedBlackTreeModule/CurrentQualityAssessment.md` / `Sources/RedBlackTreeCollections/Documentation/Quality-Profile.md` |
| `RBT-035` | `FROZEN` | Claude / Codex | [DISCOVERY] RedBlackTreeチューニングの落ち穂拾い | ユーザーの明示的な再開指示後、過去の実装・benchmark・Git履歴・チューニング記録を現行コードと照合し、取りこぼした改善候補、未反映の知見、再検証が必要な仮説を発見する。性能変更は行わず、実測と判断が必要な後続taskへ分離する | `RedBlackTreeModule/CurrentQualityAssessment.md` / `Sources/RedBlackTreeCollections/Documentation/Quality-Profile.md` / `Benchmarks/` |
| `RBT-026` | `FROZEN` | User / Codex | [DECISION] Mapped Values ViewのO(1)範囲契約再検討 | 利用者向け文書作業フェーズで、View外だがbase treeでは有効なIndexを黙って読み書きし得る性質を踏まえ、O(1)と呼び出し側事前条件の現行契約を維持するか一つだけ再判断 | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-004` | `FROZEN` | Codex | Debug限定Comparable群・Balanced群 | Index契約またはexecutable API Matrix方針の確定後 | `EXTERNAL_TYPE_EXTENSION_AUDIT.md` |
| `RBT-005` | `FROZEN` | Codex | Memoize群の公開終了／正式API化 | 外部consumer 2件の移行後 | `EXTERNAL_TYPE_EXTENSION_AUDIT.md` |
| `PERM-041` | `PROPOSED` | Codex | [DISCOVERY] Permutation一般Swift利用Validation scenario設計 | 代表利用者、SwiftPM・facade経路、利用課題、類似APIとの選択、観測方法を整理し、一般Swift開発への適合を判断できるscenarioと必要な後続候補を提示する | `PermutationModule/CurrentQualityAssessment.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` |
| `PERM-043` | `FROZEN` | User | [DECISION] C++標準に匹敵すると判定する性能比の上限 | 2026-10-11、ユーザー指示により比較水準の判断を保留。明示的な再開指示後、28要素中7要素を選ぶ最大ケースでSwiftの全体処理時間を`std::next_permutation`の何倍以内なら「匹敵」と受け入れるか一つだけ決定する | `PermutationModule/CurrentQualityAssessment.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` |
| `PERM-044` | `FROZEN` | Codex | [EXECUTION] Permutation外部性能アセスメントの実測・判定 | 2026-10-11、比較水準の判断とともにユーザー指示で保留。`PERM-043`の明示的な再開・完了後、macOS上で専用scriptを実行し、環境情報、生JSON、PNG chartを保存して判定する | `PermutationModule/CurrentQualityAssessment.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` |
| `PERM-046` | `FROZEN` | Codex | [DISCOVERY] Swift 6.2向けmanifest構成の必要性再評価 | runtime-check View通常版がSwift 6.2で成立したため、旧「PermutationModuleなしの縮小manifest」案はそのまま実行しない。ユーザーの明示的な再開指示後、package全体の6.2成立条件を調べ、version-specific manifest自体が必要かから再評価する | `PermutationModule/CurrentQualityAssessment.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` |
| `PERM-051` | `FROZEN` | Claude | [EXECUTION] borrowed Span版PermutationのTest as Specification | runtime仕様test 25件を受け入れ、2026-10-13にも対象25件成功を再確認。一時clientによるcompile-pass／compile-fail結果は返却記録にあるが、repository内の再実行可能なfixtureではないため、ユーザーの明示的な再開まで残作業を凍結 | `PermutationModule/BorrowedPermutationTestPlan.md` / `Sources/PermutationModule/BorrowedNextPermutations.swift` / `Tests/PermutationTests/BorrowedNextPermutations/` |
| `PERM-052` | `DONE` | Codex / Claude | [DISCOVERY] runtime-check View版Permutationの現行Test as Specification再構成 | 現行runtime-check契約とborrowed版を分離し、旧38関数をG0〜G5またはRETIREDへ一度ずつ分類。判断不要な後続4単位と受入境界を確定 | `PermutationModule/RuntimeCheckedPermutationTestPlan.md` / `PermutationModule/CurrentQualityAssessment.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` / `Tests/PermutationTests/EtcTests.swift` |
| `PERM-053` | `DONE` | Claude / Codex | [EXECUTION] runtime-check Permutation列挙・Collection仕様test | G1列挙12件、G3 Collection 6件、範囲外Death Test 5件を追加し、包含された手動scratch 1件を削除。ClaudeのDebug／Release各24件成功に加え、CodexがXcodeで対象24件の成功を独立確認 | `PermutationModule/RuntimeCheckedPermutationTestPlan.md` |
| `PERM-054` | `DONE` | Claude / Codex | [EXECUTION] runtime-check Permutation View失効Death Test | G2のpositive control 1件とDeath Test 9件を追加し、旧scratch 2件をexact signal契約へ昇格。ClaudeのDebug／Release各33件成功に加え、CodexがXcodeで対象33件の成功を独立確認 | `PermutationModule/RuntimeCheckedPermutationTestPlan.md` |
| `PERM-055` | `DONE` | Claude / Codex | [EXECUTION] runtime-check Permutation所有・破棄仕様test | G4の内部仕様test 7件を追加し、source独立性、4破棄経路、奇数suffix反転、escaped Viewとstorage寿命の分離を固定。ClaudeのDebug／Release各40件成功に加え、CodexがXcodeで累積40件の成功を独立確認 | `PermutationModule/RuntimeCheckedPermutationTestPlan.md` |
| `PERM-056` | `DONE` | Claude / Codex | [EXECUTION] runtime-check Permutation公開表面・共存仕様test | G0／G5のruntime 5件とcompiler fixture 4経路を追加。ClaudeのDebug／Release成功に加え、CodexがXcode 44件、AcCollections再公開1件、compile-pass 1件・compile-fail 3件を独立確認 | `PermutationModule/RuntimeCheckedPermutationTestPlan.md` |
| `PERM-057` | `DONE` | Codex | [EXECUTION] Permutation品質正本の現在性同期 | G0〜G5、独立検収、CI greenをQuality ProfileとCurrent Quality Assessmentへ反映し、旧COW版38件と再構築前の記述を現行評価から分離 | `PermutationModule/CurrentQualityAssessment.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` / `PermutationModule/RuntimeCheckedPermutationTestPlan.md` |
| `PERM-058` | `DONE` | Codex | [EXECUTION] Permutation利用者向け文書本文ドラフト | 公開媒体を決めず、公開契約と現行品質評価に接続した内部本文ドラフトを作成し、2026-10-13にユーザーが本文を受入 | `PermutationModule/UserDocumentationDraft.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` / `PermutationModule/CurrentQualityAssessment.md` |
| `PERM-059` | `PROPOSED` | Codex / Claude | [DISCOVERY] Tests側NextPermutations Sequence化試験実装 | productionと公開APIを変更せず、Tests内のadapterでruntime-check版`NextPermutations`を`Sequence`として扱う試験実装を作り、列挙契約、View寿命、所有権、copyの発生、性能差を観測する。採用可否は決めず、結果と判断候補を別taskへ返す | `PermutationModule/CurrentQualityAssessment.md` / `PermutationModule/RuntimeCheckedPermutationTestPlan.md` / `Tests/PermutationTests/` |
| `OPT-006` | `FROZEN` | Codex | [DISCOVERY] OptionalArray品質評価の文書作業後レビュー | `OPT-005`とユーザードキュメント作業の完了後に再評価し、1.0判断前に解消する不足を独立task候補へ分離 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-044` | `FROZEN` | User | [DECISION] OptionalArray 1D所有型名の再判断 | 0.6.0の到達範囲判断前に、`OptionalArray1D`を維持するか、AI間で整理した選択肢から一つ判断。0.5.2のコメントドック作業は現行名で先行する | `OptionalArrayModule/OptionalArrayAudit.md` / `RELEASE_0_6_0.md` |
| `OPT-045` | `FROZEN` | User | [DECISION] OptionalArray次元名体系の再判断 | 0.6.0の到達範囲判断前に、2D・3Dの意味名と4Dの`size0`〜`size3`を維持するか、AI間で整理した選択肢から一つ判断。0.5.2のコメントドック作業は現行名で先行する | `OptionalArrayModule/OptionalArrayAudit.md` / `RELEASE_0_6_0.md` |
| `OPT-048` | `DONE` | Codex | [DISCOVERY] OptionalArray現行APIの公開安全性分類・strict安全性の依存分解 | 現行40診断を再取得し、所有4型の分類4件、allocation境界8件、deprecated View経路28件へ分離。現行API側12件は`@safe`分類とscoped `unsafe`で解消でき、製品判断を要しないと確定 | `OptionalArrayModule/CurrentQualityAssessment.md` / `StrictMemorySafetyReadiness.md` |
| `OPT-055` | `DONE` | Codex | [EXECUTION] OptionalArray strict memory safety恒久適用 | 所有4型を`@safe`に分類し、現行APIとdeprecated Viewの低レベル操作をscoped `unsafe`へ限定して`.strictMemorySafety()`を恒久適用。単独strict診断0件、Build for Testing成功、全65 test成功 | `OptionalArrayModule/CurrentQualityAssessment.md` / `StrictMemorySafetyReadiness.md` |
| `OPT-056` | `DONE` | Codex | [DISCOVERY] OptionalArray現行座標accessのTest as Specification監査 | 現行direct methodは各次元1座標の正常系だけで、非対称shape全座標、各軸の負値・上限trap、direct `setElement`の参照要素寿命が不足すると確定。deprecated互換testと分離した後続を登録 | `OptionalArrayModule/CurrentQualityAssessment.md` / `Tests/OptionalArrayModuleTests/` |
| `OPT-057` | `DONE` | Codex | [EXECUTION] OptionalArray座標access Test as Specification | 1D〜4Dの非対称shape全座標、選択位置だけの更新、値・nil遷移と参照要素のexactly-once破棄、全軸の負値・上限に対するread/write trapを現行`element`／`setElement`で固定。Build for Testing成功、追加11件を含む全76 test成功 | `OptionalArrayModule/CurrentQualityAssessment.md` / `Tests/OptionalArrayModuleTests/` |
| `OPT-060` | `DONE` | Codex | [EXECUTION] OptionalArray deprecated公開面の削除 | 所有1D〜4Dの連鎖subscriptと非所有View 3型を削除し、test・EDPC例・benchmark・facade testを座標accessへ移行。View固有仕様を退役。Xcode Build for Testing、OptionalArray全56 test、benchmark package build成功 | `Sources/OptionalArrayModule/OptinalArray.swift` / `Tests/OptionalArrayModuleTests/` / `Benchmarks/Sources/Benchmarks/OptionalArrayBenchmarks.swift` |
| `OPT-058` | `DONE` | Codex | [EXECUTION] OptionalArray品質正本の現在性同期 | 座標accessだけになった公開面、strict memory safety、削除後の全56 testをQuality Profile・現行評価・監査へ反映し、旧29宣言監査を履歴入力として分離 | `OptionalArrayModule/OptionalArrayAudit.md` / `OptionalArrayModule/CurrentQualityAssessment.md` / `Sources/OptionalArrayModule/Documentation/Quality-Profile.md` |
| `OPT-059` | `PROPOSED` | Codex | [EXECUTION] OptionalArray利用者向け文書本文ドラフト | `OPT-058`完了後、現行名と座標accessだけを使う媒体未決定の本文をユーザーがレビューできる状態にする | `OptionalArrayModule/OptionalArrayAudit.md` / `OptionalArrayModule/CurrentQualityAssessment.md` / `Sources/OptionalArrayModule/Documentation/Quality-Profile.md` |
| `OPT-053` | `FROZEN` | User | [DECISION] OptionalArrayがC++番兵手法に匹敵すると判定する性能比の上限 | `OPT-052`の暫定実測後、代表memoization workloadで許容する性能比を一つだけ決定する | `OptionalArrayModule/CurrentQualityAssessment.md` / `Sources/OptionalArrayModule/Documentation/Quality-Profile.md` |
| `OPT-054` | `FROZEN` | Codex | [EXECUTION] OptionalArray外部性能アセスメントの実測・判定 | `OPT-053`完了後、macOS上で正式測定し、環境情報、生JSON、PNG chart、判定を保存する | `OptionalArrayModule/CurrentQualityAssessment.md` / `Sources/OptionalArrayModule/Documentation/Quality-Profile.md` |
| `ARRAY-005` | `WAITING_USER` | User | [DECISION] Always-initialized Array owner base名 | 三者採点の相対的な首位が`BareElements`、`ElementBuffer`、`BareArray`へ分かれた。将来の製品包含とは分離し、互換性、役割精度、Arrayの値semantics期待を比較して一つを判断する | `PUBLIC_API_NAMING_SCORE_REPORT.md` / `PUBLIC_API_NAMING_DECISIONS.md` / `ArrayObjectAndAPINamingDraft.md` |
| `ARRAY-006` | `WAITING_USER` | User | [DECISION] Array系copied value access名 | ユーザーは`value`系、両AIは現行`element`系を相対的に高く評価。reference elementの同一性、call-site、移行費用を比較してread/write語彙を判断する | `PUBLIC_API_NAMING_SCORE_REPORT.md` / `PUBLIC_API_NAMING_DECISIONS.md` / `ArrayObjectAndAPINamingDraft.md` |
| `ARRAY-009` | `WAITING_USER` | User | [DECISION] Presence-tracked Array owner base名 | ユーザーは`OptionalCache`、Codexはstate-model名、Claudeは`OptionalArray`・`SlotArray`・`MemoTable`を相対的に高く評価。memoization用途、storage状態、互換性のどれを公開identityにするか判断する | `PUBLIC_API_NAMING_SCORE_REPORT.md` / `PUBLIC_API_NAMING_DECISIONS.md` / `ArrayObjectAndAPINamingDraft.md` |
| `ARRAY-010` | `WAITING_USER` | User | [DECISION] Array owner 1D suffix規則 | ユーザーはunsuffixed統一を強く低評価し、explicit `1D`と現行非対称を同点評価。両AIはunsuffixed統一を高評価したため、ユーザーの命名原則を確認して判断する | `PUBLIC_API_NAMING_SCORE_REPORT.md` / `PUBLIC_API_NAMING_DECISIONS.md` / `ArrayObjectAndAPINamingDraft.md` |
| `ARRAY-011` | `WAITING_USER` | User | [DECISION] BareArray borrowed-reference method名 | ユーザーは3候補を同点、Codexは明示的代替、Claudeは現行`reference`を相対的に高く評価。method名にmutabilityとresult kindのどちらを表すか判断する | `PUBLIC_API_NAMING_SCORE_REPORT.md` / `PUBLIC_API_NAMING_DECISIONS.md` / `ArrayObjectAndAPINamingDraft.md` |
| `ARRAY-012` | `WAITING_USER` | User | [DECISION] BareArray borrowed-reference result type名 | 三者の相対評価ではdirect `MutableRef`が首位。`Reference` aliasの互換性費用と二重名を比較し、alias維持・deprecate・直接削除を含め判断する | `PUBLIC_API_NAMING_SCORE_REPORT.md` / `PUBLIC_API_NAMING_DECISIONS.md` / `ArrayObjectAndAPINamingDraft.md` |
| `ARRAY-013` | `WAITING_USER` | User | [DECISION] BareArray borrowed-reference property名 | ユーザーとClaudeは`pointee`／`value`を同点、Codexは`pointee`を高評価。pointer/reference精度と親しみやすさのどちらを優先するか判断する | `PUBLIC_API_NAMING_SCORE_REPORT.md` / `PUBLIC_API_NAMING_DECISIONS.md` / `ArrayObjectAndAPINamingDraft.md` |
| `ARRAY-008` | `DONE` | Codex | [DISCOVERY] Array命名候補の現行公開面への再整理 | 三者の提出をowner二family、1D suffix、値access、借用参照へ分解。削除済みView・subscript、closure化、API追加、製品除外を命名ballotから分離し、現行source・品質正本に照合した補足候補を追加 | `ArrayObjectAndAPINamingDraft.md` / `PUBLIC_API_NAMING_CANDIDATES_CODEX.md` |
| `ARRAY-007` | `FROZEN` | Codex | [EXECUTION] Array系object・API命名の実装反映 | 7つの公開名判断完了後、ユーザーが明示的に再開し、判断正本を入力にproduction、test、benchmark、文書を決定どおりに更新してTest as SpecificationとCI baseline準備へ渡す | `PUBLIC_API_NAMING_DECISIONS.md` / `ArrayObjectAndAPINamingDraft.md` |
| `API-002` | `DONE` | Codex / Claude / User | [DECISION] Public API名ballotの編成・検証 | Claudeの独立検査を受入れ、帰属、BareArray限定scope、後続候補の所在を修正。ユーザーがreview-informed Codex supplement 4件の同一ballotへの包含を承認し、採点用ballotを固定した | `PUBLIC_API_NAMING_BALLOT.md` / `PUBLIC_API_NAMING_CANDIDATES_USER.md` / `PUBLIC_API_NAMING_CANDIDATES_CODEX.md` / `PUBLIC_API_NAMING_CANDIDATES_CLAUDE.md` |
| `API-004` | `DONE` | User | [EXECUTION] Public API名ballotのユーザー独立採点 | ユーザーが固定ballot全29候補へ1〜10の総合点を記録。CodexとClaudeの採点を読む前の独立提出としてCodexが件数と点数範囲を検収した | `PUBLIC_API_NAMING_SCORE_USER.md` / `PUBLIC_API_NAMING_BALLOT.md` |
| `API-005` | `DONE` | Codex | [EXECUTION] Public API名ballotのCodex独立採点 | ユーザーの開始承認後、CodexがUser・Claudeのscore recordを読まず、固定ballot全候補へ総合点、理由、重要な懸念を記録した | `PUBLIC_API_NAMING_SCORE_CODEX.md` / `PUBLIC_API_NAMING_BALLOT.md` |
| `API-006` | `DONE` | Claude | [EXECUTION] Public API名ballotのClaude独立採点 | ClaudeがUser・Codexのscore recordを読まず、固定ballot全29候補へ総合点、理由、重要な懸念を記録。Codexが件数、点数範囲、説明欄を検収した | `PUBLIC_API_NAMING_SCORE_CLAUDE.md` / `PUBLIC_API_NAMING_BALLOT.md` |
| `API-007` | `DONE` | Codex | [DISCOVERY] Public API名採点の統合報告と判断task分解 | 三者29候補のraw scoreを改変せず統合。尺度差を明記し、平均・多数決を採用判断にせず、合意、衝突、未解決事実を7つの公開名判断へ分解した | `PUBLIC_API_NAMING_SCORE_REPORT.md` / `PUBLIC_API_NAMING_DECISIONS.md` / `PUBLIC_API_NAMING_SCORE_USER.md` / `PUBLIC_API_NAMING_SCORE_CODEX.md` / `PUBLIC_API_NAMING_SCORE_CLAUDE.md` |
| `BARE-007` | `FROZEN` | Codex | [EXECUTION] BareArray外部性能アセスメントの実測・判定 | 性能比の受入判断後、macOS上で正式測定し、環境情報、生JSON、PNG chart、判定を保存する | `BareArrayModule/CurrentQualityAssessment.md` / `Sources/BareArrayModule/Documentation/Quality-Profile.md` |
| `BARE-032` | `FROZEN` | User | [DECISION] BareArrayがC++ nested vectorに匹敵すると判定する性能比の上限 | `BARE-031`の暫定実測後、代表多次元access workloadで許容する性能比を一つだけ決定する | `BareArrayModule/CurrentQualityAssessment.md` / `Sources/BareArrayModule/Documentation/Quality-Profile.md` |
| `BARE-035` | `PROPOSED` | Codex | [DISCOVERY] BareArray提供停止の実施境界整理 | package、facade、文書、移行、release、既存利用への影響を確認し、提供停止を局所的に実施できるtaskへ分解する | `Sources/BareArrayModule/Documentation/Quality-Profile.md` / `Package.swift` |
| `BARE-036` | `DONE` | Codex | [EXECUTION] BareArray deprecated公開面の削除 | 所有1D〜4Dの連鎖subscriptと非所有View 3型を削除し、test・benchmark・compiler fixture・品質文書を座標accessと`reference(at:)`／`MutableRef`へ移行。SwiftPMの現行60 test、MutableRef compiler diagnostics、benchmark package buildが成功 | `Sources/BareArrayModule/BareArray.swift` / `Tests/BareArrayModuleTests/` / `Benchmarks/Sources/Benchmarks/BareArrayBenchmarks.swift` |
| `BARE-039` | `DONE` | Claude / Codex | [DISCOVERY] OptionalArray／BareArray deprecated公開面削除後の独立目視検査 | Claudeが旧公開面の残存と現行座標access・借用参照経路を横断確認。Quality Profileに残った存在しない`mutable`表記をCodexが修正し、旧fixtureの空directoryを除去して受け入れた | `Maintanance/CLAUDE_TASK.md` / `Sources/BareArrayModule/Documentation/Quality-Profile.md` |
| `BARE-017` | `PROPOSED` | Codex | [DISCOVERY] BareArray利用Validation scenario設計 | 一般Swift利用と競技利用について、代表利用者、導入経路、利用課題、観測方法を整理し、異なる判断・実行境界を後続task候補へ分離する | `BareArrayModule/CurrentQualityAssessment.md` / `Sources/BareArrayModule/Documentation/Quality-Profile.md` |
| `RBT-007` | `FROZEN` | User / Codex | RedBlackTreeCollectionsのstrict memory safety全面適用 | ユーザーが段階3を承認 | `StrictMemorySafetyReadiness.md` |
| `RBT-008` | `FROZEN` | User / Codex | `lazyDetach`等の並行初期化保証 | concurrency契約を扱う明示的な再開指示 | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` |
| `HIST-001` | `FROZEN` | V3オーサー | [DISCOVERY] AtCoder 2025移行史 | 2026-10-13、現時点の整理を一段落として凍結。ユーザーの明示的な再開指示後、本紙の説明または証拠別紙へ追加する必要がある範囲だけを再開する | `RefactoringFromAtCoder2025/README.md` / `RefactoringFromAtCoder2025/EVIDENCE.md` |
| `RBT-009` | `FROZEN` | User / Codex | [DECISION] runtime-check実装の再審査 | ユーザードキュメント作業後、1.0中間ゴールへ移行した時点、または`-Ounchecked`が主要構成と判明した時点で再開し、現行実装を1.0へ採用するか一つだけ判断 | `Sources/RedBlackTreeCollections/Documentation/Design/Design-RuntimeChecks.md` |
| `QUALITY-001` | `FROZEN` | User / Codex | 汎用基盤ライブラリとしての1.0採用品質ゲート | Index契約確定後、ユーザーが明示的に再開 | `Sources/RedBlackTreeCollections/Documentation/Quality-Profile.md` |
| `QUALITY-002` | `FROZEN` | Codex | [EXECUTION] 1.0品質保証CIの構成・証拠化 | 1.0品質ゲートの再開後、Ubuntu 24.04 LTS / x86_64のGitHub-hosted runnerで合意済みの品質試験を実行し、commit、workflow run、runner image、kernel、architecture、CPU、Swift、依存解決、選択試験、完全log、終了statusを証拠として残す。変動するrunner上の絶対性能は判定対象に含めない | `QUALITY_REQUIREMENTS.md` / `Tests/TESTING.md` / `.github/workflows/candidate.yml` |
| `QUALITY-003` | `FROZEN` | Codex | [EXECUTION] Apple platforms 27提供境界のmanifest反映・build確認 | 1.0品質ゲートの再開後、対象Apple platformごとの最低deployment versionをmanifestへ反映し、64-bitのplatform別build・導入経路を確認する。macOS 27 / arm64以外はbuild証拠と実行品質を区別する | `QUALITY_REQUIREMENTS.md` / `Package.swift` |

## Task precedence

| 後続task | 前提task | Flow | 制約 |
| --- | --- | --- | --- |
| `RBT-001` | `RBT-010` | `PARALLEL_JOIN` | 公開Index表現・完了範囲の判断は、Comparable採否と分離したまま親ゲートの完了前に合流する |
| `RBT-001` | `RBT-011` | `PARALLEL_JOIN` | Comparable採否の外部依存は判断task側に残し、親ゲートの完了前に合流する |
| `QUALITY-001` | `RBT-001` | `PARALLEL_JOIN` | 品質調査は並行できるが、1.0品質判定を確定する前にIndex契約完了と合流する |
| `QUALITY-001` | `RBT-009` | `PARALLEL_JOIN` | 他の1.0品質作業は並行できるが、最終判定前にruntime-check実装の採否と合流する |
| `QUALITY-001` | `RBT-034` | `PARALLEL_JOIN` | 1.0採用品質を判定する前に、再現可能な証拠を備えた品質アセスメントの完成と合流する |
| `QUALITY-001` | `QUALITY-002` | `PARALLEL_JOIN` | 1.0採用品質を判定する前に、Linux代表環境の品質保証CIと再現可能な実行証拠を合流する |
| `QUALITY-001` | `QUALITY-003` | `PARALLEL_JOIN` | 1.0採用品質を判定する前に、Apple platforms 27のmanifest境界とplatform別build証拠を合流する |
| `RBT-026` | `RBT-014` | `SEQUENCE` | 現行APIとの照合を判断材料として揃えてからMapped Values契約を再判断する |
| `BARE-007` | `BARE-032` | `SEQUENCE` | 性能比上限の決定後、正式測定結果へ適用して判定する |
| `OPT-054` | `OPT-053` | `SEQUENCE` | 性能比上限の決定後、正式測定結果へ適用して判定する |
| `PERM-044` | `PERM-043` | `SEQUENCE` | C++標準に匹敵すると判定する性能比上限を確定してから、保存したmacOS測定証拠へ適用する |
| `PERM-053` | `PERM-052` | `SEQUENCE` | 旧38関数の台帳と現行契約の分類確定後、列挙・Collection仕様testを実装する |
| `PERM-054` | `PERM-052` | `SEQUENCE` | runtime失効契約とborrowed契約の分離確定後、View失効Death Testを実装する |
| `PERM-055` | `PERM-052` | `SEQUENCE` | 旧COW内部probeの処遇確定後、現行owned bufferの所有・破棄仕様testを実装する |
| `PERM-056` | `PERM-052` | `SEQUENCE` | 現行公開表面とretired表面の分類確定後、compiler表面・共存・再公開testを実装する |
| `PERM-057` | `PERM-056` | `SEQUENCE` | G0〜G5の実装と独立検収が完了してから、品質正本を現行証拠へ同期する |
| `PERM-058` | `PERM-057` | `SEQUENCE` | 現行契約と証拠へ同期した品質正本を入力に、利用者向け本文を起草する |
| `OPT-058` | `OPT-060` | `SEQUENCE` | deprecated公開面の削除と利用箇所移行を受け入れてから、品質正本を現行表面へ同期する |
| `OPT-059` | `OPT-058` | `SEQUENCE` | 座標accessだけの現行公開面へ同期した品質正本を入力に、利用者向け本文を起草する |
| `API-002` | `ARRAY-008` | `SEQUENCE` | 現行公開面に有効な命名候補と契約変更候補を分離してから固定ballotを編成する |
| `BARE-039` | `BARE-036` | `SEQUENCE` | BareArrayのdeprecated公開面削除と移行が完了してから、残存・誤削除を独立検査する |
| `BARE-039` | `OPT-060` | `SEQUENCE` | OptionalArrayのdeprecated公開面削除と移行が完了してから、残存・誤削除を独立検査する |
| `OPS-028` | `OPS-030` | `SEQUENCE` | ユーザーが未採用初稿とレビュー論点を確認してから、Codexが候補を再構成する |
| `API-004` | `API-002` | `PARALLEL_JOIN` | Codexによるballot編成・検証後、ユーザーが他者から独立して採点する |
| `API-005` | `API-002` | `PARALLEL_JOIN` | Codexによるballot編成・検証後、Codexが他者から独立して採点する |
| `API-006` | `API-002` | `PARALLEL_JOIN` | Codexによるballot編成・検証後、Claudeが他者から独立して採点する |
| `API-007` | `API-004` | `PARALLEL_JOIN` | ユーザー採点の提出後に統合報告へ合流する |
| `API-007` | `API-005` | `PARALLEL_JOIN` | Codex採点の提出後に統合報告へ合流する |
| `API-007` | `API-006` | `PARALLEL_JOIN` | Claude採点の提出後に統合報告へ合流する |
| `ARRAY-005` | `API-007` | `SEQUENCE` | 三者採点の統合報告後にobject名を決定し、判断正本へ記録する |
| `ARRAY-006` | `API-007` | `SEQUENCE` | 三者採点の統合報告後にArray access API familyを決定し、判断正本へ記録する |
| `ARRAY-009` | `API-007` | `SEQUENCE` | 三者採点の統合報告後にpresence-tracked owner名を決定する |
| `ARRAY-010` | `API-007` | `SEQUENCE` | 三者採点の統合報告後に1D suffix規則を決定する |
| `ARRAY-011` | `API-007` | `SEQUENCE` | 三者採点の統合報告後にborrowed-reference method名を決定する |
| `ARRAY-012` | `API-007` | `SEQUENCE` | 三者採点の統合報告後にborrowed-reference result type名を決定する |
| `ARRAY-013` | `API-007` | `SEQUENCE` | 三者採点の統合報告後にborrowed-reference property名を決定する |
| `ARRAY-007` | `ARRAY-005` | `PARALLEL_JOIN` | object名の決定を実装入力にする |
| `ARRAY-007` | `ARRAY-006` | `PARALLEL_JOIN` | method名の決定を実装入力にする |
| `ARRAY-007` | `ARRAY-009` | `PARALLEL_JOIN` | presence-tracked owner名の決定を実装入力にする |
| `ARRAY-007` | `ARRAY-010` | `PARALLEL_JOIN` | 1D suffix規則の決定を実装入力にする |
| `ARRAY-007` | `ARRAY-011` | `PARALLEL_JOIN` | borrowed-reference method名の決定を実装入力にする |
| `ARRAY-007` | `ARRAY-012` | `PARALLEL_JOIN` | borrowed-reference result type名の決定を実装入力にする |
| `ARRAY-007` | `ARRAY-013` | `PARALLEL_JOIN` | borrowed-reference property名の決定を実装入力にする |
| `RELEASE-020` | `RELEASE-007` | `SEQUENCE` | 0.6.0の到達範囲とrelease開始を決定してから、Pages更新元の一本化をrelease工程として実施する |
| `RELEASE-076` | `RELEASE-075` | `SEQUENCE` | 不足仕様を充当して検証可能な工程にしてから、Validation & Verificationを行う |
| `RELEASE-007` | `OPT-044` | `PARALLEL_JOIN` | 利用者向け文書作業は現行名で先行できるが、0.6.0の到達範囲判断前に1D所有型名を確定する |
| `RELEASE-007` | `OPT-045` | `PARALLEL_JOIN` | 利用者向け文書作業は現行名で先行できるが、0.6.0の到達範囲判断前に次元名体系を確定する |
| `DOC-027` | `DOC-026` | `SEQUENCE` | SPI登録と実在するpackage page・module別DocC URLを確認してから、badgeと公開導線をrepositoryへ反映する |

## Registry rules

- 状態は`PROPOSED`、`ACTIVE`、`WAITING_USER`、`WAITING_EXTERNAL`、`FROZEN`、`USER_ONLY`、`EXCLUDED`、`DONE`、`ARCHIVED`のいずれかとする。
- `PROPOSED`は忘失防止のtask候補であり、範囲、完了条件、担当、詳細正本、必須依存を確定して状態を更新するまで着手・委任しない。
- `FROZEN`は明示的な再開指示なしに着手しない。
- `USER_ONLY`はユーザー専任とし、AIは着手、代行、催促を行わない。
- `WAITING_EXTERNAL`は外部条件が解消するまで着手可能とみなさない。
- Task precedenceには内部task間の必須AND前提だけを記録する。
- Task precedenceのFlowは、前提taskの後に後続taskを始める`SEQUENCE`、または並行を許可して
  後続taskの完了前に合流する`PARALLEL_JOIN`のいずれかを必須とする。
- 新規または内容更新したtaskの項目名は、`[DECISION]`、`[EXECUTION]`、`[DISCOVERY]`のいずれかで始める。
- `DECISION`は一つのユーザー判断だけを含む。複数の判断がある場合は登録前または発見時に分割する。
- `EXECUTION`と`DISCOVERY`はノー判断taskとし、未確定の判断をagentが補って完了させない。
- Task Registryの確定更新はCodexが担当する。
- 優先順位は、ユーザーの最新指示、Task Registry、詳細正本、Archivedと過去ログの順とする。
