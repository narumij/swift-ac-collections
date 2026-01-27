//
//  RedBlackTreeSet+Debug.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/03.
//

#if DEBUG && false
  extension RedBlackTreeSet {

    @inlinable
    var __nodes: [___Node] {
      get {
        (0..<__tree_._header.initializedCount).map {
          .init(
            __is_black_: __tree_.__is_black_($0),
            __left_: __tree_.__left_($0),
            __right_: __tree_.__right_($0),
            __parent_: __tree_.__parent_($0))
        }
      }
      set {
        __tree_.___clearDestroy()
        __tree_._header.initializedCount = newValue.count
        newValue.enumerated().forEach {
          i, v in
          __tree_.__is_black_(i, v.__is_black_)
          __tree_.__left_(i, v.__left_)
          __tree_.__right_(i, v.__right_)
          __tree_.__parent_(i, v.__parent_)
        }
      }
    }

    @inlinable
    var ___elements: [Element] {
      get {
        (0..<__tree_._header.initializedCount).map {
          __tree_.__value_($0)
        }
      }
      set {
        __tree_._header.initializedCount = newValue.count
        newValue.enumerated().forEach {
          i, v in
          __tree_.___element(i, v)
        }
      }
    }
    @inlinable
    var ___header: Tree.Header {
      get { __tree_._header }
      set { __tree_._header = newValue }
    }
    @inlinable
    var _count: Int {
      var it = ___header.__begin_node
      if it == .end {
        return 0
      }
      var c = 0
      repeat {
        c += 1
        it = __tree_.__tree_next_iter(it)
      } while it != .end
      return c
    }
    @inlinable var __left_: _NodePtr {
      get { ___header.__left_ }
      set { ___header.__left_ = newValue }
    }
    @inlinable func __left_(_ p: _NodePtr) -> _NodePtr {
      __tree_.__left_(p)
    }
    @inlinable func __right_(_ p: _NodePtr) -> _NodePtr {
      __tree_.__right_(p)
    }
    @inlinable
    func __root() -> _NodePtr {
      __left_
    }
    @inlinable
    mutating func __root(_ p: _NodePtr) {
      __left_ = p
    }
    @inlinable
    func
      __tree_min(_ __x: _NodePtr) -> _NodePtr
    {
      __tree_.__tree_min(__x)
    }
    @inlinable
    func
      __tree_max(_ __x: _NodePtr) -> _NodePtr
    {
      __tree_.__tree_max(__x)
    }
    @inlinable
    mutating func
      __tree_left_rotate(_ __x: _NodePtr)
    {
      __tree_.__tree_left_rotate(__x)
    }
    @inlinable
    mutating func
      __tree_right_rotate(_ __x: _NodePtr)
    {
      __tree_.__tree_right_rotate(__x)
    }
    @inlinable
    mutating func
      __tree_balance_after_insert(_ __root: _NodePtr, _ __x: _NodePtr)
    {
      __tree_.__tree_balance_after_insert(__root, __x)
    }
  }
#endif
