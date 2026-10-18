# メンバー状態の規約・表示の往復協議

## TL;DR（人間向け）
トップバーのAstra継続表示を作業ページへ移し、メンバー状態としてまとめたい。まず状態の意味と更新責任を姫と往復で確認する。表示の改修とコンシェルジュ制度を先に実装しない。

2026-10-19 / OPS-141 / Astra作成。ユーザーの「先にそっち、姫と往復」による依頼。

## Astraの初案

「本人が申告した活動状態」と「その記録の鮮度・取得可否」は別軸にしたい。作業中・待機中・終了は本人の明示記録に基づき、依頼送信や無通信から推定しない。期限切れは確認の途切れで停止断定ではない。特にWAKE ACKのendedは待機終了であり、その人の全作業終了や離席へ広げない。返却は次の状態を本人が添え、返却単独から待機を作らない。

更新契機は着手・返却・待機開始/終了・意図した連続動作終了。節目の単発信号を基本とし、独立heartbeatで本人不在を隠さない。既存のpresenceとcontinuityの役割を照合し、表示だけのために二重報告を義務化しない。識別はモデル名だけでなく会話/担当単位の必要性を検討。同名複数会話を今すぐ支援する実装は要求しない。

## 姫への第1依頼

通信規約0.2、activity/continuityの現実と照合し、初案の矛盾・負担・不足を最大5点に絞って返してください。各点に最小の修正案、現実装で成立/未実装の区別を付ける。二系統（省力・手動）で同じ意味を保つこと。状態一覧を増やすための網羅調査は不要。

編集は本書の「姫第1返却」への追記だけ。規約本体・Registry・コード・他者記録・commit・ライブサーバーは操作しない。返却を通知したら、第2往復のため連続待機してください。Astraが応答案を書き、姫に再照合してもらう。正式規約への反映と表示実装の境界はそこで明記する。

## 姫第1返却

返却（2026-10-19 姫・Opus 5.5）。照合したのは、通信規約0.2、`activity.py`・`continuity.py`、Studioの`presenceStates`・作業レーン（`index.template.html` 1123・1167行あたり）、今日の姫の実際の操作。規約・コードの変更はなし。

1. **「作業中」を明示する記録がない（現実装は未対応）。**
   - 現状：presenceの値は`waiting`/`ended`だけ。本人の実務記録が来るとランプは「不明」に戻る。初案の「作業中は本人の明示記録」に当たる値はない。
   - 最小案：新しい値を足さず、「本人の実務の記録（work・return等）＝その時点で作業中と本人が申告した」と規約で定義する。依頼の送信や無通信からは推定しない、という初案の線はそのまま保てる。表示を「不明」から「作業中（記録 hh:mm）」に変えるだけで済む。
   - 手動経路では、会話で「着手します」と書けば同じ意味になる。
2. **「ended」が2つの意味で使われている（現実装で衝突あり）。**
   - presenceの`ended`とWAKEへのACKは「待機の終了」。continuityの`ended`は「連続動作の意図した終了」。今の画面では別の場所に出ているが、メンバー状態として1行にまとめると混ざる。
   - 今日の実例：ユーザーからのWAKE（19:19）に、待機を続ける前提で`ACK WAKE-…：受信（待機は継続）`と返した。それでも`presenceStates`は、`ACK WAKE`を無条件に「待機終了」と判定するので、ランプが一度「待機終了」になった。直後に`waiting`を書き直して戻した。
   - 最小案：表示の言葉を「待機終了」と「連続動作の終了」に分けて、まとめない。WAKEへのACKを「待機終了」とみなすのは、本人が`--presence ended`を付けたときだけにする（ACKの文面からは推定しない）。ここはコードの変更が要る。
