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
| `OPS-042` | `DONE` | Claude / Codex（受入・記録） | [EXECUTION] テストダッシュボードの完了記録・旧handoffのアーカイブ | 2026-10-15、ユーザーが古くなった`Tests/TESTING.md`の記載をアーカイブするようClaudeへ依頼。Claudeが完了済みの作業記録・旧handoff・旧監査手順を原文のまま履歴へ移し、現行側を現在の状態と有効な方針へ整理した。成果は`3d5fc0cd`で保存され、`ed3fd951`で現配置へ移動済み。Codexが現行側から履歴への参照、履歴索引、両commitと現存ファイルを照合して受入。採番待ち`CP-20261015-006`の正式統合が当時漏れたため、同日のユーザー指摘を受けて遡及記録した | `Tests/TESTING.md` / `Maintanance/Archived/TestDashboard/TESTING_HISTORY_2026-10-15.md` / `Maintanance/Archived/TestDashboard/README.md` |
| `OPS-041` | `DONE` | Claude / Codex（受入・記録） | [EXECUTION] CLAUDE_TASK受入済み節の履歴圧縮 | 2026-10-15、ユーザーが`CLAUDE_TASK.md`の受入済み節を履歴へ移す常設委任を追加し、Codexへ初回実行の発注記録と姫への依頼を指示。Claudeが受入済み・中止済みの7節を新規履歴へ原文のまま移し、本体へ参照を追加。Codexが圧縮前原文との完全一致、参照先の実在、対象外文書が未変更であることを確認して受入。固定ID、Returnとの対応、返却文面の訂正経緯、Archived索引の登録漏れをユーザー指摘後に修復し、履歴ファイルと受入・Registry記録を同じcommitへ保存して完了 | `Maintanance/CLAUDE_TASK.md` / `Maintanance/Archived/CLAUDE_TASK_HISTORY_2026-10-15.md` / `Maintanance/Archived/README.md` |
| `GRAPH-001` | `ACTIVE` | Claude | Claude用task graph DBの独立試験 | ready判定を維持する常設nodeとして`ACTIVE`を保つ。個別assignmentや実行中ジョブを意味せず、必要なときだけ現行Registryとの一致を確認 | `Maintanance/Graph/TASK_GRAPH_DB_EXPERIMENT.md` |

