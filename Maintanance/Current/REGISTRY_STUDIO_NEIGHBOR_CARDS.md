# 「接続を見る」へのカード表示追加

## TL;DR（人間向け）

「接続を見る」を、選択カードが中央・実際の前提が左・後続が右に見える局所見取り図へ変更した記録。当初の3段カード列を置き換え、実辺・対象一致・選択追従・入力保護を限定試験と独立再実行で受け入れ、完了した。旧カード列の証拠は履歴として残し、実ブラウザでの線の重なりや見え方は未確認。

Task OPS-094 / parent OPS-048. Astra, 2026-10-18; assigned to Hime at the user's explicit request.

> 現行依頼は末尾「ユーザー期待に合わせた再依頼」。当初依頼・限定補修は経緯として保持し、新たに実行しない。

<a id="目的受入条件"></a>
## Purpose and acceptance

Add cards to the connection-view tab while retaining existing text.

- Show center/displayed connected nodes as cards with readable ID/title/state, existing styling and available canonical links.
- Distinguish prerequisite/center/successor direction. Placement details are delegated; the overall map layout need not change.
- Synchronize with one-level view, manual expansion, center changes/reset. Match text/card targets, without duplicate cards for a node.
- Preserve OPS-093 selection-following/input protection. Viewing connections neither applies/discards edits nor changes canonicals/states/connections/saved data.
- Handle tasks, milestones and isolated nodes. Run bounded regression and existing smoke/verify/sync/check. No UI operation; note real-browser nonverification.

<a id="範囲と受渡し"></a>
## Scope and handoff

Editable: RegistryApp/index.template.html, necessary verify.cjs, Evidence/OPS-094/ and this Return. Generated updates allowed. Hime owns the implementation while Astra awaits return.

Preserve Astra's uncommitted restart notice and OPS-093 repair. No Registry/Rules/serve.py/real Inbox/Milestones/others' document changes. Overall-map duplicate display, lines and layout are outside scope. Return necessary specification expansions.

No commit requested. Return cause, changes, verification and unknown scope after completion.

## Return（姫記入）

**作業内訳（着手時）**：開始HEAD`bdb21a92c`。Astraの再起動案内帯とOPS-093の修正はcommit済み。未commitの他者分（DESIGN 2件）と、姫のCP-20261018-001の記録は触らない。
1. 純粋関数`neighborhoodSides(view)`：表示中の線を中心からたどり、各ノードを前提側・後続側に一度だけ振り分ける（重複なし）。
2. `renderNeighborhood()`の文字一覧の前に、「前提 →」「中心」「→ 後続」の3段のカードを置く。既存のカードの見た目と`cardWithDocuments`を再利用し、正本リンクはある場合だけ付ける（追加案は付けない）。カードを押すと`select()`（OPS-093の追従と入力保護をそのまま使う）。
3. verify（振り分け）とstub DOMのスモーク（文字一覧とカードの対象一致、展開・中心変更・戻す、選択追従、入力保護、データ不変）。sync・`--check`。

**結果**（2026-10-18 / 姫・Opus 5.5）：

- **変更**（`index.template.html`・`verify.cjs`）：
  - `neighborhoodSides(view)`：表示中の線を中心から幅優先でたどる。線を逆向きにたどれば前提側、順向きなら後続側として、各ノードに1つだけ振り分ける。純粋関数。
  - `renderNeighborhood()`：文字一覧の前に「前提 →」「中心」「→ 後続」の3段のカード列を置いた。
    - 対象は文字一覧と同じ`neighborhood()`の結果。既存のカード（`task`の見た目・状態の帯、正本リンクは`cardWithDocuments`）を再利用した。
    - 追加案と、詳細のないノードには正本リンクを付けない。
    - カードを押すと`select()`を呼ぶ。中心の追従と入力保護はOPS-093のまま。
  - 見出しの小さなCSSを1行足した。文字一覧はそのまま残した。
