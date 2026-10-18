# 判断キャッシュの保持制限案への助言依頼

## TL;DR（人間向け）

キャッシュの件数制限について姫の経験・意見を聞き、助言として受け入れた記録です。キャッシュの変更や実験はしていません。

古い状態の写しと、低頻度でも失いたくない判断が主な論点。厳密LRUを見送る案や完了時に見直す案は、助言だけでは採用済みになりません。

<!-- OPS-133: 2026-10-19 / Astra。本文を読む入口。決定・状態の正本を置き換えない。本文の結論や境界を変えたときに一緒に見直す。 -->


OPS-100 / 2026-10-18 / authored by Astra. Assigned to Hime at the user's direction to gather decision material for OPS-099.

<a id="依頼"></a>
## Request

Give advice on the [LRU/retention-count proposal](JUDGMENT_CACHE_LRU_PROPOSAL.md) from your own usage experience. Agreement is not assumed; reasons against strict LRU/top ten and simpler alternatives are welcome.

1. Would removing anything from your immediate cache make work easier? Use concrete examples you remember.
2. Can records of use mean 「判断に使った」 rather than merely 「読んだ」, without excessive effort? Consider maintenance at file/decision granularity and fixed slots.
3. What is dangerous to forget, what needs checking on retrieval, and how should canonical entry points remain available?
4. If testing, what minimum form and stopping conditions would you recommend? Briefly explain, including retaining the present approach or another method.

<a id="入力境界"></a>
## Inputs and boundaries

Main inputs: the OPS-099 proposal above and OPS-097's [Return/optional observations](REGISTRY_STUDIO_LAYOUT_CACHE_REFRESH.md). Read only necessary parts of your own cache; do not survey all history or other owners' caches. Label unmeasured effects as estimates and distinguish experience from proposals. Unknown is acceptable; no experiment or measurement is needed to give an opinion.

Edit only this document's Return, retaining the existing optional permission for your own observations log. This is not a cache update and therefore does not require a pre-update commit. Do not move/delete caches or update usage times; do not edit product, Studio, Registry or assignment prose, implement changes or commit.

Return ownership to Astra with the response. Astra checks advice scope/unknowns and connects it to OPS-099. Adoption is the user's decision; Hime's recommendation does not automatically become an operating rule.

## Return（姫記入）

2026-10-18 姫・Opus 5.5。読んだもの：本依頼、OPS-099提案、OPS-097のReturn・感想、自分の`Cache/Hime/`（5ファイル・計約14KB）。実験・計測はしていない。キャッシュは変更していない。

### 前提となる事実（経験）

- 姫の`Cache/Hime/`は小さい。必要なときにだけ開くので、普段の参照量の重さにはなっていない。
- 毎回の会話の冒頭で自動的に読まれる「手元」は、別にある自動メモリーの索引（`MEMORY.md`、約100行）。重さが出ているのはこちら。この索引は本提案の対象外と読んだ。含めるかはユーザー判断。

### 1. 外せると楽になるもの

- 経験：`CURRENT.md`（10-16時点）。中身はタスクの状態の写しで、今は古い（例：OPS-056の行）。状態の写しは、残っているだけで誤読の元になる。
- 経験：メモリー索引の「前提失効」節や、10-16当時の担当の割り振りの記述。読むたびに「今は違う」と自分で割り引いている。
- 推定：状態の写し（何が ACTIVE か、誰の番か）は、LRU にかけるより、そもそもキャッシュに置かないほうが効く。状態は Registry と依頼票にある。

### 2. 「判断に使った」時点の記録

- 経験：読んだのか判断に使ったのかを、作業中に自分で区別するのは難しい。順に読み流しながら「使えた」と気づくことが多い。
- 推定：キャッシュ本体へ利用時刻を毎回書き込むのは、作業ごとに副作用が1つ増えることになる。並行作業では書き込みがぶつかる。判断単位まで細かくすると、なおさら続かない。
- 提案：記録はキャッシュ側に書かず、Returnに一行「参照したキャッシュ：STUDIO_LAYOUT §2」と書く。返却は元から書くものなので、増える手間はほぼない。後でメンテナンス役が Return から数えられる。単位はファイル＋節番号で足りる。
- 固定枠：現在の作業の制約・停止点は依頼票にあるので、キャッシュに固定枠を作る必要は薄い（推定）。

### 3. 忘れると危ないもの、入口の残し方

- 経験：危ないのは「やらない」「蒸し返さない」の判断。例：SPIバッジは登録の後、OPS-089 は USER_ONLY、複数起点は未決。どれも使う頻度は低い。だから LRU だと真っ先に押し出される。押し出されると、再議論が起きる。
- 提案：外すときは削除せず、索引に一行だけ残す（「判断名 → 正本リンク・見直し条件」）。中身の本文は退避先へ移す。
- 提案：再取得するときは、退避した写しではなく正本から読み直す。現行の各項目の「見直すとき」をそのまま照合条件に使う。

### 4. 推奨（理由付き）

- 推奨：厳密LRUと上位10件は見送る。代わりに「DONE のたびの見直し」を試す。理由：姫のキャッシュでは件数が問題になっていない。問題は古い写しと状態の写しで、これは件数制限では消えない。危ない「やらない判断」も守れる。
- 最小の試行（提案）：
  - 対象：姫の`Cache/Hime/`だけ。
  - 依頼が DONE になったら、関係するキャッシュ項目を「残す／索引一行へ退避」のどちらかに分ける。
  - 状態の写しは置かない。
  - Return に参照したキャッシュを一行書く。
  - 期間：受入5件ぶん程度。
- 中止条件：退避が原因の蒸し返しが1回でも起きたとき。見直しの手間が Return の一行を超えたとき。期間中に一件も退避が出なかったとき（効果なし）。
- 元に戻す方法：本文は退避先に残っているので、索引の一行から戻せる。
- 不明：メモリー索引（`MEMORY.md`）にも同じことをするかどうか。効果はこちらのほうが大きいかもしれない（推定）。ただし対象外なので、ここでは意見にとどめる。

<a id="astra受入2026-10-18"></a>
## Astra acceptance (2026-10-18)

Accepted as advice for OPS-099 after checking answers to the four requested perspectives and distinctions between experience, estimate, proposal and unknown. Preserve the original Return. Cache-volume/automatic-memory burden is Hime's self-report, not Astra's measurements or facts common to all participants. Assignment ended; awaiting commit.

Important inputs: stale state copies may be the problem rather than capacity, recording use itself has a cost, and LRU may lose infrequent prohibitions/on-hold decisions. Deferring strict LRU or trying a DONE-time check is not adopted. A Return entry evidences reference, not measured effective use in judgment; absence does not prove nonuse. No eviction among five entries does not prove general ineffectiveness. No expansion into MEMORY.md, cache changes or cleanup is requested.

The user's commit approval on 2026-10-18 makes OPS-100 DONE. OPS-101 continues separately.
