# Task Registry completed history — 2026-10-11

This file preserves task rows and precedence edges removed when the active Registry was compressed.
The exact pre-compression Task Registry is commit `a3b8483d`. Detailed evidence remains in each row’s canonical document.
IDs remain permanent and must not be reused. Earlier snapshots and completed history remain unchanged.

## Completed and excluded tasks

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `OPS-002` | `DONE` | Codex / Claude | [EXECUTION] 司令塔オリエンテーションMDの作成 | 2026-10-09、責任分担、証拠基準、技術的難所への入口、文書境界、事故時の復帰経路を統合し、新しい会話による実読確認とユーザー確認を完了 | `Orientation/CODEX_ORIENTATION.md` |
| `OPS-003` | `DONE` | Codex | [EXECUTION] AI向け技術オリエンテーションの作成 | 2026-10-09、AIが誤認しやすい技術構造、既存中核の由来、証拠経路、停止点を整理し、ユーザー確認を完了 | `Orientation/AI_TECHNICAL_ORIENTATION.md` |
| `OPS-004` | `DONE` | Claude / Codex | [DISCOVERY] Codex司令塔オリエンテーションの独立レビュー | 2026-10-09、指定6観点のレビュー報告をもって作業完了。指摘と修正案は採用せず参考資料として保存し、本文へ反映しない | `Orientation/CODEX_ORIENTATION.md` / `CLAUDE_TASK.md` |
| `OPS-005` | `DONE` | Codex | [EXECUTION] taskオリエンテーションMDの作成 | 2026-10-09、中間ゴールからtask分解、判断分離、依存、ready、距離、受入、ユーザー判断への変換を、OptionalArray・RedBlackTree・独立レビューの実例で説明する初回実践ガイドを作成。三者の反復による由来と事故後の復帰確認を記録し、司令塔オリエンテーションから導線を追加 | `Orientation/TASK_ORIENTATION.md` / `Orientation/CODEX_TASK_OPERATION_PLAYBOOK.md` |
| `OPS-006` | `DONE` | User / Codex | [DECISION] `AGENTS.md`の恒久保持 | 2026-10-09、`AGENTS.md`を会話継続性の基盤としてmainと作業branchへ恒久的に保持し、cleanup、archive、release準備、task再編で削除・退避・一時除去しないと決定。release artifactから内部管理fileを除外する場合も正本は保持する | `AGENTS.md` |
| `RELEASE-005` | `DONE` | User / Codex | [DECISION] 0.5.1の到達範囲とrelease検討開始 | 2026-10-09、BareArray契約の堅牢化と三対象のTest as Specificationを0.5.1の範囲として採用し、release checklistへ進むと決定 | `Archived/Canonical/RELEASE_0_5_1.md` |
| `RELEASE-008` | `DONE` | Codex / Claude | [EXECUTION] 0.5.1 release候補の準備と検収 | 2026-10-09、PR #176をmainへmergeし、main CI green確認後、merge commit `d7b3863e`へannotated tag `0.5.1`を作成・pushしてremote到達を確認 | `Archived/Canonical/RELEASE_0_5_1.md` / `RELEASE_CHECKLIST.md` |
| `RELEASE-010` | `DONE` | User / Codex | [DECISION] release template branch方式の採用 | 2026-10-09、`prepare/release/template`から`release/<version>`を切り、mainをmergeして専用工程を実施し、mainへ戻さず同versionのtagを打って完成とする方式を将来方式として採用。0.5.2は準備不足により適用せず、0.5.1相当のmain release工程を用いる | `RELEASE_CHECKLIST.md` |
| `RELEASE-012` | `DONE` | User / Codex | [DECISION] release treeから除外する内部管理資産 | 2026-10-09、`Maintanance`、`AGENTS.md`、`CLAUDE.md`、`Utilities/Maintenance`はmainへ保持し、release treeから除外すると決定 | `RELEASE_CHECKLIST.md` |
| `RELEASE-013` | `DONE` | User / Codex | [DECISION] release treeにおける互換生成・検証utility | 2026-10-09、`Utilities/Permutation`は通常版への変換を検証する工程中だけ使用し、最終的なtag対象から除外すると決定 | `RELEASE_CHECKLIST.md` |
| `RELEASE-014` | `DONE` | User / Codex | [DECISION] release treeにおけるbenchmark | 2026-10-09、`Benchmarks`はrelease性能gateと利用者が追試できる証拠としてtag対象へ残し、release時は通常CIより大きい入力規模も扱える設計対象とすると決定 | `RELEASE_CHECKLIST.md` |
| `RELEASE-015` | `DONE` | User / Codex | [DECISION] release treeにおける文書境界 | 2026-10-09、tag対象には利用者向け文書だけを残し、品質評価、内部設計、執筆workflow・outline・memoと、通常版から除く互換mode専用文書はmainだけに保持すると決定 | `RELEASE_CHECKLIST.md` |
| `RELEASE-016` | `DONE` | User / Codex | [DECISION] release工程の全test実行方式 | 2026-10-09、`Tests`はtag対象へ残し、Debugのprocess-global寿命カウンタ等価検査を`SKIP_DEBUG_LIFETIME_BALANCE_CHECKS`で外して、隔離されていたSwift Testing・Death Testを含む通常版の全testをrelease工程で実行すると決定。ASanの扱いは変更しない | `RELEASE_CHECKLIST.md` |
| `RELEASE-017` | `DONE` | User / Codex | [DECISION] release専用workflowの変更branch | 2026-10-09、現在の作業branchとmainのworkflowは変更せず、`prepare/release/template`上でrelease専用workflowを別fileとして用意すると決定。`release/<version>`はユーザー操作でremoteへpushしてrelease CIを実行し、変換時にmain用workflowを除外する | `RELEASE_CHECKLIST.md` |
| `RELEASE-018` | `DONE` | User / Codex | [DECISION] release treeにおけるbenchmark結果 | 2026-10-09、benchmark source・release profile・再実行手段はtag対象へ残す一方、`Benchmarks/Results/**`の過去結果は除外し、release測定結果・環境・binary・assemblyはtag対象と同じcommitのCI artifactとして保存すると決定 | `RELEASE_TEMPLATE_BRANCH_DESIGN.md` |
| `RELEASE-019` | `DONE` | User / Codex | [DECISION] release性能の比較baseline | 2026-10-09、直前のrelease tagをbaselineとし、candidate側で固定したrelease profile・benchmark定義をbaselineとcandidateの双方へ適用して同じrunner job内で比較すると決定。0.5.2のbaselineは0.5.1 | `RELEASE_TEMPLATE_BRANCH_DESIGN.md` |
| `RELEASE-006` | `DONE` | User / Codex | [DECISION] 0.5.2の到達範囲とrelease検討開始 | 2026-10-09、BareArray、Permutation通常モード、OptionalArray、RedBlackTreeのコメントドック・ドラフトを0.5.2の製品スコープとして採用し、release checklistへ進むと決定 | `Archived/Canonical/RELEASE_0_5_2.md` |
| `RELEASE-021` | `EXCLUDED` | Codex | [EXECUTION] 0.5.2 release候補の準備と検収 | 2026-10-09、工程確定前の分解は早すぎるため未着手で除外。準備・検収はrelease工程を具体化する時点で新しいtaskへ分解する | `Archived/Canonical/RELEASE_0_5_2.md` / `RELEASE_CHECKLIST.md` |
| `RELEASE-022` | `DONE` | User / Codex | [DECISION] 0.5.2 release可否ゲート | 2026-10-09、固定候補のlocal一次検収とremote CI greenを入力に、独立レビューなしで0.5.2をrelease可とユーザーが決定。merge、tag、pushはそれぞれ別操作として扱う | `Archived/Canonical/RELEASE_0_5_2.md` / `RELEASE_CHECKLIST.md` |
| `RELEASE-023` | `EXCLUDED` | User / Codex | [EXECUTION] 0.5.2 tag・push・公開 | 2026-10-09、工程確定前の分解は早すぎるため未着手で除外。可否決定後の操作は必要になった時点で個別にtask化する | `Archived/Canonical/RELEASE_0_5_2.md` / `RELEASE_CHECKLIST.md` |
| `RELEASE-024` | `DONE` | User / Codex | [DECISION] 0.5.2のrelease branch方式 | 2026-10-09、template branch rehearsalは準備不足のため0.5.2では中止。0.5.1相当として、作業branchで候補を準備・検証し、PRでmainへmerge後、main CIがgreenの同一commitをtag候補とする方式を採用 | `Archived/Canonical/RELEASE_0_5_2.md` / `Archived/Canonical/RELEASE_0_5_1.md` |
| `RELEASE-025` | `DONE` | Codex | [DISCOVERY] 0.5.2候補計画と必須証拠の具体化 | 2026-10-09、0.5.1からの差分を公開コメント3 sourceと内部管理文書へ分類し、0.5.1相当のlocal／remote gate、記録境界、Claude独立確認を定め、候補準備・一次検収・remote CI・独立確認へ分解 | `Archived/Canonical/RELEASE_0_5_2.md` / `RELEASE_CHECKLIST.md` |
| `RELEASE-026` | `DONE` | Codex | [EXECUTION] 0.5.2候補内容の準備と固定 | 2026-10-09、CHANGELOGへ公開コメント差分を記録し、製品差分がBareArray・OptionalArray・Permutation通常モードのコメントだけで、Package・workflow・READMEに差分がないことを確認。内容基準commit `5eb56236`を固定し、記録同期後のHEADをlocal検証へ渡した | `Archived/Canonical/RELEASE_0_5_2.md` / `RELEASE_CHECKLIST.md` |
| `RELEASE-027` | `DONE` | Codex | [EXECUTION] 0.5.2候補のlocal一次検収 | 2026-10-09、固定候補でDebug／Release全testとDeath Test、4対象のdocumentation warning-as-error、公開source・Package・workflow・README差分を検証して成功。既存Permutation compiler警告だけを非阻害として確認 | `Archived/Canonical/RELEASE_0_5_2.md` / `RELEASE_CHECKLIST.md` |
| `RELEASE-028` | `DONE` | Codex | [EXECUTION] 0.5.2候補のremote CI確認 | 2026-10-09、ユーザーから固定候補のremote CI green報告を受け入れ、release可否判断へ引き渡した | `Archived/Canonical/RELEASE_0_5_2.md` / `RELEASE_CHECKLIST.md` |
| `RELEASE-029` | `EXCLUDED` | Claude / Codex | [EXECUTION] 0.5.2固定候補の独立確認 | 2026-10-09、0.5.2はユーザーへのドラフト引き渡しを目的とし、Claudeの使用量制約下では独立レビューなしで進めるというユーザー決定を再確認。release阻害条件から除外 | `Archived/Canonical/RELEASE_0_5_2.md` / `RELEASE_CHECKLIST.md` |
| `RELEASE-030` | `DONE` | User | [EXECUTION] 0.5.2固定候補branchのremote push | 2026-10-09、ユーザーが固定候補branchをremoteへpushし、CI greenを確認。AIはpushを実行していない | `Archived/Canonical/RELEASE_0_5_2.md` / `RELEASE_CHECKLIST.md` |
| `RELEASE-031` | `DONE` | User / Codex | [DISCOVERY] release専用Task Registryの分離設計 | 2026-10-09、配置、schema、life cycle、startup precedence、task運用summary、完了／中止cleanup、checklist由来の実行task骨格、内部採番、移行taskへの分解を確定 | `RELEASE_TASK_REGISTRY_DESIGN.md` / `RELEASE_TASK_REGISTRY_TEMPLATE.md` / `RELEASE_CHECKLIST.md` |
| `RELEASE-032` | `DONE` | User / Codex | [EXECUTION] 0.5.2 annotated tag作成 | 2026-10-09、ユーザー承認後、main CI greenのmerge commit `631cb59a`へmessage `Release 0.5.2`のannotated tag `0.5.2`をlocal作成し、対象commitを読み戻した | `Archived/Canonical/RELEASE_0_5_2.md` / `RELEASE_CHECKLIST.md` |
| `RELEASE-033` | `DONE` | User / Codex | [EXECUTION] 0.5.2 tag push | 2026-10-09、ユーザー承認後、`refs/tags/0.5.2`だけをoriginへpushし、remote tagが`631cb59a`を指すことを読み戻した | `Archived/Canonical/RELEASE_0_5_2.md` / `RELEASE_CHECKLIST.md` |
| `RELEASE-069` | `DONE` | User | [EXECUTION] 0.5.3中間ゲート起動 | 2026-10-10、ユーザーが`README.ja.md`をcommit `f7fcdd09`で編集し、中間ゲートを起動。AIは編集を代行していない | `README.ja.md` |
| `RELEASE-034` | `DONE` | User / Codex | [DECISION] 0.5.3 release作業開始 | 2026-10-10、ユーザーが開始を承認し、release専用Registryを起動して実行へ委譲 | `Archived/Canonical/RELEASE_0_5_3.md` |
| `RELEASE-070` | `DONE` | User / Codex | [EXECUTION] 0.5.3 release実行 | candidate `5c22e2cf`のlocal build・DocC、remote CI、main merge・CIを確認し、merge commit `139ffef8`へannotated tag `0.5.3`を作成・push。remote到達確認後、`develop/misc/55`を作成 | `Archived/Canonical/RELEASE_0_5_3.md` |
| `RELEASE-071` | `DONE` | Codex | [EXECUTION] tag push工程のrelease Registry template反映 | 2026-10-10、0.5.3実行時にtemplateからtag push工程が欠落していた実績を受け、独立した判断・ユーザー専任push・remote tag確認を実release templateへ追加。今後の別テーマのrehearsalを維持しつつ二重管理を避けるため、訓練templateは本番templateを参照する薄いoverlayへ変更 | `RELEASE_TASK_REGISTRY_TEMPLATE.md` / `RELEASE_TASK_REGISTRY_REHEARSAL_TEMPLATE.md` / `RELEASE_TASK_REGISTRY_DESIGN.md` / `Archived/Canonical/RELEASE_0_5_3.md` |
| `RELEASE-073` | `DONE` | User / Codex | [DECISION] 人間向けリリース工程のコンセプト定義策定 | 2026-10-10、ユーザーが製品コンセプトを一文で定義し、Codexの軽いレビューで対象、性能上の強み、競技プログラミング起点、一般Swift開発への展開が品質要求定義へ渡せることを確認 | `User/CONCEPT_DEFINITION.md` |
| `RELEASE-074` | `DONE` | User / Codex / Claude | [DISCOVERY] 製品品質要求定義の同抽象度ドラフト再作成 | 2026-10-10、コンセプトから上位品質要求を導き、既存のTest as Specification、品質評価、性能証拠、文書、CIへの接続、洗練の手がかり、V&V、不足仕様候補までを同じ抽象度で再作成。Claudeは他案未読、CodexはChappy版既読を明示し、具体的閾値・release停止条件・工程設計を確定せず完了 | `User/CONCEPT_DEFINITION.md` / `User/Archived/QUALITY_REQUIREMENTS_CODEX_V2.md` / `User/Archived/QUALITY_REQUIREMENTS_CLAUDE_V2.md` |
| `RELEASE-077` | `DONE` | Claude / Codex | [EXECUTION] 製品品質要求の本体・参照資料分離 | 2026-10-11、Chappy V4を`QUALITY_REQUIREMENTS.md`へ改名して正本化し、Claude V2から非規範的な参照資料を抽出・再編。本体、参照資料、元ドラフトを相対linkで接続し、観察を作成時点の`UNVERIFIED`として隔離した構造をCodexがcommit `3c496eeb`で検収・受入 | `User/QUALITY_REQUIREMENTS.md` / `User/QUALITY_REQUIREMENTS_REFERENCE.md` / `User/Archived/QUALITY_REQUIREMENTS_CLAUDE_V2.md` / `CLAUDE_TASK.md` |
| `QUALITY-002` | `DONE` | Claude / Codex | [DISCOVERY] 品質プロファイル共通骨格の独立レビュー（DIRECT） | 2026-10-11、両profileの共通骨格を受入。BLOCKなし。上位要求名、外部性能比較、評価状態、未実施の実提出、strict memory safety適用経路に関するNOTE 5件をCodexが最小修正へ反映 | `Sources/RedBlackTreeCollections/Documentation/Quality-Profile.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` / `CLAUDE_TASK.md` |
| `PERM-028` | `DONE` | User / Codex | [DISCOVERY] Permutation strict memory safetyの再検討 | 2026-10-11、通常版`PermutationModule` targetへの`.strictMemorySafety()`恒久適用を現行`Package.swift`で再確認し、testingを含むproject buildが警告・errorなしで成功。危険操作は明示的なscoped `unsafe`に置かれている。AtCoder 2025互換modeと実提出Validationは対象外 | `Sources/PermutationModule/Documentation/Quality-Profile.md` / `Package.swift` |
| `PERM-039` | `DONE` | Codex | [DISCOVERY] Permutation現行品質アセスメント | 2026-10-11、QR-01〜QR-06を現行仕様・test・build・benchmark・CI・利用経路へ接続して評価。通常版38件とfacade 1件のtest成功、strict build成功を確認。C/C++外部性能比較、競技実提出、一般Swift利用Validationを未検証として分離した | `PermutationModule/CurrentQualityAssessment.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` |
| `DOC-002` | `EXCLUDED` | Codex | [DISCOVERY] 0.5.2コメントドック対象・証拠・阻害判断の棚卸し | 2026-10-09、独立した事前棚卸しを完了させてから執筆する方式を取りやめ。対象別実行taskでTest as Specificationを確認しながら期待動作を直接コメントへ記載する | `Archived/Canonical/RELEASE_0_5_2.md` |
| `DOC-003` | `DONE` | Codex | [EXECUTION] Permutation公開APIコメントドック・ドラフト完成判定 | 2026-10-09、通常版のレビュー用ドラフトと検証を受入。`DOC-007`でAtCoder 2025互換modeを0.5.2の対象外と決定したため、追加実行なしでユーザーへの引き渡しを完了 | `Archived/Canonical/RELEASE_0_5_2.md` / `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` |
| `DOC-004` | `DONE` | Codex | [EXECUTION] OptionalArray公開APIコメントドック・ドラフト | 2026-10-09、現行名の公開29宣言と4適合をTest as Specification・実装へ再照合し、所有、View寿命、破棄、変更共有、軸、境界、計算量をレビュー用コメントへ記載。Debug／Release通常35件＋Death Test 21件、documentation warning-as-error成功。0.5.2段階の成果としてユーザーへ引き渡し済み | `Archived/Canonical/RELEASE_0_5_2.md` / `OptionalArrayModule/OptionalArrayAudit.md` |
| `DOC-005` | `DONE` | Codex | [EXECUTION] BareArray公開APIコメントドック・ドラフト | 2026-10-09、8群のTest as Specificationを確認しながら公開29宣言へ期待動作を記載。Debug／Release通常test・Death Test 42件、code issues 0件、documentation build成功を確認 | `Archived/Canonical/RELEASE_0_5_2.md` / `BareArrayModule/BareArrayAudit.md` |
| `DOC-006` | `DONE` | Codex | [EXECUTION] RedBlackTree公開APIコメントドック・ドラフト | 2026-10-09、既存の公開コメント横断監査、4公開型のHead原稿、API Matrix、Test as Specification、Release DocC検証により、0.5.2が要求するユーザーレビュー可能なドラフトへ到達済みと確認。公開可能な初版への仕上げは0.6.0側で扱う | `Archived/Canonical/RELEASE_0_5_2.md` / `Sources/RedBlackTreeCollections/Documentation/Head/DOCUMENTATION_WORKFLOW.md` |
| `DOC-007` | `DONE` | User / Codex | [DECISION] Permutation通常版と互換modeのコメントドック境界 | 2026-10-09、0.5.2のコメントドック対象は通常版だけとし、AtCoder 2025互換modeは含めないと決定 | `Archived/Canonical/RELEASE_0_5_2.md` / `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` |
| `DOC-008` | `DONE` | Claude / Codex | [DISCOVERY] BareArrayコメントドック独立レビュー | 2026-10-09、公開29宣言のcoverage、Test as Specificationとの一致、BLOCKなしを受入。判断不要の不揃い4点を補正し、残る2候補はCodexの再検収対象へ分離 | `Archived/Canonical/RELEASE_0_5_2.md` / `CLAUDE_TASK.md` |
| `DOC-009` | `EXCLUDED` | Codex | [EXECUTION] BareArrayのView保持中Sendable注記 | 2026-10-09、`@unchecked Sendable`の妥当性を覆す指摘ではなく、一般的な並行アクセス規則を重ねる蛇足とCodexが判定。公開コメントへの追記は行わない | `Archived/Canonical/RELEASE_0_5_2.md` / `BareArrayModule/BareArrayAudit.md` |
| `DOC-011` | `DONE` | Codex | [EXECUTION] Permutation通常版の公開APIコメントドック・レビュー用ドラフト | 2026-10-09、通常版のTest as Specificationへ照合し、入力copy、iterator独立性、終端、zero-based index、値semantics、計算量をレビュー用ドラフトとして公開コメントへ記載。Debug 32件＋Death Test 5件、Release 28件＋Death Test 5件、documentation warning-as-error成功。0.5.2段階の成果としてユーザーへ引き渡し済みで、受入レビューとClaude独立レビューはこのtaskの完了条件に含めない。互換modeは未変更 | `Archived/Canonical/RELEASE_0_5_2.md` / `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` |
| `DOC-012` | `DONE` | Codex | [DISCOVERY] RedBlackTree以外の公開targetのコメントドック・セルフレビュー | 2026-10-10、4対象を実装と対応testへ照合。判断不要のコメント不一致はなし。PermutationのRelease構成におけるiterator copy独立性は未確認事項、OptionalArrayのView setter契約は製品判断候補として記録し、推定による修正は行わなかった | `Archived/Canonical/NON_RBT_COMMENT_DOC_SELF_REVIEW.md` / `RELEASE_0_6_0.md` |
| `DOC-013` | `DONE` | Claude / Codex | [DISCOVERY] 3モジュールのコメントドック独立ドラフト品質レビュー | 2026-10-10、Claudeのread-only証拠packageをCodexが検収。先行観測2件に加え、計算量1件・破棄説明1件・用語2件を受入れ、過剰な完成判定とtest不足だけによる未確認分類は採用しなかった。Claudeへの追加依頼なし | `CLAUDE_TASK.md` / `Archived/Canonical/NON_RBT_COMMENT_DOC_SELF_REVIEW.md` / `Orientation/AGENT_TASK_FIT_INTERVIEW.md` |
| `DOC-014` | `DONE` | Codex | [EXECUTION] Permutation計算量コメント補正と横断確認 | 2026-10-10、`makeIterator()`、公開入口、index、等値比較、hash、descriptionへ実装に基づく計算量を補い、OptionalArrayとBareArrayの対象operationは記載済みで一致すると確認。Xcode buildと3 targetのdocumentation build成功 | `Archived/Canonical/NON_RBT_COMMENT_DOC_SELF_REVIEW.md` |
| `DOC-015` | `DONE` | Codex | [DISCOVERY] OptionalArray上書き破棄契約の重大課題調査 | 2026-10-10、所有1Dと1DViewの別実装および参照寿命testを確認。記載不能ではなく重要なcoverage不足と判定し、両subscriptへ非nil上書き時の旧要素破棄を追記。Xcode buildとdocumentation build成功 | `Archived/Canonical/NON_RBT_COMMENT_DOC_SELF_REVIEW.md` / `OptionalArrayModule/OptionalArrayAudit.md` |
| `DOC-016` | `DONE` | Codex | [EXECUTION] OptionalArray4Dの軸表現補正 | 2026-10-10、`array[size3][size2][size1][size0]`を`array[w][z][y][x]`へ補正。file診断0件、Xcode buildとdocumentation build成功 | `Archived/Canonical/NON_RBT_COMMENT_DOC_SELF_REVIEW.md` |
| `DOC-017` | `DONE` | Codex | [EXECUTION] BareArray 1Dの多次元表現補正 | 2026-10-10、1D型本文の「多次元配列」を「配列」へ補正。file診断0件、Xcode buildとdocumentation build成功 | `Archived/Canonical/NON_RBT_COMMENT_DOC_SELF_REVIEW.md` |
| `DOC-018` | `DONE` | Codex | [EXECUTION] 3モジュール公開コメントのparameter欄補完 | 2026-10-10、parameterを持つ公開宣言29件（BareArray 15、OptionalArray 11、Permutation 3）へDocC parameter欄を追加。3 targetのdocumentation buildを`--warnings-as-errors`付きで実行して成功 | `Archived/Canonical/NON_RBT_COMMENT_DOC_SELF_REVIEW.md` |
| `DOC-019` | `DONE` | Codex / Claude | [DISCOVERY] 非RedBlackTreeコードスニペット候補TOP10アンケート | 2026-10-10、BareArray・OptionalArray・Permutationを対象に、編集先を分けて各TOP10を確定し、強い一致8観点と相違を統合TOP10へ整理 | `Archived/Canonical/CODE_SNIPPET_SURVEY.md` / `Archived/Canonical/CODE_SNIPPET_SURVEY_CODEX.md` / `Archived/Canonical/CODE_SNIPPET_SURVEY_CLAUDE.md` |
| `DOC-020` | `DONE` | Codex / Claude | [DISCOVERY] リポジトリ公開APIコードスニペット候補TOP10アンケート第2弾 | 2026-10-10、リポジトリ全体の公開APIから両者が各TOP10を選定し、共通5観点、各固有候補、既存RedBlackTreeスニペットの修正候補を整理。回答file分離は同時編集の競合回避だけに使用 | `Archived/Canonical/PUBLIC_API_CODE_SNIPPET_SURVEY_2.md` / `Archived/Canonical/PUBLIC_API_CODE_SNIPPET_SURVEY_2_CODEX.md` / `Archived/Canonical/PUBLIC_API_CODE_SNIPPET_SURVEY_2_CLAUDE.md` |
| `DOC-021` | `DONE` | Claude / Codex | [EXECUTION] RedBlackTree境界式例の現行API修正 | 2026-10-11、型コメント3 fileとHead文書6 fileの存在しない`.advance(by:)`および境界式の`.endIndex`を`.advanced(by:)`と`.end`へ限定修正。Claudeの一時clientによる9例のcompile・実行成功、旧表記0件、CodexのHEAD build成功を確認して受入 | `Archived/Canonical/PUBLIC_API_CODE_SNIPPET_SURVEY_2.md` / `CLAUDE_PENDING_TASKS.md` |
| `DOC-022` | `DONE` | Codex | [EXECUTION] OptionalArray品質評価参照の現状同期 | 2026-10-11、OptionalArrayの旧品質評価をアーカイブし、現行`Quality-Profile.md`へ移行したことで、`Tests/TESTING.md`のPermutationと同形式という記述が現在事実と一致。本文変更なしで不一致を解消 | `Tests/TESTING.md` / `Sources/OptionalArrayModule/Documentation/Quality-Profile.md` |
| `PERM-029` | `DONE` | Codex | [DISCOVERY] Swift 6.4 Releaseでのiterator copy独立性再確認 | 2026-10-10、`Buffer.copy()`だけを非インライン化するとDebug／Release回帰testが成功し、再インライン化した一時copyではRelease再現することを独立確認。Release機械語でhot path分離とwitness参照範囲を確認し、ユーザー報告の性能CI greenを受け入れ、コメント補正まで完了。原因自体は未断定 | `Sources/PermutationModule/Permutations.swift` / `Tests/PermutationTests/NextPermutationsSequence/NextPermutationsSequence_2_ValueSemanticsTests.swift` / `CLAUDE_TASK.md` / `CLAUDE_PENDING_TASKS.md` |
| `OPT-043` | `DONE` | External AI / Codex | [DISCOVERY] OptionalArray命名体系のAI間再検討 | 2026-10-09、Claude初稿と第三者AI補完調査をCodexが独立評価し、1D所有型名と次元名を別々の判断へ渡せる材料として受入 | `Archived/Canonical/ARRAY_NAMING_REVIEW.md` / `Archived/Canonical/CHATGPT_ARRAY_NAMING_REVIEW_REQUEST.md` |
| `OPT-046` | `DONE` | Codex | [EXECUTION] OptionalArray View writeback setterの契約検査 | 2026-10-10、所有2D〜4DとView 2D〜3Dの5 setterへposition・`hasPayload`・`payload`・shape検査を追加。Debug／Release通常test各35件、Death Test各26件、documentation buildが成功 | `OptionalArrayModule/OptionalArrayAudit.md` |
| `BARE-001` | `DONE` | Codex | [DISCOVERY] BareArrayの体系監査・名称再検討 | 2026-10-09、契約棚卸し、個別判断、Test as Specification、品質評価初版を受入れ、ユーザードキュメント作業へ引渡可能と判定 | `BareArrayModule/BareArrayAudit.md` |
| `BARE-002` | `DONE` | Claude | [DISCOVERY] BareArray公開7型の契約棚卸し | 2026-10-09、公開29宣言と4適合のledger、新しい判断点、後続への振り分けをCodexが受入 | `BareArrayModule/BareArrayAudit.md` |
| `BARE-003` | `DONE` | User | [DECISION] BareArrayを低レベル公開部品として維持するか | 2026-10-09、競技プログラミング向けの低レベル公開部品として維持すると決定 | `BareArrayModule/BareArrayAudit.md` |
| `BARE-004` | `DONE` | User | [DECISION] BareArray公開型・次元名の命名体系 | 2026-10-09、所有型・View型・次元propertyの現行命名体系を維持し、寿命責務と4D軸順は文書で明示すると決定 | `BareArrayModule/BareArrayAudit.md` |
| `BARE-005` | `DONE` | Codex / Claude | [EXECUTION] BareArrayModuleTestsのTest as Specification整理 | 2026-10-09、8個の番号付き仕様群、通常test Debug 35件・Release 28件、Death Test 42件をCodexが受入 | `BareArrayModule/BareArrayAudit.md` |
| `BARE-008` | `DONE` | Claude / Codex | [DISCOVERY] BareArray品質評価初版 | 2026-10-09、ISO/IEC 25010観点の証拠・制約・不足・未確認と後続境界を分離した初版をCodexが受入 | `BareArrayModule/BareArrayAudit.md` |
| `BARE-009` | `DONE` | Claude | [EXECUTION] BareArray既存契約の不足test追加 | 2026-10-09、所有2D〜4D外側subscriptの上下限6件と、非対称寸法での所有型・Viewの全位置照合5件をDebug／Releaseで受入 | `BareArrayModule/BareArrayAudit.md` |
| `BARE-010` | `DONE` | User | [DECISION] BareArrayのNOP setter契約 | 2026-10-09、連鎖書き込みを維持し、同一pointer・shapeのwritebackだけを許す検査付きsetterへ変更すると決定 | `BareArrayModule/BareArrayAudit.md` |
| `BARE-011` | `DONE` | User | [DECISION] BareArrayの不正寸法契約 | 2026-10-09、各次元は非負、zero許可、次元積は`Int`で表現可能というOptionalArrayと同じ事前条件を採用 | `BareArrayModule/BareArrayAudit.md` |
| `BARE-012` | `DONE` | External AI / Codex | [DISCOVERY] BareArray命名体系のAI間検討 | 2026-10-09、Claude初稿と第三者AI補完調査をCodexが独立評価し、現行体系維持を推奨してユーザー判断へ引渡 | `Archived/Canonical/ARRAY_NAMING_REVIEW.md` / `Archived/Canonical/CHATGPT_ARRAY_NAMING_REVIEW_REQUEST.md` |
| `BARE-013` | `DONE` | Codex | [DISCOVERY] BareArray NOP setter代替設計 | 2026-10-09、get-onlyでは連鎖代入不可、settable accessorでは全体代入を構文上除外不可、同一pointer・shapeを検査するsetterは成立すると確認 | `BareArrayModule/BareArrayAudit.md` |
| `BARE-014` | `DONE` | Codex | [EXECUTION] BareArray検査付きView writeback setter | 2026-10-09、所有2D〜4DとView 2D〜3Dを検査付きsetterへ変更し、連鎖書き込み成功と別View代入trap 5件をDebug／Releaseで受入 | `BareArrayModule/BareArrayAudit.md` |
| `BARE-015` | `DONE` | Codex | [EXECUTION] BareArray不正寸法事前条件 | 2026-10-09、1D〜4Dの公開initializerへ非負・zero・積overflow契約を実装し、通常1件・Death Test 14件をDebug／Releaseで受入 | `BareArrayModule/BareArrayAudit.md` |

