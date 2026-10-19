# Studioユーザビリティ改善の段階実施（OPS-126）

## TL;DR（人間向け）

表示・閲覧に関する8案を、姫との相談と限定実装・確認に分けて進めた記録。最終受入では全8案の段階実施を完了し、関連試験とWebKit/Chromiumの保存証拠を照合した。Safari実機、通知開閉時の本文移動、単語途中の改行などの制約を残し、保存契約・権限・接続の意味を変えたものではない。

2026-10-18 / Astra. Parent OPS-048; material OPS-125. The user delegated 「受け入れ仕分けしながら姫と相談しながらすすめて」; Hime was already waiting. This authorizes reversible display improvements, not save-contract, authority or process changes.

<a id="astraの暫定仕分け"></a>
## Astra's provisional triage

| Proposals | Treatment | Boundary |
|---|---|---|
| 1/2 | First implementation candidates | Keep only title/operation row fixed; prevent scrolled destinations being hidden, without removing operations/activity. |
| 3 | Candidate small change | Shorten unknown-start wording to 「開始：不明」 while retaining outside-record/unrecorded detail. |
| 4 | Next stage | Two-line local-card titles without changing connections/backbone; retain full-text access. |
| 5 | Bounded repair after reproduction | Reproduce tooltip remaining on scroll in headless; record real-device uncertainty separately. |
| 6 | Next stage | Collapse add forms; retain in-progress input, warnings and open state across redraw. |
| 7 | Reassess after 1/2 | Repair remaining narrow-screen problems only; do not rely on hover. |
| 8 | Discuss separately | Investigate minimal connection-anchor changes preserving order/graph meaning; no implementation yet. |

<a id="姫への第1依頼短い相談"></a>
## First assignment to Hime: brief consultation

Edit only 「姫第1回答」. Return disagreements/omissions and file-level breakdown/checks for proposals 1/2, especially sticky-parent limits, variable header height, button wrapping, scroll regressions and activity access. No whole-code audit.
No renewed start confirmation, implementation, commit or active-server operation. If needed, read-only checking in an independent headless browser is allowed, without saving/approving/updating existing data. Close/remove test environments and record retained evidence. Return then await the next bounded assignment. Record OPS-126 work/return and one cache-reference line.

## 姫第1回答

2026-10-18 姫・Opus 5.5。読んだもの：`index.template.html`の`<header>`の中身とheader関係のCSS、`scrollIntoView`の呼び出し、`test-approvals.cjs` 60行。数値はOPS-125作成時のheadless観察（ヘッダー183px／390px幅で約280px）。今回はheadlessを起動していない。実装・commitなし。

### 暫定仕分けへの意見

おおむね賛成。補足と、私の訂正が1つずつある。

- **案2の効き目を訂正する（私の提案の言い過ぎ）**：アプリ内の`scrollIntoView`は「変更内容を見る」の差分パネル（820行）の1か所だけだった。タブの切替ではスクロールしない。案2が効くのは、差分パネル、キーボードでのフォーカス移動、ブラウザのページ内検索。単独の価値は小さいので、案1と同じ値（ヘッダーの高さ）で一緒に入れるのがよい。
- **案5**：たいていのブラウザは、マウスを動かさずにスクロールすると`mouseleave`を出さない。なので、実機でも起きうる（推測）。headlessでは、`page.mouse.move`でカードに乗せてから`mouse.wheel`でスクロールすれば再現を確かめられる。
- **案7**：1・2の後に再評価、に賛成。候補は「600px以下では固定をやめる」の1行。これは下の判断点2にした。
- 見落としは見つからない。案8を別枠にするのも賛成。

### 最初の区切り（案1・2）の作業内訳

いまの`<header>`は、次の5つを1つの固定要素として持っている：題名と操作の行（`.header-row`）、説明文（`.header-note`）、現在の作業（`.activity-current` 44px＋余白）、作業イベントの帯（`.activity-timelines` 48px＋余白）、正本変更の通知（`#canonicalNotice`、通常は非表示）。stickyは親の箱の中でしか効かないので、`.header-row`だけを中で固定することはできない。だから、要素を外へ出す必要がある。

