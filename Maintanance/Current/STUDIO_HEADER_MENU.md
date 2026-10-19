# 左上メニューへの操作集約

## TL;DR（人間向け）

右側の5操作を左上の「メニュー ▾」へまとめます。保存結果・未保存表示とコミット承認は、メニューを開かなくても見えるように残します。

<a id="姫への依頼"></a>
## Assignment to 姫

OPS-136 / 2026-10-19 / Astra. User requested an upper-left dropdown and moderate delegation to 姫. No start reconfirmation. Input implementation 698e2673; retain OPS-135 top-bar approval.

- Group 「編集結果を保存」「変更内容を見る」「更新」「JSONを開く」「正本から新しく始める」 in upper-left menu. Separate last operation by space/divider. Retain IDs/handlers/dialogs/save contract.
- Approval status/bulk approval, unsaved/save-result and canonical-difference notices stay visible when menu closed. Title may be subdued, need not disappear.
- Click/keyboard open/close, Esc returns to origin, outside click closes. Close after action selection without disrupting dialogs/file input/focus. No narrow-screen clipping, polling closure or stolen focus.
- Styling at 姫's discretion within scope; no graph/approval/save/communication/live-server changes.

Editable: index.template.html, relevant test-header-layout.cjs/test-usability-final.cjs, new test-header-menu.cjs, RegistryApp/README.md procedures, this 姫Return, Current/Evidence/OPS-136/ scripts/results/images. Return reasons for other needs. Registry/Rules/assignment remain Astra-owned. No commit.

Write short breakdown; implement, run regressions and isolated WebKit headless at 1400/390 for open/close, five operations and approval retention. Block/mock actual save/approval/sync APIs. Temporary server on independent port/Inbox only; clean it. No user-screen/live-server operations.

Notify start via activity; finish 「姫Return」 then reference-bearing return (next=Astra), wait continuously, end with WAKE/ACK after acceptance.

## 姫Return

返却（2026-10-19 姫・Opus 5.5、開始HEAD `698e2673b`）。内訳：(1) 見出しの行の左に「メニュー ▾」を置き、5つの操作（既存のIDと処理のまま）を開閉式の一覧へ移す。正本から新しく始めるは区切り線の下。承認の欄・`#status`・正本差分の通知はメニューの外のまま。(2) 開閉：クリック、Enter/Space、Escで閉じて起点へ、外側のクリックで閉じる、操作を選んだら閉じる（file inputとダイアログの動作を妨げないよう、閉じるのはクリック処理の後）。処理中はメニューのボタンに表示。(3) 狭い画面で行の横スクロールをやめる（ドロップダウンが切れるため）。(4) `test-header-menu.cjs`の新規作成、`test-header-layout`・`test-usability-final`の該当箇所、README。(5) 隔離headless（WebKit 1400/390）で開閉・5操作・承認欄・ポーリング中の保持を確認。

- 実装（`index.template.html`）：
  - 見出しの行は、左に`#headerMenuButton`（「メニュー ▾」）、右に控えめなタイトル（15px）。
  - `#headerMenu`の中の順番は、保存→変更内容→更新→JSONを開く→区切り線→正本から新しく始める。5つの操作はIDも処理も変えていない。
  - `createHeaderMenu`の動き：
    - ボタンで開閉し、`aria-expanded`も切り替える。
    - ボタンか一覧にフォーカスがあるときEscで閉じ、ボタンへ戻る。閉じているときのEscは横取りしない。
    - 外側をクリックすると閉じる。フォーカスは動かさない。
    - 操作を選ぶと、その操作の処理が終わった後で閉じる。フォーカスは、一覧の中か行き場がないときだけボタンへ戻す。
    - 処理中（一覧の中に無効のボタンがあるとき）は、MutationObserverでボタンを「メニュー（処理中） ▾」にする。
  - 足した点が1つある。「JSONを開く」は前からキーボードで届かなかった（labelで、inputは非表示）。これに`tabindex`を付け、Enter/Spaceでfile inputを開くようにした。
  - 狭い画面では、見出しの行を横スクロールしないようにした（スクロールさせるとドロップダウンが切れるため）。タブの行は従来どおり横スクロールする。
  - 承認の欄・`#status`・正本差分の通知の位置は変えていない。
