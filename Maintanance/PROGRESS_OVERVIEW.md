# 開発・メンテナンス進捗一覧 — V2への案内

> 2026-10-14、ユーザーの接続指示により、現在の入口を[進捗 V2](ProgressV2/PROGRESS_OVERVIEW_V2.md)へ切り替えた。現在のtask・依存は[Task Registry V2](ProgressV2/TASK_REGISTRY_V2.md)、制度・採番・文書権限は[Task制度 V2](ProgressV2/TASK_RULES_V2.md)を参照・更新する。この旧版へ現在の状態を追記しない。

以下は切替前の記録であり、現在の状態や規則を決める正本ではない。過去の参照をたどれるよう、配置と記録を残す。通常の開始時は上記V2へ進み、以下を通読しない。

記録の基準日: 2026-10-14 / Codex

切替前は、この文書を現在の作業状態の入口とし、文書の権限・配置、Registry、依存、規則を開始時に確認する構成だった。2026-10-07までの完了チェック、判断待ち、
旧サマリーは`Archived/PROGRESS_OVERVIEW_HISTORY_2026-10-07.md`へ移した。
2026-10-09までの`DONE`・`EXCLUDED` task行と、それらだけに向かう完了済みprecedence辺は
`Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-09.md`へ移した。以後2026-10-11までに完了・除外した行と
充足済みprecedence辺は`Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-11.md`へ移した。
現行Registryは残作業を管理し、履歴へ移す前の`DONE`・`EXCLUDED`行が残ることもある。
これらの行は残作業や着手候補として扱わない。2026-10-12までに完了・除外した行と
充足済みprecedence辺は`Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-12.md`へ移した。
2026-10-13に完了・除外した行と充足済みprecedence辺は
`Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-13.md`へ移した。
2026-10-14に完了・除外した行、充足済みprecedence辺、および完了した中間ゴールの詳細は
`Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-14.md`へ移した。

## 正本整理時の配置維持例外

