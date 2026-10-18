# Studioの受渡し・終了表示と担当別ランプ（OPS-127）

## TL;DR（人間向け）

次の受取人・今回の仕事の終了と、担当別の新着・待機状態をStudioで示す限定実装の記録。最終受入では構造化したnext/presence、承認色の優先、取得不調中のタイマーなどの補修を検査し、WAKEへのACKまで確認した。通知なしは不明で、生存保証ではない。直近200件・担当最大6件の表示範囲とSafari実操作未確認を残す。

2026-10-19, Astra. Parent OPS-048. After color consultation, user requested continuous work with 姫. Use 姫's visual advice for a small implementation, then WAKE/ACK after acceptance.

<a id="要求と境界"></a>
## Requirements and boundaries

- In recent work/approvals, distinguish next receiver (「次に誰が拾う番か」) and completion (「今回の一連の仕事が終わったか」) as well as approval waiting.
- Separate small owner lamps flash only for actual new messages. Distinguish waiting/ended/unknown; no communication does not imply stopped/broken. Use short text with color; legible, gentle, reduced-motion compliant.
- Keep card state, owner lamps and approval colors distinct. No new approval actions/automatic approvals.
- WAKE ACK means waiting ended, not working; distinguish PING ACK. Commit alone does not imply sequence completion.
- Consider moving permanent probe lane inward; first propose, retaining means/history.
- Do not infer receiver from prose. Missing information is unknown; propose minimal structured fields if needed. Do not collapse multiple tasks/owners into one latest event.
- No product Sources, Registry states, save contract or actual user-data changes.

<a id="第1依頼対応表と小さな実装内訳"></a>
## First assignment: mapping table and small implementation breakdown

Read only relevant activity/recent-work/approval code and map displays to evidence, especially waiting, receiver, sequence completion, WAKE ACK, fetch failure and missing records. Distinguish derivable existing data from needed structured notifications.

Edit only 「姫第1Return」. No implementation; at most one table and per-file breakdown, three decisions. After agreement assign limited implementation. No general monitoring platform. No additional start confirmation. Record OPS-127 work/return, resume continuous waiting and end with WAKE.

## 姫第1Return

2026-10-19 姫・Opus 5.5。読んだもの：`activity.py`の`validate_event`と種類（`KINDS`）、`index.template.html`の`activityLabels`・作業レーン（`workLaneItems`・疎通の判別）・承認の表示（⚪🟡🟢🔴の信号）。実装なし。

### 前提の事実

- activityの1件が持つのは`taskId`・`event`・`owner`・`reason`・`timestamp`・`commitSha`だけ。`validate_event`はほかの項目を捨てて作り直す（31〜42行）。だから、新しい項目を足すには`activity.py`の変更が要る。
- 「誰へ渡したか」「一連の仕事が終わったか」「待機中か」を表す項目は、いまのイベントにはない。reasonの文章から読み取るのは要求で禁止されている。
- 承認の表示は⚪🟡🟢🔴の丸を使っている。ランプには丸の色を使わない。

### 表示→根拠の対応表

| 表示 | 根拠（いまのデータで決まるか） | 記録がないとき |
|---|---|---|
| 担当ランプ「新着」（一瞬だけ光る） | その担当（`owner`の文字列そのまま）の新しいイベントIDが、取得の差分に現れた。**今あるデータで決まる** | 光らない。`reduced-motion`のときは光らせず、「新着」の文字を数秒だけ出す |
| 担当ランプ「待機中」 | その担当が「待機開始」を明示した記録。**今はない**（構造化の項目が要る） | 「不明」。無通信を待機とも停止とも推定しない |
| 担当ランプ「待機終了」 | その担当の`WAKE-…`へのACK（reasonが`ACK WAKE-`で始まる、既存の専用書式）。**今あるデータで決まる**。`ACK PING-`は疎通の返事にすぎず、終了にしない | 「不明」 |
| カード「次に拾う番」 | 受渡し先の明示。**今はない**。例外として、`awaiting-commit`のあとで同じtaskに未承認のカードがあれば「ユーザー（承認）」と出せる（承認storeで決まる） | 「次：不明」 |
| カード「一連の仕事が終わった」 | 終わりの明示。**今はない**。`commit`だけでは終わりと推定しない。`complete`は「作業区切り」のまま | 何も出さない（今の工程表示のまま） |
| 取得の不調 | activity・承認の取得の失敗（既存）。担当ごとではなく、レーン全体の表示 | 既存どおり「取得不調・最終情報を保持」 |
| 複数task・複数担当 | ランプは担当ごと、カードはtaskごとに独立に決める。直近の1件で全体を断定しない | — |

### 最小の通知項目の提案（構造化）

`activity.py`に、省略できる項目を2つ足す（どちらも省略時は今と同じ）：

