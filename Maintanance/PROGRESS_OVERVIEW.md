# 開発・メンテナンス進捗一覧

最終更新: 2026-10-08 / Codex

この文書のTask Registryを、CodexとClaudeが作業を再開するときの唯一の入口とする。まずRegistry
だけを読み、選択したtask行が示す詳細正本だけを追加で読む。2026-10-07までの完了チェック、判断待ち、
旧サマリーは`Archived/PROGRESS_OVERVIEW_HISTORY_2026-10-07.md`へ移した。

## Task Registry

**現在の律速:** 外部（`swift-collections` ContainersPreviewの`Container.Index`要件）。
Index契約と関連taskは、この外部条件が安定するまで最終確定できない。

**中間ゴールの取り扱い**

**現在の中間ゴール:**

- Permutationを、Codexのユーザードキュメント作業フェーズへ渡せる状態にする。
- RedBlackTreeに見えていない残作業がないかを確認し、Codexのユーザードキュメント作業フェーズへ
  渡せる状態にする。
- OptionalArrayを、Codexが作業設計・網羅性確認・完了判定を担う管理方式で、Codexの
  ユーザードキュメント作業フェーズへ渡せる状態にする。
- Claudeへ渡すtask出しを、「一つのtaskに一つのユーザー判断、またはユーザー判断なし」まで
  分解できる状態にする。

**後続の中間ゴール:**

- ユーザードキュメント作業後、RedBlackTreeを汎用基盤ライブラリの1.0として採用できるか判断可能な
  状態にする。この段階でruntime-check実装を再審査し、その結論とIndex契約を1.0品質ゲートへ渡す。
- ユーザードキュメント作業後、OptionalArrayを1.0として採用できるか判断可能な状態にする。
  BareArrayの各taskと`ARRAY-001`は、OptionalArrayで管理方式を検証して再開を判断するまで凍結する。

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

中間ゴールへ向けた残る主系列の推奨順は、`OPT-001`、`PERM-017`、`RBT-014`、`RBT-015`とする。
これは後続作業への影響が大きいものを先に調べるためのsoft orderであり、Task precedenceに記録した
必須依存以外の着手を禁止しない。

次の判断は今回の作業taskへ含めない。必要になった時点でユーザーと別途決定する。

