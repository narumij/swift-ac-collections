# 場面ごとに「判断の次に欲しい情報」を探す限定試行

## TL;DR（人間向け）

判断の次に欲しい情報を3回の限定試行で探し、維持対象が作業内訳に具体化される一方、入力にない制限も加わることを確認した記録。場面別に根拠の場所・適用境界・追加不要という候補を整理して完了した。固定の共通項目や制度は採用せず、追加情報の独立効果・工数削減・内部原因は未確認。

OPS-102 / 2026-10-18 / Drafting and acceptance: Astra / Trial: Claude (姫). The user approved three round trips and preparation of the first assignment.

<a id="問いと範囲"></a>
## Question and scope

Make concrete the user's questions 「場面がかわったときに何をキャッシュすべきか」 and 「初期状態として1番が判断だけど、2番に何が欲しいか」. Start from a judgment and look for useful additional information by situation. Reasons, validity conditions, and work status are examples, not directions toward which to steer responses. Adding nothing or finding different answers by situation are valid results.

Treat the genetic-algorithm idea as inspiration for trying combinations and retaining useful ones. Do not implement an algorithm, automatic selection, LRU, or capacity limits. Do not trim existing caches; common rules, authority, and the current assignment remain effective. Do not hide them for the experiment.

<a id="3回の区切り"></a>
## Three rounds

1. From a few recent cases, identify information that the judgment alone did not supply and that required going back for, and propose a second item.
2. After accepting the first round, Astra specifies one candidate and a small task to try judgment plus candidate (「判断＋候補」). Return what helped, what was unnecessary, and what was still missing. Fix the work and editing scope in that assignment.
3. Using only existing results, briefly organize candidates by situation and their applicability limits.

Only round 1 is assigned now. Explicitly assign the next round after acceptance; do not continue automatically. Shorten if there is enough material, and do not expand into searching the full history merely because no result appears. If selecting later work requires a new user judgment, return that point.

<a id="完了条件"></a>
## Completion criteria

For a few situations, organize what might be worth adding, with evidence, burden, and limits. No effect is also a result. Distinguish actual reference, personal recollection, and present speculation. Do not establish efficiency improvement from character counts or reference counts alone. Broad adoption and repair of existing caches are excluded.

<a id="第1回の正式依頼"></a>
## Formal assignment for round 1

Select at most three recent cases from your own work that you can explain from memory and nearby return records. Use what you recall; do not search to fill a quota. OPS-096〜101 are candidates, not a fixed selection.

Return each case briefly in this format:

- Situation and the judgment held at that time (what had been decided).
- Missing information you went back for. State whether this is an actual reference, a recollection report, or present speculation.
- Why it was needed. Distinguish information that changes and must be checked in the canonical source each time from candidates to add to a cache.
- What to add as the second item (「2番目」), or that nothing needs adding. Start with one candidate; do not nominate everything together.
- Supporting document, section, and fixed revision. If nearby records cannot substantiate it, leave it unverified and stop there.

Finally, recommend one candidate for a small round-2 trial. A proposal based on personal experience is sufficient; no unique optimum is required. Label untested effects as predictions. Keep the report to roughly one page in a table or short prose; conversational reporting may contain only key points.

Inputs are the current assignment, your most recent returns, and necessary direct references only. Record starting HEAD. No inventory of all past caches/history, investigation of automatic memory, or new product work for the experiment is needed.

Edit only this document's round-1 Return. No delegation to change the original assignment, Registry, rules, caches, product, Studio, or other canonical documents, or to commit. The standing delegation for an optional impressions log remains. Stop after returning; Astra handles acceptance and the next assignment.

## 第1回 Return（姫記入）

2026-10-18 姫・Opus 5.5。開始HEAD `e26371dc81c3de10e356c0a09849283b444f1dfa`。入力は自分の直近の返却と、その直接の参照先だけ。新しい探索はしていない。変更したのは本Returnだけで、commitなし。

### 事例1：OPS-096初回（途中マイルストーンの群の配置）

