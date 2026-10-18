# 依存見取り図の自動配置への助言依頼

## TL;DR（人間向け）

依存見取り図の配置を、固定IDの指定や手調整からコードでの自動導出へ寄せる案を姫に聞いた助言依頼と、その限定反映の記録。骨格の最長路と骨格間経路の横並びの導出を反映し、全座標の回帰一致とID置換不変を確かめて受け入れた。交差の最適化・枝単位fallback・前回位置の保持・layoutHintsは未実装で、助言の残りを自動で始める許可ではない。

2026-10-16, Astra. OPS-052, parent OPS-048. Owner: Claude (Hime); acceptance: Astra.

<a id="依頼と境界固定"></a>
## Request and boundaries (fixed)

User request: 「依存見取り図のレイアウトに関して、AI負担を減らしてコードでの自動を増やすアイデアないか、ひめに依頼して聞いてみよう」 (let's ask Hime for ideas to reduce the AI's burden and increase automation in code for the dependency-map layout).
Read the current implementation and return small, implementable improvement proposals that reduce the burden of the AI adjusting placement case by case. This is design advice only; settling the method, implementation, Registry updates and commit are not included. Agreeing with the current proposal is not a condition.
You may edit only from 「Claude回答」 onward in this document and the OPS-052 Return field in CLAUDE_TASK.md. Do not change the request text or the input code. The standing permission to append to the impressions document is kept.

<a id="固定入力"></a>
## Fixed input

Base commit: `bd70dc4741c4d80eb850446795081cb6e740ae4b`. Refer to the content of this commit for the following. If the working tree has changed, read with `git show <基準commit>:<path>`.

- `Maintanance/RegistryApp/index.html`: graphData, graphLayout, the SVG graph, dependency rewiring.
- `Maintanance/RegistryApp/registry.json`: real data (38 tasks, 9 task edges, 6 displayed milestones, 13 relations).
- `Maintanance/RegistryApp/verify.cjs`: the current verification.
- `Maintanance/RegistryApp/README.md`: common rules and unresolved items.

Do not read through the huge embedded document JSON; read only the needed functions and the separate JSON. The permanent map and the document viewer are out of scope this time.

<a id="ユーザーと調整した表示意図"></a>
## Display intent agreed with the user

- Follow the skeleton horizontally, and gather merging branches below.
- Horizontal shift is the short side of the golden ratio of the node width (about 38.2%), and vertical spacing is a common value.
- The purpose of placing PERM-079 above is to let connecting lines avoid crossing. It is not a classification of the work's meaning or state.
- Even in series, RELEASE-075 → 076 is vertical while QUALITY-005 → DOC-026 → DOC-027 is horizontal. How to decide mixing horizontal and vertical is unresolved.
- Placement does not create new dependencies, execution order or permission to start.
- Operation is opening the local HTML in Safari. Processing may be split between static generation and in-browser, but also evaluate the burden of introducing and maintaining it.

<a id="現状と相談したいこと"></a>
## Current state and what to consult on

Currently branches are gathered from their merge target and merge stage, and the skeleton order and the horizontal arrangement of the 3 SPI steps remain as designations. Upper placement is a provisional judgment, "a branch that does not merge into a later skeleton node", and crossings are not measured. If the check fails, the whole map reverts to dependency-order placement.

1. When reducing fixed-ID designations, what can be derived from structure, and what alone should remain as the human's display intent?
2. With what few rules or evaluation metrics can upper/lower assignment, crossing avoidance and horizontal/vertical mixing be handled? Also consider proposals that do not tie serial/parallel Flow directly to display direction.
3. Can the whole map moving a lot because of one connection change be suppressed? The trade-off between keeping current positions and reducing crossings.
4. The benefits/costs of a small home-made heuristic versus existing layout methods and libraries. Not an exhaustive survey; a comparison of candidates against the current state.
5. The smallest next step to try, and the fixtures, counterexamples and verification method for judging good or bad.

Separate facts from reading the code, proposals and unverified hypotheses. If possible, attach outline procedures or pseudocode. Acceptance conditions: do not replace the user's display intent with guesses, and show the boundary between geometric computation and semantic judgment.

## Claude回答

2026-10-16 / Claude（姫、Opus 5.5）。基準commit `bd70dc47`の`index.html`（`graphData`・`graphLayout`・`graph`）、`registry.json`の`edges`・`milestoneRelations`・`milestones`、`verify.cjs`の配置検査行を読んだ。
ラベル：**[事実]** コードとデータで確かめたこと／**[提案]**／**[仮説]** 未検証。

### 0. 読んだ事実の要約

