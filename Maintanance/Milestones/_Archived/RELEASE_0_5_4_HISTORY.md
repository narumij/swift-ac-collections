# 0.5.4への準備・判断・証拠の履歴

2026-10-17、ユーザーの統廃合依頼によりAstraが統合。以下は当時の記録で、現行の条件・権限・現在地ではない。旧「0.6.0」や「タグ未作成」等は記録時点の表現を保持する。現行の入口は[HEAD](../HEAD.md)と[運用規則](../README.md)。

原文はリンク調整と出典用アンカーの追加だけを行い、内容は省略しない。

- [RELEASE_0_6_0.md](#release-0-6-0)
- [RELEASE_0_6_0_SCOPE_RECONCILIATION.md](#release-0-6-0-scope-reconciliation)
- [RELEASE_0_6_0_PREPARATION.md](#release-0-6-0-preparation)
- [RELEASE_0_6_0_QUALITY_EVIDENCE_RETURN.md](#release-0-6-0-quality-evidence-return)
- [RELEASE_0_6_0_CANDIDATE_CHECK.md](#release-0-6-0-candidate-check)
- [GATE_0_5_4.md](#gate-0-5-4)
- [RELEASE_0_5_4.md](#release-0-5-4)

---

<a id="release-0-6-0"></a>

出典：`RELEASE_0_6_0.md`

<a id="release-0-6-0--release-060今回の準備時の旧予定名"></a>
# Release 0.6.0（今回の準備時の旧予定名）

> 2026-10-16ユーザー判断で今回のreleaseを0.5.4へ振替。[現在のゲート](RELEASE_0_5_4_HISTORY.md#release-0-5-4)を優先する。以下は準備・判断の経緯。将来の0.6.0範囲は未定。

人間用ゲート資料。AIの再開用要約は[0.6.0キャッシュ](../../Cache/Astra/RELEASE_0_6_0.md)に置く。

<a id="release-0-6-0--マイルストーンとしての管理-2026-10-16"></a>
## マイルストーンとしての管理 2026-10-16

RELEASE-007は重複する独立ゲートとしてEXCLUDEDとし、本書へ集約した。到達範囲と開始のユーザー判断は[リリース手順](../../User/RELEASE_PROCESS.md)の候補採用判断へ接続し、同じ判断を再度求めない。最終リリース判断は別段階として維持する。調査・前提充足は開始許可ではない。管理入口は[マイルストーン管理](../../MILESTONES.md)。


最終更新: 2026-10-10 / Codex

<a id="release-0-6-0--現在の状態"></a>
## 現在の状態

release検討開始条件待ち。これはactive release Registryではなく、0.6.0を開始できる状態とversion固有の
要件だけを保持する入口である。現時点ではrelease候補commit、製品上の到達範囲、branch方式、必須gate、
tag位置を確定しない。

`_ReleaseTask/`へ人間向け工程表をコピーする前の段階では、release、branch作成、commit、tag、push、公開を
許可しない。

<a id="release-0-6-0--release検討開始条件"></a>
## Release検討開始条件

全公開対象の利用者向けドキュメントが、公開可能な初版として揃っていることを、0.6.0のrelease検討を
始める条件とする。

対象にはNextPermutationModule、OptionalElementBufferModule、ElementBufferModule、RedBlackTreeCollectionsを含む。初版は公開契約と整合し、利用者が
主要な用途、基本操作、重要な制約を理解できる状態を指す。以後の加筆や改善余地がないことまでは要求しない。

これはrelease完了条件ではない。条件到達後、ユーザーが0.6.0へ含める製品上の到達範囲とrelease作業を
開始するかを、一つの判断として確定する。

<a id="release-0-6-0--開始判断までの依存"></a>
## 開始判断までの依存

RELEASE-078で現行提供区分・文書状態と旧開始条件を照合し、その結果を本書の判断材料に接続する。各対象の必要な文書作業が具体化した時点で、そのtaskと証拠を本書から参照する。ドラフト作成taskを初版完成と読み替えず、レビューと公開可能性の確認を残す。

OptionalArrayの1D所有型名は、後発の横断命名判断でunsuffixedの
`OptionalElementBuffer`に確定し、実装反映も完了した。旧`OPT-044`はその判断へ吸収し、
0.6.0の未解決依存にしない。次元名体系も同じ横断判断で現行維持に確定したため、旧`OPT-045`を
独立した未解決依存にしない。

<a id="release-0-6-0--release作業の起動"></a>
## Release作業の起動

開始条件に到達したら、次の順序で起動する。

1. 前versionからの差分と未完了のversion固有要件を確認し、0.6.0へ含める変更と後続へ残す変更を分ける。
2. ユーザーへ、0.6.0の製品上の到達範囲とrelease作業を開始するかを一問で確認する。
3. Yesの場合だけ、`../User/RELEASE_PROCESS.md`を`_ReleaseTask/`へコピーし、versionを実値へ置き換える。
4. 確定したbranch方式、必要な品質gate、0.6.0の文書作業と対象版の検証を人間向け工程表と通常Task Registryへ反映する。
5. release中の状態と証拠は人間向け工程表と各工程の正本へ記録し、完了または中止時にこの文書と通常Task Registryへ還元する。

2026-10-13、旧release checklist、release専用Task Registry方式、およびrehearsal templateは採用せず
Archivedへ移した。人間向け工程の正本は`../User/RELEASE_PROCESS.md`とする。

<a id="release-0-6-0--060の重点と品質確認"></a>
## 0.6.0の重点と品質確認

2026-10-16、ユーザーが0.6.0をドキュメント整備のマイルストーンと決定した。対象版の公開契約と一致する利用者向け初版を揃える。RELEASE-078で対象と残作業を照合し、本文作成・例の確認・レビュー・公開可能性の不足だけを具体化する。

各0.x.0で、前回からの変更点・既知の課題・影響範囲に応じて品質を確認・改善する。既存の評価証拠を使い、変化した前提と不足を再検証する。1.0全体の品質条件を0.6.0へ一括で前倒しせず、対象版に必要な試験・公開説明の整合・最終リリース判断は省略しない。

リリース工程表の整備・不足仕様充当・工程自体のV&V（RELEASE-072・075・076）、整形依頼手順書の完成、Pages公開方式の切替は[0.7.0](FUTURE_PLAN_HISTORY.md#release-0-7-0)へ配置する。これらの完成を0.6.0の開始・リリース条件にはしない。現行の人間主体の手順は利用でき、実際の候補を公開するための確認は引き続き必要。

旧0.6.0固有要件だったmain由来Pages deploy停止、release tag由来の文書生成・warning検査・検証済み文書のみの公開は、要求を削除せず0.7.0へ移した。現行の公開経路そのものは本整理では変更していない。

<a id="release-0-6-0--権限境界"></a>
## 権限境界

- branch作成、commit、tag作成は、それぞれ直前にユーザーの明示許可を得る。
- candidate branch push、GitHub merge、tag pushはユーザーが実行する。
- Codexは各報告後に対象commitまたはrefをremoteから確認してから後続へ進む。
- release pageやその他の公開操作を行う場合も、対象を示して別途判断する。

<a id="release-0-6-0--品質資料の保存に関するユーザー判断-2026-10-16"></a>
## 品質資料の保存に関するユーザー判断 2026-10-16

ユーザーが、これまでの`Maintanance/Quality/Current/`の一式を`Maintanance/Quality/0.6.0-1/`へ保存し、次回用に空の`Current/`を作るよう指示した。保存先は会話で`Old`、`0.5.4-1`を検討した後、ユーザーが`0.6.0-1`へ訂正し、実行を明示した。AIが独自に対象版や保存時期を決めたものではない。

この指示に従い、[今回までの品質資料](../../Quality/0.6.0-1)を保存し、`Quality/Current/`は`.gitkeep`だけを置いた空の作業先とした。関連する参照先も保存先へ更新した。共通の品質要求は`Quality/`直下に維持する。

これは資料の保存と次回作業場所の準備の判断であり、全資料が0.6.0で実測済みであること、品質合格、未解決課題の完了、次回試験やリリースの開始を決めたものではない。元資料の対象版・証拠・未確認事項は保持し、残作業の状態はTask Registryに従う。

<a id="release-0-6-0--リリース完了後の互換調査再開判断"></a>
## リリース完了後の互換調査再開判断

2026-10-16ユーザー指定。0.6.0のリリース完了を確認した後、`PERM-079`で`prepare/compatible/2`の統合手順再構築調査を再開するかユーザーが判断する。詳細は[AtCoder 2025互換計画](../../Current/AtCoder2025CompatibilityPlan.md)。

これはリリース後の判断点であり、0.6.0のリリースを止める条件ではない。リリース完了だけで調査・統合・mergeを自動開始しない。再開可の場合に調査の範囲・完了条件・担当を更新し、統合時期・送り先・merge許可は別途扱う。

<a id="release-0-6-0--文書初版ゲートの具体化2026-10-16"></a>
## 文書初版ゲートの具体化（2026-10-16）

DOC-035の全公開対象の文書初版確認を、本書の文書初版条件の必須入力とする。DOC-033→DOC-034で赤黒木本文を完成させ、RELEASE-078の照合結果とともにDOC-035へ渡す。登録は条件達成・release開始許可ではない。

2026-10-16追加のユーザー指示：DOC-034 → DOC-037（赤黒木本文のユーザー受入判断）→ DOC-035とする。DOC-037で受入可を明示した後だけDOC-035へ進む。差戻し・保留では進めず、判断taskの完了だけを許可とみなさない。DOC-035のRELEASE-078前提も維持する。

<a id="release-0-6-0--080への拡充移管と今回の固定範囲2026-10-16ユーザー決定"></a>
## 0.8.0への拡充移管と今回の固定範囲（2026-10-16ユーザー決定）

今回の0.6.0文書作業では、既存スニペットの構成・掲載数を固定し、追加・削除しない。既存例の照合・検証と誤りの訂正は扱うが、増減が必要なら無断で変更せず記録する。コードスニペット追加と文書全体の再検討は0.8.0へ配置した。既存の「必須コード例」「不足補完」はこの固定範囲で扱い、新しい例を作る要件にはしない。

<a id="release-0-6-0--開始条件の照合と初版確認2026-10-16--astra"></a>
## 開始条件の照合と初版確認（2026-10-16 / Astra）

[RELEASE-078の照合結果](RELEASE_0_5_4_HISTORY.md#release-0-6-0-scope-reconciliation)で現行4対象・提供条件・必要入力を整理した。[DOC-035の初版確認](../../Current/PUBLIC_DOCUMENTATION_INITIAL_EDITION_CHECK.md)では文書訂正、4対象＋共通入口のDocC生成、既存例の確認を実施。2026-10-16ユーザーのcommit承認により完了。確認範囲と未実施事項は同正本を参照し、本書に検証結果を重複転記しない。リリース候補・開始許可・1.0品質達成は未決定のまま。

<a id="release-0-6-0--開始承認と今回のタグ方針2026-10-16--ユーザー判断"></a>
## 開始承認と今回のタグ方針（2026-10-16 / ユーザー判断）

ユーザーが0.6.0のリリース準備開始を承認した。範囲は文書初版と既に実装済みの名称・公開入口・不具合修正。品質確認の材料は[RELEASE-081の受入・統合](RELEASE_0_5_4_HISTORY.md#release-0-6-0-preparation)を参照する。

ユーザーは「メインブランチでタグをうつ方針」と明示した。今回はmain上の最終コミットへ0.6.0タグを付ける。旧手順のリリース専用ブランチでの削除整理、mainへ戻さない運用、確認用PRをmergeせず閉じる終点は今回に適用しない。互換コード・管理文書・AGENTS.md等の削除をこの開始承認から実行しない。

候補の確認はGitHub上のPRへの新規コメント `/test release` で起動する。現行workflowは受付時のPR head SHAを固定するため、main反映後のコミットと検証対象の対応を確認してから最終タグへ進む。merge方式・最終対象SHAは未確定。コメント起動の成功だけで、異なるmainのSHAを検証済みとしない。

開始は承認済みだが、候補SHAの採用、最終リリース判断、branch作成・commit・tag・push等の個別操作は別。GitHubへの投稿・merge・pushはユーザー操作とする。今は候補PRとmain反映経路を具体化する段階。

<a id="release-0-6-0--候補確認と試験の順序2026-10-16ユーザー指定"></a>
## 候補確認と試験の順序（2026-10-16ユーザー指定）

今回はリハーサルとして、手元の候補確認を終えてからcommit・pushし、その版の通常CI、PRコメント `/test release` による追いCIへ進む。通常CI完了を手元確認の前提にして循環させない。[候補確認記録](RELEASE_0_5_4_HISTORY.md#release-0-6-0-candidate-check)へ接続。開始承認・候補確認・試験合格・最終リリース判断は区別する。

<a id="release-0-6-0--候補ci失敗後の引継ぎ2026-10-16"></a>
## 候補CI失敗後の引継ぎ（2026-10-16）

CP-015を通じ、ユーザーがClaudeへ「赤のままmergeし、その後チューニング余地を探す」と伝えた記録を受領。候補CI合格・merge済みとは扱わない。性能比較元の8件欠落とPermutation 3件の契約差はRELEASE-084正本へ集約し、追加実装の進行判断を待つ。性能の落ち穂調査はPERM-080としてリリース後の提案に分離した。

<a id="release-0-6-0--今回の後送判断の確定2026-10-16--ユーザー"></a>
## 今回の後送判断の確定（2026-10-16 / ユーザー）

ユーザーが「うん。このまま確定しよう」と承認。候補CI修正は0.6.0前には続けず、今回の候補CIの赤を引き受け、ユーザー操作でmainへmergeする方針とする。候補CI成功へ読み替えず、比較元8件欠落とPermutation 3件の契約差を既知の未解決として保持する。閾値・比較対象・workflowは変更しない。

RELEASE-084はWAITING_EXTERNALとして0.6.0リリース完了まで後送。完了後に現行baselineと修正の必要性・範囲を見直してから再開する。release完了だけで旧修正案を自動実施しない。今回のmerge方針と最終タグ・公開判断は分ける。

確認済み通常CIの対象はa5a39d12。手元HEAD 811b7a7aまでの差分は調査・管理記録だけで、製品・Tests・workflowに変更なし。本記録を含む未commit分はcommit・pushしてPRへ載せてからユーザーがmergeする。現在のremote PR head・追加CI結果は今回ネットワーク接続できず未再確認。merge後にmainの対象と検証版との差分を確認して最終release判断へ渡す。

<a id="release-0-6-0--マージ結果と記録の後送2026-10-16"></a>
## マージ結果と記録の後送（2026-10-16）

ユーザーとの訂正により、手元の記録を先にpushせず、確認済み候補のPR #198をユーザーがmergeした。GitHub APIでmerged=true、main=283c196a4d6025b6f29b246d349a2e5d4cd7aca4、候補a5a39d12とのファイル差分ゼロをAstraが確認。上記の「記録をpushしてからmerge」は旧手順であり、この決定で置き換える。未反映の調査・受入記録は保存後、別branchでmainへ戻す。タグ作成・公開はまだ行っていない。

<a id="release-0-6-0--文書開始条件の完了証拠引継ぎ2026-10-16圧縮"></a>
## 文書・開始条件の完了証拠引継ぎ（2026-10-16圧縮）

RELEASE-078の開始条件照合とDOC-035の全公開対象の文書初版確認は受入済み。完了nodeとその完了済み前提の辺を現行一覧・Studioから外し、[原Registry・依存](../../Archived/TASK_REGISTRY_COMPLETED_DOCUMENT_GATES_2026-10-16.md)へ保存した。[開始条件の照合](RELEASE_0_5_4_HISTORY.md#release-0-6-0-scope-reconciliation)、[初版確認](../../Current/PUBLIC_DOCUMENTATION_INITIAL_EDITION_CHECK.md)、[本文とユーザー受入](../../Current/RED_BLACK_TREE_DOCUMENT_COMPLETION.md)が証拠の入口。証拠を履歴化しても前提が未達へ戻るわけではない。候補CIの赤の引受判断、最終タグ・公開判断は別であり、文書完成からrelease完了とはしない。

---

<a id="release-0-6-0-scope-reconciliation"></a>

出典：`RELEASE_0_6_0_SCOPE_RECONCILIATION.md`

<a id="release-0-6-0-scope-reconciliation--060提供範囲と文書入力の照合"></a>
# 0.6.0提供範囲と文書入力の照合

2026-10-16 / Astra / RELEASE-078。ユーザーが先行実施を承認。基点はe76964c2の製品・manifest。既存のRBT-048時期記録差分は本照合の製品入力に影響しない。

<a id="release-0-6-0-scope-reconciliation--結果"></a>
## 結果

旧開始条件のPermutation / OptionalArray / BareArray / RedBlackTreeは、下表の現行4モジュールへ対応する。名称決定をやり直さず、DOC-035の点検範囲として渡す。リリースへ含める変更・開始許可・1.0品質達成は決定していない。

| 現行対象 | 公開入口と条件 | 文書入力・確認点 |
| --- | --- | --- |
| RedBlackTreeCollections | AcCollectionsから再公開。4コンテナと関連View | DOC-034の本文・型コメントと78例、DOC-037のユーザー受入を再利用。現行DocC・導線を確認 |
| NextPermutationModule | AcCollectionsから再公開。旧PermutationModuleは互換入口 | 現行DocC・NextPermutations/BorrowedNextPermutationsコメント。一時Viewの失効と借用、Sequenceではないこと |
| OptionalElementBufferModule | AcCollectionsからの再公開はENABLE_OPTIONAL_ELEMENT_BUFFER traitが必要。実験的、留保付き1.0対象 | 現行DocC・4次元型コメント。unset、要素寿命、非mutating更新、利用制約 |
| ElementBufferModule | AcCollectionsから再公開。Swift 6.2競技供用／6.4一般供用という方針 | 現行DocC・4次元型コメント。現パッケージはSwift 6.4必須。MutableRefアクセスはApple OS 27以降 |

根拠：Package.swift、Sources/AcCollections/AcCollections.swift、各モジュールの現行ソースとDocC、[品質要求](../../Quality/QUALITY_REQUIREMENTS.md#10に向けた開発対象)。manifestのmacOS最低宣言は15であり、個別APIの27条件や将来の1.0環境方針を混同しない。他platformの実行品質を宣言だけで確定しない。

<a id="release-0-6-0-scope-reconciliation--条件付き依存と判断の境界"></a>
## 条件付き依存と判断の境界

- DOC-035は本照合とDOC-037の明示受入を入力に実行可能。既存スニペットの構成・数は固定。
- 現行Pages workflowは赤黒木のみ生成。4モジュールのソース文書を確認する仕事と、0.7.0の公開方式切替は分ける。READMEでは未公開のURLを生成済みと案内しない。
- Quality/0.6.0-1は前回一周の保存資料であり、今回の対象版の合格証明ではない。対象版の差分に応じた品質確認はリリース段階に残る。
- RBT-048のnil→fatalError等のユーザー判断は0.7.0仮置き。今回決めず、現行契約で文書を点検する。
- 文書初版が揃った後の製品範囲とリリース開始は、既存のRELEASE_0_6_0 / RELEASE_PROCESSのユーザー判断へ渡す。工程整備・SPI・1.0全体評価を今回の前提へ追加しない。

<a id="release-0-6-0-scope-reconciliation--完了"></a>
## 完了

4対象・必要文書入力・条件付き依存・残るユーザー判断を整理した。新しい製品方針判断は発生していない。RELEASE-078の調査は完了し、DOC-035へ引き渡す。文書初版確認そのものは別途結果を残す。

---

<a id="release-0-6-0-preparation"></a>

出典：`RELEASE_0_6_0_PREPARATION.md`

<a id="release-0-6-0-preparation--060変更範囲案と品質確認入力"></a>
# 0.6.0変更範囲案と品質確認入力

2026-10-16 / Astra / RELEASE-081。ユーザーの継続指示とClaudeへの割当許可に基づく、リリース開始判断前の材料整理。候補採用・試験起動・release開始は行わない。

<a id="release-0-6-0-preparation--固定範囲と到達点"></a>
## 固定範囲と到達点

比較元はローカルtag 0.5.3（139ffef8）、比較先は8a0c8769。比較先は今回の調査基点であり、リリース候補としての採用ではない。並行作業の未コミット差分、特にRBT-048-death-probeやキャッシュ整備は対象外。

Astraが変更範囲案を整理し、Claudeが既存品質証拠の適用範囲と追加確認候補を返す。Astraが検収して、再利用可・差分確認が必要・判断待ちを区別した一つの材料にまとめたら調査完了。製品上の到達範囲と開始のユーザー判断はRELEASE_0_6_0へ返す。

<a id="release-0-6-0-preparation--変更範囲案未採用"></a>
## 変更範囲案（未採用）

- 公開文書：赤黒木4型の本文・コメント、4モジュールのDocC入口、README導線。DOC-034・035の結果を利用する。
- 導入条件：Package.swiftはSwift 6.2から6.4へ変更。現行の名称・公開入口はRELEASE-078の照合表を利用する。
- ElementBuffer系：BareArray/OptionalArrayからの名称・target移行、旧入口の整理、MutableRefアクセス、OptionalElementBufferのtrait opt-in。単なる文書改訂とは分けて変更履歴に示す。
- Permutation：NextPermutationModuleへの移行、旧PermutationModuleの互換再公開、一時Viewと借用iteratorの現行契約。旧版からの移行注意を確認する。
- 赤黒木：実装差分とTest as Spec補完を品質証拠へ照合する。DOC-035の文書検証を実装全体の品質保証に転用しない。
- CI・管理資料の変更は製品機能と区別する。リリース用整理は開始判断後の別工程で扱う。

根拠：0.5.3..8a0c8769のPackage.swift、公開入口、Sourcesの履歴。Sources / Tests / Package.swift / .githubの比較は147 files changed（8612 additions、9437 deletions）。移動・名称変更を含むため、この件数をリスクの大きさと同一視しない。個別変更の全リリースノートは未作成。

<a id="release-0-6-0-preparation--現在不足する材料"></a>
## 現在不足する材料

- CHANGELOGは0.5.3まで。上記を基に0.6.0の変更候補を作れるが、範囲採用前にリリース済み表記を追加しない。
- 8a0c8769に対する直近CIの全成功は未確認。以前の成功を代用しない。
- 候補コメントCIの正本には過去のperformance/report失敗記録がある。現行Registryとの対応と新しい成功証拠を照合する必要があり、旧FROZEN記載だけでtaskを復活・実行しない。
- 全体試験・trait組合せ・互換経路・差分の品質確認はClaudeの棚卸しを受けて必要範囲を確定する。1.0の全面評価は持ち込まない。

<a id="release-0-6-0-preparation--分担引渡し"></a>
## 分担・引渡し

Claudeの返却先はRELEASE_0_6_0_QUALITY_EVIDENCE_RETURN.md。本書と固定入力を渡した後は、返却まで変更しない。Astra側の追加整理は返却後の検収に合流させる。共有ビルド領域・製品・テストをこの依頼で書き換えず、並行中のユーザー直接依頼を妨げない。

<a id="release-0-6-0-preparation--astra受入統合2026-10-16"></a>
## Astra受入・統合（2026-10-16）

Claudeの[返却原文](RELEASE_0_5_4_HISTORY.md#release-0-6-0-quality-evidence-return)を保持し、読み取り調査として受け入れた。固定入力3件のhash、保存済みPR #196の受入記録、4cd0ebc2..8a0c8769のSources・Package.swift差分を独立照合した。コメント等を除くSwift実装差分は赤黒木4型の範囲erase、manifest差分は移動済みFixturesのexclude削除。今回テスト・CIは実行しておらず、GitHubの最新状態も取得していない。

<a id="release-0-6-0-preparation--返却への補正"></a>
### 返却への補正

- Swift 6.2の供用説明は未決ではない。現行ElementBufferModule.docc/ElementBufferModule.mdは、package導入はSwift 6.4、6.2での競技利用はbufferソース利用と明記済み。説明の再判断をユーザーへ戻さない。6.2での今回の対象ソースの実行証拠が未確認である点は別に残す。
- ElementBuffer座標アクセスの不足は旧Assessmentからそのまま引き継がない。Tests/ElementBufferModuleTests/BareArray_7_BorrowedReferenceTests.swiftには1〜4次元の全座標・非対称形状・対象要素だけの更新の検査がある。Archived/Reviews/ELEMENTBUFFER_TEST_AS_SPEC_REVIEW.mdには追加と受入記録がある。全座標APIの完全性を今回保証するものではないが、旧「未検証」4行を新たな必須課題へ転用しない。
- ASan＋Death Testは「成立した証拠がない」ではない。[調査正本](../../Current/ASAN_DEATH_TEST_INVESTIGATION.md)にはmacOS Swift 6.4の最小構成3件成功とASan検出の証拠がある。製品全体・Linuxでの成立は未確認で、今回の0.6.0必須条件へ自動昇格させない。
- 既定Linux CIは差分確認の提案経路であり「唯一の手段」ではない。保存された最後の全体CI証拠と、現在のGitHubの最新成功を区別する。

<a id="release-0-6-0-preparation--統合した開始判断材料"></a>
### 統合した開始判断材料

| 区分 | 適用範囲・次に確認すること |
| --- | --- |
| 再利用 | PR #196 head 4cd0ebc2の保存記録は、その版・既定構成の証拠。以後実装不変の3モジュールに利用可能。DOC-035の文書・例検証も、その対象版と範囲で利用する。 |
| 差分確認案 | 採用する候補SHAで既定Linux CIを実行し、範囲erase修正後のdebug/release/ASanと文書を確認する。候補コメントCIのperformance/reportも、新しい実行結果で確認する。過去の未確認から不合格とは断定しない。 |
| 構成別確認案 | 互換構成のbuild/test、Optional trait有効のfacade経路を確認対象案とする。通常CIの成功だけでこれらを通過扱いにしない。Linux death testは保存証拠の不足として残し、必要範囲は開始時の試験計画で確定する。 |
| 留保 | 候補SHA・リリース開始・試験範囲の承認は別。RBT-048、凍結中の並行初期化、後続マイルストーンの全面品質評価は持ち込まない。 |

変更範囲案と既存証拠の適用範囲の整理は完了。RELEASE-081はユーザーのcommit承認によりDONE。リリース合格・開始承認は意味しない。

---

<a id="release-0-6-0-quality-evidence-return"></a>

出典：`RELEASE_0_6_0_QUALITY_EVIDENCE_RETURN.md`

<a id="release-0-6-0-quality-evidence-return--060品質証拠の適用範囲--claude返却欄"></a>
# 0.6.0品質証拠の適用範囲 — Claude返却欄

RELEASE-081 / 返却済み。依頼本文はCLAUDE_TASK.mdのRELEASE-081節。

2026-10-16夜 / Claude（姫）。比較は`0.5.3`（`139ffef8`）..`8a0c8769`をGitから読んだ。作業ツリーの並行変更は混ぜていない。固定入力3件のSHA-256は依頼記載と一致した（`853ad5c8…`・`cb1046aa…`・`0d6fb9e5…`）。テスト実行、`.build`操作、製品・Tests・CI・Registryの変更、commitはしていない。

<a id="release-0-6-0-quality-evidence-return--要点事実"></a>
## 要点（事実）

1. **全体を通したCI証拠はPR #196 head `4cd0ebc2`（2026-10-15）が最後。**
   - 記録はAstraのPermutation移行受入（`Archived/PermutationMigration_2026-10-16/PERMUTATION_MODULE_MIGRATION_ACCEPTANCE.md`）。
   - Linux（ubuntu-24.04）で、debug・release・address-sanitizer・performance・documentationと対象別DocC 6件の、全11 jobがsuccess。
   - `ci.yml`は既定traitで、death test・Optional trait・互換構成のいずれも含まない。Linuxでは`DEATH_TEST`は`ENABLE_DEATH_TESTS` traitがないと無効（`Package.swift`）。
2. **`4cd0ebc2`..`8a0c8769`の製品コード差分（コメント・文書を除く）は2件だけ。**
   - a. `31aa2f07`：赤黒木4型の範囲`erase(_:where:)`で、predicateのエラーを`fatalError`にせず呼出元へ伝える修正。範囲の検証失敗だけが停止する。
   - b. `35a27b30`：`Package.swift`から`exclude: ["Fixtures.md"]`を削除。`Fixtures.md`は`Maintanance/Testing/`へ移動済みで、`8a0c8769`のTests配下にはない。
   - ほかは、文書コメント、DocC、test追加（RBT-043〜046、RBT-047の調査test）、`.github`（`2d32f71c`の候補コメントCI追加）。
3. **ElementBuffer・OptionalElementBuffer・NextPermutationは、`4cd0ebc2`以後に製品コードが変わっていない**（コメントとDocCだけ）。PR #196のCIは、3moduleの現行コードをLinuxの既定構成で通したと言える。

<a id="release-0-6-0-quality-evidence-return--module別"></a>
## module別

| 対象差分（0.5.3..8a0c8769） | 証拠と版 | 再利用範囲 | 追加確認案 | 残る判断 |
| --- | --- | --- | --- | --- |
| **RedBlackTreeCollections**：<br>実装は`31aa2f07`の1件だけ（4型×範囲erase）。<br>ほかは型コメント・文書（DOC-034）とtest追加。 | ①36f821a4（10-15、macOS、Swift 6.4）：Debug・Release全体、通常death test、ASan本体（DeathTests除外）、DocC。<br>②`31aa2f07`後、Astraがローカル実行（macOS）：Debug XCTest 944＋Swift Testing 133、Release 747＋120、修正前に8件失敗→修正後に成功。<br>③DOC-034/035：78例compile/run、Release DocC（f6e181b2・8a0c8769）。<br>④PR #196 CI（`31aa2f07`より前）。 | ①④は`31aa2f07`の前なので、範囲eraseの新しい挙動は保証しない。<br>②はmacOSのDebug・Releaseで、修正と既存testを保証。<br>Linux・ASanでの`31aa2f07`は未確認。 | ・`8a0c8769`の既定Linux CI（debug/release/ASan）を1回。<br>・互換構成のbuild（`31aa2f07`の変更は互換では条件付きで除外される）。 | ASan＋death testの併用は検証経路が未成立（RBT-033の調査結果）。0.6.0の必須にするかはユーザー判断。 |
| **NextPermutationModule**（旧PermutationModuleは互換入口）：<br>`1f87e37a`でmodule移行。実装はgeneric名`Value`→`Element`とtypealias整理のみ（Astra照合）。 | ①PERM-076受入（macOS）：通常61・death 17、compiler診断fixture、互換構成で4正常target build、新旧module同時import、両moduleのDocC。<br>②PR #196 CI（11 job success）。<br>③DOC-035：Release DocC、例4出力一致。 | 製品コードは`4cd0ebc2`以後変わっていないので、①②をそのまま再利用できる。 | なし（`8a0c8769`のCI 1回で、他moduleの確認と兼ねればよい）。 | candidate CIの経路は未実行（PERM-076記録）。 |
| **ElementBufferModule**（BareArrayから改名）：<br>旧View面の削除、MutableRef契約、`reference(at:)`をSwift 6.4以降に限定（`1a096818`）。 | ①CurrentQualityAssessment：BareArray名の時点でDebug・Release・death test・ASan・compiler fixture、外部consumer（`693b1bab`）。改名後の記録は「移行後に対象7件、compile-pass／fail」。<br>②PR #196 CI。<br>③DOC-035：Release DocC、値アクセス・借用更新の例を実行。 | 改名・`1a096818`後の製品コードは②③で通っている。<br>①の多くは旧名・旧面の記録。 | ・**Swift 6.2でのbuild**。供用区分では「Swift 6.2は1.0競技供用」だが、manifestは6.4必須（`swift-tools-version: 6.4`）。`#if swift(>=6.4)`分岐の6.2側を通した証拠は見つからなかった。<br>・座標access APIの直接仕様test不足（Assessmentの「未検証」4行）は、0.6.0の範囲かどうか判断が要る。 | 6.2供用の扱い：manifest 6.4必須のまま0.6.0を出すなら、6.2はこのpackageでは使えない。どう書くかはユーザーとAstraの判断。 |
| **OptionalElementBufferModule**（OptionalArrayから改名）：<br>trait opt-in（`314f45e0`）、文書整備。 | ①CurrentQualityAssessment：Debug・Release・ASanで通常35／death 26、DocC、外部consumer（`215be94b`）。<br>②PR #196 CI（既定構成）。<br>③DOC-035：trait有効の`AcCollections` build、例の実行。 | 製品コードは`4cd0ebc2`以後変わっていない。<br>ただしCIは既定構成なので、traitを有効にした再公開経路はCIで通っていない。③はmacOSのローカル。 | ・`--traits ENABLE_OPTIONAL_ELEMENT_BUFFER`でのbuildとfacade test（Linuxで1回あればよい）。 | 実験提供・留保付きの区分はそのまま。 |

<a id="release-0-6-0-quality-evidence-return--ciの保存証拠依頼3"></a>
## CIの保存証拠（依頼3）

- 直近の候補SHA（`8a0c8769`）のCI成功は**未確認**。保存された証拠がない。
- 候補コメントCI（`2d32f71c`で追加）の過去runは、performanceとreportが失敗（run 38765855176、`RELEASE_CANDIDATE_COMMENT_CI.md`）。ユーザーが解決済みと確認し、RELEASE-080はEXCLUDEDになった。ただし、新しい成功runの保存証拠は見つからなかった。**未確認**とする。

<a id="release-0-6-0-quality-evidence-return--追加確認案提案最小"></a>
## 追加確認案（提案、最小）

1. `8a0c8769`（または採用する候補SHA）で既定CIを1回通す（debug・release・ASan・documentation）。`31aa2f07`をLinuxで通す唯一の手段で、他3moduleの再確認も兼ねる。
2. 互換構成（`-Xswiftc -DCOMPATIBLE_ATCODER_2025`）でbuildとtestを1回。参考までに、姫がRBT-047（`f6e181b2`＋同じ調査test、ソースは`8a0c8769`と文書コメント以外同一）で互換構成のbuildに成功している。ただし実行したのは調査test 3件だけで、全体suiteではない。
3. `ENABLE_OPTIONAL_ELEMENT_BUFFER` trait付きでbuildとfacade test。
4. Linuxで`ENABLE_DEATH_TESTS` trait付きのdeath test。`31aa2f07`でdeath testが4型×60行増えたが、Linuxで走った記録はない。必須にするかは判断事項（下記）。

<a id="release-0-6-0-quality-evidence-return--昇格させないもの依頼4"></a>
## 昇格させないもの（依頼4）

- RBT-048（失敗時CoWの修正方針、ユーザー預かり）、凍結中の並行初期化、0.7/0.8/1.0の課題は、ここでは必須条件にしていない。
- 対象版を止める根拠になる事実は見つからなかった。ElementBufferのSwift 6.2供用の書き方だけは、release前に表記を決める必要があると考える（提案）。

<a id="release-0-6-0-quality-evidence-return--未確認限界"></a>
## 未確認・限界

- performanceの結果（PR #196ではsuccess）を、性能水準の合格としては扱っていない。
- Quality/0.6.0-1は前回一周の資料で、対象版の合格証明ではない（RELEASE-078の記載どおり）。
- 証拠は依頼の入口から辿れた範囲だけ。個々のtest追加の受入記録（RBT-043〜046）までは、件数を照合していない。
- ASan＋death testの併用は、macOSでもLinuxでも成立した証拠がない。

作業終了。範囲を解放する。

---

<a id="release-0-6-0-candidate-check"></a>

出典：`RELEASE_0_6_0_CANDIDATE_CHECK.md`

<a id="release-0-6-0-candidate-check--060-候補確認リハーサル"></a>
# 0.6.0 候補確認（リハーサル）

2026-10-16 / Astra / RELEASE-082。ユーザーが候補確認の実施と、確認後にpush・通常CI・コメントによる追いCIの順序を指定。最終公開の承認ではない。

<a id="release-0-6-0-candidate-check--手元確認の結果"></a>
## 手元確認の結果

- 比較元0.5.3、調査済み製品版8a0c8769、今回の作業基点4dc4d4ab0c89c8d4b3317af8b11dfdf0b599fe51。
- GitHub上のdevelop/misc/68とPR #198（main向け）のheadが4dc4d4abと一致。APIで読み取り確認した。
- 8a0c8769..4dc4d4abのSources・Tests・Package.swift・.githubに差分なし。RELEASE-081の適用範囲整理を再利用する。
- CHANGELOGへ0.6.0 Unreleasedを追加。公開日・リリース済みとは記載しない。公開入口・Swift条件・破壊的変更・修正を記載した。
- 後続の拡充、RBT-048修正判断、凍結作業は今回の製品変更へ混ぜない。Studioの未受入変更は管理側の記録として区別する。
- 元の全試験成功を今回の版の成功に転用しない。今回手元で試験は再実行していない。

<a id="release-0-6-0-candidate-check--次へ渡すもの"></a>
## 次へ渡すもの

手元の範囲・変更履歴・証拠の適用範囲の確認は完了。コミットとpush後の版をCI対象に固定する。候補の合格・最終タグ対象の確定は後段。

1. 今回の変更をユーザー承認でコミット。
2. ユーザーがpush。
3. そのSHAの通常CI結果を確認。
4. ユーザーがPR #198に `/test release` を新規コメントし、固定されたSHAと追いCI結果を確認。
5. mainへの反映版と検証版の対応、最終判断、タグへ進む。

現在走行中の通常CI run 38904834312は4dc4d4ab対象。確認時点で文書7job成功、debug・release・ASan・performanceは実行中。今回追加したCHANGELOGの版の成功証拠とはしない。CI待ちは本フェーズの完了条件から分離した（ユーザー指定）。

候補コメントCIだけでASan・Optional trait・互換構成の検証を代替しない。構成別証拠の扱いはRELEASE_0_6_0_PREPARATION.mdの受入節へ戻れる。

ユーザーが自身の変更を含めたcommitを承認。RELEASE-082はDONE。pushと対象SHAの通常CI・追いCIは次工程であり未完了。

---

<a id="gate-0-5-4"></a>

出典：`GATE_0_5_4.md`

<a id="gate-0-5-4--054-へのゲート旧060として準備した分"></a>
# 0.5.4 へのゲート（旧「0.6.0」として準備した分）

<!-- 2026-10-17 姫（CP-20261017-002）：MILESTONES.mdのゲート要素を移した。原文は逐語、リンクだけ新しい場所に合わせた。文中の「0.6.0」は、振り替え前の名前（今回の0.5.4）を指す場合がある。 -->

2026-10-16に「0.6.0」として準備した範囲は、0.5.4へ振り替えてmainへmerge済み（[0.5.4の記録](RELEASE_0_5_4_HISTORY.md#release-0-5-4)）。ゲートとしては過去の記録なので`Archived/`に置く。

<a id="gate-0-5-4--通る条件"></a>
## 通る条件

- [x] [10_RBT_DOCUMENTS](../0.5.3/10_RBT_DOCUMENTS.md) — RedBlackTree文書の本文作成完了（到達済み）

<a id="gate-0-5-4--原文milestonesmdから移した"></a>
## 原文（MILESTONES.mdから移した）

<a id="gate-0-5-4--版ごとの重点2026-10-16ユーザー決定"></a>
### 版ごとの重点（2026-10-16、ユーザー決定）

| 0.6.0 | 公開できるドキュメント初版を揃える | RELEASE-078で着手時点の文書・提供区分・品質課題と証拠を照合。旧棚卸しの完了待ちは置かない。赤黒木の本文完成も必要な文書入力へ接続する |

<a id="gate-0-5-4--文書ゲートの作業接続2026-10-16"></a>
### 文書ゲートの作業接続（2026-10-16）

赤黒木の到達点は準備ではなく本文作成完了へ訂正。DOC-033→DOC-034を接続し、RELEASE-078とDOC-034を入力とするDOC-035で全公開対象の初版を確認する。Validation計画レビューはDOC-036として既存の0.7.0前ゲートへ接続。いずれも未実行で、既存ゲートの達成を認定しない。

2026-10-16追加のユーザー指示：DOC-034 → DOC-037（赤黒木本文のユーザー受入判断）→ DOC-035とする。DOC-037で受入可を明示した後だけDOC-035へ進む。差戻し・保留では進めず、判断taskの完了だけを許可とみなさない。DOC-035のRELEASE-078前提も維持する。

---

<a id="release-0-5-4"></a>

出典：`RELEASE_0_5_4.md`

<a id="release-0-5-4--release-054--今回の区切り直し"></a>
# Release 0.5.4 — 今回の区切り直し

2026-10-16 / ユーザー決定、記録Astra。

<a id="release-0-5-4--現在位置"></a>
## 現在位置

今回のリリースは0.5.4とする。mainへのマージ済み、タグ未作成・未公開。0.5.4完了後に立て直し協議へ進む。

ユーザーは「じゃ、0.5.4にしちゃう？」に続き「それはかまわない。リセットだ」と承認。従来0.6.0として準備した今回の範囲を0.5.4へ振り替える。機能・契約・必要Swift版は変更せず、CHANGELOGのsource-breaking記述も保持する。将来の0.6.0の到達範囲は未定で、立て直し完了を0.6.0へ自動割当しない。

<a id="release-0-5-4--判断と証拠"></a>
## 判断と証拠

- 通常CI全11件成功の候補a5a39d12をPR #198でmainへmerge済み。main 283c196aとのファイル差分ゼロを確認済み。
- 候補CIの赤（比較元0.5.3の新規測定8件欠落、Permutationの契約差）を引き受け、修正は今回のrelease後へ送る。CI成功への読み替えはしない。
- タグは未作成。現在のmainのCHANGELOGはまだ旧予定名0.6.0で、今回の修正は作業branch上。公開前に版表記の変更をmainへ反映し、最終対象SHAと候補との差分を確認する。commit・push・merge・タグは各操作の委任に従う。
- 0.5.4タグをremoteへ反映すると、それを含む後続の候補CIで比較元が更新される見込み。同じ版の自己比較は性能回帰の検証証拠にしない。通常のx.y.zタグ自体はcandidate.ymlの起動条件ではない。

準備・試験・受入の過去記録は[旧0.6.0準備記録](RELEASE_0_5_4_HISTORY.md#release-0-6-0)を参照。保存済みQuality/0.6.0-1などの名称や測定対象は変更しない。

<a id="release-0-5-4--後続への境界"></a>
## 後続への境界

今回のrelease完了待ちだったPERM-079（互換調査の再開判断）、PERM-080（性能改善提案）、RELEASE-084（CI修正）、RELEASE-085（立て直し協議）は0.5.4完了を待つ。完了だけで実行を自動開始しない。RELEASE-084は立て直しプランRELEASE-086も必要。

人間用現在位置は本書とMILESTONES.md、AI用はCache/Astra/RELEASE_0_5_4.md。まだrelease完了ゲートを越えていない。
