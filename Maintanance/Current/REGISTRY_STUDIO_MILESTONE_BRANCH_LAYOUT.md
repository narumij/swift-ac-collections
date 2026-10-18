# 途中マイルストーン配下のタスク群配置

## TL;DR（人間向け）

途中マイルストーンから出る複数カード群をその下へまとめ、単独後続はユーザーが意図した右上へ残した配置修正。上下の水平オフセットを共通化し、幅不足時の必要区間拡張を限定試験・独立確認で受け入れて完了した。局所図・実辺は保持し、複数起点の優先規則と実ブラウザ確認は未確定のまま。

Task: OPS-096 / parent OPS-048
Authored by Astra, 2026-10-18. Formal assignment to Hime under user approval.

> 現行要求は恒久正本と末尾の追加依頼。初回の「単独も下」の解釈はユーザー判断により撤回。

<a id="目的と要求"></a>
## Purpose and requirements

See permanent canonical [TASK_REGISTRY_APP.md](TASK_REGISTRY_APP.md#途中マイルストーンから始まるタスク群の配置). Bring DOC-027, currently isolated at the bottom, into the group below MS-SPI. Target the overall dependency map; leave the local connection view unchanged.

<a id="実施受入条件"></a>
## Execution and acceptance conditions

1. Establish DOC-027's placement cause in current data and fix the rule for groups originating at intermediate milestones, without ID-specific fixed coordinates.
2. Place DOC-027 below MS-SPI; retain other prerequisites' edges, including DOC-026→DOC-027, between their actual endpoints. Other prerequisites need not automatically join the same group.
3. Preserve this placement intent in all/after-HEAD/relevant-version views where included. Avoid unnecessary global relayout of other groups or the milestone backbone.
4. Prevent missing/duplicate tasks/edges and card overlap, retaining OPS-095 placement rules. Do not change canonical edges, states or conditions for appearance.
5. Test MS-SPI/DOC-027 and renamed-ID fixtures for a single successor, chains and external prerequisites. If multiple origins or other unresolved placement blocks the fix, return facts/options without inventing a priority rule.
6. Run bounded regression, existing verify, OPS-095 placement, local-view/selection-following smoke and sync/check. Explain altered coordinate expectations against these requirements. No UI operation; explicitly note real-browser nonverification.

<a id="範囲受渡し"></a>
## Scope and handoff

Editable: RegistryApp/index.template.html, verify.cjs, Evidence/OPS-096/ and this Return; necessary generation allowed. No permanent canonical, Registry, Rules, Milestones, real Inbox or others' changes. Hime owns the implementation while Astra awaits return. No whole-layout redesign or unrelated fixes. No commit requested.

## Return（姫記入）

2026-10-18 姫・Opus 5.5。開始HEAD 46fd45a85。他者差分（CLAUDE_TASK.md、TASK_REGISTRY_APP.md、TASK_REGISTRY_V2.md、TASK_RULES_V2.md、本書）は不変。commitなし、画面操作なし、実ブラウザー未確認。

- 原因：QUALITY-005→DOC-026→DOC-027 は入口が MS-SPI→DOC-027 だけで骨格へ戻らない「escape」群。`graphLayout` は前提を持つ escape 群を深さ順に横へ並べ、上端を「横幅に重なる列の最下カード+drop」で決めていた。隣の MS-SPI-FOLLOWUP の縦列（13枚）が重なり、y=1849（最下段）へ送られていた。
- 修正（index.template.html +10行）：入口が1つの骨格マイルストーンだけの escape 群は、そのマイルストーンの下列（既存の below 列と同じ x+golden）へ、依存順（chainOrder）で縦に積む。上端はその列に重なる既存カードの最下+drop。入口が複数マイルストーンの群は従来配置のまま。ID固定座標なし。辺・状態・条件は不変。
- 結果：DOC-027 は MS-SPI の下（全体 1833,553／@head・0.6.0 506,553）。QUALITY-005・DOC-026 も同じ列の上側に並び、DOC-026→DOC-027・QUALITY-005→DOC-026・MS-SPI→DOC-027 は実際の両端間のまま。
- 座標の変化：群外のカードは @head 35枚・0.6.0 18枚で不変。全体表示では、どの骨格にもつながらない鎖の行（OPS-074/076/087/088/089/090）が、地図の最下端が上がった分だけ揃って136上がる（横位置・相互配置は不変）。既存 verify の座標期待は変更なし。
- 試験：`Evidence/OPS-096/layout.cjs`（修正前 `before_fix.txt` 8 FAIL → 修正後 `after_fix.txt` ALL PASS）。実データ3表示（配置の健全性・MS-SPI下・線の保持・群外不動）と、ID変更fixture（単独後続、後続鎖、外からの前提、長い外からの前提、混在、複数起点）。修正前の比較は `git show 46fd45a85:Maintanance/RegistryApp/index.template.html` を第2引数に与える。
- 回帰：sync（verify.cjs 通過）／`sync.py --check` 差分なし、OPS-095 placement（31件・8表示、問題0）、OPS-094 smoke_map PASS、OPS-093 smoke PASS、OPS-092 display-partition 違反0・edge-audit は修正前と同結果。
- 返す判断（未決定・未着手）：
  1. 単独タスクの上側退避レーン：入口が骨格マイルストーンで後続のない単独タスク（実データ PERM-079 ← GATE-0.6.0、fixture X1）は、従来どおりマイルストーンの右上（y=55）に置いており、「下」ではない。選択肢：(a) 現状維持（最下段送りではなく隣接）、(b) これも下列へ移す（PERM-079 の座標が変わる）。
  2. 複数起点：fixture（A1→M1→M2、A2→M2）は従来配置で健全（M1 は A1 列、M2 は A2 列）。優先規則は決めていない。

<a id="astra検収2026-10-18"></a>
## Astra review (2026-10-18)

Independent layout.cjs passed all checks; OPS-095 placement covered 31 cases/eight views without violations; sync --check matched. DOC-027 was below MS-SPI in all/after-HEAD/0.6.0 views; edges retained.

The single-successor fixture permits existing upper adjacency rather than 「下」. ALL PASS therefore does not establish every placement requirement. DOC-027's improvement is confirmed; overall acceptance awaits the user's single-successor decision. Multiple-origin priority was unresolved from assignment; preserve existing placement. Real screen unverified; no additional repair assignment/commit.

<a id="ユーザー判断と追加依頼2026-10-18--astra"></a>
## User decision and additional assignment (2026-10-18 / Astra)

Retain upper placement of single successors because the user intentionally uses it; the initial decision wait is resolved. Keep upper/lower selection as a future wish in the permanent canonical, without implementing it now.

<a id="姫への追加作業"></a>
### Additional work for Hime

- Single successors remain upper right; multiple-card stacks go below. Share the horizontal offset with upper placement (currently origin x+step) as one rule, not duplicate constants.
- If the lower stack's required width interferes with the next milestone, widen milestone spacing. Do not move lower cards to another horizontal offset. Limit widening to necessary intervals and effects on following positions; retain backbone order.
- Fixtures check single-above/multiple-below, matching offsets, widening when needed and no overlap. Check the current DOC-027 group too.
- Subsequent position shifts caused by widening are allowed necessary changes. Do not bend requirements merely to satisfy the old 「群外不動」 test. Explain changes/reasons in Return.
- Retain edges, displayed targets, input protection and local view. Run original regressions/sync/check. Multiple-origin priority remains outside scope.

Redelegate this scope to Hime; Astra awaits additional Return. Preserve original Return. No UI operations/commit.

## 追加Return（姫記入）

2026-10-18 姫・Opus 5.5。HEAD 46fd45a85 のまま、他者差分は不変。commitなし、画面操作なし、実ブラウザー未確認。

- 実装（index.template.html `graphLayout`）：初回の後処理（x+golden 列への積み上げ）は撤去した。代わりに、骨格の配置ループの前で、入口が1つの骨格マイルストーンだけで上側レーンに入りきらないカード（鎖・外からの前提）を持つ escape 群を、そのマイルストーンの `stack` に依存順で割り当てる。上側の単独レーンと下側スタックは共通の `lane`（=step）を水平オフセットに使う。下スタックの上端は、その列に重なる既存カードの最下+drop。複数起点の群は従来の後処理のまま。
- 間隔拡張：下スタックがあり、次のマイルストーンに下側カード（header 列、または below 列）がある場合だけ、その区間の送り幅を `lane+step−（header なら0／below なら golden）` 以上へ広げる。次のマイルストーンに下側カードがなければ広げない。下スタックを別の横位置へ逃がす処理はない。骨格順序は保持。
- 実データ：QUALITY-005・DOC-026・DOC-027 は MS-SPI の下に、オフセット 295 で縦に並ぶ。これは PERM-079（GATE-0.6.0 の上側単独レーン、オフセット 295）と一致する。全体表示では DOC-027 が 2033,553、@head・0.6.0 では 705,553。
- 座標の変化と理由：MS-SPI→MS-SPI-FOLLOWUP の区間だけが 390.5→494.5 に広がった。下スタック（MS-SPI+295）と、FOLLOWUP の below 列（13枚）が重ならないための幅。この結果、FOLLOWUP 以降のカード（全体32・@head 32・0.6.0 15）は一律に x+104 だけ動き、y は不変。MS-SPI までのカード（全体9・@head 3・0.6.0 3）は不動。全体表示の非接続鎖の行（6枚）は、地図の下端が上がった分だけ揃って136上がり、x は不変。PERM-079 は不動。既存 verify の座標期待は変更なし。
- 試験：`Evidence/OPS-096/layout.cjs` を改訂し、結果を `after_followup.txt`（ALL PASS）に置いた。実データ3表示の確認項目：健全性・骨格順序、PERM-079 が上、DOC-027 群が下でオフセットが一致、線の保持、MS-SPI までは不動・以降は一律の横ずれのみ、非接続行。fixture の確認項目：単独は上、鎖・外からの前提・長い外からの前提は下でオフセット一致、同じマイルストーンに単独+鎖、幅不足時は A1→A2 だけ 442→494 でほかの区間・左側は不変かつ非重複、裸のマイルストーン前では拡張なし、複数起点は健全性のみ。初回の `before_fix.txt`／`after_fix.txt` は初回Returnの記録として保存。
- 回帰：sync（verify.cjs 通過）／`--check` 差分なし、OPS-095 placement（31件・8表示、問題0）、OPS-094 smoke_map PASS、OPS-093 smoke PASS、OPS-092 display-partition 違反0、edge-audit 従前と同結果。辺・表示対象・入力保護・局所図に変更なし。
- 範囲外：複数起点の優先判断は未着手。

<a id="astra追加分受入2026-10-18"></a>
## Astra acceptance of additional work (2026-10-18)

Independently ran layout.cjs, all PASS. In all/after-HEAD/0.6.0 views confirmed single-above, DOC-027 group below, common 295px offsets, backbone order and actual edges. Width-shortage fixture widened the necessary interval without overlap. OPS-095's 31 cases/eight views and local-view/selection smoke passed; sync --check matched. Accepted within the user's additional decision. Multiple-origin priority remains unresolved; real browser unverified. Assignment ended; awaiting commit.

User commit approval on 2026-10-18 makes OPS-096 DONE.