### 公開とリリース

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `RELEASE-072` | `USER_ONLY` | User | [EXECUTION] 人間向けリリース工程表の作成 | 一枚の工程表の原型は2026-10-12に作成され、その後、旧release資料の一本化、AGENTS.mdを残す区間、AI分担境界が実績に基づいて追記済み。残るのは、実際のreleaseで現在位置・次の操作・完了証拠・停止点を追えるかをユーザーが観測し、工程表として受け入れること。AIは完了を代行判断せず、依頼された整理・レビューだけを補助する | `Maintanance/User/RELEASE_PROCESS.md` |
| `RELEASE-075` | `USER_ONLY` | User | [EXECUTION] リリース工程の不足仕様充当 | 工程表には基本操作、CI確認、候補・最終tag、AI分担境界まで記載済み。定義した品質要求に対する判定基準、証拠取得方法、失敗時の停止・復旧手順など、V&Vに必要な未充当部分をユーザーが補う。AIは不足が解消したと代行判断せず、依頼された整理・レビューだけを補助する | `Maintanance/User/RELEASE_PROCESS.md` / `Maintanance/Current/QUALITY_REQUIREMENTS.md` |
| `RELEASE-076` | `USER_ONLY` | User | [EXECUTION] リリース工程のValidation & Verification | ユーザーが、充当後の工程仕様について、定義した品質要求を満たすことと、意図したリリース目的に適合することを確認する。AIは開始、代行、催促を行わず、依頼された場合だけ検証・レビューを補助する | `Maintanance/User/RELEASE_PROCESS.md` |
| `DOC-010` | `FROZEN` | Codex | [DISCOVERY] ElementBufferの定性的性能表現の再検討 | 2026-10-09に確認した`[[Element]]`との比較意図は、当時の連鎖subscript・非所有Viewを含む設計の履歴である。その公開面は削除され、現行は単一連続storageの座標value accessと借用参照であるため、旧根拠から現行文言を確定しない。ユーザーの明示再開後、現在の操作、比較対象、測定証拠に照らして「C言語の配列に近いアクセス性能」を維持できるか再検討する | `Maintanance/Archived/Canonical/RELEASE_0_5_2.md` / `Maintanance/ElementBufferModule/ElementBufferAudit.md` / `Sources/ElementBufferModule/Documentation/Quality-Profile.md` |
| `DOC-026` | `FROZEN` | User / Codex | [EXECUTION] Swift Package Indexへのpackage登録 | 0.9.x release後、`QUALITY-005`で対象版の登録可が判断され、ユーザーが明示的に再開してから、公式PackageListへ`https://github.com/narumij/swift-ac-collections.git`を追加する外部PRを準備・提出して、package page、互換性表示、module別DocC build結果を確認する | `Maintanance/Current/DOCUMENTATION_CI_PLAN.md` / `Package.swift` |
| `DOC-027` | `FROZEN` | Codex | [EXECUTION] Swift Package Index公開導線のREADME・Pages反映 | `DOC-026`完了後、SPI package pageの`Do you maintain this package?`が提示するMarkdownを正として互換性badgeをREADMEへ追加し、確認できたmodule別DocC URLへの導線をREADMEまたはPagesへ接続する | `Maintanance/Current/DOCUMENTATION_CI_PLAN.md` / `README.md` |
| `DOC-028` | `DONE` | Codex | [EXECUTION] 三対象の利用者向け本文ドラフトのレビュー・反映 | 2026-10-15、ユーザー依頼でPermutation・OptionalElementBuffer・ElementBufferの内部本文ドラフトをレビュー・修正し、反映完了後のDONE登録指示を受領。`a31f23fd`時点のsourceと追記コメント、公開契約、現行提供方針へ照合し、両Bufferの更新方式・一般供用の境界、Permutationの列挙・View寿命・borrowed版の位置づけ、導入例を修正した。未実施のTODOは現行仕様と区別。Apple Swift 6.4 / macOS 27で対象moduleを現行sourceから構築し、本文の使用例9件のcompile・実行・期待値を確認（compiler診断0件）。参照先20件の実在と差分の書式も確認。内部ドラフトのレビュー・反映完了であり、公開初版の完成や利用理解Validationの完了は含まない | `Maintanance/PermutationModule/UserDocumentationDraft.md` / `Maintanance/OptionalElementBufferModule/UserDocumentationDraft.md` / `Maintanance/ElementBufferModule/UserDocumentationDraft.md` |
| `DOC-029` | `DONE` | Codex | [EXECUTION] 非赤黒木コメントドック英訳のソースレビュー・反映 | 2026-10-15、ユーザーからソース直接レビュー、不備の修正、レビューtask追加とDONE記録を委任された。`d04840fc`の英訳差分を元の日本語と照合し、両Bufferの座標・初期化条件・非コピー・nonmutating更新・借用寿命の意味を確認。OptionalElementBuffer全4型の概要で、未設定slotと要素を所有する設定済みslotの区別を明確にし、重複説明を整理した。その後のユーザー訂正によりPermutation互換版は英訳対象外と確認し、同版のコメントドックを元の日本語へ復元。英訳commit全24ファイルがコメント行のみの変更であること、今回のsource変更もコメントのみであること、差分書式を確認。Apple Swift 6.4 / macOS 27でtest targetを含むXcode buildに成功（error 0件）。active test plan `swift-ac-collections`の全テスト操作では1474件成功、失敗0件、skip 0件、256件は`No result`で未実行。プレビュー生成は含まない。公開品質全体の受け入れや凍結中の性能表現判断は含めない | `Sources/OptionalElementBufferModule/OptionalElementBuffer.swift` / `Sources/ElementBufferModule/ElementBuffer.swift` / `Sources/PermutationModule/Compatibility/AtCoder2025/PermutationsAtCoder2025.swift` |
| `RELEASE-007` | `FROZEN` | User / Codex | [DECISION] 0.6.0の到達範囲とrelease検討開始 | `RELEASE-078`で、0.5.3後の公開面、現行品質区分、文書の完成状態、および旧開始条件の差を判断材料として揃えた後、ユーザーが0.6.0へ含める到達範囲とrelease工程へ進むかを一つに決定する。調査完了だけでは凍結を解除しない | `Maintanance/Current/RELEASE_0_6_0.md` / `Maintanance/Current/QUALITY_REQUIREMENTS.md` / `Package.swift` |
| `RELEASE-078` | `PROPOSED` | Codex | [DISCOVERY] 0.6.0開始条件と現行提供区分の再照合 | `QUALITY-004`の品質棚卸し完了後、0.5.3後の公開面、利用者向け文書、`QUALITY_REQUIREMENTS.md`の1.0提供区分、および`RELEASE_0_6_0.md`の旧開始条件を照合し、0.6.0の対象候補、必要な文書入力、条件付き依存、残る一つずつのユーザー判断を整理する。release範囲、提供停止、名称、公開契約は決定せず、範囲・完了条件・担当・詳細正本・必須依存を確認して状態を更新するまで着手しない | `Maintanance/Current/RELEASE_0_6_0.md` / `Maintanance/Current/QUALITY_REQUIREMENTS.md` / `Package.swift` / `Maintanance/ProgressV2/TASK_REGISTRY_V2.md` |
| `RELEASE-079` | `FROZEN` | User / Codex | [DECISION] 0.7.0の到達範囲とrelease検討開始 | 0.6.0 releaseの完了と完了証拠の記録後、ユーザーの明示的な再開指示を受け、0.6.0後の公開面、残課題、品質・文書状態を判断材料として揃え、ユーザーが0.7.0へ含める到達範囲とrelease工程へ進むかを一つに決定する。0.6.0完了や前提整理だけでは自動再開しない | `Maintanance/Current/RELEASE_0_7_0.md` / `Maintanance/User/RELEASE_PROCESS.md` / `Maintanance/Current/QUALITY_REQUIREMENTS.md` / `Package.swift` |

