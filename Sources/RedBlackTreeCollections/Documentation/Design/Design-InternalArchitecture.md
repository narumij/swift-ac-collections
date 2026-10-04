# 内部アーキテクチャ

## この文書の目的

RedBlackTreeCollectionsの公開コレクション、Swift向け木ラッパー、LLVM libc++由来の
赤黒木アルゴリズム、独自メモリ管理の境界を記録する。

コードは性能と移植元との照合を優先して細かいプロトコルへ分割されている。
型名やディレクトリ名だけでは層の責務が分かりにくいため、変更時の依存方向を
この文書で明確にする。

## 全体構造

```text
公開コレクション
RedBlackTreeSet / RedBlackTreeDictionary
RedBlackTreeMultiSet / RedBlackTreeMultiMap
        │
        │ __tree_: UnsafeTreeV2<Base>
        ▼
Swift向け木ラッパー
UnsafeTreeV2<Base>
        │
        ├── Baseによる型・比較・重複可否の注入
        ├── CoW、容量、Index解決、Range正規化
        └── 移植アルゴリズムへのprotocol適合
                │
                ▼
__tree 移植層
find / bounds / insert / erase / remove / balancing
                │
                ▼
ノード・ストレージ層
UnsafeNode / UnsafeTreeV2BufferHeader
FreshPool / RecyclePool / BucketAllocator
                │
                ▼
Index寿命・安全性層
_NodePtrSealing / _LazyTie / _TiedRawBuffer
```

依存方向は上から下を基本とする。移植アルゴリズムは公開コレクションを知らず、
必要な型と操作をprotocol経由で受け取る。

## 公開コレクション層

現在の主要な公開値型は次の四つである。

- `RedBlackTreeSet<Element>`
- `RedBlackTreeDictionary<Key, Value>`
- `RedBlackTreeMultiSet<Element>`
- `RedBlackTreeMultiMap<Key, Value>`

それぞれが `__tree_: UnsafeTreeV2<Base>` を一つ保持する。
公開APIは検索、挿入、削除、subscript、RangeExpression、Sequenceなどの用途ごとに
ファイルを分けている。

各コレクション内の `Base` は、木へ静的な型情報と振る舞いを注入する。

- `_Key`: 比較に使う型
- `_PayloadValue`: ノードへ格納する型
- `Element`: 公開Sequenceの要素型
- uniqueまたはmultiの重複方針
- scalarまたはkey-valueのpayload変換
- キー比較とノード比較

Set系では `_Key == _PayloadValue` である。
Dictionary系ではpayloadに `RedBlackTreePair<Key, Value>` を使い、
公開要素との間を変換する。

`RedBlackTreePair`はDictionary/MultiMapの内部保持型であり、Swift 6.2で観測されたtupleの
性能低下を避けながら、公開要素の`(key:value:)` tupleとの往復を担う。keyとmapped valueの
順序を保持し、`Equatable`、`Hashable`、`Comparable`は両成分のtuple semanticsに従う。
Codable表現はkey、valueの順のunkeyed containerである。この表現は内部型であっても、
コレクションのencode/decode経路へ影響するため、field追加時に無断でkeyed形式へ変えない。

公開コレクションは木アルゴリズムを重複実装せず、`UnsafeTreeV2` へ委譲する。
変更APIは委譲前にCoWの一意性と容量を確保する。

## `UnsafeTreeV2<Base>` 層

`UnsafeTreeV2` は、公開コレクションと低レベルアルゴリズムを接続する値型である。
保持する実データは `ManagedBufferPointer` 一つである。

主な責務は次のとおり。

- ManagedBufferの所有とCoW
- countとcapacity
- fresh poolとrecycle poolへの接続
- begin、end、rootへのアクセス
- Indexの生成と解決
- 独自RangeExpressionの内部Rangeへの正規化
- payload型とkey型の橋渡し
- unique/multiアルゴリズムの選択
- `__tree` 移植protocolへの適合

`UnsafeTreeV2+__tree.swift` は、この型を移植アルゴリズムが要求するprotocolへ
適合させる主要な接続点である。construct、destroy、value access、比較、find、
insert、eraseなどを低レベル実装へ公開する。

## `__tree` 移植層

`Implements/__tree` はLLVM libc++の赤黒木実装をSwiftへ移植・適応した層である。
命名とアルゴリズム構造は、移植元との目視比較をしやすくすることを優先する。

主な区分は次のとおり。