- 持っていた判断：途中マイルストーンから始まる群は、その下へまとめる（当時のTASK_REGISTRY_APP.md 該当節）。
- 取りに戻った情報（実際の参照）：既存の右上配置（単独タスク）が意図されたものかどうか。コードのコメント（`46fd45a85`のindex.template.html 312〜313行「upper escape lane…has no task-status meaning」）までは見た。ユーザーの意図はどの記録にもなく、選択肢として返した（`b2f9e8e4`のMILESTONE_BRANCH_LAYOUT.md 36行）。ユーザーの答えは「意図して利用」（同47行）。
- 何に必要だったか：新しい判断を当てたときに、壊してはいけない既存の挙動を知るため。これは判断に付く性質で、毎回変わる状態ではない。キャッシュへ添える候補になる。
- 2番目の候補：**判断が変えないもの（維持する既存の挙動と、その理由）**。

### 事例2：OPS-101第2回 §3（OPS-089 USER_ONLY）

- 持っていた判断：5案の採否はユーザーが決め、AIは代行しない。
- 取りに戻るべきだった情報（記憶による報告＋記録で確認）：「催促しない」の根拠の場所。私は取りに戻らず、独自の付け足しと誤分類した。根拠は共通規則のTASK_RULES_V2.md「状態の扱い」のUSER_ONLY（`3847fe31d`の本パイロット文書166行、Astra補正）。
- 何に必要だったか：文が写しか解釈かを決めるため。根拠の場所は変わりにくいので、キャッシュへ添えられる。根拠の中身（規則の文面）は毎回正本で確かめる。
- 2番目の候補：**根拠の場所（個別正本に加えて、効いている共通規則の節名）**。

### 事例3：OPS-101第2回 §4（SPIバッジは登録の後）

- 持っていた判断：DOC-027のバッジはMS-SPIの後。
- 取りに戻った情報（実際の参照）：正本の今の場所。0.6.1の挿入で`Milestones/0.6.0/10_SPI.md`から0.6.1へ移っていた。移動は依頼文に書かれていた（`3847fe31d`の本パイロット文書103行）。
- 何に必要だったか：判断が今も有効かを確かめるため。置き場所は版の挿入などで変わるので、毎回正本（Registryの接続行・Milestones）で確かめる情報。キャッシュに置いても、また古くなる。
- 2番目の候補：**追加不要**。固定版と節名の入口があれば足りた。

### 第2回で試す候補（推奨）

事例1の「判断が変えないもの」を一つ勧める。

- 理由：3件のうち、取りに戻っても記録から得られず、ユーザーに聞くしかなかったのは事例1だけだった。判断と一緒に書いておかないと、後から再取得できない種類の情報に見える。
- 事例2の「根拠の場所」は、共通規則を一手引く習慣でも補える（姫の自動メモリーに10-18に記録済み）。だから、キャッシュの欄にする必要は事例1より低い（推測）。
- 効果は試していないので予想。余計になりうる点：「変えないもの」は書き出すと際限がない。そのため、試すときは「その判断を当てるときに、実際に触れる既存挙動だけ」に絞るのがよさそう（予想）。


<a id="第1回-astra受入2026-10-18"></a>
## Astra acceptance of round 1 (2026-10-18)

Accepted the three cases as candidate generation. In the first Return, Astra acceptance, and additional assignment in b2f9e8e4's `Maintanance/Current/REGISTRY_STUDIO_MILESTONE_BRANCH_LAYOUT.md`, confirmed that the single-successor issue was returned and the user's intended upper placement retained. In 3847fe31's `JUDGMENT_ORIGIN_CLASSIFICATION_PILOT.md`, confirmed the classification correction to common rules and the SPI destination provided within the assignment. The original Return's abbreviations 「MILESTONE_BRANCH_LAYOUT.md」 and 「本パイロット文書」 refer to these actual files respectively.

Do not read 「ユーザーの意図はどの記録にもなく」 as verified absence from all records. Treat it as the person's report of asking after not finding evidence within the sources consulted at the time. Case 2 is information that should have been retrieved, not a successful actual retrieval. Case 3's 「追加不要」 is a situation-specific proposal. Do not turn this into an obligation to read all common rules every time or a system of adding invariants to every judgment.