### RedBlackTreeと品質ゲート

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `RBT-001` | `WAITING_EXTERNAL` | User / Codex | Index完了ゲート | 公開Index表現・完了範囲と`Comparable`採否を確定し、Index契約全体を閉じる。再開時は現行API・設計と外部要件を照合し、旧残task文書は経緯だけに使う | 現行確認：`Sources/RedBlackTreeCollections/Documentation/API-Matrix.md` / `Sources/RedBlackTreeCollections/Documentation/Design/Design-MemorySafety.md` / `Sources/RedBlackTreeCollections/Documentation/Quality-Profile.md`。履歴：`Maintanance/Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-011` | `WAITING_EXTERNAL` | User / Codex | Indexの`Comparable`採否 | `swift-collections`の要件が安定または正式化した後、現行API・設計と外部要件を照合して互換性を再評価し、採否を決定する。旧残task文書は経緯だけに使う | 現行確認：`Sources/RedBlackTreeCollections/Documentation/API-Matrix.md` / `Sources/RedBlackTreeCollections/Documentation/Design/Design-MemorySafety.md` / `Sources/RedBlackTreeCollections/Documentation/Quality-Profile.md`。履歴：`Maintanance/Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-014` | `WAITING_USER` | Codex | RedBlackTree文書workflowと4型outlineのAPI照合 | Permutation、OptionalElementBuffer、ElementBufferの利用者向け文書作業による方式習熟は完了済み。赤黒木の利用者向け文書作業へ進めるというユーザー指示を待ち、その後、workflowと4公開型のoutlineを現在のAPI、test、設計資料へ再照合し、本文作成へ渡せる状態を確認する。状態変更だけでは実作業を開始しない | `Sources/RedBlackTreeCollections/Documentation/Head/DOCUMENTATION_WORKFLOW.md` |
| `RBT-033` | `PROPOSED` | Codex | [DISCOVERY] macOS ASan＋Swift Testing Death Test実行経路の成立確認 | lifetime balance検査をtraitで除外しても子プロセスでASan runtimeが遅延ロードされる事象について、Swift Testing実行基盤、macOS環境、Linux CIとの差を切り分け、製品不具合と検証経路不成立を区別する | `Maintanance/RedBlackTreeModule/CurrentQualityAssessment.md` / `Package.swift` |
| `RBT-034` | `FROZEN` | User / Codex | [EXECUTION] RedBlackTree 1.0品質アセスメント完成 | 1.0品質ゲートの再開後、再現可能な証拠一式を備え、要求・主張・反証・未検証領域・残余リスクを接続した品質アセスメントを完成させる | `Maintanance/RedBlackTreeModule/CurrentQualityAssessment.md` / `Sources/RedBlackTreeCollections/Documentation/Quality-Profile.md` |
| `RBT-035` | `FROZEN` | 姫 / 80ms | [DISCOVERY] RedBlackTreeチューニングの落ち穂拾い | ユーザーの明示的な再開指示後、過去の実装・benchmark・Git履歴・チューニング記録を現行コードと照合し、取りこぼした改善候補、未反映の知見、再検証が必要な仮説を発見する。性能変更は行わず、実測と判断が必要な後続taskへ分離する | `Maintanance/RedBlackTreeModule/CurrentQualityAssessment.md` / `Sources/RedBlackTreeCollections/Documentation/Quality-Profile.md` / `Benchmarks/` |
| `RBT-026` | `FROZEN` | User / Codex | [DECISION] Mapped Values ViewのO(1)範囲契約再検討 | 利用者向け文書作業フェーズで、現行View APIと実装を確認し、View外だがbase treeでは有効なIndexを黙って読み書きし得る性質を踏まえ、O(1)と呼び出し側事前条件の契約を維持するか一つだけ再判断する。旧残task文書は論点の経緯だけに使う | 現行確認：`Sources/RedBlackTreeCollections/Documentation/API-Matrix-View.md` / `Sources/RedBlackTreeCollections/Documentation/API-Matrix.md`。履歴：`Maintanance/Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-004` | `FROZEN` | Codex | 残存するDebug限定Comparable群・Balanced群 | Debug限定`Result: Comparable`はユーザー介入で削除済み。`RBT-011`でIndexの`Comparable`採否が確定した後、残る`_LazyTieWrap`・`_NodePtrSealing`・`_LazyTie`の比較宣言とBalanced群について、ユーザーがこのtaskを明示的に再開 | `Maintanance/Current/EXTERNAL_TYPE_EXTENSION_AUDIT.md` |
| `RBT-005` | `FROZEN` | Codex | Memoize群の公開終了／正式API化 | 外部consumer 2件の移行後、ユーザーがこのtaskを明示的に再開。consumer移行だけでは自動再開しない | `Maintanance/Current/EXTERNAL_TYPE_EXTENSION_AUDIT.md` |
| `RBT-007` | `ACTIVE` | User / Codex | RedBlackTreeCollectionsのstrict memory safety全面適用 | 2026-10-15、ユーザー指示により有効化。現行readiness、対象範囲、必要な検証を照合して進める。状態変更だけでは実装操作を開始しない | `Maintanance/Current/StrictMemorySafetyReadiness.md` |
| `RBT-008` | `FROZEN` | User / Codex | `lazyDetach`等の並行初期化保証 | concurrency契約を扱う明示的な再開指示後、現行の非thread-safe契約、外部同期要件、実装上の一度だけの初期化TODOを照合して、必要な保証を改めて定める。旧残task文書は論点の経緯だけに使う | 現行確認：`Sources/RedBlackTreeCollections/Documentation/Design/Design-MemorySafety.md` / `Maintanance/RedBlackTreeModule/CurrentQualityAssessment.md` / `Sources/RedBlackTreeCollections/Implements/UnsafeTreeV2/Buffer/UnsafeTreeV2+BufferHeader.swift`。履歴：`Maintanance/Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-009` | `FROZEN` | User / Codex | [DECISION] runtime-check実装の再審査 | ユーザードキュメント作業後、1.0中間ゴールへ移行した時点、または`-Ounchecked`が主要構成と判明した時点で再開し、現行実装を1.0へ採用するか一つだけ判断 | `Sources/RedBlackTreeCollections/Documentation/Design/Design-RuntimeChecks.md` |
| `QUALITY-001` | `FROZEN` | User / Codex | 汎用基盤ライブラリとしての1.0採用品質ゲート | Index契約確定後、ユーザーが明示的に再開 | `Sources/RedBlackTreeCollections/Documentation/Quality-Profile.md` |
| `QUALITY-002` | `FROZEN` | Codex | [EXECUTION] 1.0品質保証CIの構成・証拠化 | 1.0品質ゲートの再開後、Ubuntu 24.04 LTS / x86_64のGitHub-hosted runnerで合意済みの品質試験を実行し、commit、workflow run、runner image、kernel、architecture、CPU、Swift、依存解決、選択試験、完全log、終了statusを証拠として残す。変動するrunner上の絶対性能は判定対象に含めない | `Maintanance/Current/QUALITY_REQUIREMENTS.md` / `Tests/TESTING.md` / `.github/workflows/candidate.yml` |
| `QUALITY-003` | `FROZEN` | Codex | [EXECUTION] Apple platforms 27提供境界のmanifest反映・build確認 | 1.0品質ゲートの再開後、対象Apple platformごとの最低deployment versionをmanifestへ反映し、64-bitのplatform別build・導入経路を確認する。macOS 27 / arm64以外はbuild証拠と実行品質を区別する | `Maintanance/Current/QUALITY_REQUIREMENTS.md` / `Package.swift` |
| `QUALITY-004` | `PROPOSED` | Codex | [DISCOVERY] 品質評価棚卸し | 四対象の評価・証拠・現行提供区分と既存taskを照合し、残る品質課題、記録不整合、既存taskで扱う範囲と未充当部分を整理する。初期抽出結果は詳細正本へ保存済み。開始時に対象版・範囲・完了条件・必須依存を確認して有効化する。個別課題の解消、公開契約・提供方針の採用、凍結解除は含めない | `Maintanance/Current/QUALITY_ASSESSMENT_INVENTORY.md` |
| `QUALITY-005` | `FROZEN` | User / Codex | [DECISION] SPI登録前の公開準備判定 | ユーザーの明示再開後、対象版の公開情報と品質証拠を照合し、初見の利用者が採用・利用を判断できる状態としてSPIへ登録してよいかをユーザーが一つ判断する。対象版・根拠・残る不足・判断を詳細正本に記録して完了。登録可の判断なしに登録へ進めない | `Maintanance/Current/SPI_REGISTRATION_GATE.md` |

