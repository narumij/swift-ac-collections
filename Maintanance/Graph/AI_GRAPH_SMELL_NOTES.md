# AIとインメモリ関係モデルによるSmell知見ノート（code / test / task）

最終更新: 2026-10-08 / Codex（インメモリ・スキーム共有へ転換）

## 位置づけ

この文書は、AIがrepositoryの関係を解析時にインメモリへ構築して観察したときに見つかるsmellと、
その判定方法に関する継続的な知見ノートである。永続graph DBそのものを共有基盤にせず、
CodexとClaudeがnode、edge、根拠、確度、query、判定結果のスキームを共有する。

- 編集担当: Codex / Claude
- 閲覧者: User / Codex / Claude
- CodexはTask Registryの状態管理と共有スキームの統合を担当する。
- Claudeは合意済みスキームを使った観測、仮説、反証、判断基準を自由に追記・整理できる。
- このノートはTask Registryや各taskの詳細正本を置き換えない。
- ノート中の候補を、記録しただけで実装taskや着手可能taskとして扱わない。
- `GRAPH-001`の永続task graph DBとは独立して扱い、DB同士の統合を目的にしない。
- 正式運用への昇格、source変更は、この試験とは別に決定する。

## 2026-10-08の転換

`GRAPH-004`は、永続graph DBを中心とする独立試験から、解析ごとに関係をインメモリへ構築し、
AI間で判定スキームを共有する試験へ移行した。

- source、compiler index、test、documentation、Git履歴、Task Registryを正本とする。
- 関係グラフは観測時に生成し、解析終了後に破棄できる一時データとする。
- 永続化するのは、再利用可能なスキーム、query、観測結果、反証、例外、人の判断である。
- ストレージ実装は固定しない。Swiftの辞書・集合、隣接リスト、SQLite `:memory:`などを、問いに応じて選べる。
- コンパイラで解決した事実、構文から得た関係、AIの推定を混同せず、出所と確度を保持する。

初期の共有スキームは次を最小単位とする。

- node: symbol、source file、test、document、commit、task、decision
- edge: declaration、reference、call、test evidence、documentation mention、change、task scope、precedence
- provenance: syntax、compiler-resolved、repository record、runtime observation、AI-inferred
- confidence: confirmed、supported、hypothesis、refuted
- finding: observation、smell hypothesis、counterevidence、impact、next check、human decision

このスキームは初期仮説であり、実地の当たり・空振りを受けて変更する。スキーム変更そのものは
公開APIやtask方針の決定ではないため、ノート内で試行できる。

## 用語と対象

旧名は「refactoring smell」（2026-10-07にユーザー判断で改名）。一般的な用語に合わせ、
対象を次の3種類に分けて扱う。

- code smell: production codeの臭い。出典はMartin Fowler『Refactoring』（用語はKent Beck）。
- test smell: test codeとtest運用の臭い。出典はGerard Meszaros『xUnit Test Patterns』（2007）。
- task smell: task graphの区切り方・順序制約の臭い。このrepository固有の観点（S-1〜S-3）。

## 目的

- source、test、documentation、履歴、task graph間の関係からsmellを見つける。
- AIの推測と構文・コンパイラ・repository記録から得た構造的事実を分離する。
- 誤検知、反証、見送り理由を残し、同じ調査の反復を減らす。
- repository固有の観測から、ほかの作業にも再利用できる判断基準を抽出する。
- インメモリ関係モデルの粒度、辺の種類、query方法が発見精度へ与える影響を記録する。

## 自由編集の範囲

CodexとClaudeは、見出し構成、分類、記録形式、仮説、query例、評価軸を必要に応じて変更できる。
sourceやtestの変更、Task Registryの更新、新規task化、凍結taskの再開はこの自由編集に含まれない。

知見から具体的な変更候補が生じた場合は、本文に候補として記録する。実装が必要なら、ユーザーまたは
CodexがTask Registry上の独立taskとして採否と状態を確定する。

## 推奨する観測単位

各項目では、可能な範囲で次を区別する。

1. 観測した事実と参照元
2. smellと考える仮説
3. graph DBが与えた根拠
4. AIによる解釈
5. 反証または代替説明
6. 影響範囲と確信度
7. 実装せず記録だけに留める理由
8. 再利用可能な判断基準

形式は固定しない。Claudeが知見を残しやすく、閲覧者が事実と推測を判別できることを優先する。

## 初期観点