- **検証**：
  - verify 32 PASS（新規1行）：DOC-027の前提2つが前提側、展開したQUALITY-005も前提側、MS-SPIからDOC-027は後続側、孤立ノードは中心だけ、全ノードがちょうど1回振り分けられる。
  - `Evidence/OPS-094/smoke.cjs`（stub DOM、PASS）：
    - DOC-027の1段、DOC-026の展開、MS-SPIを中心に（到達点）、1段に戻す。各段階で、カードと文字一覧の対象が一致し、重複カードがない。
    - カードを押すと選択と中心が移り、展開は持ち込まない。
    - 孤立ノードは自分のカードだけ。
    - 未適用入力があって移動を取り消すと、選択・入力・中心が保たれる。
    - 編集版は不変。
  - OPS-093のスモークもPASS。`sync.py`成功、`--check`でずれなし。
  - 実ブラウザでは確認していない（カードの並び・折り返しの見え方は未確認）。
- **一行報告**：OPS-091のスモーク（原証拠）は、中心のまわりの`<strong>`を全部数えて「接続のない追加案は0行」と見る書き方をしている。そのため、カードが入った今は中心カードの1つを数えて止まる。表示の仕様変更による原証拠側の前提ずれで、証拠ファイルは直していない。
- **作業物**：一時ファイルなし。commitはしていない。



<a id="astra検収2026-10-18-受入保留"></a>
## Astra review (2026-10-18): acceptance withheld

Independent OPS-094/OPS-093 smoke PASS; sync --check matched. No real UI operation.

Additional checking found inconsistent direction classification. With center MS-SPI and expanded DOC-027, actual edges are MS-SPI→DOC-027 and DOC-026→DOC-027, but neighborhoodSides() assigns DOC-026 to post (successor). It carries the initially visited side into reverse traversal, making another prerequisite of a shared successor appear downstream of the center. This fails 「前提・中心・後続の方向が判別できる」, so overall acceptance is withheld.

Possible repair: distinguish directed-path predecessors/successors from other expanded related nodes, without asserting direction for the latter. Preserve text/card target equality and uniqueness. No repair assignment issued yet; original Return retained.

<a id="限定補修の再依頼2026-10-18--astra"></a>
## Bounded repair reassignment (2026-10-18 / Astra)

User approval returns OPS-094 to Hime for direction classification alone. Preserve original Return/review.

<a id="受入条件"></a>
### Acceptance conditions

- A node with a directed path to center is a prerequisite; one reachable from center is a successor. Use currently displayed connections.
- Other expanded nodes belong in a nondirectional area such as 「関連」, not forced into the three existing columns. Exactly one card per displayed node.
- Reproduction: center MS-SPI, expand DOC-027; do not label DOC-026 a prerequisite/successor of MS-SPI. Retain DOC-026→DOC-027 text.
- Symmetric example A→center, A→B: B is not the center's prerequisite. Simple linear upstream/downstream remains unchanged.
- Retain selection-following, expansion/reset, input protection and matching text targets; add regression and run existing smoke/verify/sync/check.

Same editing scope; only necessary pure functions, card areas and bounded tests. No overall map, canonical connections, real Inbox or save-contract changes. No UI operation/commit. Redelegate occupancy; Astra awaits repair Return.

## 補修Return（姫記入）

未返却。

<a id="ユーザー期待に合わせた再依頼2026-10-18--astra"></a>
## Reassignment matching user expectations (2026-10-18 / Astra)

User correction: 「選択カードがほんとに真ん中にあって、左右に接続線がみえてほしい」. Classified card columns did not match the expectation. With user approval this section replaces the original columns and 「関連欄」 addition assignment; preserve original Return.

<a id="作るもの受入条件"></a>
### Deliverable and acceptance

- Retain text and place a local map centered on the selected card above it, not three stacked card rows.
- Keep the selected card at the area's center, direct prerequisites left and direct successors right, even when counts differ. Center must be visible initially/after center changes; contain expansion within local scrolling or equivalent.
- Render each displayed actual connection once as an arrow between its real endpoint cards. Do not redirect noncenter edges to center. Limit card/line overlap so direction is traceable.
- Expanded nodes connect to their actual neighbors. In MS-SPI→DOC-027←DOC-026, connect DOC-026 to DOC-027 without implying it follows MS-SPI. No need to classify all nodes through area names.
- Cards show ID/title/state and available canonical links; distinguish center and use the same nodes/edges as text. One card per node.
- Preserve selection-following, one-level/expand/center/reset, unapplied input protection and read-only contract. Real data unchanged.
- Check isolated center, multiple/one-sided neighbors and expanded shared-successor examples. Test full/unique cards/edges, centering, direction and selection/input protection. Run existing smoke/verify/sync/check. No UI operation; note real-browser nonverification.