### Permutation

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `PERM-072` | `DONE` | User / Claude姫 / V3（回答）、Codex（集約） | [EXECUTION] Astra最終名称提案の三者合意確認 | 2026-10-15ユーザー指示で登録。Astra提案のmodule名`NextPermutationModule`と一時view名`Permutation`維持について、ユーザー・姫・V3の回答と条件を対象別に記録し、合意の成立・不成立を`PERM-070`へ渡す。2026-10-15、Astraが三者回答を集約し、module名`NextPermutationModule`と通常版一時view名`NextPermutations.Permutation`維持の両方への三者同意を確認。旧回答は履歴として保存し、view名は各人の追加回答を優先。集約結果は`PERM-070`の判断材料として正本に記録済み。旧module名の互換方針は対象外として残す。2026-10-15、ユーザーがコミットを許可し、回答・集約結果と完了記録を同じコミットに保存する。再採点、rename、公開名の代理決定は含めない。三者回答の確認・集約を完了 | `Maintanance/Current/PERMUTATION_PUBLIC_API_NAMING_FINAL_PROPOSAL.md` |
| `PERM-071` | `PROPOSED` | Codex | [EXECUTION] PermutationModule公開API名決定ゲート確認 | `PERM-070`後、決定正本、対象scope、採用名、実装へ渡す検証条件、Registry依存が一致していることを照合してゲートを閉じる。記録整合だけを扱い、移行方式の設計、名称の再決定、rename実装、契約変更、`PERM-060`の凍結解除を行わない | `Maintanance/Current/PERMUTATION_PUBLIC_API_NAMING_REVIEW.md` / `Maintanance/Current/PUBLIC_API_NAMING_DECISIONS.md` / `Maintanance/ProgressV2/TASK_REGISTRY_V2.md` |
| `PERM-070` | `DONE` | User | [DECISION] PermutationModule公開API名の最終決定 | 2026-10-15、ユーザーが通常入口`nextPermutations()`、通常owner`NextPermutations`、borrowed入口`borrowedNextPermutations()`、borrowed owner`BorrowedNextPermutations`、通常ownerのgeneric parameter`Element`を暫定確定。`PERM-069`の三者採点・Round 4統合と`PERM-072`の最終提案への三者回答を確認後、module名`NextPermutationModule`と通常一時view名`NextPermutations.Permutation`維持を正式採用し、先の暫定確定を含む名称family全体を名称決定正本へ記録して完了した。`Element`は実sourceのcompile・DocC確認をrename実装時の受入条件とする。旧module名`PermutationModule`を残すかを含む移行方式は、名称の採否ではなく後続の移行プランで扱う。正式採用だけでrename、実装変更を開始しない | `Maintanance/Current/PERMUTATION_PUBLIC_API_NAMING_REVIEW.md` / `Maintanance/Current/PERMUTATION_PUBLIC_API_NAMING_SCORE_ROUND1_REPORT.md` / `Maintanance/Current/PERMUTATION_PUBLIC_API_NAMING_SCORE_ROUND2_REPORT.md` / `Maintanance/Current/PERMUTATION_PUBLIC_API_NAMING_SCORE_ROUND3_REPORT.md` / `Maintanance/Current/PERMUTATION_PUBLIC_API_NAMING_SCORE_ROUND4_REPORT.md` / `Maintanance/Current/PERMUTATION_PUBLIC_API_NAMING_FINAL_PROPOSAL.md` / `Maintanance/Current/PUBLIC_API_NAMING_DECISIONS.md` |
| `PERM-069` | `DONE` | User / 姫 / V3 | [EXECUTION] PermutationModule公開API名称の独立採点 | 2026-10-15、Round 1〜3に続き、未決のmodule名2候補と通常view2候補を三者が同じ尺度でRound 4再採点。候補ごとの自由記述を含む回答を受入れ、点数を自動決定に使わず、現在機能との語幹一致対将来scope・互換、短さ・現行互換対一時性の補助手掛かりという対立へ統合した。UserのRound 4点はmodule名で`NextPermutationModule`、通常viewで`Permutation`が上。採点と集計は完了したが、採用、互換方針、rename、公開契約変更は行っておらず、最終決定は`PERM-070`に残す | `Maintanance/Current/PERMUTATION_PUBLIC_API_NAMING_REVIEW.md` / `Maintanance/Current/PERMUTATION_PUBLIC_API_NAMING_SCORE_ROUND3_REPORT.md` / `Maintanance/Current/PERMUTATION_PUBLIC_API_NAMING_ROUND4_INPUT.md` / `Maintanance/Current/PERMUTATION_PUBLIC_API_NAMING_SCORE_USER_ROUND4.md` / `Maintanance/Current/PERMUTATION_PUBLIC_API_NAMING_SCORE_HIME_ROUND4.md` / `Maintanance/Current/PERMUTATION_PUBLIC_API_NAMING_SCORE_V3_ROUND4.md` / `Maintanance/Current/PERMUTATION_PUBLIC_API_NAMING_SCORE_ROUND4_REPORT.md` |
| `PERM-068` | `DONE` | Codex | [EXECUTION] PermutationModule公開API名称候補の集計・採点表作成 | 2026-10-15、三者候補を6 surface別に出典つき集計し、提出family対応、補助宣言名、契約変更論点を分離。ユーザー指示を受け、`MN-03`は現行契約固定、`BE-06`は入口単独、generic parameterは補助判断として含め、対象surface・候補シンボル・IDを展開した同一内容の三者別Round 1採点表を固定して完了。採点、候補採用、renameはまだ行っていない | `Maintanance/Current/PERMUTATION_PUBLIC_API_NAMING_REVIEW.md` / `Maintanance/Current/PERMUTATION_PUBLIC_API_NAMING_BALLOT.md` / `Maintanance/Current/PERMUTATION_PUBLIC_API_NAMING_SCORE_USER_ROUND1.md` / `Maintanance/Current/PERMUTATION_PUBLIC_API_NAMING_SCORE_HIME_ROUND1.md` / `Maintanance/Current/PERMUTATION_PUBLIC_API_NAMING_SCORE_V3_ROUND1.md` |
| `PERM-067` | `DONE` | User / 姫 / V3 | [DISCOVERY] PermutationModule公開API名称候補の提出 | 2026-10-15、ユーザー、姫、V3の候補を受領して完了。候補出しでは他者案を参照できるものとし、候補と反応の出典を保持した。ユーザーはmodule名`NextPermutationModule`とAPI familyの現状維持、姫とV3は現行維持を含む複数案と未解決論点を提出した。候補提出は採用、採点、production変更、rename、Sequence案再開、performance task名変更を意味しない | `Maintanance/Current/PERMUTATION_PUBLIC_API_NAMING_REVIEW.md` / `Maintanance/Current/PERMUTATION_PUBLIC_API_NAMING_CANDIDATE_FORM.md` / `Maintanance/Current/PERMUTATION_PUBLIC_API_NAMING_CANDIDATES_USER.md` / `Maintanance/Current/PERMUTATION_PUBLIC_API_NAMING_CANDIDATES_HIME.md` / `Maintanance/Current/PERMUTATION_PUBLIC_API_NAMING_CANDIDATES_V3.md` / `Maintanance/CLAUDE_TASK.md` / `Sources/PermutationModule/NextPermutations.swift` / `Sources/PermutationModule/BorrowedNextPermutations.swift` / `Sources/PermutationModule/PermutationModule.docc/PermutationModule.md` |
| `PERM-066` | `DONE` | Codex | [EXECUTION] Permutation生成DocC入口の利用導線補完 | 2026-10-15に受領したプレビューのレビューを反映。module landing pageを追加し、後続順列を一つずつ生成する用途、`nextPermutations()`への直接導線、開始順を含む最小例、保存時の`Array` copyを示した。通常版は一時Viewの失効をruntimeで検査し、borrowed版は`Span`の借用期間をcompilerが検査するという選択基準と、両版が単一の所有bufferを使う非`Sequence`の手動反復APIであることを入口に整理した。package・toolchain設定はroot READMEへリンクし、個別APIの既存契約は変更していない。Xcode build成功、例を実行して4順列を確認、`NextPermutations|BorrowedNextPermutations` filterのXCTest 60件・Swift Testing 17件とfacade再公開test 1件成功、DocCのwarnings-as-errors生成と生成JSON上の4リンク解決を確認して完了 | `Sources/PermutationModule/PermutationModule.docc/PermutationModule.md` / `Maintanance/PermutationModule/UserDocumentationDraft.md` / `Sources/PermutationModule/NextPermutations.swift` / `Sources/PermutationModule/BorrowedNextPermutations.swift` |
| `PERM-062` | `PROPOSED` | User / Codex | [EXECUTION] Permutation利用理解Validation試行 | API設計非参加者に利用者向け本文と公開surfaceだけを渡し、類似API選択、即時消費、永続保存、失効説明、View copyと要素copyの区別を無誘導で観測する。参加者選定と外部接触はユーザーが行い、Codexは課題提示と記録整理を担う | `Maintanance/PermutationModule/GeneralSwiftValidationScenario.md` / `Maintanance/PermutationModule/UserDocumentationDraft.md` |
| `PERM-063` | `FROZEN` | Codex | [EXECUTION] Permutation benchmark task名移行互換の先行導入 | ユーザーの明示再開後、CI登録中の旧`Permutations.SubSequenceN` 2 taskを現行`NextPermutationsSequence.Permutation`名へ対応付けるbaseline入力・結果名正規化をworkflowへ先に追加し、remote performance CIのgreenを確認 | `Maintanance/PermutationModule/BENCHMARK_TASK_NAME_MIGRATION.md` / `Maintanance/Current/PERFORMANCE_CI_CHANGE_GUIDE.md` / `.github/workflows/ci.yml` |
| `PERM-064` | `FROZEN` | Codex | [EXECUTION] Permutation benchmark表示名の現行型名への移行 | `PERM-063`のmerge後、benchmark sourceの旧内部型名を含む4 titleとCI library登録2件を`NextPermutationsSequence.Permutation`へ変更し、task列挙、base / current比較、remote performance CIのgreenを確認 | `Maintanance/PermutationModule/BENCHMARK_TASK_NAME_MIGRATION.md` / `Benchmarks/Sources/Benchmarks/PermutationBenchmarks.swift` / `Benchmarks/Libraries/CI.json` |
| `PERM-065` | `DONE` | Codex | [EXECUTION] runtime-check版Permutationコメントドック回復 | 2026-10-15のユーザー指示により登録・実施。`9ff515c9`で喪失した公開APIコメントを過去差分から回収し、現行runtime-check契約へ照合して、後続順列、所有buffer、手動反復、一時Viewの失効・保存方法、index境界、複雑度を復元した。borrowed Span固有の寿命説明は持ち込んでいない。source診断0件、Xcode build成功、現行`NextPermutations` 44 test成功、`PermutationModule` DocCを`--warnings-as-errors`で生成成功 | `Maintanance/MAINTENANCE.md` / `Maintanance/PermutationModule/UserDocumentationDraft.md` / `Maintanance/PermutationModule/RuntimeCheckedPermutationTestPlan.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` / `Sources/PermutationModule/NextPermutations.swift` |
| `PERM-043` | `FROZEN` | User | [DECISION] C++標準に匹敵すると判定する性能比の上限 | 2026-10-11、ユーザー指示により比較水準の判断を保留。明示的な再開指示後、28要素中7要素を選ぶ最大ケースでSwiftの全体処理時間を`std::next_permutation`の何倍以内なら「匹敵」と受け入れるか一つだけ決定する | `Maintanance/PermutationModule/CurrentQualityAssessment.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` |
| `PERM-044` | `FROZEN` | Codex | [EXECUTION] Permutation外部性能アセスメントの実測・判定 | 2026-10-11、比較水準の判断とともにユーザー指示で保留。`PERM-043`の明示的な再開・完了後、macOS上で専用scriptを実行し、環境情報、生JSON、PNG chartを保存して判定する | `Maintanance/PermutationModule/CurrentQualityAssessment.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` |
| `PERM-046` | `FROZEN` | Codex | [DISCOVERY] Swift 6.2向けmanifest構成の必要性再評価 | runtime-check View通常版がSwift 6.2で成立したため、旧「PermutationModuleなしの縮小manifest」案はそのまま実行しない。ユーザーの明示的な再開指示後、package全体の6.2成立条件を調べ、version-specific manifest自体が必要かから再評価する | `Maintanance/PermutationModule/CurrentQualityAssessment.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` |
| `PERM-051` | `FROZEN` | Claude | [EXECUTION] borrowed Span版PermutationのTest as Specification | runtime仕様test 25件を受け入れ、2026-10-13にも対象25件成功を再確認。一時clientによるcompile-pass／compile-fail結果は返却記録にあるが、repository内の再実行可能なfixtureではないため、ユーザーの明示的な再開まで残作業を凍結 | `Maintanance/PermutationModule/BorrowedPermutationTestPlan.md` / `Sources/PermutationModule/BorrowedNextPermutations.swift` / `Tests/PermutationTests/BorrowedNextPermutations/` |
| `PERM-060` | `FROZEN` | User | [DECISION] NextPermutationsのSequence表面を製品候補として検討するか | 2026-10-13、`Array(sequence)`が要素配列ではなく失効可能なViewを収集する事実を新しい判断材料として、採用・不採用を決めず延期。ユーザーの明示的な再開後、View Sequenceの有効な操作範囲と誤用防止、所有配列を返す別Sequence、copy・性能costを追試してから一つ選ぶ | `Maintanance/PermutationModule/NextPermutationsSequenceExperiment.md` |