- 利用されないpublic API、protocol、extension、compatibility path
- sourceの依存関係とtest coverageの非対称
- documentationと実装の表現差・更新遅延
- task境界とcode graph上の変更波及範囲の不一致
- 構成条件ごとに変わる公開面や適合集合
- 名前、責務、所有moduleが依存構造と一致しない箇所
- 履歴上の暫定判断が恒久的な設計制約として残る箇所
- graphに現れないruntime、aliasing、lifetime、性能上の関係

## 知見ログ

Claudeがここから自由に追記・再構成する。

### 判定の扱い

- 候補: 着想段階。まだ実地で試していない。
- 試験中: 実作業で当てて、当たり・空振りを記録している。
- 知見: 当たりが続き、ほかの作業にも使える判断基準として残す。

閾値は先に決めず、試験の当たり・空振りから決める。graphの結果は候補出しに使い、確定は
コンパイラ・テスト・人の判断で行う。

### Fowlerの臭いとの対応（2026-10-07）

出典: Martin Fowler『Refactoring』第2版（2018）の24の臭い。graphで見つけやすいかで3つに分ける。
分類はAIの見立てで、実地で当たり・空振りを見て直す。

- graph向き（依存・参照・変更履歴で分かる）: Divergent Change、Shotgun Surgery、Feature Envy、
  Insider Trading、Message Chains、Middle Man、Lazy Element、Refused Bequest、Large Class
- 半分graph向き（graphで候補を出し、読んで確定する）: Speculative Generality、
  Long Parameter List、Data Clumps、Duplicated Code、Global Data、Mutable Data、Temporary Field、
  Data Class、Alternative Classes with Different Interfaces、Repeated Switches
- 読まないと分からない: Mysterious Name、Long Function、Primitive Obsession、Loops、Comments

本ノートの候補との対応:

- S-1 ≒ Divergent Change（変更理由をtaskに置き換えたもの）
- S-3 ≒ Large Classのtask版
- S-2・S-4: Fowlerの一覧に対応なし。task graphとtest coverageに固有の観点
- PERM-003で見つけた`nextPermutation(upperBound:)`の死んだ引数 = Speculative Generality

### Meszarosのtest smellとの対応（2026-10-07）

出典: Gerard Meszaros『xUnit Test Patterns』（2007）。3つの層に分かれる。

- code（test codeを読めば分かる）: Obscure Test、Conditional Test Logic、Hard-to-Test Code、
  Test Code Duplication、Test Logic in Production
- behavior（実行すると分かる）: Assertion Roulette、Erratic Test（原因の1つにInteracting Tests）、
  Fragile Test、Frequent Debugging、Manual Intervention、Slow Tests
- project（運営で分かる）: Buggy Tests、Developers Not Writing Tests、High Test Maintenance Cost、
  Production Bugs（原因にUntested Code、Untested Requirementなど）

graph向きなのは、Untested Code（production symbolとtestの参照辺）、Test Logic in Production
（test専用flag下の公開symbol）、Interacting Tests（process-globalな状態を触るtestの集合）。
残りは主に読む・実行する側で見る。

本ノート・このrepositoryとの対応:

- S-4 ≒ Untested Code
- PERM-003の`PermutationRemovedAPITests` = Untested Requirement（削除済みAPIを出さない要件）を
  埋めたもの。項目ごとに文を分けた直しは、Assertion Rouletteを避けるのと同じ考え方
- RedBlackTreeのlifetime counter汚染（XCTestの順番次第で落ちた件） = Interacting Testsによる
  Erratic Test
- `AC_COLLECTIONS_INTERNAL_CHECKS`下の`_copyCount`等: Test Logic in Productionの境界。意図した
  設計なので、臭いと確定しない。観測対象として残す

### S-1 1つのsymbolに複数taskが集中する（候補）

- 事実（2026-10-07）: `_LazyTieWrap.<(_:_:)` を `RBT-001`・`RBT-004`・`RBT-010`・`RBT-011`
  のscopeが共有する。このうち `RBT-001/RBT-004`、`RBT-004/RBT-010`、`RBT-004/RBT-011`、
  `RBT-010/RBT-011` の間にはprecedence辺がない。
- 仮説: 変更理由の多いsymbolは、設計上の決め事がまだ決まっていない点である。コードの
  「変更理由が多すぎるクラス」に相当する。
- 代替説明: 比較演算子のように、広く使われるだけで決め事を含まない基盤symbolかもしれない。
  その場合は辺の書き漏れではない。