**`RegistryApp/index.template.html`**
1. HTML：`.header-note`・`.activity-current`・`.activity-timelines`を`<header>`の外、直後の新しい`<section class="header-info">`へ移す。IDは変えないので、JSと既存の取得処理はそのまま動く。
2. HTML：`#canonicalNotice`は`<header>`に残す。外へ出すと、通知が出た瞬間に本文が下へずれる。固定の中なら、本文の位置は変わらない。
3. CSS：`.header-info`にヘッダーと同じ背景と左右の余白を付ける（見た目は今とほぼ同じで、スクロールで流れるだけ）。`header`のstickyは残す。
4. CSS＋JS（案2）：`html{scroll-padding-top:var(--sticky-h,0px)}`を足す。`ResizeObserver`で`header`の高さを`--sticky-h`へ入れる（数行）。ボタンの折り返しや通知の開閉で高さが変わっても追従する。

**新規 `RegistryApp/test-header-layout.cjs`（静的な検査）**
- `<header>`の中には`.header-row`と`#canonicalNotice`だけがあり、`activity-current`・`activity-events`・`header-note`は外にある。
- `header`のstickyが残っている。`scroll-padding-top`と高さを追従させる処理がある。
- 既存の`test-approvals.cjs` 60行（承認レーンが`</header>`より後）も、そのまま通るはず。

**headlessでの確認（試験専用サーバー、終了後に削除。証拠はEvidenceへ）**
1. 1400×900で、固定部分の高さが183pxから大きく下がる（目安は70px前後）。下へスクロールしたとき、見取り図の上の段のカードの上端が`elementFromPoint`でヘッダーに隠れていない。
2. 390×844と900px幅で、ボタンが折り返した高さに`--sticky-h`が追従している。
3. 差分パネルへの`scrollIntoView`で、パネルの上端が固定部分の下に来る。
4. 作業イベントの帯が3秒ごとに更新されても、スクロール位置（`scrollY`）が動かない。帯の高さは固定値なので、ずれは出ない見込み。
5. ページの先頭へ戻れば、活動帯と「現在の作業」が今と同じように見える。帯の横スクロールとフォーカスも、今と同じに動く。
6. 既存の`test-activity`・`test-approvals`・`test-work-lane`・`test-work-progress`（.cjsと.py）、sync・`--check`。

### 判断点（ユーザーへ、2点）

1. **活動の帯を固定から外してよいか**：外すと、見取り図を見ている間は「現在：…」の1行も見えなくなる。(a) 3つとも流す（推奨：いちばん広く使える）。(b) 「現在：…」の1行だけ固定の行に残す（固定部分が20px前後増える）。
2. **狭い画面（600px以下）で固定をやめるか**：案7の先取りになる。(a) 今回は入れない（推奨：1・2の結果を見てから）。(b) 今回入れる。

参照したキャッシュ：なし。

<a id="astra応答と第2依頼案35の限定実装"></a>
## Astra response and second assignment: proposals 3/5

Received the correction to proposal 2's effects. Awaiting user answer on fixing proposal 1's current-work line; defer 7 and do not implement 1/2 before that answer. Implement independent proposals 3/5 instead.

- 3: shorten missing-start display to 「開始：不明」; retain 「記録範囲外または未記録」 in existing title/detail. Unknown must not become success or unstarted.
- 5: reproduce hover-then-wheel residue in test-only headless first, then close tooltip on page/map scroll or leaving the area. Verify it reappears with hover enabled and preserves OFF/click selection.

Editing occupancy: index.template.html, test-work-lane.cjs, new test-tooltip-scroll.cjs, relevant README, 「姫第2Return」 and proposal-3/5 evidence under Current/Evidence/OPS-126/. No server implementation/active server/real data/other canonicals. Independent server, isolated Inbox and headless are allowed; saves/approvals use mock data only. Close processes/clean temporary areas afterward. No commit.

Write a brief Return breakdown then proceed within scope without renewed confirmation. Run existing activity/approval/work-lane tests and sync/check. Retain before/after screen evidence and reproducible steps. No external packages/general testing platform. Await next bounded assignment afterward.

## 姫第2Return