- **[事実]** 固定IDは2か所。骨格`backbone=['MS-DOC','MS-060','MS-070','MS-SPI','MS-HUMAN','QUALITY-001']`と、横並び`horizontal=new Set(['QUALITY-005','DOC-026','DOC-027'])`。
- **[事実]** 各taskは「最初に届く骨格node」と距離で列を決める。距離は`SEQUENCE`かつ行き先が到達点でない辺で0、それ以外で1（`destinations`）。Flowが列の決定に入っている。
- **[事実]** 骨格へ合流しない枝は、骨格の直接の後続なら上側の`escape`（現データではPERM-079）。
- **[事実]** `valid()`は「全node配置済み」「辺が左→右か同列で上→下」「カード非重複」だけを見る。交差は数えていない。不成立なら全体を依存深さ順へ落とす（全体fallback）。
- **[事実]** データ上、骨格と枝の関係は次の3通りに分かれる。
  - QUALITY-005→DOC-026→DOC-027：MS-070から出てMS-SPIへ入る（骨格から出て、後の骨格へ入る）。現在は横。
  - RELEASE-075→RELEASE-076：どちらもMS-070へ入るだけで、骨格から出ていない。現在は縦。
  - PERM-079：MS-060から出て、どこへも入らない。現在は上。

### 1. 構造から導けるものと、残す表示意図（問1）

**[提案]** 固定IDは2つとも構造から導ける見込みがある。

- **骨格**：到達点（`kind==='milestone'`）だけの部分グラフで、最終到達点（出次数0の到達点）へ至る**最長路**を骨格にする。現データでは`MS-DOC→MS-060→MS-070→MS-SPI→MS-HUMAN→QUALITY-001`が最長で、MS-VALIDATION→MS-070は短いので骨格から外れる。現行の固定列と一致する見込み（**[仮説]** 実行して確かめていない）。
- **横か縦か**：枝を「骨格から出るか」「骨格へ入るか」の2ビットで分類すれば、Flowを使わずに現行の3通りを説明できる（2節の表）。

人間の表示意図として残すのは、構造で決まらないときの**上書きだけ**にする。

- 置き場所はコードではなくJSONの`layoutHints`（例：`{"backbone": [...]}`、`{"lane": {"PERM-079": "above"}}`）。空なら導出結果を使う。
- 上書きは「見た目の指定」であり、依存・順序・許可を作らない、と`README.md`の共通規則に書く。

### 2. 上下振分け・交差・横縦混在の規則（問2）

**[提案]** 枝の分類は次の表の4通り。骨格nodeを除き、骨格以外のnodeを弱連結成分ごとに「枝」とまとめ、枝が骨格のどこから出てどこへ入るかで決める。

| 骨格から出る | 骨格へ入る | 種類 | 置き方 | 現データの例 |
| --- | --- | --- | --- | --- |
| あり（列i） | あり（列j>i） | 経路 | 列iとjの間に**横**に並べる | QUALITY-005→DOC-026→DOC-027 |
| なし | あり（列j） | 供給 | 列jの手前に**縦**に積む | RELEASE-075→076、RBT-*→QUALITY-001 |
| あり（列i） | なし | 退避 | 列iの次の**上**側 | PERM-079 |
| なし | なし | 独立 | 骨格の外（現行どおり別表示） | — |

- 横縦は「枝が骨格のどこからどこへ渡るか」という幾何で決まり、`SEQUENCE`/`PARALLEL_JOIN`には依存しない。直列でもRELEASE-075→076が縦、QUALITY-005→DOC-027が横になる理由を、これで説明できる。
- 上下は、表の「退避」だけを初期値で上にし、その他は下。そのうえで交差数を評価指標にする。
- 交差数は、辺を直線の線分として近似し、全組の交差を数える（40node・二十数辺なら全組で十分軽い）。曲線のbezierでも、線分近似で順位付けには足りる見込み（**[仮説]**）。
- 調整は「枝ごとに上/下の2択」と「同じ列に積む枝の順番」だけにする。枝の数kが小さければ2^k通りを全部試し、交差数が最小のものを選ぶ。

概略：

```text
backbone = longestMilestonePath(nodes, edges)          // layoutHints.backbone があればそれを使う
branches = weakComponents(nodes - backbone)
for b in branches:
  i = min backbone column with an edge backbone[i] -> b   (なければ none)
  j = min backbone column with an edge b -> backbone[j]   (なければ none)
  b.kind = route | feeder | escape | isolated   (上の表)
  b.side = hints.lane[b] ?? (b.kind == escape ? above : below)
candidates = all side assignments for non-hinted branches   (2^k、kが大きければ貪欲法)
best = argmin over candidates of (crossings * 1000 + displacement(prevPos))
place(best)  // 横は step、縦は row、横ずらしは golden で現行値をそのまま使う
```

### 3. 1本の変更で全体が動くのを抑える（問3）

**[提案]**

- **全体fallbackをやめ、枝ごとにする。** 不成立の枝だけを依存深さ順で、その枝に割り当てた列の範囲内に置き直す。他の枝と骨格は動かさない。
- **前回位置を覚える。** 直前の`pos`をlocalStorage（またはメモリ）に置き、評価に`displacement`（前回位置からの移動量の和）を足す。交差を優先し、同点なら動きの少ない案を選ぶ。
- 骨格の列順は、骨格の集合が変わらない限り固定する。つなぎ替えで動くのは、原則その枝と、同じ列の積み順だけになる。