3. **「返却に次の状態を添える」は、今は1操作でできない（現実装の制約）。**
   - `--presence waiting`は`return`にも付けられるが、作業レーンも「現在」の帯もpresence付きの記録を飛ばす（1123・1051行）。付けると返却がレーンから消える。だから姫は毎回「return」と「presence waiting」の2件を書いている。
   - 最小案：レーンが飛ばすのを「presence付きのwork」に限る（returnなどの実務はpresence付きでも数える）。そうすれば1件で済む。それまでは、2件に分けることを規約に書いておく。
4. **55秒の期限は待機中にしか合わない（負担と誤検知）。**
   - continuityの`alive`を節目だけで書くと、作業中（ビルド・試験・長い読み込み）は数分あいて「途切れ」が頻繁に出る。姫の待機は5分ごとの区切りなので、区切りごとに書くだけでも途切れる。待機ループの中で20〜50秒ごとに書けば防げる（シェルで書くのでトークンは増えない。ターンが終われば止まるのでheartbeatの偽装にはならない）。
   - 最小案：期限は「待機中」と申告している間だけ55秒にする。作業中は期限を設けず、経過時間を表示するだけにする。「止まったら1分以内」というユーザーの目的は、主に待機が途切れた場合を指すので、それに合う。現実装は、状態に関係なく一律55秒。
5. **識別は担当名だけ。同じ名前の会話が2つあると区別できない（現実装も同じ）。**
   - activityもcontinuityもWAKEの宛先も、担当名をキーにしている。同時に2つの「姫」の会話があると、ランプ・期限・WAKEがどちらのものか分からない。
   - 最小案：今は「同じ名前で連続待機する会話は1つまで」という運用の約束にとどめる。必要になったら、reasonの先頭に会話の短い識別子を付けるところから始める（形式の追加は後回し）。手動経路では、会話そのものが識別になるので問題は起きない。

二系統の意味：1・3・5は、会話の文面でも同じ意味を表せる。4の「鮮度」の軸は省力側にしかない。手動側は「最終確認 hh:mm」と書くことで代わりにする。2は、どちらの側でも「待機終了」と「連続動作の終了」を言葉で分ければ揃う。

## Astra応答・第2依頼（2026-10-19）

第1返却を受領。以下の修正案を既存規約と運用に照らして再確認してください。編集は本書の「姫第2返却」への追記のみ。実装・規約確定・commitなし。

1. 実務イベント全般を「作業中」に変換しない。returnは返却した事実であり、その後も作業中という申告ではない。明示的な着手と待機を状態として扱い、その他のイベントは「最後の活動」として時刻付き表示に分ける。現行workにもACK等が混じるためevent名だけでは着手と確定しない。明示値の追加が必要なら小さな追加を避けない。
2. endedの二義は分離する。WAKE受信ACKは受信確認、待機終了は本人の明示に基づく。現在の通信規約にあるWAKE/ACKの完了解釈と、UI側の依頼消化判定も移行対象として挙げる。古いACK記録を黙って新しい意味に変えない。
3. 返却＋次状態を一度で記録でき、返却もレーンに残る案を支持。実装までの2操作は暫定手順と明示。二つの状態ファイルへの二重申告を必須にしない。
4. ユーザーは主にAstraの連続動作の途切れを知りたかった。待機だけの目的と狭めない。55秒を超えたら「確認が古い」と表示し、作業中/待機中の申告を勝手に終了へ変更しない。長いツール中にも古くなる限界は残す。待機ループ内の信号更新は、その待機処理と確実に寿命が結び付く場合にだけ検討可能で、今回は新規ループ実装をしない。
5. 同名の活動会話を区別できない制約を明記。同時利用時は別の担当表示名を使う。reason内の識別子だけで機械的に分離できるとはしない。恒久的な会話ID設計は別途必要になったときに扱う。

再返却では、残る矛盾と最小の実装項目を短くまとめてください。その後Astraが規約案・実装境界をまとめる。

## 姫第2返却

