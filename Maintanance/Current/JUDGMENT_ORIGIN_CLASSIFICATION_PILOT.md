# コピー判断とオリジナル判断を区別する運用の限定試行

## TL;DR（人間向け）

判断の写しに、実装事実や作成者の解釈が混ざる様子を、少数のキャッシュで照合した試行です。初期の未実施記述より後段の受入・総括を見ます。

出典が個別正本にないだけで独自判断とは言えません。この結果を、全件分類や安全な自動退避の承認にはしていません。

<!-- OPS-133: 2026-10-19 / Astra。本文を読む入口。決定・状態の正本を置き換えない。本文の結論や境界を変えたときに一緒に見直す。 -->


OPS-101 / 2026-10-18 / Astra. Registered at the user's request: 「制度整備としてはオリジナル判断とコピー判断を分ける運用を試験開始」「タスク化」. This initial entry prepares the trial; existing caches had not yet been classified or changed.

<a id="目的"></a>
## Purpose

Retain the user's intention that decision caches primarily copy canonical decisions. Test identifying provenance in a few entries, conditions for safe offloading and record-maintenance effort. No finding is made that original judgments are actually mixed into existing caches.

<a id="試す区分"></a>
## Trial categories

| Category | Evidence for classification | Treatment |
| --- | --- | --- |
| Copied decision | An identifiable source decision supports the summary's meaning and applicability | Retain source, location and update conditions. Being a copy does not guarantee freshness or correctness. |
| Original judgment | Records establish that it is an interpretation, hypothesis or proposal arising during work | Separate it as an unsettled proposal, return only necessary items to the decision owner, and do not automatically promote it into a canonical decision. |
| Unverified provenance | Bounded comparison cannot establish evidence or origin | Leave unknown, recording checked scope and next leads. Do not infer invention, error or nonexistence of an original decision. |

Origin and approval are separate axes. Do not treat a source decision made by the user as 「オリジナルだから未承認」. This trial separates canonical copies from unsettled interpretations arising in work. Decision authority remains governed by existing rules.

<a id="実施前の範囲固定"></a>
## Fixing scope before execution

Specify the owner, documents, small set of entries, count, reference revision and output location. If cache editing is needed, confirm its owner's occupancy and follow existing pre-update commit rules. Do not explore every cache or automatic memory while scope remains undefined.

<a id="最小の試行と返却"></a>
## Minimal trial and return

- Compare selected entries' sources and meanings within bounds; record category, evidence and checked scope in a separate trial record first, preserving originals.
- Identify portions where copies and interpretations coexist. Missing provenance alone does not establish originality.
- Report difficult classifications, avoided rediscovery and maintenance effort; precise timing is optional.
- Stop expanding searches as unverified provenance. Report unnecessary/dangerous findings without starting out-of-scope cleanup.

<a id="完了条件と次への接続"></a>
## Completion and next step

Return classifications for the assigned scope, usefulness, burden/misclassification concerns and unknowns in a receivable form. Feed results into [OPS-099](JUDGMENT_CACHE_LRU_PROPOSAL.md). Permanent adoption, scope expansion, LRU implementation, cache deletion and canonical decision changes require separate user decisions; do not assume adoption.

<a id="結果"></a>
## Result

Not yet executed at this point in the record.

<a id="複数回の依頼計画2026-10-18ユーザー指定"></a>
## Multi-round plan (user-specified 2026-10-18)

Three rounds within OPS-101. Astra checks each return before fixing the next scope and assignment. Do not automatically start every round. The purpose is material for OPS-099's 「何を安全に手元から外せるか」, not completing a classification system or exhaustive coverage. End early if a small sample provides enough material.

1. **Round 1: classify three existing entries; the present formal assignment.** Compare Hime's STUDIO_LAYOUT.md entries on placement, single/multiple placement and the local view, reporting classification difficulties.
2. **Round 2: test operation on another small sample; not yet assigned.** Select at most three other entries to check ambiguous boundaries and record effort. Test whether provenance is distinguishable without forcing uniform categories. Fix targets at round-1 acceptance.
3. **Round 3: consolidate results; not yet assigned.** Use existing records to summarize useful distinctions, burden, implications for offloading and unknowns. No new exhaustive survey; return material for OPS-099.

