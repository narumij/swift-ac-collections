# Studio UI改善2周目（OPS-132）

## TL;DR（人間向け）

UI改善2周目で、作業カードの次担当・終了を見出し直下に示し、見取り図の操作欄をコンパクトにした記録。関連試験と隔離WebKitの広幅・狭幅証拠を基に受入し、WAKEへのACKを確認した。この記録時点では主要操作のメニュー化は保留で、長文はtitle属性に保持するがキーボード・タッチでの全文表示、実ユーザー画面・Chromiumは未確認。

2026-10-19. The user delegated 「UI改善2周目、連続」. Parent OPS-048. Astra coordinates and accepts; Hime observes and implements. The previous round was OPS-126; the target is the current state, including the later activity, approval and owner lamps.

<a id="要求境界"></a>
## Requirements and boundaries

Make everyday viewing, checking canonicals, editing and approving easier to see and operate. The user values visibility and wants waiting-for-approval, the next recipient and an end to be recognizable by colour and text. Prefer small, reversible improvements. Do not change the save / approval / authority / communication contracts, the meaning of tasks and connections, or the graph placement rules. Do not operate the real user screen or the server in use.

<a id="姫第1依頼現状確認と候補"></a>
## First request to Hime: current state and candidates

Check wide and narrow layouts with an independent headless browser, mocked APIs and a temporary Inbox, and propose at most 3 concrete difficulties that remain. Briefly write the flow of operation and phenomenon, the effect, a per-file breakdown and the verification method. Distinguish problems that are only guesses. Do not redo the previous full audit. Start only from the needed parts of the current index.template.html and the previous records.

No implementation at this break. Edits only to this document's 「姫第1Return」 and the check script, results and images in Current/Evidence/OPS-132/. End the work processes and clean the temporary data. No save, approval or sync calls against real data. No need to re-confirm the start; return with reference (next=Astra) and keep waiting continuously after returning. No commit.

Astra selects proposals and hands over a limited implementation in the next request. New decisions that existing policy cannot settle go back to the user. Continuous operation lasts until WAKE/ACK.

## 姫第1Return

返却（2026-10-19 姫・Opus 5.5）。確認には、隔離サーバー（port 18940・一時Inbox）とWebKitのheadlessを使った。画面幅は1400×900と390×844の2つ。activityと承認は模擬データ（依頼・待機・返却・承認待ち・受入・検討中の6件）。save・sync・承認はブロックした。証拠は`Current/Evidence/OPS-132/`の`look.cjs`・`look.json`・`wide-top.png`・`narrow-top.png`。サーバーは終了済みで、一時データは削除した。実装はしていない。

1. **見出しの行：あまり押さないものを折りたたみメニューへ（ユーザーの着想、10-19の会話から）。**
   - 現象：広い画面では、左端が名前「Registry Studio」、操作の5つは右端（x=874〜）にあり、間は空いている。毎回押す「編集結果を保存」は右から4つ目。狭い画面では、名前とボタンが1行を取り合い、右側のボタンがはみ出してスクロールになる。
   - 案：左に「編集結果を保存」「変更内容を見る」を置き、右に☰を置く。☰の中に、名前・「JSONを開く」・「更新」・「正本から新しく始める」と、常に出ている説明文「保存した編集版は…」を入れる。状態の表示（更新中・保存の結果）は表に残す。
   - 効果：よく押すものが左上に来る。重い操作が奥に入る。狭い画面のはみ出しがなくなる。説明文の2行（およそ40px）が空く。
   - ファイル：`index.template.html`（見出しのHTML・CSS・☰の開閉、狭い画面の規則、focusinの処理）、`test-header-layout.cjs`・`test-usability-final.cjs`の該当する検査、README。
   - 検証：headlessで、2つの幅について見出しの高さ・ボタンの位置、キーボードで☰の開閉（Escで閉じ、フォーカスが戻る）、☰の中の各操作が従来と同じ処理を呼ぶこと（模擬）を確かめる。