- 試験：
  - 新規`test-header-menu.cjs`は、実関数をstubのDOMで動かす。開閉、Escとフォーカスの戻り、閉じたときのEsc、外側のクリック、背景のクリック、操作の後に閉じること、ダイアログのフォーカスを保つこと、file inputのEnter/Space、処理中の表示、HTMLの順番、外に残る要素を確かめる。
  - `test-usability-final.cjs`は、狭い画面の規則を「見出しの行は横スクロールしない」に直した。
  - `test-header-layout`・`ui-round2`・`handoff-signals`・`activity`・`approvals`・`tooltip-scroll`・`usability-cards`・`work-progress`（いずれもcjs）はPASS。
  - `sync.py`（verify.cjs込み）は完了し、`--check`でずれなし。
- **既存の不具合（直していない）**：`test-work-lane.cjs`88行目の「no separate approval section」が落ちる。HEAD `698e2673b`のテンプレートでも同じように落ちることを確認した。OPS-135で見出しに足した承認欄（`aria-label="コミット事前承認"`）と、古いOPS-119の検査がぶつかっている。今回の許可ファイル外なので触れていない。
- headless（`Evidence/OPS-136/check.cjs`、WebKit、隔離port 18942・一時Inbox・模擬API）：結果は`results.json`、画像は`wide-closed/open.png`・`narrow-closed/open.png`。
  - 位置：広い画面ではメニューが左上（x=28）、タイトルが右端。狭い画面ではメニューがx=12、一覧の右端が232pxで、画面からはみ出さない。
  - 閉じた状態でも、承認の欄（🔴 承認待ち1件と一括ボタン）が見える。
  - 開閉：外側のクリックで閉じる。Enterで開き、Tabで保存→変更内容→更新→JSONを開く→正本から新しく始めるの順に進み、Escで閉じてボタンへ戻る（2つの幅とも同じ）。
  - 一覧を開いてフォーカスを中に置いたまま、ポーリングを3.5秒待った。閉じず、フォーカスも保たれた。
  - 変更内容：一覧が閉じ、差分の欄が表示された。
  - JSONを開く：クリックでもEnterでもfilechooserが出た。
  - 保存：POSTを遮断した結果、`#status`（メニューの外）に失敗の表示が出た。
  - 更新：処理中はボタンが「メニュー（処理中） ▾」になり、終わると元に戻った。
  - 正本から新しく始める：既存のconfirmが出たので、キャンセルした。
  - POSTは保存とsyncの2件だけで、どちらも遮断した。承認のPOSTは0件。ページのエラーは0件。サーバーは終了し、一時データは削除した。
- 限界：
  - Chromiumは試していない。
  - スクリーンリーダーでの読み上げは試していない（disclosureの形で、role=menuにはしていない）。
  - 一覧の中で矢印キーは使えない（Tabで移動する）。
- commitなし。

<a id="ユーザー追記トップバーは一段2026-10-19"></a>
## User addition: one-row top bar (2026-10-19)

During implementation the user specified 「2列ではなく、一列にしてほしい」. Put left menu, subdued title and approval/bulk control in one horizontal row, not two vertical rows. At narrow width avoid clipping/inaccessibility; horizontal scroll as necessary. Never clip dropdown in scroll container. If abbreviated, keep full status accessible. Preserve approval synchronization and verify same-row placement/usability at wide/narrow widths. Included in this implementation/acceptance.

<a id="ユーザー追記2段目はタブ切り替え2026-10-19"></a>
## User addition: tabs on second row (2026-10-19)

User clarified 「というか2列目はタブ切り替えがいいんだよな」. Upper row is menu/title/approval; immediately below is existing tab switching with functions/selection preserved. Notices/work lane must not interrupt these two rows. Earlier 「一段」 requirement concerns operations/approvals, not all tabs in that row. Check narrow tab scrolling/non-clipped menu. Included in acceptance.

### 姫Return追記：トップバー一段（ユーザー追記への対応）

- 実装：
  - `.header-approval`を`.header-row`の中へ移し、メニュー→タイトル→承認欄（右寄せ）の1段にした。全幅で`flex-wrap:nowrap`。
  - はみ出したときに横スクロールするのは承認欄だけ。メニューの行はスクロール枠に入れていないので、ドロップダウンは切れない。
  - 狭い画面（600px以下）では、見出しの「コミット事前承認：」（`.header-approval-label`）を隠して状態を先に見せ、タイトルは13pxにした。グループの`aria-label="コミット事前承認"`は残した。
  - 既存のfocusinの処理の対象に`header .header-approval`を足した。承認欄の中のボタンにフォーカスが来ると、見える位置までスクロールする。
  - 承認の同期と処理は変えていない。