1. `--next <担当名|user|none>`：このイベントのあと、次に拾うのは誰か。`none`は「この一連の仕事はここで終わり」。
2. `--presence waiting|ended`：担当ランプのための自分の在席の状態。「連続待機」を始めたときに`waiting`を1回、WAKEで戻るときに`ended`。

reasonの書式（`ACK WAKE-…`）に頼っている部分も、2つ目の項目が入れば書式に頼らなくて済む。

### ファイル別の作業内訳（次の限定実装で）

- `RegistryApp/activity.py`：`--next`・`--presence`の受付と検証。`validate_event`で、2つの項目を値が正しいときだけ残す。`schemaVersion`は1のまま（省略できる追加なので、古い記録も読める）。
- `RegistryApp/index.template.html`：
  - `validateActivityRows`で2つの項目を受け取る。
  - 「最近の作業」の見出し行に、担当ランプの列を置く。担当ごとに小さな四角の印＋「Astra：新着」「姫：待機中」などの文字。光り方は1回だけ弱く（約1秒）、`prefers-reduced-motion`では光らせない。
  - カードに「次：…」の1行（ない、または不明なら「次：不明」）を足す。
- 疎通専用レーン：常設の位置から外し、「最近の作業」の折り畳みの奥（承認の詳細と並べる）へ移す。疎通の手段と履歴は残す。
- `RegistryApp/README.md`：作業イベント更新ルールの表に2つの項目を書く。
- 試験：`test-activity.py`・`test-activity.cjs`に項目の検証を足す。新規`test-handoff-signals.cjs`で、ランプの状態の遷移（新着→表示が消える、WAKE ACKは終了・PING ACKは終了にしない、記録なしは不明）、`次：`の表示、`reduced-motion`を試す。headlessで、光り方・文字・色の区別を確かめる。

### 判断点（3つ）

1. **構造化の2項目を足すか**：(a) 足す（推奨：推測なしで「次」「終わり」「待機中」が出せる）。(b) 足さず、当面は「不明」と、決まる部分（新着・WAKE ACK・承認待ち）だけを出す。
2. **待機の開始を記録してよいか**：「新しいイベントがない時はイベントを追加しない」という既存ルールがある。待機の開始は実際の切替なので、1回記録するのはルールの範囲内と読む（推奨）。ただし、待機中に定期的に書くことはしない。
3. **疎通専用レーンの置き場所**：(a) 「最近の作業」の折り畳みの奥へ（推奨）。(b) 画面の最下部へ。

参照したキャッシュ：なし。


<a id="astra応答と第2依頼限定実装"></a>
## Astra response and second assignment: limited implementation

Accepted first proposal as material. Add optional next-receiver/presence notifications. A single actual switch-to-wait record is allowed; no periodic empty events. Move probes into recent-work details. Limited display implementation, not general monitoring.

Additional invariants:
- next=none explicitly closes this task's current work. Later practical events do not inherit old next/end; absent fields return to unknown. Probe ACKs do not alter task next.
- presence is owner-based. After waiting/ended, later practical work clears stale presence to unknown unless explicit. Silence/time alone do not change it. Fetch failure is distinct lane-wide unknown.
- Initial/refetched historical events never flash. Only new IDs flash once, with text/reduced-motion. No liveness guarantee.
- Current text strip must not count WAKE ACK as work. Lamps show waiting ended; raw history retained.
- Color receiver/end on cards; approval waiting takes priority. Explain text/legend; avoid many owner-specific colors.
- Validate values/lengths, retain old records and check fields through API. Preserve save/approval contract.

Editable: RegistryApp/activity.py, index.template.html, README.md, test-activity.py, test-activity.cjs, test-work-lane.cjs, new test-handoff-signals.cjs, this 「姫第2Return」 and Current/Evidence/OPS-127/check.cjs/results.json/wide.png/narrow.png. If more files/server changes needed, return minimal scope.

Write short breakdown; no reconfirmation within scope. Only isolated Inbox, mock events/approvals and independent headless; no live server/screen/user edits. Test old-record compatibility, multiple tasks/owners, initial/duplicate fetch, waiting→work, end→new request, approval priority, failure/recovery, focus/input. Run existing activity/work-lane/approval and sync/check, save headless evidence, stop temporary processes/clean artifacts. No commit; return then wait. Astra acceptance precedes live new-CLI use.

## 姫第2Return

2026-10-19 姫・Opus 5.5。開始HEAD `c34cde8ea`。commitなし。実サーバー・ユーザーの画面・実編集データ・実activity履歴・実承認storeには触れていない。新しいCLIの項目は、Astraの受入まで実運用で使っていない（今回の自分のwork・returnの記録にも使っていない）。

作業内訳（着手時に記入）：(1) `activity.py`、(2) 表示、(3) 試験・headless・README。

