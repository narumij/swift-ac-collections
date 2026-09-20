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

プロトコル分割には、依存関係の明確化に加えて、コンパイル負荷とwitness tableの
削減を狙う意図がある。ただし、適合の追加・削除が最適化結果へ影響する場合があるため、
機械的な統合は行わない。

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
- Index寿命管理用の `_tied` と `_lazyDetach`
- Debug時の検査・計測値

### FreshPool

未使用ノードを供給する。容量が不足するとbucketを追加する。
新規ノードには単調なtracking tagを割り当てる。

### RecyclePool

削除したノード領域を再利用する。削除時にpayloadを破棄し、recycle countを進め、
古いsealed pointerを無効化してからpoolへ戻す。

### Bucket

ノードとpayloadの連続領域を確保する単位である。通常の容量拡張ではbucketを追加できる。
CoWによるコピー直後はtracking tagから O(1) で解決できるよう、単一bucketを維持する。

## Index、Iterator、Range

- `UnsafeIndexV3`: 世代管理されたノードと遅延寿命管理を組み合わせたIndex
- `UnsafeIterator`: key、value、payload、Indexなどの走査実装の名前空間
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
- 移植元との対応が必要なコードは、命名を一括でSwift風に変更しない。
- protocol整理ではRelease性能とコンパイル負荷を確認する。
- Deprecated経路と現行経路を混同しない。
- メモリ所有権とIndex寿命の変更は `Design-MemorySafety.md` も更新する。
- Rangeまたは反復の変更は `Design-Range.md` も更新する。

## 関連文書

- [Copy on Writeの設計](Design-CopyOnWrite.md)
- [メモリ安全性の設計](Design-MemorySafety.md)
- [RangeとIndex反復の設計](Design-Range.md)