- 次の確認: 各taskの詳細正本で、このsymbolに対する意図が衝突しているかを見る。

### S-2 precedence辺はあるがコード上の結合がない（候補）

- 仮説: 理由の書かれていない順序制約は、不要な待ちを生んでいる可能性がある。
- 代替説明: 文書・CI・判断の順序のように、コードに現れない依存は正当である。
- 反例（2026-10-07）: `PERM-004 <- PERM-003`、`PERM-007 <- PERM-006` はコードを共有しており、
  この臭いには該当しない。

### S-3 scopeが過大なtask（候補）

- 事実（2026-10-07）: `RBT-005` のscopeは75 symbol。PermutationModule全体（73 symbol）と同程度。
- 仮説: task境界が粗く、完了判定や依存判定がぼやける。「大きすぎるメソッド」に相当する。
- 代替説明: 一律の機械的変更（命名・属性の横展開など）なら、広くても境界は明確である。

### S-4 fan-inが大きいのに仕様testから参照されない（候補）

- 仮説: 壊れたときの波及が大きいのに守られていない急所である。
- 代替説明: 内部の基盤symbolが、上位APIの仕様testを通じて間接的に守られている場合がある。
  直接の参照がないことは、守られていないことを意味しない。
- 次の確認: 間接的に守られているかは、テストを壊して確かめる（mutation的な確認）以外に
  判定しにくい。費用が高いので、対象を絞ってから行う。

### 試験記録: PERM-003（2026-10-07, d784b91e）

**S-2の結果: 判定不能（scopeが粗い）。** `PERM-001/004/006/007`のscopeはどれも
PermutationModule全体（73 symbol）なので、どの2つを選んでもコード上の結合ありになる。
S-2は、scopeがtaskごとに絞られていて初めて意味を持つ。S-3（scope過大）が先に解消されないと、
S-2は空振りではなく「常に当たり」になって情報を持たない。
`PERM-005/008/009/010`にはscopeがない。Package設定・CI・生成・文書の順序制約なので、
S-2の代替説明（コードに現れない依存）に当たる。

**S-4の結果: 道具の死角。** `spec-gaps`は`RedBlackTree*_NN_*.swift`だけを仕様testとして数える。
PermutationModuleには番号付き仕様testがないため、このmoduleは最初から対象外になる。
手で見ると、公開API（`nextPermutations()`・`Nexts`・`IteratorN`・`SubSequenceN`）は
すべて`PermutationTests`から参照されていた。

**当たり1件（S-4の延長、graph＋目視）。** `code-impact NextPermutationProtocol`で、内部の
急所（全公開APIが経由する）を特定し、本文を読んだ。
- 事実: `nextPermutation(upperBound:)`の`upperBound`は、現行版でも基準ref
  （`release/AtCoder/2025`）でも、呼び出し側から一度も渡されない。そのため`i < upperBound`は
  常に真になり、`else`節（`i = index(before: endIndex); continue`）には到達しない。
- 解釈: swift-algorithmsの部分順列（k-permutations）用の引数が、移植時にそのまま残ったもの。
- graphの役割: 急所の特定まで。引数の既定値や到達不能な分岐はsymbol graphに現れないので、
  発見そのものは目視による。
- 実装しない理由: このfileは通常版と互換版で共有する予定（互換計画）なので、削るなら両modeに
  効く。また、削除にはユーザーの指示が要る。
- 候補: 引数と`else`節を削る。採否はユーザーが決める。

**追記（2026-10-07、PERM-012の後）: `spec-gaps`の死角を2つ塞いだ。**
- 対象範囲: 仕様testのfile名規則を`RedBlackTree*_NN_*`から`<公開型>_NN_*`へ、調べる公開APIを
  `RedBlackTreeCollections`だけから`PermutationModule`も含むよう広げた。
- 古い索引: index storeは、名前を変えた・消したtest fileの索引を残す。これを数えていたため、
  仕様fileを`_9x`へ改名しても「指摘0件」のままだった。ディスク上に無いfileの索引を除外して解消。
- 確かめ方: 仕様fileを一時的に`_9x`へ改名して指摘が出ること、戻して0件になることを確認した。
  道具の「0件」は、わざと壊して指摘が出るのを見るまで信用しない。

