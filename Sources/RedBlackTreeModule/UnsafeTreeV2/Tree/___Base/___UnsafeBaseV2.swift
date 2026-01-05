// コレクション実装の基点
public protocol ___Root {
  associatedtype Base
  associatedtype Tree
}

@usableFromInline
protocol ___UnsafeIndexBaseV2: ___Root
where
  Base: ___TreeBase & ___TreeIndex,
  Tree == UnsafeTreeV2<Base>,
  Index == Tree.Index,
  _NodePtr == Tree._NodePtr
{
  associatedtype Index
  associatedtype _NodePtr
  var __tree_: Tree { get }
}

extension ___UnsafeIndexBaseV2 {

  @inlinable
  @inline(__always)
  internal func ___index(_ p: _NodePtr) -> Index {
    __tree_.makeIndex(rawValue: p)
  }

  @inlinable
  @inline(__always)
  internal func ___index_or_nil(_ p: _NodePtr) -> Index? {
    p == __tree_.nullptr ? nil : ___index(p)
  }

  @inlinable
  @inline(__always)
  internal func ___index_or_nil(_ p: _NodePtr?) -> Index? {
    p.map { ___index($0) }
  }
}

@usableFromInline
protocol ___UnsafeBaseV2: ___UnsafeIndexBaseV2
where
  Base: ___TreeBase & ___TreeIndex,
  Tree == UnsafeTreeV2<Base>,
  Index == Tree.Index,
  Indices == Tree.Indices,
  _Key == Tree._Key,
  _Value == Tree._Value
{
  associatedtype Index
  associatedtype Indices
  associatedtype _Key
  associatedtype _Value
  associatedtype Element
  var __tree_: Tree { get }
  var _start: _NodePtr { get }
  var _end: _NodePtr { get }
}


public typealias RedBlackTreeIndex = UnsafeIndexV2
public typealias RedBlackTreeIndices = UnsafeIndicesV2
public typealias RedBlackTreeIterator = RedBlackTreeIteratorV2
public typealias RedBlackTreeSlice = RedBlackTreeSliceV2

@usableFromInline
protocol ___RedBlackTreeKeyOnlyBase:
  ___UnsafeStorageProtocolV2 & ___UnsafeCopyOnWriteV2 & ___UnsafeCommonV2 & ___UnsafeIndexV2 & ___UnsafeBaseSequenceV2
    & ___UnsafeKeyOnlySequenceV2
{}
@usableFromInline
protocol ___RedBlackTreeKeyValuesBase:
  ___UnsafeStorageProtocolV2 & ___UnsafeCopyOnWriteV2 & ___UnsafeCommonV2 & ___UnsafeIndexV2 & ___UnsafeBaseSequenceV2
    & ___UnsafeKeyValueSequenceV2
{}
