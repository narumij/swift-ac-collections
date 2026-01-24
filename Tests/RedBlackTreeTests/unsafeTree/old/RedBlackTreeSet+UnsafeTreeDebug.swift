#if DEBUG
  @testable import RedBlackTreeModule

  extension RedBlackTreeSet {

    @inlinable
    var __nodes: [___Node] {
      get {
        (0..<__tree_.initializedCount).map {
          .init(
            __is_black_: __tree_.__is_black_($0),
            __left_: __tree_.__left_($0),
            __right_: __tree_.__right_($0),
            __parent_: __tree_.__parent_($0))
        }
      }
      set {
        __tree_._buffer.header.___flushRecyclePool()
        __tree_.initializedCount = newValue.count
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
        (0..<__tree_.initializedCount).map {
          __tree_.__value_($0)
        }
      }
      set {
        __tree_.initializedCount = newValue.count
        newValue.enumerated().forEach {
          i, v in
          __tree_.___element(i, v)
        }
      }
    }
    @inlinable
    var __begin_node_: _NodePtr {
      get { __tree_.__begin_node_ }
      set { __tree_.__begin_node_ = newValue }
    }
    @inlinable
    var ___header: Tree.Header {
      get { __tree_._buffer.header }
      set { __tree_._buffer.header = newValue }
    }
    @inlinable
    var _count: Int {
      var it = __tree_.__begin_node_
      if it == __tree_.end {
        return 0
      }
      var c = 0
      repeat {
        c += 1
        it = __tree_.__tree_next_iter(it)
      } while it != __tree_.end
      return c
    }
    @inlinable var __left_: _NodePtr {
      get { _end.pointee.__left_ }
      set { _end.pointee.__left_ = newValue }
    }
    @inlinable func __left_(_ p: _NodePtr) -> _NodePtr {
      __tree_.__left_(p)
    }
    @inlinable func __right_(_ p: _NodePtr) -> _NodePtr {
      __tree_.__right_(p)
    }
    @inlinable
    var __root: _NodePtr {
      __tree_.end.pointee.__left_
    }
    @inlinable
    mutating func __root(_ p: _NodePtr) {
      __tree_.end.pointee.__left_ = p
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
      __tree_._ptr__tree_balance_after_insert(__root, __x)
    }
    @inlinable
    func ___NodePtr(_ p: Int) -> _NodePtr {
      __tree_.___NodePtr(p)
    }
    @inlinable
    var nullptr: _NodePtr { __tree_.nullptr }
    @inlinable
    var end: _NodePtr { __tree_.end }
  }
#endif