**追記（2026-10-07、`PERM-013`追加時）: 粗いscopeは逆向きの誤検知も出す。**
`PERM-013`（性能のCI比較）にPermutationModule全体のscopeを付けると、`scope-check`は互換mode系の
`PERM-001/004/006/007`との間に「辺なし・コード上の結合あり（依存の書き漏れ候補）」を4件出した。
実際には、通常版の性能測定と互換版の追加の間に順序の依存はない。S-2（辺あり・結合なし）だけでなく、
その逆（辺なし・結合あり）も、scopeがmodule単位のままでは情報を持たない。

**反証（2026-10-07、同日夕）: このうち`PERM-004 / PERM-013`は誤検知ではなく当たりだった。**
ユーザーとPERM-004の手順を話すうちに、性能の基準（`PERM-013`）を先に取らないと、未計測の通常版の
変更（`@inline(__always)`の全削除、`next()`の変更）の影響と、`PERM-004`のファイル再配置による
コード配置のノイズを分けられないと分かった。順序の依存は「コードを変える順」ではなく
「測定の帰属を保つ順」としてあった。AIは「互換版を足すだけで通常版は変わらない」と考えて、
graphの指摘を退けていた。
- 知見7: 「辺なし・結合あり」を誤検知として退ける前に、性能・測定・検証の帰属が順序に依存しないかを
  確かめる。コードの意味では独立でも、測定では独立でないことがある。

**知見（再利用できる判断基準）。**
1. graphは「あるのに守られていないもの」は探せるが、「無いままであるべきもの」は表せない。
   削除済みAPIの非露出のように、不在を守る契約は、graphではなくcompile時のtestで固定する
   （PERM-003で`PermutationRemovedAPITests`として実施）。
2. fan-inの大きい内部symbolは、仕様testの有無より先に本文を読む価値がある。全経路が通るので、
   死んだ引数や分岐のような残骸が、変更なしで長く残りやすい。
3. 道具の対象範囲（今回は`spec-gaps`のfile名規則）を先に確かめる。対象外のmoduleでの
   「指摘0件」は、問題が無いことを意味しない。

### 試験記録: Permutation・赤黒木の臭いチェック（2026-10-07, 4eae63f9〜19a894c3）

**graphで当たったもの。**
- `spec-gaps`: 未参照の公開APIが2件出た。`RedBlackTreeBoundExpression.find(_:)`は本物の空き
  （仕様testを追加して解消）。`RedBlackTreeSet.freeCapacity`は`#if DEBUG`限定のBalanced群で、
  Releaseの公開APIではなかった（誤検知）。`#if DEBUG`の中の宣言を数えないよう道具を直した。
- `check`の「`@inlinable`本体から呼ばれる非`@inlinable`関数」12件: 静的には候補止まり。
  Releaseで利用側moduleの機械語を見ると、SwiftPMのmoduleをまたぐ最適化で`elementsEqual`や
  `unsafeValues`などは展開されていた（空振り）。本物は1件で、`filter`・`mapValues`の特殊化版が
  未特殊化の`__construct_node<A>`を要素ごとに呼んでいた。同じ関数でも`insert`では問題がなく、
  当たり・空振りは呼び出し元ごとに分かれる（ユーザーが`@inlinable`を付けて解消）。

**graphでは見えず、読んで見つけたもの。**
- `ManagedBuffer`の`header`を`deinit`で手動破棄していた二重破棄（headerが自明な型だけなので潜伏）。
- 終端に達するだけの無駄なコピー、`swapAt`のTODOの事実誤り（奇数長の反転で自己交換は起きる）。
- 横に比べて分かった不揃い: Permutationの`_copyCount`だけ`public`で、赤黒木は`package`。

**誤った臭い（AI側の誤読）。**
- Registryの`RBT-012`が発見元としてPermutationの`ensureUnique()`に触れていたため、改名すると
  taskとの対応が壊れると考えた。task文書の記述は経緯であり、別スコープのコード名を縛らない。
  名前の一致は結合ではない（scopeの過大登録と同種の誤り）。

**知見（再利用できる判断基準）。**
4. 特殊化境界の候補は、静的な属性の組み合わせではなく、利用側moduleのReleaseの機械語で
   未特殊化の呼び出しが残るかで判定する。判定は呼び出し元ごとに行う。
5. 公開APIの検査では、`#if DEBUG`などの構成限定の宣言を先に分ける。分けないと、Releaseに
   存在しないAPIを「守られていない」と数える。
