# 過去graph知見のインメモリ追試

最終更新: 2026-10-08 / Claude（GRAPH-008台帳）。task定義はCodex

## 位置づけ

この文書は、過去のgraph系文書に記録された観測・仮説・反証のうち、`GRAPH-007`で確立した
SQLite `:memory:` fixture方式で追試可能な範囲を分類し、再実行可能な回帰fixtureへ変換する作業の正本である。

作業は、可能性を分類する`GRAPH-008`と、受入済みの対象だけを実装する候補`GRAPH-009`へ分ける。
分類と実装を同時に行わず、過去記録の印象だけでfixtureを増やさない。

## 対象文書

- `Graph/AI_GRAPH_SMELL_NOTES.md`
- `Graph/GRAPH_DB_EXCHANGE.md`
- `Graph/TASK_GRAPH_DB_EXPERIMENT.md`

`Archived/AI_GRAPH_SHARED_SCHEMA.md`と`Archived/AI_GRAPH_IN_MEMORY_FIXTURE.md`は追試方式の入力であり、過去知見の
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

観測時点: HEAD `ce97783d`。略記: SN = `Graph/AI_GRAPH_SMELL_NOTES.md`、EX = `Graph/GRAPH_DB_EXCHANGE.md`、TE = `Graph/TASK_GRAPH_DB_EXPERIMENT.md`、
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

GRAPH-008のCodex受入により、RP-01・RP-05・RP-08・RP-15・RP-17を実装対象とする。
GRAPH-009は5件の子taskを統合して完成判定するtaskとし、各fixtureの実装はGRAPH-010〜014へ分ける。

現時点の共通境界は次のとおり。

- SQLite `:memory:`とtracked SQLだけを使う。
- 一つのcommandで空DBから全fixtureを実行する。
- 過去結果と現在結果の一致・不一致を項目ごとに表示する。
- Claude専用DB、永続DB、production変更に依存しない。
- 自動抽出が必要な`C`と回帰fixtureにしない`D`は実装しない。

### 今回実装しない項目

- RP-11: `task_scopes` 0件の規則はGRAPH-007と同じで、別事例を足す情報利得が小さい。
- RP-14: GRAPH-007が全体を実装済み。
- RP-19: precedence辺が着手前提か完了前提かを示すfieldがRegistryになく、意味判断が未確定。

### GRAPH-010: precedence missing-pair fixture（RP-01）

- 担当: Claude
- `task_precedence` relationをSQLite schemaへ追加する。
- RBT-001・004・010・011と、記録された2辺をfixtureへ入れる。
- 4 taskの全pairから、どちら向きにも辺のない4組を返すqueryと期待値を作る。
- symbol共有、task→symbol、scopeは扱わない。

### GRAPH-011: specification file role fixture（RP-05）

- 担当: Claude
- test pathと観測commitを入力し、旧規則と現行規則で`spec / non-spec`を計算する。
- `d784b91e`とHEAD相当のsnapshotをfixtureへ入れる。
- 現行規則で番号0〜4がspec、98・99がnon-specとなる期待値を固定する。
- Gitやfilesystemからの自動抽出は行わない。

### GRAPH-012: configuration-aware spec-gap fixture（RP-08）

- 担当: Claude
- symbolへaccessと構成条件を表す最小fieldまたはtableを追加する。
- `RedBlackTreeBoundExpression.find(_:)`と`RedBlackTreeSet.freeCapacity`、`58aab943`前後のtest edgeをfixture化する。
- DEBUG限定symbolをRelease公開gapから除き、test追加前は`find(_:)`だけ1件、追加後は0件となるqueryと期待値を作る。
- compilerやbuildからの自動抽出は行わない。

### GRAPH-013: document match precision fixture（RP-15）

- 担当: Claude
- 文書照合方法を表すfieldまたはrelationを追加する。
- `bb77fafc`時点を基準snapshotとし、`subscript`単語だけ36件、所属型との組で9件を期待値にする。
- `f6f84d6c`で38件になる自己参照増加は別snapshotとして記録し、基準件数へ混ぜない。
- 文書filesystemからの自動抽出は行わない。