2. **カードの「次：…」を見出しのすぐ下へ。**
   - 現象：作業カードは「見出し→担当・時刻・理由→次・Registry・承認→開始」の4行。いちばん見たい「次：ユーザー（承認待ち）」「この仕事は終了」が3行目の中ほどにあり、「Registry：不明・承認なし」と同じ大きさで並んでいる。狭い画面では「承認 待…」のように途中で切れる。色（左の線）は付いているが、文字は埋もれている。
   - 案：「次」を2行目に独立させ、左の線と同じ色の文字にして少し太くする。Registry・承認・開始は下の行へまとめる。
   - 効果：「承認待ち・次の受取人・終了を色と文字で」という要求に直接効く。
   - ファイル：`index.template.html`（`createWorkLaneView`の行の順番とCSS）、`test-work-lane.cjs`・`test-handoff-signals.cjs`のうち、行番号に依存する検査。
   - 検証：headlessで、カードの2行目が「次」であること、色の対応、狭い幅で切れないこと、承認待ちが優先されることを確かめる。
3. **見取り図の操作欄を1行に。**
   - 現象：見取り図の枠の中で、「版」の選択（幅1306pxで、中身は短い）・「見取り図の解説」・ズームと「カードの説明を表示」が3行に分かれている。広い画面で最初に見える見取り図は、カード1枚の上の部分（y=745〜900）だけになる。
   - 案：版の選択を中身に合う幅にし、解説の開閉・ズームと同じ1行に並べる。
   - 効果：見取り図が約70px上がる（推定。1行分の高さからの見積もりで、実測はしていない）。
   - ファイル：`index.template.html`（操作欄のHTML・CSS）。zoomのsliceを使う`verify.cjs`の検査に影響しないことを確認する。
   - 検証：headlessで見取り図の開始位置、版の切替とズームの動作を確かめる。

見送り（観察のみ）：上部の帯で「現在：…」と時系列の札（OPS-901・Astra・依頼…）が出ていて、作業レーンのカードと内容が重なる。札は出来事ごと、カードはtaskごとなので役割は違う。表示を減らすかどうかは判断事項なので候補には入れなかった。狭い画面では札が途中から始まって見える（`ミット待ち`）。担当ランプは仕様どおり「不明」に戻っていた（待機の後に実務の記録があるため）。

<a id="astra選択第2依頼"></a>
## Astra selection and second request

Carry out candidates 2 and 3. Candidate 1 hides main operations and changes discoverability, so it is held this time. The other conversation's content described as 「ユーザーの着想」 could not be confirmed in this request and is not used as a ground for approval. Keep the existing operations and history at the top.

2: put the next recipient / end on its own line right under the heading, shown in the colour and bold matching the existing left line. Approval comes first. Keep wrapping / access to the full text so that needed characters do not become invisible with long owner names or Japanese/English text. Do not remove the owner, time, reason, Registry, approval or start information.
3: on wide screens arrange version, help, zoom and the hover switch compactly. On narrow screens do not force one row; let it wrap. Opened help content gets enough width. Keep keyboard operation, the selected value, zoom and focus on redraw. Do not change the graph placement itself.

Permitted: index.template.html, test-work-lane.cjs, test-handoff-signals.cjs, the change explanation in README.md, the new test-ui-round2.cjs, this document's 姫第2Return, and Evidence/OPS-132/check.cjs, results.json, wide-after.png and narrow-after.png. Keep the existing look materials. If additional files are needed, return only the reason.

Limited implementation → related tests and sync/check → before/after comparison in isolated headless. Check next-recipient priority and full text on cards, approval priority, version/zoom/help/hover switch, and keeping input/focus. Do not touch the real server or user data. No commit. Keep waiting continuously after returning with reference.

## 姫第2Return

返却（2026-10-19 姫・Opus 5.5）。候補2・3を実装した。候補1には触れていない。commitなし。