6. メモリの寿命・CoWの誤りはsymbol graphに現れない。fan-inの大きい型の`deinit`とCoWの入口は、
   graphの結果と関係なく本文を読む。

### 試験記録: taskの臭い（2026-10-07夜、`RBT-017`）

**「実装中に決め事が出る」は、taskの不足の臭い。** `RBT-017`（範囲の値ビューの範囲外更新を止める）は、方向（検査を足す）だけが
決まった状態でRegistryに載った。実装を始めると、検査を省く条件、計算量の変化、停止メッセージ、`@inlinable`の追加、読み取りの扱い、
添字の種類、MultiMapのtestと、7つの決め事が出てきた。Claudeはそれを自分で埋めて実装し、ユーザーに「相談が必要なことを独断で決めた」と
止められ、実装を取り下げた。
- 判断基準: taskの途中で決め事が出てきたら、それは「手順・仕様を決めるtaskが前に足りていない」という不足。自分で埋めずに、
  taskの過不足として報告する。`PERM-004`の前に`PERM-014`（手順決定）が要ったのと同じ形。
- graphとの関係: この臭いは依存graphには現れない（task 1行の中に決め事が隠れている）。見つかるのは手を動かし始めてから。
  だから「実装の最初の数歩で決め事が出たら止まる」を、作業側の規律として持つ。
- 時間帯との関係（ユーザーの着想）: 決め事の済んだtaskは夜（判断力が落ちる時間）に回せる。昼は、夜に回せるtaskを作る決め事を優先する。

### 試験記録: taskの臭い その2（2026-10-08、`RBT-017`〜`RBT-025`）

**「決め事を分解しても、前提そのものが誤っていた」。** 前日の臭いを受けて`RBT-017`を一判断ずつ9 taskへ分解し、判断4件を閉じた。
実装を始めると既存の仕様testが赤になり、`211ca2fc`（2026-10-05）で同じ検査を意図して外したO(1)契約が見つかった。9件すべて`EXCLUDED`、
コード変更はゼロ。発端は`RBT-013`の「文書は範囲内前提なのに実装は検査しない＝不一致」という誤読（事前条件を実装で検査しないのは不一致ではない）。
- 判断基準: 「足す／戻す」taskは、対象行の`git log -L`・仕様test・API Matrixで直近の逆向きの決定を先に探す。仕様testを最初に走らせると
  衝突が早く出る。分解の細かさは、前提の正しさを保証しない。
- graphとの関係: 分解で生まれたnodeが全部`EXCLUDED`で閉じ、親も`EXCLUDED`になる形は、後から見ると「前提の誤り」の痕跡として拾える。
  依存graphは形が整っていたので、事前には見えなかった。
- 失敗ではなく発見として扱う（ユーザー）: 結果として、O(1)契約を文書段階で見直す`RBT-026`が残り、DISCOVERYの確認範囲も決まった。

### 観点: 隣接を先に引く（2026-10-08、ユーザーの着想）

**「分からない」と思った所のほとんどは、すでに知っていることの隣にある。** 今日の失敗はどれも、知らなかったのではなく、
知っていることを使う場面で気づかなかった形だった（O(1)契約は触るコードの隣の`API-Matrix-View.md`と仕様testにあり、判断の根拠は
既存メモ「契約は信じる」にあり、段階ゴールの観点は同じ夜に得たばかり）。だから未知に当たったら、新しく調べに行く前に、まず隣を引く。
- 判断基準: taskの対象symbolに対し、着手前に「隣」を列挙する。依存先・利用箇所、付いているメモ、参照している仕様test、
  同じsymbolに乗る他task、対象行の直近の変更（`git log -L`）、そのsymbolを名指しする文書。
- graphとの関係（確認済みの事実）: 今の`code-impact`が返す隣はSourcesの利用箇所とメモだけで、`RBT-018`当時に引いても
  10/5の契約には届かなかった。仕様testの参照は`spec-gaps`がtestのindex storeから都度作っているが、symbolの隣としては出していない。
  文書の名指しとgit履歴はgraphに無い。隣接を先に引くには、この3種（仕様test・文書・直近の変更）をsymbolの隣として出す必要がある。
- 試すこと: `code-impact`に「参照する仕様test」「名指しする文書」「対象行の直近commit」を並べ、次のDISCOVERYで実際に効くかを見る。

### 観点: graphは知の地図（2026-10-08、ユーザーとの振り返り）