<a id="第1回の正式依頼姫"></a>
## Round 1 formal assignment: Hime

- Target only the three entries in `Maintanance/Cache/Hime/STUDIO_LAYOUT.md`: placement with/without edges, single-above/multiple-below placement, and the local view with center card and actual edges. Report missing entries without substituting others.
- Compare the referenced sections, chiefly TASK_REGISTRY_APP.md, REGISTRY_STUDIO_MILESTONE_BRANCH_LAYOUT.md and REGISTRY_STUDIO_NEIGHBOR_CARDS.md. Start with the cache's fixed revision and record differences from current separately. Age does not mean a non-copy.
- Record starting HEAD, source commit/path/section or lines, cache entry names and file hash. Identify uncommitted evidence explicitly. No full cache duplication is needed.
- For each entry, return category, supporting evidence, added interpretations and unknowns. If source and necessary direct references do not settle it, stop at 「出典未確認」. There is no quota for original judgments.
- Add classification difficulties and whether brief records appear maintainable. Keep classification evidence separate from observations.
- Edit only round-1 Return. Existing optional observations-log permission remains. No cache/canonical/Registry/code changes. This read-only trial is not a cache update, so pre-update commit is not a start condition. No commit.
- Stop after return and await round 2; Astra leaves the assigned response area unchanged until then.

## 第1回 Return（姫記入）

2026-10-18 姫・Opus 5.5。読み取りだけで、キャッシュ・正本・Registry・コードは変更していない。commitなし。

### 証拠

- 開始時HEAD：`3b4020d0d228a3cdf9f300e6dff09dde7e6cd367`
- 対象：`Maintanance/Cache/Hime/STUDIO_LAYOUT.md`（sha256 `65cff23c0f7b5fdfee6a74c0fdeb20b88caad5a3c272515eb01d5b29b5ad97b2`）の §1・§2・§3。3項目とも存在し、欠落はなかった。
- 照合元：キャッシュに記載された固定版`b2f9e8e4`で読んだ（`git show b2f9e8e4:<path>`）。3文書とも、`b2f9e8e4`→HEAD、HEAD→作業ツリーの差分は空。したがって「現行との差」欄は該当なし。未コミット資料は根拠に使っていない。

### 項目ごとの分類

**§1 置き場所（辺あり→見取り図、辺なし→独立欄）：コピー判断**
- 根拠：TASK_REGISTRY_APP.md「タスク配置の要求」（固定版の19〜28行）。恒久木の除外（1）、辺ありは見取り図で未接続群も含む（2）、辺なしだけ独立欄・「独立≠未接続」（3）、漏れ・重複の禁止（4）、版フィルタで独立扱いにしない、カード一覧・局所図は重複に含めない（28行）。どの文にも対応行がある。
- 追加解釈：「見直すとき」に挙げた`Evidence/OPS-095/placement.cjs`は、正本の判断ではなく私が選んだ確認契機。OPS-097依頼17行「再現する不一致などを再確認契機」に沿って選んだ。判断本体には混ざっていない。
- 不明点：なし。

**§2 単独は右上、複数は下：コピー判断（一部に実装事実の写しと、私の言い換え1文が混在）**
- 根拠（ユーザー決定）：TASK_REGISTRY_APP.md 32行。単独後続は右上を維持、「大気圏外へ送り出す」、複数は起点の下へ縦に積む、上下で同じオフセット、幅不足はマイルストーン間隔を広げる。34行：実辺を保持、ID固定座標なし、局所図は変更しない。
- 根拠（追加依頼）：MILESTONE_BRANCH_LAYOUT.md 52行。下側を別の横位置へ逃がさない、拡張は必要な区間に限る。
- 実装事実の写し：MILESTONE_BRANCH_LAYOUT.md 63〜67行（姫の追加Return、Astra受入済み）。対象は「依存順に」「共通の`lane`」「例：PERM-079」「QUALITY-005・DOC-026・DOC-027がMS-SPIの下」。ユーザーの決定ではなく、実装と結果の記述を写したもの。
- オリジナル（私の言い換え）：「理由：最下段へ離れると、起点との関係が読めない」。依頼10行には「DOC-027が最下段に離れる状況を…修正する」という状況しかない。「関係が読めない」という理由づけは、私の解釈。
- 不明点：なし。

