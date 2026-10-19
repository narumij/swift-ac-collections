# 選択ノード中心の接続表示

## TL;DR（人間向け）

選択したタスクや到達点の直接の前提・後続を確認し、手動で先へ展開する「接続を見る」機能の記録。実装・独立試験・同期一致を限定受入済みで、閲覧時の入力と編集版の保持を確認した。実画面はユーザー希望により未確認で、過去の全スモーク試験の成功まで保証しない。

2026-10-18 / Author Astra / OPS-091 / Parent OPS-048. Limited assignment based on the user's 「特定のノードと接続されてる辺とノードを表示する機能」 and 「姫に依頼かな」.

<a id="目的と範囲"></a>
## Purpose and scope

Allow checking direct prerequisites/successors of a task or milestone separately from version-wide diagrams. QUALITY-005's omission prompted this, but do not special-case its ID.

- Show selected node, directly connected prerequisite/successor nodes and edges for one hop; distinguish center and direction.
- Allow explicit manual one-hop expansion from a needed node, not automatic whole-graph exploration. Provide recenter/reset-to-one-hop operations.
- Source is current editing document. Do not inherit version-filter omissions; use tasks, milestones, proposals, edges and milestoneRelations. Show original START/END endpoints; isolated nodes show themselves.
- Provide entry from card list/inspector selections. Placement/style at 姫's discretion; retain existing diagrams/lists/canonical links.
- Viewing only: center/expand/reset must not change doc, baseline, dirty or pending inputs. Show condition text; do not infer eligibility from lines alone.

<a id="受渡しと編集範囲"></a>
## Handoff and editing scope

Hand index.template.html, verify.cjs, necessary limited interaction tests, RegistryApp/README.md and this Return to 姫. Registry, Rules, other canonicals, save mechanisms and server API are excluded. Astra will not alter implementation until Return.

Astra's uncommitted QUALITY-005 version-filter fix/regression check is in the working tree. Retain it while adding changes; preserve other owners' edits. Do not treat a fixed commit alone as the complete input.

<a id="検証返却"></a>
## Verification and return

Check one-hop prerequisites/successors, multi-hop manual expansion, recenter/reset, isolated nodes, START/END, proposals and deduplication. Cover QUALITY-005→DOC-026→DOC-027 and MS-SPI→DOC-027 branching/merging. Confirm view operations leave save diff and pending input unchanged. Run existing verify and sync/check. No browser operation requested by the user; explicitly mark real display unverified.

Return only the new policy decision if needed and stop there. No expansion or simultaneous unnumbered work. Commit is not assigned; Astra accepts then asks the user about commit.

## Return（姫記入）

**作業内訳（着手時）**：開始HEAD`adf2158317be0eab1fc66eb75ca4e4d7de0eb097`。Astraの未commit差分（`versionView`の前提連鎖の補修と、その回帰検査）は保持する。
1. 純粋関数`neighborhood(data, center, expanded)`：開いている編集版のtasks・proposals・milestonesとedges・milestoneRelationsから、中心の直接の前提・後続と、展開したノードの隣を集める。版フィルターは通さない。
2. 「接続を見る」タブ：中心、前提・後続の一覧（線ごとに種類・条件文・相手の状態）、各ノードの「ここを中心に」「この先を展開」、「1段に戻す」。入口はインスペクタのボタン。中心は選択とは別の変数で持ち、doc・baseline・dirty・入力中の値に触れない。
3. verify（純粋関数）とstub DOMのスモーク、README、sync・`--check`。

**結果**（2026-10-18 / 姫・Opus 5.5）：

- **変更**（`index.template.html`・`verify.cjs`・`README.md`）：
  - `neighborhood(data, center, expanded)`：純粋関数。編集版全体から作り、版の絞込みを通さない。重複を除き、深さを持つ。データは変えない。
  - 「接続を見る」タブ（`neighborTab`・`neighborView`）：中心、前提・後続・展開した先の一覧（線の種類・Flow・条件文、相手の状態）、各ノードの「ここを中心に」「この先を展開」、「1段に戻す」。
  - インスペクタの先頭に「接続を見る」ボタンを置いた（task・追加案・マイルストーンのどれでも）。
  - 中心・展開は選択と別の変数で持つので、`select()`は呼ばない（未適用入力の確認・破棄が起きない）。
  - タブ切替の一覧（`MAP_TABS`）とverifyのタブ検査に1つ足した。
  - Astraの未commit差分（`versionView`の前提連鎖の補修と、その回帰検査）は保持した。
- **検証**：
  - verify 31 PASS（新規1行）：
    - 1段の表示：DOC-027で、DOC-026とMS-SPIの両方が出て、QUALITY-005は出ない。
    - 展開：DOC-026を展開すると、QUALITY-005→DOC-026が深さ2で出る。
    - 端点：MS-SPIの元の端点、STARTを中心にできること。
    - 孤立ノード、追加案、重複なし、存在しないID、データ不変。
  - `Evidence/OPS-091/smoke.cjs`（stub DOM、PASS）：
    - インスペクタから開き、DOC-027の前提2本を確かめた。
    - DOC-026を展開してQUALITY-005、MS-SPIを中心にしてSTART/END、1段に戻す。
    - 編集版とdirtyが不変。
    - 追加案の未適用メモがある状態で開いても、入力・選択・データが変わらない。
  - `sync.py`成功、`--check`でずれなし。
  - 実画面は、ユーザーの希望どおり確認していない。
- **一行報告**：`adf215831`でテンプレートに`document.addEventListener('input', …)`が入った。そのため、以前のスモーク（OPS-082 v2・OPS-085・OPS-086ほか）は、stubに`addEventListener`がなく起動時に止まる。今回のOPS-091のスモークだけstubに1行足した。以前の証拠ファイルは原記録として直していない。
- **作業物**：一時ファイルなし。commitはしていない。



<a id="astra受入"></a>
## Astra acceptance

2026-10-18, Astra: limited acceptance. Read neighborhood and handlers; independently reran all verify items and OPS-091 smoke successfully; confirmed sync/check agreement. Verified one-hop prerequisites/successors, manual expansion, recenter, START/END, isolated/proposal nodes, and retention of pending inputs/doc/dirty. UI is a connection list rather than graph drawing; accepted within delegated layout/style. Real display remains unverified at user preference.

Keep the old-smoke DOM-stub deficiency report distinct from this feature's failure. Do not guarantee all historical checks currently pass. No further repair assignment. OPS-091 is WAITING_USER (commit confirmation).

2026-10-18: user commit approval made OPS-091 DONE. No further assignment.