- 試験：
  - `test-header-menu.cjs`に「1段の順番」と「狭い画面で見出しを隠す」を足した。
  - `test-usability-final.cjs`の「広い画面は折り返す」は、ユーザーの指定と逆になったので「1段・承認欄が横スクロール」の確認に置き換えた。
  - 関連のcjsはすべてPASS（`test-work-lane`の既存の失敗は上に書いたとおりで、変わらず）。sync・`--check`も通った。
- headless（同じ`check.cjs`に1段の検査を追加して再実行。results.json・画像を更新）：
  - 2つの幅とも、行の高さは31px。メニュー・タイトル・承認欄が同じ段に収まる。
  - 広い画面：承認欄はx=1041〜1372で、スクロールしない。
  - 狭い画面：承認欄はx=228〜378。最初から「🔴 承認待ち 1件」が見え、一括ボタンは横スクロールの先にある。
  - キーボード：メニューからAlt+Tabで一括ボタンに届く。届くと承認欄がscrollLeft=194まで動き、ボタン全体が見える（`narrow-approval-focus.png`）。ボタンは操作可能な状態（disabled=false）。押してはいない。
  - メニューの開閉・5つの操作・ポーリング中の保持・処理中の表示は、前回と同じ結果。POSTは保存とsyncだけで、承認は0件。ページのエラーは0件。サーバーは終了し、一時データは削除した。

### 姫Return追記2：2段目はタブ切り替え（ユーザー追記への対応）

- 実装：
  - 見取り図のタブの一覧（IDとrole、`aria-controls`、切替処理はそのまま）を`<main>`から見出しの中へ移した。位置は1段目（メニュー・タイトル・承認欄）の直後で、`#canonicalNotice`より前。クラス`header-tabs`を足した。
  - 通知・説明文・作業レーン・`#status`は2段の下で、間には入らない。2段とも固定（sticky）で、スクロール余白は既存の実測（ResizeObserver）がそのまま追う。
  - 見出しの暗い背景で選ばれたタブが見えなくならないよう、見出しの中だけ色を変えた。選ばれたタブは白地に濃い緑の文字、ほかは透明で淡い文字、フォーカスの枠は黄色。
  - 足した点が1つある。狭い画面で一括ボタンにフォーカスすると承認欄が横へスクロールし、そのままでは状態が隠れていた。フォーカスが承認欄から出たら`scrollLeft=0`へ戻すようにした。
- 試験：
  - `test-header-menu.cjs`に4点を足した。タブが見出しの中にあり、1段目との間に閉じタグしかないこと。通知より前にあること。`main`にタブが残っていないこと。選ばれたタブの色。承認欄を出たときに戻ること。
  - 関連のcjsはPASS（`test-work-lane`の既存の失敗は変わらず）。sync・`--check`も通った。
- headless（`check.cjs`に検査を追加して再実行。画像は`wide-tabs.png`・`narrow-tabs.png`）：
  - 2つの幅とも、1段目の下端が43px、タブが53〜84（狭い画面は87）px、見出しの下端（＝説明文の始まり）が96（99）pxで、間に何も挟まらない。
  - タブ：狭い画面ではタブの行だけが横スクロールする。クリックで「カード一覧」に切り替わり、パネルも切り替わる。→キーで「接続を見る」へ移り、選択されて見える位置に来る。
  - メニューを開くと、一覧がタブより手前に出る（`elementFromPoint`で確認）。
  - 900px下へスクロールしても、見出しは上端に、タブは53pxに残る。
  - 承認欄からフォーカスを外すと`scrollLeft`が0に戻る。
  - メニュー・5つの操作・ポーリング中の保持は、前回と同じ結果。POSTは保存とsyncだけで、承認は0件。ページのエラーは0件。サーバーは終了し、一時データは削除した。
- 限界：
  - 2段を固定したので、上に固定される高さが約96px（狭い画面は99px）になった。
  - Chromiumは試していない。
- commitなし。

<a id="ユーザー追記作業タブへ切り出す2026-10-19"></a>
## User addition: separate work tab (2026-10-19)