## Completed precedence history

後続taskが完了または除外済みのため、現行graphから退避した辺。

| 後続task | 前提task | Flow | 制約 |
| --- | --- | --- | --- |
| `BARE-005` | `BARE-002` | `SEQUENCE` | 契約棚卸しを受け入れ、先行する契約判断・不足testの有無を再計算した後に整理へ着手できる |
| `BARE-004` | `BARE-003` | `SEQUENCE` | 公開維持の決定後に、公開名として維持または変更する命名体系を判断する |
| `BARE-004` | `BARE-012` | `SEQUENCE` | AI同士で命名案、互換性、移行コスト、反証を整理してからユーザー判断へ渡す |
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
| `BARE-001` | `BARE-002` | `PARALLEL_JOIN` | 親監査と契約棚卸しは並行できるが、親監査の完了前に合流する |
| `BARE-001` | `BARE-005` | `PARALLEL_JOIN` | 親監査は先行できるが、完了前にTest as Specification整理と合流する |
| `BARE-008` | `BARE-005` | `SEQUENCE` | 公開契約と仕様testの対応を確定してから、その証拠を入力に品質評価初版を作成する |
| `BARE-001` | `BARE-008` | `PARALLEL_JOIN` | 親監査は先行できるが、ユーザードキュメント作業への引き渡し判定前に品質評価初版と合流する |
| `RELEASE-005` | `BARE-005` | `SEQUENCE` | PermutationとOptionalArrayは整理済み。BareArrayのTest as Specification整理後に0.5.1を検討する |
| `RELEASE-008` | `RELEASE-005` | `SEQUENCE` | 製品上の到達範囲とrelease検討開始を確定してから候補commitを準備する |
| `RELEASE-025` | `RELEASE-006` | `SEQUENCE` | 0.5.2の製品範囲とrelease検討開始を確定してから候補計画を具体化する |
| `RELEASE-025` | `RELEASE-024` | `SEQUENCE` | 0.5.2で使うbranch方式を確定してから、その工程に沿った候補境界と証拠を設計する |
| `RELEASE-026` | `RELEASE-025` | `SEQUENCE` | 候補境界と必須証拠を具体化してから候補内容を準備・固定する |
| `RELEASE-027` | `RELEASE-026` | `SEQUENCE` | 候補commitを固定してから同じcommitへlocal一次検収を行う |
| `RELEASE-028` | `RELEASE-026` | `SEQUENCE` | 候補commitを固定し、remote反映の対象を一意にしてからCIを確認する |
| `RELEASE-028` | `RELEASE-030` | `SEQUENCE` | ユーザー専任のfixed candidate branch pushが完了してからCodexがCIを確認する |
| `RELEASE-034` | `RELEASE-069` | `GATE` | 日本語READMEのダミー編集を契機に中間ゲートを起動し、0.5.3のrelease作業開始を判断する |
| `RELEASE-074` | `RELEASE-073` | `SEQUENCE` | 人間向けリリース工程のコンセプトを定めてから、それを実現するための品質要求と証拠を具体化する |
| `RELEASE-077` | `RELEASE-074` | `SEQUENCE` | 同抽象度の独立ドラフトと既存品質資産への接続候補を揃えてから、品質要求本体と非規範的な参照資料を分離する |
| `RELEASE-029` | `RELEASE-027` | `PARALLEL_JOIN` | local一次検収の証拠を揃えてから独立確認へ渡す |
| `RELEASE-029` | `RELEASE-028` | `PARALLEL_JOIN` | 同じ候補commitのremote CI証拠を揃えてから独立確認へ渡す |
| `RELEASE-022` | `RELEASE-027` | `PARALLEL_JOIN` | release可否判断前に固定候補のlocal一次検収を完了する |
| `RELEASE-022` | `RELEASE-028` | `PARALLEL_JOIN` | release可否判断前に同じ候補commitのremote CIを確認する |
| `RELEASE-022` | `RELEASE-029` | `PARALLEL_JOIN` | release可否判断前にClaude独立確認とCodex受入を完了する |
| `DOC-003` | `DOC-007` | `PARALLEL_JOIN` | 通常版の執筆は先行できるが、Permutation全体の完成判定前に互換modeの対象境界を確定する |
| `DOC-003` | `DOC-011` | `PARALLEL_JOIN` | 通常版の公開APIコメントと検証を先行して揃え、Permutation全体の完成判定前に合流する |
| `DOC-008` | `DOC-005` | `SEQUENCE` | BareArrayコメントドックと検証記録が完成してから独立レビューする |
| `RELEASE-006` | `DOC-003` | `PARALLEL_JOIN` | 0.5.2到達範囲の判断前にPermutationコメントドック・ドラフトを揃える |
| `RELEASE-006` | `DOC-004` | `PARALLEL_JOIN` | 0.5.2到達範囲の判断前にOptionalArrayコメントドック・ドラフトを揃える |
| `RELEASE-006` | `DOC-005` | `PARALLEL_JOIN` | 0.5.2到達範囲の判断前にBareArrayコメントドック・ドラフトを揃える |
| `RELEASE-006` | `DOC-006` | `PARALLEL_JOIN` | 0.5.2到達範囲の判断前にRedBlackTreeコメントドック・ドラフトを揃える |

## Satisfied edges removed from the active graph

後続taskは現役だが、前提taskが完了・除外済みのため現行graphから退避した辺。
後続task固有の再開・完了条件は現行Registry行に残る。

| 後続task | 完了・除外済み前提task | Flow | 制約 |
| --- | --- | --- | --- |
| `OPT-044` | `OPT-043` | `SEQUENCE` | AI同士で1D型名の案、BareArrayとの一貫性、互換性、移行コストを整理してからユーザー判断へ渡す |
| `OPT-045` | `OPT-043` | `SEQUENCE` | AI同士で次元名の案、BareArrayとの一貫性、互換性、移行コストを整理してからユーザー判断へ渡す |
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
| `RELEASE-035` | `RELEASE-031` | `SEQUENCE` | 分離設計とtask骨格の確定後に旧checklistをtemplateへ移行する |
| `RELEASE-072` | `RELEASE-073` | `SEQUENCE` | 人間向けリリース工程のコンセプトを定義してから、その目的と役割分担を一枚の工程表へ具体化する |
| `RELEASE-075` | `RELEASE-074` | `SEQUENCE` | リリース工程の品質要求を定義してから、その要求に対する不足仕様を充当する |
