# 最近の作業レーン実装（OPS-119）

2026-10-18 Astra。親OPS-048、入力OPS-118の案とAstra補足。ユーザーは最近活動の表示を選び、実装継続を承認した。

## 姫への正式依頼

通知を受けたらCLAUDE_TASKと本書を確認し、本件に限り追加開始確認なしで着手してよい。設計案 `STUDIO_WORK_LANE_PROPOSAL.md` の補修と受入を基に、次の境界で最小実装する。

### 成果と境界

- 現在の事前承認レーンの位置に、最近の作業をtask単位の小さいカードで示す。表示は「直近200件の活動＋未完の承認」、全taskの現在地ではないことを明示。
- 同一taskの実務イベントから最近の工程・担当・時刻・短い説明を出す。Registryの正式状態を別表示。開始点不明は不明とし、requestが見えないだけで過去のworkを検討中と断定しない。新たな検討開始には既存work＋説明を使える。
- 最新commitは「記録コミット済み」、completeは「作業区切り」。RegistryのDONEへ変換しない。RBT-026のWAITING_USER＋commitを回帰例にする。recheckで別の回を作らない。complete後のawaiting-commitを扱う。
- 承認は同じtaskのpending/approved/claimedをtask単位で表示。時刻で回へ結び付けない。未完承認だけのtaskも落とさず「活動情報なし」。同一taskの並行依頼は識別しないと明示。consumed/cancelledは既存履歴で保持。
- 個別承認・取消・表示中の全部承認は既存コントローラと対象集合の契約を保持。承認詳細を折り畳みにまとめてもよいが、未承認件数と操作への入口を見失わせず、二重の承認操作を増やさない。作業カードは承認を代行しない。
- 疎通は既存PING/WAKE/ACKの専用表記を根拠に段階判定から除外する。一般の説明でPINGに言及しただけの実務を除外しない。具体的な判別をReturnに書き、陽性・陰性fixtureで検証する。原イベント帯には残す。
- 既存activity帯は履歴として保持。レーンの再描画はactivity/approval取得時のみの局所更新。未保存編集・入力・選択・スクロール・承認中のフォーカスを壊さない。取得失敗時は最後の正常表示＋不調表示を維持。既存の非表示停止・timeoutを維持。
- サーバー/API/DB/schemaは変更しない。作業レーンは導出表示だけ。自動起動・自動着手・新たな承認権限は作らない。

### 占有と検証

姫の編集範囲：`Maintanance/RegistryApp/index.template.html`、新規`Maintanance/RegistryApp/test-work-lane.cjs`、`Maintanance/RegistryApp/README.md`のレーン説明、下記Returnのみ。既存smokeの環境補修が必須なら自分で広げず報告する。Registry・他正本・サーバー・activity.py・approvals.py・AGENTS編集なし。commit・サーバー再起動・ユーザー画面操作なし。

最初にReturnへ短い内訳を書き、範囲内なら続行。純粋関数の状態遷移・古い起点・承認のみ・同task複数承認・ACK等除外・RBT-026例、DOMの局所更新と入力/フォーカス保持、既存activity/approval試験、sync/verifyを確認する。sync生成物はキャッシュへ。実画面未確認なら明記。

着手/検証/返却の実イベントをOPS-119・owner姫でactivityへ記録。返却は変更ファイル、具体的規則、試験結果、限界、参照キャッシュ一行を添える。返却後は本件作業を止めてAstra受入待ち。

## 姫 Return

2026-10-18 姫・Opus 5.5。開始HEAD `16ec8d0d64f15330355bb342c0bb0bfbccf89a62`。commitなし、サーバー操作・再起動なし、実画面は未確認。

作業内訳（着手時に記入）：(1) 既存のactivity・承認の作りを読む。(2) 純粋関数と疎通判別を書いて試験する。(3) 承認レーンの位置に描画し、取得時だけ局所更新する。(4) READMEに説明を足し、既存試験・sync・verifyを流す。

### 変更ファイル