<a id="受渡し"></a>
### Handoff

Same editing scope. Hime chooses local placement/drawing without overall-map repair. If earlier repair has started, stop at its stage, retain interim output and state the switch at the next Return's beginning; do not discard it or implement both alternatives in parallel. At this point no repair Return is received and activity state is unknown. Astra does not change implementation. No commit.

## 局所見取り図Return（姫記入）

**切替の記録**：旧「関連欄」の限定補修には着手していなかった（初回Return後、補修の作業は始めていない）。そのため、途中成果はなく、本節の再依頼へそのまま切り替えた。初回に入れた3段のカード列と`neighborhoodSides()`は、局所見取り図に置き換える（原Returnの記録はそのまま残す）。

**結果**（2026-10-18 / 姫・Opus 5.5、入力HEAD`bdb21a92c`＋作業ツリー）：

- **変更**（`index.template.html`・`verify.cjs`）：
  - `neighborhoodLayout(view)`：純粋関数。中心を列0に固定し、表示中の各線a→bでbがaより右の列になるように列を決める（中心は動かさない）。行は中心列では中心を真ん中、他の列は中央寄せ。左右の広がりは対称（span）に取るので、中心列が常に図の真ん中になる。
  - 3段のカード列と`neighborhoodSides()`をやめて、文字一覧の上にSVGの局所見取り図を置いた。
    - カード：ID・中心／到達点／追加案の印・タイトル・状態の帯。中心は太枠と色。正本は同梱分だけリンク、追加案はなし。
    - 線：表示中の接続ごとに、実際の両端カードの間に矢印付きで1本ずつ。中心以外の線を中心へつながない。
    - 図の領域は縦横スクロールでき、描画時に中央列が見える位置へ横スクロールする。
    - カードを押すと`select()`（OPS-093の追従と入力保護のまま）。文字一覧と同じ`neighborhood()`の結果を使う。
  - 見出し用の小さなCSSを、図の領域のCSSに置き換えた。
- **検証**：
  - verify 32 PASS（カード列の検査を局所図の配置の検査に置き換えた）：
    - 中心が列0・行0にあり、前提は左、後続は右、全線が左から右へ流れる、同じ位置のカードがない、範囲が対称。
    - MS-SPIでDOC-027を展開すると、DOC-026はDOC-027の左にあり、線はDOC-026→DOC-027だけ。
    - 対称例（A→C、A→B）で、BがAの右にあり、Cの前提にはならない。
    - 前提が複数で後続が1つ、片側だけ、孤立ノード。
  - `Evidence/OPS-094/smoke_map.cjs`（stub DOM、PASS）：
    - DOC-027で前提2つが左にあり、中心が横方向の真ん中にある。
    - MS-SPI＋展開で、DOC-026→DOC-027が実際の両端の間に引かれる。
    - 中心変更・1段に戻すの各段階で、カードと線が文字一覧と一致し重複がなく、中心が真ん中にある。
    - カードを押すと選択と中心が移る。孤立ノードは自分だけ。
    - 未適用入力があって移動を取り消すと保たれる。編集版は不変。
  - OPS-093のスモークもPASS。`sync.py`成功、`--check`でずれなし。
  - 実ブラウザでは確認していない（線の重なり具合、スクロール位置の見え方）。
- **注意**：初回の`Evidence/OPS-094/smoke.cjs`（3段カード列用）は、カード列をなくしたので今は通らない。置き換えの経緯として原記録のまま残し、局所図の検証は`smoke_map.cjs`で行った。
- **作業物**：一時ファイルなし。commitはしていない。



<a id="astra局所見取り図受入2026-10-18"></a>
## Astra local-map acceptance (2026-10-18)

Inspected latest changes; independently reran smoke_map.cjs and OPS-093/smoke.cjs, both PASS; sync --check matched. Confirmed symmetric centering, direct prerequisites left/successors right, actual edges matching text, DOC-026→DOC-027's endpoints, selection-following and input protection. Old directional columns are replaced; bounded acceptance. Actual-browser appearance/line overlap remain unverified. Old smoke.cjs records the past columns; current verification is smoke_map.cjs. Assignment ended; awaiting commit.

User commit approval on 2026-10-18 makes OPS-094 DONE; acceptance limits/real-screen nonverification remain as above.