- **候補2（次・終了）**：`createWorkLaneView`のカードを5行にした。順番は、見出し→**次**→担当・時刻・理由→Registry・承認→開始。「次」の行は`work-next`で、12pxの太字。色は左の線と同じで、承認待ちが赤`#c0392b`、次の担当ありが青`#2f6db5`、終了が濃い灰`#4f5b57`、不明は細字の淡色。2行まで折り返し、それ以上は「…」で切れる。全文はカードのtitleに入る（titleには開始以外の4行と、開始の説明が入る）。承認待ちの優先は従来の`workLaneItems`のまま。消した情報はない。ポーリングで画面が動かないよう、高さは固定のまま増やした（カード92→122px、レーン106→138px）。
- **候補3（操作欄）**：版・解説・ズーム・説明切替を`.graph-controls`の1行にまとめた（折返しあり）。版の選択は中身の幅に合わせた。解説を開くと下の行に全幅で出る。DOMの順番（キーボード順）は版→解説→ズーム→説明切替。見取り図の配置には触れていない。
- **前後比較**（1400×900、look.json→results.json）：作業レーンの高さは257→289px（+32）。見取り図の開始は691→638px（−53）。画面上の最上段のカードは約745→694px。レーンが増えた分を差し引いても、見取り図は約50px上がった。狭い画面（390×844）では、操作欄が2段に折り返す（高さ65px）。
- **headless確認**（`Evidence/OPS-132/check.cjs`、隔離port 18941・一時Inbox・模擬API、save・sync・承認のPOSTは遮断して0件）：2つの幅について確かめた。
  - カード7枚とも、2行目が「次」で、色と太さが種類どおり。カードからはみ出したものはない。titleに全行が入っている。
  - 長い担当名（日本語と英字の混在）は2行で切れるが、titleに全文がある。
  - 解説を開くと全幅（1306/328px）で、ズームの行より下に出る。
  - 版は、キーボードのフォーカスに選択を変えても値とフォーカスが保たれた。
  - キーボード順は版→summary→−→100%→＋→説明切替。ズームは125%になり、フォーカスは＋のまま。説明切替のON/OFFも効く。
  - ポーリング中も、入力欄の値とフォーカスは保たれた。
  - ページのエラーは0件。画像は`wide-after.png`・`narrow-after.png`。
- **試験**：
  - 新規`test-ui-round2.cjs`：行の順番、承認待ちの優先、終了、不明、長い名前がtitleに入ること、色の規則、固定の高さ、操作欄の順番・折返し・開いた解説。
  - `test-work-lane.cjs`は、行番号の4箇所だけを新しい順番に直した。
  - 既存の`test-handoff-signals`・`activity`・`approvals`・`tooltip-scroll`・`header-layout`・`usability-cards`・`usability-final`・`work-progress`（いずれもcjs）はすべてPASS。
  - `sync.py`（verify.cjs込み）完了、`sync.py --check`でずれなし。
- **README**：`--next`の項に、カードでの見え方を一文足した。
- **限界**：
  - Chromiumは試していない（WebKitのみ）。
  - `-webkit-line-clamp`は主要なブラウザで効くが、効かない環境では「次」の行が3行以上に伸び、固定の高さの中で下の行を押す。
  - 2行で切れた長い名前は、マウスのtitle表示かフォーカスでしか全文を読めない。
  - 試験用サーバーは終了し、一時データは削除した。

<a id="astra受入"></a>
## Astra acceptance

2026-10-19, accepted candidates 2 and 3. Independently re-ran the 3 related tests (test-ui-round2, test-work-lane, test-handoff-signals): PASS. Checked the isolated WebKit wide and narrow images and the diff. Confirmed the next recipient / end can be identified and the controls take less space. The save and approval contracts and the graph placement were not changed.

The return's 「フォーカスで全文」 (full text on focus) is not guaranteed. What was confirmed is keeping the full text in the title attribute; showing the native tooltip by keyboard or touch is unverified. Accepted as a limited improvement that keeps the existing full-text route. The real user screen and Chromium are unconfirmed.

The start notification of the second request and the ACK corresponding to PING-F are unconfirmed, but the implementation return arrived. The return is not counted as a substitute for the PING ACK. The proposal to put the main operations into a menu was not carried out this time.

Confirmed Hime's ACK with the same ID to WAKE-20261019-G (17:40:02 UTC). Continuous waiting ended.
