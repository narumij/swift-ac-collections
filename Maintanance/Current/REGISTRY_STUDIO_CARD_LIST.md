# 正本を探すためのカード一覧タブ

## TL;DR（人間向け）

見取り図から探しにくい正本へ短く到達できるよう、接続や版の絞込みに頼らないカード一覧タブを追加した記録。同梱正本だけのリンク・複数選択・入力保護を限定試験と独立確認で受け入れ、完了した。検索は追加しておらず、Safari実表示・実クリックは未確認。

2026-10-18 / OPS-085 / Parent OPS-048 / Astra drafting/acceptance; 姫 implementation/verification.

<a id="目的と委任"></a>
## Purpose and delegation

Users may be unable to find a card in the diagram even when they only want its canonical document. Add an on-demand 「カード一覧」 tab. The user delegated broad composition and requested assignment to 姫. Search is optional. Prefer few steps to canonical documents without restoring a permanent left pane.

<a id="範囲"></a>
## Scope

- Add a card-list tab beside dependency, permanent and placement-protection views.
- List formal tasks (including permanent, independent and complete) and milestones from the loaded editing document, independent of diagram connections/version filtering. Ordering/light categorization at implementer's discretion; make coverage clear and avoid lost cards.
- Show ID/title/state and direct existing canonical links. Reuse multi-document selection; invent no links. Treat virtual START/END canonical availability according to data.
- Label any proposals as proposals with no canonical link. Share selection with diagram/inspector. Preserve unsaved edits and unapplied input through tab changes/viewing.
- Reuse Markdown display. No mandatory search, advanced filtering or separate editor; add no new canonical management data.

<a id="編集範囲受渡し"></a>
## Editing scope and handoff

OPS-084 already accepted by Astra; preserve its uncommitted changes. Editable: RegistryApp/index.template.html, verify.cjs, README, this breakdown/Return and Current/Evidence/OPS-085/. Explain any necessary limited changes elsewhere. Do not change DESIGN, Registry, Rules, actual milestones or user Inbox. Write a short initial breakdown and starting HEAD/prior changes. Hand scope to 姫; Astra awaits Return. No commit.

<a id="検証完了条件"></a>
## Verification and completion criteria

Find isolated/permanent/completed tasks and intermediate milestones from the list and open canonical documents directly. Correctly handle multiple/absent sources. Check tabs/selection and input protection. Run sync/verify and limited interaction smoke; mark Safari unverified if so. Return diff, tests, unknowns and temporary-artifact handling.

## 作業内訳（姫記入）

2026-10-18 / 姫・Opus 5.5。開始HEAD`a1dae54ff`。先行差分：OPS-084の未commit実装（`index.template.html`・`verify.cjs`・`README.md`、Astra受入済み）は保持して続ける。DESIGN 2件（ユーザー）、`CLAUDE_TASK.md`・Registry・Rules（Astra）には触れない。

1. 「カード一覧」タブを、依存・恒久・配置維持と並べて足す。タブの切替処理を4つに広げる。
2. 一覧の中身：見取り図の接続や版の絞込みに頼らず、読み込んだ編集版から作る。
   - 区分の順：マイルストーン（配置順、仮想START/ENDを含む）／恒久タスク／タスク（未完了）／完了・除外／追加案。
   - 各カードにID・タイトル・状態と、同梱された正本だけを開く「正本」リンクを付ける。複数なら選択ダイアログ、正本がなければリンクなし。
   - 追加案は「追加案」と示し、正本は付けない。
3. カードを押すと既存の`select`で選ぶ。見取り図・インスペクタと共有し、未適用入力の確認も既存のものを使う。タブ切替と正本の閲覧はデータに触れない。
4. 検証：verifyに一覧の網羅（全task・全マイルストーン・追加案、重複なし）と、正本パスの扱い（同梱分のみ・複数・なし）を足す。stub DOMのスモークで次を確かめる。
   - 孤立・恒久・完了task、中間カードを一覧から開ける。
   - タブ切替で未保存・未適用入力が残る。
