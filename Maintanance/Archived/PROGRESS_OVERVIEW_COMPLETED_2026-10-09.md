# Task Registry completed history — 2026-10-09

This file preserves task rows and precedence edges removed when the active Registry was compressed.
The exact pre-compression snapshot is commit `42f19324`. Detailed evidence remains in each row’s canonical document.
IDs remain permanent and must not be reused.

## Completed intermediate goals

- 2026-10-09、Claudeへ渡すtask出しを「一つのtaskに一つのユーザー判断、またはユーザー判断なし」まで
  分解できる状態にするゴールから、BareArrayをユーザードキュメント作業へ渡すゴールへ移行した。

## Completed and excluded tasks

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `RBT-002` | `DONE` | User / Codex / Claude | Index-range `erase`の空guard | 2026-10-06、範囲検査を維持して空での不要なCoWを回避（`11817dfe`） | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `DOC-001` | `DONE` | Codex / Claude | P10残存記述確認 | 2026-10-06、監査と必要箇所の同期を完了（`9b0f42d5`） | `MAINTENANCE.md` |
| `GRAPH-003` | `EXCLUDED` | — | 二つのtask graph DBの統合議論 | 2026-10-07、統合方針をdrop。再開候補にしない | `Graph/TASK_GRAPH_DB_EXPERIMENT.md` |
| `GRAPH-006` | `DONE` | Claude / Codex | [DISCOVERY] smell判定共有スキームの最小fixture | 2026-10-08、local DB非依存の共有schema候補とRBT-017 fixtureを作成。Codexが文書件数とO(1)契約への3経路を再構築し、task→symbol辺の入力不在と自己参照除外を既知制約として受入 | `AI_GRAPH_SHARED_SCHEMA.md` |
| `GRAPH-007` | `DONE` | Claude / Codex | [EXECUTION] SQLiteインメモリ共有schema fixture | 2026-10-08、tracked SQL 4 fileで空のSQLite `:memory:`から2 symbol・8区分を再現。Codexが一発command、期待件数、外部キー違反なし、local DB非依存を確認 | `AI_GRAPH_IN_MEMORY_FIXTURE.md` |
| `GRAPH-008` | `DONE` | Claude / Codex | [DISCOVERY] 過去graph知見のインメモリ追試可能性台帳 | 2026-10-08、graph系3文書を23項目へ整理しA〜D分類。CodexがRP-01・05・08・15・17を実装対象として受入 | `Graph/AI_GRAPH_RETROSPECTIVE_REPLAY.md` |
| `GRAPH-009` | `DONE` | Claude / Codex | [EXECUTION] 受入済み過去graph知見のSQLite追試完成判定 | 2026-10-08、GRAPH-007とRP-01・05・08・15・17を一つのcommandで実行し、6件全PASS・exit 0・local DB非依存をCodexが確認 | `Graph/AI_GRAPH_RETROSPECTIVE_REPLAY.md` |
| `GRAPH-010` | `DONE` | Claude / Codex | [EXECUTION] precedence missing-pair fixture | 2026-10-08、task 4件・既存辺2件から辺のない4組を再現しCodexがPASSを確認 | `Graph/AI_GRAPH_RETROSPECTIVE_REPLAY.md` |
| `GRAPH-011` | `DONE` | Claude / Codex | [EXECUTION] specification file role fixture | 2026-10-08、旧・現行規則を2 snapshotへ適用し、番号0〜4がspec、98・99がnon-specとなるPASSを確認 | `Graph/AI_GRAPH_RETROSPECTIVE_REPLAY.md` |
| `GRAPH-012` | `DONE` | Claude / Codex | [EXECUTION] configuration-aware spec-gap fixture | 2026-10-08、DEBUG限定を除きRelease公開gapがtest追加前1件・追加後0件となるPASSを確認 | `Graph/AI_GRAPH_RETROSPECTIVE_REPLAY.md` |
| `GRAPH-013` | `DONE` | Claude / Codex | [EXECUTION] document match precision fixture | 2026-10-08、基準snapshotの単語照合36件・所属型併用9件と自己参照後38・9件のPASSを確認 | `Graph/AI_GRAPH_RETROSPECTIVE_REPLAY.md` |
| `GRAPH-014` | `DONE` | Claude / Codex | [EXECUTION] observation staleness fixture | 2026-10-08、古い観測をstale、再構築後をnot staleとするPASSを確認 | `Graph/AI_GRAPH_RETROSPECTIVE_REPLAY.md` |
| `GRAPH-015` | `DONE` | User / Codex | [DECISION] Task precedence Gateの意味と段階移行 | 2026-10-08、`START`・`COMPLETE`・移行中の`UNCLASSIFIED`を定義し、現役辺pilot、fixture検証、残辺移行の順に浸透させると決定 | `Graph/AI_GRAPH_RETROSPECTIVE_REPLAY.md` |
| `GRAPH-016` | `DONE` | Codex | [EXECUTION] Task precedence Gate列のpilot導入 | 2026-10-08、Gate列を追加し、現行`ACTIVE` taskに接続する6辺を`START` 4件・`COMPLETE` 2件へ分類。他の既存辺は`UNCLASSIFIED`のまま保持 | `Graph/AI_GRAPH_RETROSPECTIVE_REPLAY.md` |
| `GRAPH-005` | `DONE` | User / Codex / Claude | ClaudeとCodexのgraph DB交流会 | 2026-10-09、必要な観測交換を終え、ユーザー判断で終了。後続判断によりClaude専用DBだけを継続 | `Graph/TASK_GRAPH_DB_EXPERIMENT.md` |
| `GRAPH-002` | `EXCLUDED` | User / Codex | Codex用task graph DBの独立試験 | 2026-10-09、Registryと意味判断で十分であり、Codex用DBを再開しないと決定 | `Graph/TASK_GRAPH_DB_EXPERIMENT.md` |
| `GRAPH-004` | `EXCLUDED` | User / Codex / Claude | [DISCOVERY] AIとインメモリ関係モデルによるsmell判定スキーム共有試験 | 2026-10-09、継続taskとしては終了。既存schema・fixture・観測を保存し、必要時だけその場の関係整理として再利用する | `Graph/AI_GRAPH_SMELL_NOTES.md` |
| `GRAPH-017` | `EXCLUDED` | — | [EXECUTION] RP-19 readiness fixture | 親目的の共有スキーム試験を終了したため、未実施のfixtureを不要として除外 | `Graph/AI_GRAPH_RETROSPECTIVE_REPLAY.md` |
| `GRAPH-018` | `EXCLUDED` | — | [EXECUTION] Task precedence Gateの段階移行完成判定 | Codex用DBと共有スキームの継続を終了し、DB向けGate移行の完成判定を不要として除外 | `Graph/AI_GRAPH_RETROSPECTIVE_REPLAY.md` |
| `GRAPH-019` | `DONE` | Codex | [EXECUTION] Task Registry構造lintの最小実装 | 2026-10-09、現行MarkdownをSQLiteインメモリDBへ読み込み、cycle・参照切れ・自己依存・重複edge・Gate・条件付き前提をread-only検査する入口を追加 | `Graph/TASK_GRAPH_LINT.md` |
| `OPS-002` | `DONE` | Codex | [DISCOVERY] task分解・インライン化・割当の三段階運用検討 | 2026-10-09、stable ID・依存・履歴は維持し、条件の揃った連続`EXECUTION`だけを一時assignment packageへまとめる方式を採用。判断・凍結・待機taskは対象外とし、新判断や失敗時は元taskへ戻す | `CODEX_TASK_OPERATION_PLAYBOOK.md` |
| `FIT-001` | `DONE` | Codex | [EXECUTION] agent task適性表の現行責任境界の暫定更新 | 2026-10-08、OptionalArray管理方式、全面委譲解除、Codexの統合・受入責任を暫定案として反映 | `AGENT_TASK_FIT_INTERVIEW.md` |
| `FIT-002` | `DONE` | Claude | [DISCOVERY] agent task適性表の暫定更新reviewと自己評価 | 2026-10-08、責任境界、現行補正、OptionalArray 10 package、追加skillについて項目別回答を記録 | `AGENT_TASK_FIT_INTERVIEW.md` |
| `FIT-003` | `DONE` | Codex | [DISCOVERY] agent task適性表の合意・不一致整理 | 2026-10-08、実質的不一致なし。修正提案を条件付き合意へ整理し、OptionalArray固有の疑義は監査packageへ移管 | `AGENT_TASK_FIT_INTERVIEW.md` |
| `FIT-004` | `EXCLUDED` | — | [EXECUTION] agent task適性表の不一致decision登録 | `FIT-003`でユーザー判断を要する実質的不一致が無かったため登録不要 | `AGENT_TASK_FIT_INTERVIEW.md` |
| `FIT-005` | `DONE` | Codex | [EXECUTION] agent task適性表の合意済み最終反映 | 2026-10-08、合意済み責任境界とsmell 4・tuning確認3を現行運用へ反映 | `AGENT_TASK_FIT_INTERVIEW.md` |
| `FIT-006` | `DONE` | Claude | [DISCOVERY] agent task適性表の最終差分確認 | 2026-10-08、3項目を合意どおり、2項目を文言上の留保として記録。能力点・責任境界の異論なし | `AGENT_TASK_FIT_INTERVIEW.md` |
| `FIT-007` | `DONE` | Codex | [EXECUTION] agent task適性表更新の完成判定 | 2026-10-08、2件の留保を合意済み文言の欠落として補正し、新しい不一致なく更新全体を完了 | `AGENT_TASK_FIT_INTERVIEW.md` |
| `RBT-003` | `DONE` | Codex / Claude | `Result`のpublic比較overloadとpublic `_NodePtr` | 2026-10-07、公開面縮小と検証を完了。performance job成功を確認 | `EXTERNAL_TYPE_EXTENSION_AUDIT.md` |
| `RBT-012` | `DONE` | Claude | Swift 6.4 `-O`のCoW誤コンパイルに対する値セマンティクスのTest as Spec拡充 | 2026-10-07、closure-captured mutation形状を4型へ追加し、Debug / Releaseで値セマンティクス維持を確認（`4249ed8c`） | `Tests/RedBlackTreeTests/` |
| `RBT-013` | `DONE` | Claude | RedBlackTree sourceのTODO/FIXME棚卸し | 2026-10-07、27件を分類。文書へ影響するRange View検査と公開API名、古いコメント2件を判断候補として報告 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `PERM-016` | `DONE` | Claude | [EXECUTION] Permutation品質評価の事実更新 | 2026-10-07、解消済み`swapAt`懸念を除き、header二重破棄、終端の不要copy、走査共有、Debug限定検査member、行数を反映（`127a0d5b`） | `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` |
| `PERM-017` | `DONE` | Codex | Permutation品質評価R-1〜R-4 review | 2026-10-08、品質特性の読み替え、1.0前改善候補、文書形式の選択肢、事実参照をreviewし初版を完成 | `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` |
| `RBT-015` | `DONE` | Codex | RedBlackTree残task文書の事実更新 | 2026-10-08、PR #158前後の時制、success-only Index分離済みと外部待ちgate、削除済みTODOの表現を現状へ同期 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-017` | `EXCLUDED` | — | [EXECUTION] Mapped Values Range Viewの範囲外更新防止ゲート | 2026-10-08、範囲所属は呼び出し側の事前条件、単一Index操作はO(1)と`211ca2fc`で確定済みのため変更不要 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-018` | `EXCLUDED` | — | [DISCOVERY] Mapped Values ViewのIndex検査条件調査 | 2026-10-08、調査は既存のAPI Matrix・仕様testを見落としており、追加判断が必要という前提を撤回 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-019` | `EXCLUDED` | — | [DECISION] 全体Mapped Values Viewの範囲検査 | 既存のO(1)契約を維持するため判断不要 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-020` | `EXCLUDED` | — | [DECISION] 部分Mapped Values Viewの更新計算量 | O(1)を維持する契約が確定済みのため判断不要 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-021` | `EXCLUDED` | — | [DECISION] Mapped Values View範囲外停止メッセージ | 範囲所属を操作内で検査しないため判断不要 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-022` | `EXCLUDED` | — | [DECISION] Mapped Values View getterの範囲検査 | getterもO(1)契約を維持するため判断不要 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-023` | `EXCLUDED` | — | [DECISION] Mapped Values View範囲判定helperのinline境界 | 新helperを追加しないため判断不要 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-024` | `EXCLUDED` | — | [EXECUTION] Mapped Values View範囲検査の実装と機能検証 | 既存契約に反する実装となるため実施しない。試行差分は破棄済み | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-025` | `EXCLUDED` | — | [EXECUTION] Mapped Values View範囲検査の性能確認 | 実装を行わないため性能確認も不要 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-027` | `DONE` | Claude | [DISCOVERY] RedBlackTree残task文書のbranch・commit時制ledger | 2026-10-08、PR #158前後と現行HEADの記述を現行／履歴／曖昧へ分類し、commit根拠を記録 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-028` | `DONE` | Claude | [DISCOVERY] RedBlackTree残task文書とRegistryの状態対応表 | 2026-10-08、checkbox・状態語・task IDをRegistryへ対応し、一致・履歴説明・対応なし・不一致を表化 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-029` | `DONE` | Claude | [DISCOVERY] RedBlackTree残task文書のpath・symbol現存ledger | 2026-10-08、現在形のpath・symbol・flagを存在・移動・削除・構成限定・未確認へ分類 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-030` | `DONE` | Claude | [EXECUTION] RedBlackTree merge前PoC節の時制補正 | 2026-10-08、PR #158前の判断を過去形へ直し、merge後の現行事実と検証正本を明記 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-031` | `DONE` | Claude | [EXECUTION] RedBlackTree完了済みIndex分離と未確定gateの表現補正 | 2026-10-08、success-only分離済みと公開Index最終形・Comparable等の外部待ちを分離して表現 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `PERM-018` | `DONE` | Claude | [EXECUTION] swift-algorithms同時import時のPermutation名前衝突test | 2026-10-07、両moduleの同時import、名前解決、successor列と全順列の使い分けを仕様testで固定（`0ff5fd84`） | `Tests/PermutationTests/NextPermutationsSequence/` |
| `PERM-019` | `EXCLUDED` | — | [EXECUTION] 利用者向けPermutation使用例の仕様test化 | 2026-10-08、使用例の選定は利用者向け文書作業そのものとして文書フェーズへ移し、独立taskから除外 | `Tests/PermutationTests/NextPermutationsSequence/` |
| `PERM-020` | `DONE` | Claude | [DISCOVERY] Permutation公開API・コメントledger | 2026-10-08、公開宣言14件と別枠の公開適合9件をsource位置・制約・属性・コメントへ対応 | `PermutationModule/DocumentationHandoffAudit.md` |
| `PERM-021` | `DONE` | Claude | [DISCOVERY] Permutation公開契約と仕様testの対応表 | 2026-10-08、番号付きtestが固定する契約と未検証事項を公開宣言へ対応 | `PermutationModule/DocumentationHandoffAudit.md` |
| `PERM-022` | `DONE` | Claude | [DISCOVERY] Permutation名称・契約履歴ledger | 2026-10-08、現行名称、削除済みAPI、通常版・互換mode・facadeの決定済み／履歴事実／未決定を分離 | `PermutationModule/DocumentationHandoffAudit.md` |
| `PERM-023` | `DONE` | Codex | [EXECUTION] Permutationユーザードキュメント作業への引き渡し判定 | 2026-10-08、公開面、test根拠、履歴、品質評価を検収し、残る判断を分離して文書作業へ引き渡し可能と判定 | `PermutationModule/DocumentationHandoffAudit.md` |
| `PERM-024` | `DONE` | Claude | [DISCOVERY] Permutation品質評価の根拠参照照合 | 2026-10-08、commit・file・test・数値参照を照合し、不一致1件と未確認2件を評価変更せず記録 | `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` |
| `PERM-025` | `DONE` | Claude | [EXECUTION] Permutation品質評価の事実参照補正 | 2026-10-08、共存test、改名理由、Release確認日の3点を根拠へ同期し、共存性の評価判断をCodexへ返却 | `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` |
| `PERM-026` | `DONE` | Claude | [DISCOVERY] Permutation共存性の残存evidence gap確認 | 2026-10-08、通常版、facade、凍結中の互換modeを分離して検証済み・未検証範囲を整理 | `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` |
| `PERM-027` | `DONE` | Claude | [DISCOVERY] Permutation 1.0前改善候補3件の実施前提整理 | 2026-10-08、性能CI、C++差分比較、Linux Death Testの現状・基盤・依存・未確認を採否判断なしで整理 | `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` |
| `RBT-016` | `EXCLUDED` | — | `RedBlackTreePair.tuple`の仕様test | 2026-10-07、型全体がdocumentation上internalで公開仕様testは不要。graphのspec-gap検出を修正して0件を確認 | `Tests/RedBlackTreeTests/` |
| `PERM-001` | `DONE` | Codex | AtCoder 2025互換mode | 2026-10-09、互換source、trait、仕様test、再公開、単一file、文書同期を完了。CI分離は統合後へ移管 | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-003` | `DONE` | Claude | 現行Permutation契約の基準固定 | 2026-10-07、削除済みAPIの非露出をcompile時に固定し、重複要素・非Array入力のtestを追加 | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-011` | `DONE` | Claude | Permutation公開型の改名 | 2026-10-07、`NextPermutationsSequence`/`.Iterator`/`.Permutation`へ改名し`Permutations`名前空間を廃止（source-breaking、ユーザー承認済み） | `Tests/PermutationTests/NextPermutationsSequence/` |
| `PERM-012` | `DONE` | Claude | Permutation仕様のTest as Specification化 | 2026-10-07、仕様をテストの連番fileへ移し、`Specification.md`を削除（ユーザー判断）。テストで表せない約束はソースのドキュメントコメントへ | `Tests/PermutationTests/NextPermutationsSequence/` |
| `PERM-013` | `DONE` | User / Claude / Codex | Permutation性能のCIベース比較 | 2026-10-08、PR #174のperformance job成功とmergeを確認。5計測を継続比較へ追加し、互換導入前の通常版基準を確定 | `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` |
| `PERM-014` | `DONE` | Codex | [EXECUTION] Permutation互換modeの実施手順統合 | 2026-10-08、二つの判断結果から成果単位、commit境界、mode別検証を確定 | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-015` | `DONE` | Codex | [EXECUTION] Permutation互換task依存の再評価 | 2026-10-08、性能基準を互換ソース隔離の着手前提に採用し、実装・test・再公開・CI・単一file・文書のGateを確定 | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-029` | `DONE` | User / Codex | [DECISION] Permutation互換modeでstrict memory safetyを扱うか | 2026-10-08、互換modeから外し、後日独立して取り組み直すと決定 | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-030` | `DONE` | User / Codex | [DECISION] 互換ソース隔離段階の検証範囲 | 2026-10-08、互換module buildだけを確認し、mode別testを後続taskへ送ると決定 | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-031` | `DONE` | Claude / Codex | [DISCOVERY] Permutation 5計測のCI実行構成調査 | 2026-10-08、二つのlibraryと同一結果fileへの追記で、既存sourceのままbase / HEADの5件を比較できると確認 | `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` |
| `PERM-032` | `DONE` | User / Codex | [DECISION] Permutation CI計測の実行構成 | 2026-10-08、二つのlibraryを64k・10で実行し、同じ結果fileへ追記する構成を採用 | `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` |
| `PERM-033` | `DONE` | Claude / Codex | [EXECUTION] Permutation CI計測構成の実装 | 2026-10-08、4件・1件の二library、同一結果file追記、base / HEAD対称性を実装し、構文とtitle集合を検収 | `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` |
| `PERM-034` | `DONE` | Claude / Codex | [DISCOVERY] Permutation sequential subscriptのwitness table参照比較 | 2026-10-09、macOS arm64の同一Release条件で三版のhot path命令列が一致し、witness table参照・特殊化失敗がないことを確認。後続のLinux実CI確認は`PERM-036`で完了 | `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` |
| `PERM-035` | `DONE` | Claude / Codex | [DISCOVERY] Permutation sequential subscript性能回帰のbenchmark二分探索 | 2026-10-09、実benchmarkを交互に各3回測定し中央値1.0053で回帰を再現せず、規定どおり探索を停止。Linux CI候補列を記録 | `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` |
| `PERM-036` | `DONE` | Claude / Codex | [DISCOVERY] Permutation sequential subscriptの実benchmark hot path比較 | 2026-10-09、macOS arm64とLinux x86-64で修正前後の実benchmark binaryを比較。regressed hot loopの命令列は同一で、Linuxでは遅い側だけ64 byte境界をまたぐ配置差を確認。第三者assembly reviewのgetter非inline化仮説とは独立した観測として保持 | `PERFORMANCE_REGRESSION_BISECTION.md` |
| `PERM-037` | `DONE` | User / Codex / Claude | [EXECUTION] performance失敗時の診断artifact拡充 | 2026-10-09、base / HEADの実行済みbenchmark binary、逆アセンブル、symbol、hash、測定JSON、比較結果、runner CPUを失敗時に保存するworkflowへ更新し、引用符不備も補正 | `PERFORMANCE_REGRESSION_BISECTION.md` |
| `PERM-038` | `DONE` | User / Codex | [DISCOVERY] 第三者AIによるPermutation assembly reviewの採用 | 2026-10-09、binary全体の独立比較を構造上の観測として採用。後続のhot-path検証によりgetter非inline化は実測回帰の原因説明として不採用とし、元の仮説は履歴として保持 | `PERFORMANCE_REGRESSION_ASSEMBLY_ANALYSIS.md` |
| `BARE-008` | `DONE` | User / Codex | [DECISION] BareArray監査を再開するか | 2026-10-09、OptionalArrayで検証した管理方式を用いて監査を再開。性能、View寿命、strict memory safetyは後続の1.0判断まで凍結を維持 | `Tests/TESTING.md` |
| `RELEASE-004` | `DONE` | User / Codex | [EXECUTION] 0.5.0の互換準備branch統合 | 2026-10-09、`main`を`prepare/compatible/2`へmergeし、競合解消、Debug・Release全test、互換branch資料整理、remote pushまで完了 | `RELEASE_0_5_0.md` |
| `PERM-008` | `DONE` | Codex | [EXECUTION] Permutation互換branchの有効化とCI分離 | 2026-10-09、branch defineと通常source排他を有効化。互換機能testを維持し、対象外のdocumentation・performance jobを互換branchで停止 | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-004` | `DONE` | Codex | [EXECUTION] AtCoder 2025互換ソースの隔離 | 2026-10-09、基準2 fileを条件付き専用fileへ隔離。0.5.0の通常sourceは無条件compileへ戻し、排他切替は後続branch統合時へ移管 | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-005` | `EXCLUDED` | — | Permutation互換traitのPackage設定 | 2026-10-09、0.5.0は通常Permutationだけを公開するためtraitを撤回。互換切替は`prepare/compatible/2`統合後のbranch defineで扱う | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-006` | `DONE` | Codex | 互換modeのTest as Specification | 2026-10-09、列挙順・重複・safe CoW・unsafe aliasing・境界を互換限定5 testで固定 | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-007` | `DONE` | Codex | 両modeのAcCollections再公開検証 | 2026-10-09、AcCollectionsだけをimportした通常API・互換APIのcompileとtest成功を確認 | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-009` | `DONE` | Codex | AtCoder単一file生成とローカル検証 | 2026-10-09、互換2 sourceから自己完結fileを生成し、ABC328E公式sampleでcompile・実行結果33を確認 | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-010` | `DONE` | Codex | Permutation互換mode文書同期 | 2026-10-09、現行文書は通常版だけを扱い、互換資料と品質評価は後続branch define・制限・検証結果へ同期 | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `OPT-001` | `DONE` | Codex | [DISCOVERY] OptionalArrayの体系監査・名称再検討 | 2026-10-08、公開7型・29宣言の契約、test、履歴、判断、Test as Specificationを検収し、ユーザードキュメント作業へ引き渡し | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-002` | `DONE` | Codex | [DISCOVERY] OptionalArray監査の管理方式と受入基準の抽出 | 2026-10-08、実績から段階構成、責任境界、受入基準、停止条件を再利用可能な監査方式として抽出 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-005` | `DONE` | Codex / Claude | [DISCOVERY] OptionalArray品質評価の初版策定 | 2026-10-08、9製品品質特性を評価し、既知の不足を利用者向け文書作業と1.0準備へ分離して初版を完成 | `Sources/OptionalArrayModule/Documentation/QualityAssessment-ISO25010.md` |
| `OPT-007` | `DONE` | Codex | [EXECUTION] OptionalArray監査の暫定受入基準策定 | 2026-10-08、公開宣言網羅、契約・test・履歴対応、判断分離、引き渡し成果物を監査開始前の基準として確定 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-008` | `DONE` | Codex | [DISCOVERY] OptionalArray公開7型の宣言・契約・履歴監査 | 2026-10-08、29宣言と4適合の契約・履歴を棚卸しし、決定記録のない4件を判断候補として分離 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-009` | `DONE` | Codex | [DISCOVERY] OptionalArray公開契約とtest根拠の対応監査 | 2026-10-08、実装・test・利用例・coverageを公開宣言へ対応し、未検証範囲と本文不一致を確定・同期 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-010` | `DONE` | Codex | [DISCOVERY] OptionalArrayの型名・次元API体系監査 | 2026-10-08、OptionalArrayとBareArrayの型名・View名・次元label・property・軸対応を比較し、不揃いを判断候補へ分離 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-011` | `DONE` | Codex | [EXECUTION] OptionalArray監査で見つかった判断taskの登録 | 2026-10-08、位置づけ、1D型名、次元名、不正次元契約を一判断ずつ4 taskへ分離登録 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-012` | `DONE` | Codex | [EXECUTION] OptionalArrayModuleTestsのTest as Specification整理 | 2026-10-08、通常35件とDeath Test 21件を番号付き仕様fileへ整理し、test集合・契約対応・実行結果を完成検収 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-013` | `DONE` | Codex | [EXECUTION] OptionalArrayのユーザードキュメント作業への引き渡し判定 | 2026-10-08、契約表、test対応、決定事項、既知の不足、文書入力を検収し、追加判断なしで引き渡し可能と判定 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-014` | `DONE` | Codex | [EXECUTION] OptionalArray3DViewの2D面stride修正 | 2026-10-08、非対称次元testで修正前のslice aliasを確認し、offsetを`width * height * position`へ修正。NOP setterは連鎖writeback用と明文化 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-015` | `DONE` | Claude | [DISCOVERY] OptionalArray公開宣言29件のledger作成 | 2026-10-08、型7・init 4・removeAll 4・subscript 7・indices 7をsource位置とコメントへ対応 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-016` | `DONE` | Claude | [DISCOVERY] OptionalArray所有4型のtest根拠表 | 2026-10-08、4型のinit、removeAll、subscript、indices、Sendable、deinitの根拠と不足を表化 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-017` | `DONE` | Claude | [DISCOVERY] OptionalArray View 3型のtest根拠表 | 2026-10-08、非所有性、storage共有、subscript、indicesの直接・間接証拠と不足を表化 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-018` | `DONE` | Claude | [DISCOVERY] OptionalArray境界test matrix | 2026-10-08、所有型・Viewの負値／上端、read／write、Debug／Release／`-Ounchecked`を表化 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-019` | `DONE` | Claude | [DISCOVERY] OptionalArray参照型寿命test matrix | 2026-10-08、構築、上書き、nil、removeAll、再利用、deinitの期待破棄数と既存testを表化 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-020` | `DONE` | Claude | [DISCOVERY] OptionalArray次元・offset式の独立照合 | 2026-10-08、非対称次元で2D〜4DとViewのoffset・indicesを机上および一時実行で照合 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-021` | `DONE` | Claude | [DISCOVERY] OptionalArray Sendable採用履歴の事実確認 | 2026-10-08、導入commit、後続変更、現行test、未記録の導入理由と利用範囲を分離 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-022` | `DONE` | Claude | [DISCOVERY] OptionalArray不正次元の現挙動確認 | 2026-10-08、zero・負値・overflowを構成別に確認し、`-Ounchecked`の安全性疑義で方針判断せず停止 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-023` | `DONE` | Claude | [DISCOVERY] OptionalArray EDPC利用例の責務分類 | 2026-10-08、使用公開面、capture・連鎖subscript形状、DP固有部分、未実行状態を分類 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-024` | `DONE` | Claude | [DISCOVERY] OptionalArrayコメントドックcoverage表 | 2026-10-08、29宣言の境界・所有・寿命・破棄・変更・計算量の明示記載を棚卸し | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-025` | `DONE` | Claude | [DISCOVERY] OptionalArray証拠packageの受入基準coverage照合 | 2026-10-08、10 packageを29宣言と受入基準へ再配置し、既知の本文不一致2件とcoverage不足を表化 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-026` | `DONE` | Claude | [EXECUTION] OptionalArray監査本文の証拠同期 | 2026-10-08、Sendable testは1Dのみ、EDPC利用例は未実行のcompile対象という事実へ本文を同期 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-027` | `DONE` | Claude | [DISCOVERY] OptionalArray判断候補4件の決定来歴確認 | 2026-10-08、4件とも明示決定なし。用途・名称・次元は実装事実、不正次元は履歴なしとして確認 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-028` | `DONE` | Claude | [DISCOVERY] OptionalArray・BareArray名称次元surface比較 | 2026-10-08、現行宣言の型名・View名・initializer・property・subscript軸・indices軸を対応表化 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-029` | `DONE` | User / Codex | [DECISION] OptionalArrayの公開位置づけ | 2026-10-08、競技プログラミング用の低レベル公開部品として1.0でも公開を継続すると決定 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-030` | `DONE` | User / Codex | [DECISION] OptionalArray 1D所有型の名称 | 2026-10-08、`OptionalArray1D`を維持。BareArray再開時または文書作業で具体的問題が判明した場合は再検討可能 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-031` | `DONE` | User / Codex | [DECISION] OptionalArray 2D〜4Dの次元名称体系 | 2026-10-08、2D／3Dの意味名と4Dの`size0`〜`size3`という現行体系を維持 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-032` | `DONE` | User / Codex | [DECISION] OptionalArray initializerの不正次元契約 | 2026-10-08、各次元は0以上、zeroは許可、次元積は`Int`で表現可能であることを事前条件に決定 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-033` | `DONE` | Claude | [EXECUTION] OptionalArray次元事前条件の実装と仕様test | 2026-10-08、非負・積overflow検査、zero成功、負値・overflow停止を実装しDebug／Releaseで固定 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-034` | `DONE` | Claude | [EXECUTION] OptionalArray4D zero-volume外側subscriptのoverflow回避 | 2026-10-08、内側zero軸では途中積を評価せず空Viewへ辿れるよう修正しDebug／Releaseで固定 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-035` | `DONE` | Claude | [DISCOVERY] OptionalArray Test as Specification配置・移行設計 | 2026-10-08、8仕様群と利用例へ分類し、段階移行可否、並列化・Death Test制約を整理 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-036` | `DONE` | Claude / Codex | [EXECUTION] OptionalArray通常testの番号付き仕様file分割 | 2026-10-08、通常35件をXCTestのまま`OptionalArray_0_`〜`_6_`へ一度ずつ移し、test名集合一致と成功をCodexが確認 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-037` | `DONE` | Claude / Codex | [EXECUTION] OptionalArray Death Testの番号付きfile改名 | 2026-10-08、Swift Testing 21件、構成、保存指示を維持した100% renameと成功をCodexが確認 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-038` | `DONE` | Codex | [EXECUTION] OptionalArray Test as Specification完成判定 | 2026-10-08、file番号、test名集合、契約対応、通常35件・Death Test 21件の結果と`Tests/TESTING.md`同期を検収 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-039` | `DONE` | Claude / Codex | [DISCOVERY] OptionalArrayの機能適合性・信頼性・安全性の証拠表 | 2026-10-08、公開契約、仕様test、Death Test、境界・寿命・次元の事実・根拠・未検証範囲をCodexが受入 | `Sources/OptionalArrayModule/Documentation/QualityAssessment-ISO25010.md` |
| `OPT-040` | `DONE` | Claude / Codex | [DISCOVERY] OptionalArrayの性能効率性・互換性・柔軟性の証拠表 | 2026-10-08、benchmark、計算量、SwiftPM、platform、再公開・同時利用の既存根拠をCodexが受入 | `Sources/OptionalArrayModule/Documentation/QualityAssessment-ISO25010.md` |
| `OPT-041` | `DONE` | Claude / Codex | [DISCOVERY] OptionalArrayのインタラクション能力・セキュリティ・保守性・利用時品質の証拠表 | 2026-10-08、コメント、誤用、unsafe境界、View寿命、source・test構成、利用例の証拠をCodexが受入 | `Sources/OptionalArrayModule/Documentation/QualityAssessment-ISO25010.md` |
| `OPT-042` | `DONE` | Codex | [EXECUTION] OptionalArray品質評価初版の統合・完成判定 | 2026-10-08、証拠3 packageを統合し、評価語、既知の不足、文書作業と1.0準備への引き渡しを確定 | `Sources/OptionalArrayModule/Documentation/QualityAssessment-ISO25010.md` |
| `OPT-003` | `DONE` | User / Codex | [DECISION] Claude向け委任規則を明文化するか | 2026-10-09、独立文書は作らず、必要な責任境界・成果物・停止条件を既存のAGENTS規則とplaybookへ保持すると決定 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-004` | `EXCLUDED` | — | [EXECUTION] Claude向け委任規則の明文化 | `OPT-003`で独立文書を作らないと決定し、必要事項は既存規則へ吸収済みのため独立実行を除外 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `CPP-001` | `DONE` | Codex / Claude | C++挙動比較 | 比較契約または対象環境を変更する場合だけ更新 | `Sources/RedBlackTreeCollections/Documentation/Cpp-Matrix.md` |
| `CPP-002` | `EXCLUDED` | — | MSVC STLとのC++挙動比較 | 現行計画では実施しない | `Sources/RedBlackTreeCollections/Documentation/Cpp-Matrix.md` |
| `RELEASE-001` | `DONE` | User / Codex | [DECISION] 0.5.0のtag地点 | 2026-10-08、PermutationのAtCoder 2025互換mode完成を含む状態と決定 | `RELEASE_0_5_0.md` |
| `RELEASE-002` | `DONE` | Codex | [EXECUTION] 0.5.0 release gateの実施 | 2026-10-09、互換trait撤回とinline安定化後、PR #175のDebug・Release・documentation・ASan・performance全成功を確認 | `RELEASE_0_5_0.md` |
| `RELEASE-003` | `DONE` | User / Codex | [EXECUTION] 0.5.0 tag作成 | 2026-10-09、ユーザー確認後、`main`のmerge commit `0dc1bd26`へannotated tag `0.5.0`を作成 | `RELEASE_0_5_0.md` |

## Completed precedence history

| 後続task | 前提task | Gate | 制約 |
| --- | --- | --- | --- |
| `GRAPH-007` | `GRAPH-006` | `UNCLASSIFIED` | 共有schema候補と期待結果をCodexが受入後、SQLiteインメモリfixtureへ変換する |
| `GRAPH-008` | `GRAPH-007` | `UNCLASSIFIED` | 実行可能fixtureの受入後、同じ方式で過去知見の追試可能性を分類する |
| `GRAPH-010` | `GRAPH-008` | `UNCLASSIFIED` | 追試可能性台帳の受入後、RP-01をfixture化する |
| `GRAPH-011` | `GRAPH-008` | `UNCLASSIFIED` | 追試可能性台帳の受入後、RP-05をfixture化する |
| `GRAPH-012` | `GRAPH-008` | `UNCLASSIFIED` | 追試可能性台帳の受入後、RP-08をfixture化する |
| `GRAPH-013` | `GRAPH-008` | `UNCLASSIFIED` | 追試可能性台帳の受入後、RP-15をfixture化する |
| `GRAPH-014` | `GRAPH-008` | `UNCLASSIFIED` | 追試可能性台帳の受入後、RP-17をfixture化する |
| `GRAPH-009` | `GRAPH-010` | `UNCLASSIFIED` | precedence fixture受入後に追試全体を完成判定する |
| `GRAPH-009` | `GRAPH-011` | `UNCLASSIFIED` | specification role fixture受入後に追試全体を完成判定する |
| `GRAPH-009` | `GRAPH-012` | `UNCLASSIFIED` | configuration-aware spec-gap fixture受入後に追試全体を完成判定する |
| `GRAPH-009` | `GRAPH-013` | `UNCLASSIFIED` | document match fixture受入後に追試全体を完成判定する |
| `GRAPH-009` | `GRAPH-014` | `UNCLASSIFIED` | observation staleness fixture受入後に追試全体を完成判定する |
| `GRAPH-016` | `GRAPH-015` | `START` | Gateの意味と段階移行方針の決定後にpilotを開始する |
| `GRAPH-017` | `GRAPH-016` | `START` | 確定したpilot分類をfixture入力にする |
| `GRAPH-018` | `GRAPH-017` | `UNCLASSIFIED` | RP-19でready判定の意味一致を確認後、残る辺を段階移行する |
| `GRAPH-004` | `GRAPH-009` | `COMPLETE` | 過去知見の追試fixture群の受入後に共有スキーム試験の次段階を判断する |
| `GRAPH-004` | `GRAPH-018` | `COMPLETE` | Gate移行の完成判定後に共有スキーム試験全体を完了できる |
| `PERM-017` | `PERM-016` | `UNCLASSIFIED` | 品質評価の事実更新後にreviewする |
| `PERM-017` | `PERM-024` | `UNCLASSIFIED` | 根拠参照の機械照合後に品質評価reviewを完了する |
| `PERM-017` | `PERM-025` | `UNCLASSIFIED` | 確認済みの事実参照補正後に品質評価reviewを完了する |
| `PERM-017` | `PERM-026` | `UNCLASSIFIED` | 共存性の検証済み・未検証範囲を確認後に品質評価reviewを完了する |
| `PERM-017` | `PERM-027` | `UNCLASSIFIED` | 1.0前改善候補3件の実施前提を確認後に品質評価reviewを完了する |
| `PERM-023` | `PERM-017` | `UNCLASSIFIED` | 品質評価review後に文書作業への引き渡しを判定する |
| `PERM-023` | `PERM-020` | `UNCLASSIFIED` | 公開API ledgerをCodexが検収後、引き渡しを判定する |
| `PERM-023` | `PERM-021` | `UNCLASSIFIED` | test evidence matrixをCodexが検収後、引き渡しを判定する |
| `PERM-023` | `PERM-022` | `UNCLASSIFIED` | 名称・契約履歴ledgerをCodexが検収後、引き渡しを判定する |
| `RBT-015` | `RBT-027` | `UNCLASSIFIED` | branch・commit時制の全件確認後に内部残task文書を更新する |
| `RBT-015` | `RBT-028` | `UNCLASSIFIED` | Registryとチェック状態の対応確認後に内部残task文書を更新する |
| `RBT-015` | `RBT-029` | `UNCLASSIFIED` | path・symbolの現存確認後に内部残task文書を更新する |
| `RBT-015` | `RBT-030` | `UNCLASSIFIED` | merge前PoC記録の時制補正後に内部残task文書を完了判定する |
| `RBT-015` | `RBT-031` | `UNCLASSIFIED` | 完了済みIndex分離と未確定gateの表現分離後に内部残task文書を完了判定する |
| `PERM-014` | `PERM-003` | `START` | 現行契約の基準固定後に手順を決定できる |
| `PERM-014` | `PERM-029` | `COMPLETE` | strict memory safetyの扱いを決定後に実施手順を完成できる |
| `PERM-014` | `PERM-030` | `COMPLETE` | 初期検証範囲を決定後に実施手順を完成できる |
| `PERM-015` | `PERM-014` | `START` | 実施手順の決定後にtask依存を再評価できる |
| `PERM-004` | `PERM-013` | `START` | 互換file追加前の通常版で性能基準を取得する |
| `PERM-032` | `PERM-031` | `START` | 実行可能な最小構成を把握してから構成を決定する |
| `PERM-033` | `PERM-032` | `START` | 決定済みの構成だけを実装する |
| `PERM-013` | `PERM-033` | `COMPLETE` | CI設定を実装後、pushとperformance jobの結果確認を経て性能基準取得を完了する |
| `PERM-004` | `PERM-015` | `START` | task依存の再評価とRegistry反映後に着手できる |
| `PERM-005` | `PERM-004` | `START` | 前提taskの完了後に着手できる |
| `PERM-006` | `PERM-005` | `START` | 前提taskの完了後に着手できる |
| `PERM-007` | `PERM-006` | `START` | 前提taskの完了後に着手できる |
| `PERM-009` | `PERM-007` | `START` | 前提taskの完了後に着手できる |
| `PERM-010` | `PERM-007` | `START` | 前提taskの完了後に着手できる |
| `PERM-010` | `PERM-009` | `START` | 前提taskの完了後に着手できる |
| `PERM-001` | `PERM-010` | `COMPLETE` | 前提taskの完了後に後続taskを完了できる |
| `OPT-002` | `OPT-001` | `UNCLASSIFIED` | OptionalArray監査の完了後に実績から管理方式を抽出する |
| `OPT-005` | `OPT-001` | `UNCLASSIFIED` | 体系監査の完了後に品質評価の初版を策定する |
| `OPT-039` | `OPT-001` | `UNCLASSIFIED` | 体系監査の引き渡し成果物を根拠に機能適合性・信頼性・安全性の事実を整理する |
| `OPT-040` | `OPT-001` | `UNCLASSIFIED` | 体系監査完了後、性能・互換性・柔軟性の既存根拠を整理する |
| `OPT-041` | `OPT-001` | `UNCLASSIFIED` | 体系監査完了後、文書・unsafe境界・保守性・利用文脈の既存根拠を整理する |
| `OPT-042` | `OPT-039` | `UNCLASSIFIED` | 機能適合性・信頼性・安全性の証拠受入後に初版を統合する |
| `OPT-042` | `OPT-040` | `UNCLASSIFIED` | 性能効率性・互換性・柔軟性の証拠受入後に初版を統合する |
| `OPT-042` | `OPT-041` | `UNCLASSIFIED` | インタラクション能力・セキュリティ・保守性・利用時品質の証拠受入後に初版を統合する |
| `OPT-005` | `OPT-042` | `UNCLASSIFIED` | Codexの統合・完成判定後に品質評価初版を完了できる |
| `OPT-010` | `OPT-008` | `UNCLASSIFIED` | 公開契約と過去判断を棚卸しした後に名称・次元体系を比較する |
| `OPT-010` | `OPT-028` | `UNCLASSIFIED` | 現行surfaceの機械的な対応表を検収後、名称・次元体系監査を完了できる |
| `OPT-011` | `OPT-008` | `UNCLASSIFIED` | 公開契約監査後に判断候補を登録する |
| `OPT-011` | `OPT-009` | `UNCLASSIFIED` | test根拠監査後に判断候補を登録する |
| `OPT-011` | `OPT-010` | `UNCLASSIFIED` | 名称・次元体系監査後に判断候補を登録する |
| `OPT-012` | `OPT-009` | `UNCLASSIFIED` | test根拠と不足を把握した後に仕様単位へ整理する |
| `OPT-012` | `OPT-029` | `UNCLASSIFIED` | 公開位置づけの決定後に仕様testの範囲を確定する |
| `OPT-012` | `OPT-030` | `UNCLASSIFIED` | 1D型名の決定後に仕様testの名称を確定する |
| `OPT-012` | `OPT-031` | `UNCLASSIFIED` | 次元名称体系の決定後に次元契約testを整理する |
| `OPT-012` | `OPT-032` | `UNCLASSIFIED` | 不正次元契約の決定後に境界testを整理する |
| `OPT-012` | `OPT-033` | `UNCLASSIFIED` | 決定済みの次元事前条件を実装・仕様test化した後、test全体を整理する |
| `OPT-012` | `OPT-035` | `UNCLASSIFIED` | 番号付き仕様fileと段階的移行の設計をCodexが検収後、test全体を整理する |
| `OPT-036` | `OPT-035` | `UNCLASSIFIED` | 受入済み配置案とCodexの小判断に従い通常testを分割する |
| `OPT-037` | `OPT-035` | `UNCLASSIFIED` | 受入済み配置案に従いDeath Test fileを改名する |
| `OPT-038` | `OPT-036` | `UNCLASSIFIED` | 通常testの番号付き分割後に全体を検収する |
| `OPT-038` | `OPT-037` | `UNCLASSIFIED` | Death Test file改名後に全体を検収する |
| `OPT-012` | `OPT-038` | `UNCLASSIFIED` | Codexの完成検収後にTest as Specification整理を完了できる |
| `OPT-033` | `OPT-034` | `UNCLASSIFIED` | zero-volume 4Dの有効なView取得を固定した後、次元事前条件taskを完了できる |
| `OPT-013` | `OPT-011` | `UNCLASSIFIED` | 必要な判断taskを登録・完了または除外した後に引き渡し判定する |
| `OPT-013` | `OPT-012` | `UNCLASSIFIED` | Test as Specification整理後に引き渡し判定する |
| `OPT-001` | `OPT-013` | `UNCLASSIFIED` | 引き渡し検収後に親taskを完了できる |
| `OPT-008` | `OPT-015` | `UNCLASSIFIED` | 公開宣言ledgerをCodexが検収後、契約・履歴監査を完了できる |
| `OPT-008` | `OPT-020` | `UNCLASSIFIED` | 次元・offset式の独立照合をCodexが検収後、契約監査を完了できる |
| `OPT-008` | `OPT-021` | `UNCLASSIFIED` | Sendable履歴調査をCodexが検収後、契約監査を完了できる |
| `OPT-008` | `OPT-022` | `UNCLASSIFIED` | 不正次元の現挙動をCodexが検収後、契約監査を完了できる |
| `OPT-009` | `OPT-016` | `UNCLASSIFIED` | 所有型のtest根拠表をCodexが検収後、test対応監査を完了できる |
| `OPT-009` | `OPT-017` | `UNCLASSIFIED` | Viewのtest根拠表をCodexが検収後、test対応監査を完了できる |
| `OPT-009` | `OPT-018` | `UNCLASSIFIED` | 境界test matrixをCodexが検収後、test対応監査を完了できる |
| `OPT-009` | `OPT-019` | `UNCLASSIFIED` | 寿命test matrixをCodexが検収後、test対応監査を完了できる |
| `OPT-009` | `OPT-023` | `UNCLASSIFIED` | EDPC利用例の責務分類をCodexが検収後、test対応監査を完了できる |
| `OPT-009` | `OPT-024` | `UNCLASSIFIED` | コメントドックcoverageをCodexが検収後、test対応監査を完了できる |
| `OPT-008` | `OPT-025` | `UNCLASSIFIED` | 受入基準coverageの横断照合をCodexが検収後、契約・履歴監査を完了できる |
| `OPT-009` | `OPT-025` | `UNCLASSIFIED` | 受入基準coverageの横断照合をCodexが検収後、test対応監査を完了できる |
| `OPT-008` | `OPT-026` | `UNCLASSIFIED` | 監査本文の事実を証拠表へ同期後、契約・履歴監査を完了できる |
| `OPT-009` | `OPT-026` | `UNCLASSIFIED` | 監査本文の事実を証拠表へ同期後、test対応監査を完了できる |
| `OPT-008` | `OPT-027` | `UNCLASSIFIED` | 判断候補4件の決定来歴を確認後、契約・履歴監査を完了できる |
| `FIT-003` | `FIT-002` | `UNCLASSIFIED` | Claudeの独立review後にCodexが合意・不一致を整理する |
| `FIT-004` | `FIT-003` | `UNCLASSIFIED` | 合意整理後、残ったユーザー判断を一件ずつ登録する |
| `FIT-005` | `FIT-003` | `UNCLASSIFIED` | 両agentの合意範囲が明確になった後に最終反映する |
| `FIT-005` | `FIT-004` | `UNCLASSIFIED` | 必要な不一致decisionを登録し、各判断が完了または除外された後に最終反映する |
| `FIT-006` | `FIT-005` | `UNCLASSIFIED` | Codexの最終反映後、Claudeが合意matrixとの取り違えを確認する |
| `FIT-007` | `FIT-006` | `UNCLASSIFIED` | Claudeの最終確認後、Codexが留保を検収して完成判定する |
| `RELEASE-002` | `RELEASE-001` | `START` | 0.5.0へ含める到達範囲を決定後にrelease gateを実施する |
| `RELEASE-002` | `PERM-001` | `START` | 互換mode完成後に0.5.0 release gateを開始する |
| `RELEASE-002` | `PERM-034` | `COMPLETE` | performance赤の生成コード要因を確認後にrelease gateを最終判定する |
| `RELEASE-002` | `PERM-035` | `COMPLETE` | performance赤の再現性とcommit境界を確認後にrelease gateを最終判定する |
| `RELEASE-003` | `RELEASE-002` | `START` | release gate成功後に対象commitへtagを作成する |

## Satisfied edges removed from the active graph

後続taskは現役だが、前提taskが完了・Archive済みのため、ready判定を自己完結させる目的で現行graphから
退避した辺。後続task固有の再開条件は現行Registry行に残る。

| 後続task | 完了済み前提task | Gate | 制約 |
| --- | --- | --- | --- |
| `RBT-014` | `RBT-013` | `UNCLASSIFIED` | TODO/FIXMEの文書影響を分類後にoutlineを照合する |
| `OPT-003` | `OPT-002` | `UNCLASSIFIED` | 管理方式と受入基準の抽出後に明文化の要否を判断する |
| `BARE-008` | `OPT-002` | `UNCLASSIFIED` | OptionalArrayで管理方式を検証した後にBareArray再開を判断する |
| `OPT-006` | `OPT-005` | `UNCLASSIFIED` | 初版策定後、ユーザードキュメント作業の完了も確認して再評価する |
| `OPT-004` | `OPT-003` | `UNCLASSIFIED` | 明文化すると決定した場合だけ運用規則へ反映する |
| `RELEASE-004` | `RELEASE-003` | `START` | tag対象を確定してから`prepare/compatible/2`へ統合する |

## Maintanance root archive audit

| ID | 状態 | 担当 | 項目 | 完了結果 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `OPS-003` | `DONE` | Codex | [DISCOVERY] Maintanance直下文書の用途・参照inventory | 2026-10-09、27文書を起動・運用、現役正本、継続記録、完了証拠へ分類 | `MAINTENANCE_ROOT_ARCHIVE_AUDIT_2026-10-09.md` |
| `OPS-004` | `DONE` | Codex | [DECISION] 起動・運用正本を待避するか | 直下維持 | `MAINTENANCE_ROOT_ARCHIVE_AUDIT_2026-10-09.md` |
| `OPS-005` | `DONE` | Codex | [DECISION] graph実験文書を待避するか | 完了fixture正本2件だけ待避 | `MAINTENANCE_ROOT_ARCHIVE_AUDIT_2026-10-09.md` |
| `OPS-006` | `DONE` | Codex | [DECISION] 評価・observation文書を待避するか | 旧統合評価1件だけ待避 | `MAINTENANCE_ROOT_ARCHIVE_AUDIT_2026-10-09.md` |
| `OPS-007` | `DONE` | Codex | [DECISION] 技術調査・release文書を待避するか | 未完・凍結・後続作業の正本として直下維持 | `MAINTENANCE_ROOT_ARCHIVE_AUDIT_2026-10-09.md` |
| `OPS-008` | `DONE` | Codex | [EXECUTION] 採用済み文書の待避と参照更新 | 3文書を待避し索引・参照を更新 | `MAINTENANCE_ROOT_ARCHIVE_AUDIT_2026-10-09.md` |
| `OPS-009` | `DONE` | Claude / Codex | [EXECUTION] AI task process posterの作成と正式配置 | 2026-10-09、AIによるtask処理と責任境界を1枚にまとめ、生成scriptとSVGを追跡対象へ移した | `CODEX_TASK_OPERATION_PLAYBOOK.md` |
| `OPS-010` | `DONE` | Codex | [DISCOVERY] AI task process posterの内容照合 | Registryの全9状態、第三者AIの役割、関係性の記述を正本と照合し、修正点を確定 | `CODEX_TASK_OPERATION_PLAYBOOK.md` |
| `OPS-011` | `DONE` | Codex | [EXECUTION] AI task process posterへのreview反映 | 内容照合の指摘を生成scriptと成果物へ反映し、再生成と画像確認を完了 | `CODEX_TASK_OPERATION_PLAYBOOK.md` |