**ユーザーの頭の中はグラフで、mdのメモリは線形。** mdのメモリは説明文が話題に近いときにしか呼ばれず、触っているcode・taskと
結び付かない。graph DBのメモはsymbol・taskに付き、そのtaskが着手可能になると要約へ自動で出る。思い出すのではなく、
触った場所から知識が出てくる。これがmdの弱点を補うための道具だった。今夜は学びを全部mdに積み、補う側を使っていなかった。
- 三分類（グラフの例えで）: 無知の知 = 辺はあるが先のノードが無い（BARE-001のゴール）。機械的に検出できる。
  知の無知 = ノードはあるが今いる所からの辺が無い（「契約は信じる」とMapped Values Viewの間）。辺を張れば直る。
  無知の無知 = ノードも辺も無い。graphでは見つからず、会話で見つける。
- 置き場の判断基準: 場面に結び付く知識（このsymbolの契約、このtaskの前提）はDBのメモとして該当ノードへ付ける。
  場面に依らない振る舞い方だけをmdのメモリに残す。
- 次のgraph作業の候補: (1) Registry・詳細正本の前回読んだ状態を覚え、変わっていたら「読み直せ」と出す（事実の賞味期限）
  (2) 段階・ゴールの無い親taskを警告する（行き先の無い辺） (3) DISCOVERY開始時に対象symbolの仕様test・文書・直近の変更を並べる
  （隣を引く） (4) ユーザーに指摘されたずれを事実・手順・観点・目的の段ごとに記録し、ループが上の段へ上がっているかを見る。

### 試験記録: 隣を引く（2026-10-08、Claude graph）

「観点: 隣を引く」の試すことを実装し、`RBT-017`の対象（Mapped Values Viewの`subscript`・`swapAt`）へ遡って当てた。
- 結果（事実）: 仕様test（`RedBlackTreeView_0_MappedValuesViewTests.swift`）、名指しする文書（`API-Matrix-View.md`を含む9件）、
  宣言本体の直近commit（先頭が`211ca2fc` 2026-10-05「make mapped values index operations constant time」）の3経路すべてで、
  10/5のO(1)契約に着手前に届く。`RBT-018`当時に引いていれば、誤った前提のtask分解は避けられた。
- 調整（事実）: `subscript`のような一般名は文書36件・無関係taskを拾った。memberは所属型の名前も含む文書だけに絞ると9件になり、
  全件が関係文書だった。
- 限界（推測）: commit履歴は宣言本体の範囲で取るので、別fileへ移された判断や、文書だけで決めた契約は経路3では届かない。
  経路2（文書）と経路1（仕様test）が補う前提で使う。
- 運用: DISCOVERYと「足す／戻す」taskの着手前に、対象symbolへ一度引く。

### 試験記録: Permutationのbuffer要素アクセス経路（2026-10-09、`GRAPH-004` fallback）

2026-10-09 06:48 JST / Claude Opus 5.5（`claude-opus-5-5`）。`CLAUDE_TASK.md`のbounded assignment。
問い: `Permutation`の公開subscript、内部`Buffer.subscript`、`__storage_ptr`の複数経路は、保守上のsmellか、
公開境界・CoW・unsafe境界を分けるための必要な構造か。source・test・文書は変更していない。build・benchmarkは実行していない。

**1. 事実（`Sources/PermutationModule/Permutations.swift`と`git log -L`）**
- 経路は3段。
  - 公開`Permutation.subscript(position:)`（188行）: `@inlinable`。範囲の`precondition`を行い、`elementBuffer[position]`へ委ねる。
    読み取り専用（`Permutation`は`let elementBuffer`だけを持つ）。
  - 内部`Buffer.subscript(position:)`（252行）: `@inlinable`。getterは`@inline(__always)`で`unsafe __storage_ptr[position]`、
    `_modify`は`__storage_ptr`をlocalへ取り出して`yield unsafe &storage[position]`。
  - `__storage_ptr`（225行）: `@inlinable @unsafe`。`withUnsafeMutablePointerToElements({ unsafe $0 })`で
    pointerをclosureの外へ持ち出す。参照元は`Buffer.subscript`のgetterと`_modify`だけ。
- `Buffer.subscript`の利用者: 公開subscript（get）、`swapAt`（`swap(&self[a], &self[b])`で`_modify`）、
  `lastIndex(where:)`・`lastAscentIndex`（get）。`nextPermutation`と`reverse`はこれらを経由する。
