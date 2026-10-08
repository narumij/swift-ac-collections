# 過去graph知見のインメモリ追試

最終更新: 2026-10-08 / Claude（GRAPH-008台帳）。task定義はCodex

## 位置づけ

この文書は、過去のgraph系文書に記録された観測・仮説・反証のうち、`GRAPH-007`で確立した
SQLite `:memory:` fixture方式で追試可能な範囲を分類し、再実行可能な回帰fixtureへ変換する作業の正本である。

作業は、可能性を分類する`GRAPH-008`と、受入済みの対象だけを実装する候補`GRAPH-009`へ分ける。
分類と実装を同時に行わず、過去記録の印象だけでfixtureを増やさない。

## 対象文書

- `AI_GRAPH_SMELL_NOTES.md`
- `GRAPH_DB_EXCHANGE.md`
- `TASK_GRAPH_DB_EXPERIMENT.md`

`AI_GRAPH_SHARED_SCHEMA.md`と`AI_GRAPH_IN_MEMORY_FIXTURE.md`は追試方式の入力であり、過去知見の
棚卸し対象には数えない。Archived文書は、上の3文書から具体的根拠として参照される場合だけ読む。

## GRAPH-008: 追試可能性台帳

### 担当と受入

- 作成担当: Claude
- 受入担当: Codex
- 種別: `DISCOVERY`
- ユーザー判断: なし

### 目的

対象文書のgraphに関する試験記録・知見・候補を項目単位で列挙し、現行のSQLiteインメモリ方式で
どこまで追試可能かを分類する。SQLやfixtureの実装は行わない。

### 分類

各項目を必ず次のいずれかへ分類する。

- `A`: 現行schemaと手書きfixtureだけで追試可能
- `B`: SQLite `:memory:`内の小さなschemaまたはquery追加で追試可能
- `C`: source、compiler index、runtime、機械語、性能測定などの自動抽出・外部検証が必要
- `D`: 歴史的説明、主観的評価、期待値を安定定義できないため回帰fixtureにしない

`B`は永続DBやproduction変更を必要としないものに限る。task→symbolのようにrepositoryに入力がない
関係を、AI推定だけで`A`または`B`へ分類しない。

### 台帳の必須列

| 列 | 内容 |
| --- | --- |
| replay ID | この文書内だけで使う安定した識別子 |
| source | 文書名と見出し |
| original claim | 過去記録が述べる観測・仮説・反証 |
| expected result | PASS条件または期待される行・件数 |
| required input | 必要なnode・edge・外部観測 |
| query shape | 追試に必要なqueryの概要 |
| class | `A / B / C / D` |
| reason | その分類にした根拠 |
| overlap | GRAPH-007で既に覆われる部分 |

同じ事実を複数文書が述べる場合は別fixture候補へ重複させず、代表項目と参照元をまとめる。

### 対象外

- SQL、DDL、fixture、抽出器の作成・変更
- 過去のsmell判定の正誤を新しく決定すること
- Claude専用graph DBの参照・更新
- production source、test、build設定の変更
- task→symbol辺をAI推定で補うこと
- 新しいsmell探索

### 停止条件

- 分類に新しい公開契約または保存方式の判断が必要になった場合、選択肢を記録して停止する。
- 過去記録だけでは期待結果を特定できない場合、推測せず`D`または不足として記録する。
- 対象が広すぎて項目単位の完了判定ができない場合、文書・節単位の子task候補を提示して停止する。

### 完了条件

- 対象3文書のgraph試験・知見が台帳へ一度ずつ対応している。
- 全項目に`A / B / C / D`と根拠がある。
- `A / B`について、実装前に必要な入力、query、期待結果が明記されている。
- GRAPH-007との重複を除き、GRAPH-009へ渡す候補集合をCodexが選べる。

### 台帳（2026-10-08 / Claude）

観測時点: HEAD `ce97783d`。略記: SN = `AI_GRAPH_SMELL_NOTES.md`、EX = `GRAPH_DB_EXCHANGE.md`、TE = `TASK_GRAPH_DB_EXPERIMENT.md`、
G7 = GRAPH-007のfixture。「task→symbol」はrepositoryに入力が無い関係を指す（GRAPH-006 A-1）。

