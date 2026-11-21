import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

/// 現行の生木(`UnsafeTreeV2`)を4型すべてから直接操作するためのブートストラップ・デバッグ用プロトコル。
/// `RedBlackTreeTestSupport`側のBound/Index相当のヘルパーとは対象が異なる(常に生木側)。
#if DEBUG
  protocol RedBlackTreeDebugFixture: _UnsafeNodePtrType {
    associatedtype Base: ___TreeBase
    var __tree_: UnsafeTreeV2<Base> { get set }
  }

  extension RedBlackTreeDebugFixture {

    func __left_(_ p: _NodePtr) -> _NodePtr {
      p.__left_
    }
    func __right_(_ p: _NodePtr) -> _NodePtr {
      p.__right_
    }
    var __root: _NodePtr {
      get { __tree_.__root }
      //      set { __tree_.__root = newValue }
    }
    mutating func __root(_ p: _NodePtr) {
      __tree_.__end_node.pointee.__left_ = p
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
      __tree_._ptr__tree_balance_after_insert(__root, __x)
    }
  }

  extension RedBlackTreeSet: RedBlackTreeDebugFixture {}
  extension RedBlackTreeMultiSet: RedBlackTreeDebugFixture {}
  extension RedBlackTreeMultiMap: RedBlackTreeDebugFixture {}
  extension RedBlackTreeDictionary: RedBlackTreeDebugFixture {}
#endif