- `_types`: key、payload、element、pointerなどの型関係
- `base`: 比較方法、multiplicity、payload accessなどのBase側実装
- `interfaces`: アルゴリズムが要求する細粒度protocol
- `unsafe_node`: ノード表現、ポインタ操作、進行、距離、安全化
- `unsafe_tree`: find、bounds、insert、erase、remove、平衡化
- `three_way_compare`: 比較結果と比較器

この層では、C++のpointer、iterator、node referenceに相当する概念がSwiftの
ポインタとprotocolへ写されている。Swiftらしい抽象化へ全面的に置き換えることより、
移植元との対応とホットパス性能を優先する。

移植元との一致は、アルゴリズム更新時の差分監査と退行検出の手段でもある。
移植元と同じ制御構造から生じる到達不能な末尾や重複して見える分岐は、カバレッジ率だけを
理由に書き換えない。原木テストは到達可能な分岐と不変条件を実行可能仕様として固定するが、
移植元との構造的一致そのものはソース比較で確認する。両者を合わせて「100%相当」と判断する
場合は、到達不能である根拠をテスト保守記録へ残す。

## protocolによる型注入

プロトコルは依存の循環を避け、必要な能力だけをアルゴリズムへ渡すために
細かく分割されている。

命名上のおおまかな区分は次のとおり。

- `...Type`: associated typeと型関係を定義する
- `...Interface`: 型を使う操作の要求を定義する
- `...Protocol`: 既定実装を含む、または分類途中の能力を表す
- `..._ptr`: ポインタベース実装であることを表す
- snake_caseの名前: 移植元との対応を優先した別名または概念

`Base` は型レベルの構成、`Tree` はインスタンスレベルの状態という区別を取る。
`___TreeBase` は比較可能なキー、multiplicity、ノードポインタ能力などを合成した
制約である。

比較アルゴリズムは、比較器を必ず`Base`から取得するものとして固定しない。
現行の公開コレクションはstaticな`Base`を主経路として使う一方、`__tree`の細粒度protocolは、
適合インスタンスが`value_comp`や三方比較を直接実装する構成でも動作する。
これにより、fixture、別のストレージFacade、実行時状態を持つ比較器、noncopyableな適合型を、
公開コレクションの`Base`構造へ依存させずに接続できる。

`_ValueCompBridge`はstaticな`Base.value_comp`をインスタンス要件へ橋渡しする一つのadapterであり、
`__tree`アルゴリズム自体の必須構成要素ではない。find、bound、count、hint付き探索、equal rangeは、
static `Base`経路とインスタンス注入経路の双方で同じ探索契約を満たす。インスタンス経路では、
降順などの状態が実際の探索分岐へ反映されなければならない。

プロトコル分割には、依存関係の明確化に加えて、コンパイル負荷とwitness tableの
削減を狙う意図がある。ただし、適合の追加・削除が最適化結果へ影響する場合があるため、
機械的な統合は行わない。

## 比較結果の契約

標準の三方比較器は小・等・大をそれぞれ`-1`、`0`、`1`へ正規化する。
アルゴリズム側は具体的な正負値ではなく、package内部の`ThreeWayCompareResult`が持つ
`__less()`と`__greater()`で符号を読む。0はlessにもgreaterにも含めない。`Int`版と
eager wrapperはこの符号契約を共有し、比較表現を差し替えても探索分岐の意味を変えない。
これらは赤黒木実装と同packageのtest fixtureを接続する内部境界であり、利用者向けAPIではない。

## 構造不変条件と診断

`__tree_invariant`は空木を有効とし、非空木ではrootが非nullの親を持つこと、親の左リンクから
rootへ戻れること、rootが黒であることを検査する。`__tree_sub_invariant`は各部分木について、
親子リンクの往復、左右の非null childが同一でないこと、赤nodeのchildが赤でないこと、
左右の黒高さが一致することを検査する。不正な部分木は0、正常な部分木は黒高さを返す。

これらは正常系だけを通すassertの代替ではなく、壊れたfixtureをfalseまたは0として診断する
能力も契約に含む。DEBUG用の`equiv`、`nullCheck`、`endCheck`も同様に、不一致を必ずtrapする
のではなく診断結果を返せるように保つ。挿入・削除・回転のテストでは操作後のinvariantを確認し、
不変条件検査そのもののテストでは各破損を意図的に独立して作る。

## ノードとpayload

`UnsafeNode` は木構造のメタデータを保持し、payloadはノードに隣接する領域として
独自アロケータが管理する。

概念上の配置は次のとおり。

```text
| UnsafeNode | Payload | UnsafeNode | Payload | ...
^`_NodePtr`  ^ value storage
```

ノードは左、右、親、色、tracking tag、recycle count、payload有無などを保持する。
Set系のpayloadはキーそのものであり、Dictionary系は
`RedBlackTreePair<Key, Value>` である。