2026-10-18〜19 姫・Opus 5.5。開始HEAD `e39bee1d4`。commitなし。使用中サーバー（8088）・ユーザーのブラウザ・実データには触れていない。保存・承認・更新の操作はしていない。

作業内訳（着手時に記入）：案5の再現→修正→検査、案3の短縮、前後のheadless証拠、既存試験・sync・`--check`。

### 案5（スクロール後のホバー説明）

- **再現の結果**（修正前、WebKit・Chromiumのheadless、試験専用サーバー＋空のInbox）：
  - マウスのホイール、PageDown、Space、スクリプトでのスクロールのどれでも、説明は**残り続けなかった**（`before.json`、`before-variants.json`）。
  - 待ち時間を細かく測ると、ページのスクロール後0〜50msは見えていて、100msで消えた（`before-timing.json`）。ブラウザがスクロール後に出す擬似的なポインタイベントで閉じている。
  - OPS-125で「残っていた」と書いたのは、スクロールの直後に撮った一瞬の像だった。**私の観察の誤り**で、残るのは100ms未満の一瞬だけ。
- **修正**（`index.template.html`、1行＋注記）：ページがスクロールしたら、説明（`#graphTip`）を即座に閉じる（`window`の`scroll`、passive）。ブラウザの擬似イベントに頼らなくなる。
  - verifyの倍率の検査が、`window`のない環境でこの範囲を実行するので、`typeof window`で守った（verifyは編集範囲外のため変えていない）。
- **修正後**（`after-timing.json`、`after.json`）：
  - 0ms時点で閉じている。
  - ホバーでまた出る。見取り図の外へ出ると閉じる。表示OFFでは出ない。クリックで選択できる。
  - ページのエラーは0件。
- **検査**：新規`test-tooltip-scroll.cjs`。実際の1行を、擬似のwindowで実行する。スクロールで閉じること、passiveであること、既存の閉じる経路とOFF設定が残っていることを確かめる。

### 案3（開始不明の短縮）

- カードの4行目を「開始：不明」にした。カードの説明（title）には「開始：不明（記録範囲外または未記録）」と理由を残した。不明を成功や未着手に置き換えてはいない。
- `test-work-lane.cjs`の期待値を直し、カードの文字とtitleの両方を検査するようにした。READMEの該当文も直した。
- 実画面（`after.json`の`lane`、`after-top.png`）：OPS-125のカードは「開始：不明」、titleに理由がある。requestが見えるOPS-126は「依頼 10/18 21:12:24」のまま。

### 試験

- `test-tooltip-scroll.cjs`・`test-work-lane.cjs`・`test-activity.cjs`・`test-approvals.cjs`・`test-work-progress.cjs` PASS。`test-*.py` 3件 OK。
- sync（verify通過）、`--check`差分なし。

### 証拠（`Current/Evidence/OPS-126/`）

- 再実行できる手順：`check.cjs`（ホバー・ホイール・再表示・外へ出る・OFF・クリック・レーン）、`variants.cjs`（スクロール方法の違い）、`timing.cjs`（待ち時間ごと）。使い方は`check.cjs`の先頭に書いた。試験専用サーバーは`REGISTRY_STUDIO_INBOX=$(mktemp -d) python3 -B Maintanance/RegistryApp/serve.py --port 18933`。
- 結果：`before*.json`・`after*.json`と、スクリーンショット5枚。
- 試験用サーバーとブラウザは終了済み（プロセス0件）。一時ディレクトリは削除済み。

### 限界

- Safariの実機と実際のマウスでは見ていない。
- 「残り続ける」不具合は再現しなかった。修正は、100ms未満の一瞬の残りを消すものにとどまる。

参照したキャッシュ：なし。


<a id="astra第2受入とユーザー回答2026-10-19"></a>
## Astra second acceptance and user answer (2026-10-19)

Accepted 3/5 within bounds after comparing actual changes/before-after records and independently passing tooltip/work-lane/activity/approvals/work-progress tests and sync --check. Browser measurements rely on Hime's evidence, not Astra reruns. Proposal 5 removes a momentary delay rather than an indefinitely stuck tooltip; retain the corrected observation.

