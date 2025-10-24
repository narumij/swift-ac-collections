//
//  RedBlackTreeFixture.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/10/25.
//

#if DEBUG
  @testable import RedBlackTreeModule
#endif

#if DEBUG
  protocol RedBlackTreeFixture: ___TreeBase & Sequence {
    associatedtype Index
    var __tree_: ___Tree<Self> { get }
    var startIndex: Index { get }
    func distance(from start: Index, to end: Index) -> Int
    func lowerBound(_ member: Element) -> Index
    func upperBound(_ member: Element) -> Index
  }

  extension RedBlackTreeFixture {

    func __left_(_ p: _NodePtr) -> _NodePtr {
      __tree_.__left_(p)
    }
    func __right_(_ p: _NodePtr) -> _NodePtr {
      __tree_.__right_(p)
    }
    func __root() -> _NodePtr {
      __tree_.__root()
    }
    mutating func __root(_ p: _NodePtr) {
      __tree_.__left_(.end, p)
    }
    func
      __tree_min(_ __x: _NodePtr) -> _NodePtr
    {
      __tree_.__tree_min(__x)
    }
    func
      __tree_max(_ __x: _NodePtr) -> _NodePtr
    {
      __tree_.__tree_max(__x)
    }
    mutating func
      __tree_left_rotate(_ __x: _NodePtr)
    {
      __tree_.__tree_left_rotate(__x)
    }
    mutating func
      __tree_right_rotate(_ __x: _NodePtr)
    {
      __tree_.__tree_right_rotate(__x)
    }
    mutating func
      __tree_balance_after_insert(_ __root: _NodePtr, _ __x: _NodePtr)
    {
      __tree_.__tree_balance_after_insert(__root, __x)
    }
  }

  extension RedBlackTreeFixture {
    var elements: [Element] {
      map { $0 }
    }
  }

  extension RedBlackTreeFixture {
    func left(_ p: Element) -> Int {
      distance(from: startIndex, to: lowerBound(p))
    }
    func right(_ p: Element) -> Int {
      distance(from: startIndex, to: upperBound(p))
    }
  }
#endif

#if DEBUG
  extension RedBlackTreeSet: RedBlackTreeFixture {}
  extension RedBlackTreeMultiSet: RedBlackTreeFixture {}
#endif