## ストレージとアロケータ

`UnsafeTreeV2Buffer` は `ManagedBuffer` の参照型本体であり、
`UnsafeTreeV2BufferHeader` が木とpoolの状態を保持する。

ヘッダの主な状態は次のとおり。

- root、begin、end、nullptr
- 有効要素数
- fresh poolの容量と利用済み数
- recycle poolの先頭
- bucket allocator
- 互換経路の寿命管理用 `_tied` と、Indexの同一性・解放検出用 `_lazyDetach`
- Debug時の検査・計測値

### FreshPool

未使用ノードを供給する。容量が不足するとbucketを追加する。
新規ノードには単調なtracking tagを割り当てる。

### RecyclePool

削除したノード領域を再利用する。削除時にpayloadを破棄し、recycle countを進め、
古いsealed pointerを無効化してからpoolへ戻す。

`ALLOW_CROSS_TREE_INDEX` 有効時のCoWコピーではrecycle countも新しいノードへ
引き継ぎ、コピー先での世代照合に用いる。空の木ではCoWコストを抑えるため、
不要なpool履歴を再構築しない。

### Bucket

ノードとpayloadの連続領域を確保する単位である。通常の容量拡張ではbucketを追加できる。
CoWによるコピー直後はtracking tagから O(1) で解決できるよう、単一bucketを維持する。

## Index、Iterator、Range

- `UnsafeIndexV3`: sealed pointerに `_LazyTie` の同一性・解放検出とtracking tagを加えたIndex
- `UnsafeIterator`: 現行経路では木のスナップショットを保持してCoW共有する走査実装の名前空間。互換経路ではtied bufferを使う
- `_RawRange`: 解決済みの内部半開範囲
- `_RawRangeExpression`: 半開・閉・部分・非有界の内部表現
- `UnsafeIndexV3Range`: 公開側の解決済みIndex範囲
- `UnsafeIndexV3RangeExpression`: Index演算子から作る独自範囲式
- `RedBlackTreeBoundExpression`: 値やstart/endから位置を解決する安全側の式
- `RedBlackTreeBoundRangeExpression`: BoundExpressionの範囲

Indexはノード識別を直接扱う。BoundExpressionはキー検索などを木へ委ね、
利用者がIndexを直接保持しなくても位置を指定できる。

Rangeの計算量と反復方針は `Design-Range.md` に分離して記録する。

## Deprecatedと互換モード

`Implements/Deprecated` には旧Index、旧Iterator、Slice、旧protocolなどが残る。
多くは `COMPATIBLE_ATCODER_2025` で切り替えられる。

新しい設計を検討するとき、Deprecated配下の挙動を現行設計の根拠として扱わない。
ただし、互換モードのビルドを維持する変更では両経路を確認する。

## 性能上の境界

この構造では抽象化の整理だけで性能が改善するとは限らない。
次の変更は特にRelease計測を必要とする。

- protocol適合の追加・削除・統合
- `@inlinable` と `@inline(__always)` の変更
- CoW低速経路のinline指定
- ファイル間の実装移動
- bucket構成とtracking tag解決
- IteratorとRangeの抽象化
- ManagedBuffer境界の変更

ソース上の重複や細分化には、コード生成を安定させるため意図的に残されているものがある。

## 変更時の原則

- 公開API層に木アルゴリズムを複製しない。
- `__tree` 移植層へCoWや公開Indexの寿命管理を持ち込まない。
- `UnsafeTreeV2` を高低レベル間の橋渡しとして維持する。
- raw pointerを公開コレクション層へ露出させない。
- Baseの型関係とmultiplicityを壊さない。
- 比較protocolを変更するときは、static `Base`注入と状態付きインスタンス注入の双方を維持する。
- `_ValueCompBridge`を、`Base`を持たない適合型にまで要求する依存へしない。
- 移植元との対応が必要なコードは、命名を一括でSwift風に変更しない。
- protocol整理ではRelease性能とコンパイル負荷を確認する。
- Deprecated経路と現行経路を混同しない。
- メモリ所有権とIndex寿命の変更は `Design-MemorySafety.md` も更新する。
- Rangeまたは反復の変更は `Design-Range.md` も更新する。

## 関連文書

- [設計Overview](Design-Overview.md)

- [ノードストレージの設計](Design-NodeStorage.md)
- [Copy on Writeの設計](Design-CopyOnWrite.md)
- [メモリ安全性の設計](Design-MemorySafety.md)
- [RangeとIndex反復の設計](Design-Range.md)