User proposed 「ページ情報上部にあるものを、作業タブに切り出しかな」. Astra's interpretation: group recent work, owner presence, work text strip, approval details/history and related work areas in a new 「作業」 tab. Top-bar approval status/bulk remains permanent. Do not hide save/unsaved/refresh/restart notices there. Use existing tabs; continue hidden-area updates and same-controller approval sync. No independent feature/server change. Before implementation append area breakdown to Return, then continue within placement scope. Add isolated tab/work-update/top-approval checks; necessary related-test changes allowed. Astra checks final commit scope.

### 姫Return追記3：作業タブ（内訳、実装前）

- 「作業」タブへ移すもの：
  - `.activity-current`（現在の作業の2行）。
  - `.activity-timelines`（作業イベントの札の帯）。
  - `.approval-lane.work-lane`の全体。中身は最近の作業のカード、担当ランプ、承認の詳細（個別承認・取消・履歴）、疎通確認の折りたたみ。
- 移さないもの：
  - 見出しの2段（メニュー・タイトル・承認状態と一括承認、タブ）と`#canonicalNotice`。
  - `#serverRestartNotice`（見出しより上）と`#status`（保存・更新の結果）。
  - 説明文`.header-note`は見出しの下に残す。保存の説明であって、作業の情報ではないため。
- 仕組み：
  - タブは`MAP_TABS`に`'work'`を足すだけで、既存の切替（クリック・矢印・Home/End）に乗る。既定のタブは依存の見取り図のまま。
  - 隠れているパネルでもポーリングとDOMの更新は続く。承認の表示は既存の同じcontrollerで、見出しとレーンが同期する。
  - 札の帯は暗い色前提の配色なので、パネルの中では暗い帯（`.work-activity`）に入れて配色を保つ。
- 試験：
  - `verify.cjs`のタブ切替の検査に`workView`・`workTab`を足す。ないと`$`がundefinedを返して落ちる。
  - `test-header-layout.cjs`の「info節にある」という検査を「作業パネルにある」へ直す。
  - `test-header-menu.cjs`に作業タブの検査を足す。headlessで、タブ切替、隠れている間の更新、承認の同期を確かめる。

### 姫Return追記3：作業タブ（結果）

- 実装：
  - 内訳のとおり、`.activity-current`・`.activity-timelines`（暗い帯`.work-activity`に入れた）と`.approval-lane.work-lane`の全体を、新しい`#workView`へ移した。
  - タブの行の最後に`#workTab`「作業」を足した。`MAP_TABS`に`'work'`を足しただけで、クリック・矢印・Home/Endの切替は既存のまま。
  - `#workView`は、ほかのタブのパネルの直後（常に表示される「独立タスク」の節より前）に置いた。最初は`main`の末尾に入れてしまい、独立タスクより下に出たので直した。
  - `.header-info`には説明文だけを残し、`aria-label`を「編集版の説明」にした。
  - `#status`・`#serverRestartNotice`・`#canonicalNotice`・見出しの承認欄は、作業タブの外にある。
  - ポーリング・承認のcontroller・DOMの更新処理は変えていない。
- 試験の変更（関連する範囲だけ）：
  - `verify.cjs`のタブ切替の検査に`workView`・`workTab`を足した。
  - `test-header-layout.cjs`：info節の切り出しを説明文の節だけにし、作業の各IDは「作業パネルにある」へ直した。
  - `test-handoff-signals.cjs`：レーンの切り出しの終わりを`</main>`にした。
  - `test-header-menu.cjs`に4点を足した。作業タブが最後にあること、同じ切替を使うこと、パネルの位置と中身、外に残るもの。
  - 関連のcjsはPASS（`test-work-lane`の既存の失敗は変わらず）。sync（verify.cjs込み）・`--check`も通った。
- headless（`check.cjs`に検査を追加して再実行。画像は`wide-work.png`・`narrow-work.png`）：
  - 依存の見取り図を表示している間（作業パネルは非表示）に、新しい返却の記録を足し、承認を「承認済み」に変えた。4秒待つと、見出しはすでに「🟢 承認済み・Astra未処理 1件」になっていた。
  - その後、「接続を見る」から→キーで「作業」へ移ると、作業パネルが出た。新しいカードがあり、「現在」の行も新しい返却に変わり、ランプは「新着」。レーンの承認欄も見出しと同じ表示だった。
  - 2つの幅とも同じ結果。メニュー・5つの操作・1段目・タブの位置は前回と同じ。POSTは保存とsyncだけで、承認は0件。ページのエラーは0件。サーバーは終了し、一時データは削除した。