**§3 「接続を見る」は実辺の局所図：コピー判断（評価語1つが混在）**
- 根拠：NEIGHBOR_CARDS.md 89行（文字一覧を残し、その上に局所図、3段カード列ではない）。90行（中心を中央、直接の前提を左・後続を右）。93行（文字一覧と同じノード・辺）。109行（3段カード列と`neighborhoodSides()`をやめた）。136行（Astra受入：実辺・左右・現行検証は`smoke_map.cjs`）。
- 追加解釈：旧`smoke.cjs`が「今は通らないのが正しい」。事実は129行（今は通らない、原記録として残す）と136行（過去の証拠）。「正しい」は私の評価語。
- 不明点：なし。

### 経験（分類の証拠とは別）

- 迷った点：§2の「依存順」や`lane`は、ユーザーの決定ではない。それでも受入済みのReturnにある事実なので、出典はある。「コピーだが、写した先がユーザー判断ではなく実装の記録」という中間を、どの区分に入れるか迷った。今回は、コピーの中に「実装事実」と注記した。
- 見つけ方：オリジナルが混ざっていたのは、「理由」「見直すとき」「正しい」のように、私が結論を付け足す欄だった。判断本体の文は、ほぼ正本の言い換えだった。
- 負担：3項目で、正本の該当行を引くのに一往復ずつで足りた。固定版と行番号がキャッシュ側に書いてあったので、探索は膨らまなかった。短い分類記録（項目ごと「区分＋根拠の行＋混在箇所」）なら維持できそう。ただし、キャッシュに行番号まで書くと正本の編集でずれるので、節名＋固定版が限度だと思う（推定）。

<a id="第1回-astra受入2026-10-18"></a>
## Round 1 Astra acceptance (2026-10-18)

Independently matched the cache hash, verified no differences from fixed b2f9e8e4 to current in the three assigned canonicals, and checked placement requirements, additional assignment/Return and local-view acceptance. Accepted as a classification trial; preserve original Return.

Copies of decisions coexisted with implementation facts, author reasoning/evaluative wording and choices of verification triggers. Added interpretation does not necessarily change a user decision. No original-decision alteration or overall mixing rate is established. The material suggests provenance/content annotations may help more than a blanket 「オリジナル判断」 label. No settled policy or cache repair.

<a id="第2回の正式依頼別の3項目で境界を確認"></a>
## Round 2 formal assignment: boundaries in three other entries

Bounded assignment after round-1 acceptance. Hime receives this response scope; Astra awaits return.

- Only `Cache/Hime/STUDIO_JUDGMENTS.md` §1 (save contract), §3 (OPS-089), §4 (SPI badge).
- Alongside the same origin categories, annotate where useful: 「決定の写し／実装・状態の事実／作成者の解釈・評価／確認の手掛かり」. This is trial assistance, not new mandatory fields.
- Separate support by the stated fixed revision/source from current validity. The old §4 SPI target moved to 0.6.1; comparison with current `Milestones/0.6.1/10_SPI.md` and Registry MS-SPI→DOC-027 is allowed. Link relocation alone is not a changed decision.
- Check only the source and necessary direct references. Do not derive new authority from state labels or 「決着済み」. Stop with unverified provenance if unresolved.
- Record starting HEAD, cache hash, compared revisions/locations and any uncommitted inputs. Try a final line 「参照したキャッシュ：STUDIO_JUDGMENTS §1・§3・§4」 and briefly describe its burden. It records reference, not effective-use frequency or a permanent universal obligation.
- Edit only round-2 Return. No cache updates, link repairs, Registry/code edits or commit. Existing optional observations permission remains. Round 3 is not assigned; stop after return.

## 第2回 Return（姫記入）

2026-10-18 姫・Opus 5.5。読み取りだけで、キャッシュ・リンク・Registry・コードは変更していない。commitなし。

### 証拠