Under 「迷ったら姫によせといて」「ビジュはねぇ」, favor Hime's visual recommendation. For 1, scroll all activity normally while fixing title/operations. Reassess narrow-screen unfixing (7) afterward. Do not extend this visual delegation to save contracts, authority or process.

<a id="第3依頼案12の限定実装"></a>
## Third assignment: proposals 1/2

Follow the first response's breakdown: fix title/operation row, moving explanation/current work/event strip immediately afterward in normal flow. Measure header height for scroll clearance and follow wrapping/notification toggles. Notification may remain fixed, but sticky elements still occupy normal-flow height; 「本文位置が変わらない」 is unverified, so measure toggles too. Do not add unnecessary automatic scroll correction.

Occupancy: RegistryApp/index.template.html, new RegistryApp/test-header-layout.cjs, relevant RegistryApp/README.md, Hime's third Return, and only Current/Evidence/OPS-126/header-check.cjs, header-results.json, header-wide.png, header-narrow.png. Preserve old Returns and 3/5 evidence; return reasons for other needed files.

At 1400×900, 390×844 and 900px widths, use independent headless to check fixed height, difference-panel destination, notification toggles, scrolling during activity updates and activity display/operations after returning to top. No active-server/user-screen/real-data interaction; mocked API or isolated server, with saves/approvals on mock data only. No installations; close/clean test environments. Run related tests and sync/check. Astra handles commit; do not commit.

Write bounded breakdown and proceed without renewed confirmation. Notify OPS-126 work/return; await next assignment.

## 姫第3Return

2026-10-19 姫・Opus 5.5。開始HEAD `e39bee1d4`（案3・5は未commitのまま、その上に重ねた）。commitなし。使用中サーバー（8088）・ユーザーの画面・実データには触れていない。試験専用サーバー（ポート18934、空の一時Inbox）だけを使った。操作は「変更内容を見る」（表示だけ）のみで、保存・承認・更新はしていない。

作業内訳（着手時に記入）：(1) HTMLの分割、(2) CSS、(3) 高さの実測、(4) 試験・実測・README。

### 変更

- `index.template.html`
  - `.header-note`・`.activity-current`・`.activity-timelines`を、`<header>`の直後の`<section class="header-info" aria-label="作業の状況">`（通常スクロール）へ移した。`<header>`に残したのは`.header-row`（題名・操作）と`#canonicalNotice`だけ。IDは変えていない。
  - CSS：`.header-info`に背景と余白を付けた（600px以下は左右12px）。`html{scroll-padding-top:var(--sticky-h,0px)}`を足した。
  - JS：`ResizeObserver`で`<header>`の実測の高さを`--sticky-h`へ入れる。`ResizeObserver`がない環境では何もしない。自動のスクロール補正は入れていない。
- 新規 `test-header-layout.cjs`：固定・通常スクロールそれぞれの要素の所属、IDの重複なし、stickyの維持、余白と実測、スクロール補正なし、レーンがヘッダーの外にあること。
- `README.md`：「画面上部の固定（OPS-126）」の節。

### 実測（`Evidence/OPS-126/header-check.cjs` → `header-results.json`、WebKit headless）

| 幅 | 固定部分の高さ（前→後） | `--sticky-h` | 下へ移動したカードの上端 | 差分パネル | 活動の更新中のscrollY | 先頭の活動帯 |
|---|---|---|---|---|---|---|
| 1400×900 | 183px → 55px | 55px | 55（ヘッダー下端55）・見える | 下に来る | 1200→1200 | 見える・横スクロール可・フォーカス可 |
| 900×900 | → 55px | 55px | 55・見える | 下に来る | 1200→1200 | 同上 |
| 390×844 | 約280px → 125px | 125px | 125・見える | 下に来る | 1200→1200 | 同上 |

- 「前」の183px・約280pxは、OPS-125作成時の実測。
- スクロール後も、ヘッダーは上端（top 0）に固定されたまま。ページのエラーは3つの幅とも0件。
- **通知の開閉**：通知を開くと固定部分が高くなる（1400・900幅で55→201px、390幅で125→358px）。`--sticky-h`も追従し、閉じると戻る。ただし、stickyの要素も通常の流れの高さを持つので、**通知を開いた分だけ本文が下へずれる**（146px／233px）。第1回答の「固定に残せば本文はずれない」は誤りで、ここで訂正する。依頼どおり、自動の補正は加えていない。通知は通常は出ないもので、今回はスクリプトで開いて測った。
- スクリーンショット：`header-wide.png`（1400幅で見取り図までスクロール）、`header-narrow.png`（390幅）。

