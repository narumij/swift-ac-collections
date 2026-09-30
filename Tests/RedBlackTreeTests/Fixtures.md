<!-- Fixtureの追加削除に応じて、CodexまたはClaudeあるいはちゃっぴーでメンテナンスすること -->

# RedBlackTree Test Fixtures

この文書は `RedBlackTreeTests` で使用している Fixture と Fixture 構築支援コードを整理する。

Fixture は SUT (System Under Test) とは別の概念として扱う。

- **SUT**: 何を検証するか
- **Fixture**: その検証を成立させるために何を用意するか
- **Test Harness / Support**: Fixture の構築・検査・後始末を支援するもの

原則として、テストには目的を満たす最小の Fixture を使用する。

## Current shared fixtures

### `RedBlackTreeFixture`

場所:

`RedBlackTreeTestSupport/RedBlackTreeFixture.swift`

4つの公開コレクション型を共通に扱うための軽量な Fixture protocol。

準拠型:

- `RedBlackTreeSet`
- `RedBlackTreeMultiSet`
- `RedBlackTreeDictionary`
- `RedBlackTreeMultiMap`

提供する主な能力:

- `Sequence`
- `startIndex`
- `distance(from:to:)`
- `lowerBound(_:)`
- `upperBound(_:)`
- 要素列の取得 (`elements`)
- `_TrackingTag` による lower/upper bound 位置の取得 (`left(_:)` / `right(_:)`)

生ポインタや `UnsafeTreeV2` そのものを Fixture API として要求しない。

公開コレクションの観測可能な挙動を共通化して検査するときに適する。

### `RedBlackTreeDebugFixture`

場所:

`RedBlackTreeTestSupport/RedBlackTreeFixture.swift`

DEBUG ビルドで、4つの公開コレクションを現行の `UnsafeTreeV2` 実装へ接続する内部向け Fixture protocol。

準拠型:

- `RedBlackTreeSet`
- `RedBlackTreeMultiSet`
- `RedBlackTreeDictionary`
- `RedBlackTreeMultiMap`

要求:

- `_UnsafeNodePtrType`
- `Base: ___TreeBase`
- `__tree_: UnsafeTreeV2<Base>`

提供する主な能力:

- left / right node access
- root access
- tree minimum / maximum
- left / right rotation
- insert 後 balancing

実ポインタを使う現行実装に依存するため、`RedBlackTreeFixture` より強い Fixture。

## Current instance fixtures

### Public collection instances

`RedBlackTreeSet` などの実インスタンス自体を Fixture として使用するケース。

例:

`RedBlackTreeInternal/Base/RedBlackTreeInternal_SetBaseTests.swift`

```swift
typealias Fixture = RedBlackTreeSet<Int>
typealias SUT = Fixture.Base
```

この場合、

- SUT = `RedBlackTreeSet<Int>.Base`
- Fixture = `RedBlackTreeSet<Int>`

であり、両者を区別する。

同様に `RedBlackTreeMultiSet<Int>` を Fixture として使用するテストがある。

### `UnsafeTreeV2<Base>`

場所:

`UnsafeTreeV2/Base/UnsafeTreeBasicTests.swift`

テスト専用の `Base` trait を用意し、実際の `UnsafeTreeV2<Base>` を生成する。

`Base` は次の protocol 群へ準拠する。

- `ScalarValueTrait`
- `UniqueMultiplicity`
- `IntThreeWayComparator`
- `_ScalarBasePayloadValue_KeyProtocol`
- `_UnsafeNodePtrType`

対象となる能力:

- storage create
- node construct / destroy
- recycle
- copy
- pool iteration
- capacity / count
- root / begin node

実際の `UnsafeTreeV2` と実ポインタを利用するため、低レイヤの integration fixture に近い。

### `UnsafeTreeV2BufferHeader`

場所:

`UnsafeTreeV2/Instance/BufferHeaderTests.swift`

```swift
typealias Fixture = UnsafeTreeV2BufferHeader
```

production type を直接 Fixture として使用する。

主な対象:

- fresh pool
- recycle pool
- end / begin pointer
- grow
- construct node
- pool selection

## Synthetic fixtures

実コレクション型を生成せず、テスト対象 protocol に必要な最小構成だけを実装する Fixture。

### `FreshPoolFixture<_PayloadValue>`

場所:

`UnsafeTreeV2/Synthetic/UnsafeNodeFreshPoolTests.swift`

準拠:

- `_FreshPool`

保持する主な状態:

- fresh bucket
- allocator
- capacity
- used count
- node count

Fresh Pool のロジックを実際の木から切り離して検査するための Fixture。

### `RecyclePoolTests.Fixture`

場所:

`UnsafeTreeV2/Synthetic/RecyclePoolTests.swift`

準拠:

- `_UnsafeNodePtrType`
- `_RecyclePool`
- `_RecyclePoolDebug`

Recycle Pool を木全体から切り離して検査する Fixture。

テスト側で `UnsafeMutablePointer<FixtureNode>` を確保して実ポインタを与える。

### `UnsafeNodeTests.Fixture`

場所:

`UnsafeTreeV2/Synthetic/UnsafeNodeTests.swift`

準拠:

- `InsertNodeAtProtocol_ptr`

必要最小限の