- 限界：
  - 札の帯の「最新に追従するスクロール」が、非表示のあいだ（幅0）にどう振る舞うかは、表示に戻った直後の見た目でしか確かめていない。
  - Chromiumは試していない。
- commitなし。

<a id="astra受入2026-10-19"></a>
## Astra acceptance (2026-10-19)

Accepted left menu, upper approval, immediately following tabs and work-tab separation. Independently passed header-menu/header-layout/usability-final/approvals/handoff-signals. Reviewed wide work screen/isolated results; hidden updates/sync rely on 姫 mock-API evidence. No live server/approval POST. Old work-lane 「承認aria-label全面禁止」 is inconsistent after top-bar approval; limited it to absence of a separate old lane. New reporting/reflection elements belong to later OPS-137 design.

<a id="ユーザー確定一列トップバーと作業タスク2026-10-19"></a>
## User decision: one-row top bar and work/tasks (2026-10-19)

Replace prior two-row arrangement. User confirmation 「そうそう」: one horizontal row with menu, subdued title, 「作業／タスク」 switching, approval/bulk. Move diagram/permanent/protection/card-list/neighborhood tabs back to tasks; work is a separate top-level area. Independent/requested/unnumbered/detail areas belong to tasks. Retain task selection on round trips; initially tasks. Save/unsaved/refresh/restart notices remain needed in both. Preserve save/approval/communication contracts. Test narrow access, keyboard, tab hierarchy, hidden updates and approval sync with isolated screens/regressions.

Additional 姫 assignment: edit this task's files, necessary related tests/evidence/README and own Return. Registry is Astra's. No commit. Short breakdown → limited implementation → tests → referenced return → continuous waiting. Keep prior acceptance as prior-placement history; accept this addition separately. OPS-137 elements received, but do not implement new reporting/reflection yet.

### 姫Return追記4：作業／タスク切替（内訳、実装前）

- 見出しの1列：メニュー →（控えめな）タイトル →「タスク｜作業」の切替（`role=tablist`の2つ、初期はタスク）→ 承認状態と一括承認（右端）。
- タスク側＝既存の`#workspace`全体：見取り図の5つのタブ（`main`の先頭へ戻す）、各パネル、独立タスク・依頼中・採番待ち・詳細など。
- 作業側＝新しい上位の領域`#workArea`（`#workspace`と並ぶ兄弟）：現在の作業の2行、イベントの帯、最近の作業のレーン（承認の詳細・履歴・疎通確認を含む）。
- 切替はDOMを残したまま`hidden`を切り替えるだけ。タスク側の選択・スクロール以外の状態・入力は往復しても残る。隠れている間もポーリングは続く。
- 両方で見えるもの：`#serverRestartNotice`、見出し（承認欄を含む）、`#canonicalNotice`、説明文、`#status`。
- 狭い画面：1列に収めるため、600px以下ではタイトルを隠す（いちばん重要度が低いため）。承認欄は従来どおり横スクロール。
- キーボード：上段の切替は←→/Home/Endで動き、既存の見取り図タブと同じ作法。
- 試験：
  - `MAP_TABS`から`work`を外し、`verify.cjs`に足した`workView`・`workTab`も戻す。
  - `test-header-menu`・`test-header-layout`・`test-handoff-signals`の該当箇所を直す。
  - headlessで、切替、往復しても選択が残ること、隠れている間の更新、承認の同期、狭い画面での到達を確かめる。

<a id="ユーザー追記左の3ボタンを同寸法2026-10-19"></a>
## User addition: equal-size left three buttons (2026-10-19)

「メニュー、タスク、作業はボタンサイズ同じで並べておいて」. Adjacent menu/tasks/work left-to-right with equal width/height; no intervening title. Keep menu disclosure/top-level tab roles and distinguish selection. Busy label must not change menu dimensions. Check wide/narrow dimensions/usability in isolated tests.

<a id="ユーザー最新配置上段はタスク作業メニューはタスク側2026-10-19"></a>
## Latest user placement: tasks/work above, menu in tasks (2026-10-19)

Replace three-button plan with user directions 「RegistryStudioの文字は水平位置真ん中」 and 「メニューってタスクにしかかかってないから、トップバーはタスクと作業の2ボタンでいいかも」. Equal tasks/work buttons left, Registry Studio centered, approval/bulk right. Move menu into tasks; retain five actions/opening/focus/save contract. Prioritize operations on narrow screens; title may hide. Center title must not overlap controls. Supersedes upper menu/tasks/work trio and incorporates prior centered-title idea. No extra features; apply before return if still pending.