### 試験

`test-header-layout.cjs`・`test-tooltip-scroll.cjs`・`test-work-lane.cjs`・`test-activity.cjs`・`test-approvals.cjs`・`test-work-progress.cjs` PASS。`test-*.py` 3件 OK。sync（verify通過）、`--check`差分なし。試験用サーバーとブラウザは終了済み（プロセス0件）。一時ディレクトリは削除済み。

### 限界・残り

- Safariの実機では見ていない。
- 390幅でも、ボタンが2行に折り返して125pxある。案7（狭い画面で固定をやめるか）の判断材料になる。
- 通知を開いたときの本文のずれは残る。ずらさないためには、通知を固定の外の上部（流れの中）へ出すか、閉じるまで重ねて表示する、などの別の判断が要る。

参照したキャッシュ：なし。


<a id="astra第3受入2026-10-19"></a>
## Astra third acceptance (2026-10-19)

Accepted 1/2 after comparing changes, measurement script and three-width results. Independently passed header-layout/approvals/work-lane. Headless results rely on Hime's evidence: fixed height 55px normally/125px at 390, unchanged scrollY during activity updates and visible cards. Notification-induced body movement follows existing normal flow; do not claim 「ずれなし」. The third Return's alternative 「固定の外の流れへ出せばずれない」 also lacks assurance because normal-flow height still changes; do not adopt it. No notification redesign added.

<a id="第4依頼案46の限定実装と案78の短い相談"></a>
## Fourth assignment: proposals 4/6 and brief consultation on 7/8

4: show local-map card titles in at most two lines, retaining full text through existing explanations/inspector. Preserve center selection, left/right connections, edges and selection operations.
6: put version/intermediate-card editing under initially closed 「版・中間カードの編集」 disclosure. Retain input, open state and unsaved warnings across tab switches/redraw. No save-contract/addition changes.

Scope: RegistryApp/index.template.html, RegistryApp/README.md, new RegistryApp/test-usability-cards.cjs, Hime's fourth Return, and only Current/Evidence/OPS-126/cards-check.cjs, cards-results.json, cards-view.png. Return minimum scope before changing existing tests; do not overwrite returns/evidence.

Write brief breakdown and proceed without renewed confirmation. Check related tests/sync/check plus isolated headless long titles, click selection, disclosure and input→tab away/back/redraw retention. No real user screen/data/active server; mocked or isolated only. Close processes/clean temporary files; no commit; work/return notification.

For 7, briefly report remaining problems/recommendation at 390 width. For 8, propose minimum line-concentration improvement/invariants only, no implementation. Discuss both in fourth Return, then await next bounded assignment.

## 姫第4Return

2026-10-19 姫・Opus 5.5。commitなし。使用中サーバー・ユーザーの画面・実データには触れていない。試験専用サーバー（ポート18935、空の一時Inbox）だけを使った。保存・承認・更新はしていない。入力欄に打った文字は、適用していない。

作業内訳（着手時に記入）：(1) 読む、(2) 案4、(3) 案6、(4) 試験・実測・README、(5) 案7・8の相談。

### 案4：局所図の題名を2行に（`index.template.html`）

- 原因は、題名を`.slice(0,16)`で16文字に固定で切っていたこと（カード幅210px）。
- `twoLineTitle(text,width,measure)`（純粋関数）で、文字幅を測って2行まで折り返す。入りきらない分は「…」で切る。canvasで測れない環境では、文字数からの見積もりを使う。
- 全文は、カードの`<title>`（ホバーの説明）、中心の見出し、インスペクタで読める。
- カードの大きさ・配置・辺・クリックでの選択は変えていない。

### 案6：計画の編集欄を折り畳みに（`index.template.html`）

