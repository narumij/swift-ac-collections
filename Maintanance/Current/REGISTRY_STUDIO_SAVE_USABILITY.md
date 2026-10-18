# Studioの保存・編集操作のユーザビリティ改善提案

## TL;DR（人間向け）

保存状態と次の操作を分かりやすくする5件の改善提案と、その受入記録。取込済み版が再開される現状は隔離データで再現したが、見つけやすさや表示効果は実ブラウザ未確認の仮説を含む。提案の受入は採否・実装承認ではなく、判断は別のユーザー専任資料へ渡している。

2026-10-18 / OPS-088 / parent OPS-048 / proposed by Hime, accepted by Astra.

<a id="目的と開始条件"></a>
## Purpose and start condition

User-specified. After OPS-087's save contract is settled, ask Hime for proposals that help the user understand the save state and the next operation. Currently waiting for the prerequisite; the formal request has not been issued. This document alone does not start the work.

<a id="依頼予定の範囲"></a>
## Planned scope of the request

Check, in a limited way, the save contract and the current screen's flow of edit → apply → save → update/resume → AI import, and list confusing displays, operations and results with concrete examples. Focus on finding the add button, distinguishing unapplied / unsaved / saved / imported, and distinguishing an old edit version from the latest canonical.

Return small improvement proposals with priority, effect, size of work and whether the contract must change. Do not add problems to fill a quota of proposals. Separate guesses from facts observed by actual operation, and state it if Safari was not checked.

Implementation, changes to the canonical contract, changes to the real Inbox, a full redesign and commit are not included. Proposals touching new guarantees or undecided policies are separated as decision items. Preserving the current saved versions takes priority.

<a id="入力固定正式依頼"></a>
## Fixed input and formal request

After OPS-087 completes, Astra fills in the target version, the sections to read, the editing scope and the return destination, and makes the formal request in CLAUDE_TASK.

## Return

Not requested, not returned.

<a id="正式依頼2026-10-18--astra"></a>
## Formal request (2026-10-18 / Astra)

OPS-087's specification is complete, so the follow-up work the user specified is requested of Hime. The input is the save contract from 「試行保存契約 v1」 onward and the current Studio (implementation base 18e881e8, records added in 47cf771b). The uncommitted specification and this request are fixed at the time of this handover.

First write a short work breakdown in this document, then carry it through to proposals. Focus on save, apply, update, resume and AI import, and narrow it to at most about 5 valid proposals. In particular consider resuming an imported edit version, unapplied input, and telling the canonical from an edit version. The current README still describes the old method, so refer to OPS-087 for the contract; discrepancies in the UI or guidance may be included in the proposals.

Each proposal shows the concrete trouble, the minimal change, the expected effect, whether it changes the contract, and how to verify it. Do not modify code or operations. If a contract change is needed, separate it as an undecided proposal. Do not edit the real Inbox; do the needed operation checks with isolated data. Limit evidence to what was seen, and state it explicitly if not checked in a real browser.

The editable scope is only the work breakdown/Return of this document and Current/Evidence/OPS-088/. Do not change the input contract, Registry, README, implementation or DESIGN. With the request complete, the specified output scope is handed to Hime and Astra waits for the return. No commit.

## 作業内訳（姫記入）

2026-10-18 / 姫・Opus 5.5。入力：保存契約「試行保存契約 v1」以降と、現行Studio。読んだのは作業時のHEAD`eb5a6f7d0673f78a6ea3ff172a970138814cdbbf`（実装は依頼の基準`18e881e8`から変わっていないことを`git log`で確認）。

1. 保存・適用・更新・再開・取込にかかわる画面の文言と状態表示を、テンプレートのコードで確かめる（ヘッダー、`banner()`、保存・再開・やり直しの処理、追加案の案内、README）。
2. 取込済みの保存版が再開される挙動を、隔離したInboxで`inbox.py`を使って確かめる（実Inboxは使わない）。
3. 見つけた食い違いを、契約の用語（未適用入力・未保存編集・保存版・取込済み）に照らして5件以内の案にする。契約の変更が要るものは分けて書く。
4. 証拠は`Evidence/OPS-088/`に置き、Returnに書く。コード・README・契約は変更しない。