- 同じstorageへの別の入り方が3か所ある: `deinit`（`withUnsafeMutablePointers`）、`copy()`と`prepare(source:)`
  （`withUnsafeMutablePointerToElements`のclosure内で使う）。こちらは持ち出さず、closure内で完結する。
- test・benchmarkは`__storage_ptr`も`elementBuffer`も直接参照しない（`grep`で0件）。仕様は公開subscript経由で固定されている。
- 変更履歴: 3宣言とも初出は`bab50616`（2025-01-02、ユーザー）。`fd68782c`（2026-10-03）で`@unsafe`・`unsafe`注記を付与。
  `0ef177d3`（2026-10-07、Claude）がmodule内の`@inline(__always)` 27個を「計測なしの初期チューニング」として一括で外し、
  getterのものも外れた。`f01c66a6`（2026-10-09、ユーザー）がgetterにだけ`@inline(__always)`を戻した。コメントでの理由づけはない。

**2. smell仮説**
- H-a（最適化判断の分散）: hot pathのinline化は3宣言の属性の組み合わせで決まり、getterの属性は3日で2回変わった。
  性能の調整が1宣言に閉じない、という意味での「散弾銃的変更」候補。
- H-b（unsafe境界の書き方の不統一）: 同じstorageに、pointerを持ち出す書き方（`__storage_ptr`）とclosure内で完結する書き方
  （`deinit`・`copy()`・`prepare`）が並ぶ。持ち出したpointerの有効期間は「`self`が生きている間」という暗黙の前提に依存する。

**3. 必要な層分離だとする代替説明・反証**
- 3段はそれぞれ別の境界を受け持つ。公開subscriptは公開契約（範囲検査、読み取り専用の値）、`Buffer.subscript`は内部の
  変更口（`swapAt`の`_modify`）、`__storage_ptr`は`unsafe`を1か所に閉じこめ、`lastAscentIndex`・`reverse`・`swapAt`などの
  アルゴリズム側を`unsafe`なしで書けるようにしている（`.strictMemorySafety()`下で意味がある）。どれを畳んでも、
  境界のどれかが消えるか、`unsafe`がアルゴリズム側へ広がる。
- H-aへの反証: 2026-10-09のLinux artifactでは、計測ループの命令列はgetterの属性の有無で変わらなかった
  （`PERFORMANCE_REGRESSION_BISECTION.md`の事例記録）。属性が効いたのは汎用版の大きさと配置で、経路の多さそのものが
  hot pathを悪くした証拠はない。散弾銃的変更は、構造よりも「属性を付け外しした理由が残っていない」ことのほうに由来する。
- H-bへの反証: `ManagedBuffer`の要素領域はobjectが生きている間は動かない。`__storage_ptr`は`Buffer`のmethod内でだけ使われ、
  `@unsafe`で明示されている。2026-10-08に`Buffer.subscript`をclosure内完結に書き換えても、Releaseの値semanticsの失敗は
  変わらなかった（`CP-20261009-001`前の調査、memory記録）。持ち出しが実害を出した証拠はない。

**4. 影響・確度・次に確かめるなら**
- 構造（3段）は必要な層分離と判断する。確度: 高い。
- H-a: 構造のsmellではなく、記録のsmell（tuning intentが宣言の近くにも記録にも残っていない）。影響は中程度
  （次に誰かが`0ef177d3`と同じ一括整理をすると、また外れる）。確度: 中。次に確かめるなら、module内に残る他の
  `@inlinable`・`@inline(__always)`のうち、`0ef177d3`で外れて戻っていないものが性能に関係するかを、計測ループの機械語で見る。
- H-b: 低い。確度: 中。次に確かめるなら、`__storage_ptr`の持ち出しがmethodの外（返り値やescaping closure）へ漏れる経路が
  将来できないかを、宣言の可視性（`internal`）とfan-inで見張る。

**5. 判断**
- 現状維持でよい（3段の構造は変えない）。
- Codexへ返す価値がある独立task候補は1件だけ: getterの`@inline(__always)`（`f01c66a6`）に、付けた理由と根拠（2026-10-09の
  事例記録）を1行で残すかどうか。source（コメント）か記録のどちらに置くかは性能方針の判断を含むので、ここでは決めない。
- 参考: `0ef177d3`で外した27個は、初出が2025-01-02のユーザーのチューニングだった。外した側（Claude）の判断理由
  「計測なし」は、初出時期で意図を判断するという後の運用とは合わない。