| replay ID | source | original claim | expected result | required input | query shape | class | reason | overlap |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| RP-01 | SN「S-1」 | `RBT-001`・`004`・`010`・`011`のうち、001/004、004/010、004/011、010/011の間にprecedence辺がない | HEADのRegistryでは辺は`RBT-001`←`RBT-010`、`RBT-001`←`RBT-011`の2本だけ。辺のないpairは主張どおりの4組 | task node 4、Task precedenceの該当行（HEADと2026-10-07時点のcommit） | 集合内のpairのうち、どちらの向きにも辺がないもの | B | precedenceはRegistryの記録。task→task辺のrelation追加だけで済む。symbolを共有するという前半はRP-02 | なし |
| RP-02 | SN「S-1」前半、「S-3」、「試験記録: PERM-003」S-2、`PERM-013`追加時の追記 | 同じsymbolを複数taskのscopeが共有する／`RBT-005`のscopeが75 symbol／module単位のscopeでは結合判定が常に当たる・逆向きの誤検知4件 | 定義できない | task→symbolのscope | — | D | scopeはClaudeのlocal DBにしか無く、repositoryに入力が無い。AI推定で補わない | なし |
| RP-03 | SN「S-2」の反例 | `PERM-004`←`PERM-003`、`PERM-007`←`PERM-006`はコードを共有する | 辺の存在だけは確認できる（`PERM-004`←`PERM-003`は`git log -S`で2 commitに出入りがあり、HEADには無い。`PERM-007`←`PERM-006`はHEADにある）。「コードを共有する」は定義できない | 辺: Registryの履歴。共有: task→symbol | — | D | 主張の核心はコードの共有で、RP-02と同じく入力が無い。辺の存在だけを追試しても主張を検証しない | なし |
| RP-04 | SN「S-4」 | fan-inが大きいのに仕様testから参照されないsymbolは急所 | 具体例の記録なし | call graphのfan-in | — | C | fan-inの算出にはindex storeの抽出が必要。具体的な事例も記録されていない | なし |
| RP-05 | SN「試験記録: PERM-003」S-4、PERM-012後の追記「対象範囲」「確かめ方」 | `spec-gaps`のfile名規則が`RedBlackTree*_NN_*`だとPermutationTestsは対象外。`<公開型>_NN_*`かつ`NN < 90`へ直すと拾える。`_9x`へ改名すると仕様から外れる | `d784b91e`: 旧規則で仕様file 0、新規則でも0（番号付きfileがまだ無い）。HEAD: 旧規則0、新規則で仕様5（`NextPermutationsSequence_0`〜`_4`）、仕様外2（`_98`、`_99`） | `git ls-tree`による2 commit分のtest path | pathから`role`を規則で計算し、規則ごと・commitごとに数える | B | 今の`node.role`は入力値で、規則で計算していない。規則をqueryに移せばSQLite内で済む | G7は`role`を手で入れているだけ |
| RP-06 | SN PERM-012後の追記「古い索引」、EX 2026-10-07「native buildが…リンクに失敗」 | index storeは改名・削除したfileの索引を残す／公開シグネチャ変更後の索引buildがリンクに失敗する | — | index storeとbuildの実行 | — | C | 抽出器とbuildそのものの性質で、fixtureでは再現できない | なし |
| RP-07 | SN「試験記録: PERM-003」当たり1件 | `nextPermutation(upperBound:)`の`upperBound`は呼び出し側から渡されず、`else`節に到達しない | — | 呼び出し箇所（現在のsourceには`upperBound`引数が無く、`nextPermutation()`だけ） | — | C | 呼び出し側の解析が必要。対象の引数はHEADで既に無く、過去の状態はbuildし直さないと得られない | なし |
| RP-08 | SN「試験記録: Permutation・赤黒木」spec-gaps、知見5、EX 2026-10-07の申し送り | 未参照の公開API 2件のうち、`RedBlackTreeBoundExpression.find(_:)`は本物の空き、`RedBlackTreeSet.freeCapacity`は`#if DEBUG`限定の誤検知 | `58aab943`の前: gapは`find(_:)`だけ、`freeCapacity`は構成限定として除外。後: gap 0（`58aab943`が`RedBlackTreeSet_16_BoundExpressionTests.swift`に仕様を追加） | symbol node 2（access、構成条件`DEBUG`）、`58aab943`前後の仕様test edge | 公開かつ構成限定でなく、spec testからの`test_references`が無いsymbol | B | symbolに`access`と構成条件のfieldを足し、gap queryを1本足せば済む。USRと構成条件は手で写せる | G7の`test_references`と`role`を流用 |
| RP-09 | SN「試験記録: Permutation・赤黒木」check 12件、知見4、EX 2026-10-07 | `@inlinable`から非`@inlinable`を呼ぶ候補12件のうち、本物は1件で、しかも呼び出し元の一部だけ | — | 利用側moduleのRelease機械語 | — | C | 当たり・空振りが機械語で決まる | なし |
| RP-10 | SN「試験記録: Permutation・赤黒木」graphでは見えず読んで見つけたもの | header二重破棄、終端の無駄なコピー、`swapAt` TODOの誤り、`_copyCount`だけpublic | — | source本文、構成ごとのsymbol graph | — | C | 読んで見つけたもので、graphの主張ではない。`_copyCount`のaccess差だけは構成ごとのsymbol graphが要る | なし |
| RP-11 | SN「誤った臭い」 | Registryの`RBT-012`が`ensureUnique()`に触れていても、名前の一致はtaskとsymbolの結合ではない | task node `RBT-012`があっても、`ensureUnique()`のtask区分は0件・導出元なし | task node 1、symbol node 1 | G7の「隣を引く」 | A | 今のschemaで書ける。task→symbol辺を作らない規則を、別の事例で確かめるだけ | G7のtask区分0件と同じ規則。追加で得られる情報は少ない |
| RP-12 | SN「taskの臭い」（2026-10-07夜） | 実装中に決め事が7つ出たのは、手順・仕様を決めるtaskの不足の臭い | 定義できない | 作業中の出来事 | — | D | 作業の経緯で、repositoryの関係として記録されていない | なし |
| RP-13 | SN「taskの臭い その2」 | 分解で生まれた子task 9件と親がすべて`EXCLUDED`になる形は、前提の誤りの痕跡 | 定義できない。状態は`RBT-017`〜`RBT-025`の9件すべてHEADで`EXCLUDED` | 親子関係 | — | D | Registryに親子関係の記録が無く、9件の間にprecedence辺も無い。番号の連続や項目名から親子を推定すると、AI推定で辺を作ることになる | なし |
| RP-14 | SN「観点: 隣接を先に引く」、SN「試験記録: 隣を引く」の結果、EX 2026-10-08 | 仕様test・文書・直近commitを並べれば、10/5のO(1)契約へ着手前に届く | G7の期待件数どおり | G7 | G7 | A | 実装済み | G7が全部覆う |
| RP-15 | SN「試験記録: 隣を引く」調整、EX 2026-10-08 | `subscript`だけで照合すると文書36件、所属型と組にすると9件 | `bb77fafc`: 単語だけ36件、所属型と組で9件。`f6f84d6c`: 単語だけ38件、組で9件 | 2 commit分の文書path（`git grep`の結果を写す） | 照合方法ごとに文書を数える | B | 文書edgeに照合方法（単語だけ／所属型と組）を持たせれば済む | G7は組の9件だけ |
| RP-16 | SN「試験記録: 隣を引く」限界 | 別fileへ移された判断や、文書だけで決めた契約は、commit経路では届かない | 具体例の記録なし | — | — | D | 推測として書かれていて、事例が無い | なし |
| RP-17 | SN「観点: graphは知の地図」候補(1)、EX 2026-10-07「古いgraph」 | 前回読んだ状態を覚えておき、変わっていたら「古い」と出す。会話開始時にコードグラフが古いと表示されていた | `observed_at = b87c8428`のnodeは、`b87c8428..bb77fafc`に`Sources/`の変更があるので古い。`bb77fafc`で作り直したnodeは古くない | nodeの`observed_at`、比較するHEAD、`git diff --name-only`で写した変更file一覧 | `observed_at`以降に、node自身のfileが変わったかを見る | B | `observed_at`は既にある。変更file一覧のtableを足せば済む | G7は`observed_at`を記録するだけで比較しない |
| RP-18 | SN「観点: graphは知の地図」三分類と候補(2)(4) | 無知の知（辺の先にnodeが無い）、ゴールの無い親task、指摘されたずれを段ごとに記録 | 定義できない | 段階・ゴール（ClaudeのlocalにだけあるRegistry解釈）、会話記録 | — | D | ゴール・段階はrepositoryにfieldが無い。三分類は観点で、期待値が無い | なし |
| RP-19 | TE「Initial scope and acceptance」、EX 2026-10-07「graph側の観測」 | 必須依存だけで判定した着手可能集合が、Registryの表示と一致する | Registryのtask行とprecedence行のsnapshotに対し、表示上の着手可能集合と一致すること | task node（state）、precedence edge、edgeの種別（着手前提か完了前提か） | `ACTIVE`のうち、未完了の着手前提を持たないもの | B | ただし「着手前提か完了前提か」はRegistryの文言から読む解釈で、fieldが無い。fixtureで各edgeの種別を誰が確定するかが未決（下の不足1） | なし |
| RP-20 | EX 2026-10-07「中間ゴールから作業列」、「順序の考え方」 | 中間ゴールから作業taskだけを出して並べる手順。倍率係数と失敗確率で順序を決める着想 | 定義できない | — | — | D | 手順の記録と未確定の着想。期待値を定義できない | なし |
| RP-21 | SN「Fowlerの臭いとの対応」「Meszarosのtest smellとの対応」 | 臭いの分類と、このrepositoryの事例との対応 | 定義できない。事例のうち寿命counter汚染と`AC_COLLECTIONS_INTERNAL_CHECKS`下の公開symbolはC | — | — | D | AIの見立てによる分類。事例の確認にはruntimeか構成ごとのbuildが要る | なし |
| RP-22 | SN 知見1〜3・6・7、「判定の扱い」、EX 2026-10-07の推測 | 不在は compile時のtestで守る、道具の0件はわざと壊して確かめる、graphは候補出しに強く確定に弱い、など | 定義できない | — | — | D | 判断の基準で、回帰fixtureの期待値にならない。「わざと壊して確かめる」はG7の不一致検出で実施済み | 「わざと壊す」はG7の確認で覆われる |
| RP-23 | SN「位置づけ」「2026-10-08の転換」、TE「Authority」「Independent tracks」「Dropped integration」「Exchange task」 | 正本、担当、独立性、統合の取りやめ、交流の規則 | 定義できない | — | — | D | 運用の規則で、関係の主張ではない | G6・G7のschemaが「転換」のschema案を引き継ぐ |