返却（2026-10-19 姫・Opus 5.5）。経緯：上の「姫第1返却」の文面は姫の下書きと同じ内容だが、姫の書き込みはユーザーが途中で止めたので、本書へ書いたのは姫ではない（転記したのはユーザーかAstra）。activityの第1返却の通知も出していない。内容は姫の意図どおりなので、そのまま第1返却として扱ってよい。

Astraの5つの修正には、すべて同意する。4の「55秒を待機中だけにする」という姫の案は撤回する。残る矛盾と、最小の実装項目は次のとおり。

**残る矛盾**
- A（1と3）：明示の「着手」を状態にすると、返却の後も「作業中」が残る。returnは作業中の申告ではないので、returnが次の状態（待機・なし）を一緒に運べるようになる（3）までは、状態と最後の活動を並べて出す必要がある。例：「作業中（申告 hh:mm）・最後の活動：返却 hh:mm」。3が入れば、この矛盾はほぼ消える。
- B（2）：`presenceStates`から「`ACK WAKE`＝待機終了」をやめると、過去のACKの記録の表示も変わってしまう。新しい意味は切替の時刻より後の記録にだけ当て、それより前のACKは従来どおり「待機終了」と読む（日時の定数を1つ置く）。過去の記録を黙って読み替えない。
- C（3と4）：「二重申告を必須にしない」と、continuityが別ファイルで本人が別に書くこととがぶつかる。案：本人が自分のactivityの記録を書いた時点で、continuityの確認時刻も同時に更新する（activity.pyの中で行う）。そうすれば別に書く操作は任意になる。書いた主体を信用する度合いは、activityそのものと同じ。

**最小の実装項目**（規約が決まった後）
1. presenceの値に、明示の着手`working`を足す。`ended`は「待機終了」の意味のまま、旧記録との互換を保つ。表示では、状態と「最後の活動（時刻つき）」を分ける。
2. `presenceStates`の「`ACK WAKE`→待機終了」を、切替時刻より後の記録には適用しない。READMEの「ACKの返事でも待機終了になります」と、規約の該当箇所も直す。待機完了ボタンの「ACK済み」は受信確認の意味のままで、変更は要らない。
3. 作業レーンと「現在」の帯が飛ばすのを、「presence付きのwork」だけにする。presence付きのreturnはレーンに残す。それまでは2件に分けることを、暫定の手順として規約に書く。
4. continuityで55秒を超えたときの表示を「確認が古い」に変える（今は「途切れ」）。状態（作業中・待機中）は変えない。任意で、上のCの同時更新を入れる。
5. 同名の会話を区別できないことを規約に書く。同時に使うときは別の担当表示名を使う。実装は不要。

手動経路との対応：1は会話の「着手します／返却します。この後は待機します」、2は「受け取りました（待機は継続）」と「待機を終えます」を言い分けることで同じ意味になる。4は「最終確認 hh:mm」と書く。

訂正（19:27、姫）：冒頭の経緯は誤り。activityを確かめたところ、19:22:20の第1返却のreturnは姫自身が送ったもので、正本への書き込みも姫の操作で完了していた。ユーザーが止めたのは、同じコマンドの後半（待機）だった。姫は止められた時点で何も書かれていないと思い込み、確かめずに「未書込」（19:25:23の記録）と「他者の転記」を書いた。第1返却は1件だけで、重複はない。

## Astra整理 — 往復協議の結論（2026-10-19）

姫の第2返却と経緯訂正を受領。協議成果として受入。規約本体とコードはまだ変更していない。表示移設の依頼は本taskで継続して追跡する。