- `RegistryApp/index.template.html`（+74/−4）
  - 承認レーンの直前に「最近の作業」セクションを置いた。既存の「コミット事前承認」はそのまま下に残し、承認・取消・全部承認の操作はそこだけ。
  - 純粋関数`workLaneItems`、疎通判別`isProbeEvent`、描画`createWorkLaneView`、状態保持`createWorkLane`、遅延生成`workLaneInstance`を足した。
  - activityの行に、元の項目（`raw`：taskId・owner・reason・時刻）を足した（既存の帯は使わない追加項目）。
  - activity・承認の各取得のviewを薄く包み、成功・失敗のときにレーンへも渡す。
- 新規 `RegistryApp/test-work-lane.cjs`
- `RegistryApp/README.md`：「最近の作業レーン（OPS-119）」の節を、作業イベント更新ルールの直後に足した。

### 具体的な規則

- 工程：そのtaskの最新の実務イベントで決める。request＝依頼済み、work＝作業中（reasonが「相談待ち：」で始まれば相談待ち）、verification＝確認中、return＝返却・受入待ち、recheck＝再確認中、acceptance＝受入済み、complete＝作業区切り、awaiting-commit＝コミット待ち、commit＝記録コミット済み。RegistryのDONEへは変換しない。Registryの状態は別の行に出す（生成時の正本seedから）。
- 開始：範囲内の最新のrequestの時刻。なければ「開始は記録範囲外または未記録」。requestが見えないことから検討中とは断定しない。recheckで別のカードを作らない。completeの後のawaiting-commitはコミット待ち。
- 承認：同じtaskのpending・approved・claimedの数をtask単位で出す。時刻で依頼へ結び付けない。承認だけのtaskは「活動情報なし」で出す。consumed・cancelledは数えず、既存の履歴に残る。同じtaskの並行依頼は区別しないことを、見出しの説明に明記した。
- 疎通の判別（`isProbeEvent`）：次のどちらかなら、工程に数えない。帯には残る。
  - reasonが`ACK `（ACK＋空白）で始まる。
  - reasonに`(PING|WAKE)-数字8桁-英数字`のIDを含む。前後が英数字やハイフンにつながる場合は除く。
  - 陰性（数える）：「PINGの仕組みを説明」「WAKE-UP手順」「XPING-20261018-A」「ACKNOWLEDGE」など。
- 更新：既存のactivity取得・承認取得が成功・失敗したときだけ描き直す。どちらかが不調なら、最後の表示を残して「〜の取得不調・最終情報を保持」と出す。フォーカスがレーン内のカードにある間は、カードを並べ替えない（文字だけ更新）。横スクロール位置は保持する。

### 試験結果

- `test-work-lane.cjs` PASS。確かめた内容：
  - 9種のイベントの状態遷移。recheckでカードが1枚のまま。complete→awaiting-commit。相談待ち。
  - 起点不明。承認のみ。同じtaskの複数承認（consumed・cancelledを除く）。承認で工程が変わらない。
  - 疎通の陽性4件・陰性6件。commit後のPINGで再開しない。PINGに触れた実務は残る。
  - RBT-026（WAITING_USER＋commit）。新しい順の並び。
  - DOMの局所更新：ノードの同一性、フォーカス中は動かさない、スクロール保持、失敗時に表示を保持、承認バッジ。
  - 配線と、承認操作がレーンにないこと。
- 既存：`test-activity.cjs`・`test-approvals.cjs`・`test-work-progress.cjs` PASS。`test-activity.py`・`test-approvals.py`・`test-work-progress.py` OK。
- sync（verify.cjs通過）、`--check`差分なし。生成物はキャッシュへ。
- 実データでの導出（読み取りだけ）：OPS-119が確認中、OPS-118がDONE＋記録コミット済み。RBT-026とOPS-117はWAITING_USER＋記録コミット済み。OPS-048は、ACKを除いた最新がcompleteで作業区切り。

### 限界

- 実ブラウザでの表示・操作・フォーカスの挙動は未確認（擬似DOMの試験だけ）。
- 直近200件より古い仕事は出ない。開始が範囲外なら不明と出す。
- 疎通の除外は表記の約束（PING-／WAKE-のID、`ACK `）に頼る。約束どおりでない疎通は工程に数えられる。
- OPS-093・094の古いsmokeが`clearTimeout`等で落ちる件（OPS-116で報告済み）は、今回は触っていない。

参照したキャッシュ：なし。

## Astra確認・限定補修依頼

