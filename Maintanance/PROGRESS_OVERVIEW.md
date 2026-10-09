# 開発・メンテナンス進捗一覧

最終更新: 2026-10-09 / Codex

この文書のTask Registryを、CodexとClaudeが作業を再開するときの唯一の入口とする。まずRegistry
だけを読み、選択したtask行が示す詳細正本だけを追加で読む。2026-10-07までの完了チェック、判断待ち、
旧サマリーは`Archived/PROGRESS_OVERVIEW_HISTORY_2026-10-07.md`へ移した。
2026-10-09までの`DONE`・`EXCLUDED` task行と、それらだけに向かう完了済みprecedence辺は
`Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-09.md`へ移した。現行Registryには状態が変わり得るtaskを残す。

## Task Registry

**現在の律速:** 外部（`swift-collections` ContainersPreviewの`Container.Index`要件）。
Index契約と関連taskは、この外部条件が安定するまで最終確定できない。

**中間ゴールの取り扱い**

**現在の中間ゴール:**

- BareArrayを、Codexのユーザードキュメント作業フェーズへ渡せる状態にする。

**後続の中間ゴール:**

- Permutationの利用者向け文書ドラフトを、公開契約と品質評価に接続し、ユーザーが本文をレビューできる
  状態にする。公開可能な初版の完成はこのゴールに含めない。
- OptionalArrayの利用者向け文書ドラフトを、公開契約と品質評価に接続し、ユーザーが本文をレビューできる
  状態にする。公開可能な初版の完成はこのゴールに含めない。
- BareArrayの利用者向け文書ドラフトを、監査で確定した公開契約に接続し、ユーザーが本文をレビューできる
  状態にする。公開可能な初版の完成はこのゴールに含めない。
- 三対象の文書ドラフト作業を通じて作業方式を習熟した後、RedBlackTreeに見えていない残作業を確認し、
  Codexのユーザードキュメント作業フェーズへ渡せる状態にする。
- ユーザードキュメント作業後、OptionalArrayのISO/IEC 25010観点の品質評価を再評価し、
  1.0判断前に解消する不足をtaskへ分離できる状態にする。
- 再評価後、OptionalArrayを1.0として採用できるか判断可能な状態にする。
- BareArrayのユーザードキュメント作業後、性能基準、View寿命、storage再設計、strict memory safetyを
  再評価し、BareArrayを1.0として採用できるか判断可能な状態にする。
- RedBlackTreeのユーザードキュメント作業後、汎用基盤ライブラリの1.0として採用できるか判断可能な
  状態にする。この段階でruntime-check実装を再審査し、その結論とIndex契約を1.0品質ゲートへ渡す。