The round-2 candidate is 「判断が変えない既存挙動と理由」. Try it as one additional piece of information, with effectiveness unverified. Also observe whether including the invariant in the judgment itself would suffice and whether the information is duplicated.

<a id="第2回の正式依頼維持事項を添えた作業内訳の予備試行"></a>
## Formal assignment for round 2: preliminary work-breakdown trial with invariants

Edit only this document's round-2 Return. Using round-1 acceptance as input, produce a short work breakdown for the completed case below without reimplementing it. Common rules and the current assignment remain effective; do not change existing caches.

<a id="入力"></a>
### Inputs

- Situation: preparing a layout change to place a group of multiple cards emerging from an intermediate milestone below that origin.
- Judgment: stack multiple cards vertically below the origin. Use the same horizontal offset as the upper placement; make room for insufficient width by widening milestone spacing.
- Second information item: retain single successors at the existing upper-right position, because the user intentionally uses the image of 「大気圏外へ送り出す」.
- Fixed evidence: layout requirements around 「途中マイルストーン」 in `5780db57`'s `Maintanance/Current/TASK_REGISTRY_APP.md` and 「ユーザー判断と追加依頼」 in `Maintanance/Current/REGISTRY_STUDIO_MILESTONE_BRANCH_LAYOUT.md`. Consult only relevant sections if needed; no new history search.
- Do not change edges, states, conditions, displayed targets, or the local diagram. Priority among multiple origins remains unresolved. This is a small desk exercise using a completed case, not an implementation assignment.

<a id="作業と返却"></a>
### Work and return

1. From these inputs, produce at most five lines combining changes, invariants, and verification.
2. If you actually checked any additional information, briefly record where and why. If none was needed, say so.
3. Briefly state where the second item helped, whether it was unnecessary or duplicated the judgment itself, and what was still missing. If the effects of the reason and the invariant cannot be distinguished, leave that unverified.
4. Briefly say whether this case suggests value in continuing to try the approach.

Keep the whole response to about half a page. Record starting HEAD and consulted revision. Since this is a known case, do not claim the counterfactual that it would have failed without the extra information (「追加情報なしなら失敗したはず」), or reduced time/usage. No implementation, tests, cache repair, changes to other canonical documents or the Registry, or commit. Stop after returning. Round 3 will be assigned after acceptance.

## 第2回 Return（姫記入）

2026-10-18 姫・Opus 5.5。開始HEAD `e26371dc81c3de10e356c0a09849283b444f1dfa`。参照版は`5780db577b0f2705db090c8ec23cceb213762a35`。机上の作業だけで、実装・試験・キャッシュ・他正本・Registryは変更していない。commitなし。

### 1. 作業内訳（5行）

1. 変更：起点が一つの骨格マイルストーンで、上側に入りきらない群（鎖、外からの前提を持つもの）を、起点の下へ依存順に縦に積む。水平位置は、上側配置と共通の値にする。
2. 変更：下に積んだ群が次のマイルストーンの下側カードと重なるときだけ、その区間のマイルストーン間隔を広げる。骨格の順序は保つ。
3. 維持：単独後続は右上のまま（送り出し）。辺・状態・条件・表示対象・局所図は変えない。複数起点の群は従来の配置のまま。
4. 検証：単独は上、複数は下。上下のオフセットが一致する。幅が足りないときは必要な区間だけ広がり、カードが重ならない。実データのDOC-027群がMS-SPIの下に来て、実辺の両端が保たれる。
5. 検証：既存の配置試験、局所図・選択追従のsmoke、sync/`--check`。

### 2. 追加で確認した情報

- `5780db57`のTASK_REGISTRY_APP.md「途中マイルストーンから始まるタスク群の配置」（30行〜）の文面を見た。理由：入力の判断と2番目の情報が、参照版の正本と同じ内容かを確かめるため。`b2f9e8e4`からの差分は、同書の末尾に倍率操作の節が足されただけで、該当節は同じだった。
- MILESTONE_BRANCH_LAYOUT.mdは`b2f9e8e4`→`5780db57`で差分なし。中身は読み直していない。

### 3. 2番目の情報の効き方