### GRAPH-014: observation staleness fixture（RP-17）

- 担当: Claude
- nodeの`observed_at`と、commit間で変更されたfileのsnapshotを使う。
- `b87c8428`観測nodeは`bb77fafc`時点でstale、`bb77fafc`観測nodeはnot staleとなるqueryと期待値を作る。
- Gitから変更fileを自動抽出せず、追試に必要な入力をfixtureへ明示する。

### GRAPH-009の完了条件

- GRAPH-010〜014をCodexが個別に受入済み。
- repository rootから一つのcommandでGRAPH-007と追加5 fixtureを空のSQLite `:memory:`へ読み込める。
- 各replay IDについて独立したPASS / FAILが表示される。
- 既存GRAPH-007の8区分が引き続きPASSする。
- Claude専用DB、永続DB、production変更、自動抽出へ依存しない。

### GRAPH-010〜014 Claude実装結果（2026-10-08）

各fixtureは単独のfileで、repository rootから空の`:memory:`へ流す。どれも`schema.sql`を読んでから自分の入力を足すので、互いに独立している。

```sh
for f in rp01_precedence rp05_spec_role rp08_spec_gap rp15_document_match rp17_staleness; do
  sqlite3 :memory: < Maintanance/Graph/InMemoryFixture/$f.sql | tail -1
done
```

| task | file | 結果（最終行） | 足したもの |
| --- | --- | --- | --- |
| GRAPH-010 | `rp01_precedence.sql` | `RP-01: PASS (4 pairs without a precedence edge)` | `schema.sql`の`edge.relation`に`task_precedence`を追加（srcのtaskがdstのtaskを必要とする） |
| GRAPH-011 | `rp05_spec_role.sql` | `RP-05: PASS (current rule: 0-4 spec, 98 and 99 non-spec)` | `test_path`（snapshot別のpath）と、file名から旧規則・現行規則の`role`を計算するview |
| GRAPH-012 | `rp08_spec_gap.sql` | `RP-08: PASS (before 58aab943: 1 gap find(_:), after: 0; freeCapacity excluded as DEBUG-only)` | `symbol_config`（accessと`#if`条件）、`introduced_by`（commitが加えたedge。前のsnapshotはこれを除いて作る） |
| GRAPH-013 | `rp15_document_match.sql` | `RP-15: PASS (baseline bb77fafc: word 36, with owner 9; f6f84d6c: 38 / 9)` | `document_match`（snapshot・path・所属型も含むか）。`f6f84d6c`で増えた2件が当時の`AI_GRAPH_SMELL_NOTES.md`と`GRAPH_DB_EXCHANGE.md`であることも照合 |
| GRAPH-014 | `rp17_staleness.sql` | `RP-17: PASS (observed at b87c8428: stale, at bb77fafc: not stale)` | `observation`（nodeの観測commitごとの記録）、`diff_range`・`changed_file`（写したcommit範囲と変更file）。写していない範囲は`unknown`とし、「変更なし」と区別する |

**確認したこと**

- GRAPH-007の`run.sql`は、`schema.sql`変更後も`PASS: all 8 section counts match`。
- 6 fileすべてで`PRAGMA foreign_key_check`の違反0件。
- 各fixtureで期待値か入力を1か所ずらしてpipeで流すと、5本とも`FAIL (2 mismatch(es))`になる（fileは変更していない）。

**決めずに記録した前提**

- RP-05の旧規則: `Graph/AI_GRAPH_SMELL_NOTES.md`に「`RedBlackTree*_NN_*`」とだけあり、番号の上限（`< 90`）があったかは記録が無い。対照用のRedBlackTree fileは番号16の1件だけにして、上限の有無で結果が変わらないようにした。
- RP-08の「DEBUG限定」の判定: `#if`条件に`DEBUG`を含み、`!DEBUG`を含まないもの。`freeCapacity`の条件は`DEBUG && !COMPATIBLE_ATCODER_2025`（`BalancedSequence.swift:188`）。条件式の一般的な評価はしていない。
- RP-08の`58aab943`より前: 仕様testから`find(_:)`への参照が無いことは、当時の`spec-gaps`の記録に基づく。index storeを再構築して確かめてはいない。