### OptionalElementBuffer

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `OPT-074` | `ACTIVE` | Claude / Codex（受入） | [EXECUTION] OptionalElementBuffer Test as Specレビュー反映 | 2026-10-15ユーザー指示により、Astraが現行仕様と番号付きtestを静的レビューし、A〜Eの不足を正本に記録。Claudeへnested Optional状態、共有・取得参照の寿命、removeAll反復と再利用、ゼロ容量操作、非コピー所有型のcompiler検証を依頼。production・公開契約変更は含めず、新しい判断や不具合を検出した場合は該当範囲を停止して返却。対象Debug／Release・Death Test・compiler fixtureの証拠をCodexが確認後、コミット許可待ちをWAITING_USERとし、保存確認後にDONE | `Maintanance/Current/OPTIONAL_ELEMENTBUFFER_TEST_AS_SPEC_REVIEW.md` / `Maintanance/CLAUDE_TASK.md` |
| `OPT-073` | `DONE` | Codex | [EXECUTION] OptionalElementBuffer生成DocCの利用導線補完 | 2026-10-15のユーザー指示により、ElementBufferの生成DocCレビューからOptionalElementBufferにも該当する不足を実装と内部本文へ照合して補完。module入口へ2D bufferの未設定確認、設定、取得、`nil`による再未設定化の最小例を加え、座標順、`indices`、要素寿命を説明した。入口と4公開型へnoncopyable境界と、nonmutating APIにより`let`でも内容を更新できる性質を明示。続くプレビュー指摘を受け、8本の座標accessへ軸別の事前条件を追加し、範囲外は未設定を表す`nil`ではなく契約違反であることを入口にも明記した。SwiftPM dependencyでtraitを有効化する設定例と公式案内は、API説明ではなくpackage導入条件として日英root READMEへ配置し、DocC入口にはopt-inである事実だけを残した。Optional側に存在しない借用参照APIは追加していない。source診断0件、Xcode build成功、OptionalElementBufferの通常test 35件・Death Test 21件成功、DocCを`--warnings-as-errors`で生成し、入口・4型・8 accessへの反映を確認 | `README.ja.md` / `README.md` / `Sources/OptionalElementBufferModule/OptionalElementBufferModule.docc/OptionalElementBufferModule.md` / `Sources/OptionalElementBufferModule/OptionalElementBuffer.swift` / `Maintanance/OptionalElementBufferModule/UserDocumentationDraft.md` |
| `OPT-064` | `FROZEN` | User / Codex | [EXECUTION] OptionalElementBuffer一般利用理解Validation試行 | 一般Swift向け提供方式の採用判断と、検証する公開surface・説明がそろうまで凍結を保つ。明示再開後、設計非参加者が本文と公開surfaceから用途、座標順、nil遷移、所有・並行利用境界を理解できるか観測する。再開に向けて不足する判断・実行は別taskへ分ける | `Maintanance/OptionalElementBufferModule/GeneralSwiftValidationScenario.md` / `Maintanance/OptionalElementBufferModule/UserDocumentationDraft.md` / `Maintanance/OptionalElementBufferModule/OptionalElementBufferAudit.md` |
| `OPT-065` | `PROPOSED` | User / Codex | [EXECUTION] OptionalElementBuffer競技利用Validation試行 | ユーザーが問題・judge・提出可否を決めた後、未計算状態を持つ固定shapeの多次元メモ化問題で提出source、正否、実行時間、メモリを記録する。C++級性能や一般Swift利用へ一般化しない | `Maintanance/OptionalElementBufferModule/GeneralSwiftValidationScenario.md` / `Tests/OptionalElementBufferModuleTests/EDPC-J.swift` / `Tests/OptionalElementBufferModuleTests/EDPC-L.swift` |