- end node
- begin node
- root
- size

を持つ。

外部で確保された `UnsafeNode` 配列を利用して、node insertion や traversal を検証する。

### `_BaseNode_KeyProtocol_Fixture`

場所:

`RedBlackTreeInternal/Synthetic/RedBlackTreeInternal_98_CoverageTests.swift`

`_BaseNode_KeyProtocol` の最小実装。

protocol default implementation の coverage 用。

### `_PairBasePayloadValue_MappedValueProtocol_Fixture`

場所:

`RedBlackTreeInternal/Synthetic/RedBlackTreeInternal_98_CoverageTests.swift`

`_PairBasePayloadValue_MappedValueProtocol` の最小実装。

mapped value の default implementation の coverage 用。

### `KeyValueComparerTests`

場所:

`RedBlackTreeInternal/Synthetic/RedBlackTreeInternal_KeyValueComparerTests.swift`

TestCase 自身が

- `KeyValueTrait`
- `UniqueMultiplicity`
- `_UnsafeNodePtrType`

へ準拠する self-contained synthetic fixture になっている。

独自 `_Key` を使い、`value_comp` の trait semantics を検証する。

## Tree-shape fixtures

型ではなく、決められた木構造を生成する Fixture。

### `fixtureEmpty(_:)`

場所:

`UnsafeTreeV2/Instance/UnsafeTreeV2BootstrapTests.swift`

空の木を構築する。

### `fixture0_10_20(_:)`

3ノードの既知形状を構築する。

値:

```text
    10
   /  \
  0   20
```

### `fixture0_1_2_3_4_5_6(_:)`

7ノードの既知形状を構築する。

balancing、min/max、rotation 等の内部アルゴリズム検証に利用する。

### `___applyFixture(nodes:elements:)`

場所:

`DebugAdditionals/UnsafeTreeV2+Debug/RedBlackTreeSet+UnsafeTreeDebug.swift`

`___Node` 配列と要素列から、現行 `UnsafeTreeV2` の実ポインタ木へ任意の形状を注入する。

旧 Array-based Fixture の `_TrackingTag` ベース表現を、現行実装の node pointer へ写像する橋渡しでもある。

## Legacy Array-based fixtures

場所:

`Legacy/ArrayBasedFixture/`

現行の `UnsafeMutablePointer` ベース実装以前の、`_TrackingTag` と Array を使う Fixture。

Legacy は unused を意味しない。現在も `Legacy/ArrayBasedTests` から利用されている。

### `TreeFixtureBase<Element>`

主な実装:

- `TreeAlgorithmBaseProtocol_std`
- `TreeNodeAccessInterface`
- `RootInterface`
- `EndNodeProtocol`
- `___RedBlackTreeNodePoolProtocol`

データ表現:

- `__nodes: [___Node]`
- `__values: [Element]`
- `_NodePtr = _TrackingTag`

実ポインタを使用しない。

Tree Algorithm の基本的な検証に利用できる。

### `TreeFixture<Element>`

`TreeFixtureBase` を拡張し、以下を含むアルゴリズム能力を追加する。

- find
- find equal
- insert
- remove / erase
- compare
- bounds
- node bitmap
- three-way compare

Array-based な完全な tree algorithm fixture。

### `TreeFixture0_10_20`

固定3ノード木。

### `TreeFixture0_1_2_3_4_5_6`

固定7ノード木。

既知形状から algorithm の期待結果を検査するときに使用する。

## Test harness / support

以下は Fixture そのものとは区別する。

### `RedBlackTreeTestCase`

共通 XCTest harness。

主な責務:

- allocation / deallocation counter の初期化・検査
- node / payload lifetime の検査
- singleton buffer の健全性確認
- null node の破損検査
- tuple / key-value helper

### `PointerRedBlackTreeTestCase`

`RedBlackTreeTestCase` + `_UnsafeNodePtrType`。

pointer-based test の共通 harness。

### `DebugAdditionals`

Fixtureそのものではなく、現行 production type にテスト・デバッグ用能力を追加する support layer。

主な例:

- `UnsafeTreeV2` testing helpers
- node dump
- graphviz
- pointer compare / distance
- `RedBlackTreeSet.___applyFixture`

`RedBlackTreeTestSupport` と一部役割が近いため、今後境界を再整理する余地がある。

## Fixture selection guideline

テストを書くときは、原則として次の順で最小の Fixture を選ぶ。

```text
実コレクションの挙動そのものが必要か？
 ├─ Yes
 │   └─ RedBlackTreeSet / MultiSet / Dictionary / MultiMap
 │
 └─ No
     │
     ├─ protocol / algorithm 単体で表現できるか？
     │   └─ Synthetic Fixture
     │
     ├─ Array + _TrackingTag で表現できるか？
     │   └─ Legacy Array-based Fixture
     │
     └─ 実メモリ・実ポインタ・UnsafeTreeV2 が必要か？
         └─ Current pointer-backed / instance Fixture
```

特に、実ポインタを必要としない SUT のテストで `UnsafeTreeV2` や公開コレクションを Fixture として使用する必要があるかは再検討する。

## Notes

`RedBlackTreeSet_13_CodableTests.swift` にあった未使用の `CodableFixture` は、どこからも継承・参照されていなかったため2026-09-30に削除した。
