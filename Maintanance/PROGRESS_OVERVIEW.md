# 開発・メンテナンス進捗一覧

最終更新: 2026-10-11 / Codex

この文書のTask Registryを、CodexとClaudeが作業を再開するときの唯一の入口とする。まずRegistry
だけを読み、選択したtask行が示す詳細正本だけを追加で読む。2026-10-07までの完了チェック、判断待ち、
旧サマリーは`Archived/PROGRESS_OVERVIEW_HISTORY_2026-10-07.md`へ移した。
2026-10-09までの`DONE`・`EXCLUDED` task行と、それらだけに向かう完了済みprecedence辺は
`Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-09.md`へ移した。以後2026-10-11までに完了・除外した行と
充足済みprecedence辺は`Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-11.md`へ移した。
現行Registryには状態が変わり得るtaskだけを残す。

## 正本整理時の配置維持例外

正本整理、役割別のfolder分け、またはArchivedへの移動を行う場合でも、次のMarkdownは現在位置から
移動または改名しない。この表は配置だけの例外を定め、各文書の権限、正本性、内容の更新規則は変更しない。

| Markdown | 現在位置に残す理由 |
| --- | --- |
| `USER_MANAGEMENT_INTERVIEW_CODEX.md` | Codexによるマネジメント継続性の記録 |
| `USER_MANAGEMENT_INTERVIEW_CLAUDE.md` | Claudeによる独立したマネジメント評価の記録 |
| `CLAUDE_OBSERVATIONS.md` | Claude本人の任意の観察を本人の声のまま保持する場所 |
| `CODEX_OBSERVATIONS.md` | Codex本人の任意の観察を本人の声のまま保持する場所 |
| `PROGRESS_OVERVIEW_TEMPLATE.md` | 他projectへのtask運用移植を初めて試みた痕跡として現在位置を保持する |

## Task Registry

**現在の律速:** 外部（`swift-collections` ContainersPreviewの`Container.Index`要件）。
Index契約と関連taskは、この外部条件が安定するまで最終確定できない。

**中間ゴールの取り扱い**

**直近達成した中間ゴール:** 0.5.3を完成させる。

2026-10-10、main merge commit `139ffef8`のCI greenを確認し、annotated tag `0.5.3`を同commitへ作成・pushして
remote到達を確認した。release後の記録用branchとして、同tagから`develop/misc/55`を作成した。

**現在の中間ゴール:** BareArrayとOptionalArrayの競技用途における多次元access性能を、Permutationと
同じBenchmark・CI回帰・macOS外部アセスメントの二層構造で評価可能にする。BareArrayはC++ nested
`vector<T>`、OptionalArrayはC++ nested `vector<T>`の番兵手法を比較対象とし、性能比の受入判断は
暫定実測後まで発生させない。

**凍結中の中間ゴール（前任conversationの残存記録）:**

- 0.5.1の実施結果からrelease checklistの不足を抽出し、Webマージ、main CI、実際のmain commit確認、
  tag作成、tag pushの順序を次回releaseで誤認しない汎用手順へ改訂する。
- `prepare/release/template`をrelease工程のtemplate branchとする方式について、削除規則、release専用test、
  workflow、mainとのmerge境界を設計し、準備完了後のreleaseへ適用できる状態にする。0.5.2には適用しない。

**後続の中間ゴール:**

- Permutation、OptionalArray、BareArrayのTest as Specification整理が完了した時点で、0.5.1の
  製品上の到達範囲を決め、release checklistへ進むか判断できる状態にする。
- Permutationの利用者向け文書ドラフトを、公開契約と品質評価に接続し、ユーザーが本文をレビューできる
  状態にする。公開可能な初版の完成はこのゴールに含めない。
- OptionalArrayの利用者向け文書ドラフトを、公開契約と品質評価に接続し、ユーザーが本文をレビューできる
  状態にする。公開可能な初版の完成はこのゴールに含めない。
- BareArrayの利用者向け文書ドラフトを、監査で確定した公開契約に接続し、ユーザーが本文をレビューできる
  状態にする。公開可能な初版の完成はこのゴールに含めない。
- 三対象の文書ドラフト作業を通じて作業方式を習熟した後、RedBlackTreeに見えていない残作業を確認し、
  Codexのユーザードキュメント作業フェーズへ渡せる状態にする。
- 全公開対象のコメントドックについて、公開契約に接続したドラフトが揃った時点で、0.5.2の製品上の
  到達範囲を決め、release checklistへ進むか判断できる状態にする。