> 以下は旧記録。現在の参照・更新先は[V2の該当箇所](ProgressV2/TASK_RULES_V2.md#正本整理時の配置維持例外)。

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

> 以下は旧記録。現在の参照・更新先は[V2の該当箇所](ProgressV2/TASK_RULES_V2.md#文書ランクと変更権限)。

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

> 以下は旧記録。現在の参照・更新先は[V2の該当箇所](ProgressV2/TASK_REGISTRY_V2.md#task-registry)。

### Task ID採番状態

> 以下は旧記録。現在の参照・更新先は[V2の該当箇所](ProgressV2/TASK_RULES_V2.md#task-id採番状態)。

次の表を、Task Registry IDのprefixごとの**最後に使用した番号**を保持する正本とする。現行Registryから
Archivedへ移したtask、`DONE`・`EXCLUDED`になったtask、後から誤りや重複が判明したtaskも使用済みに含める。
行の削除、移動、状態変更、改名、またはtaskの統合を理由に番号を戻さず、欠番を再利用しない。

既存prefixでtaskを新規登録するときは、この表の最後の番号へ1を加えたIDを使い、**新しいtask行の追加と同じ編集で**
表の番号も更新する。採番したtaskを同じ編集で取りやめた場合も、その番号は使用済みとして表に残す。新しいprefixを
導入するときは、既存のRegistryとArchivedに同じprefixがないことを確認し、最初のtask行と同じ編集でそのprefixを
表へ追加する。採番待ちqueueの仮ID、conversation reference ID、release専用Registryの内部IDはこの表の対象外とする。

初期値は2026-10-14時点の現行Registry、`Archived/PROGRESS_OVERVIEW_HISTORY_2026-10-07.md`、および
`Archived/PROGRESS_OVERVIEW_COMPLETED_*.md`のtask行を照合して復元した。

| Prefix | 最後に使用した番号 |
| --- | ---: |
| `API` | `010` |
| `ARRAY` | `018` |
| `BARE` | `043` |
| `BENCH` | `001` |
| `CPP` | `002` |
| `DOC` | `027` |
| `EVAL` | `001` |
| `FIT` | `007` |
| `GRAPH` | `019` |
| `HIST` | `001` |
| `OPS` | `035` |
| `OPT` | `072` |
| `PERF` | `005` |
| `PERM` | `064` |
| `QUALITY` | `003` |
| `RBT` | `035` |
| `RELEASE` | `077` |
| `TEST` | `004` |

**現在の律速:** 外部（`swift-collections` ContainersPreviewの`Container.Index`要件）。
Index契約と関連taskは、この外部条件が安定するまで最終確定できない。

**中間ゴールの取り扱い**

**直近達成した中間ゴール:** Array系benchmark・OptionalElementBuffer opt-in・ElementBuffer系名称移行を
完了した。詳細は`Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-14.md`に保存した。

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
- 0.9.x release後、Swift Package Indexへpackageを登録し、module別DocCの生成と互換性表示を確認する。登録後に
  SPIが提供するbadgeとmodule別API referenceへの導線をREADMEまたはPagesへ接続し、結果を1.0品質gateへ渡す。
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
| `OPS-031` | `DONE` | User / Codex | [EXECUTION] Orientation V4正本採用とplaybook参照切替 | 2026-10-14、ユーザーの採用指示を受け、V4三文書とTask Operation Playbook V4の冒頭へ正本採用を明記し、V4から辿るplaybook参照をV4へ統一。旧版の移動・アーカイブは行わない | `Orientation/CODEX_ORIENTATION_V4.md` / `Orientation/TASK_ORIENTATION_V4.md` / `Orientation/AI_COLLABORATION_PHILOSOPHY_V4.md` / `Orientation/CODEX_TASK_OPERATION_PLAYBOOK_V4.md` |
| `OPS-032` | `DONE` | Prime Codex / 80ms Codex / V3オーサー / ChatGPT | [DISCOVERY] 名前持ちCodexによる`AGENTS.md`再現性レビュー | 2026-10-14、4者の個別reviewを統合。全員が既存議論へ露出済みのためblindな独立再現とはせず、既知所見の適用再現、Routine commit許可の共通追加所見、Xcode handoffのPrime固有所見を証拠種別つきで分離した。このtaskの完了時点ではAGENTS変更は未承認であり、後の採用は`OPS-035`に記録 | `Archived/AGENTS_MD_NAMED_CODEX_REVIEW.md` |
| `OPS-033` | `DONE` | Prime Codex | [EXECUTION] `AGENTS.md`原案R1の4者レビュー配布準備 | 2026-10-14、draft・master・4票のR1本文hash一致、4票が識別番号以外byte一致、一枚ごとの共通依頼・対象本文・返却欄を確認。01〜04をPrime Codex、80ms Codex、V3オーサー、ChatGPTへ割り当て、各票を渡せる状態にした。このtaskは配布準備までを完了範囲とし、返却・統合は`OPS-034`、後の採用は`OPS-035`に記録 | `AgentsReview/AGENTS_REVIEW_MASTER.md` |
| `OPS-034` | `DONE` | Prime Codex / 80ms Codex / V3オーサー / ChatGPT | [DISCOVERY] `AGENTS.md`原案R1の4者初読レビューと統合 | 2026-10-14、4票の返却と事前接触記録を確認し、文言、具体場面、反証を照合して統合。R1は協働の入口として骨格を保てるが実効性は未観測。必須修正は確定せず、依頼と合意、許可範囲、権限返還、俯瞰対象を任意の表現改善候補として分離した。このtaskの完了時点では現行`AGENTS.md`への採用・反映は未実施であり、後の採用は`OPS-035`に記録 | `AgentsReview/AGENTS_REVIEW_MASTER.integrated.md` |
| `OPS-035` | `DONE` | User / Codex | [EXECUTION] 現行`AGENTS.md`とOrientation V5の正本採用・参照切替 | 2026-10-14、ユーザーが現行`AGENTS.md`を採用・修正し、続く正式採用指示によりV5の4文書を一組の正本として採用。`AGENTS.md`の明示的なオリエンテーション参照先を`OrientationV5/CODEX_ORIENTATION_V5.md`へ切り替え、各文書の状態欄と採用記録を整合した。旧V4は履歴として現在位置に残す | `../AGENTS.md` / `OrientationV5/README.md` / `OrientationV5/CODEX_ORIENTATION_V5.md` / `OrientationV5/TASK_ORIENTATION_V5.md` / `OrientationV5/AI_COLLABORATION_PHILOSOPHY_V5.md` / `OrientationV5/CODEX_TASK_OPERATION_PLAYBOOK_V5.md` |
| `RELEASE-020` | `FROZEN` | Codex | [EXECUTION] 0.6.0でGitHub Pages更新元をrelease tagへ一本化 | 0.5.xではmain pushとrelease tag pushの双方によるdeploy競合を許容。0.6.0のrelease工程でmain由来のdeployを停止し、tag commitから生成・検証した利用者向け文書だけがPagesを更新することを確認 | `RELEASE_0_6_0.md` |
| `RELEASE-072` | `USER_ONLY` | User | [EXECUTION] 人間向けリリース工程表の作成 | ユーザーがゴールを定め、人間だけでも現在位置、次の操作、完了証拠、停止点を追える一枚の工程表を作成する。0.5.xで実際に使って観測し、0.6.xで磨く。AIは開始、代行、催促を行わず、依頼された場合だけ整理・レビューを補助する | `User/RELEASE_PROCESS.md` |
| `RELEASE-075` | `USER_ONLY` | User | [EXECUTION] リリース工程の不足仕様充当 | ユーザーが、定義した品質要求に対して不足する工程仕様、判定基準、証拠取得方法、停止・復旧手順を補い、V&V可能な状態にする。AIは開始、代行、催促を行わず、依頼された場合だけ整理・レビューを補助する | `User/RELEASE_PROCESS.md` |
| `RELEASE-076` | `USER_ONLY` | User | [EXECUTION] リリース工程のValidation & Verification | ユーザーが、充当後の工程仕様について、定義した品質要求を満たすことと、意図したリリース目的に適合することを確認する。AIは開始、代行、催促を行わず、依頼された場合だけ検証・レビューを補助する | `User/RELEASE_PROCESS.md` |
| `DOC-010` | `FROZEN` | Codex | [DISCOVERY] BareArrayの定性的性能表現の再検討 | 2026-10-09、比較対象はSwiftの`[[Element]]`であり、COWと連鎖subscriptによる深刻な性能劣化を単一連続storageと非所有Viewで迂回する設計意図があると確認。アンカリングを避けるため、ユーザー指示による再訪まで文言判断を保留 | `Archived/Canonical/RELEASE_0_5_2.md` / `ElementBufferModule/ElementBufferAudit.md` |
| `DOC-026` | `FROZEN` | User / Codex | [EXECUTION] Swift Package Indexへのpackage登録 | 0.9.x release後にユーザーが明示的に再開し、公式PackageListへ`https://github.com/narumij/swift-ac-collections.git`を追加する外部PRを準備・提出して、package page、互換性表示、module別DocC build結果を確認する | `DOCUMENTATION_CI_PLAN.md` / `Package.swift` |
| `DOC-027` | `FROZEN` | Codex | [EXECUTION] Swift Package Index公開導線のREADME・Pages反映 | `DOC-026`完了後、SPI package pageの`Do you maintain this package?`が提示するMarkdownを正として互換性badgeをREADMEへ追加し、確認できたmodule別DocC URLへの導線をREADMEまたはPagesへ接続する | `DOCUMENTATION_CI_PLAN.md` / `README.md` |
| `RELEASE-007` | `FROZEN` | User / Codex | [DECISION] 0.6.0の到達範囲とrelease検討開始 | 全公開対象の利用者向けドキュメント初版完成後、0.6.0へ含める到達範囲を一つに定め、release工程へ進むか判断 | `RELEASE_0_6_0.md` |
| `RBT-014` | `FROZEN` | Codex | RedBlackTree文書workflowと4型outlineのAPI照合 | Permutation、OptionalArray、BareArrayのユーザードキュメント作業で方式を習熟した後、ユーザーが再開。workflowと4公開型のoutlineを現在のAPI、test、設計資料と照合し、本文作成へ渡せる状態を確認 | `Sources/RedBlackTreeCollections/Documentation/Head/DOCUMENTATION_WORKFLOW.md` |
| `RBT-032` | `FROZEN` | Codex | [DISCOVERY] RedBlackTree 0.6.0現行品質アセスメント | 2026-10-13、Codex復旧中の中断taskとして凍結。ユーザーの明示的な再開指示後、既存の試験結果と不足する再現証拠を照合してから継続する | `RedBlackTreeModule/CurrentQualityAssessment.md` |
| `RBT-033` | `PROPOSED` | Codex | [DISCOVERY] macOS ASan＋Swift Testing Death Test実行経路の成立確認 | lifetime balance検査をtraitで除外しても子プロセスでASan runtimeが遅延ロードされる事象について、Swift Testing実行基盤、macOS環境、Linux CIとの差を切り分け、製品不具合と検証経路不成立を区別する | `RedBlackTreeModule/CurrentQualityAssessment.md` / `Package.swift` |
| `RBT-034` | `FROZEN` | User / Codex | [EXECUTION] RedBlackTree 1.0品質アセスメント完成 | 1.0品質ゲートの再開後、再現可能な証拠一式を備え、要求・主張・反証・未検証領域・残余リスクを接続した品質アセスメントを完成させる | `RedBlackTreeModule/CurrentQualityAssessment.md` / `Sources/RedBlackTreeCollections/Documentation/Quality-Profile.md` |
| `RBT-035` | `FROZEN` | Claude / Codex | [DISCOVERY] RedBlackTreeチューニングの落ち穂拾い | ユーザーの明示的な再開指示後、過去の実装・benchmark・Git履歴・チューニング記録を現行コードと照合し、取りこぼした改善候補、未反映の知見、再検証が必要な仮説を発見する。性能変更は行わず、実測と判断が必要な後続taskへ分離する | `RedBlackTreeModule/CurrentQualityAssessment.md` / `Sources/RedBlackTreeCollections/Documentation/Quality-Profile.md` / `Benchmarks/` |
| `RBT-026` | `FROZEN` | User / Codex | [DECISION] Mapped Values ViewのO(1)範囲契約再検討 | 利用者向け文書作業フェーズで、View外だがbase treeでは有効なIndexを黙って読み書きし得る性質を踏まえ、O(1)と呼び出し側事前条件の現行契約を維持するか一つだけ再判断 | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-004` | `FROZEN` | Codex | Debug限定Comparable群・Balanced群 | Index契約またはexecutable API Matrix方針の確定後 | `EXTERNAL_TYPE_EXTENSION_AUDIT.md` |
| `RBT-005` | `WAITING_EXTERNAL` | Codex | Memoize群の公開終了／正式API化 | 外部consumer 2件の移行後 | `EXTERNAL_TYPE_EXTENSION_AUDIT.md` |
| `PERM-062` | `PROPOSED` | User / Codex | [EXECUTION] Permutation利用理解Validation試行 | API設計非参加者に利用者向け本文と公開surfaceだけを渡し、類似API選択、即時消費、永続保存、失効説明、View copyと要素copyの区別を無誘導で観測する。参加者選定と外部接触はユーザーが行い、Codexは課題提示と記録整理を担う | `PermutationModule/GeneralSwiftValidationScenario.md` / `PermutationModule/UserDocumentationDraft.md` |
| `PERM-063` | `FROZEN` | Codex | [EXECUTION] Permutation benchmark task名移行互換の先行導入 | ユーザーの明示再開後、CI登録中の旧`Permutations.SubSequenceN` 2 taskを現行`NextPermutationsSequence.Permutation`名へ対応付けるbaseline入力・結果名正規化をworkflowへ先に追加し、remote performance CIのgreenを確認 | `PermutationModule/BENCHMARK_TASK_NAME_MIGRATION.md` / `PERFORMANCE_CI_CHANGE_GUIDE.md` / `.github/workflows/ci.yml` |
| `PERM-064` | `FROZEN` | Codex | [EXECUTION] Permutation benchmark表示名の現行型名への移行 | `PERM-063`のmerge後、benchmark sourceの旧内部型名を含む4 titleとCI library登録2件を`NextPermutationsSequence.Permutation`へ変更し、task列挙、base / current比較、remote performance CIのgreenを確認 | `PermutationModule/BENCHMARK_TASK_NAME_MIGRATION.md` / `Benchmarks/Sources/Benchmarks/PermutationBenchmarks.swift` / `Benchmarks/Libraries/CI.json` |
| `PERM-043` | `FROZEN` | User | [DECISION] C++標準に匹敵すると判定する性能比の上限 | 2026-10-11、ユーザー指示により比較水準の判断を保留。明示的な再開指示後、28要素中7要素を選ぶ最大ケースでSwiftの全体処理時間を`std::next_permutation`の何倍以内なら「匹敵」と受け入れるか一つだけ決定する | `PermutationModule/CurrentQualityAssessment.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` |
| `PERM-044` | `FROZEN` | Codex | [EXECUTION] Permutation外部性能アセスメントの実測・判定 | 2026-10-11、比較水準の判断とともにユーザー指示で保留。`PERM-043`の明示的な再開・完了後、macOS上で専用scriptを実行し、環境情報、生JSON、PNG chartを保存して判定する | `PermutationModule/CurrentQualityAssessment.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` |
| `PERM-046` | `FROZEN` | Codex | [DISCOVERY] Swift 6.2向けmanifest構成の必要性再評価 | runtime-check View通常版がSwift 6.2で成立したため、旧「PermutationModuleなしの縮小manifest」案はそのまま実行しない。ユーザーの明示的な再開指示後、package全体の6.2成立条件を調べ、version-specific manifest自体が必要かから再評価する | `PermutationModule/CurrentQualityAssessment.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` |
| `PERM-051` | `FROZEN` | Claude | [EXECUTION] borrowed Span版PermutationのTest as Specification | runtime仕様test 25件を受け入れ、2026-10-13にも対象25件成功を再確認。一時clientによるcompile-pass／compile-fail結果は返却記録にあるが、repository内の再実行可能なfixtureではないため、ユーザーの明示的な再開まで残作業を凍結 | `PermutationModule/BorrowedPermutationTestPlan.md` / `Sources/PermutationModule/BorrowedNextPermutations.swift` / `Tests/PermutationTests/BorrowedNextPermutations/` |
| `PERM-060` | `FROZEN` | User | [DECISION] NextPermutationsのSequence表面を製品候補として検討するか | 2026-10-13、`Array(sequence)`が要素配列ではなく失効可能なViewを収集する事実を新しい判断材料として、採用・不採用を決めず延期。ユーザーの明示的な再開後、View Sequenceの有効な操作範囲と誤用防止、所有配列を返す別Sequence、copy・性能costを追試してから一つ選ぶ | `PermutationModule/NextPermutationsSequenceExperiment.md` |
| `OPT-045` | `FROZEN` | User | [DECISION] OptionalArray次元名体系の再判断 | 0.6.0の到達範囲判断前に、2D・3Dの意味名と4Dの`size0`〜`size3`を維持するか、AI間で整理した選択肢から一つ判断。0.5.2のコメントドック作業は現行名で先行する | `OptionalElementBufferModule/OptionalElementBufferAudit.md` / `RELEASE_0_6_0.md` |
| `OPT-072` | `FROZEN` | User / Codex / Claude | [DISCOVERY] Swift 6.4以降向けOptionalElementBuffer一般提供方式 | split storageを維持するか、`Element?` storageと標準`MutableRef`を使うかを、性能測定を含めて再検討する。現在の競技用途向けopt-in提供を妨げず、ユーザーの明示再開まで着手しない | `OptionalElementBufferModule/CurrentQualityAssessment.md` / `Sources/OptionalElementBufferModule/Documentation/Quality-Profile.md` |
| `OPT-064` | `FROZEN` | User / Codex | [EXECUTION] OptionalArray一般利用理解Validation試行 | 一般Swift向けの既定提供を再設計する`OPT-072`まで凍結。再開後、設計非参加者が本文と公開surfaceから用途、座標順、nil遷移、所有・並行利用境界を理解できるか観測する | `OptionalElementBufferModule/GeneralSwiftValidationScenario.md` / `OptionalElementBufferModule/UserDocumentationDraft.md` / `OptionalElementBufferModule/OptionalElementBufferAudit.md` |
| `OPT-065` | `PROPOSED` | User / Codex | [EXECUTION] OptionalArray競技利用Validation試行 | ユーザーが問題・judge・提出可否を決めた後、未計算状態を持つ固定shapeの多次元メモ化問題で提出source、正否、実行時間、メモリを記録する。C++級性能や一般Swift利用へ一般化しない | `OptionalElementBufferModule/GeneralSwiftValidationScenario.md` / `Tests/OptionalElementBufferModuleTests/EDPC-J.swift` / `Tests/OptionalElementBufferModuleTests/EDPC-L.swift` |
| `BARE-035` | `PROPOSED` | Codex | [DISCOVERY] BareArray提供停止の実施境界整理 | package、facade、文書、移行、release、既存利用への影響を確認し、提供停止を局所的に実施できるtaskへ分解する | `Sources/ElementBufferModule/Documentation/Quality-Profile.md` / `Package.swift` |
| `BARE-042` | `PROPOSED` | User / Codex | [EXECUTION] ElementBuffer利用理解Validation試行 | 設計非参加者へ利用者向け本文と公開surfaceだけを提示し、座標順、`indices`、value accessと借用参照、提供環境、非Collection性、性能説明を無誘導で観測する。参加者選定と外部接触はユーザーが行う | `ElementBufferModule/GeneralSwiftValidationScenario.md` / `ElementBufferModule/UserDocumentationDraft.md` |
| `BARE-043` | `PROPOSED` | User / Codex | [EXECUTION] ElementBuffer競技利用Validation試行 | ユーザーが問題・judge・提出可否を決めた後、固定shapeの多次元storageを必要とする実問題で提出source、正否、実行時間、メモリを記録する。C++級性能や一般Swift利用へ一般化しない | `ElementBufferModule/GeneralSwiftValidationScenario.md` |
| `RBT-007` | `FROZEN` | User / Codex | RedBlackTreeCollectionsのstrict memory safety全面適用 | ユーザーが段階3を承認 | `StrictMemorySafetyReadiness.md` |
| `RBT-008` | `FROZEN` | User / Codex | `lazyDetach`等の並行初期化保証 | concurrency契約を扱う明示的な再開指示 | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` |
| `HIST-001` | `FROZEN` | V3オーサー | [DISCOVERY] AtCoder 2025移行史 | 2026-10-13、現時点の整理を一段落として凍結。ユーザーの明示的な再開指示後、本紙の説明または証拠別紙へ追加する必要がある範囲だけを再開する | `RefactoringFromAtCoder2025/README.md` / `RefactoringFromAtCoder2025/EVIDENCE.md` |
| `RBT-009` | `FROZEN` | User / Codex | [DECISION] runtime-check実装の再審査 | ユーザードキュメント作業後、1.0中間ゴールへ移行した時点、または`-Ounchecked`が主要構成と判明した時点で再開し、現行実装を1.0へ採用するか一つだけ判断 | `Sources/RedBlackTreeCollections/Documentation/Design/Design-RuntimeChecks.md` |
| `QUALITY-001` | `FROZEN` | User / Codex | 汎用基盤ライブラリとしての1.0採用品質ゲート | Index契約確定後、ユーザーが明示的に再開 | `Sources/RedBlackTreeCollections/Documentation/Quality-Profile.md` |
| `QUALITY-002` | `FROZEN` | Codex | [EXECUTION] 1.0品質保証CIの構成・証拠化 | 1.0品質ゲートの再開後、Ubuntu 24.04 LTS / x86_64のGitHub-hosted runnerで合意済みの品質試験を実行し、commit、workflow run、runner image、kernel、architecture、CPU、Swift、依存解決、選択試験、完全log、終了statusを証拠として残す。変動するrunner上の絶対性能は判定対象に含めない | `QUALITY_REQUIREMENTS.md` / `Tests/TESTING.md` / `.github/workflows/candidate.yml` |
| `QUALITY-003` | `FROZEN` | Codex | [EXECUTION] Apple platforms 27提供境界のmanifest反映・build確認 | 1.0品質ゲートの再開後、対象Apple platformごとの最低deployment versionをmanifestへ反映し、64-bitのplatform別build・導入経路を確認する。macOS 27 / arm64以外はbuild証拠と実行品質を区別する | `QUALITY_REQUIREMENTS.md` / `Package.swift` |

## Task precedence

> 以下は旧記録。現在の参照・更新先は[V2の該当箇所](ProgressV2/TASK_REGISTRY_V2.md#task-precedence)。

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
| `OPT-064` | `OPT-072` | `SEQUENCE` | 一般Swift向けの既定提供方式を再設計してから、一般利用者による理解Validationを実施する |
| `PERM-044` | `PERM-043` | `SEQUENCE` | C++標準に匹敵すると判定する性能比上限を確定してから、保存したmacOS測定証拠へ適用する |
| `PERM-064` | `PERM-063` | `SEQUENCE` | 旧名baselineと新名HEADを対応付けるworkflowを先にmergeしてgreenを確認してから、benchmark titleを変更する |
| `OPS-028` | `OPS-030` | `SEQUENCE` | ユーザーが未採用初稿とレビュー論点を確認してから、Codexが候補を再構成する |
| `RELEASE-020` | `RELEASE-007` | `SEQUENCE` | 0.6.0の到達範囲とrelease開始を決定してから、Pages更新元の一本化をrelease工程として実施する |
| `RELEASE-076` | `RELEASE-075` | `SEQUENCE` | 不足仕様を充当して検証可能な工程にしてから、Validation & Verificationを行う |
| `RELEASE-007` | `OPT-045` | `PARALLEL_JOIN` | 利用者向け文書作業は現行名で先行できるが、0.6.0の到達範囲判断前に次元名体系を確定する |
| `DOC-027` | `DOC-026` | `SEQUENCE` | SPI登録と実在するpackage page・module別DocC URLを確認してから、badgeと公開導線をrepositoryへ反映する |

## Registry rules

> 以下は旧記録。現在の参照・更新先は[V2の該当箇所](ProgressV2/TASK_RULES_V2.md)。

- 状態は`PROPOSED`、`ACTIVE`、`WAITING_USER`、`WAITING_EXTERNAL`、`FROZEN`、`USER_ONLY`、`EXCLUDED`、`DONE`、`ARCHIVED`のいずれかとする。
- `PROPOSED`は忘失防止のtask候補であり、範囲、完了条件、担当、詳細正本、必須依存を確定して状態を更新するまで着手・委任しない。
- `FROZEN`は明示的な再開指示なしに着手しない。
- `USER_ONLY`はユーザー専任とし、AIはtask本体への着手、代行、委任、催促を行わない。ユーザーが
  整理・レビュー・検証などの補助を明示的に依頼した場合は、その範囲だけを行い、task本体の代行や
  完了の受入とは扱わない。
- `WAITING_EXTERNAL`は外部条件が解消するまで着手可能とみなさない。
- Task precedenceには内部task間の必須AND前提だけを記録する。
- Task precedenceのFlowは、前提taskの後に後続taskを始める`SEQUENCE`、または並行を許可して
  後続taskの完了前に合流する`PARALLEL_JOIN`のいずれかを必須とする。
- 新規または内容更新したtaskの項目名は、`[DECISION]`、`[EXECUTION]`、`[DISCOVERY]`のいずれかで始める。
- `DECISION`は一つのユーザー判断だけを含む。複数の判断がある場合は登録前または発見時に分割する。
- `EXECUTION`と`DISCOVERY`はノー判断taskとし、未確定の判断をagentが補って完了させない。
- Task Registryの確定更新は、その仕事を明示的に割り当てられたCodexが担当する。担当欄の名称を読む
  だけでは、この文書を読んだ個体への割当は成立しない。
- 現在の作業状態についての優先順位は、ユーザーの最新指示、Task Registry、詳細正本、Archivedと過去ログ
  の順とする。この順位やtaskの委任から、上位文書の編集・正本採用・参照切替・配置変更の権限を作らない。