- 開始時HEAD：`3b4020d0d228a3cdf9f300e6dff09dde7e6cd367`
- 対象：`Maintanance/Cache/Hime/STUDIO_JUDGMENTS.md`（sha256 `c392757219b6e4855bc2391052dd63386d2a7d1b1b638334cd5fbe33e10278fd`）の §1・§3・§4。3項目とも存在した。
- 固定版：キャッシュに記載の`c98fd93a79e1e37b3c44993b5273763bf3e370c8`。SAVE_CONTRACT.md・USABILITY_DECISION.mdは、固定版→HEAD、HEAD→作業ツリーとも差分なし。
- 「現在」の照合：Registryは作業ツリーに他担当の未コミット変更があるため、HEADの版（`git show HEAD:`）で読んだ。10_SPI.mdもHEADの`Milestones/0.6.1/10_SPI.md`で読んだ。

### 項目ごとの分類

注記の記号：〔写〕＝決定の写し、〔実〕＝実装・状態の事実、〔解〕＝作成者の解釈・評価、〔手〕＝確認の手掛かり。

**§1 保存の約束は「試行保存契約 v1」：コピー判断（要約で一部の未決項目が落ちている）**
- 裏づけ（固定版）：
  - 〔写〕契約v1が正本で、恒久採用ではない：SAVE_CONTRACT.md 34〜36行。
  - 〔写〕READMEは参照側：同22行（「本文をこの文書にまとめ、READMEから参照する」）。
  - 〔実〕仕様化の完了（OPS-087 DONE）：同101行と、Registryの`OPS-087`行。
  - 〔写〕追わない未決：同88〜93行。
  - 〔手〕見直すとき：同95〜97行「更新条件」の要約。
- 落ち：キャッシュの「追わない」一覧に、93行の「破損保存の案内、強制終了時の復旧」と、92行の「一部反映後の残差分・波及」がない。追加解釈ではなく、縮約での欠落。リンク先に誘導しているので害は小さいが、写しが完全でないことは記録しておく。
- 現在も有効か：両文書は差分なし。Registryの`OPS-087`はHEADでも`DONE`。有効。

**§3 どれを実装するかはOPS-089（USER_ONLY）：コピー判断（作成者の運用の付け足しが混在）**
- 裏づけ（固定版）：
  - 〔写〕5案の採否と範囲はユーザーが決める、AIは代行しない、期限・必須ゲートなし：USABILITY_DECISION.md 7行。
  - 〔実〕`OPS-089`は`USER_ONLY`：Registry 134行。
- 〔解〕「催促しない」は私の付け足し。正本にあるのは「依頼された補助のみ行う」（7行）まで。「今は追わない」は、7行の「代行しない」から導いた私の運用。
- 〔手〕「見直すとき」（状態の変化、ユーザーからの採否）は、私が選んだ確認契機。
- 現在も有効か：USABILITY_DECISION.mdは差分なしで「未判断」のまま。HEADのRegistryで`OPS-089`は`USER_ONLY`のまま。有効。

**§4 SPIのバッジは登録の後：コピー判断（リンク切れ1件、評価語が混在）**
- 裏づけ（固定版）：
  - 〔写〕登録後でなければバッジが機能しないという既決判断の反映、DOC-027のバッジ・公開導線はMS-SPIの後、MS-SPIの完了条件から外す：`Milestones/0.6.0/10_SPI.md` 33行（2026-10-18ユーザー訂正）。
  - 〔写〕Registry「マイルストーン接続」の`MS-SPI → DOC-027`は開始側：Registry 381行。
  - 〔実〕`18e881e8`で修正済み：同commitの件名「move badge work after SPI registration」。
- 〔解〕「再議論・再実装は不要」「蒸し返さない」は私の評価。正本の言葉は「既決判断」「ユーザー訂正」で、そこから導いた。ただし、ユーザーが判断を変えれば再議論はありうるので、「不要」は言い過ぎの余地がある。
- 現在も有効か：
  - HEADの`Milestones/0.6.1/10_SPI.md` 33行は、固定版と同文。差分は、34〜35行に「0.6.1挿入に伴い0.6.0から移動、ID・未達状態・内容は保持」が足されただけ。
  - HEADのRegistryの`MS-SPI → DOC-027`行も同文（409行）。
  - 判断は有効。キャッシュのリンク（`Milestones/0.6.0/10_SPI.md`）は切れているが、判断の変更ではない（依頼どおり、リンクは直していない）。

### 経験（分類の証拠とは別）