### 姫Return追記4：作業／タスク切替（結果）

- 実装（`index.template.html`）：
  - 見出しの1列に`.header-area-tabs`（`#taskAreaTab`「タスク」・`#workAreaTab`「作業」、`role=tablist`）を足した。並びはメニュー→タイトル→切替→承認欄。
  - 見取り図の5つのタブは`main`の先頭へ戻した。クラスも元に戻し、`MAP_TABS`は5つのまま。
  - 作業のパネルを、上位の`#workArea`（`#workspace`の直前の兄弟、`role=tabpanel`）にした。`#workspace`にも`role=tabpanel`を付けた。
  - `switchArea`と`AREA_TABS`は、既存の`switchMap`と同じ形にした。クリック・←→・Home/End、`aria-selected`・`tabIndex`の切替。
  - `.layout{display:grid}`が`hidden`に勝ってしまうので、`#workspace[hidden],#workArea[hidden]{display:none}`を足した。
  - 狭い画面ではタイトルを隠し、切替ボタンと一括ボタンの余白を詰めた。この規則はstyleの末尾に置いた。初めは前に置いたため、後ろの通常の規則に負けて効いていなかった。headlessの値で気づいて直した。
  - `verify.cjs`は、前回足した`workView`・`workTab`を戻して元どおり。
- 試験：
  - `test-header-menu.cjs`は、前回の「2段目・作業タブ」の検査を新しい構成に置き換えた。1列の順番、初期はタスク、見出しに見取り図のタブがないこと、`main`の先頭のタブ、作業領域の位置と中身と外に残るもの、`hidden`の上書き、狭い画面の規則とその順番を確かめる。`switchArea`の実コードをstubで動かし、クリック・→で一周・End・フォーカスも確かめる。
  - `test-header-layout`・`test-handoff-signals`は、切り出しの範囲を`#workArea`〜`#workspace`に直した。
  - cjsの11本すべてPASS（`test-work-lane`は、Astraが受入のときに直したので通るようになった）。sync（verify.cjs込み）・`--check`も通った。
- headless（`check.cjs`の作業タブの検査を置き換えて再実行。画像は`wide-task/work.png`・`narrow-task/work.png`ほか）：
  - 2つの幅とも、行の高さは31pxで、メニュー・切替・承認欄が同じ段にある。タイトルは広い画面だけに出る。見出しの下端は55px。
  - 見取り図のタブは`main`の中で、広い画面は143px、狭い画面は130pxから始まる。初期はタスク側で、作業側は非表示。メニューの一覧は内容より手前に出る。
  - タスク側で「カード一覧」・選択中のtask（GRAPH-001）・入力中の値を作った。その状態のまま、新しい返却の記録と承認の状態変化を足し、4秒待った。見出しは「🟢 承認済み・Astra未処理 1件」。
  - →キーで作業側へ切り替えると、新しいカードと「現在」の行があり、レーンの承認欄も見出しと同じ表示だった。Homeでタスク側へ戻ると、カード一覧・選択・入力値がすべて残っていた。
  - 狭い画面でも、一括ボタンにキーボードで届き、全体が見える。フォーカスを外すと承認欄は先頭へ戻る。
  - メニュー・5つの操作は前回と同じ結果。POSTは保存とsyncだけで、承認は0件。ページのエラーは0件。サーバーは終了し、一時データは削除した。
- 限界：
  - Chromiumは試していない。
  - 狭い画面ではタイトルが見えない（ユーザーの「控えめでよい」の範囲と判断したが、要るなら戻せる）。
- commitなし。

### 姫Return追記5：上段はタスク／作業、メニューはタスク側（ユーザー最新配置への対応）

- 実装：
  - 上段の`.header-row`をgridにした（`minmax(0,1fr) auto minmax(0,1fr)`）。左に「タスク｜作業」（2列gridで同じ幅、72px以上）、中央にタイトル、右に承認欄。左右の列が同じ幅なのでタイトルは中央に来て、操作とは重ならない。
  - メニュー（`#headerMenuButton`と一覧、IDも処理も同じ）は上段から外し、タスク側の`main`の先頭に置いた。見取り図のタブと並ぶ`.task-toolbar`の中。開閉・Esc・外側のクリック・操作後に閉じる・処理中の表示・file inputは変えていない。
  - 狭い画面では、タイトルを隠して2列（`auto minmax(0,1fr)`）にした。
  - 前回の「メニュー・タスク・作業の3つを並べる」配置は、この配置で置き換えた。