- `renderPlanTools`の中身を`<details id="planToolsDetails">`に入れ、最初は閉じた状態にした。見出しは「版・中間カードの編集（マイルストーン計画・編集版の案）」。
- 開閉状態は`renderPlanTools.open`に覚えるので、再描画をまたいで残る。
- 閉じていても、入力途中なら「入力途中あり」、計画の変更があれば「計画の変更N件」が見出しに出る。開閉したときに見出しも更新する。
- 入力の値は、既存の`planDraft`から戻る（従来どおり）。保存契約・追加処理は変えていない。

### 試験・実測

- 新規`test-usability-cards.cjs` PASS。確かめた内容：
  - 短い題名は1行、長い題名は2行で「…」、各行が幅に収まる、ちょうど2行なら「…」なし、空。
  - 固定の16文字切りがないこと。全文の`<title>`。クリックで選択。
  - 折り畳みの初期状態と状態の保持、見出しの注記、入力欄と値の復元。
- 既存：`test-header-layout`・`test-tooltip-scroll`・`test-work-lane`・`test-activity`・`test-approvals`・`test-work-progress`（.cjs）PASS、`.py` 3件 OK。sync（verify通過）、`--check`差分なし。
- headless（`Evidence/OPS-126/cards-check.cjs` → `cards-results.json`、`cards-view.png`）：
  - DOC-027：「Swift Package Index公開導線のR／EADME・Pages反映」、一番長い行177.6px（カード210px、使える幅190px）。DOC-026も2行。MS-SPIは1行。
  - 側のカード（DOC-026）を押すと、中心がDOC-026へ移る。
  - 計画の編集欄：最初は閉じている→開いて入力→タブを切り替えて戻る→カードを押して再描画、のどこでも開いたままで、入力が残る。閉じると見出しに「入力途中あり」。ページのエラーは0件。
- 試験用サーバー・ブラウザは終了済み（プロセス0件）。一時ディレクトリは削除済み。

### 限界

- 折り返しは1文字単位なので、英単語の途中で切れる（「R／EADME」「packag／e」）。本図のカードも同じ方式なので、今回はそろえた。単語の切れ目を優先するなら、本図と一緒に別の小さな変更になる。
- Safariの実機は未確認。

### 案7の相談（390幅）

- 今回までで残っている支障は3つ（`header-results.json`、OPS-125の`9-narrow.png`）。
  - 固定部分が125px（画面の約15%）。ボタンが2行に折り返すため。
  - 見取り図のタブが3行に折り返す。
  - 「最近の作業」のカードは1枚がほぼ画面幅で、横スクロールが必要。
- 推奨：600px以下では、題名とボタンを**1行の横スクロール**にする（固定は55〜60px程度の見込み、未測定）。固定そのものをやめる案より、操作がいつでも届く利点を残せる。ホバーには頼らない。タブの折り返しは、同じ1行の横スクロールで扱える。

### 案8の相談（到達点への線の集中、実装しない）

- 現状：`graph()`の辺の描画は、線の終点をいつも受け側カードの左端の中央（`v+H/2`）にしている。一つの到達点へ前提が何本も入ると、1点に集まる。
- 最小の変更案：受け側カードごとに、入ってくる線を始点の縦位置の順に並べ、終点を左端の上下に等間隔でずらす（`v+H*(k+1)/(n+1)`）。2本以上のときだけ。出ていく線の始点も同じように扱える（任意）。
- 守る不変条件：
  - カードの位置（`graphLayout`の`pos`）は変えない。valid()・fallbackの判定にも触れない。
  - 線の両端のカード、向き（左から右）、矢印、点線（PARALLEL_JOIN）は変えない。
  - 縦の線（同じ列の上下）は対象外。
  - OPS-096・116の配置試験と、線の網羅・重複の検査（OPS-092のedge-audit）がそのまま通ること。
- 確かめ方：変更前後のSVGで、到達点ごとの終点の重なり数を数える。headlessで50%表示のスクリーンショットを並べる。

参照したキャッシュ：なし。


<a id="astra第4受入残案の決定2026-10-19"></a>
## Astra fourth acceptance and remaining choices (2026-10-19)

