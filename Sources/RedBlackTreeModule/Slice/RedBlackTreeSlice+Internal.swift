//
//  RedBlackTreeSlice+Internal.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/12/24.
//

@usableFromInline
protocol RedBlackTreeSliceInternal: ___RedBlackTree___
where
  Base: ___TreeBase & ___TreeIndex,
  Tree == ___Tree<Base>
{
  associatedtype Index where Index == Tree.Index
  associatedtype _Value where _Value == Tree._Value
  var __tree_: Tree { get }
  var _start: _NodePtr { get }
  var _end: _NodePtr { get }
}

extension RedBlackTreeSliceInternal {

  @inlinable
  @inline(__always)
  func ___index(_ rawValue: _NodePtr) -> Index {
    .init(tree: __tree_, rawValue: rawValue)
  }

  @inlinable
  @inline(__always)
  func ___contains(_ i: _NodePtr) -> Bool {
    !__tree_.___is_subscript_null(i) && __tree_.___ptr_closed_range_contains(_start, _end, i)
  }

  @inlinable
  @inline(__always)
  func ___contains(_ bounds: Range<Index>) -> Bool {
    !__tree_.___is_offset_null(bounds.lowerBound.rawValue)
      && !__tree_.___is_offset_null(bounds.upperBound.rawValue)
      && __tree_.___ptr_range_contains(_start, _end, bounds.lowerBound.rawValue)
      && __tree_.___ptr_range_contains(_start, _end, bounds.upperBound.rawValue)
  }
}

extension RedBlackTreeSliceInternal {

  @inlinable
  @inline(__always)
  public func ___node_positions() -> ___SafePointers<Base> {
    ___SafePointers(tree: __tree_, start: _start, end: _end)
  }
}