- 第1回と同じく、〔解〕は「追わない」「見直すとき」「不要」の欄に出た。判断本体の文はほぼ〔写〕だった。
- 今回新しく出たのは、付け足しではなく「縮約での欠落」（§1）。区分は「コピー判断」のままで正しいが、「写しが完全か」は区分とは別の軸になる。
- 4種の注記は付けやすかった。迷ったのは§3の「今は追わない」。正本の「代行しない」の言い換えとも、私の運用とも読める。今回は〔解〕に入れた。
- 負担：3項目で、正本の該当行を各1〜2回引いて済んだ。いちばん手間がかかったのはリンク切れの§4で、移動先と内容が同じかの確認に一往復増えた。
- 参照記録の一行：Returnの末尾に書くだけなので、負担はほぼない。ただ、今回は照合のために全部読んだので、「判断に使った」という意味の記録にはなっていない（OPS-100の受入の注意どおり）。

参照したキャッシュ：STUDIO_JUDGMENTS §1・§3・§4

<a id="第2回-astra受入補正2026-10-18"></a>
## Round 2 Astra acceptance and correction (2026-10-18)

Independently confirmed matching cache hash and no differences from the fixed save-contract/user-decision canonicals. Accepted omissions caused by compression, the distinction between old SPI links and relocation, and the reference-record trial as material for consideration. Preserve original Return.

Correct classification of §3's 「催促しない」 as an independent operating addition. TASK_RULES_V2.md's USER_ONLY under 「状態の扱い」 says 「本体の着手・代行・委任・催促をしない」; AGENTS.md's 「現在の仕事と正本」 also prohibits prompting execution. Absence from the individual canonical does not establish absence of common-rule authority. 「今は追わない」 would be overbroad if it rejected assistance too; distinguish restricted task execution from explicitly requested assistance.

Hime explicitly limited its 「現在」 comparison to HEAD, not the entire working tree's currency. Completeness, freshness and provenance are separate. Not every summary omission is a defect; check whether it affects application when needed. Accept the Return line as reference recording, not measurement of effective-use frequency. No cache repair or exhaustive comparison.

<a id="第3回の正式依頼結果整理のみ"></a>
## Round 3 formal assignment: consolidate only

Include the round-2 corrections above and delegate this response scope to Hime.

- Inputs are this document's round-1/2 Returns and Astra acceptance/corrections, plus OPS-099's purpose. No discovery of new entries/history.
- In roughly one page maximum, summarize (1) useful distinctions, (2) likely misclassification boundaries, (3) minimal recording, (4) what can/cannot be said about safe offloading, (5) recommendation to continue/reduce/reject.
- Distinguish copy/original provenance from decision/fact/interpretation, freshness and summary scope. Do not classify a common-rule decision as independent merely because the individual canonical omits it. Unknown evidence remains unverified provenance.
- Evaluate the one-line reference record as a candidate. Missing entries are not nonuse; reference is not effective use.
- No complete institutional or LRU design is needed. Do not generalize mixing rates or savings across caches from six entries.
- Edit only round-3 Return. No cache/Registry/other canonical/code changes or commit. Optional observations permission remains. Stop after return; Astra receives material for OPS-099. Adoption is the user's decision.

## 第3回 Return（姫記入）

2026-10-18 姫・Opus 5.5。入力は本書の第1・2回ReturnとAstra受入・補正、OPS-099の目的だけ。新しい探索はしていない。キャッシュ・Registry・正本・コードは変更していない。commitなし。母数は6項目で、ここから全キャッシュへの一般化はしない。

### (1) 有用だった区別

- 出どころの区分（コピー／オリジナル／出典未確認）は、6項目とも項目単位では「コピー」で、差が出なかった。
- 差が出たのは、項目の中の文単位の種類（〔写〕決定の写し／〔実〕実装・状態の事実／〔解〕解釈・評価／〔手〕確認の手掛かり）。〔解〕と〔手〕は、どの回も「理由」「追わない」「見直すとき」「不要・正しい」の欄に集まった。判断本体の文はほぼ〔写〕。
- 出どころ・種類とは別の軸として、「写しの完全性」（§1保存契約の縮約による欠落）と「鮮度・参照先の移動」（§4の旧リンク）が見えた。どちらも区分では表せないので、別に書く必要があった。