- 役立った所：内訳の3行目（維持）と4行目（「単独は上」の検証）は、2番目の情報から直接書けた。
- 重複：判断本体の「水平位置は上側配置と同じオフセット」は、上側配置が残ることを前提にしている。だから、維持対象は判断本体にも半分含まれていた。
- 理由と維持対象のどちらが効いたか：内訳を書くのに効いたのは維持対象。理由（「大気圏外へ送り出す」）で変わった行はなかった。理由が効くのは、境界の事例を判定するときだと思うが、今回の作業では確かめていないので未確認。
- なお不足：「単独」と「複数」の境目。例えば、同じ起点から単独のカードが2枚出る場合や、外からの前提を持つ単独カードはどちらか。この情報は2番目の情報からも判断本体からも決まらない。実際の実装では「上側レーンに入りきるか」で分けたが、これは実装上の選択で、ユーザーの判断ではない。

### 4. 継続の価値

少しある。維持対象は、内訳の「維持」と「検証」の行にそのまま入った。ただ、判断本体と半分重なっていた。判断本体に維持の条件として書かれていない場合に限って添えると、重複が減りそう（予想）。今回いちばん欲しかったのは、維持対象よりも、判断が当てはまる範囲の境目（「単独」の定義）のほうだった。


<a id="第2回-astra受入補正2026-10-18"></a>
## Astra acceptance and correction of round 2 (2026-10-18)

Compared the inputs with the five returned lines and accepted this as a desk trial observing how information was used, not as a correct implementation plan. Findings: invariants became concrete maintenance and verification items; the reason's effect was unverified; there was overlap with the judgment and a perceived lack of applicability boundaries.

Work-breakdown item 1's 「上側に入りきらない群」 and item 2's 「次のマイルストーンの下側カードと重なるときだけ」 are restrictions absent from this input. The judgment is to place multiple-card groups below and widen spacing when width is insufficient; do not narrow it to those added conditions. The Return itself identifies 「上側レーンに入りきるか」 as an implementation choice; distinguish it from requirements. Preserve the original Return and do not adopt these conditions as new requirements or repair assignments.

The need to clarify applicability boundaries is material for consideration, but feeling that lack in this trial does not decide adoption of a new cache field or an implementation change. The case was familiar, canonical documents were consulted again, and the judgment overlapped with the added information, so neither the independent effect of additional information nor effort reduction was measured.

<a id="第3回の正式依頼場面別の候補と限界を整理"></a>
## Formal assignment for round 3: organize candidates and limits by situation

Delegate this round's editing scope to 姫. Inputs are only this document's round-1 and round-2 Returns and Astra's acceptance/corrections. No additional research, implementation, trial, or cache changes are needed.

In about half a page, organize the following:

1. Second-item candidates by situation: invariants, evidence location, no addition, and applicability boundaries. Distinguish what was tried from proposals or perceived gaps only.
2. Conditions under which an addition might be worthwhile and whether including it in the judgment would suffice. Do not force a single common second item for all situations.
3. What this trial can and cannot establish. Include the addition of conditions absent from the assignment; good information does not guarantee correct application.
4. Briefly recommend collecting information when needed in practical work, further trials, or deferral, with reasons. These remain proposals; do not start new work from them.

Separate impressions from facts. Do not create a classification system or mandatory template. Edit only Return, then stop; no commit. Astra will receive it and report results to the user.

## 第3回 Return（姫記入）

2026-10-18 姫・Opus 5.5。入力は本書の第1・2回ReturnとAstraの受入・補正だけ。新しい調査・試行はしていない。変更したのは本Returnだけで、commitなし。

### 1. 場面ごとの2番目の候補

| 場面（事例） | 候補 | 状態 |
|---|---|---|
| 新しい判断を既存の挙動に当てる（OPS-096） | 維持対象（＋理由） | 第2回で机上試行した。維持・検証の行に入った。理由の効果は未確認 |
| 文が写しか解釈かを決める（OPS-101 §3） | 根拠の場所（共通規則の節名を含む） | 提案だけ。取りに戻るべきだったのに戻らなかった例で、試していない |
| 判断が今も有効かを確かめる（OPS-101 §4） | 追加不要 | 提案だけ。場所は変わるので正本で確かめる |
| 判断を当てはめる（第2回で出た不足） | 適用範囲の境目（例：何を「単独」とするか） | 不足を感じただけ。候補として試していない |