### GRAPH-009 一括実行の入口（2026-10-08 / Claude）

repository rootから次の一つで、GRAPH-007とRP-01・05・08・15・17の6件を実行する。

```sh
sh Maintanance/Graph/InMemoryFixture/run_all.sh
```

- `run_all.sh`は各fixtureを別の`sqlite3 :memory:`で流す（fixture同士でDBを共有しない）。Claude専用DBや永続DBは読まない。
- fixtureごとに`PASS` / `FAIL`と最終行を1行ずつ表示し、最後に`ALL PASS: 6 of 6 fixtures`または`FAILED: N of 6 fixtures`を出す。
- 終了コードは全件PASSのときだけ0、それ以外は1。fixtureのFAIL行、SQL error（`sqlite3`の終了コードが0以外）、PASS行が出ない場合はすべてFAILとして数える。
- 確認: 全件で`ALL PASS: 6 of 6 fixtures`、終了コード0。一時directoryへの複製で、RP-15の期待値を1か所ずらすと`FAILED: 1 of 6 fixtures`・終了コード1。RP-01の先頭に存在しないtableへのSELECTを入れると、RP-01が`sqlite3 exit 1`のFAILになり、同じく全体失敗になった。repository内のfixtureは変更していない。

## Codex受入欄

### GRAPH-008

- coverage: 受入。対象3文書の見出しと試験記録を23項目へ対応し、重複記録は代表項目へ統合した。
- 分類根拠: 受入。repositoryに入力のないtask→symbol・親子関係をD、自動抽出・runtime・機械語を
  必要とするものをCへ置き、AI推定でA/Bへ昇格していない。
- GRAPH-009候補集合: RP-01、RP-05、RP-08、RP-15、RP-17。RP-11・14は重複、RP-19は意味判断不足で除外。
- 判定: `DONE`

### GRAPH-009

- scope: GRAPH-010〜014の5 fixtureと一括再現・回帰確認。
- 個別fixture: 受入。RP-01・05・08・15・17がそれぞれ独立してPASSすることをCodexが確認した。
- 一括実行: 受入。`sh Maintanance/Graph/InMemoryFixture/run_all.sh`をrepository rootから実行し、
  GRAPH-007を含む6件すべてのPASSと`ALL PASS: 6 of 6 fixtures`を確認した。
- 終了状態: 受入。全件成功時のexit status 0を確認し、runnerがSQL error、PASS行欠落、FAILを
  全体失敗として集約することを実装で照合した。
- 依存境界: 受入。各fixtureは別の空SQLite `:memory:`を使い、Claude専用DB、永続DB、production変更、
  runtime自動抽出に依存しない。
- 状態: `DONE`

## RP-19の採用判断と段階移行（2026-10-08）

Claudeのユーザーインタビューで、Task precedenceの各辺へ「着手の前提」か「完了の前提」かを示す
fieldを追加する提案があった。`GRAPH-004` ← `GRAPH-009`を着手前提と読むと、Registryで`ACTIVE`の
`GRAPH-004`がDBでは着手不可となる食い違いを再確認した。この辺は、共有スキーム試験を並行して進める
ことを妨げず、追試受入前の完成判定だけを止める完了前提である。

ユーザーとCodexは、この提案を採用し、次の意味を確定した。

| Gate | 意味 | readinessへの作用 | completionへの作用 |
| --- | --- | --- | --- |
| `START` | 前提taskの完了まで後続taskを開始・assignできない | 未完了ならreadyではない | 着手済みならRegistry不整合として扱う |
| `COMPLETE` | 後続taskは並行着手できるが、前提taskの完了まで完成判定できない | 阻止しない | 未完了なら`DONE`にできない |
| `UNCLASSIFIED` | 移行中で意味をまだCodexが確定していない | ready／not readyを自動確定しない | complete／incompleteを自動確定しない |

