# RedBlackTree 残タスク

最終更新: 2026-10-08 / Codex

## 目的

RedBlackTreeCollectionsを「完成」と判断するまでに残っている作業を管理する。
テスト件数を増やすこと自体ではなく、公開設計を確定し、その契約を実装・テスト・文書で
同じ内容にすることを完了条件とする。

## 現在の判定

赤黒木アルゴリズムと4つの公開コンテナの基本的な正しさについては、完成判断に使える
証拠が揃っている。一方、公開`Index`はsuccess-only表現を採用済み(PR #158)だが、Comparable採否等の契約が確定していないため、
RedBlackTreeCollections全体はまだ完成とはしない。

### Mapped Values Range Viewの範囲契約（変更なしで終了）

`RedBlackTreeMappedValuesView`の`subscript(position:)`と`swapAt(_:_:)`はO(1)とする。
標準`Collection`のIndex操作と同様、IndexがView内の要素を指すことは呼び出し側の事前条件であり、
操作ごとの範囲所属検査は行わない。必要な利用者は`isElement(at:)`を明示的に使用する。

この契約は`211ca2fc`、`API-Matrix-View.md`、および
`test_subrangeValuesSingleIndexOperations_doNotCompareKeys`で確定済みだった。2026-10-07〜08に提案した
範囲検査追加は、この既存契約を見落とした誤ったtask化だったため、`RBT-017`〜`RBT-025`をすべて
`EXCLUDED`として閉じた。試行した実装とDeath Testは破棄済みで、製品コードの変更はない。

ただし、部分Viewの外でもbase treeでは有効なIndexを渡すと、停止せずView外の要素を読み書きし得る。
性能重視の契約として成立する一方、利用者が実行時停止を期待する可能性があるため、利用者向け文書作業
フェーズで`RBT-026`を再開する。そのtaskでは「O(1)と呼び出し側事前条件の現行契約を維持するか」だけを
判断する。維持する場合の具体的な警告文と使用例、変更する場合の実装・test・性能検証は、結論後の
ノー判断taskへ分ける。

`index(inserting:)`と`erase(exactly:)`は現行名で確定し、名前再検討のTODOを終了する。実装済みの
Mapped Values Viewに関する古いTODOも削除する。

### 確認済みの根拠

- Set / MultiSet / Dictionary / MultiMapの参照モデル付きfuzz testと、各操作後の木の不変条件検査
- 4コンテナとRange Viewに対するIndex世代、CoW後のIndex寿命、範囲操作のテスト
- C++標準コンテナとの4組・35テストの挙動比較
  - macOS / LLVM libc++: Debug・Release成功
  - Linux / GNU libstdc++: Debug成功
- raw treeの専用テストターゲット、通常到達可能行のcoverage確認
- Debug寿命検査、境界Death Test、LinuxでのDeath Test実行実績

C++比較の詳細は`Sources/RedBlackTreeCollections/Documentation/Cpp-Matrix.md`を正本とする。

## 外部契約と二種類の内部実装を分ける

Indexの検討では、利用者に見える契約と、その契約を実現・調査する内部機構を
同じ選択肢として扱わない。さらに内部機構を、外部へ波及し得るものと
実装内へ閉じるものに分ける。

### 外部契約

- `RedBlackTreeIndex`を`Comparable`へ適合させるか
- `==`と、採用する場合の`<`が何を意味するか
- 比較、移動、dereferenceの計算量
- staleなIndexを各公開APIがoptional、precondition failure等のどれで扱うか
- 利用者が「失敗状態を格納したIndex」を値として受け取る必要があるか

### 外部へ影響し得る内部実装

公開APIとして直接説明しなくても、利用者のコード、互換性、または他ライブラリへ
影響し得るため、外部契約を決めた後に慎重に選ぶ。

- public typealiasが露出する具体型。現状では`_LazyTiedPtr`がそのまま見える(PR #158以前は`Result`)
- `RedBlackTreeIndex`を固有nominal型にするか
- `Comparable`等の適合と、特に標準型へのretroactive conformance
- `@frozen`型の保存プロパティ、サイズ、レイアウト
- `@inlinable`から参照され、利用側へ埋め込まれ得る処理
- Indexコピー・比較・dereferenceのRelease性能
- エラー状態をIndex値に含めることで生じるoverload resolutionやgeneric制約への影響

この層は便宜上「内部」と呼べても、自由に差し替えられる実装詳細とは扱わない。

### 外部へ影響させない内部実装

- 外部型のレイアウトから隠したノードポインタ、世代、tie、tracking tagの保持方法
- 検証・移動処理が`SealError`を`Result`で運ぶ方法
- 外部型から隠された内部tokenとresolved pointer
- Debug専用の失敗理由、assertion、調査用表示
- 公開契約へ変換する前の内部helperと制御フロー

`SealError`を伴う`Result`が内部調査に有用であることと、公開Indexそのものを
`Result`にすることは別問題である。内部の診断能力は、外部契約へ失敗状態を
露出せずに維持できる。

## 依存関係と実行順

重要度の一覧と着手順を混同しない。赤黒木完成までの主経路は次のとおり。

```text
A. 外部: RedBlackTreeCollectionsの公開面を監査
    ↓
B. 外部: 公開・境界内部・Index表現拘束・TestCode・内部へ分類
    ↓
C. 外部: 既存の安全性・計算量契約を固定
    ↓
D. 外部: IndexのComparableが本当に必要かを判断
    ↓
E. 外部: 公開APIに失敗Indexが必要か判断
    ↓
F. Indexの外部契約を固定
    ↓
G. 境界内部: 外部へ波及する表現候補を導く
   ├─ 現行Result typealias
   ├─ 成功tokenだけのIndex
   └─ 失敗状態を隠蔽する固有nominal Index型
    ↓
H. 境界内部: 必要な候補だけ試作・Release計測
    ↓
I. 境界内部の表現を最終決定
    ↓
J. 閉じた内部: resolver・SealError・診断経路を実装
    ↓
K. 境界内部: Index表現とRange/Viewを実装・追従
    ↓
L. 回帰検証・文書同期・完成判定
```

境界内部の表現は、外部契約より先に固定しない。Comparable不要なら
retroactive conformance問題は消えるが、調査用の失敗状態を公開Indexへ残す妥当性は
別途判断する。Comparableが必要なら、標準`Result`へのretroactive conformanceを
避けられる表現だけをG以降の候補にする。

公開面監査では、外部所有型extensionに加えて、内部実装由来に見えるpublic宣言も扱う。
具体的には`SealError`、`Unsafe*`型、`_` / `__`接頭辞の型・typealias・member、
public typealiasが露出する具体型、public protocol適合を対象にする。

Bでは「Index表現拘束」を独立分類にする。現行Indexのalias chainを成立させる
`_LazyTieWrap`、`_NodePtrSealing`、`SealError`、中間alias、特殊化`Result`の比較、
Index range operator等は分類だけ行い、G〜Kで表現を変更するまで狭めない。
これらをBで先に狭めるとcompile不能になるか、Fより前にIndex表現を決めることになる。

TestCode専用と確認できたfixture・実験経路は先にproduction targetから外せる。
ただし`Result: Comparable`はIndexのComparable採否に依存するため、分類だけ行い、
D〜Iの判断が済むまで最終処置を固定しない。

公開範囲の縮小はデッドコード判断より先に行う。未使用コードは外部へ見えなければ
後から削除できるが、意図しないpublic APIは利用者が現れた時点から変更コストを持つ。

A・Bの監査と、Cの既存契約確認、DのComparable要否、Eの失敗Index要否は並行して
調査できる。DとEは互いに独立した外部契約判断であり、両方の結論をFへ入力する。

一方、外部へ影響させないresolverの`Result`や`SealError`診断は、外部契約を変えずに
維持・改善できる。ただし境界内部の型を先に仮定して大量に作り込まず、Iの決定後に
Jで接続する。

未結線コードやテスト支持層の整理は主経路と並行できる。ただしIndex、Range、Viewに
触れる整理はJ・Kと競合するため、Iの設計確定まで開始しない。追加の参考比較や大規模ベンチは
主経路の依存先ではなく、完成後にも実施できる追加検証である。

## 主経路: Indexの表現と契約の確定

これは赤黒木の完成を止める最優先タスクである。

現行の`RedBlackTreeIndex`は`UnsafeIndexV3`、さらに成功値だけを保持する`_LazyTiedPtr`の別名である
(2026-10-05時点。PR #158以前は`Result<_LazyTieWrap<_NodePtrSealing>, SealError>`の別名だった)。ノードのsealed pointer、
世代、ストレージの同一性・解放検出を組み合わせ、CoWで分岐した木ではtracking tagを
使って対応ノードを解決する。

この仕組みは既存テストを通過しているが、現在の表現を公開契約として確定するかは
別の判断である。少なくとも次を明文化して比較する。

### 外部契約の主論点: `Comparable`にするか

`Index`を`Comparable`へ適合させるかを決める。適合させる場合は、少なくとも次を
公開契約として説明できなければならない。

- `<`がコンテナ内の論理位置順を表すこと
- MultiSet / MultiMapの同値キーに属する別nodeも順序付けられること
- 異なる木に由来するIndex同士をどう扱うか
- `Equatable`との整合性
- 比較の計算量。特に同値キー間の位置比較はO(log N)になり得る
- 標準`Range`等から、反復ごとの比較によるO(N log N)経路が意図せず生じないこと

適合させない場合は、現在Comparableを期待しているコードまたは外部コンテナ設計との
関係を確認し、独自`IndexRange` / `IndexRangeExpression`で必要な操作を満たせるかを
確定する。

現状の`Comparable`実装はDebug構成に限定されている。これは調査用の状態であり、
公開仕様が確定した根拠にはしない。

PR #158以前は`Index`が標準ライブラリの`Result`のtypealiasだったため、Indexだけを
`Comparable`にできなかった。`Result`へretroactiveな`Comparable`適合を追加すると、
RedBlackTreeのIndexに閉じず、条件を満たすすべての`Result`へ適合が見える。
これは1ライブラリの都合で標準型の意味を拡張し、他ライブラリまたは将来の
標準ライブラリによる同じ適合と衝突し得るため、正式な解決策にはしない。

### 外部境界の主要判断: 失敗Indexを公開するか

PR #158以前はpublic typealiasにより、`Index`そのものが`Result<成功値, SealError>`だった
(現在は成功値だけを保持する`_LazyTiedPtr`の別名)。
まず内部表現を考えず、利用者が失敗状態を格納したIndexを受け取る必要があるかを判断する。
この形を採った当初の主な理由は、失敗状態と原因をそのまま保持でき、実装の調査が
容易になると考えたためである。公開Indexが失敗値を保持する必要がある、という
API契約から導かれた設計ではない。したがって、調査上の利便性だけを恒久的な
公開表現の根拠にはしない。

1. 失敗状態をIndex本体に保持する
   - 移動や検証の失敗状態をIndex値として運べる
   - 失敗Indexが公開Indexの通常表現へ混在する
   - `Comparable` / `Hashable`の意味を`SealError`まで含めて定義する必要が生じる
2. 失敗状態をIndex本体から分離する
   - Indexは有効位置またはstaleになり得る位置の識別子へ絞られる
   - 移動・検証の失敗はAPI境界でoptional、`Result`、precondition等として返す
   - 現在Resultを直接伝播している内部経路の変更量とコード生成を確認する必要がある

### 外部へ影響し得る内部表現の選択

`RedBlackTreeIndex`を固有のnominal typeにするかは、外部契約を決めた後の表現上の判断である。
失敗状態を保持する場合にも分離する場合にも固有型を利用できる。

- `RedBlackTreeIndex`を固有型にする
   - 内部に成功値または失敗状態を保持しても、適合をIndex型だけへ限定できる
   - `Result`へretroactive conformanceを追加せず`Comparable`を実装できる
   - typealiasから固有型への移行コスト、公開レイアウト、inliningへの影響を確認する

`Result`の採否は、`Comparable`を採用した場合の比較規則を不自然にしないこと、
および不正pointerをdereference前に拒否できることを条件に決める。

有力な分離案は、Index本体には位置を識別するtokenだけを保持し、解決・検証を
`Result<ResolvedPointer, SealError>`として返す構造である。stale、recycled、detached等の
詳しい失敗理由は内部診断として維持できる一方、公開Indexが生成時から`.failure`である
状態を排除できる。移動失敗についても、内部では`Result`を保ち、公開API境界でoptional、
precondition failure等の契約へ変換する。

### 既存契約として維持するもの

今回の設計判断では、検証済みのCoW、世代、detach、Range/Viewの契約を一から
選び直すことを主目的にしない。ComparableまたはResult表現の変更に必要な範囲で、
既存契約を満たせるか確認する。

- stale / recycled / detachedなIndexをraw pointer参照前に拒否する
- CoWで分岐した木の対応要素へ、既存契約の範囲でIndexを解決する
- 親コンテナとRange ViewのIndex契約を一貫させる
- 通常の全走査と範囲走査をO(N)に保つ

### C〜F 調査結果と暫定推奨

2026-10-04 / Codex。通常構成のsource、公開API、Index validity test、Range/View実装を
突き合わせた。これは現行sourceだけから導いた暫定推奨であり、公開契約の決定ではない。
判断材料の正本候補としてswift-collectionsの`Sources/ContainersPreview`を継続的に確認する。
可逆な設計判断と小さな適合性調査は現行Previewに合わせて進め、公開Index表現の最終固定は
Container protocolの要件が十分に安定した時点で行う。

#### Container protocol追跡基準

- 追跡先: `apple/swift-collections/Sources/ContainersPreview`と関連Swift Evolution proposal。
- 現行Previewは`UnstableContainersPreview` trait配下で、source-stableな契約ではない。
- 2026-10-04に確認したupstream `main`とtag 1.7.0では、`Container.Index`は
  `Equatable & Comparable & Hashable`を要求する。PR #623（2026-04-20）では一度
  `Comparable`が削除されたが、その後再導入され、現在のsourceには再度削除を検討するFIXMEがある。
- したがって方向は未確定である。「Comparableなし」は本ライブラリ単独では自然だが、
  Container適合候補としては現行upstreamを満たさない暫定案として扱う。
- `Container`はspan単位の走査APIも要求するため、非連続node storageでspanをどう提供するかは
  Index表現とは別の適合課題として追跡する。Preview適合そのものを現時点の出荷条件にはしない。
- upstream変更を確認するたびに、Index要件、移動API、range expression、span/lifetime要件の
  差分だけをこの判断表へ反映する。実験APIをそのまま製品APIへ露出しない。

#### 既存試作: `try/index/1`

> 2026-10-05時点: 検証を経てPR #158でmerge済み(`a6c8a474`)。以下はmerge前の記録である。

`try/index/1`はユーザーが手作業で設計・実装した、この主要判断に対する先行PoCである。
作業列は2026-09-24 15:48 JSTから始まり、同日22:46の`005a7bb3`
(`non Result type index`)で中心案を実装した後、09-27朝までテスト修正と記録を継続した。
さらに10-04に`develop/misc/48`をmergeして現行開発へ追従させている。短期の使い捨て試作ではなく、
秋の連休初期から進めてきたIndex再設計の主要成果として扱う。
現行のfailure-valued `_LazyTieWrappedPtr`から、成功値だけを保持する
`_LazyTiedPtr`へIndex aliasを切り替える準備実装がある。主な関連commitは
`005a7bb3` (`non Result type index`)で、その後のbranch内修正も含めて参照する。

- `UnsafeIndexV3 = _LazyTiedPtr`とし、公開Index本体から`Result`を外している。
- tree resolverは引き続き`_SealedPtr`（内部`Result`）を返し、cross-tree、unsealed等の
  診断を内部に維持している。
- limited movementだけは内部のfailureをoptional / Boolへ変換する試作になっている。
- `Equatable`はpointer sealとstorage tie、`Hashable`はpointerとsealを用いるO(1)実装を継続している。
- 一方、`try!` / bare `fatalError()`、Debug用の擬似`.nullptr`、sanitizer TODOが残り、
  現在のproductionへそのままmergeできる完成実装ではない。
- branchは現在のHEADから大きく乖離しているため、branch全体をmergeしない。Gの候補検証では
  merge-base以降のIndex関連差分だけを設計資料・試作として読み直し、現行source上へ再構成する。

これはnominal IndexのPoCではなく、公開Indexから`Result`を除去できるかを検証したPoCである。
したがってゼロから代案を作り直さず、設計意図と成立範囲を保持したまま、現行HEADと
Quality Checklistの正しさ、memory / Index寿命、性能の要求に耐えるかをCodexとClaudeが
独立に検証する。Comparable採否とContainersPreviewへの適合判断は、この検証と分離する。

#### C. 維持する安全性・CoW・計算量

| 契約 | 採用 | 根拠・注意 |
| --- | --- | --- |
| stale / recycled / detachedをdereference前に拒否 | 現行実装で維持 | 公開契約は事前条件とし、`-Ounchecked`での検出・安全停止を保証しない。現行のguard / `fatalError`は契約を上回る防御として1.0前の再審査まで維持する |
| CoW分岐後の論理node解決 | 構成に応じ維持 | `ALLOW_CROSS_TREE_INDEX`有効時だけtracking tagで引き直す。無効時は同一storageだけを受理 |
| 親コンテナとRange ViewのIndex共有 | 維持 | 現在はいずれも`RedBlackTreeIndex`を使用し、View側で範囲包含を追加検証する |
| 全走査・範囲走査 | O(N)を維持 | traversalはnode successorを使う。位置比較を反復条件へ持ち込まない |
| Indexの同値判定・hash | O(1)を維持 | `==`はpointer、世代、storage tieによるtoken identity。hashはpointerと世代で、等値より粗いがHashable契約を満たす。node順序の探索は行わない |

#### D. `Comparable`採否

| 観点 | Comparableなし | Comparableあり |
| --- | --- | --- |
| 現行通常APIの成立 | 成立する | 成立するが追加能力に留まる |
| protocol要件 | 通常構成は`Sequence`であり不要 | 将来`Collection`へ適合するなら必要 |
| 範囲API | 独自`RedBlackTreeIndexRange` / Expressionで成立 | 標準`Range<Index>`も候補になるが、反復で比較を使う危険が増える |
| unique keyの位置順 | 比較契約不要 | key比較を利用できる |
| MultiSet / MultiMapの同値key内 | 比較契約不要 | node順序の決定に最悪O(log N)を要し得る |
| 異なる木のIndex | 等値でないことだけ定義 | 全順序を人工的に定義する必要があり、論理位置順という説明が崩れる |
| 実装への影響 | `Result`へのretroactive適合を除去できる | 固有nominal Index型が必須。標準`Result`への適合追加は不可 |

**本ライブラリ単独での暫定推奨:** 通常構成の`RedBlackTreeIndex`は`Comparable`にしない。現在の公開操作に必要なく、
multi containerと異なる木を含む自然な全順序を、安価かつ利用者に有用な契約として定義できないためである。
ただし現行ContainersPreviewは`Comparable`を要求するため、Container適合を採るならこの案は成立しない。
upstreamの要件が安定した後、その要求とIndex設計を一つの機能として再審査する。
Debug限定の`Result: Comparable` retroactive conformanceは正式設計から除去する。

#### E. 失敗状態の公開

| 状態 | 公開Indexへ格納 | 採用する公開境界 |
| --- | --- | --- |
| 正常な要素位置 / `endIndex` | 必要 | nominal Indexのtokenとして保持 |
| mutation後のstale / recycled / detached | 生成時には格納しない | Indexは値として残る。利用時に内部resolverが`SealError`付きで拒否 |
| `find`の不一致 | 不要 | 現行どおり`endIndex` |
| 検証可能な単一位置 | 不要 | `isElement(at:)` / `isEnd(_:)`でBool化 |
| 条件付き削除の不成立 | 不要 | `erase(exactly:)`で`nil` |
| 不正なsubscript / index移動 | 不要 | 公開契約はprecondition failure。現行実装は内部診断の失敗理由を保持し、`_O_UNCHECKED`でも停止するが、この上乗せ挙動は保証しない |

**暫定推奨:** 公開Indexは生成時からfailureである値を持たない。`SealError`と`Result`は、
pointerへ触れる前に検証する内部resolverの診断結果として維持する。公開APIでは既存の
`Bool`、optional、`endIndex`、precondition failureへ変換する。

#### F. Container protocol確定後に判断する契約候補

- `RedBlackTreeIndex`は固有のpublic nominal typeとし、内部表現型のpublic typealiasにしない。
- `Equatable`と`Hashable`は維持し、比較・hashをO(1)とする。`Comparable`採否はupstream待ちとする。
- `==`は現在の木で解決できる「論理位置の一致」ではなく、Index tokenの同一性を表す。
  そのためcross-tree解決できる旧Indexと、分岐後の木から新しく得たIndexは等しいとは限らない。
- 有効な要素位置と`endIndex`を表現できる。failureを正常なIndex値として生成しない。
- mutationによりstaleになり得るsoft referenceとし、利用時には必ず対象treeで解決・検証する。
- stale / recycled / detached / foreign storageの詳細は内部`Result<Resolved, SealError>`に残す。
- stale等の拒否は現行実装では`_O_UNCHECKED`でも省略しない。公開契約上は事前条件違反であり、
  検出と安全停止を保証しない。実装を契約へ寄せるかは1.0前に再審査する。
- `RedBlackTreeIndexRange` / ExpressionとRange Viewは同じIndex契約を使用する。
- `ALLOW_CROSS_TREE_INDEX`によるCoW分岐追跡の有無は、現行どおり構成差として扱う。
- 現行の`index(inserting:)` / `erase(exactly:)`提供範囲はKまで変更しない。Index移行後は
  いずれも4コンテナへ提供する（提供範囲は決定済み）。

Gでは現行ContainersPreviewとの適合性を含む小さく破棄可能な候補比較までは進めてよいが、
productionのIndex表現はまだ置換しない。「失敗状態を持たないnominal Index + 内部resolver」を
第一候補とする。公開レイアウトを固定する`@frozen`は付けず、必要な`@inlinable`境界だけ
package helperへ委譲する。最終採用はContainer protocolの要件が十分に安定した時点で行う。

### Claude review of C〜F Index decision gate

2026-10-04 / Claude Opus 5.5。read-onlyでレビューした。source、test、`Package.swift`、上の節は変更して
いない。build、test、試作も行っていない。upstreamの確認は、repository内にあるcheckoutだけで行った。
`Benchmarks/.build/checkouts/swift-collections`はtag 1.7.0、`a66de878`、2026-09-22で、
`Benchmarks/Package.resolved`が固定しているrevisionと同じである。`.build/checkouts/swift-collections`は
`1.3.0-407-g7b371ce8`、2026-05-11である。network上のupstream mainは参照していない。
`try/index/1`は`git merge-base HEAD try/index/1` = `7ae8237c`(2026-09-27)からのdiffだけを読んだ。
branchはmerge-base以降に23 commit、HEADは540 commitある。

このmerge-baseとcommit数はClaudeレビュー時点の観測値である。その後2026-10-04 20:25 JSTに
`develop/misc/48`を`try/index/1`へmergeしたため、現在のmerge-baseは`b3570172`へ更新されている。
今後の検証では古い23 commitという範囲を再利用せず、09-24〜09-27のPoC作業列と10-04の
同期mergeを区別して追跡する。

#### Blocking corrections

1. **追跡基準の「Comparable要件は削除済み」は、repository内の証拠と矛盾する。**
   - 1.7.0の`Sources/ContainersPreview/Protocols/Container/Container.swift:29`は
     `associatedtype Index: Equatable, Comparable, Hashable`である。Comparableを外す案はFIXMEとして
     議論されているだけ(同`:34-40`)。
   - 1.7.0の`RangeExpression2`は`Bound: Comparable`と`Range<Bound>`を要求する
     (`Protocols/Container/RangeExpression2.swift`)。`DrainableContainer`などの`Range<Index>`引数も
     Comparableを前提にしている。
   - 2026-05のsnapshotは`Index: Equatable`だけだった(同ファイル`:22`)。つまり手元で確認できる推移は
     「削除」ではなく「追加」である。
   - 本repositoryのsourceにも「swift-collections 1.7.0でContainerのIndexにComparable要求がある」と
     書かれている(`Sources/RedBlackTreeCollections/Implements/RawBuffer/_LazyTieWrap.swift:54`、
     `.../Seal/_NodePtrSealing.swift:162`)。
   - 1.7.0より後のmainで削除されたのなら、commitまたはPRを記録すること。そうでなければ基準を
     「最新release 1.7.0はComparableを要求している」に直すこと。D・Fの「Comparableなし」はupstreamの
     現行要件と一致すると書かず、「upstreamの議論の方向を見込んだ暫定案」と位置付けるべきである。
     追跡対象はtagとcommitで固定すること。
2. **Cの「dereference前に拒否」は、`_O_UNCHECKED` traitでは成立しない。**
   - subscriptの検証は`precondition(sealed.accessible.error == nil)`の後に`sealed.pointer!.__value_()`
     を呼んでいる(`Implements/UnsafeTreeV2/UnsafeTreeV2+Subscript.swift:36-38`)。
   - `Package.swift:104`は、Releaseで`_O_UNCHECKED`を指定すると`-Ounchecked`を付ける。すると
     `precondition`と`!`の検査が消え、stale / foreignなIndexで確保外メモリに触れ得る。
   - Eの「SwiftのIndex契約に合わせprecondition failure」をそのまま実装すると、同じ穴が契約になる。
   - Cの表は構成の例外を明記するか、`-Ounchecked`でも消えない停止(`fatalError`など)を契約に選ぶこと。
3. **`ALLOW_CROSS_TREE_INDEX`の解決とO(1)の`==`の関係が、F契約で未定義になっている。**
   - `==`は`rawValue == rawValue && lazyDetach === lazyDetach`である
     (`Implements/RawBuffer/_LazyTieWrap.swift`)。CoWで分岐した後の旧Indexは、新しい木の
     `isElement(at:)` / `isEnd(_:)`では対応nodeへ解決される。しかし新しい木の`startIndex` /
     `endIndex`などとは等しくならない。
   - したがって`==`は論理位置の同一性ではなく、token(storage、pointer、seal)の同一性である。
     この点をFに明記すること。
   - hashは`pointer + seal`だけでstorage identityを含まない(`_NodePtrSealing.swift`、
     `_LazyTieWrap.swift`)。`==`より粗いので整合はしているが、Cの「token、世代、storage identityから
     構成」という記述はhashについては不正確である。
4. **`try/index/1`はF案(nominal型)の実証ではない。**
   - `UnsafeIndexV3 = _LazyTiedPtr`は`_LazyTieWrap<_NodePtrSealing>`へのpublic typealiasで、
     `_LazyTieWrap`、`_NodePtrSealing`、`UnsafeNode`を引き続き公開signatureに出している。
     Debug限定の`_LazyTieWrap: Comparable`も残る。
   - 実証できたのは、公開Indexから`Result`を外せることと、標準型への遡及適合なしにDebugの比較を
     成立させられることまでである。「第一候補の既存PoC」とは呼ばず、「Result除去の部分PoC」と書くこと。

#### Non-blocking safeguards

- **互換modeはComparableを要求する。** 互換modeの4コンテナは`Collection, BidirectionalCollection`へ
  適合し(`RedBlackTreeSet/RedBlackTreeSet+Deprecated.swift:56`)、`UnsafeIndexV2: Comparable`を持つ
  (`Implements/Deprecated/Index/UnsafeIndexV2.swift:94`)。Dの「Comparableなし」は通常構成に限ると、
  表に明記すること。
- **Test as Specificationの変更が必要になる。** `Tests/RedBlackTreeTests/RedBlackTreeSet/RedBlackTreeSet_9_ProtocolConformanceTests.swift:57,66-71`
  は、DebugでIndexがComparableであることを番号付き仕様として記述している。Comparableを外すときは、
  仕様変更として扱うこと。ほかに`RedBlackTreeSet_98_PerformanceTests.swift:199-210`(`DEBUG && false`)も
  Index比較を使っている。
- **source互換の移行項目。**
  - `RedBlackTreeIndex`が`Result`でなくなるので、利用者の`switch` / `if case .success/.failure`、
    `.get()`、`.map`が壊れる。`.failure(SealError)`も構築できなくなる。
  - public alias `UnsafeIndexV3`をどう扱うか決めること。
  - Index型が`Sendable`か決めること。現行は`_LazyTie`(class)を含み、`Sendable`ではない。
  - Debugの`RedBlackTreeBoundExpression.index(_:)` / `.debug(SealError)`の扱いを決めること。
  - `Benchmarks/`は別packageで、`path: ".."`としてHEADに追従している。`__indices`がIndexを返すので、
    同時に更新する必要がある(`Benchmarks/Sources/Benchmarks/RedBlackTreeDictionaryBenchmarks.swift:90`)。
- **`@frozen`の扱いは判断の根拠にならない。** このpackageはlibrary evolutionを使っていない
  (`Package.swift`に`-enable-library-evolution`がない)ので、`@frozen`の有無に関係なく、clientは常に
  レイアウトを見てcompileする。`@inlinable`本体は`@usableFromInline`な`_LazyTie` / `_NodePtrSealing` /
  `Result`をserializeする。source上は隠せるが、「`@inlinable`本体から露出しない」は成立しない。
  - 第5問への答えは「public signatureからは除去できる。`@inlinable`本体からは除去できない
    (`@usableFromInline`として残る)」である。
  - package helperへ委譲する場合、helperも`@inlinable`にしないとgenericの特殊化が失われる。性能の比較は、
    コード配置ノイズを考慮して交互に計測すること。
- **HEADの移動処理の既存問題。**
  - 移動の失敗は、すでにメッセージのない`fatalError()`で止まる(`Implements/UnsafeTreeV2/UnsafeTreeV2+Index.swift:97-118,141,160`)。
  - `form_index`は`adv_iter`を2回呼んでおり、O(distance)の処理を二重に行っている(同`:155-156`)。
    `try/index/1`も同じ形を引き継いでいる。
  - Eで「内部診断には失敗理由を残す」とするなら、停止時に`SealError`をメッセージへ変換すること
    (`Implements/Misc/Message.swift`)。
- **失敗Indexを除去しても、意図した挙動は失われない。**
  - 現行の公開APIは、failure IndexをIndexとして返さない。移動はtrap、`limitedBy`はoptional / Bool、
    `find`は`endIndex`、Viewの端点は`_sealed_start.pointer!`(`RedBlackTreeView/RedBlackTreeRangeView+KeyOnly.swift:50-56`)
    で、いずれも内部で処理している。
  - failure Indexを作れるのは、利用者が`.failure(...)`を直接構築した場合と、Debug fixtureの
    `Result.unsafe(tree:rawTag:)`だけである。
  - 失われるのは、invalid IndexのBool判定のtest手段(`.index(.failure(.null))`。`try/index/1`で
    commentアウトされた)である。代わりのfixtureを用意すること。
- **spanとlifetimeは独立したblockerである(1.7.0の要件)。**
  - `nextSpan(after:) -> Span<Element>`(`@_lifetime(borrow self)`)、`subscript(index:) -> Element { borrow }`、
    `makeBorrowingIterator`、`Failure == Never`、`compiler(>=6.4)`と`SwiftStdlib 6.4`のavailabilityが
    必要になる。packageの最小環境は`.macOS(.v15)`なので、条件付きの適合になる。
  - 各nodeのpayloadは連続しているので、1要素のspanなら提供できる。ただしDictionary / MultiMapの
    `Element = (key:value:)`は、保存型`RedBlackTreePair`(`tuple`だけを持つ`@frozen` struct、
    `Implements/__tree/_types/RedBlackTreePair.swift:29-39`)からの型変換が必要になる。
  - `index(after:)`は最悪O(log N)なので、計算量の逸脱を文書化する必要がある。
  - 出荷条件にしない判断は妥当である。

#### `try/index/1`の再利用評価

- **実証済み:**
  - Index aliasを`Result`から成功値だけの型へ置き換えた状態で、4コンテナと2 Viewの通常APIが成立する。
  - resolverの内部`_SealedPtr`で、cross-tree、unsealed、detachedの診断を維持できる
    (`UnsafeTreeV2.__purified_(_: _LazyTiedPtr)`)。
  - `limitedBy`の変換。
- **古くなった点:**
  - View実装のpathが古い(`Sources/RedBlackTreeCollections/View/`。HEADは`RedBlackTreeView/`)。
  - `RedBlackTreeMappedValuesView`(2026-09-30に追加)が対象外である。
  - 削除済みのpublic `isValid(_:)`を前提にしたtestが残っている。
  - `_LazyTieWrappedPtr`版と`_LazyTiedPtr`版のoverloadが重複して並存している(戻り値型だけが違う)。
- **HEADでの再利用を阻むもの:**
  - `try!`。停止理由のメッセージがない。
  - Debugの擬似`.nullptr`。failure状態を番兵Indexとして再導入している。`_emptyLazyDetach`を共有し、
    `unsafe(tree:rawTag:)`の失敗をこれで表す。
  - sanitizerのTODO。`Tests/RedBlackTreeTests/EtcTests.swift`で、`a`が早く解放されている疑いのある
    assertを`isDetached`で迂回して弱めている。記憶安全性に関わる兆候なので、解明前に再利用しないこと。
  - O(1)とした`==` / hashは計算量としては正しいが、上記blocking 3の意味論は未解決のままである。

#### Confirmed findings

- 第1問: 通常構成の4コンテナと3 Viewは`Sequence`だけに適合し、`Comparable`を必要とする公開APIはない。
  `Range<Index>`、`RangeExpression where Bound == Index`、`Index: Comparable`の制約は通常構成の
  sourceにない。`..<` / `...`は独自のglobal operatorで、`RedBlackTreeIndexRangeExpression`を返す。
  Debugの`Balanced*`も`Index: Equatable`だけである。
- 第2問: Comparableを要求するのは、互換modeと、upstream 1.7.0の`Container`、`RangeExpression2`だけ。
  benchmarkは要求しない(`__indices`はIndexを順に返すだけ)。
- 第3問: 上記のとおり、意図した公開挙動は失われない。cross-tree解決は内部resolverに残る。
- 第4問: 現行の`==` / hashはO(1)である。`endIndex`はstorageごとのend nodeなので、同じstorage内では
  安定し、CoW後は旧`endIndex`と等しくならない(解決はできる)。この差の明記が必要(blocking 3)。
- 第7問: 今行っても安全で有用なのは次の作業。
  - (a) 表現に依存しない現行の公開挙動を固定するtest。移動のtrap、`isElement` / `isEnd`、
    `limitedBy`、CoW後の`==`と解決の関係など。
  - (b) Cの`_O_UNCHECKED`例外を判断すること。
  - (c) upstreamの追跡基準をtagとcommitで固定すること。
  - (d) 停止メッセージの整備。
  - Comparableの除去、nominal型の導入、Debug Comparableの削除は、upstream 1.7.0がComparableを
    要求しているので、まだ着手しない。
- 第8問: spanとlifetimeは、Index表現とは別のblockerだと確認した。「Index要件」の記述だけが不正確である。

#### Verdict

`decision boundary needs correction`

### Codex response to Claude review

2026-10-04。blocking correction 2〜4とnon-blocking safeguardsを採用した。blocking 1は
Claudeの結論も正しいが、確認範囲を明確化する。PR #623（commit `a8f8ade`）で一度
`Comparable`要件が削除された事実はある一方、2026-10-04に取得したupstream `main`の
`Container.swift`は再び`Equatable, Comparable, Hashable`を要求し、tag 1.7.0とも一致する。
よって追跡表を「現在はComparable必須、再削除はFIXME段階」へ訂正した。

追加で次を確定した。

- `_O_UNCHECKED`でもIndex検証を残すのは現行実装の上乗せ防御とする。公開契約は
  Swift標準ライブラリと同じ事前条件モデルとし、実装を寄せるかは1.0前に再審査する。
- `==`はcross-tree resolver上の論理位置一致ではなく、O(1)のtoken identityとする。
- hashはstorage identityを含めなくても整合するが、その事実を文書化する。
- `try/index/1`はResult除去の部分PoCとしてのみ再利用し、nominal型の実証とは扱わない。
- Comparable採否とproduction置換は保留するが、移動失敗の診断、二重`adv_iter`、
  `_O_UNCHECKED`安全性testなど、表現非依存の改善は先行可能とする。

### Index表現に依存しない安全性改善

2026-10-04 / Codex。公開Index表現を変えず、現行resolverの安全停止を強化した。

- subscriptは`precondition`とforce unwrapをやめ、resolver resultをswitchして、
  `_O_UNCHECKED`でも消えない`fatalError(errorMessage(error))`で停止する。
- `prev_iter` / `next_iter` / unlimited advance / limited advanceの想定外失敗にも、
  `SealError`由来の具体的な停止理由を付けた。
- `form_index`の2回の`adv_iter`は削除しなかった。1回目は、環境提供の`nullptr`を保持する
  `ManagedBufferHeader`のcache lineを載せた状態で2回目のAPIを呼ぶための意図的な構造である。
  再計測なしに一呼び出しへ畳み込まない旨をsource commentへ記録した。
- stale Indexのsubscriptと移動についてDeath Testを追加し、Debugと
  Release + `_O_UNCHECKED`の両方で、SIGSEGV/SIGBUS/ASanではなく期待する診断で停止することを確認した。
- Xcode buildと`git diff --check`は成功した。


- [x] A: 外部所有型extensionと、内部実装由来に見えるpublic宣言を列挙する
- [x] `EXTERNAL_TYPE_EXTENSION_AUDIT.md`のRedBlackTreeCollections対象を確定する
- [x] `SealError`、`Unsafe*`、`_` / `__`系public宣言とpublic typealiasを抽出する
- [x] B: 意図した公開API、境界内部、Index表現拘束、TestCode専用、内部用途へ分類する
- [x] B4-a: ThreeWay比較宣言群をpackageへ縮小する
- [x] B4-c: Debug限定SortedSequence実験経路をTestCodeへ分離する
- [ ] B4-b: Memoize群は外部consumer 2件の移行後に公開終了または正式API化を判断する（外部consumer移行まで凍結）
- [ ] source compatibilityを意図する公開API以外を、可能な範囲でpackage/internalへ縮小する（2026-10-05時点で独立縮小batchは無し。残りはIndex依存または凍結clusterのみ）
- [ ] TestCode専用の宣言と実験経路をproduction targetから分離する（B4-cは完了。残りは凍結Balanced群とIndex依存Debug比較群のみ）
- [x] C: 外部へ保証する安全性・CoW・走査計算量の契約を確認する
- [ ] D: ContainersPreviewを追跡し、外部APIでComparableが必要になる利用箇所と非適合時の代替を確定する
- [x] Comparableあり・なしの2案を比較し、必要APIと計算量を表にする
- [x] E: ユーザー実装の`try/index/1`を主PoCとして、公開Indexから失敗状態を除去する設計が現行HEADとQuality Checklistに耐えるかCodex・Claudeが独立検証し、最終判断する（2026-10-05: verdict `adopt after corrections`、PR #158でmerge。正本は`Archived/INDEX_POC_VALIDATION.md`。Comparable採否とは分離）
- [ ] F: Container protocolの安定度を確認し、Comparable採否、失敗時の公開API、計算量を外部契約として固定する
- [x] Kで`index(inserting:)`をMultiSet / Dictionaryへ横展開する（4コンテナ提供と名称維持はCodex・Claudeレビューで決定済み。戻り値は全型で`(inserted: Bool, index: Index)`。Dictionaryは既存値を置換せず既存位置、Multi系は常に新規occurrenceと`true`を返す。`insert(_:)`と`erase(exactly:)`からSee Alsoで発見可能にする。2026-10-05実装・テスト済み）
- [x] Kで`erase(exactly:)`をMultiSet / Dictionaryへ横展開する（4コンテナ提供は決定済み。2026-10-05実装・テスト済み。Setの空でのCoW回避漏れも同時に修正）
- [x] KeyValue Range Viewの範囲外Index契約を決定（単一Indexは標準Collection同様のprecondition、Bound / range操作は入力を検査するsafe動作）
- [ ] G: 固定した外部契約から、typealias、固有Index型等の境界表現候補を導く
- [x] 標準`Result`へのretroactive `Comparable`適合を正式案から除外する（2026-10-06、未使用のDebug限定適合も削除）
- [x] 調査用の`SealError`情報を、Index本体から分離しても維持できることを確認する（内部resolver testで確認）
- [ ] H: 必要な境界表現候補だけ小さく試作し、比較・移動・dereferenceをRelease計測する
- [ ] I: 採用した境界表現と不採用案、その理由をDesign文書へ記録する
- [x] J: 外部から隠すresolver、`SealError`、診断経路をsuccess-only公開Indexへ接続する（PR #158）
- [x] K: success-only Index本体を実装し、4コンテナと両Range Viewへ追従させる（PR #158）
- [ ] L: テスト・DocC・API Matrixを採用案へ同期する

### Index完了ゲート

- [ ] Comparableの採否と理由が明記されている
- [x] ResultをIndex本体に残すか、API境界へ分離するかが決まっている（分離。PR #158でsuccess-only Indexをmergeしたことで決定済みと、2026-10-06にユーザーが確認）
- [x] 標準型へのretroactive conformanceへ依存していない
- [x] stale / recycled / detached / out-of-rangeを、確保外メモリへ触れる前に処理できる
- [x] CoW前後の契約が4コンテナとViewで一貫している
- [ ] 採用する`==`、`<`、`hash(into:)`の意味と計算量が矛盾しない
- [x] 通常の全走査と範囲走査が意図せずO(N log N)にならない
- [ ] Debugだけで成立する適合や検査を公開仕様の根拠にしない
- [x] Index表現を変更した場合もC++比較・fuzz・不変条件検査が成功する

## Kで処理するIndex依存タスク

- [x] Fで決定したKeyValue Range Viewの範囲外Index契約を実装・テストへ反映する
- [x] cross-tree indexingのテストが公開契約と一致しているか再監査する（2026-10-06:
  Codexが4問を独立再確認し、focused test 18件成功。正本は
  `Archived/CROSS_TREE_INDEX_TEST_AUDIT.md`）
- [x] eraseのrange sanitizeをすり抜ける入力に対するテストを追加する（2026-10-05: 4型で逆向き範囲と同値キーの逆向き区間を追加し、すり抜けがないことを確認。空でのBound範囲eraseの無駄なCoWを8か所修正。Index range版の空guardはIndex契約に関わるとして保留したが、2026-10-06にユーザー判断でTest as Spec案件として実施:
  4型の`UnboundedRange` / `IndexRange` / `IndexRangeExpression`版（`where`付き含む）で空のときだけ`ensureUnique()`を省き、
  範囲検査は維持。空でCoWしない仕様と、空でも他木の範囲でtrapするDeath Testを追加）
- [x] MultiMapで確認されたaccessorのcompiler不具合と同種の問題がないか、`unsafeAddress` /
  `unsafeMutableAddress` accessorを使用する他の箇所をReleaseビルドで横断確認する。MultiMap自身は
  通常`get`へ退避済みであり、対象は内部の`_unsafeAddress`関数呼び出しではなくSwift accessor宣言である
  （2026-10-05: Test as Specを主とし、届かない経路だけ内部テストとする方針により、CIの
  `swift test -c release`で担保する。公開accessorのSet / MultiSet `[position]`とDictionary
  `[key, default:]`は`#if DEBUG`外の連番テストで使用され、内部accessorはその下で通る）

これらは現在のIndex表現を前提に先走って横展開しない。Index契約の決定によって
API名、戻り値、検査方法が変わり得る。

## 主経路と並行できる完成前の整理

- 公開面の監査・縮小は主経路A・Bで実施済み。この節のデッドコード判断は再開指示まで凍結する。
- テスト責務の整理は完了した。未結線コード削除はユーザーが個別に再開を決めるまで凍結し、
  Index設計ゲートの停止中に新たな実装作業を起こさない。
- [ ] 未結線コードを段階的に削除する（個々の削除はユーザーが決定し、再開指示まで凍結）
  - `_Reverse4`関連
  - iteratorの未接続API
  - `swap_key` / `swap_mapped_value`
  - `Message.outOfRange` / `keyMismatch`
  - BufferHeaderの`payloadLayout` / `__root_ptr()`
  - RawRangeの`contains(range:pointer:)`
  - `_TrackingTag.retire`
- [x] `RedBlackTreeTestSupport`と`DebugAdditionals`の責務を整理する
  - 自動テストから呼ぶ再利用基盤はTestSupport、人間向けdump/Graphvizと凍結した旧実験は
    DebugAdditionalsとする。
  - `_LazyTieWrap+Debug.swift`と`unsafe_node+debug.swift`は配置例外として許容し、移動作業は
    発生させない。無効化・歴史的コードはユーザーが再開を決めるまで凍結する。
- [x] UnsafeNode / RawBufferのクロスチェックと単層テストの役割を記録する
  - 単層テストの期待値算術、reference経路、RawBuffer経路を共有せず、同じ誤りで両辺が
    一致することを防ぐ。helperとpayload matrixの重複は検証上の独立性として維持する。
  - stride assertionの重複とfixtureのalignment引数差は、必要時だけ扱う凍結中の任意改善とする。
- [x] `Tests/TESTING.md`の古いC++比較件数と次作業の記述を更新する

## 完成を止めない追加検証

- ランダム比較失敗時の自動縮小
- SortedCollectionsとの大規模性能比較
- Strict Memory Safetyの全面適用に向けたstorage再設計
- 並行アクセス時の`lazyDetach`等の一度だけの初期化保証
- Swift更新後のCoWコード生成の再計測

これらは重要だが、現時点では赤黒木の完成条件へ含めない。公開契約または安全性に
新しい問題が見つかった場合のみ主経路またはIndex依存タスクへ昇格する。

MSVC STLとの比較は2026-10-04のユーザー決定により実施しない。保留タスクにも置かない。

## 完成条件

RedBlackTreeCollectionsを完成と判断する条件は次のとおり。

1. 主経路A〜Lが完了し、意図した公開面とIndex契約について実装・テスト・文書が一致している。
2. Index依存APIと安全性境界が、そのIndex契約に基づいて確定している。
3. 公開範囲の縮小を終えた後、未結線コードについて残す理由または削除の判断が記録されている。
4. 4コンテナのfuzz・不変条件検査・C++比較に回帰がない。
5. 未完了の追加検証が、完成を止めない理由とともに明示されている。

## 関連文書

- `Tests/TESTING.md`
- `Tests/Archived/TESTING_REFERENCE.md`
- `Sources/RedBlackTreeCollections/Documentation/Cpp-Matrix.md`
- `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`
- `Sources/RedBlackTreeCollections/Documentation/Design/Design-CopyOnWrite.md`
- `Sources/RedBlackTreeCollections/Documentation/Design/Design-MemorySafety.md`
- `Sources/RedBlackTreeCollections/Documentation/Design/Design-Range.md`
- `Sources/RedBlackTreeCollections/Documentation/API-Matrix.md`

## RBT-015 evidence packages（2026-10-08）

RedBlackTreeの利用者向け文書作業は後段へ凍結したまま、内部の残task文書を現行実装とRegistryへ
合わせるための事実収集だけを行う。Claudeはこの節へ指定された台帳を追記し、既存本文を修正しない。

共通境界:

- 公開契約、Index契約、完成条件、task状態を決めない。
- source、test、利用者向け文書、Registry、既存本文を変更しない。
- Archived記録からtaskを復活させない。
- 古い記述を見つけても削除案や新しい本文を作らず、位置、現在の事実、根拠だけを書く。
- defectまたは新しい判断点を見つけた場合は、根拠を記録してその項目を停止する。
- Codexが3台帳を検収し、既存本文へ反映するもの、履歴として残すもの、別taskへ分けるものを判断する。

### Branch and commit tense ledger

`try/index/1`、PR #158、`develop/misc/48`、merge前／merge後、現行HEADを述べる箇所を全件列挙する。
各行について、文書位置、現在の主張、時制区分（現行／履歴／曖昧）、確認根拠のcommitまたはRegistry行を
表にする。git履歴の意味を推測せず、確認できないものは未確認とする。成果物は
`### Branch and commit tense evidence`節。

### Registry and checklist state ledger

この文書の`[ ]`／`[x]`、状態語（未完了、凍結、完了、保留等）、task IDをTask Registryと照合する。
一致、不一致、履歴説明として妥当、Registryに対応行なし、のいずれかへ分類する。チェックを変更せず、
依存や優先順位を新しく決めない。成果物は`### Registry and checklist state evidence`節。

### Source path and symbol existence ledger

この文書が現在形で参照するsource／test path、型、member、compile flagを列挙し、現行HEADで
存在、移動、改名、削除、構成限定、未確認へ分類する。Archived正本への参照や明示的な履歴記述は対象外。
存在確認だけを行い、APIの要否や削除判断を行わない。成果物は`### Source path and symbol evidence`節。