5. README・Return・Evidence。

## Return（姫記入）

2026-10-18 / 姫・Opus 5.5。入力`a1dae54ff8a5e8b72b46a218b00c5b85476b03fc`＋OPS-084の未commit実装（保持）。DESIGN 2件（ユーザー）、`CLAUDE_TASK.md`・Registry・Rules（Astra）には触れていない。実ユーザーの`Inbox/`は使っていない。

**変更**（`index.template.html`・`verify.cjs`・`README.md`）：
1. 「カード一覧」タブ（`cardsTab`・`cardsView`）を依存・恒久・配置維持の横に足した。タブ切替は`MAP_TABS`の4つにまとめ、矢印キーでの移動も4つで回る。
2. `cardListGroups(data)`：編集版から区分（マイルストーン／恒久タスク／タスク（未完了）／完了・除外／追加案）を作る。接続や版の絞込みは見ない。
3. `cardDocumentPaths(t, bundle)`：既存の`taskDocumentPaths`のうち、同梱されている文書だけを返す。追加案は常に空。
4. `renderCards()`：区分ごとの見出しと件数、折り返して並ぶカード（ID・種類・タイトル・状態の帯）を描く。押すと既存の`select`で選択する。「正本」は1件なら直接、複数なら同梱分だけの選択ダイアログで開く（既存のMarkdown表示を再利用）。正本がなければリンクは出さない。`render()`から呼ぶ。
5. README「カード一覧タブ（OPS-085）」節。
6. verifyにあったタブ切替の検査は、旧来の切り出し位置が変わったので、新しい位置で読み直すよう直した。「カード一覧」への切替の確認も足した。

**検証**：
- `verify.cjs`（27 PASS、以前は26）：
  - 全task・全マイルストーン・追加案が1回ずつ載り、恒久・完了・追加案が正しい区分に入る。
  - リンクは同梱文書だけ。存在しない文書や追加案にはリンクがない。複数の正本を持つtaskがある。
  - タブの切替は4面のうち1面だけを表示する。
- `Evidence/OPS-085/smoke.cjs`（最小DOM stub）：
  - 追加案の未適用入力がある状態でタブを切り替えても、編集・入力が残る。
  - 孤立task・恒久task・完了task・MS-SPI・追加案が一覧にあり、追加案にはリンクがない。
  - 一覧から正本を直接開ける（1件は文書、複数は選択ダイアログ）。複数正本の選択肢は同梱分の数と一致する。閲覧しても編集は残る。
  - カードを押すと選択がインスペクタと共有される。依存タブへ戻れる。
  - 結果：PASS。
- 既存のOPS-084・OPS-082 v2/v3スモークもPASS。`sync.py`成功、`--check`でずれなし。
- Safari・実ブラウザでの見え方とクリックは未確認。

**未確認・注意**：
- 一覧の並びは、区分の中ではデータの順（マイルストーンは配置順、taskはRegistry順）。検索・絞込みは付けていない（必須でないため）。
- カードを押して別のカードを選ぶとき、未適用の入力があれば既存の「破棄して移動しますか？」の確認が出る（既存の動作）。

**作業物**：一時ファイルなし。

commitはしていない。

<a id="astra受入2026-10-18"></a>
## Astra acceptance (2026-10-18)

Accepted at user instruction. Inputs: `a1dae54f`, accepted OPS-084 changes and OPS-085 return diff. Compared list generation, bundled-document access and tab switching in code.

Independent sync/verify: 27 PASS, no missing documents. OPS-085 interaction smoke PASS: categories, direct/multiple-source opening, no proposal links, shared selection and input retention during switching/viewing. OPS-084 connection and OPS-082 update-protection v3 smokes PASS; --check agrees. Safari display/clicks unverified.

Meets scope as a small search-free list. User Inbox/DESIGN unchanged. Accepted, WAITING_USER pending commit; 姫 assignment closed.

2026-10-18: user's commit instruction resolved the wait; DONE. Acceptance scope/unknowns unchanged.