Gateは条件付き依存を表す`制約`欄を置き換えない。前提taskが`EXCLUDED`の場合も自動的に充足とはせず、
後続taskを`EXCLUDED`にするか、辺または制約を更新してから再判定する。DBとfixtureはRegistryへ状態を
書き戻さず、`UNCLASSIFIED`を文言から推定して補完しない。

全行を一度に変換すると、`START`を`COMPLETE`と誤って前提未完了の作業を開始する危険と、逆方向に
誤って作業を不必要に止める危険がある。このため、次の順で段階移行する。

1. Task precedence表へGate列を追加し、現行`ACTIVE` taskに関係する辺だけをCodexが分類する。
   他の既存辺は`UNCLASSIFIED`とする。新規または意味を更新する辺には`START`か`COMPLETE`を必須とする。
2. Claudeが確定済みpilotだけを入力にRP-19 fixtureを作り、`START`だけがready判定を阻止すること、
   `COMPLETE`と`UNCLASSIFIED`を混同しないことを再現する。
3. Codexが残る`UNCLASSIFIED`を小さいbatchで分類し、各batchでRegistry表示とready集合の差分を検収する。
4. 全辺の意味とfixtureが安定した後にだけ、Gateを必須欄として完成判定する。

意味分類、Registry更新、移行の完成判定はCodexが担い、Claudeは確定済み分類に対するDB・fixture実装を
担う。この採用判断によりRP-19は「意味判断不足で実装しない」状態から、pilot後に実装可能な状態へ移った。

### Gate列pilot結果（2026-10-08 / Codex）

Task precedenceへGate列を追加し、現行`ACTIVE` taskを始点または終点に持つ6辺だけを分類した。

| 後続task | 前提task | Gate | 根拠 |
| --- | --- | --- | --- |
| `GRAPH-004` | `GRAPH-009` | `COMPLETE` | 共有スキーム試験は並行着手でき、追試fixture群の受入が次段階の判断だけを止める |
| `GRAPH-016` | `GRAPH-015` | `START` | Gateの意味と移行方針の決定前にはpilotを開始しない |
| `GRAPH-017` | `GRAPH-016` | `START` | 確定したpilot分類をfixture入力にする |
| `GRAPH-004` | `GRAPH-018` | `COMPLETE` | 共有スキーム試験は継続できるが、Gate移行前には試験全体を完了できない |
| `PERM-014` | `PERM-003` | `START` | 現行契約の基準固定後にだけ実施手順を決定する |
| `PERM-015` | `PERM-014` | `START` | 実施手順の決定結果を入力にtask依存を再評価する |

その他の既存辺は意味を自動推定せず`UNCLASSIFIED`とした。これによりRP-19 fixtureへ渡すpilot入力が
確定したが、後続taskは明示的な再開指示があるまで`FROZEN`を維持する。

### 後続fixtureの終了（2026-10-09）

Codex用graph DBと共有smell判定スキームを継続しないとのユーザー判断により、RP-19 readiness fixtureと
Gate段階移行の完成判定は不要になった。pilotで確定した`START` / `COMPLETE`の意味と既存fixtureは保持するが、
未分類辺をDBのために全件移行する作業は行わない。Registryで新規・更新する辺には、引き続き確定したGateを付ける。

### 同期位置としての名称変更（2026-10-09）

ユーザーとCodexは、task依存が同期処理であることを確認し、現行名称を`Flow`列の`SEQUENCE` /
`PARALLEL_JOIN`へ変更した。`SEQUENCE`は旧`START`（一時案`HEAD`）、`PARALLEL_JOIN`は旧`COMPLETE`
（一時案`LAST`）と同じ意味を持つ。この節より前の旧表記は、採用時点の履歴として保持する。