### ElementBuffer

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `BARE-046` | `DONE` | Claude / Codex（受入） | [EXECUTION] ElementBuffer Test as Specレビュー反映 | 作業・検証は受入済み、テスト反映は`4b44e758`でコミット済み。Astraの追加確認・作成者・試行完了手順の記録更新も、2026-10-15のユーザー許可に基づき本記録のコミットへ含める。2026-10-15、レビュー指摘A〜Eについて、借用中の競合20件と正常例、1D〜4Dの全座標借用、軸別負寸法、ゼロ寸法・空領域、参照型要素の共有寿命を検出するtestとcompiler fixtureを追加。production変更なし。Codexがcompiler診断script（正常例21関数、escape 4件、borrow-conflict 20件）とXcode上のElementBuffer 81 test（全件成功、未実行0）を独立再確認して受入。Linux、Swift 6.2 toolchain、D・Eのmutation検査は未実施であり、1.0品質全体の受入には含めない | `Maintanance/Current/ELEMENTBUFFER_TEST_AS_SPEC_REVIEW.md` / `Maintanance/CLAUDE_TASK.md` |
| `BARE-045` | `DONE` | Codex | [EXECUTION] ElementBuffer生成DocCレビュー反映 | 2026-10-15に受領した生成DocCレビューの4点を反映。module入口と4公開型へnoncopyable境界を明示し、2Dの最小例と`let`からの更新、Apple標準`MutableRef`文書への導線と借用参照の読み書き例を加え、`init(count:_:)`のclosure名誤記を修正した。追加例は実行して`42`・`3`を確認。source診断0件、Xcode build成功、`ElementBufferModule` DocCを`--warnings-as-errors`で生成し、入口・4型・2D reference・修正文言が生成JSONへ反映されたことを確認 | `Sources/ElementBufferModule/ElementBufferModule.docc/ElementBufferModule.md` / `Sources/ElementBufferModule/ElementBuffer.swift` / `Maintanance/ElementBufferModule/UserDocumentationDraft.md` |
| `BARE-044` | `DONE` | Codex | [EXECUTION] ElementBuffer座標accessコメントドック回復 | 2026-10-15のユーザー指示により登録・実施。`4b023333`のaccess性能探索で追加され、旧連鎖subscript削除後に主要表面となった1D〜4Dの`element(at:)`・`setElement(_:at:)`・`reference(at:)`計12本へ、旧subscriptの契約記述と現行本文ドラフトを照合して、座標、事前条件、所有・寿命、nonmutating更新、計算量を復元した。`DOC-010`で凍結中の定性的性能表現は変更していない。source診断0件、Xcode build成功、ElementBuffer 60 test成功、`ElementBufferModule` DocCを`--warnings-as-errors`で生成成功 | `Maintanance/MAINTENANCE.md` / `Maintanance/ElementBufferModule/UserDocumentationDraft.md` / `Maintanance/ElementBufferModule/ElementBufferAudit.md` / `Sources/ElementBufferModule/Documentation/Quality-Profile.md` / `Sources/ElementBufferModule/ElementBuffer.swift` |
| `BARE-035` | `FROZEN` | Codex | [DISCOVERY] ElementBuffer提供停止の実施境界整理 | 2026-10-15のユーザー訂正により、Swift 6.2は1.0競技供用、Swift 6.4は1.0一般供用である。旧記録の「1.0提供対象外」を提供停止の根拠にしない。ユーザーが提供停止の検討を明示的に再開した場合に限り、package、facade、文書、移行、release、既存利用への影響を現在の公開面へ再照合し、局所的な後続taskへ分解する | `Maintanance/Current/QUALITY_REQUIREMENTS.md` / `Sources/ElementBufferModule/Documentation/Quality-Profile.md` / `Package.swift` |

