@usableFromInline
protocol ___UnsafeIndexBase: ___Root
where
  Base: ___TreeBase & ___TreeIndex,
  Tree == UnsafeTree<Base>,
  Index == Tree.Index,
  _NodePtr == Tree._NodePtr
{
  associatedtype Index
  associatedtype _NodePtr
  var __tree_: Tree { get }
}

@usableFromInline
protocol ___UnsafeBase: ___UnsafeIndexBase
where
  Base: ___TreeBase & ___TreeIndex,
  Tree == UnsafeTree<Base>,
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

extension ___UnsafeIndexBase {

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