2026-10-18。新規test-work-lane.cjsを独立実行しPASS。受入前に次の2点だけ補修する。初回Returnは保持し、末尾に第2回Returnを追記する。編集範囲・開始確認不要・サーバー操作禁止は同じ。

1. 最近の作業と従来の承認が大きな別セクションで並んでいる。ユーザーの二重レーン解消意図に合わせ、最近の作業レーン内に承認詳細を折り畳みでまとめる。未承認件数と操作入口は常時見え、既存の承認コントローラ・対象集合・履歴は維持。承認UIは一つだけとし、構造も試験で確認する。
2. isProbeEventは文中の疎通IDへの言及も除外する。たとえば「PING-20261018-Aの判定不具合を修正」は実務として残すこと。実際の疎通送信・ACKの専用書式に限定して判定し、実際の疎通例とこの陰性例を試験する。新schemaは不要。

その他の表示環境未確認は維持。追加改善へ広げず、この2点を返却してください。

## 第2回Return（姫記入）

2026-10-18 姫・Opus 5.5。初回Returnは保持。指摘の2点だけを補修した。commitなし、サーバー操作なし、実画面は未確認。

1. **承認を作業レーンの中へまとめた**（`index.template.html`）
   - 独立した「コミット事前承認」セクションをなくし、「最近の作業」セクション1つにした。
   - 見出し行には常に次を出す：レーンの件数、「コミット事前承認：承認待ちN件・承認済みM件」（既存の`approval-status`）、「表示中の未承認N件を承認」ボタン（既存の`approval-all`）。
   - 説明（`approval-policy`）、承認カード（`approval-track`）、使用と取消の履歴は、折り畳み「コミット事前承認の詳細（個別の承認・取消・履歴）」に入れた。
   - IDは全部そのままなので、既存の承認コントローラ・表示・対象集合・履歴・詳細ダイアログは変えていない。承認のUIは1つだけ。
   - 試験（`test-work-lane.cjs`）で次を確かめる：承認関係の6つのIDがHTMLにそれぞれ1つだけあること。件数と全部承認が折り畳みの外（見出し）にあること。カード・履歴・説明が折り畳みの中にあること。独立した承認セクションがないこと。
2. **疎通の判別を専用の書式に絞った**（`isProbeEvent`）
   - 送信：IDの直後にコロンがある形（`(PING|WAKE)-数字8桁-英数字` の直後に`：`か`:`）。IDの前は、文頭か空白。
   - 応答：reasonが`ACK <ID>`で始まる形。
   - 文中でIDに触れただけのもの（「PING-20261018-Aの判定不具合を修正」「疎通ID PING-20261018-A の扱いを整理」）は実務として残る。
   - 陽性：今日の実際の送信4件（A・B・C1・WAKE-D）と応答3件。陰性：上の2例に加え、「PINGの仕組み」「WAKE-UP」「XPING-…：」「ACKNOWLEDGE」「ACK の表記」。いずれも試験した。
   - 初回の試験にあった「疎通専用 PING-20261018-Z」（コロンなし）は、新しい書式に合わせて、コロン付きの送信例に直した。
   - READMEの説明（承認のまとめ方、疎通の書式）も合わせて直した。

試験：`test-work-lane.cjs` PASS。`test-activity.cjs`・`test-approvals.cjs`・`test-work-progress.cjs` PASS。`test-*.py` 3件 OK。sync（verify通過）、`--check`差分なし。

限界：折り畳みが閉じている間は、個別の承認・取消ボタンは見えない（入口は折り畳みの見出しと、見出し行の全部承認）。表記の約束から外れた疎通は、工程に数えられる。実ブラウザは未確認。

参照したキャッシュ：なし。

## Astra技術受入（2026-10-18）

初回と第2回Returnを照合し受入。独立実行でtest-work-lane、test-activity、test-approvals、test-work-progressの4本PASS、git diff --check正常。承認UIが単一で作業レーン内に折り畳まれ、件数と入口が残る構造を確認。疎通専用書式と実務でのID言及の区別、Registry状態と記録コミット済みの区別を試験で確認した。サーバー/API変更なし。正式状態はページ生成時seedに基づく。実ブラウザの見た目・操作は未確認で、技術受入を視覚確認の代用とはしない。追加依頼なし。

事前承認675d98979eb7448fb913da58ebc842deを受入時にapprovedと確認。指定ファイルをコミットする。
