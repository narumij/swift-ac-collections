# 凍結タスク棚卸し 2026-10-16

作成：Astra。基準commit：`8132eb63`、開始時の作業ツリーは未変更。

ユーザーの「不要・重複は消し、必要なゲートで介入凍結に巻き込まれたものは復活してほしい」という依頼に基づく。凍結26件と、照合中に見つかった重複候補1件を対象に、現行方針・詳細資料・実物・受入記録を照合した。状態の正本は[Task Registry](../ProgressV2/TASK_REGISTRY_V2.md)。

## 結果と適用範囲

- 凍結26件のうち3件をEXCLUDEDとして残作業から外し、6件をACTIVEへ戻した。凍結は17件となる。
- 関連するPROPOSEDの名称決定ゲート確認1件も、移行受入と重複するためEXCLUDEDとして外した。
- 削除した4件の番号は使用済みのまま保持。[変更前の27行・外した依存辺・除外理由](../Archived/FROZEN_TASKS_BEFORE_RECONCILIATION_2026-10-16.md)を保存した。完了を偽装するDONEにはしていない。
- 復帰は計画上の有効化であり、合格、製品判断、担当への発注、実装・測定・公開の実行ではない。必要な証拠とユーザー判断を維持する。

事故や介入が凍結原因だったとは一括して断定できない。例えばQUALITY-001はcommit `7784ff7f`で最初からFROZENとして登録されている。今回の復帰は、現行の1.0方針と依存関係に照らして必要性を確認し、今回のユーザー依頼を根拠に行った。過去の記録から権限を復活させたものではない。

## 残作業から外したもの

| ID | 理由と引継ぎ先 |
| --- | --- |
| DOC-010 | [ElementBuffer品質プロファイル](../../Sources/ElementBufferModule/Documentation/Quality-Profile.md)の「供用区分と設計判断」に、ユーザーによる定性的性能表現の維持判断が記録済み。文言の再判断という独立作業を除外。新しい比較測定や性能適合が完了したことにはしない |
| BARE-035 | [現行品質要求](QUALITY_REQUIREMENTS.md)でElementBufferは1.0競技供用・一般供用の対象。旧「対象外」から残った提供停止検討には現在の需要がなく除外。提供停止を将来の義務として残さない |
| PERM-046 | 現行品質要求はNextPermutationModuleをSwift 6.4以降の対象とし、[manifest](../../Package.swift)も6.4。6.2向けソース利用やAtCoder互換modeを、package全体の6.2提供義務に広げない。version-specific manifest調査は現行範囲から除外 |
| PERM-071 | [名称決定](PUBLIC_API_NAMING_DECISIONS.md)、[移行計画の完了記録](PERMUTATION_MODULE_MIGRATION_PLAN.md)、[独立受入とPR/main到達記録](../Archived/PermutationMigration_2026-10-16/PERMUTATION_MODULE_MIGRATION_ACCEPTANCE.md)で、名称・新旧入口・generic parameter・compile/DocC等が照合済み。ゲート確認を受入へ吸収して除外。名称レビュー冒頭の「未決定」を訂正し、決定正本と移行へ接続した |

除外は今の目的に対する仕事の整理であり、将来の別の需要や新しい反証を否定しない。再検討が必要になった場合も、過去の行を無条件に実行指示として使わない。

## 有効な計画へ戻したもの

| ID | 戻した理由と残る条件 |
| --- | --- |
| QUALITY-001 | 1.0として受け入れるかのゲートは現在も必要。行の「Index確定後に再開」と、依存表の「品質調査は並行可能」が食い違っていた。Indexは最終判定の合流条件として保持し、全準備作業の停止条件にはしない |
| RBT-009 | [runtime-check設計](../../Sources/RedBlackTreeCollections/Documentation/Design/Design-RuntimeChecks.md)が1.0前の再審査を要求。判断ゲートとして復帰。防御の変更や-Ouncheckedの保証変更は行わず、判断材料とユーザー決定を待つ |
| RBT-034 | [赤黒木の評価](../RedBlackTreeModule/CurrentQualityAssessment.md)を1.0対象版の証拠へ接続する仕事は残る。QUALITY-001の復帰に伴い証拠準備を有効化。既存の0.6評価や型別レビューを未完了へ戻さない |
| QUALITY-002 | [品質要求](QUALITY_REQUIREMENTS.md)のLinux代表環境の証拠は必要。既存のCI成功をゼロ扱いせず、要求との差だけ補う仕事として復帰。今回CIを変更・起動しない |
| QUALITY-003 | 品質要求の暫定Apple platforms 27方針に対し、manifestはmacOS 15の宣言。宣言・platform別build・導入の不足が残るため復帰。対応環境の新規決定、manifest変更、buildは今回実施しない |
| QUALITY-005 | [SPI登録前ゲート](SPI_REGISTRATION_GATE.md)は、SPI公開後に人間レビューする最新の方針とも整合する必要な判断点。ゲートを有効化し、重複する「再開指示待ち」を取り除いた。対象版の登録可判断、0.9.x以降の時期、登録実行の委任は残る |