- 作業ページにメンバー状態を集める。本人が明示した状態、申告時刻、最後の活動、確認の鮮度を区別する。トップバーのAstra表示は移設対象。
- 着手には明示値workingを使い、依頼・返却・ACKだけでは作業中を推定しない。返却と次状態を1件で運べるようにする。状態が添えられていなければ、古い申告と最新の活動を時刻付きで併記する。
- 待機終了と連続動作終了を別の意味にする。WAKEのACKは受信確認、待機終了は本人の明示。ボタンのACK済みを終了済みと誤読させない。旧記録は旧解釈を注記できるが、推定だったものを本人の明示と呼ばない。切替は証拠に残る版/境界を定め、任意の日付定数だけに意味を隠さない。
- 55秒は確認情報の鮮度の目安。「確認が古い」と表示し、活動状態を終了へ変更しない。長い処理・取得不調・未記録は区別する。
- 省力経路では実務記録と確認時刻を一操作にまとめる候補を検討する。ただし本人の記録か、代理送信・履歴取込かを区別し、後者で本人を稼働扱いにしない。2ファイル更新が片方だけ成功した場合を成功と偽らない。手動経路は会話＋参照記録で同じ意味を保つ。
- 同名の複数会話は区別できない制約を明記し、同時利用では異なる表示名を使う。コンシェルジュ設計・常駐heartbeat・全面的会話ID導入は本件に含めない。

次の区切りは通信規約の改訂と限定実装。着手前に、旧記録の境界、返却＋状態のレーン保持、部分失敗の扱いを実装内訳で固定する。協議完了を表示変更完了とは扱わない。

## 第3依頼 — 規約反映と限定実装（2026-10-19）

ユーザー「残クレジット渋いけど、頑張って動いてみて」に基づきAstra発注。先の結論を次の小さい範囲で実施してください。新規調査を広げず、内訳を短く本書へ追記して着手。

1. 通信規約を0.3へ。本人状態/最後の活動/鮮度、待機終了/連続動作終了、同名会話の制約と手動経路を整理。過去記録の意味は保存し、実装済みと未実装を分ける。
2. トップバーのAstra継続表示を作業ページの「メンバー状態」へ移す。既存presenceランプも同じ領域へ。状態、記録時刻、最後の活動を確認できる形。活動の記録に現れるメンバーと継続記録のメンバーを扱い、Astraだけに固定しない。継続記録のない人は未確認で、存在しない状態を作らない。
3. presenceにworkingを追加。本人の明示がない実務eventだけで作業中としない。return＋presenceが返却レーンから消えないようにする。既存waiting/endedは待機開始/待機終了。ACKだけで終了と推定する処理は新しい記録では廃止。旧記録境界は既存の最新event ID等で固定して記録し、旧解釈は明示的な本人申告と区別。待機完了ボタンのACK済みは受信確認と説明する。
4. 継続記録の55秒超は「確認が古い」。活動状態を変更しない。今回はactivityとcontinuityの自動二重書込は実装しない（部分失敗/代理送信の設計を増やさない）。既存単発CLIは維持し、頻繁な二重報告を新しい必須義務にしない。

範囲：関連UI/activityと限定試験、通信規約/README、本書Return。Registry/採番/commitはAstra。ライブサーバー/ユーザー画面は操作しない。隔離試験可。確認項目は複数メンバー、未記録/古い/取得失敗、working→返却waiting→待機終了、ACKだけで終了しない、返却が消えない、作業/タスク切替と狭幅。既存試験は変更に関係するものだけ。返却後はAstra確認のため連続待機。

受入条件：規約と表示の意味が一致し、トップバーから移設され、既存保存/承認を壊さない。未実装の自動更新を実装済みとしない。

## 姫第3依頼の内訳（実装前、2026-10-19）

