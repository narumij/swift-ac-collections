# D-20261019-08 — 地図VM段階0/1独立評価

## 結論

専用契約試験と保存済みa/bキャプチャのbaseline照合はPASS。ただし入力→VMとVM→Viewの境界に2件を確認した。受入・修正・仕様決定は調整担当へ返す。

## 固定版

開始読取2026-10-19T03:52:47Z。以下SHA256は返却前再照合でも一致。未commit作業版として評価。

| 対象 | SHA256 |
| --- | --- |
| index.template.html | 792180ed47c3ebb200b12444251a2bb919c6cadcbf9141d46ef999c24be12d63 |
| test-task-view-model-maps.cjs | 59d35b3d2019d1df6f2fa0d639fb8d68616fef4b0fa4e7bcc25259bc1c43768c |
| task-view-model-maps.baseline.json | 1069fa61f834add54c5bd3b7eb999c68314b3cd8bcab89f4d931d93134c2294e |

根拠はTASK_VIEW_MODEL_MIGRATION.md H17と段階1の純粋VM・View忠実性。段階3/4の未実装を完成要件として誤適用しない。

## 指摘1：依存図VMは明示入力だけで決まらない

- **期待・根拠**：H17の入力明示化、graphViewModel({data, version, selected, measure, hasDocuments})を純粋導出とする返却。Model→VMの意味検証を入力固定で行えること。
- **実態**：graphViewModelから呼ぶversionViewは大域doc.milestoneHead、doc.milestonesとversionFolders()を読む。線のisMilestoneLink/linkLabelも大域docに依存する。固定したdata/version='@head'/selected/measure/hasDocumentsをそのまま使い、大域docだけを別のmilestoneHead・空milestonesへ差し替えるとVMのJSONが変わった。専用試験の抽出環境でメモリ内の追加照合、ファイル変更なし。
- **区分**：**実装側：段階1の純粋VM契約との不一致**。現在ページのdocとdataが同時に一致している通常経路で表示回帰が起きたとは主張しない。既存helperをそのまま呼んだことで大域依存が新VM内に残っている。単一revision配布を予定する段階4とは別に、現在の「純粋」という保証が不足。
- **試験の限界**：同じ引数で2回呼ぶassertは、その間に大域docを変えず通るため入力閉包を検証していない。

## 指摘2：独立タスクViewがVMの文書有無を無視して再判定する

- **期待・根拠**：H17はVM→SVG/DOMの固定入力試験、段階1は文字/title/aria等をVMへ、Viewは描くだけとする。独立VMはdocumentsフラグを持つ。
- **実態**：independentViewModelは注入hasDocumentsでdocumentsを決めるが、independent()はc.documentsを使わずcardWithDocuments(b,c.node)を呼ぶ。そのhelperはtaskDocumentPaths(t)を再実行しリンク有無を決める。したがってhasDocumentsがfalseを返す固定VMでも、node.detailに正本があればView側ではリンクが作られる。ソースのデータフローで確認。加えてstateBandがView側でstateStyleを呼び色を導出するため、色まで移したとのソースassertは間接呼出を検出していない。
- **区分**：**実装側：VM→View忠実性の未完**。本番の同じ判定関数を使う経路では同値になり得るため、通常表示の回帰と混同しない。独立/カード一覧の固定VMを丸ごとViewへ渡す試験はなく、既存専用試験の固定VM→View部分は汎用drawSvgSpecに限定される。どこまでViewの装飾を許すかの仕様変更は評価役では決めない。

## 確認できたこと

専用test-task-view-model-maps.cjsはPASS。追加の大域依存最小照合のため同じ抽出コードを再使用し契約assertも再通過。入力の非変更、選択強調・共有、辺の経路と意図、文書リンク条件、折返し、独立/恒久/カードの列挙ケースはその入力範囲で成立。drawSvgSpecの固定VM順序・属性・click/Enter意図もPASS。全既存試験は再実行していない。

`task-view-model-baseline.cjs check`を、既存隔離証拠 `/var/folders/x9/2p70phpx3_xdvwx9s6gp35rm0000gn/T/tmp.I2dIB4mGYk/new-a.json` と `new-b.json` に対して実行しPASS（a7段/b8段）。新たなブラウザ取得ではない。保存済みキャプチャとbaselineの一致であり、現在コードで再取得した証拠や要求上の正しさとは区別する。baselineは固定measure・UTC/ja-JP・匿名fixture条件の互換証拠。

## 既知境界・未確認

版変更時の未確定入力消失は返却済みの既存不具合。入力保持の必須契約の残件だが、新規発見・今回の抽出回帰には数えない。段階3の編集欄/段階4の配線で対処予定という範囲を維持し、今回解決済みとはしない。近傍・保護・編集保存の全面検査、単一revisionの全体配線、実フォント・狭幅・実画面は未検査。

実サーバー/HTTP/ユーザー画面操作、コード/正本修正、sync、commitなし。本人返却とpresence/continuity endedを記録し本書の占有終了。