## 追加Return（姫記入）

2026-10-18 / 姫・Opus 5.5。入力`eb5a6f7d0673f78a6ea3ff172a970138814cdbbf`。

**確かめ方**：テンプレート・`inbox.py`・READMEをコードで読んだ（行番号は入力版）。取込済みの再開は、隔離Inboxで確かめた（`Evidence/OPS-088/imported_resume_check.txt`。一時ディレクトリは削除済み）。実ブラウザ・Safariでは見ていないので、見え方（位置・目立ち方）は推測を含む。推測の箇所はそう書いた。

### 案1：保存の状態を、契約の用語で保存ボタンの横に出す（優先：高）
- **困り方**：状態は`banner()`（137行）が画面下端の`sourceInfo`（35行のフッター）に1つの文として出すだけ。「n件の変更 ／ ファイル未保存 ／ 入力を編集中…」と生成元の情報が混ざっている。「ファイル未保存」はダウンロード時代の言葉で、今のサーバー保存（保存版）と合わない。保存したかどうかを確かめるのに、画面の一番下まで見に行く必要がある（位置は推測、コード上はフッター）。
- **最小変更**：ヘッダーの保存ボタンの横に、状態を1語で出す小さな表示を置く。
  - 表示は「未適用の入力あり」／「未保存の変更 n件」／「保存済み（保存ID末尾）」／「最新の正本と土台が違う」。
  - 同じ判定（`formDirty`・`dirty`・`planDraftPending`・`workspace`・sha）を使うので、ロジックは足さない。
  - 「ファイル未保存」は「未保存の変更」に直す。
- **期待効果**：契約のS1〜S3の区別が、押す場所の隣で分かる。
- **契約変更**：不要（表示だけ）。
- **検証**：stub DOMのスモークで、4つの状態それぞれに表示が切り替わることと、保存待ち中の後続編集で「未保存」に戻ることを確かめる。

### 案2：再開した保存版が取込済みなら、そう知らせて新しい土台を勧める（優先：高）
- **困り方**：`inbox.latest()`（69行）は取込記録を見ずに直近の保存を返す。そのため、AIが取り込んだ後も同じ保存版が再開され、そのまま編集を続けられる。隔離した確認でも、取込記録のある保存がそのまま再開され、応答に取込済みの印がなかった。画面は「正本が更新されています」と出るだけで、取込済みとは分からない。続けて保存すると、取り込み済みの内容をもう一度送ることになり、S5の二重登録の照合をAIに押し付ける。
- **最小変更**：`/workspace`の応答に、その保存IDが取込記録にあるかを1つ足す（`inbox.imports()`を引くだけ）。画面は「この編集版は取込済みです。続けるなら『正本から新しく始める』がおすすめです」と出し、そのボタンを目立たせる。自動で切り替えはしない。
- **期待効果**：取り込み後にどこから始めればよいかが分かり、二重送付が減る。
- **契約変更**：不要。再開の規則（S3）は変えず、表示を足すだけ。取込済みの意味は契約のS5（全体処理後の記録）に従う。
- **検証**：隔離Inboxで保存→記録→`/workspace`の印を確かめる。stubで表示とボタンの強調を確かめる。

### 案3：「正本から新しく始める」の直後は、保存するまで前の版が再開されると表示する（優先：中）
- **困り方**：やり直しの処理（655行）は画面上で新しい編集版を始めるだけで、保存するまで系列はできない。保存せずに閉じたり再読込したりすると、次は前の保存版が再開される（656行付近の`resumeWorkspace`）。完了メッセージは一度出て消えるので、この事情は伝わりにくい（推測）。
- **最小変更**：新しく始めた後、最初に保存するまで、案1の表示を「新しい編集版（未保存）：保存するまで、次に開くと前の保存版が再開されます」にする。
- **期待効果**：「やり直したはずが元に戻った」と見える驚きを防ぐ。
- **契約変更**：表示だけなら不要。「始めた時点で空の保存版を作る」ようにするなら、保存単位（S1）と履歴（S4）に触れるので**判断事項**。
- **検証**：stubで、やり直し→保存前の表示→保存後に通常表示へ戻ることを確かめる。