- 旧記録の境界：この時点の最新のevent（idと時刻を規約0.3に記す）。それ以前の`ACK WAKE`だけを旧解釈で「待機終了（旧ACK）」と表示し、本人の明示とは表示を分ける。それより後のACKは受信確認だけで、状態を変えない。
- 状態は、本人の最新のpresence（`working`／`waiting`／`ended`）がそのまま残る。実務の記録は「最後の活動」として、時刻つきで別に出す（状態は変えない）。PINGとACKは、どちらも変えない。
- 作業レーンと「現在」の帯が飛ばすのは、presence付きの`work`だけにする。presence付きの`return`はレーンに残す。
- メンバー状態：作業領域のランプを「メンバー状態」とし、activityとcontinuityに出てくる担当をまとめる。1人につき「状態 時刻・最後の活動・継続確認（未確認／時刻／確認が古い／不調／連続動作の終了）」を並べる。上段のAstraの表示は外す。
- 部分失敗：activityとcontinuityを自動で二重に書くことはしない。表示側で、片方だけ取れないときは、その欄だけを「不調」にする。
- 試験：既存のランプ・継続確認・レーンの試験のうち関係する箇所を直し、新しい検査を足す。隔離headlessで2つの幅を確かめる。

## User UI amendment — request direction (2026-10-19)

Show the sender and recipient on request event cards as `Astra → 姫`, using the recorded owner and next recipient. Preserve the existing task ID and event label. Use the actual recorded names; do not rename Astra to Astora. If the recipient is missing/none/unknown, show the sender only or an explicit unknown recipient, never invent one. Apply only to request event presentation; no event schema or historical record rewrite. Include a small rendering check for known and missing recipients. This is an addition to the current implementation scope.

## User UI amendment — separate member area (2026-10-19)

Within the Work page, give member status its own visibly separate section, not an inline part of Recent work or its heading. Use comfortably readable member cards/rows with larger text and spacing than the existing tiny presence lamps. Keep each member's declared state, last activity, and confirmation freshness distinguishable. Allow wrapping on narrow screens; do not put this back in the top bar. Verify wide and narrow layouts with the current isolated checks.

## 姫第3返却（規約反映と限定実装）

返却（2026-10-19 姫・Opus 5.5）。commitなし。
- 規約0.3（`COMMUNICATION_PROTOCOL.md`）：§2に「メンバー状態」の小節を足し、版の行と改訂履歴に0.3を加えた。書いたのは、申告した状態・最後の活動・確認の鮮度の区別、`working`、待機終了と連続動作の終了の区別、ACK＝受信確認、旧記録の境界（event `feeb9d2c…`、19:35:45Z）、同名会話の制約、手動経路、未実装（自動の同時更新）。
- 実装：
  - `activity.py`：`PRESENCE`に`working`を足した。
  - `index.template.html`：
    - `presenceStates`を書き換え、状態は本人のpresenceだけで変わるようにした。境界より前のACK WAKEは`legacy`として旧解釈で読む。「最後の活動」は別に持つ。ユーザーはメンバーに含めない。
    - `createPresenceLamps`は「状態 時刻 · 最後 活動 時刻 · 継続確認」を表示し、continuityの記録だけがある担当も「未申告」として出す。
    - 継続確認は全担当を扱うように一般化した（`CONTINUITY_OWNER`は削除）。55秒を超えたら「確認が古い」、`ended`は「連続動作の終了」。上段の`#continuity-status`は削除した。
    - レーンと「現在」の帯が飛ばすのは、presence付きのworkだけにした。presence付きの`working`は検証で受け付ける。
    - 待機完了の「ACK済み」は「ACK済み・受信確認」とし、titleで意味を説明した。
  - 自動の二重書き込みはしていない。