### 2. 添える価値がありそうな条件（提案）

- 維持対象：判断本体に維持の条件が書かれていないときだけ、添える価値がありそう。第2回では、判断本体の「上側と同じオフセット」が上側配置の存続を前提にしていたので、半分は重なっていた。書けるなら判断本体に含めれば足りる。
- 根拠の場所：判断本体の外にある情報。とくに共通規則は個別の判断に書かれにくいので、添えるならこれ。ただし、共通規則を一手引く習慣でも補える。
- 適用範囲の境目：判断の一部とも言える。境目が未決なら、キャッシュに添えるより、判断の持ち主に返す種類の情報。
- 全場面に共通する2番目は、この3件では見つからなかった。

### 3. 言えること・言えないこと

- 言えること（事実）：
  - 第2回では、維持対象が内訳の維持・検証の行に具体化された。
  - その一方で、私は入力にない絞り込みを2つ加えた（「上側に入りきらない群」「下側カードと重なるときだけ」）。どちらも、自分が以前に実装した内容の記憶から来ている（Astra補正）。
  - 良い2番目の情報を渡しても、正しく適用されるとは限らない。受け手の側の古い知識（ここでは過去の実装）が、判断を狭める方向に混ざりうる。
- 言えないこと：
  - 追加情報だけの効果。既知の事例で、正本も読み直しており、判断本体とも重なっていた。
  - 工数や使用量の削減。
  - 理由が効く場面があるかどうか。
  - 適用範囲の境目を添えたら不足が埋まるかどうか（未試行）。

### 4. 推奨（提案）

**実務で必要なときに拾う**を推奨する。

- 理由：
  - 候補は場面ごとに違い、共通の2番目はなかった。
  - 試せたのは1件だけで、それも既知の事例だった。
  - 追加試行をするなら、未知の作業で行わないと、独立した効果は見えない（推測）。
- 拾うときの形：判断を当てる作業で、維持対象や境目に迷ったら、その場で判断の持ち主に確かめる。答えを判断本体のほうに書き足してもらう。今回、単独後続の扱いはこの流れで要求に入った。

### 感想（事実とは別）

第2回でいちばん驚いたのは、情報が足りなかったことより、自分の記憶が足しすぎたことだった。キャッシュは判断を写すだけでなく、受け手にも「前にこう作った」というキャッシュがある。そちらは、写しの出どころの表示が付かないまま混ざる。


<a id="第3回-astra受入限定試行の総括2026-10-18"></a>
## Astra acceptance of round 3 and limited-trial conclusion (2026-10-18)

Compared with the first two returns and acceptance corrections and accepted round 3's organization. The three limited assignments are closed. Set OPS-102 to WAITING_USER (awaiting commit confirmation); do not assign further research, implementation, or cache changes.

Astra sees continuing value in collecting information that a judgment alone does not supply (「判断だけでは足りない情報」), according to the situation. Invariants becoming concrete work-breakdown items was observed. Candidates also emerged for evidence location, applicability boundaries, and no addition, but their respective efficiency improvements are unverified. This is not a conclusion to introduce a fixed second item or mandatory template. Retain it as a proposal: use candidates when gaps arise in practical work, check what existing canonical documents can establish cheaply, and return only unresolved judgments to their owner.

Round 3's 「過去の実装の記憶から来ている」 is 姫's own causal explanation. Astra independently confirmed only the fact that two conditions absent from the inputs were added. Distinguish the observation that good additional information does not guarantee correct application from the self-report attributing the cause to internal memory. Preserve the original Return.

Effort/usage reduction, the independent effect of adding reasons, and generalization to unfamiliar work remain unverified. This trial produced situation-specific candidates and exposed the risk of adding too much familiar information as well as too little information. Do not proceed to broad institutionalization or automatic selection; retain these as materials to draw on when practical work requires them.

2026-10-18: the user's commit approval updated OPS-102 to DONE. Subsequent research topics are maintained in the [OPS-103 permanent canonical document](AI_COLLABORATION_BASIC_RESEARCH.md). The initial experiment has not yet been assigned.