### 案4：未適用の入力がある欄の「適用」ボタンを、その場で目立たせる（優先：中）
- **困り方**：未適用入力の案内は、フッターの文「入力を編集中：下の『変更を適用』で確定」と、操作を止めたときの赤い文だけ。「変更を適用」「名前・条件を適用」は欄ごとにある（539・592行など）。どれを押せば確定するのかが、入力した場所から分かりにくい（推測）。保存しても未適用入力は含まれない（S1）が、それに気づくのは止められてから。
- **最小変更**：`formDirty`の間、その欄の適用ボタンに「未適用」の印（色か、横の短い文）を付ける。保存を押したときに未適用の入力があれば、どの欄かを案内文に入れる。
- **期待効果**：「入力した＝保存した」という誤解を、入力した場所で防ぐ。
- **契約変更**：不要。
- **検証**：stubで、入力すると印が付き、適用すると消えること、保存の案内に欄名が出ることを確かめる。

### 案5：案内文を今の保存方式に揃え、「タスク追加」をヘッダーからも押せるようにする（優先：中〜低）
- **困り方**：
  - 文言の食い違い：追加案の案内（590行）に「保存したJSONをAIへ渡すと」がある。READMEの手順（44〜47行）も「JSONをダウンロード」「保存したJSONをAIへ渡す」「ダウンロードを確認する」のままで、サーバー保存（Inbox）と食い違う。ヘッダーの案内（33行）は今の方式なので、画面の中でも食い違っている。
  - 追加ボタンの見つけにくさ：「タスク追加」は独立タスク欄の中にしかない（35行）。見取り図を見ているときは見つけにくい（推測）。
- **最小変更**：
  - 追加案の案内とREADMEの該当手順を「保存するとサーバーに残り、AIに取り込みを頼める」に直す。`file://`のダウンロードは別の経路と明記する（契約の冒頭どおり）。
  - ヘッダーのツールバーに「タスク追加」を1つ足す（同じダイアログを開く）。
- **期待効果**：古い手順に従って余計なダウンロードや添付をしない。追加の入口が分かる。
- **契約変更**：不要。
- **検証**：文言はgrepで旧方式の言葉が残っていないことを確かめる。stubでヘッダーのボタンから追加ダイアログが開くことを確かめる。

### 判断事項として分けたもの
- 案3の「空の保存版を作る」方式（S1・S4に関わる）。
- 系列を選ぶ画面、取込後に土台を自動で切り替えること（契約の未決欄）。今回の案では表示と推奨にとどめた。

### 未確認
- 実ブラウザ・Safariでの見え方。フッターがどれだけ見落とされやすいか、ボタンの目立ち方は推測。
- 各案の作業規模は、どれもテンプレートの表示処理の数行〜数十行と見込む。案2だけ`serve.py`／`inbox.py`に1項目足す。

**作業物**：隔離Inboxの一時ディレクトリと、確認で出来た`__pycache__/`は削除済み。コード・README・契約・実Inboxは変更していない。

commitはしていない。

<a id="astra受入2026-10-18"></a>
## Astra acceptance (2026-10-18)

Accepted the 5 improvement proposals based on the user's request. This is not adoption or implementation approval. Checked the save/update/resume/state-display code of input eb5a6f7d against the proposals, and independently reproduced save → import record → latest with an isolated temporary Inbox. Confirmed that the imported version is resumed and that the response has no imported mark. The temporary area was deleted after verification. Product code and the real Inbox were not changed.

Display position and discoverability are hypotheses, not real-browser observations. Effort estimates are also unverified. The 4 states in proposal 1 can hold at the same time, so the design must not let a one-word exclusive display hide other cautions. "Imported" in proposal 2 is limited to the record after whole processing, and is judged separately from whether the currently displayed base is the latest. The old-wording search in proposal 5 is not a ground for removing even the legitimate explanation of the file:// route.

Proposal acceptance is complete, waiting for commit. Adoption decisions are gathered in the new USER_ONLY OPS-089. No implementation request is issued. The follow-up is OPS-090's limited cache update.