- 利用者向け文書の形（Markdown、DocC、documentation commentのみのいずれにするか）
- Permutation通常版と互換modeの文書境界
- 性能の数値を利用者向け文書へ掲載するか
- 1.0ゲート（`QUALITY-001`）との境界
- RedBlackTreeのデバッグ用memberを`#if DEBUG`へ揃えるか

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `RBT-001` | `WAITING_EXTERNAL` | User / Codex | Index完了ゲート | 公開Index表現・完了範囲と`Comparable`採否を確定し、Index契約全体を閉じる | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-010` | `WAITING_EXTERNAL` | User / Codex | Index完了ゲートのうち公開Index表現と完了範囲 | Container要件の安定後、公開Indexと内部`SealError`の分離、1.0での完了範囲を決定 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-011` | `WAITING_EXTERNAL` | User / Codex | Indexの`Comparable`採否 | `swift-collections`の要件が安定または正式化した後、互換性を再評価して決定 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-002` | `DONE` | User / Codex / Claude | Index-range `erase`の空guard | 2026-10-06、範囲検査を維持して空での不要なCoWを回避（`11817dfe`） | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `DOC-001` | `DONE` | Codex / Claude | P10残存記述確認 | 2026-10-06、監査と必要箇所の同期を完了（`9b0f42d5`） | `MAINTENANCE.md` |
| `GRAPH-001` | `ACTIVE` | Claude | Claude用task graph DBの独立試験 | 現行Registryとのready判定一致を確認しながら試験運用を継続 | `TASK_GRAPH_DB_EXPERIMENT.md` |
| `GRAPH-002` | `FROZEN` | Codex | Codex用task graph DBの独立試験 | Codexのcontext reset後、ユーザーが明示的に再開 | `TASK_GRAPH_DB_EXPERIMENT.md` |
| `GRAPH-003` | `EXCLUDED` | — | 二つのtask graph DBの統合議論 | 2026-10-07、統合方針をdrop。再開候補にしない | `TASK_GRAPH_DB_EXPERIMENT.md` |
| `GRAPH-004` | `ACTIVE` | Claude | AIとgraph DBによるsmell（code / test / task）の独立試験 | 専用ノートをClaudeが自由編集し、観測・仮説・反証・再利用可能な判断基準を継続記録 | `AI_GRAPH_SMELL_NOTES.md` |
| `GRAPH-005` | `ACTIVE` | Codex / Claude | ClaudeとCodexのgraph DB交流会 | 合意した共有面で観測、問い、反証、試したい見方を交換。tracked MDを強制せず、統合や正本化を目的にしない | `TASK_GRAPH_DB_EXPERIMENT.md` |
| `EVAL-001` | `FROZEN` | Claude | Claudeによる正式なユーザー評価・依頼された感想の記録 | ユーザーが記録を明示的に依頼した時だけ再開し、記録後は再び凍結。Claude自身の任意observation追記は妨げない | `USER_MANAGEMENT_INTERVIEW_CLAUDE.md` / `CLAUDE_OBSERVATIONS.md` |
| `RBT-003` | `DONE` | Codex / Claude | `Result`のpublic比較overloadとpublic `_NodePtr` | 2026-10-07、公開面縮小と検証を完了。performance job成功を確認 | `EXTERNAL_TYPE_EXTENSION_AUDIT.md` |
| `RBT-012` | `DONE` | Claude | Swift 6.4 `-O`のCoW誤コンパイルに対する値セマンティクスのTest as Spec拡充 | 2026-10-07、closure-captured mutation形状を4型へ追加し、Debug / Releaseで値セマンティクス維持を確認（`4249ed8c`） | `Tests/RedBlackTreeTests/` |
| `RBT-013` | `DONE` | Claude | RedBlackTree sourceのTODO/FIXME棚卸し | 2026-10-07、27件を分類。文書へ影響するRange View検査と公開API名、古いコメント2件を判断候補として報告 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `PERM-016` | `DONE` | Claude | [EXECUTION] Permutation品質評価の事実更新 | 2026-10-07、解消済み`swapAt`懸念を除き、header二重破棄、終端の不要copy、走査共有、Debug限定検査member、行数を反映（`127a0d5b`） | `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` |
| `PERM-017` | `ACTIVE` | Codex | Permutation品質評価R-1〜R-4 review | `PERM-016`後の§6をreviewし、品質特性の解釈、1.0前の不足、根拠の正確性へ回答を反映。R-3は文書形式を決めず、ユーザー判断に必要な選択肢と技術的根拠までを整理 | `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` |
| `RBT-014` | `ACTIVE` | Codex | RedBlackTree文書workflowと4型outlineのAPI照合 | `RBT-013`後、workflowと4公開型のoutlineを現在のAPI、test、設計資料と照合し、本文作成へ渡せる状態を確認 | `Sources/RedBlackTreeCollections/Documentation/Head/DOCUMENTATION_WORKFLOW.md` |
| `RBT-015` | `ACTIVE` | Codex | RedBlackTree残task文書の事実更新 | PR #158前提の記述など、現在の実装とRegistryに対して古い記述を修正 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-017` | `EXCLUDED` | — | [EXECUTION] Mapped Values Range Viewの範囲外更新防止ゲート | 2026-10-08、範囲所属は呼び出し側の事前条件、単一Index操作はO(1)と`211ca2fc`で確定済みのため変更不要 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-018` | `EXCLUDED` | — | [DISCOVERY] Mapped Values ViewのIndex検査条件調査 | 2026-10-08、調査は既存のAPI Matrix・仕様testを見落としており、追加判断が必要という前提を撤回 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-019` | `EXCLUDED` | — | [DECISION] 全体Mapped Values Viewの範囲検査 | 既存のO(1)契約を維持するため判断不要 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-020` | `EXCLUDED` | — | [DECISION] 部分Mapped Values Viewの更新計算量 | O(1)を維持する契約が確定済みのため判断不要 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-021` | `EXCLUDED` | — | [DECISION] Mapped Values View範囲外停止メッセージ | 範囲所属を操作内で検査しないため判断不要 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-022` | `EXCLUDED` | — | [DECISION] Mapped Values View getterの範囲検査 | getterもO(1)契約を維持するため判断不要 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-023` | `EXCLUDED` | — | [DECISION] Mapped Values View範囲判定helperのinline境界 | 新helperを追加しないため判断不要 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-024` | `EXCLUDED` | — | [EXECUTION] Mapped Values View範囲検査の実装と機能検証 | 既存契約に反する実装となるため実施しない。試行差分は破棄済み | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-025` | `EXCLUDED` | — | [EXECUTION] Mapped Values View範囲検査の性能確認 | 実装を行わないため性能確認も不要 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-026` | `FROZEN` | User / Codex | [DECISION] Mapped Values ViewのO(1)範囲契約再検討 | 利用者向け文書作業フェーズで、View外だがbase treeでは有効なIndexを黙って読み書きし得る性質を踏まえ、O(1)と呼び出し側事前条件の現行契約を維持するか一つだけ再判断 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `PERM-018` | `DONE` | Claude | [EXECUTION] swift-algorithms同時import時のPermutation名前衝突test | 2026-10-07、両moduleの同時import、名前解決、successor列と全順列の使い分けを仕様testで固定（`0ff5fd84`） | `Tests/PermutationTests/NextPermutationsSequence/` |
| `PERM-019` | `EXCLUDED` | — | [EXECUTION] 利用者向けPermutation使用例の仕様test化 | 2026-10-08、使用例の選定は利用者向け文書作業そのものとして文書フェーズへ移し、独立taskから除外 | `Tests/PermutationTests/NextPermutationsSequence/` |
| `RBT-016` | `EXCLUDED` | — | `RedBlackTreePair.tuple`の仕様test | 2026-10-07、型全体がdocumentation上internalで公開仕様testは不要。graphのspec-gap検出を修正して0件を確認 | `Tests/RedBlackTreeTests/` |
| `RBT-004` | `FROZEN` | Codex | Debug限定Comparable群・Balanced群 | Index契約またはexecutable API Matrix方針の確定後 | `EXTERNAL_TYPE_EXTENSION_AUDIT.md` |
| `RBT-005` | `FROZEN` | Codex | Memoize群の公開終了／正式API化 | 外部consumer 2件の移行後 | `EXTERNAL_TYPE_EXTENSION_AUDIT.md` |
| `RBT-006` | `FROZEN` | User / Codex | 未結線コードの個別削除 | ユーザーが対象を個別指定 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `TEST-001` | `FROZEN` | User / Codex | 無効化・歴史的テストコードの処遇 | ユーザーが対象を個別指定 | `Tests/TESTING.md` |
| `TEST-002` | `FROZEN` | Codex | stride assertion／fixture alignmentの任意改善 | 実害または明示的な再開指示 | `Tests/TESTING.md` |
| `PERM-001` | `FROZEN` | Codex | AtCoder 2025互換mode | ユーザーが明示的に再開 | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-002` | `USER_ONLY` | User | ABC328E実提出確認 | ユーザーが手作業で実施 | `PermutationModule/ImplementationPlan.md` |
| `PERM-003` | `DONE` | Claude | 現行Permutation契約の基準固定 | 2026-10-07、削除済みAPIの非露出をcompile時に固定し、重複要素・非Array入力のtestを追加 | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-011` | `DONE` | Claude | Permutation公開型の改名 | 2026-10-07、`NextPermutationsSequence`/`.Iterator`/`.Permutation`へ改名し`Permutations`名前空間を廃止（source-breaking、ユーザー承認済み） | `Tests/PermutationTests/NextPermutationsSequence/` |
| `PERM-012` | `DONE` | Claude | Permutation仕様のTest as Specification化 | 2026-10-07、仕様をテストの連番fileへ移し、`Specification.md`を削除（ユーザー判断）。テストで表せない約束はソースのドキュメントコメントへ | `Tests/PermutationTests/NextPermutationsSequence/` |
| `PERM-013` | `FROZEN` | User / Claude | Permutation性能のCIベース比較 | 作業の区切りでユーザーが再開。Claudeが`Benchmarks/Libraries/CI.json`へPermutationの計測を追加し、ユーザーのpush後にperformance jobのベース比較で`@inline(__always)`全削除（`0ef177d3`）以降の影響を確認 | `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` |
| `PERM-014` | `ACTIVE` | User / Codex | Permutation互換modeの実施手順決定 | Claude案を出発点に、`PERM-004`〜`PERM-010`のcommit境界、検証範囲、警告とtestの扱いをユーザーとCodexで決定 | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-015` | `FROZEN` | Codex | Permutation互換task依存の再評価 | `PERM-014`完了後、`PERM-004`〜`PERM-010`と`PERM-013`の順序を再評価し、候補`PERM-004` ← `PERM-013`を確定または棄却してRegistryへ反映 | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-004` | `FROZEN` | Codex | AtCoder 2025互換ソースの隔離 | 基準版を専用fileへ配置し、通常版と排他的にcompileできる状態にする | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-005` | `FROZEN` | Codex | Permutation互換traitのPackage設定 | 互換defineをtraitへ接続し、traitなしを通常版の既定にする | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-006` | `FROZEN` | Codex | 互換modeのTest as Specification | 列挙順・重複・safe CoW・unsafe aliasing・境界を基準refに対して固定 | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-007` | `FROZEN` | Codex | 両modeのAcCollections再公開検証 | 通常・互換の期待APIをAcCollections経由でcompile・test | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-008` | `FROZEN` | Codex | Permutation互換CIの分離 | 通常版と互換版を別jobとして表示し、結果を混在させない | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-009` | `FROZEN` | Codex | AtCoder単一file生成とローカル検証 | 互換版から自己完結fileを生成し、ABC328E相当入力で検証 | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-010` | `FROZEN` | Codex | Permutation互換mode文書同期 | 通常APIと互換APIを混同せず、trait・制限・検証方法を文書化 | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `OPT-001` | `ACTIVE` | Codex | [DISCOVERY] OptionalArrayの体系監査・名称再検討 | Codexが作業設計・網羅性確認・完了判定を担い、ユーザードキュメント作業フェーズへ渡せる状態にする | `Tests/TESTING.md` |
| `OPT-002` | `FROZEN` | Codex | [DISCOVERY] OptionalArray監査の管理方式と受入基準の抽出 | `OPT-001`完了後、実際に有効だった作業設計・責任境界・受入基準を再利用可能な形で整理 | `Tests/TESTING.md` |
| `OPT-003` | `FROZEN` | User / Codex | [DECISION] Claude向け委任規則を明文化するか | `OPT-002`後、抽出した管理方式をClaude向け運用規則として残す必要があるか一つだけ判断 | `Tests/TESTING.md` |
| `OPT-004` | `FROZEN` | Codex | [EXECUTION] Claude向け委任規則の明文化 | `OPT-003`で明文化すると決定した場合、人物評価を含めず責任境界・成果物・停止条件として正本へ反映 | `Tests/TESTING.md` |
| `BARE-001` | `FROZEN` | Codex | [DISCOVERY] BareArrayの体系監査・名称再検討 | `BARE-008`で再開すると決定し、ユーザーが明示的に再開するまで着手しない | `Tests/TESTING.md` |
| `BARE-002` | `FROZEN` | Claude | [DISCOVERY] BareArray公開7型の契約棚卸し | 途中成果を保持し、`BARE-008`で再開すると決定するまで追加作業を行わない | `Tests/TESTING.md` |
| `BARE-003` | `FROZEN` | User | [DECISION] BareArrayを低レベル公開部品として維持するか | `BARE-002`後、未決定と判明した場合だけ一つの位置づけを判断。決定済みなら不要として除外 | `Tests/TESTING.md` |
| `BARE-004` | `FROZEN` | User | [DECISION] BareArray公開型・次元名の命名体系 | `BARE-003`後、型名、View名、次元property名とOptionalArray1Dとの整合について一つの命名体系を判断 | `Tests/TESTING.md` |
| `BARE-005` | `FROZEN` | Claude | [EXECUTION] BareArrayModuleTestsのTest as Specification整理 | `BARE-002`後、既存testを番号付きTest as Specificationへ整理。コメントドック全件整備は含めない | `Tests/TESTING.md` |
| `BARE-006` | `FROZEN` | User / Codex | [DECISION] BareArray 1.0の性能基準 | ユーザードキュメント作業後、低レベル部品としての存在理由を評価できる性能基準と計測方法を一つの基準として決定 | `Tests/TESTING.md` |
| `BARE-007` | `FROZEN` | Codex | [EXECUTION] BareArray 1.0の性能計測 | `BARE-006`で決めた基準と方法に従って計測し、1.0判断へ渡す | `Tests/TESTING.md` |
| `BARE-008` | `FROZEN` | User / Codex | [DECISION] BareArray監査を再開するか | `OPT-002`後、必要なら`OPT-003`・`OPT-004`の結果も踏まえ、検証済みの管理方式でBareArrayを再開するか一つだけ判断 | `Tests/TESTING.md` |
| `ARRAY-001` | `FROZEN` | User / Codex | BareArray／OptionalArrayのstorage再設計とstrict恒久適用 | 公開unsafe境界を決定して再開 | `StrictMemorySafetyReadiness.md` |
| `RBT-007` | `FROZEN` | User / Codex | RedBlackTreeCollectionsのstrict memory safety全面適用 | ユーザーが段階3を承認 | `StrictMemorySafetyReadiness.md` |
| `BENCH-001` | `FROZEN` | Codex | SortedCollectionsとのpublishableな大規模比較 | ユーザーが明示的に再開 | `Archived/SORTED_COLLECTIONS_BENCHMARK_TASK.md` |
| `TEST-003` | `FROZEN` | Codex | randomized trace失敗時の自動縮小 | 実害または明示的な再開指示 | `Sources/RedBlackTreeCollections/Documentation/Cpp-Matrix.md` |
| `RBT-008` | `FROZEN` | User / Codex | `lazyDetach`等の並行初期化保証 | concurrency契約を扱う明示的な再開指示 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `PERF-001` | `FROZEN` | Codex | Swift更新後のCoWコード生成再計測 | Swift更新または明示的な再計測指示 | `PERFORMANCE_REGRESSION_BISECTION.md` |
| `HIST-001` | `FROZEN` | Codex | unsafe移行史の追加調査 | ユーザーが明示的に再開 | `REFACTORING_FROM_ATCODER_2025.md` |
| `TEST-004` | `FROZEN` | Codex | 原木Fixtureの追加portable化 | 実害または明示的な再開指示 | `Tests/TESTING.md` |
| `RBT-009` | `FROZEN` | User / Codex | [DECISION] runtime-check実装の再審査 | ユーザードキュメント作業後、1.0中間ゴールへ移行した時点、または`-Ounchecked`が主要構成と判明した時点で再開し、現行実装を1.0へ採用するか一つだけ判断 | `Sources/RedBlackTreeCollections/Documentation/Design/Design-RuntimeChecks.md` |
| `QUALITY-001` | `FROZEN` | User / Codex | 汎用基盤ライブラリとしての1.0採用品質ゲート | Index契約確定後、ユーザーが明示的に再開 | `Sources/RedBlackTreeCollections/Documentation/Quality-Checklist.md` |
| `CPP-001` | `DONE` | Codex / Claude | C++挙動比較 | 比較契約または対象環境を変更する場合だけ更新 | `Sources/RedBlackTreeCollections/Documentation/Cpp-Matrix.md` |
| `CPP-002` | `EXCLUDED` | — | MSVC STLとのC++挙動比較 | 現行計画では実施しない | `Sources/RedBlackTreeCollections/Documentation/Cpp-Matrix.md` |

## Task precedence

| 後続task | 前提task | 制約 |
| --- | --- | --- |
| `RBT-001` | `RBT-010` | 前提taskの完了後に後続taskを完了できる |
| `RBT-001` | `RBT-011` | 前提taskの完了後に後続taskを完了できる |
| `QUALITY-001` | `RBT-001` | 前提taskの完了後に着手候補にできる |
| `QUALITY-001` | `RBT-009` | runtime-check実装の1.0採否を再審査した後に品質ゲートを判断する |
| `PERM-017` | `PERM-016` | 品質評価の事実更新後にreviewする |
| `RBT-014` | `RBT-013` | TODO/FIXMEの文書影響を分類後にoutlineを照合する |
| `RBT-026` | `RBT-014` | outlineのAPI照合後、利用者向け文書作業フェーズで契約を再判断する |
| `PERM-014` | `PERM-003` | 現行契約の基準固定後に手順を決定できる |
| `PERM-015` | `PERM-014` | 実施手順の決定後にtask依存を再評価できる |
| `PERM-004` | `PERM-015` | task依存の再評価とRegistry反映後に着手できる |
| `PERM-005` | `PERM-004` | 前提taskの完了後に着手できる |
| `PERM-006` | `PERM-005` | 前提taskの完了後に着手できる |
| `PERM-007` | `PERM-006` | 前提taskの完了後に着手できる |
| `PERM-008` | `PERM-006` | 前提taskの完了後に着手できる |
| `PERM-009` | `PERM-007` | 前提taskの完了後に着手できる |
| `PERM-010` | `PERM-007` | 前提taskの完了後に着手できる |
| `PERM-010` | `PERM-008` | 前提taskの完了後に着手できる |
| `PERM-010` | `PERM-009` | 前提taskの完了後に着手できる |
| `PERM-001` | `PERM-010` | 前提taskの完了後に後続taskを完了できる |
| `BARE-003` | `BARE-002` | 棚卸しで位置づけが未決定と判明した場合だけ判断する |
| `BARE-004` | `BARE-003` | BareArrayを公開継続する判断後に命名体系を決定する |
| `BARE-005` | `BARE-002` | 契約棚卸し後に既存testを仕様単位へ整理する |
| `BARE-007` | `BARE-006` | 性能基準と計測方法の決定後に計測する |
| `BARE-001` | `BARE-002` | 公開契約の棚卸しを親taskの完了条件とする |
| `BARE-001` | `BARE-003` | 未決定だった場合の位置づけ判断を親taskの完了条件とする |
| `BARE-001` | `BARE-004` | 公開継続時の命名判断を親taskの完了条件とする |
| `BARE-001` | `BARE-005` | Test as Specification整理を親taskの完了条件とする |
| `OPT-002` | `OPT-001` | OptionalArray監査の完了後に実績から管理方式を抽出する |
| `OPT-003` | `OPT-002` | 管理方式と受入基準の抽出後に明文化の要否を判断する |
| `OPT-004` | `OPT-003` | 明文化すると決定した場合だけ運用規則へ反映する |
| `BARE-008` | `OPT-002` | OptionalArrayで管理方式を検証した後にBareArray再開を判断する |

## Registry rules

- 状態は`ACTIVE`、`WAITING_USER`、`WAITING_EXTERNAL`、`FROZEN`、`USER_ONLY`、`EXCLUDED`、`DONE`、`ARCHIVED`のいずれかとする。
- `FROZEN`は明示的な再開指示なしに着手しない。
- `USER_ONLY`はユーザー専任とし、AIは着手、代行、催促を行わない。
- `WAITING_EXTERNAL`は外部条件が解消するまで着手可能とみなさない。
- Task precedenceには内部task間の必須AND前提だけを記録する。
- 新規または内容更新したtaskの項目名は、`[DECISION]`、`[EXECUTION]`、`[DISCOVERY]`のいずれかで始める。
- `DECISION`は一つのユーザー判断だけを含む。複数の判断がある場合は登録前または発見時に分割する。
- `EXECUTION`と`DISCOVERY`はノー判断taskとし、未確定の判断をagentが補って完了させない。
- Task Registryの確定更新はCodexが担当する。
- 優先順位は、ユーザーの最新指示、Task Registry、詳細正本、Archivedと過去ログの順とする。

## Current summary

- RedBlackTreeの実装、正当性検証、主要な公開面整理は完了済み。
- RedBlackTreeは外部要件待ちのIndex判断と並行して、見えていない残作業の棚卸しと利用者向け文書の準備を進める。
- Permutationは互換modeの手順決定に加え、品質評価、利用者向け使用例、他packageとの名前衝突を確認する。
- OptionalArrayはCodex管理で体系監査を再開し、BareArrayとstorage再設計は管理方式の検証後まで凍結する。
- Claudeのtask graph DB試験とsmell知見試験が進行中。