既存の必須依存辺は、削除したPERM-071の入力辺を除き保持した。QUALITY-002・003をQUALITY-001の完了待ちにはしていない。RBT-004をOR条件の例とする古い補足は、現在の行・辺のRBT-011待ちに合わせて訂正した。

## 凍結を維持した17件

| ID | 現在残る理由・確認不足 |
| --- | --- |
| RELEASE-080 | 今回直前のユーザー指示でCI調査を後回しにしたもの。単なる介入残りではない |
| DOC-026 | SPI登録の実行。0.9.x release後・登録可判断・外部PR実行の条件を保つ。ゲート復帰と登録開始を混同しない |
| DOC-027 | SPI登録結果から実在URL・badgeを接続する後続。登録前には完了できず、現在の作業へ割り込ませない |
| RELEASE-007 | 0.6.0の範囲・開始判断。RELEASE-078の現行条件照合を待つ。名称だけで不要とせず、release開始も代行しない |
| RELEASE-079 | 0.7.0の範囲・開始判断。0.6.0完了が前提。version固有の判断であり0.6ゲートと重複しない |
| RBT-035 | チューニング知見の再探索。現在の性能評価と目的が違い、完了・不要の根拠が不足。探索量も未確定 |
| RBT-026 | [View Matrix](../../Sources/RedBlackTreeCollections/Documentation/API-Matrix-View.md)にO(1)契約が残る。文書作業時に呼出し側前提を含め再判断する境界を維持 |
| RBT-004 | [監査](EXTERNAL_TYPE_EXTENSION_AUDIT.md)に残存比較宣言・Balanced群の未決事項がある。Result削除済みを全体完了としない。現在のIndex採否待ちを維持 |
| RBT-005 | 同監査で外部consumer 2件の互換維持が必要。移行済みの証拠を今回は得ていない。repository内で使わないことだけでは除去できない |
| RBT-008 | ユーザーが性能上の理由で「最後の最後」と明示した意図的な凍結。必要性不明や介入による凍結として扱わない。[凍結判断の正本](Frozen/LAZY_INITIALIZATION_FREEZE_DECISION.md)に理由と再開の境界を記録した |
| PERM-063 | benchmark名の互換処理は、[移行計画](PERMUTATION_MODULE_MIGRATION_PLAN.md)でユーザーが後段まで遅らせた仕事。現在の名称に合わせる必要はあるが、今回着手しない |
| PERM-064 | PERM-063の互換導入後にtitleを変える別受入境界。二段階は[性能CI手順](PERFORMANCE_CI_CHANGE_GUIDE.md)に必要であり重複ではない |
| PERM-043 | [現行評価内の記録](../PermutationModule/CurrentQualityAssessment.md)に比較水準の明示保留あり。旧COWの数値を現行実装へ転用できない。再検査時に対象と主張を更新して判断する |
| PERM-044 | 基準を決めるPERM-043と実測・評価は別の仕事。既存チャートを否定せず、現行対象版と判定水準の証拠不足を残す |
| PERM-051 | [仕様レビュー](PERMUTATION_TEST_AS_SPEC_REVIEW.md)でも借用寿命の再実行可能なcompiler fixtureが残件。既存の通常版public-surface fixtureやruntime testでは代替できない |
| PERM-060 | [Sequence実験](../PermutationModule/NextPermutationsSequenceExperiment.md)は一時Viewを集める問題を示す。現在非Sequenceだから将来判断を完了扱いにせず、明示的な延期を維持 |
| OPT-064 | 既存taskは一般提供方式の判断を前提とする。一方、[新Validation案](DOCUMENTATION_VALIDATION_PLAN_DRAFT.md)は現行の実験提供を含む公開文書の確認。対象が同じとは確定できず、計画レビュー前に統合・解除しない |

PERM-063・064には旧NextPermutationsSequence名、PERM-051には旧source pathなどが残る。仕事の必要性とは分け、実行を具体化するときに現行名・契約へ照合する。今回、将来のbenchmark表示名を独自に決定していない。

## 残る判断を絞る

今なお「要るか」が判断しにくい中心は、チューニング再探索、OptionalElementBufferの将来一般提供に対する理解試行である。外部consumer移行とIndex要件は事実確認が必要で、不要の判断では代用できない。これらを全部同時に再調査する義務にはせず、現在の目的に必要になった対象から具体化する。

公開後の人間レビューは新しいValidationドラフトとそのユーザーレビューtaskに接続済み。今回のゲート復帰で同計画全体の受け入れや試行開始を代行していない。

## 検証範囲

資料・ソース・保存された受入証拠の静的照合。製品test、性能測定、remote CI、外部consumerの実行はしていない。変更前原文の保存、ID重複、依存先の実在・循環、未変更行と依存辺の保持、採番表の無変更、ローカルリンクの実在を機械確認する。