### 移行史

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `HIST-001` | `ACTIVE` | V3オーサー | [DISCOVERY] AtCoder 2025移行史 | 移行史へ接続すべき新しい事実・証拠が見つかったときに受け入れる常設nodeとして`ACTIVE`を保つ。個別調査や追記が常時実行中であることを意味せず、必要な範囲が具体化したときだけ本紙または証拠別紙へ反映する | `Maintanance/RefactoringFromAtCoder2025/README.md` / `Maintanance/RefactoringFromAtCoder2025/EVIDENCE.md` |

## Task precedence

内部task間の必須AND前提を記録する。`SEQUENCE`は前提成果がそろうまで後続を開始・継続しない。`PARALLEL_JOIN`は独立部分を並行でき、後続の完了までに合流する。いずれも状態・委任・再開条件を上書きしない。

| 後続task | 前提task | Flow | 制約 |
| --- | --- | --- | --- |
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
| `PERM-068` | `PERM-067` | `SEQUENCE` | 三者の候補と出典つき反応がそろってから、集計と固定採点表を作る |
| `PERM-069` | `PERM-068` | `SEQUENCE` | ユーザーが候補範囲と判断単位を確認した固定採点表を使ってから、三者が独立採点する |
| `PERM-070` | `PERM-069` | `SEQUENCE` | 三者の採点、理由、反証、対立点を判断材料として揃えてから、ユーザーが公開名を最終決定する |
| `PERM-070` | `PERM-072` | `SEQUENCE` | Astra最終提案への三者回答・合意状況・未解決条件を判断材料として揃える。全員一致や名称の自動採用を意味しない |
| `PERM-071` | `PERM-070` | `SEQUENCE` | ユーザーの最終決定を正本へ記録してから、scope・未決事項・互換方針・依存の整合を確認してゲートを閉じる |
| `RELEASE-078` | `QUALITY-004` | `SEQUENCE` | 現行提供区分に照らした品質課題と証拠の棚卸しを揃えてから、0.6.0開始条件と対象候補を再照合する |
| `RELEASE-007` | `RELEASE-078` | `SEQUENCE` | 0.5.3後の公開面、現行提供区分、文書状態、および旧0.6.0開始条件の差を判断材料として揃えてから、0.6.0の範囲とrelease開始を決定する |
| `RELEASE-076` | `RELEASE-075` | `SEQUENCE` | 不足仕様を充当して検証可能な工程にしてから、Validation & Verificationを行う |
| `DOC-026` | `QUALITY-005` | `SEQUENCE` | 対象版についてSPI登録可の判断を得てから登録する。ゲートtaskのDONEだけでは登録可を意味せず、0.9.x release後・明示再開の条件も維持する |
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