### 4. 自前の規則か、既存のライブラリか（問4）

| 候補 | 利点 | 費用 |
| --- | --- | --- |
| 自前の小さい規則（2・3節） | 黄金比のずらし・骨格を横に追う意図をそのまま保てる。依存なしのまま、ローカルHTMLで動く。40node規模なら全探索で足りる | 規則が増えると読みにくくなる。交差の最小化は近似 |
| dagre（Sugiyama型の層状配置） | 層割り当て・交差削減が既製で、コードが減る | 骨格を一直線に保つ・枝を上下に逃がす、という意図を制約で表しにくい。ライブラリの埋め込みかCDNが要り、「依存なし」でなくなる |
| ELK（layered） | 制約・ポート・優先度まで表現でき、品質が高い | 大きい（数百KB級）。設定が多く、保守の負担が今の規模に見合わない |

**[提案]** 自前の規則を推す。今の負担は「固定IDとその場の手調整」で、層状配置の汎用アルゴリズムが要る規模ではない。既製の交差最小化が欲しくなったら、そのときdagreを試す。

### 5. 次の最小の一歩と検証（問5）

**[提案]** 最初の一歩は**分類関数だけ**を入れることにする。配置の計算は変えない。

1. `classifyBranches(nodes, edges, backbone)`を書き、`horizontal`集合と`escape`判定をこの結果で置き換える。骨格の固定列は、まだ残す。
2. 現データで、全nodeの位置が現行と**完全一致**することを`verify.cjs`で確かめる（回帰）。一致しなければ、規則か現行の意図のどちらかが違うので、そこで止めてユーザーへ返す。
3. 一致したら、骨格の導出（`longestMilestonePath`）を入れ、同じく完全一致を確かめる。
4. 交差数の関数を足し、現データの交差数を表示する（まだ最適化しない）。値を見てから上下の全探索へ進む。

fixtureと反例：

- 経路が骨格を一つ飛ばす（列iからi+2へ入る）。横の範囲が正しく2列ぶんになるか。
- 供給の枝が、2つの骨格nodeへ入る。最初の列に積むか。
- 枝が骨格の**前の**列へ入る（逆向き）。`valid()`で落ち、その枝だけfallbackになるか。
- 骨格に新しい到達点が挿入される。最長路が変わっても、既存の枝の相対位置が保たれるか。
- 退避の枝が2本ある。上側で重ならないか。
- つなぎ替え1本の前後で、動いたnode数を数える（3節の効果の確認）。

### 幾何と意味の境界

| 側 | 持つもの |
| --- | --- |
| コード（幾何） | 骨格の最長路、枝の分類、上下・積み順、交差数、移動量、重なりの検査 |
| データ・人（意味） | どのnodeが到達点か（`kind`）、最終到達点、`layoutHints`の上書き |
| どちらも作らないもの | 配置から依存・実行順・着手許可・状態を導くこと |

骨格は「到達点の最長路」という幾何の規則で導くが、到達点かどうかは意味の側の入力である。導出結果が意図と違ったときは、規則を足すのではなく`layoutHints`で上書きする。

<a id="astra受入"></a>
## Astra acceptance

2026-10-16, Astra. Accepted the advice. Claude's original answer is not changed.

- Computed the longest path over arrival points only on the real data; it matched the current 6-node skeleton. Examined the entries and exits of weakly connected components and confirmed that the 3 SPI tasks are a route, RELEASE-075 and 076 are feeders, and PERM-079 is a non-merging branch.
- On the user's 「拾えるもの拾って反映して」 (pick up what you can and apply it), applied to the implementation the derivation of the skeleton's longest path and the horizontal judgment for components connecting earlier and later skeleton nodes. Removed the fixed-ID skeleton row and the horizontal set.
- Saved all node coordinates just before applying into layout-reference.json and verified an exact match of all coordinates. Also confirmed that replacing every ID with another name gives the same coordinates. The existing checks for edge removal, connection changes, duplicates and rectangle overlaps also pass.
- Boundary of partial adoption: the column decision for feeder branches keeps the existing distance that includes Flow. No full change folding RBT-011 → RBT-001 into the same vertical column. The branch classification alone is not treated as determining all placement.
- Not implemented: upper/lower crossing optimization, per-branch fallback, keeping previous positions, and layoutHints. crossings×1000 + displacement can reverse priorities depending on scale, so if adopted, consider lexicographic comparison or the like. Whether exhaustive search is feasible is limited by the number of branches, not nodes. The performance and size of the library comparison were not verified this time.

The advice and this limited application are confirmed. OPS-052 is DONE by the user's commit instruction. Adopting or executing the additional proposals does not start automatically with this acceptance.