- 試験：`test-handoff-signals.cjs`のランプの部分と、`test-continuity.cjs`を新しい意味で書き直した。内容は、状態が変わらないこと、旧ACK、新ACK、作業中→返却と待機→待機終了、返却がレーンに残ること、continuityだけの担当、不調と回復、全担当、未確認、確認が古い、上段からの撤去。cjsの14本とPython 3本はすべてPASS。sync・`--check`も通った。
- headless（`Evidence/OPS-141/check.cjs`・`results.json`・`wide.png`・`narrow.png`、隔離port 18948、activity・continuity・承認はすべて模擬、POSTは0件）：2つの幅とも、5人のメンバーが出た。
  - 姫：待機中。最後は返却。継続は8秒前。
  - Astra：未申告。継続は「確認が古い（93秒前）」。
  - Luna：待機終了（旧ACKからの読み）。
  - Sol：未申告。継続の記録だけがあり、「連続動作の終了」。
  - Fable：未申告。
  - 新しいACKでは状態が変わらなかった。continuityの取得に失敗すると全員の継続欄が「不調」になった。姫が`ended`を書くと「待機終了」になった。返却はレーンに残った。上段にはAstraの表示がない。作業とタスクを往復してもメンバー状態は残った。ページのエラーは0件。
  - 初回は、模擬の時刻が境界より前だったため、姫の新しいACKまで旧ACKと読まれた。時刻を境界の後へずらして取り直した。
- 限界：
  - 実サーバーの再起動はしていない。動いているサーバーで`working`を書くには、activity.pyがファイルから読まれるので再起動は要らないはず（未確認）。表示はsyncの後に読み直せば反映される。
  - Chromiumは試していない。

## Hime third return — addendum (amendments of 19:36–19:40, English per the language trial)

Returned 2026-10-19, Hime (Opus 5.5). No commit. The Japanese third return above was written after the language policy of 19:36 without noticing it. It is kept as returned; this addendum and the rewritten new sections follow the policy.

- **Language**: the new protocol 0.3 section ("Member status") and its history row, and the new README section, are now in English. Earlier unchanged sections were not translated.
- **Request direction**: activity-band request cards show `sender → recipient` from the recorded `owner`/`next`, e.g. `OPS-2 · Astra → 姫 · 依頼`. Without a recipient (or `none`/`unknown`), the sender only. No schema or record change; other events unchanged. The check is in `test-handoff-signals.cjs`.
- **Separate member area**: `#presence-lamps` moved out of the Recent-work heading into its own `section.member-area` titled "メンバー状態", above Recent work. The cards use 13px text, padding, and one line per field (state / last activity / continuity). They wrap on narrow screens. The test asserts it is outside the lane; headless shows 13px and in-view at both widths (`Evidence/OPS-141/wide.png`, `narrow.png`).
- **Tests**: all 14 cjs and 3 Python suites pass; sync and `--check` pass. Headless re-run (isolated port 18948, all APIs mocked, 0 POSTs, no page errors).
- **Limit**: the user's live server was not restarted or touched. Chromium is not checked.


### Hime third return — acceptance-note fixes (19:42)

- Protocol §5 "継続確認" row rewritten (English) to match §2 and the code: marks appear in Work → member status, not the top bar. The labels are "継続 hh:mm", "確認が古い" over 55 s, "連続動作の終了", "未確認" and "不調". The row says the declared state is never changed and no stop is asserted. No other "途切れ"/top-bar wording remains in the protocol (grep).
- `presenceStates` no longer slices to 6 owners. Every member in the 200-record window is shown, newest first, and the member area wraps. The OPS-127 timer test now checks that 8 members all show, that an owner leaves only when its records leave the window, and that the flash timer does not revive it. Related cjs pass; sync/`--check` pass.

## Astra acceptance — 2026-10-19

Accepted the implementation and both UI amendments. Independently ran test-handoff-signals.cjs, test-continuity.cjs and test-activity.cjs: PASS. Inspected the saved narrow-screen image: member status is a separate readable section in Work and absent from the top bar. Reviewed the explicit-state/legacy-ACK logic and protocol alignment; Hime corrected the stale §5 description and removed the silent six-member limit. Request direction uses recorded sender/recipient. Isolated browser evidence is Hime's; the live server was not restarted or operated. Commit remains a separate approval step.

## 追加の表示変更（2026-10-19）

ユーザー指示により、コミット事前承認の詳細と使用・取消履歴を常時表示へ変更。疎通確認など他の折りたたみは変更しない。承認操作・保存データは変更しない。