- 保留中の運用playbookをユーザー指示で再開した後、このrepositoryで得たtask運用知見を、
  別projectでもCodexが同程度の管理品質を再現できる移植可能な形へ整理する。

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
- Permutation通常版と互換modeの文書境界
- 性能の数値を利用者向け文書へ掲載するか
- 1.0ゲート（`QUALITY-001`）との境界
- RedBlackTreeのデバッグ用memberを`#if DEBUG`へ揃えるか

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `RBT-001` | `WAITING_EXTERNAL` | User / Codex | Index完了ゲート | 公開Index表現・完了範囲と`Comparable`採否を確定し、Index契約全体を閉じる | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-010` | `WAITING_EXTERNAL` | User / Codex | Index完了ゲートのうち公開Index表現と完了範囲 | Container要件の安定後、公開Indexと内部`SealError`の分離、1.0での完了範囲を決定 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-011` | `WAITING_EXTERNAL` | User / Codex | Indexの`Comparable`採否 | `swift-collections`の要件が安定または正式化した後、互換性を再評価して決定 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `GRAPH-001` | `ACTIVE` | Claude | Claude用task graph DBの独立試験 | 現行Registryとのready判定一致を確認しながら試験運用を継続 | `Graph/TASK_GRAPH_DB_EXPERIMENT.md` |
| `OPS-001` | `FROZEN` | Codex | [DISCOVERY] Codex task運用playbookの移植可能化 | 2026-10-08、ユーザー指示により保留。明示的な再開指示後、別projectでの再現性検証へ進む | `CODEX_TASK_OPERATION_PLAYBOOK.md` / `PROGRESS_OVERVIEW_TEMPLATE.md` |
| `EVAL-001` | `FROZEN` | Claude | Claudeによる正式なユーザー評価・依頼された感想の記録 | ユーザーが記録を明示的に依頼した時だけ再開し、記録後は再び凍結。Claude自身の任意observation追記は妨げない | `USER_MANAGEMENT_INTERVIEW_CLAUDE.md` / `CLAUDE_OBSERVATIONS.md` |
| `RBT-014` | `FROZEN` | Codex | RedBlackTree文書workflowと4型outlineのAPI照合 | Permutation、OptionalArray、BareArrayのユーザードキュメント作業で方式を習熟した後、ユーザーが再開。workflowと4公開型のoutlineを現在のAPI、test、設計資料と照合し、本文作成へ渡せる状態を確認 | `Sources/RedBlackTreeCollections/Documentation/Head/DOCUMENTATION_WORKFLOW.md` |
| `RBT-026` | `FROZEN` | User / Codex | [DECISION] Mapped Values ViewのO(1)範囲契約再検討 | 利用者向け文書作業フェーズで、View外だがbase treeでは有効なIndexを黙って読み書きし得る性質を踏まえ、O(1)と呼び出し側事前条件の現行契約を維持するか一つだけ再判断 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-004` | `FROZEN` | Codex | Debug限定Comparable群・Balanced群 | Index契約またはexecutable API Matrix方針の確定後 | `EXTERNAL_TYPE_EXTENSION_AUDIT.md` |
| `RBT-005` | `FROZEN` | Codex | Memoize群の公開終了／正式API化 | 外部consumer 2件の移行後 | `EXTERNAL_TYPE_EXTENSION_AUDIT.md` |
| `RBT-006` | `FROZEN` | User / Codex | 未結線コードの個別削除 | ユーザーが対象を個別指定 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `TEST-001` | `FROZEN` | User / Codex | 無効化・歴史的テストコードの処遇 | ユーザーが対象を個別指定 | `Tests/TESTING.md` |
| `TEST-002` | `FROZEN` | Codex | stride assertion／fixture alignmentの任意改善 | 実害または明示的な再開指示 | `Tests/TESTING.md` |
| `PERM-002` | `USER_ONLY` | User | ABC328E実提出確認 | ユーザーが手作業で実施 | `PermutationModule/ImplementationPlan.md` |
| `PERM-028` | `FROZEN` | User / Codex | [DISCOVERY] Permutation strict memory safetyの再検討 | ユーザーが後日明示的に再開したとき、互換modeとは独立に前提、対象構成、警告、完了条件から設計し直す | `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` |
| `OPT-006` | `FROZEN` | Codex | [DISCOVERY] OptionalArray品質評価の文書作業後レビュー | `OPT-005`とユーザードキュメント作業の完了後に再評価し、1.0判断前に解消する不足を独立task候補へ分離 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `BARE-001` | `ACTIVE` | Codex | [DISCOVERY] BareArrayの体系監査・名称再検討 | 公開7型の契約棚卸し、必要な個別判断、Test as Specification整理を受入れ、ユーザードキュメント作業への引き渡し可否を判定する | `BareArrayModule/BareArrayAudit.md` |
| `BARE-002` | `ACTIVE` | Claude | [DISCOVERY] BareArray公開7型の契約棚卸し | 既存のsafety・test証拠を入力に、公開29宣言と4適合の境界・寿命・破棄契約を履歴・OptionalArrayとの対応に照らして閉じ、新しい判断点を分離する | `BareArrayModule/BareArrayAudit.md` |
| `BARE-003` | `FROZEN` | User | [DECISION] BareArrayを低レベル公開部品として維持するか | `BARE-002`後、未決定と判明した場合だけ一つの位置づけを判断。決定済みなら不要として除外 | `BareArrayModule/BareArrayAudit.md` |
| `BARE-004` | `FROZEN` | User | [DECISION] BareArray公開型・次元名の命名体系 | `BARE-003`後、型名、View名、次元property名とOptionalArray1Dとの整合について一つの命名体系を判断 | `BareArrayModule/BareArrayAudit.md` |
| `BARE-005` | `FROZEN` | Claude | [EXECUTION] BareArrayModuleTestsのTest as Specification整理 | `BARE-002`受入時の再計算後、先行する契約判断・不足testが残らない状態で、既存testを番号付きTest as Specificationへ整理。コメントドック全件整備は含めない | `BareArrayModule/BareArrayAudit.md` |
| `BARE-006` | `FROZEN` | Codex | [DISCOVERY] BareArray 1.0の性能測定設計 | ユーザードキュメント作業後、既存のRelease・同一環境・base/HEAD比較・30%回帰判定を前提に、対象操作・size・比較対象を整理。既存方式で閉じない製品判断が出た場合だけ停止 | `Tests/TESTING.md` |
| `BARE-007` | `FROZEN` | Codex | [EXECUTION] BareArray 1.0の性能計測 | `BARE-006`で整理した対象操作・size・比較対象と既存の測定方式に従って計測し、1.0判断へ渡す | `Tests/TESTING.md` |
| `ARRAY-001` | `FROZEN` | Codex | [DISCOVERY] Array系storage・View寿命・strict安全性の再分解 | BareArrayのTest as Specification前に必要な振り分けは`BARE-002`受入へ移管済み。全体再分解はユーザードキュメント作業後、再開時点の契約・品質評価を入力に行う | `StrictMemorySafetyReadiness.md` |
| `RBT-007` | `FROZEN` | User / Codex | RedBlackTreeCollectionsのstrict memory safety全面適用 | ユーザーが段階3を承認 | `StrictMemorySafetyReadiness.md` |
| `BENCH-001` | `FROZEN` | Codex | SortedCollectionsとのpublishableな大規模比較 | ユーザーが明示的に再開 | `Archived/SORTED_COLLECTIONS_BENCHMARK_TASK.md` |
| `TEST-003` | `FROZEN` | Codex | randomized trace失敗時の自動縮小 | 実害または明示的な再開指示 | `Sources/RedBlackTreeCollections/Documentation/Cpp-Matrix.md` |
| `RBT-008` | `FROZEN` | User / Codex | `lazyDetach`等の並行初期化保証 | concurrency契約を扱う明示的な再開指示 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `PERF-001` | `FROZEN` | Codex | Swift更新後のCoWコード生成再計測 | Swift更新または明示的な再計測指示 | `PERFORMANCE_REGRESSION_BISECTION.md` |
| `HIST-001` | `FROZEN` | Codex | unsafe移行史の追加調査 | ユーザーが明示的に再開 | `REFACTORING_FROM_ATCODER_2025.md` |
| `TEST-004` | `FROZEN` | Codex | 原木Fixtureの追加portable化 | 実害または明示的な再開指示 | `Tests/TESTING.md` |
| `RBT-009` | `FROZEN` | User / Codex | [DECISION] runtime-check実装の再審査 | ユーザードキュメント作業後、1.0中間ゴールへ移行した時点、または`-Ounchecked`が主要構成と判明した時点で再開し、現行実装を1.0へ採用するか一つだけ判断 | `Sources/RedBlackTreeCollections/Documentation/Design/Design-RuntimeChecks.md` |
| `QUALITY-001` | `FROZEN` | User / Codex | 汎用基盤ライブラリとしての1.0採用品質ゲート | Index契約確定後、ユーザーが明示的に再開 | `Sources/RedBlackTreeCollections/Documentation/Quality-Checklist.md` |

## Task precedence

| 後続task | 前提task | Flow | 制約 |
| --- | --- | --- | --- |
| `RBT-001` | `RBT-010` | `PARALLEL_JOIN` | 公開Index表現・完了範囲の判断は、Comparable採否と分離したまま親ゲートの完了前に合流する |
| `RBT-001` | `RBT-011` | `PARALLEL_JOIN` | Comparable採否の外部依存は判断task側に残し、親ゲートの完了前に合流する |
| `QUALITY-001` | `RBT-001` | `PARALLEL_JOIN` | 品質調査は並行できるが、1.0品質判定を確定する前にIndex契約完了と合流する |
| `QUALITY-001` | `RBT-009` | `PARALLEL_JOIN` | 他の1.0品質作業は並行できるが、最終判定前にruntime-check実装の採否と合流する |
| `RBT-026` | `RBT-014` | `SEQUENCE` | 現行APIとの照合を判断材料として揃えてからMapped Values契約を再判断する |
| `BARE-005` | `BARE-002` | `SEQUENCE` | 契約棚卸しを受け入れ、先行する契約判断・不足testの有無を再計算した後に整理へ着手できる |
| `BARE-007` | `BARE-006` | `SEQUENCE` | 既存方式に沿った対象操作・size・比較対象の測定設計を入力にして計測する |
| `BARE-001` | `BARE-002` | `PARALLEL_JOIN` | 親監査と契約棚卸しは並行できるが、親監査の完了前に合流する |
| `BARE-001` | `BARE-005` | `PARALLEL_JOIN` | 親監査は先行できるが、完了前にTest as Specification整理と合流する |

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