Accepted 4/6, comparing changes/cards-results.json and independently passing usability-cards/header-layout/work-lane/sync --check. Headless relies on Hime's evidence. Retain mid-word wrapping as a current limit rather than extending repairs.

Within the visual delegation, choose horizontally scrolling controls/tabs at ≤600px for 7; for 8, try spreading incoming endpoints only. No outgoing spread. Return without implementation if card placement or connection meaning would change.

<a id="第5依頼案78の限定実装最終区切り"></a>
## Fifth assignment: proposals 7/8, final stage

7: ≤600px, place title/operations and tabs in single horizontally scrollable rows. Reach end controls with visible keyboard focus; return to ordinary layout on widening. Leave an affordance for scrolling. No save operations/contracts changed.
8: when at least two left-to-right edges enter one card, spread endpoints vertically on its left edge in source-height order, with stable ID or equivalent tie-break. Retain single edges, same-column vertical edges, card positions, actual endpoints/directions/types and click selection. Do not change outgoing side or redesign layout rules.

Scope: RegistryApp/index.template.html, RegistryApp/README.md, new RegistryApp/test-usability-final.cjs, Hime's fifth Return and only Current/Evidence/OPS-126/final-check.cjs, final-results.json, final-wide.png, final-narrow.png. Return minimum scope before existing-test edits.

After brief breakdown, proceed within scope without renewed confirmation. Run existing placement/edge-audit/related UI tests and sync/check. Independent headless checks 390/normal widths and transitions, keyboard access, unchanged endpoint counts/connection ID sets, spread multiple destinations and unchanged single/vertical edges. Save visual evidence. Use only isolated environments, no real data/server/user screen; close/clean afterward. No commit. Return a brief implementation/limit list for all eight; do not automatically start more work. Notify work/return.

## 姫第5Return

2026-10-19 姫・Opus 5.5。commitなし。使用中サーバー・ユーザーの画面・実データには触れていない。試験専用サーバー（ポート18936、空の一時Inbox）だけを使った。保存・承認・更新はしていない。

作業内訳（着手時に記入）：(1) 案7のCSS、(2) 案8の終点分散、(3) 試験・実測・README・既存試験。

### 案7：狭い画面の1行横スクロール（`index.template.html`）

- 600px以下だけ：題名・操作の行と見取り図のタブを、折り返さない1行の横スクロールにした。フォーカスの枠（操作の行は金色、タブは緑、内側に2px）を付けた。601px以上は今までどおり折り返す。
- 実測の途中で、Chromiumではキーボードでフォーカスした最後のボタンが右に75pxはみ出したままだった（最大318まで動かせるのに243で止まる）。行がはみ出しているときだけ、フォーカスした操作を`scrollIntoView({block:'nearest',inline:'nearest'})`で全部見せる処理を足した。
- 保存の操作・契約は変えていない。

### 案8：同じカードへ入る線の終点を分ける（`index.template.html`）

- `graph()`の中に`edgeEntryOffsets(edges,pos,H)`を足した。左から右へ入る線が同じカードに2本以上あるとき、始点の縦位置の順（同じならIDの順）で、終点を左端の上下に等間隔（`H*(k+1)/(n+1)`）に置く。曲線の最後の制御点も同じ高さにする。
- 1本だけの線・同じ列の縦の線・カードの位置・線の両端・向き・線の種類・クリックでの選択は変えていない。出ていく側は変えていない。
- edge-audit（OPS-092）は`function graph(`から先だけを切り出して実行するので、補助関数は`graph()`の中に置いた。最初は外に置いて落ちたので、直した。

### 試験・実測

- 新規`test-usability-final.cjs` PASS。確かめた内容：
  - 3本＋同じ高さの2本が、順番どおり等間隔になる。カードの内側に収まる。
  - 1本・縦の線・未配置の線は対象外。入力の順に依存しない。
  - 経路が新しい終点を使う。縦の経路は変わらない。
  - 600px以下の規則とフォーカスの枠。広い画面は折り返しのまま。フォーカスの処理。