### 変更

- `activity.py`
  - 省略できる`next`（80文字以内、制御文字なし）と`presence`（`waiting`／`ended`）を受け付けて検証する。正しい値のときだけ記録に残す。
  - CLIに`--next`・`--presence`を足した。`schemaVersion`は1のまま。項目のない旧記録は、そのまま読める。
  - サーバーの読み出し（`/activity-events`）は`validate_event`を通るので、新しい項目もそのまま届く（`test-activity.py`で確かめた）。
- `index.template.html`
  - イベントの検証に2項目を足した（不正な`presence`は拒否）。
  - **次の担当**：カードの3行目の先頭に「次：…」。決め方の順は次のとおり。そのtaskに承認待ちがあれば「次：ユーザー（承認待ち）」（最優先）。なければ、そのtaskの最新の**実務**イベントの`next`（`none`は「この仕事は終了」、`user`は「次：ユーザー」）。どれもなければ「次：不明」。
    - 古い値は持ち越さない。疎通（PING・WAKE・ACK）と在席の記録は、実務に数えない。
    - カードの左の線で区別する：赤＝承認待ち（上の承認信号の🔴と同じ意味）、青＝次の担当あり、灰＝この仕事は終了、薄い線＝不明。凡例を1行足した。
  - **担当ランプ**：「最近の作業」の見出しに、担当ごとの小さな印と文字（「姫：待機中」など）を出す。
    - 状態は、その担当の最新の記録から決める。`presence`があればその値。`ACK WAKE-…`なら待機終了。`ACK PING-…`など疎通なら前の状態のまま。それ以外の実務なら「不明」。沈黙や経過時間では変えない。
    - 新着：初回の読込や同じ内容の再取得では光らない。新しいIDが届いた担当だけ、1回弱く光り、3秒だけ「・新着」と出る。動きを減らす設定（`prefers-reduced-motion`）では光らず、文字だけ。
    - 取得の失敗：ランプの列全体を「不明（取得不調）」にし、回復で戻る。
    - 印は四角（点線・枠・塗り）と文字で、承認信号の丸の色は使わない。
  - 在席の記録は、工程と「現在」の帯に数えない（作業イベントの帯には原文のまま残る）。WAKE ACKが「作業」に見えないことも、既存の処理で保たれている。
  - 疎通専用の欄を、「最近の作業」の中の承認の詳細の下へ移した（折り畳みのまま、手段と履歴は残る）。
- `README.md`：作業イベント更新ルールに、2項目と、ランプの意味（仕事中の保証ではない）を足した。

### 試験

- `test-activity.py`（新しいtest：2項目の往復、不正値の拒否と無変更、旧記録、サーバーの読み出しで項目が届く）OK。ほか`.py` 2件 OK。
- `test-activity.cjs`（2項目の検証、在席の記録は「現在」に出ないが帯には残る）・`test-work-lane.cjs`（3行目の先頭が「次：」、承認待ちが優先）・新規`test-handoff-signals.cjs`、ほか既存の.cjs 6件、すべてPASS。
  - `test-handoff-signals.cjs`で確かめた内容：
    - 次の担当：最新の値だけ。持ち越さない。疎通のACKで変わらない。終了→再依頼で不明。commitだけでは終わりにしない。承認待ちが優先。taskごとに独立。
    - ランプ：PING ACKで変わらない。実務で不明に戻る。WAKE ACKで終了。担当ごとに独立。言及は実務。
    - 表示：初回・同じ内容の再取得では光らない。新着は該当の担当だけ1回。消える。取得失敗と回復。動きを減らす設定。丸を使わない。疎通欄の位置。
- sync（verify通過）、`--check`差分なし。OPS-096 `layout.cjs` ALL PASS、OPS-095 `placement.cjs` 問題0、OPS-092 `edge-audit.cjs` 従前どおり。
- headless（`Evidence/OPS-127/check.cjs` → `results.json`、`wide.png`、`narrow.png`）：
  - ページは試験専用サーバー（ポート18937、空の一時Inbox）。`/activity-events`と`/commit-approvals`は、ブラウザ内で模擬データに差し替えた。実の履歴・承認storeには書いていない。
  - 流れ：
    1. 依頼（next=姫）＋姫のwaiting：姫は「待機中」、光らない。
    2. 姫の返却（next=Astra）：姫は「不明・新着」、カードは「次：Astra」。3.5秒後に「・新着」が消える。
    3. 受入（next=none）：カードは「この仕事は終了」（灰）。
    4. 姫のPING ACK：カードは変わらない。
    5. 姫のWAKE ACK：姫は「待機終了」。
    6. 再依頼：カードは「次：不明」へ戻る。
    7. 取得失敗：全員「不明（取得不調）」。回復で戻る。
  - 承認待ちのOPS-902は、ずっと「次：ユーザー（承認待ち）」（赤）。commitだけのOPS-903は「次：不明」。
  - 入力欄のフォーカスと入力値は、更新の間も残った。動きを減らす設定では`animation:none`。ページのエラーは0件。