- 全公開対象の利用者向けドキュメントが公開可能な初版として揃った時点で、0.6.0の製品上の到達範囲を
  決め、release checklistへ進むか判断できる状態にする。
- ユーザードキュメント作業後、OptionalArrayのISO/IEC 25010観点の品質評価を再評価し、
  1.0判断前に解消する不足をtaskへ分離できる状態にする。
- 再評価後、OptionalArrayを1.0として採用できるか判断可能な状態にする。
- BareArrayのユーザードキュメント作業後、性能基準、View寿命、storage再設計、strict memory safetyを
  再評価し、BareArrayを1.0として採用できるか判断可能な状態にする。
- RedBlackTreeのユーザードキュメント作業後、汎用基盤ライブラリの1.0として採用できるか判断可能な
  状態にする。この段階でruntime-check実装を再審査し、その結論とIndex契約を1.0品質ゲートへ渡す。
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
| `OPS-001` | `FROZEN` | Codex | [DISCOVERY] Codex task運用playbookの移植可能化 | 2026-10-08、ユーザー指示により保留。明示的な再開指示後、別projectでの再現性検証へ進む | `Orientation/CODEX_TASK_OPERATION_PLAYBOOK.md` / `PROGRESS_OVERVIEW_TEMPLATE.md` |
| `OPS-002` | `USER_ONLY` | User | [DISCOVERY] Codex task運用playbookの改訂 | 分解に長けたconversationの喪失後に生じた再分解・復旧の失敗経験を踏まえ、分解理由、依存、停止点、継承、復元、再構成について本書へ残す内容と表現をユーザーが整理する。AIは開始、代行、催促を行わず、依頼された場合だけ整理・レビュー・文書反映を補助する | `Orientation/CODEX_TASK_OPERATION_PLAYBOOK.md` |
| `OPS-003` | `DONE` | Codex | [EXECUTION] タスク依存変化による作業中停止の明文化 | 実行中も依存関係とreadyを再評価し、新しい必須前提、Flow、完了条件、および委任権限に応じて停止範囲を導く原則を独立文書へ記録 | `Orientation/TASK_DEPENDENCY_RUNTIME_STOP.md` |
| `OPS-004` | `DONE` | Codex | [EXECUTION] タスク分解と再構成の明文化 | 見えない作業から本質的判断を抽出し、task境界、依存、Flow、ready集合、優先順を再構成する原則を独立文書へ記録し、ユーザー指示により完了 | `Orientation/TASK_DECOMPOSITION_AND_REORGANIZATION.md` |
| `OPS-005` | `DONE` | Codex | [EXECUTION] AI task process posterの更新 | 完了した分解・再構成文書と作業中停止文書を入力に、判断整理、task境界、graph再構成、ready、委任を中心とするV2へ生成script、SVG、PNGを更新し、ユーザーが受入 | `AI_TASK_PROCESS_POSTER.png` / `Utilities/Maintenance/GenerateAITaskProcessPoster.py` |
| `OPS-006` | `DONE` | Codex | [EXECUTION] task依存判断の軽量draft | 後続taskの成立に現在欠けている前提を探し、依存の見落としによる破綻・片手落ち・手戻りを避けるための短い観点整理を独立文書へ記録し、ユーザーレビューで修正必須なしを確認。文書はdraftのまま維持 | `Orientation/TASK_DEPENDENCY_IDENTIFICATION_DRAFT.md` |
| `OPS-007` | `DONE` | Codex | [EXECUTION] AI task process poster V2への依存発見反映 | V2の構造を維持したまま、後続の成立条件、欠けた必須前提、並行依存、未確定候補を入口へ追加し、生成script、SVG、PNGを上書き。ユーザーが受入 | `AI_TASK_PROCESS_POSTER.png` / `Utilities/Maintenance/GenerateAITaskProcessPoster.py` |
| `RELEASE-009` | `FROZEN` | Codex | [DISCOVERY] 0.5.1実績に基づくrelease checklist見直し | 2026-10-09、前任conversationの意図と途中経過の喪失により再開困難なため凍結。明示的な再開指示後、残存記録を参考資料として目的と境界から再確認 | `RELEASE_CHECKLIST.md` / `Archived/Canonical/RELEASE_0_5_1.md` |
| `RELEASE-011` | `FROZEN` | Codex | [DISCOVERY] `prepare/release/template`の構成設計と試行 | 2026-10-09、前任conversationの意図と途中経過の喪失により再開困難なため凍結。残存ドラフトは当面保存するが既決事項とは扱わず、明示的な再開指示後に目的と境界を再確認 | `RELEASE_TEMPLATE_BRANCH_DESIGN.md` / `RELEASE_CHECKLIST.md` |
| `RELEASE-020` | `FROZEN` | Codex | [EXECUTION] 0.6.0でGitHub Pages更新元をrelease tagへ一本化 | 0.5.xではmain pushとrelease tag pushの双方によるdeploy競合を許容。0.6.0のrelease工程でmain由来のdeployを停止し、tag commitから生成・検証した利用者向け文書だけがPagesを更新することを確認 | `RELEASE_0_6_0.md` / `RELEASE_TEMPLATE_BRANCH_DESIGN.md` |
| `RELEASE-072` | `USER_ONLY` | User | [EXECUTION] 人間向けリリース工程表の作成 | ユーザーがゴールを定め、人間だけでも現在位置、次の操作、完了証拠、停止点を追える一枚の工程表を作成する。0.5.xで実際に使って観測し、0.6.xで磨く。AIは開始、代行、催促を行わず、依頼された場合だけ整理・レビューを補助する | `RELEASE_CHECKLIST.md` / `RELEASE_TASK_REGISTRY_DESIGN.md` |
| `RELEASE-075` | `USER_ONLY` | User | [EXECUTION] リリース工程の不足仕様充当 | ユーザーが、定義した品質要求に対して不足する工程仕様、判定基準、証拠取得方法、停止・復旧手順を補い、V&V可能な状態にする。AIは開始、代行、催促を行わず、依頼された場合だけ整理・レビューを補助する | `User/RELEASE_PROCESS.md` |
| `RELEASE-076` | `USER_ONLY` | User | [EXECUTION] リリース工程のValidation & Verification | ユーザーが、充当後の工程仕様について、定義した品質要求を満たすことと、意図したリリース目的に適合することを確認する。AIは開始、代行、催促を行わず、依頼された場合だけ検証・レビューを補助する | `User/RELEASE_PROCESS.md` |
| `RELEASE-035` | `PROPOSED` | Codex | [EXECUTION] release checklistのRegistry templateへの移行 | checklist本文を読んで判断・操作・証拠へ分類する規則とtask骨格をtemplateへ移し、一判断ごとの必須依存、`REL-000`からの内部採番、任意task除去条件を検証する | `RELEASE_TASK_REGISTRY_TEMPLATE.md` / `RELEASE_TASK_REGISTRY_DESIGN.md` / `RELEASE_CHECKLIST.md` |
| `RELEASE-036` | `PROPOSED` | Codex | [EXECUTION] release専用Registryへの正本切替 | 移行後の旧checklistをArchivedへ移し、現行参照をtemplateとactive Registryへ切り替え、生成・startup precedence・完了／中止還元を一往復検証する | `RELEASE_TASK_REGISTRY_DESIGN.md` / `RELEASE_TASK_REGISTRY_TEMPLATE.md` |
| `DOC-010` | `FROZEN` | Codex | [DISCOVERY] BareArrayの定性的性能表現の再検討 | 2026-10-09、比較対象はSwiftの`[[Element]]`であり、COWと連鎖subscriptによる深刻な性能劣化を単一連続storageと非所有Viewで迂回する設計意図があると確認。アンカリングを避けるため、ユーザー指示による再訪まで文言判断を保留 | `Archived/Canonical/RELEASE_0_5_2.md` / `BareArrayModule/BareArrayAudit.md` |
| `RELEASE-007` | `FROZEN` | User / Codex | [DECISION] 0.6.0の到達範囲とrelease検討開始 | 全公開対象の利用者向けドキュメント初版完成後、0.6.0へ含める到達範囲を一つに定め、release checklistへ進むか判断 | `RELEASE_0_6_0.md` |
| `RBT-014` | `FROZEN` | Codex | RedBlackTree文書workflowと4型outlineのAPI照合 | Permutation、OptionalArray、BareArrayのユーザードキュメント作業で方式を習熟した後、ユーザーが再開。workflowと4公開型のoutlineを現在のAPI、test、設計資料と照合し、本文作成へ渡せる状態を確認 | `Sources/RedBlackTreeCollections/Documentation/Head/DOCUMENTATION_WORKFLOW.md` |
| `RBT-026` | `FROZEN` | User / Codex | [DECISION] Mapped Values ViewのO(1)範囲契約再検討 | 利用者向け文書作業フェーズで、View外だがbase treeでは有効なIndexを黙って読み書きし得る性質を踏まえ、O(1)と呼び出し側事前条件の現行契約を維持するか一つだけ再判断 | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-004` | `FROZEN` | Codex | Debug限定Comparable群・Balanced群 | Index契約またはexecutable API Matrix方針の確定後 | `EXTERNAL_TYPE_EXTENSION_AUDIT.md` |
| `RBT-005` | `FROZEN` | Codex | Memoize群の公開終了／正式API化 | 外部consumer 2件の移行後 | `EXTERNAL_TYPE_EXTENSION_AUDIT.md` |
| `PERM-002` | `USER_ONLY` | User | ABC328E実提出確認 | ユーザーが手作業で実施 | `PermutationModule/ImplementationPlan.md` |
| `PERM-041` | `PROPOSED` | Codex | [DISCOVERY] Permutation一般Swift利用Validation scenario設計 | 代表利用者、SwiftPM・facade経路、利用課題、類似APIとの選択、観測方法を整理し、一般Swift開発への適合を判断できるscenarioと必要な後続候補を提示する | `PermutationModule/CurrentQualityAssessment.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` |
| `PERM-043` | `FROZEN` | User | [DECISION] C++標準に匹敵すると判定する性能比の上限 | 2026-10-11、ユーザー指示により比較水準の判断を保留。明示的な再開指示後、28要素中7要素を選ぶ最大ケースでSwiftの全体処理時間を`std::next_permutation`の何倍以内なら「匹敵」と受け入れるか一つだけ決定する | `PermutationModule/CurrentQualityAssessment.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` |
| `PERM-044` | `FROZEN` | Codex | [EXECUTION] Permutation外部性能アセスメントの実測・判定 | 2026-10-11、比較水準の判断とともにユーザー指示で保留。`PERM-043`の明示的な再開・完了後、macOS上で専用scriptを実行し、環境情報、生JSON、PNG chartを保存して判定する | `PermutationModule/CurrentQualityAssessment.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` |
| `PERM-046` | `FROZEN` | Codex | [EXECUTION] Swift 6.2向け縮小manifestの実装・検証 | ユーザーの明示的な再開指示後、無印`Package.swift`をSwift 6.4完全版、`Package@swift-6.2.swift`をPermutationModuleなしの縮小版として実装し、両toolchainで製品・facade・test・CI経路を検証 | `PermutationModule/CurrentQualityAssessment.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` |
| `PERM-047` | `FROZEN` | Claude | [DISCOVERY] 借用Permutationの旧Test as Specification・実験test棚卸し | Claudeのcontext reset後、ユーザーが明示的に再開。退避中の通常版7テスト群と`PermutationTests/EtcTests.swift`をtest function単位で確認し、新借用契約に対して維持・置換・失効、または実験から後続testへ昇格すべき事実へ分類し、runtime test、compiler診断fixture、所有・破棄testへ分割可能な実装入力を作る。production code、公開契約、testは変更しない | `PermutationModule/BorrowedPermutationTestPlan.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` |
| `OPT-006` | `FROZEN` | Codex | [DISCOVERY] OptionalArray品質評価の文書作業後レビュー | `OPT-005`とユーザードキュメント作業の完了後に再評価し、1.0判断前に解消する不足を独立task候補へ分離 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-044` | `FROZEN` | User | [DECISION] OptionalArray 1D所有型名の再判断 | 0.6.0の到達範囲判断前に、`OptionalArray1D`を維持するか、AI間で整理した選択肢から一つ判断。0.5.2のコメントドック作業は現行名で先行する | `OptionalArrayModule/OptionalArrayAudit.md` / `RELEASE_0_6_0.md` |
| `OPT-045` | `FROZEN` | User | [DECISION] OptionalArray次元名体系の再判断 | 0.6.0の到達範囲判断前に、2D・3Dの意味名と4Dの`size0`〜`size3`を維持するか、AI間で整理した選択肢から一つ判断。0.5.2のコメントドック作業は現行名で先行する | `OptionalArrayModule/OptionalArrayAudit.md` / `RELEASE_0_6_0.md` |
| `OPT-047` | `DONE` | Codex | [DISCOVERY] OptionalArray 0.6.0現行品質アセスメント | Debug・Release・ASan各通常35件・Death Test 26件、facade、DocC、buildを確認。View寿命とstrict memory safetyを未達、`Sendable`・`-Ounchecked`・性能・利用Validationを未検証として分離し、品質評価から新しいユーザー判断は発生しないと確認 | `OptionalArrayModule/CurrentQualityAssessment.md` / `Sources/OptionalArrayModule/Documentation/Quality-Profile.md` |
| `OPT-048` | `PROPOSED` | Codex | [DISCOVERY] OptionalArray View寿命・公開安全性分類・strict安全性の依存分解 | 現行View寿命契約、Swift 6.4 Lifetimes、公開7型の分類、strict診断31件を照合し、事実と既存原則で閉じる偶有的判断を除去して、本質的判断が残る場合だけ独立taskへ分離する | `OptionalArrayModule/CurrentQualityAssessment.md` / `StrictMemorySafetyReadiness.md` |
| `OPT-049` | `FROZEN` | Codex | [DISCOVERY] OptionalArray多次元access性能測定設計 | BareArrayのアセスメント構成確立後、競技用途のmemoization accessを対象に、Swift OptionalArrayとC++ nested `vector<T>`の番兵手法で同じ操作・形状・checksumを定める | `OptionalArrayModule/CurrentQualityAssessment.md` |
| `OPT-050` | `FROZEN` | Codex | [EXECUTION] OptionalArray access性能のCI回帰Benchmark登録 | `OPT-049`の設計に従いSwift workloadを通常CIの既存Benchmark libraryへ追加し、base／current比較で退行検知できることを確認 | `OptionalArrayModule/CurrentQualityAssessment.md` |
| `OPT-051` | `FROZEN` | Codex | [EXECUTION] OptionalArrayアセスメント用C++番兵workload登録 | CI回帰経路の成立後、Swift版と同じmemoization access・形状・checksumをnested `vector<T>`と番兵値で実装し、通常CIには含めない | `OptionalArrayModule/CurrentQualityAssessment.md` |
| `OPT-052` | `FROZEN` | Codex | [DISCOVERY] OptionalArray macOS外部性能アセスメントへのアレンジ | Swift／C++対応workload、専用library、保存script、環境情報、生JSON、PNG chartをPermutationと同じ構成へ整え、暫定実測を保存する | `OptionalArrayModule/CurrentQualityAssessment.md` / `Sources/OptionalArrayModule/Documentation/Quality-Profile.md` |
| `OPT-053` | `FROZEN` | User | [DECISION] OptionalArrayがC++番兵手法に匹敵すると判定する性能比の上限 | `OPT-052`の暫定実測後、代表memoization workloadで許容する性能比を一つだけ決定する | `OptionalArrayModule/CurrentQualityAssessment.md` / `Sources/OptionalArrayModule/Documentation/Quality-Profile.md` |
| `OPT-054` | `FROZEN` | Codex | [EXECUTION] OptionalArray外部性能アセスメントの実測・判定 | `OPT-053`完了後、macOS上で正式測定し、環境情報、生JSON、PNG chart、判定を保存する | `OptionalArrayModule/CurrentQualityAssessment.md` / `Sources/OptionalArrayModule/Documentation/Quality-Profile.md` |
| `BARE-006` | `DONE` | Codex | [DISCOVERY] BareArray多次元access性能測定設計 | 2D・3Dのsequential read / write、総要素数が等しいshape、計測内外、checksum、C++ nested `vector<intptr_t>`との対応、CI回帰とmacOS外部assessmentの境界を確定 | `BareArrayModule/CurrentQualityAssessment.md` / `Tests/TESTING.md` |
| `BARE-007` | `FROZEN` | Codex | [EXECUTION] BareArray外部性能アセスメントの実測・判定 | 性能比の受入判断後、macOS上で正式測定し、環境情報、生JSON、PNG chart、判定を保存する | `BareArrayModule/CurrentQualityAssessment.md` / `Sources/BareArrayModule/Documentation/Quality-Profile.md` |
| `BARE-029` | `ACTIVE` | Codex | [EXECUTION] BareArray access性能のCI回帰Benchmark登録 | `BARE-006`の設計に従い2D・3D sequential read / writeを通常CIの既存Benchmark libraryへ追加し、base／current比較で退行検知できることを確認 | `BareArrayModule/CurrentQualityAssessment.md` |
| `BARE-030` | `FROZEN` | Codex | [EXECUTION] BareArrayアセスメント用C++ nested vector workload登録 | CI回帰経路の成立後、Swift版と同じ多次元access・形状・checksumをnested `vector<T>`で実装し、通常CIには含めない | `BareArrayModule/CurrentQualityAssessment.md` |
| `BARE-031` | `FROZEN` | Codex | [DISCOVERY] BareArray macOS外部性能アセスメントへのアレンジ | Swift／C++対応workload、専用library、保存script、環境情報、生JSON、PNG chartをPermutationと同じ構成へ整え、暫定実測を保存する | `BareArrayModule/CurrentQualityAssessment.md` / `Sources/BareArrayModule/Documentation/Quality-Profile.md` |
| `BARE-032` | `FROZEN` | User | [DECISION] BareArrayがC++ nested vectorに匹敵すると判定する性能比の上限 | `BARE-031`の暫定実測後、代表多次元access workloadで許容する性能比を一つだけ決定する | `BareArrayModule/CurrentQualityAssessment.md` / `Sources/BareArrayModule/Documentation/Quality-Profile.md` |
| `BARE-033` | `DONE` | Codex | [EXECUTION] 性能CIのbaseline / current間Benchmark harness統一 | PRとcandidateの両性能CIでSources、Libraries、manifest、resolved依存を現行側からbaselineへ同期し、新BareArray workloadを含む現行harnessがコミット前のbaseline製品codeに対してbuild・小規模実行できることを確認 | `Tests/TESTING.md` / `.github/workflows/ci.yml` / `.github/workflows/candidate.yml` |
| `BARE-016` | `DONE` | Codex | [DISCOVERY] BareArray現行品質アセスメント | Quality Profileの現在性監査、QR-01〜QR-06の現行評価、実行記録、既存課題と新規Validation候補への不足分離を完了 | `BareArrayModule/CurrentQualityAssessment.md` / `Sources/BareArrayModule/Documentation/Quality-Profile.md` |
| `BARE-017` | `PROPOSED` | Codex | [DISCOVERY] BareArray利用Validation scenario設計 | 一般Swift利用と競技利用について、代表利用者、導入経路、利用課題、観測方法を整理し、異なる判断・実行境界を後続task候補へ分離する | `BareArrayModule/CurrentQualityAssessment.md` / `Sources/BareArrayModule/Documentation/Quality-Profile.md` |
| `BARE-018` | `FROZEN` | Codex | [EXECUTION] BareArray Viewノンエスケーパブル化の完了ゲート | 実装と局所検証の途中証拠を保存したまま凍結。storage、公開型の安全性分類、strict memory safetyの3系統を閉じ、品質検証を再開・完了した後に受入可否を判定する | `BareArrayModule/CurrentQualityAssessment.md` |
| `BARE-019` | `EXCLUDED` | User / Codex | [DECISION] 同一BareArray間writebackのコンパイル時拒否採否 | 2026-10-11、拒否契約自体は従来から不変で、実行時Death Testからコンパイル時診断へVerification手段だけが移ったと確認。製品判断ではなかったため除外 | `BareArrayModule/CurrentQualityAssessment.md` |
| `BARE-020` | `FROZEN` | Codex | [EXECUTION] BareArray Viewノンエスケーパブル実装の整合化 | compile成功までの途中差分を保存。ユーザーの明示的な再開指示後、正式実装として受け入れる範囲を再確認する | `BareArrayModule/CurrentQualityAssessment.md` |
| `BARE-021` | `FROZEN` | Codex | [EXECUTION] BareArray compiler診断Verificationへの移行 | compile-fail fixtureとDeath Test棚卸しの途中差分を保存。ユーザーの明示的な再開指示後、Verification方法としての受入可否を再確認する | `BareArrayModule/CurrentQualityAssessment.md` |
| `BARE-022` | `FROZEN` | Codex | [EXECUTION] BareArray有効利用経路の回帰確認 | Debug・Releaseの実行結果を途中証拠として保存。ユーザーの明示的な再開指示後、必要な回帰範囲と受入可否を再確認する | `BareArrayModule/CurrentQualityAssessment.md` |
| `BARE-023` | `DONE` | Codex | [DISCOVERY] BareArray storage境界の成立確認 | `@safe`分類とノンエスケーパブルViewにより再設計候補の前提が解消し、連続配置・O(1) access・ノンコピーViewを担う現行storage境界を維持すると確認 | `BareArrayModule/CurrentQualityAssessment.md` / `StrictMemorySafetyReadiness.md` |
| `BARE-024` | `DONE` | User / Codex | [DECISION] BareArray公開7型の`@safe`／`@unsafe`分類 | 所有型4・ノンエスケーパブルView型3を`@safe`に分類して実装し、strict warning解消とDebug・Release・compiler診断fixtureの回帰成功を確認 | `BareArrayModule/CurrentQualityAssessment.md` / `StrictMemorySafetyReadiness.md` |
| `BARE-025` | `DONE` | Codex | [DISCOVERY] BareArray strict memory safety適用の成立確認 | 公開7型の`@safe`分類後、`.strictMemorySafety()`有効状態でwarningがなく、既存検証も成功するため、採否をユーザーへ返す本質的判断は残らず、品質検証の対象として維持すると確認 | `BareArrayModule/CurrentQualityAssessment.md` / `StrictMemorySafetyReadiness.md` |
| `BARE-026` | `DONE` | User | [DECISION] BareArray品質検証の再開判断 | 2026-10-11、0.6.0品質として、完了したstorage、安全性分類、strict memory safetyの3系統を前提に品質検証を再開すると決定 | `BareArrayModule/CurrentQualityAssessment.md` |
| `BARE-027` | `DONE` | Codex | [EXECUTION] BareArrayノンエスケーパブル化の品質検証 | 0.6.0品質としてDebug・Release・ASan・compiler診断fixture・facade・DocCを検証し、View寿命とstrict memory safetyを確認済み、並行利用・`-Ounchecked`・利用Validation・外部性能を未検証として分離 | `BareArrayModule/CurrentQualityAssessment.md` / `Sources/BareArrayModule/Documentation/Quality-Profile.md` |
| `BARE-028` | `FROZEN` | Codex | [EXECUTION] BareArray Claude手直し後の差分再検証 | Claudeのレビューと手直しが受け入れられた後に再開し、変更影響範囲のbuild、test、compiler診断fixture、安全性診断を再実行して現行証拠との差分を確認する | `BareArrayModule/CurrentQualityAssessment.md` |
| `ARRAY-001` | `EXCLUDED` | Codex | [DISCOVERY] Array系storage・View寿命・strict安全性の再分解 | BareArrayのView寿命はノンエスケーパブル化へ統合し、残るstorage、公開安全性分類、strict memory safetyを独立taskへ分解したため、包括taskとしては除外。OptionalArrayは必要時に別途再分解する | `StrictMemorySafetyReadiness.md` |
| `RBT-007` | `FROZEN` | User / Codex | RedBlackTreeCollectionsのstrict memory safety全面適用 | ユーザーが段階3を承認 | `StrictMemorySafetyReadiness.md` |
| `RBT-008` | `FROZEN` | User / Codex | `lazyDetach`等の並行初期化保証 | concurrency契約を扱う明示的な再開指示 | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` |
| `HIST-001` | `ACTIVE` | V3オーサー | [DISCOVERY] AtCoder 2025移行史 | 本紙をアクロバット的なリファクタリングの説明として洗練し、追加調査は証拠別紙へ蓄積する。本紙と別紙で同じ詳細事実を重複定義しない | `RefactoringFromAtCoder2025/README.md` / `RefactoringFromAtCoder2025/EVIDENCE.md` |
| `RBT-009` | `FROZEN` | User / Codex | [DECISION] runtime-check実装の再審査 | ユーザードキュメント作業後、1.0中間ゴールへ移行した時点、または`-Ounchecked`が主要構成と判明した時点で再開し、現行実装を1.0へ採用するか一つだけ判断 | `Sources/RedBlackTreeCollections/Documentation/Design/Design-RuntimeChecks.md` |
| `QUALITY-001` | `FROZEN` | User / Codex | 汎用基盤ライブラリとしての1.0採用品質ゲート | Index契約確定後、ユーザーが明示的に再開 | `Sources/RedBlackTreeCollections/Documentation/Quality-Profile.md` |

## Task precedence

| 後続task | 前提task | Flow | 制約 |
| --- | --- | --- | --- |
| `RBT-001` | `RBT-010` | `PARALLEL_JOIN` | 公開Index表現・完了範囲の判断は、Comparable採否と分離したまま親ゲートの完了前に合流する |
| `RBT-001` | `RBT-011` | `PARALLEL_JOIN` | Comparable採否の外部依存は判断task側に残し、親ゲートの完了前に合流する |
| `QUALITY-001` | `RBT-001` | `PARALLEL_JOIN` | 品質調査は並行できるが、1.0品質判定を確定する前にIndex契約完了と合流する |
| `QUALITY-001` | `RBT-009` | `PARALLEL_JOIN` | 他の1.0品質作業は並行できるが、最終判定前にruntime-check実装の採否と合流する |
| `RBT-026` | `RBT-014` | `SEQUENCE` | 現行APIとの照合を判断材料として揃えてからMapped Values契約を再判断する |
| `BARE-029` | `BARE-033` | `SEQUENCE` | 現行側にしかない新workloadも同一harnessでbase / current比較できるCI経路を先に成立させる |
| `BARE-029` | `BARE-006` | `SEQUENCE` | workload設計後、まずSwift側を通常CIの回帰検知へ追加する |
| `BARE-030` | `BARE-029` | `SEQUENCE` | CI回帰経路の成立後、外部比較専用のC++対応workloadを追加する |
| `BARE-031` | `BARE-030` | `SEQUENCE` | Swift／C++両workloadの成立後、macOSアセスメント用にアレンジして暫定実測する |
| `BARE-032` | `BARE-031` | `SEQUENCE` | 暫定結果を確認してから、必要な性能比上限を判断する |
| `BARE-007` | `BARE-032` | `SEQUENCE` | 性能比上限の決定後、正式測定結果へ適用して判定する |
| `OPT-049` | `BARE-031` | `SEQUENCE` | BareArrayで確立した二層構造を入力に、OptionalArray固有の番兵比較を設計する |
| `OPT-050` | `OPT-049` | `SEQUENCE` | workload設計後、まずSwift側を通常CIの回帰検知へ追加する |
| `OPT-051` | `OPT-050` | `SEQUENCE` | CI回帰経路の成立後、外部比較専用のC++番兵workloadを追加する |
| `OPT-052` | `OPT-051` | `SEQUENCE` | Swift／C++両workloadの成立後、macOSアセスメント用にアレンジして暫定実測する |
| `OPT-053` | `OPT-052` | `SEQUENCE` | 暫定結果を確認してから、必要な性能比上限を判断する |
| `OPT-054` | `OPT-053` | `SEQUENCE` | 性能比上限の決定後、正式測定結果へ適用して判定する |
| `BARE-021` | `BARE-020` | `SEQUENCE` | 正式実装のcompile成立後に、拒否される利用をcompiler診断のVerificationへ移す |
| `BARE-022` | `BARE-020` | `SEQUENCE` | 正式実装のcompile成立後に、有効な利用経路をDebug・Releaseで回帰確認する |
| `BARE-026` | `BARE-023` | `PARALLEL_JOIN` | 現行storage境界の成立確認後に品質検証の再開を判断する |
| `BARE-026` | `BARE-024` | `PARALLEL_JOIN` | 公開7型の安全性分類を決定してから品質検証の再開を判断する |
| `BARE-026` | `BARE-025` | `PARALLEL_JOIN` | strict memory safety適用の成立確認後に品質検証の再開を判断する |
| `BARE-027` | `BARE-026` | `SEQUENCE` | ユーザーが再開を決定した場合だけ、確定した前提で品質検証を実行する |
| `BARE-018` | `BARE-027` | `SEQUENCE` | 品質検証の結果を受け入れてからノンエスケーパブル化の完了を判定する |
| `BARE-028` | `BARE-027` | `SEQUENCE` | 現行品質検証を基準に、Claudeの手直し受入後の変更影響を再検証する |
| `BARE-018` | `BARE-028` | `PARALLEL_JOIN` | Claudeの手直し後に必要となる差分再検証も完了ゲートへ合流する |
| `BARE-017` | `BARE-018` | `SEQUENCE` | 完成したView契約を入力に一般Swift利用と競技利用のValidation scenarioを設計する |
| `PERM-044` | `PERM-043` | `SEQUENCE` | C++標準に匹敵すると判定する性能比上限を確定してから、保存したmacOS測定証拠へ適用する |
| `RELEASE-020` | `RELEASE-007` | `SEQUENCE` | 0.6.0の到達範囲とrelease開始を決定してから、Pages更新元の一本化をrelease工程として実施する |
| `RELEASE-036` | `RELEASE-035` | `SEQUENCE` | checklist移行を検証してから実行正本をactive Registryへ切り替える |
| `RELEASE-076` | `RELEASE-075` | `SEQUENCE` | 不足仕様を充当して検証可能な工程にしてから、Validation & Verificationを行う |
| `RELEASE-007` | `OPT-044` | `PARALLEL_JOIN` | 利用者向け文書作業は現行名で先行できるが、0.6.0の到達範囲判断前に1D所有型名を確定する |
| `RELEASE-007` | `OPT-045` | `PARALLEL_JOIN` | 利用者向け文書作業は現行名で先行できるが、0.6.0の到達範囲判断前に次元名体系を確定する |

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