- 既存：`test-usability-cards`・`test-header-layout`・`test-tooltip-scroll`・`test-work-lane`・`test-activity`・`test-approvals`・`test-work-progress`（.cjs）PASS、`.py` 3件 OK。配置：OPS-096 `layout.cjs` ALL PASS、OPS-095 `placement.cjs`（45件・9表示、問題0）、OPS-092 `edge-audit.cjs`・`display-partition.cjs` 違反0。sync（verify通過）、`--check`差分なし。
- headless（`Evidence/OPS-126/final-check.cjs` → `final-results.json`（WebKit）・`final-results-chromium.json`）：
  - **線**：表示中の39本すべてに経路が1本ずつある。カードの移動0。
    - 2本以上が入るカード6か所：6か所とも、終点が別々で、カードの内側、始点の順。例：GATE-0.7.0は7本、GATE-0.8.0は6本。
    - 1本の7か所：中央のまま。縦の5本：今までどおり。
    - クリックで選択できる。
  - **幅**：
    - 1400幅：固定部分は55px。折り返しのまま。
    - 390幅：58px（Chromium 61px）。行とタブが1行の横スクロールになる。前回の125pxから下がった。
    - 1400幅へ戻すと、折り返しに戻る。
  - **キーボード**：操作の行は最初から最後のボタン（`#restart`）まで届き、全部見える。枠は実線2px。タブは矢印キーで「接続を見る」まで届き、見える位置にある。WebKitはmacOSの既定でボタンへOption+Tabで移るので、それで測った。Chromiumは、補正を足した後に全部見えることを確かめた。
  - ページのエラーは0件。
- スクリーンショット：`final-wide.png`（50%表示）、`final-narrow.png`（390幅）、Chromium版の2枚。
- 試験用サーバー・ブラウザは終了済み（プロセス0件）。一時ディレクトリは削除済み。

### 8案の実施と制約（一覧）

| 案 | 状態 | 制約・残り |
|---|---|---|
| 1 固定ヘッダーを題名・操作だけに | 実施（第3回） | 通知を開くと本文が下へずれる（通常フローの結果） |
| 2 移動先の余白 | 実施（第3回） | 実測の高さに追従。効く場所は差分パネル・フォーカス・ページ内検索 |
| 3 開始：不明 | 実施（第2回） | 理由は説明（title）に残る |
| 4 局所図の題名2行 | 実施（第4回） | 1文字単位の折り返しなので、英単語の途中で切れる |
| 5 スクロール後の説明 | 実施（第2回） | 残り続ける不具合は再現せず、100ms未満の一瞬の残りを消す改善 |
| 6 計画の編集欄の折り畳み | 実施（第4回） | なし |
| 7 狭い画面の1行横スクロール | 実施（今回） | WebKitのボタン移動はmacOS既定でOption+Tab |
| 8 入る線の終点の分散 | 実施（今回） | 出ていく側は変えていない |

全体：Safariの実機は未確認。次の作業は始めていない。

参照したキャッシュ：なし。


<a id="astra最終受入2026-10-19"></a>
## Astra final acceptance (2026-10-19)

Accepted 7/8, completing staged implementation of all eight. Compared changes/final-check.cjs/both-browser results; independently passed usability-final/usability-cards/activity/approvals/header-layout, sync including verify and --check. Actual screen measurements rely on Hime's evidence, not Astra browser reruns. Card positions/connection meaning unchanged. Narrow fixed height: WebKit58px, Chromium61px. Real Safari unverified; notification-toggle movement and mid-word wrapping remain limits.

The user's additional 「差し戻し」→「返却」 was absent from fifth Return, so Astra afterward updated activityLabels.return, README event explanation and test-activity expectations. Internal key return/history unchanged. The extra-assignment section vanished when fifth Return was updated; restore the user decision/repair history here. Future extra instructions after an in-progress Return may also disappear on return; watch for this.

Technical acceptance complete; awaiting commit approval. Several stages accumulated in this file, adding evidence outside initial cards. Cancel unused stage approvals and consolidate into one explicitly listing all targets. Do not reuse existing approval for unapproved scope.

<a id="完了記録2026-10-19"></a>
## Completion record (2026-10-19)

Confirmed consolidated approval 91e683eabb1c4d69815278d605d8dd53 is approved. Compare all technically accepted targets and include OPS-126 DONE in the same commit. No additional assignment.
