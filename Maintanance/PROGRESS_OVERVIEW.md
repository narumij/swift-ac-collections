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

**現在の中間ゴール:** 0.5.2を完成させる。全公開対象のコメントドック・ドラフトを揃えることは、0.5.2の
到達範囲とrelease開始を判断するための前提であり、中間ゴールそのものではない。対象範囲と証拠の棚卸し、
対象別ドラフト、到達範囲の判断、採用されたrelease工程の実行を、0.5.2へ至るtask graphとして扱う。

**凍結中の中間ゴール（前任conversationの残存記録）:**

- 0.5.1の実施結果からrelease checklistの不足を抽出し、Webマージ、main CI、実際のmain commit確認、
  tag作成、tag pushの順序を次回releaseで誤認しない汎用手順へ改訂する。
- `prepare/release/template`をrelease工程のtemplate branchとする方式について、削除規則、release専用test、
  workflow、mainとのmerge境界を設計し、次回releaseへ適用できる状態にする。
- 残りの`0.5.x`でtemplate branch方式のrelease rehearsalを重ね、各回の工程上の改善だけを
  `prepare/release/template`へ還元し、`0.6.0`を成熟した工程による最初の本運用候補にする。

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
| `GRAPH-001` | `ACTIVE` | Claude | Claude用task graph DBの独立試験 | ready判定を維持する常設nodeとして`ACTIVE`を保つ。個別assignmentや実行中ジョブを意味せず、必要なときだけ現行Registryとの一致を確認 | `Graph/TASK_GRAPH_DB_EXPERIMENT.md` |
| `OPS-001` | `FROZEN` | Codex | [DISCOVERY] Codex task運用playbookの移植可能化 | 2026-10-08、ユーザー指示により保留。明示的な再開指示後、別projectでの再現性検証へ進む | `CODEX_TASK_OPERATION_PLAYBOOK.md` / `PROGRESS_OVERVIEW_TEMPLATE.md` |
| `OPS-002` | `DONE` | Codex / Claude | [EXECUTION] 司令塔オリエンテーションMDの作成 | 2026-10-09、責任分担、証拠基準、技術的難所への入口、文書境界、事故時の復帰経路を統合し、新しい会話による実読確認とユーザー確認を完了 | `CODEX_ORIENTATION.md` |
| `OPS-003` | `DONE` | Codex | [EXECUTION] AI向け技術オリエンテーションの作成 | 2026-10-09、AIが誤認しやすい技術構造、既存中核の由来、証拠経路、停止点を整理し、ユーザー確認を完了 | `AI_TECHNICAL_ORIENTATION.md` |
| `OPS-004` | `DONE` | Claude / Codex | [DISCOVERY] Codex司令塔オリエンテーションの独立レビュー | 2026-10-09、指定6観点のレビュー報告をもって作業完了。指摘と修正案は採用せず参考資料として保存し、本文へ反映しない | `CODEX_ORIENTATION.md` / `CLAUDE_TASK.md` |
| `RELEASE-005` | `DONE` | User / Codex | [DECISION] 0.5.1の到達範囲とrelease検討開始 | 2026-10-09、BareArray契約の堅牢化と三対象のTest as Specificationを0.5.1の範囲として採用し、release checklistへ進むと決定 | `RELEASE_0_5_1.md` |
| `RELEASE-008` | `DONE` | Codex / Claude | [EXECUTION] 0.5.1 release候補の準備と検収 | 2026-10-09、PR #176をmainへmergeし、main CI green確認後、merge commit `d7b3863e`へannotated tag `0.5.1`を作成・pushしてremote到達を確認 | `RELEASE_0_5_1.md` / `RELEASE_CHECKLIST.md` |
| `RELEASE-009` | `FROZEN` | Codex | [DISCOVERY] 0.5.1実績に基づくrelease checklist見直し | 2026-10-09、前任conversationの意図と途中経過の喪失により再開困難なため凍結。明示的な再開指示後、残存記録を参考資料として目的と境界から再確認 | `RELEASE_CHECKLIST.md` / `RELEASE_0_5_1.md` |
| `RELEASE-010` | `DONE` | User / Codex | [DECISION] release template branch方式の採用 | 2026-10-09、`prepare/release/template`から`release/<version>`を切り、mainをmergeして専用工程を実施し、mainへ戻さず同versionのtagを打って完成とする方式を採用。残りの`0.5.x`を工程のrehearsal系列とし、改善をtemplateへ還元して`0.6.0`を成熟した工程の本運用候補とする | `RELEASE_CHECKLIST.md` |
| `RELEASE-011` | `FROZEN` | Codex | [DISCOVERY] `prepare/release/template`の構成設計と試行 | 2026-10-09、前任conversationの意図と途中経過の喪失により再開困難なため凍結。残存ドラフトは当面保存するが既決事項とは扱わず、明示的な再開指示後に目的と境界を再確認 | `RELEASE_TEMPLATE_BRANCH_DESIGN.md` / `RELEASE_CHECKLIST.md` |
| `RELEASE-012` | `DONE` | User / Codex | [DECISION] release treeから除外する内部管理資産 | 2026-10-09、`Maintanance`、`AGENTS.md`、`CLAUDE.md`、`Utilities/Maintenance`はmainへ保持し、release treeから除外すると決定 | `RELEASE_CHECKLIST.md` |
| `RELEASE-013` | `DONE` | User / Codex | [DECISION] release treeにおける互換生成・検証utility | 2026-10-09、`Utilities/Permutation`は通常版への変換を検証する工程中だけ使用し、最終的なtag対象から除外すると決定 | `RELEASE_CHECKLIST.md` |
| `RELEASE-014` | `DONE` | User / Codex | [DECISION] release treeにおけるbenchmark | 2026-10-09、`Benchmarks`はrelease性能gateと利用者が追試できる証拠としてtag対象へ残し、release時は通常CIより大きい入力規模も扱える設計対象とすると決定 | `RELEASE_CHECKLIST.md` |
| `RELEASE-015` | `DONE` | User / Codex | [DECISION] release treeにおける文書境界 | 2026-10-09、tag対象には利用者向け文書だけを残し、品質評価、内部設計、執筆workflow・outline・memoと、通常版から除く互換mode専用文書はmainだけに保持すると決定 | `RELEASE_CHECKLIST.md` |
| `RELEASE-016` | `DONE` | User / Codex | [DECISION] release工程の全test実行方式 | 2026-10-09、`Tests`はtag対象へ残し、Debugのprocess-global寿命カウンタ等価検査を`SKIP_DEBUG_LIFETIME_BALANCE_CHECKS`で外して、隔離されていたSwift Testing・Death Testを含む通常版の全testをrelease工程で実行すると決定。ASanの扱いは変更しない | `RELEASE_CHECKLIST.md` |
| `RELEASE-017` | `DONE` | User / Codex | [DECISION] release専用workflowの変更branch | 2026-10-09、現在の作業branchとmainのworkflowは変更せず、`prepare/release/template`上でrelease専用workflowを別fileとして用意すると決定。`release/<version>`はユーザー操作でremoteへpushしてrelease CIを実行し、変換時にmain用workflowを除外する | `RELEASE_CHECKLIST.md` |
| `RELEASE-018` | `DONE` | User / Codex | [DECISION] release treeにおけるbenchmark結果 | 2026-10-09、benchmark source・release profile・再実行手段はtag対象へ残す一方、`Benchmarks/Results/**`の過去結果は除外し、release測定結果・環境・binary・assemblyはtag対象と同じcommitのCI artifactとして保存すると決定 | `RELEASE_TEMPLATE_BRANCH_DESIGN.md` |
| `RELEASE-019` | `DONE` | User / Codex | [DECISION] release性能の比較baseline | 2026-10-09、直前のrelease tagをbaselineとし、candidate側で固定したrelease profile・benchmark定義をbaselineとcandidateの双方へ適用して同じrunner job内で比較すると決定。0.5.2のbaselineは0.5.1 | `RELEASE_TEMPLATE_BRANCH_DESIGN.md` |
| `RELEASE-020` | `FROZEN` | Codex | [EXECUTION] 0.6.0でGitHub Pages更新元をrelease tagへ一本化 | 0.5.xではmain pushとrelease tag pushの双方によるdeploy競合を許容。0.6.0のrelease工程でmain由来のdeployを停止し、tag commitから生成・検証した利用者向け文書だけがPagesを更新することを確認 | `RELEASE_0_6_0.md` / `RELEASE_TEMPLATE_BRANCH_DESIGN.md` |
| `RELEASE-006` | `FROZEN` | User / Codex | [DECISION] 0.5.2の到達範囲とrelease検討開始 | 全公開対象のコメントドック・ドラフト完成後、0.5.2へ含める到達範囲を一つに定め、release checklistへ進むか判断 | `RELEASE_0_5_2.md` |
| `RELEASE-021` | `EXCLUDED` | Codex | [EXECUTION] 0.5.2 release候補の準備と検収 | 2026-10-09、工程確定前の分解は早すぎるため未着手で除外。準備・検収はrelease工程を具体化する時点で新しいtaskへ分解する | `RELEASE_0_5_2.md` / `RELEASE_CHECKLIST.md` |
| `RELEASE-022` | `PROPOSED` | User / Codex | [DECISION] 0.5.2 release可否ゲート | 後から分解する準備・検収taskが固定候補と必須証拠を揃えた後、0.5.2をreleaseしてよいか一つだけ判断する | `RELEASE_0_5_2.md` / `RELEASE_CHECKLIST.md` |
| `RELEASE-023` | `EXCLUDED` | User / Codex | [EXECUTION] 0.5.2 tag・push・公開 | 2026-10-09、工程確定前の分解は早すぎるため未着手で除外。可否決定後の操作は必要になった時点で個別にtask化する | `RELEASE_0_5_2.md` / `RELEASE_CHECKLIST.md` |
| `DOC-002` | `EXCLUDED` | Codex | [DISCOVERY] 0.5.2コメントドック対象・証拠・阻害判断の棚卸し | 2026-10-09、独立した事前棚卸しを完了させてから執筆する方式を取りやめ。対象別実行taskでTest as Specificationを確認しながら期待動作を直接コメントへ記載する | `RELEASE_0_5_2.md` |
| `DOC-003` | `PROPOSED` | Codex | [EXECUTION] Permutation公開APIコメントドック・ドラフト | `DOC-007`で通常版と互換modeの境界を確定後、公開対象と契約証拠に従い、ユーザーが契約内容をレビューできるコメントドック・ドラフトと検証結果を揃える | `RELEASE_0_5_2.md` / `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` |
| `DOC-004` | `PROPOSED` | Codex | [EXECUTION] OptionalArray公開APIコメントドック・ドラフト | `OPT-044`と`OPT-045`の命名判断後、公開29宣言と4適合を現在のsourceへ再照合し、所有・寿命・破棄・変更・軸・計算量を含むドラフトと検証結果を揃える | `RELEASE_0_5_2.md` / `OptionalArrayModule/OptionalArrayAudit.md` |
| `DOC-005` | `DONE` | Codex | [EXECUTION] BareArray公開APIコメントドック・ドラフト | 2026-10-09、8群のTest as Specificationを確認しながら公開29宣言へ期待動作を記載。Debug／Release通常test・Death Test 42件、code issues 0件、documentation build成功を確認 | `RELEASE_0_5_2.md` / `BareArrayModule/BareArrayAudit.md` |
| `DOC-006` | `PROPOSED` | Codex | [EXECUTION] RedBlackTree公開APIコメントドック・ドラフト | `RBT-014`と必要な公開契約判断の完了後、4公開型のコメントドック・ドラフトと検証結果を揃える。2026-10-09の`DOC-002`棚卸し対象には含めない | `RELEASE_0_5_2.md` / `Sources/RedBlackTreeCollections/Documentation/Head/DOCUMENTATION_WORKFLOW.md` |
| `DOC-007` | `FROZEN` | User / Codex | [DECISION] Permutation通常版と互換modeのコメントドック境界 | 2026-10-09、ユーザー指示により判断を後回し。明示的な再開後、通常版だけを対象とするかAtCoder 2025互換modeも含めるかを一つ決め、`DOC-003`の入力にする | `RELEASE_0_5_2.md` / `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` |
| `DOC-008` | `DONE` | Claude / Codex | [DISCOVERY] BareArrayコメントドック独立レビュー | 2026-10-09、公開29宣言のcoverage、Test as Specificationとの一致、BLOCKなしを受入。判断不要の不揃い4点を補正し、残る2候補はCodexの再検収対象へ分離 | `RELEASE_0_5_2.md` / `CLAUDE_TASK.md` |
| `DOC-009` | `EXCLUDED` | Codex | [EXECUTION] BareArrayのView保持中Sendable注記 | 2026-10-09、`@unchecked Sendable`の妥当性を覆す指摘ではなく、一般的な並行アクセス規則を重ねる蛇足とCodexが判定。公開コメントへの追記は行わない | `RELEASE_0_5_2.md` / `BareArrayModule/BareArrayAudit.md` |
| `DOC-010` | `FROZEN` | Codex | [DISCOVERY] BareArrayの定性的性能表現の再検討 | 2026-10-09、比較対象はSwiftの`[[Element]]`であり、COWと連鎖subscriptによる深刻な性能劣化を単一連続storageと非所有Viewで迂回する設計意図があると確認。アンカリングを避けるため、ユーザー指示による再訪まで文言判断を保留 | `RELEASE_0_5_2.md` / `BareArrayModule/BareArrayAudit.md` |
| `RELEASE-007` | `FROZEN` | User / Codex | [DECISION] 0.6.0の到達範囲とrelease検討開始 | 全公開対象の利用者向けドキュメント初版完成後、0.6.0へ含める到達範囲を一つに定め、release checklistへ進むか判断 | `RELEASE_0_6_0.md` |
| `RBT-014` | `FROZEN` | Codex | RedBlackTree文書workflowと4型outlineのAPI照合 | Permutation、OptionalArray、BareArrayのユーザードキュメント作業で方式を習熟した後、ユーザーが再開。workflowと4公開型のoutlineを現在のAPI、test、設計資料と照合し、本文作成へ渡せる状態を確認 | `Sources/RedBlackTreeCollections/Documentation/Head/DOCUMENTATION_WORKFLOW.md` |
| `RBT-026` | `FROZEN` | User / Codex | [DECISION] Mapped Values ViewのO(1)範囲契約再検討 | 利用者向け文書作業フェーズで、View外だがbase treeでは有効なIndexを黙って読み書きし得る性質を踏まえ、O(1)と呼び出し側事前条件の現行契約を維持するか一つだけ再判断 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-004` | `FROZEN` | Codex | Debug限定Comparable群・Balanced群 | Index契約またはexecutable API Matrix方針の確定後 | `EXTERNAL_TYPE_EXTENSION_AUDIT.md` |
| `RBT-005` | `FROZEN` | Codex | Memoize群の公開終了／正式API化 | 外部consumer 2件の移行後 | `EXTERNAL_TYPE_EXTENSION_AUDIT.md` |
| `PERM-002` | `USER_ONLY` | User | ABC328E実提出確認 | ユーザーが手作業で実施 | `PermutationModule/ImplementationPlan.md` |
| `PERM-028` | `FROZEN` | User / Codex | [DISCOVERY] Permutation strict memory safetyの再検討 | ユーザーが後日明示的に再開したとき、互換modeとは独立に前提、対象構成、警告、完了条件から設計し直す | `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` |
| `OPT-006` | `FROZEN` | Codex | [DISCOVERY] OptionalArray品質評価の文書作業後レビュー | `OPT-005`とユーザードキュメント作業の完了後に再評価し、1.0判断前に解消する不足を独立task候補へ分離 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-043` | `DONE` | External AI / Codex | [DISCOVERY] OptionalArray命名体系のAI間再検討 | 2026-10-09、Claude初稿と第三者AI補完調査をCodexが独立評価し、1D所有型名と次元名を別々の判断へ渡せる材料として受入 | `ARRAY_NAMING_REVIEW.md` / `CHATGPT_ARRAY_NAMING_REVIEW_REQUEST.md` |
| `OPT-044` | `FROZEN` | User | [DECISION] OptionalArray 1D所有型名の再判断 | `OPT-043`受入後、`OptionalArray1D`を維持するか、AI間で整理した選択肢から一つ判断 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `OPT-045` | `FROZEN` | User | [DECISION] OptionalArray次元名体系の再判断 | `OPT-043`受入後、2D・3Dの意味名と4Dの`size0`〜`size3`を維持するか、AI間で整理した選択肢から一つ判断 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `BARE-001` | `DONE` | Codex | [DISCOVERY] BareArrayの体系監査・名称再検討 | 2026-10-09、契約棚卸し、個別判断、Test as Specification、品質評価初版を受入れ、ユーザードキュメント作業へ引渡可能と判定 | `BareArrayModule/BareArrayAudit.md` |
| `BARE-002` | `DONE` | Claude | [DISCOVERY] BareArray公開7型の契約棚卸し | 2026-10-09、公開29宣言と4適合のledger、新しい判断点、後続への振り分けをCodexが受入 | `BareArrayModule/BareArrayAudit.md` |
| `BARE-003` | `DONE` | User | [DECISION] BareArrayを低レベル公開部品として維持するか | 2026-10-09、競技プログラミング向けの低レベル公開部品として維持すると決定 | `BareArrayModule/BareArrayAudit.md` |
| `BARE-004` | `DONE` | User | [DECISION] BareArray公開型・次元名の命名体系 | 2026-10-09、所有型・View型・次元propertyの現行命名体系を維持し、寿命責務と4D軸順は文書で明示すると決定 | `BareArrayModule/BareArrayAudit.md` |
| `BARE-005` | `DONE` | Codex / Claude | [EXECUTION] BareArrayModuleTestsのTest as Specification整理 | 2026-10-09、8個の番号付き仕様群、通常test Debug 35件・Release 28件、Death Test 42件をCodexが受入 | `BareArrayModule/BareArrayAudit.md` |
| `BARE-006` | `FROZEN` | Codex | [DISCOVERY] BareArray 1.0の性能測定設計 | ユーザードキュメント作業後、共通の測定基盤を入力に対象操作・size・比較対象・評価方法を設計し、BareArray固有の製品判断候補を分離 | `Tests/TESTING.md` |
| `BARE-007` | `FROZEN` | Codex | [EXECUTION] BareArray 1.0の性能計測 | `BARE-006`で整理した対象操作・size・比較対象と既存の測定方式に従って計測し、1.0判断へ渡す | `Tests/TESTING.md` |
| `BARE-008` | `DONE` | Claude / Codex | [DISCOVERY] BareArray品質評価初版 | 2026-10-09、ISO/IEC 25010観点の証拠・制約・不足・未確認と後続境界を分離した初版をCodexが受入 | `BareArrayModule/BareArrayAudit.md` |
| `BARE-009` | `DONE` | Claude | [EXECUTION] BareArray既存契約の不足test追加 | 2026-10-09、所有2D〜4D外側subscriptの上下限6件と、非対称寸法での所有型・Viewの全位置照合5件をDebug／Releaseで受入 | `BareArrayModule/BareArrayAudit.md` |
| `BARE-010` | `DONE` | User | [DECISION] BareArrayのNOP setter契約 | 2026-10-09、連鎖書き込みを維持し、同一pointer・shapeのwritebackだけを許す検査付きsetterへ変更すると決定 | `BareArrayModule/BareArrayAudit.md` |
| `BARE-011` | `DONE` | User | [DECISION] BareArrayの不正寸法契約 | 2026-10-09、各次元は非負、zero許可、次元積は`Int`で表現可能というOptionalArrayと同じ事前条件を採用 | `BareArrayModule/BareArrayAudit.md` |
| `BARE-012` | `DONE` | External AI / Codex | [DISCOVERY] BareArray命名体系のAI間検討 | 2026-10-09、Claude初稿と第三者AI補完調査をCodexが独立評価し、現行体系維持を推奨してユーザー判断へ引渡 | `ARRAY_NAMING_REVIEW.md` / `CHATGPT_ARRAY_NAMING_REVIEW_REQUEST.md` |
| `BARE-013` | `DONE` | Codex | [DISCOVERY] BareArray NOP setter代替設計 | 2026-10-09、get-onlyでは連鎖代入不可、settable accessorでは全体代入を構文上除外不可、同一pointer・shapeを検査するsetterは成立すると確認 | `BareArrayModule/BareArrayAudit.md` |
| `BARE-014` | `DONE` | Codex | [EXECUTION] BareArray検査付きView writeback setter | 2026-10-09、所有2D〜4DとView 2D〜3Dを検査付きsetterへ変更し、連鎖書き込み成功と別View代入trap 5件をDebug／Releaseで受入 | `BareArrayModule/BareArrayAudit.md` |
| `BARE-015` | `DONE` | Codex | [EXECUTION] BareArray不正寸法事前条件 | 2026-10-09、1D〜4Dの公開initializerへ非負・zero・積overflow契約を実装し、通常1件・Death Test 14件をDebug／Releaseで受入 | `BareArrayModule/BareArrayAudit.md` |
| `ARRAY-001` | `FROZEN` | Codex | [DISCOVERY] Array系storage・View寿命・strict安全性の再分解 | BareArrayのTest as Specification前に必要な振り分けは`BARE-002`受入へ移管済み。全体再分解はユーザードキュメント作業後、再開時点の契約・品質評価を入力に行う | `StrictMemorySafetyReadiness.md` |
| `RBT-007` | `FROZEN` | User / Codex | RedBlackTreeCollectionsのstrict memory safety全面適用 | ユーザーが段階3を承認 | `StrictMemorySafetyReadiness.md` |
| `RBT-008` | `FROZEN` | User / Codex | `lazyDetach`等の並行初期化保証 | concurrency契約を扱う明示的な再開指示 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `HIST-001` | `FROZEN` | Codex | unsafe移行史の追加調査 | ユーザーが明示的に再開 | `REFACTORING_FROM_ATCODER_2025.md` |
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
| `BARE-004` | `BARE-003` | `SEQUENCE` | 公開維持の決定後に、公開名として維持または変更する命名体系を判断する |
| `BARE-004` | `BARE-012` | `SEQUENCE` | AI同士で命名案、互換性、移行コスト、反証を整理してからユーザー判断へ渡す |
| `OPT-044` | `OPT-043` | `SEQUENCE` | AI同士で1D型名の案、BareArrayとの一貫性、互換性、移行コストを整理してからユーザー判断へ渡す |
| `OPT-045` | `OPT-043` | `SEQUENCE` | AI同士で次元名の案、BareArrayとの一貫性、互換性、移行コストを整理してからユーザー判断へ渡す |
| `BARE-009` | `BARE-003` | `SEQUENCE` | 公開維持の決定後に、現行公開契約の不足testを追加する |
| `BARE-010` | `BARE-003` | `SEQUENCE` | 公開維持の決定後に、NOP setterの公開契約上の位置づけを判断する |
| `BARE-010` | `BARE-013` | `SEQUENCE` | NOP導入経緯と、連鎖書き込みを維持する代替accessorの成立性を確認してから契約を判断する |
| `BARE-014` | `BARE-010` | `SEQUENCE` | 決定した検査付きsetter契約だけを実装・検証する |
| `BARE-015` | `BARE-011` | `SEQUENCE` | 決定した不正寸法事前条件だけを実装・検証する |
| `BARE-011` | `BARE-003` | `SEQUENCE` | 公開維持の決定後に、不正寸法の公開契約を判断する |
| `BARE-005` | `BARE-004` | `SEQUENCE` | 命名体系を確定してから、最終的な公開名に沿って仕様testを整理する |
| `BARE-005` | `BARE-009` | `SEQUENCE` | 現行契約の不足testを追加してからTest as Specificationへ編成する |
| `BARE-005` | `BARE-010` | `SEQUENCE` | NOP setterの契約を確定し、必要な証拠を揃えてから仕様testを整理する |
| `BARE-005` | `BARE-014` | `SEQUENCE` | 検査付きsetterの実装と仕様testを受け入れてからtest全体を整理する |
| `BARE-005` | `BARE-011` | `SEQUENCE` | 不正寸法の契約を確定し、必要な後続実行を閉じてから仕様testを整理する |
| `BARE-005` | `BARE-015` | `SEQUENCE` | 不正寸法の事前条件実装と仕様testを受け入れてからtest全体を整理する |
| `BARE-007` | `BARE-006` | `SEQUENCE` | BareArray固有の測定設計と、必要なら分離した製品判断の完了後に計測する |
| `BARE-001` | `BARE-002` | `PARALLEL_JOIN` | 親監査と契約棚卸しは並行できるが、親監査の完了前に合流する |
| `BARE-001` | `BARE-005` | `PARALLEL_JOIN` | 親監査は先行できるが、完了前にTest as Specification整理と合流する |
| `BARE-008` | `BARE-005` | `SEQUENCE` | 公開契約と仕様testの対応を確定してから、その証拠を入力に品質評価初版を作成する |
| `BARE-001` | `BARE-008` | `PARALLEL_JOIN` | 親監査は先行できるが、ユーザードキュメント作業への引き渡し判定前に品質評価初版と合流する |
| `RELEASE-005` | `BARE-005` | `SEQUENCE` | PermutationとOptionalArrayは整理済み。BareArrayのTest as Specification整理後に0.5.1を検討する |
| `RELEASE-008` | `RELEASE-005` | `SEQUENCE` | 製品上の到達範囲とrelease検討開始を確定してから候補commitを準備する |
| `RELEASE-009` | `RELEASE-008` | `SEQUENCE` | 0.5.1の実際のrelease完了までを観測してから、汎用checklistとの差を見直す |
| `RELEASE-011` | `RELEASE-010` | `SEQUENCE` | template branch方式の採用後に、実際の構成と検証方法を設計・試行する |
| `RELEASE-011` | `RELEASE-012` | `PARALLEL_JOIN` | 構成設計は先行できるが、template branch作成へ渡す前に内部管理資産の除外方針と合流する |
| `RELEASE-011` | `RELEASE-013` | `PARALLEL_JOIN` | 変換検証は先行できるが、tag treeの構成確定前に互換生成・検証utilityの扱いと合流する |
| `RELEASE-011` | `RELEASE-014` | `PARALLEL_JOIN` | 性能gateの設計は先行できるが、tag treeの構成確定前にbenchmarkを再現証拠として残す方針と合流する |
| `RELEASE-011` | `RELEASE-015` | `PARALLEL_JOIN` | 文書分類は先行できるが、tag treeの構成確定前に利用者向け文書だけを残す方針と合流する |
| `RELEASE-011` | `RELEASE-016` | `PARALLEL_JOIN` | test工程の設計は先行できるが、template branch作成へ渡す前に寿命カウンタ検査を外して全testを走らせる方針と合流する |
| `RELEASE-011` | `RELEASE-017` | `PARALLEL_JOIN` | workflow設計は現在branchで進められるが、実装へ渡す前に変更をtemplate branchだけへ限定する方針と合流する |
| `RELEASE-011` | `RELEASE-018` | `PARALLEL_JOIN` | benchmark構成の分類は先行できるが、tag tree確定前に過去結果を除外してrelease結果をCI artifactへ残す方針と合流する |
| `RELEASE-011` | `RELEASE-019` | `PARALLEL_JOIN` | performance workflowの設計は先行できるが、比較実装前に直前release tagをbaselineとする方針と合流する |
| `RELEASE-020` | `RELEASE-007` | `SEQUENCE` | 0.6.0の到達範囲とrelease開始を決定してから、Pages更新元の一本化をrelease工程として実施する |
| `DOC-003` | `DOC-007` | `SEQUENCE` | 通常版と互換modeの対象境界を一つに決めてからPermutation本文を作成する |
| `DOC-004` | `OPT-044` | `SEQUENCE` | 1D所有型名を確定してから最終的な公開名に沿って本文を作成する |
| `DOC-004` | `OPT-045` | `SEQUENCE` | 次元名体系を確定してから軸契約を本文へ反映する |
| `DOC-006` | `RBT-014` | `SEQUENCE` | 三対象で文書作業方式を確認した後、4公開型outlineを現行APIへ照合してから本文を作成する |
| `DOC-008` | `DOC-005` | `SEQUENCE` | BareArrayコメントドックと検証記録が完成してから独立レビューする |
| `RELEASE-006` | `DOC-003` | `PARALLEL_JOIN` | 0.5.2到達範囲の判断前にPermutationコメントドック・ドラフトを揃える |
| `RELEASE-006` | `DOC-004` | `PARALLEL_JOIN` | 0.5.2到達範囲の判断前にOptionalArrayコメントドック・ドラフトを揃える |
| `RELEASE-006` | `DOC-005` | `PARALLEL_JOIN` | 0.5.2到達範囲の判断前にBareArrayコメントドック・ドラフトを揃える |
| `RELEASE-006` | `DOC-006` | `PARALLEL_JOIN` | 0.5.2到達範囲の判断前にRedBlackTreeコメントドック・ドラフトを揃える |

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