### (2) 誤分類しやすい境界

- 共通規則由来の判断：私は第2回で、§3「催促しない」を自分の付け足し〔解〕と分類した。誤りだった。TASK_RULES_V2.mdのUSER_ONLYとAGENTS.mdに根拠がある（Astra補正）。個別正本にないことを、根拠がないことと取り違えた。出典の探索範囲を「記載された参照先」に限ると、この誤りは起きやすい。
- 実装の記録の写し：受入済みのReturnにある実装事実（例：「依存順」「`lane`」）は、出典はあるがユーザー決定ではない。〔実〕と書けば分けられた。
- 言い換えの度合い：「今は追わない」のように、正本の言い換えとも運用の付け足しとも読める文。補正のとおり、元の規則が制限する task 本体と、明示依頼された補助を分けて読む必要がある。
- 省略の扱い：省略がすべて欠陥ではない。適用判断を変える省略かどうかを、必要なときに見る（Astra補正）。

### (3) 最小の記録方法（候補）

- 項目ごとに一行：「区分＋根拠（文書・節・固定版）＋〔解〕〔手〕のある欄」。〔写〕は書かない（本体はほぼ〔写〕なので、例外だけ書けば足りる）。
- 根拠の位置は「節名＋固定版」まで。行番号は照合時のReturnにだけ書く（正本の編集でずれるため）。
- 参照記録の一行（「参照したキャッシュ：…」）は、Return末尾なら負担はほぼない。ただし、参照の記録であって、判断に使った証拠ではない。未記載は未使用を意味しない。

### (4) 安全な退避について言えること・言えないこと

- 言えること（6項目の範囲）：
  - 〔写〕の部分は、正本と固定版が残っていれば再取得できた。
  - 〔解〕の多くは「追わない」「見直すとき」の運用の言葉で、退避すると失われるのは主にこれ。ただし今回、その一つ（催促禁止）は共通規則に根拠があった。〔解〕だから捨ててよい、とは言えない。
- まだ言えないこと：
  - 項目全体がオリジナルの例が、6項目には一件もない。だから、その扱いは未確認。
  - 削減効果や混在率は分からない。
  - 退避後に再取得するとき、共通規則の根拠まで正しく引けるかも分からない。今回の誤りから見ると、引けない危険がある（推定）。

### (5) 推奨

- 推奨：縮小して継続。出どころの三区分を項目単位で付けるのはやめる（6項目で差が出なかった）。〔解〕〔手〕の欄だけに印を付ける、文単位の注記を候補として残す。完全性・鮮度は別の一行で書く。
- 理由：差が出て役に立ったのは文単位の種類と別軸の二つで、項目単位の区分ではなかった。
- 次に確かめるなら：項目全体がオリジナルらしい例（作業中の仮説だけのメモ）を1〜2件。または、共通規則由来の判断を含む項目で、退避と再取得が正しくできるか。どちらもユーザーの採否の後で、今は着手しない。
- 不採用にする場合：既存キャッシュは今のままで支障は見つかっていない。失うのは、〔解〕の欄を見分ける習慣だけ。

<a id="第3回-astra受入試行の総括2026-10-18"></a>
## Round 3 Astra acceptance and trial conclusion (2026-10-18)

Compared round-3 Return with prior records/corrections and accepted consolidation of the six assigned entries. All three assignments ended; connect material to OPS-099. Preserve original Return. DONE following user commit approval. No additional investigation, cache changes or policy adoption requested.

Acceptance limits: source locations were found while retaining caches. No actual offloading/restoration trial occurred; 「再取得できた」 does not mean successful restoration testing. 「既存キャッシュに支障は見つかっていない」 is not a guarantee of overall safety; old links and potentially overbroad wording are already recorded. Receive round-3 (3)'s per-entry categories and (5)'s abolition of categories as unsettled alternatives, not a unified system.

Astra's synthesis: distinguishing added interpretation, evaluation and verification leads where needed more directly addresses the observed confusion than labeling whole entries. Treat provenance separately from content type, freshness and summary scope. Six entries do not justify abolishing overall classification or adding a format to every cache. Retain the reference line as a lightweight candidate, not a use-frequency or nonuse metric. Adoption and further trials remain user decisions.
