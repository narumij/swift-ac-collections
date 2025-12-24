//
//  ___Common.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/12/24.
//

@usableFromInline
protocol ___Common: ___RedBlackTree___
where
  Base: ___TreeBase & ___TreeIndex,
  Tree == ___Tree<Base>,
Index == Tree.Index,
  _Value == Tree._Value
{
  associatedtype Index
  associatedtype _Value
  var __tree_: Tree { get }
  var _start: _NodePtr { get }
  var _end: _NodePtr { get }
}

extension ___Common {

  @inlinable
  @inline(__always)
  var ___is_empty: Bool {
    __tree_.___is_empty
  }

  @inlinable
  @inline(__always)
  var ___first: _Value? {
    ___is_empty ? nil : __tree_[_start]
  }

  @inlinable
  @inline(__always)
  var ___last: _Value? {
    ___is_empty ? nil : __tree_[__tree_.__tree_prev_iter(_end)]
  }
}

extension ___Common {

  @inlinable
  @inline(__always)
  func ___prev(_ i: _NodePtr) -> _NodePtr {
    __tree_.__tree_prev_iter(i)
  }

  @inlinable
  @inline(__always)
  func ___next(_ i: _NodePtr) -> _NodePtr {
    __tree_.__tree_next_iter(i)
  }

  @inlinable
  @inline(__always)
  func ___advanced(_ i: _NodePtr, by distance: Int) -> _NodePtr {
    __tree_.___tree_adv_iter(i, by: distance)
  }
  
  @inlinable
  @inline(__always)
  func _distance(from start: Index, to end: Index) -> Int {
    __tree_.___distance(from: start.rawValue, to: end.rawValue)
  }
}

extension ___Common {

  @inlinable
  @inline(__always)
  func ___is_valid(_ index: _NodePtr) -> Bool {
    !__tree_.___is_subscript_null(index)
  }

  @inlinable
  @inline(__always)
  func ___is_valid_range(_ p: _NodePtr, _ l: _NodePtr) -> Bool {
    !__tree_.___is_range_null(p, l)
  }
}