- 試験：
  - `test-header-menu.cjs`のHTMLの部分を新しい配置で書き直した。上段の順番、メニューが上段になくタスク側の見取り図のタブの前にあること、gridの指定、同じ幅、狭い画面の規則を確かめる。
  - `test-header-layout.cjs`は「5つの操作が固定の見出しにある」を「タスク側のメニューにある」に、`test-usability-final.cjs`は規則の文字列と狭い画面の目印を、それぞれ直した。
  - cjsの11本すべてPASS。sync（verify.cjs込み）・`--check`も通った。
- headless（`check.cjs`を新しい配置に合わせて更新・再実行）：
  - 広い画面：上段は27pxの1行。タスク・作業はどちらも72px、タイトルの中心と行の中心のずれは0px、重なりはない。承認欄は右端で同じ行。
  - メニュー：上段にはなく、見取り図のタブと同じ`.task-toolbar`の中にある（広い画面はy=110）。開くと一覧は画面に収まり、内容より手前に出る。Enter→Tab→Escと外側のクリックも、2つの幅とも前回と同じ。
  - 狭い画面：タイトルは非表示で、タスク・作業は56pxずつ。承認欄は状態も一括ボタンも見え、一括ボタンにはキーボードで届く。
  - 往復：タスク側の「カード一覧」・選択中のtask・入力中の値は、作業側を見て戻っても残る。隠れている間の更新と承認の同期も前回と同じ結果。
  - 5つの操作：保存は`#status`に結果、更新は「処理中」の表示、JSONを開くはクリックでもEnterでもfilechooser、正本から新しく始めるはconfirm（キャンセルした）、変更内容は差分の欄。
  - POSTは保存とsyncだけで、承認は0件。ページのエラーは0件。サーバーは終了し、一時データは削除した。
- 限界：
  - メニューは上に固定されないので、下へスクロールしたときは先頭へ戻る必要がある（ユーザーの「タスク側」の指定に従った）。
  - Chromiumは試していない。
- commitなし。

<a id="ユーザー最新指定作業が左初期表示も作業2026-10-19"></a>
## Latest user direction: work left and initially selected (2026-10-19)

Top-level switching is 「作業」「タスク」 left-to-right; initial display is work, superseding initial tasks. Preserve task selection/edits through round trips. Reflect in implementation/related tests.

### 姫Return追記6：作業が左・初期表示も作業

- 実装：
  - 上段の切替の順番を「作業｜タスク」にした（`#workAreaTab`が先で`aria-selected="true"`、`#taskAreaTab`は`tabindex="-1"`）。
  - 読み込み時は`#workArea`を表示し、`#workspace`を`hidden`にした。`AREA_TABS`は`[['work','workArea'],['task','workspace']]`で、←→/Home/Endもこの順番に従う。
  - そのほかは追記5のまま。
- 試験：
  - `test-header-menu.cjs`の順番・初期の選択・初期の`hidden`・`AREA_TABS`の検査を直した。stubでの切替の検査も、Home＝作業、End＝タスク、→で移ることに直した。
  - cjsの11本すべてPASS。sync（verify.cjs込み）・`--check`も通った。
- headless：
  - 2つの幅とも、読み込み直後は作業が選ばれていて、作業領域が表示され、タスク側は非表示。ボタンの並びは「作業」「タスク」。画像は`*-initial.png`。
  - 隠れたまま描かれたタスク側を開くと、見取り図はカード39枚・線39本で、カードの大きさは250×96。ズームも100%→125%に効いた。
  - 往復のときの選択・入力の保持、隠れている間の更新、承認の同期、メニュー、5つの操作、狭い画面は、追記5と同じ結果。POSTは保存とsyncだけ。ページのエラーは0件。サーバーは終了し、一時データは削除した。
- commitなし。

<a id="astra最終配置受入2026-10-19"></a>
## Astra final-placement acceptance (2026-10-19)

Accepted through Return addition 6: work left/initial, tasks right, centered title, task-side menu, selection/input retained. Independent header-menu/approvals PASS; inspected wide-initial screen. Compared narrow/round-trip/hidden-update evidence from 姫. Later visual emphasis/continuity checks managed separately.