**GRAPH-009へ渡せる候補（G7との重複を除く）**

| 候補 | 足すもの | 期待結果の根拠 |
| --- | --- | --- |
| RP-01 | task→task precedenceのrelation | HEADのTask precedence |
| RP-05 | pathから`role`を計算する規則 | 2 commit分の`git ls-tree` |
| RP-08 | symbolの`access`と構成条件、gap query | `58aab943`前後の仕様test |
| RP-15 | 文書edgeの照合方法 | 2 commit分の`git grep` |
| RP-17 | 変更file一覧のtableと、古いかの判定query | `git diff --name-only b87c8428..bb77fafc -- Sources` |
| RP-19 | taskのstate、edgeの種別、着手可能query | Registryのsnapshot。不足1が決まった場合だけ |

RP-11はAだが、G7と同じ規則の別事例なので、追加するかはCodexが選ぶ。

**不足（推測で埋めていない）**

1. RP-19: Task precedenceの各行が「着手の前提」か「完了の前提」かは、文言（「着手できる」「完了できる」「判断できる」など）からの解釈で、fieldが無い。fixtureで種別を固定するには、誰がどう決めるかが要る。参考の観測: HEADで`GRAPH-004`（`ACTIVE`）←`GRAPH-008`は「確認後、…次段階を判断できる」で、着手前提と読むと`GRAPH-004`は着手可能から外れ、Registryの表示と食い違う。
2. RP-15: 記録には「`f6f84d6c`で確認」とあるが、36件は`bb77fafc`時点の数。`f6f84d6c`は試験記録そのものを追加したcommitで、その2文書が`subscript`を含むため38件になる。GRAPH-007と同じ自己参照で、期待値にどちらのcommitを使うかを決める必要がある（上表は両方を書いた）。

## GRAPH-009: 受入済み項目のSQLite追試fixture化

状態は`PROPOSED`とする。GRAPH-008のCodex受入後、`A / B`から実装対象を確定し、対象項目、期待結果、
schema変更範囲、完了条件をこの節へ追記してから`ACTIVE`へ移す。それまでは着手・委任しない。

現時点の共通境界は次のとおり。

- SQLite `:memory:`とtracked SQLだけを使う。
- 一つのcommandで空DBから全fixtureを実行する。
- 過去結果と現在結果の一致・不一致を項目ごとに表示する。
- Claude専用DB、永続DB、production変更に依存しない。
- 自動抽出が必要な`C`と回帰fixtureにしない`D`は実装しない。

## Codex受入欄

### GRAPH-008

- coverage: 未確認
- 分類根拠: 未確認
- GRAPH-009候補集合: 未確定
- 判定: `ACTIVE`

### GRAPH-009

- scope: 未確定
- 状態: `PROPOSED`
