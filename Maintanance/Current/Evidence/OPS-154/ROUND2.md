# D-20261019-09 — H20補正2件の独立再照合

## 結論

ROUND1の2件は、H20の限定契約に沿う補正を確認した。専用test-task-view-model-maps.cjsは終了0/PASS。この2件に新規指摘なし。受入判断は調整担当へ返す。

## 固定版

2026-10-19T03:59:54Z開始。以下SHA256は試験後も一致。

| ファイル | SHA256 |
| --- | --- |
| index.template.html | 440f70b4aaaf423b0bd17da934650f2a4637675248192cbbaa4f0ead8712144a |
| test-task-view-model-maps.cjs | 5a76bf7af30927c81788e5a573ef7b663be4fd2ba90c5d325f86e1e35cb5e191 |

## 入力→VM：大域依存の補正

期待は同じ明示入力に対して大域docを変更しても同じVMとなること。graphViewModelがsourceを受け、versionView/版一覧・isMilestoneLink/linkLabelへ渡す経路を確認。ページgraph()もsource:docを明示する。専用fixtureは固定data/source等に対し大域docだけをHEAD=9.9.9・milestones=[]へ変更し、全体/@head/先頭版の3通りでJSON完全一致を確認しPASS。前回の実装側不一致はこの明示source入力の範囲で補正確認済み。sourceを省略した非契約入力まで純粋性を保証するものではない。

## 固定VM→View/intent：文書と帯の補正

期待は独立/カード一覧が渡された文書情報と帯装飾を再判定せず描くこと。drawIndependentはdocuments、drawCardListはpathsを読み、双方bandView(c.band)でtext/bg/fgをそのまま描く。taskDocumentPaths/cardWithDocuments/stateStyle等をrendererから再呼出しない経路をソースで確認。

専用fixtureはnodeに道筋がなくてもdocuments=trueならリンクあり、falseならなし、指定帯の文字・背景・前景色がDOMへ反映されることを確認。選択・文書リンクはintent、カードの複数pathsも選択intentとして返る。専用試験PASS。前回の実装側不一致はこの固定VM境界で補正確認済み。

## 限界・返却

既存全試験・baselineの広い再照合は繰り返していない。互換baselineと今回の要求fixtureの意味は別。版変更で未確定入力が消える既知件は段階3/4の残件として維持し、解決扱いにしない。実画面・実フォント・狭幅・実サーバー・編集保存全体は未確認。コード/正本修正、sync、commit、HTTP/画面操作なし。本人return・presence/continuity endedを記録し占有終了。