- 試験用サーバー・ブラウザは終了済み（プロセス0件）。一時ディレクトリは削除済み。

### 限界

- Safariの実機は未確認。
- 担当名は`owner`の文字列そのままで区別する（「姫」と「Claude（姫）」は別のランプになる）。
- 「次」と「終わり」は、新しい項目が書かれてはじめて出る。今までの記録はすべて「次：不明」のまま。
- ランプは直近200件の記録の中だけで決まる。

参照したキャッシュ：なし。


<a id="astra第2確認限定補修依頼"></a>
## Astra second review and limited repair assignment

2026-10-19. Independently passed activity.py 4 tests and activity/work-lane/handoff JS checks. Repair only these display boundaries and append results to the same Return:

1. New-arrival timer after fetch failure repaints 「不明（取得不調）」 as 「不明」. Reproduced with new update→failure→timer in test-handoff-signals.cjs lamps. Keep failure until recovery.
2. Timer must not revive owners removed from latest six; test after removal.
3. Later consultation [data-stage] border-color overrides approval [data-next] red left border. Check/repair simultaneous consultation+pending so approval color wins.

Only allowed files. Necessary regressions; computed color via headless. No live-server/user-screen operations or commit; then continuous waiting. No features/generalization.

## 姫 限定補修Return（2026-10-19）

姫・Opus 5.5。指摘の3点だけを直した。許可されたファイルだけを編集。commitなし。実サーバー・ユーザーの画面は操作していない。

1. **新着タイマーと取得不調**：タイマーが発火したとき、取得失敗の表示中（`box.dataset.stale==='true'`）なら「新着」の印だけを外し、文字は描き直さない。「不明（取得不調）」は回復まで残る。
2. **一覧から外れた担当**：タイマーは、その担当のランプがまだ一覧にあり、しかも最新の新着のときだけ動く（`lamps.get(owner)!==lamp||lamp.fresh!==mine`なら何もしない）。直近6担当から外れた担当を描き直して復活させない。
3. **相談待ちと承認の色**：「次」の左線の規則を`.work-lane .work-card[data-next=…]`にして、詳細度を上げた。相談待ちの`border-color`が後ろにあっても、承認待ちの赤い左線が勝つ。

検査：
- `test-handoff-signals.cjs`に3点の回帰検査を足した。
  - 新しいイベント→失敗→タイマー発火で「不明（取得不調）」が残り、回復で消える。
  - 7担当目が来て外れた担当が、タイマーで復活しない。
  - 承認の規則の詳細度が、相談待ちの規則より高い。
- 3点とも、修正を戻した一時コピーで落ちることを確かめた。1点目は実ファイルで、2点目・3点目はそれぞれ修正を戻した版で、該当の検査が失敗した。
- 修正後は、全.cjs（9件）PASS、.py 3件 OK、sync（verify通過）・`--check`差分なし。
- headless（`Evidence/OPS-127/check.cjs`に1手順を追加 → `results.json`の`consultWithApproval`）：承認待ちのOPS-902に「相談待ち：…」を足すと、`data-stage=相談待ち`・`data-next=approval`で、計算された左線は`rgb(192, 57, 43)`（赤）、上の線は`rgb(187, 139, 50)`（相談待ちの色）。ほかの手順の結果は前回と同じで、ページのエラーは0件。
- 試験用サーバー・ブラウザは終了済み。一時ディレクトリは削除済み。

参照したキャッシュ：なし。


<a id="astra最終受入2026-10-19"></a>
## Astra final acceptance (2026-10-19)

Technically accepted assigned scope. Checked second Return/repair and independently passed activity Python 4, approvals Python 8 and activity/work-lane/handoff-signals/approvals JS tests. Approval HTTP tests initially blocked by sandbox bind permission, then 8 passed on allowed isolated port. Whitespace diff passed.

Code/regressions distinguish initial/refetch/new arrival, task next, owner presence, PING/WAKE and new request without stale completion. Timer failure/removal and consultation/approval color collisions fixed. Reviewed 姫's isolated WebKit results/wide/narrow evidence for input retention/reduced-motion/approval priority. No Astra operation of live Safari.

New optional next/presence may be used operationally. No notification means unknown, not continued work/liveness. Display limits: 200 events, 6 owners. Running server loads activity.py at startup, so fields require restart; confirmed restart-recommendation detection covers it. No actual stop/restart.

Sent WAKE-20261019-B and confirmed 姫 ACK at 2026-10-18T16:41:21Z (presence=ended). Continuous waiting ended. Notifications retained in Activity/events.jsonl.
