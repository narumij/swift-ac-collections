//
//  TreeTests.swift
//  swift-tree
//
//  Created by narumij on 2024/09/20.
//

import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

#if DEBUG
  extension ___RedBlackTree.___Node {
    static var node: Self {
      .init(__is_black_: false, __left_: .nullptr, __right_: .nullptr, __parent_: .nullptr)
    }
  }
#endif

#if DEBUG
  class TreeFixtureBase<Element>:
    XCTestCase,
    ___tree_root_node, MemberProtocol, RootProtocol, EndNodeProtocol,
    ___RedBlackTreeNodePoolProtocol
  {
    var __left_: _NodePtr = .nullptr
    var __begin_node: _NodePtr = .end

    var __nodes: [___RedBlackTree.___Node] = []
    var __values: [Element] = []

    var ___destroy_node: RedBlackTreeModule._NodePtr = .nullptr
    var ___destroy_count: Int = 0

    func __left_(_ p: _NodePtr) -> _NodePtr { p == .end ? __left_ : __nodes[p].__left_ }
    func __left_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
      if lhs == .end {
        __left_ = rhs
      } else {
        __nodes[lhs].__left_ = rhs
      }
    }
    func __right_(_ p: _NodePtr) -> _NodePtr { __nodes[p].__right_ }
    func __right_(_ lhs: _NodePtr, _ rhs: _NodePtr) { __nodes[lhs].__right_ = rhs }
    func __parent_(_ p: _NodePtr) -> _NodePtr { __nodes[p].__parent_ }
    func __parent_(_ lhs: _NodePtr, _ rhs: _NodePtr) { __nodes[lhs].__parent_ = rhs }
    func __is_black_(_ p: _NodePtr) -> Bool { __nodes[p].__is_black_ }
    func __is_black_(_ lhs: _NodePtr, _ rhs: Bool) { __nodes[lhs].__is_black_ = rhs }
    func __parent_unsafe(_ p: _NodePtr) -> _NodePtr { __nodes[p].__parent_ }

    func ___initialize(_ e: Element) -> _NodePtr {
      let n = __nodes.count
      __nodes.append(.node)
      __values.append(e)
      return n
    }

    func ___element(_ p: _NodePtr) -> Element {
      __values[p]
    }

    func ___element(_ p: _NodePtr, _ e: Element) {
      __values[p] = e
    }

    func __root(_ p: _NodePtr) {
      __left_ = p
    }

    func clear() {
      __left_ = .nullptr
      __begin_node = .end
      __nodes = []
      ___clearDestroy()
    }

    override func setUpWithError() throws {
      // Put setup code here. This method is called before the invocation of each test method in the class.
      clear()
    }

    override func tearDownWithError() throws {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
      clear()
    }
  }

  class TreeFixture<Element: Comparable>:
    TreeFixtureBase<Element>,
    FindEqualProtocol, InsertNodeAtProtocol, InsertUniqueProtocol,
    RemoveProtocol, EraseProtocol, EraseUniqueProtocol
  {
    func __key(_ e: Element) -> Element {
      e
    }

    func __value_(_ p: _NodePtr) -> Element {
      __values[p]
    }

    typealias Element = Element

    var size: Int {
      get { __nodes.count - ___destroy_count }
      set {}
    }

    typealias _Key = Element

    func value_comp(_ l: Element, _ r: Element) -> Bool {
      l < r
    }
  }

  class TreeFixture0_10_20: TreeFixture<Int> {

    override func setUpWithError() throws {
      // Put setup code here. This method is called before the invocation of each test method in the class.
      try super.setUpWithError()
      __nodes = [
        .init(__is_black_: true, __left_: 1, __right_: 2, __parent_: .end),
        .init(__is_black_: false, __left_: nil, __right_: nil, __parent_: 0),
        .init(__is_black_: false, __left_: nil, __right_: nil, __parent_: 0),
      ]
      __values = [
        10,
        0,
        20,
      ]
      __root(0)
      XCTAssertTrue(__tree_invariant(__root()))
    }

    override func tearDownWithError() throws {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
      try super.setUpWithError()
    }
  }

  class TreeFixture0_1_2_3_4_5_6: TreeFixture<Int> {

    override func setUpWithError() throws {
      // Put setup code here. This method is called before the invocation of each test method in the class.
      try super.setUpWithError()

      __nodes = [
        .init(__is_black_: true, __left_: 1, __right_: 4, __parent_: .end),
        .init(__is_black_: false, __left_: 2, __right_: 3, __parent_: 0),
        .init(__is_black_: true, __left_: nil, __right_: nil, __parent_: 1),
        .init(__is_black_: true, __left_: nil, __right_: nil, __parent_: 1),
        .init(__is_black_: false, __left_: 5, __right_: 6, __parent_: 0),
        .init(__is_black_: true, __left_: nil, __right_: nil, __parent_: 4),
        .init(__is_black_: true, __left_: nil, __right_: nil, __parent_: 4),
      ]
      __values = [
        3,
        1,
        0,
        2,
        4,
        5,
        6,
      ]
      __root(0)
      //    size = tree.nodes.count
      __begin_node = 2
      XCTAssertTrue(__tree_invariant(__root()))
    }

    override func tearDownWithError() throws {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
      try super.setUpWithError()
    }
  }

  final class TreeBaseTests_EmptyNode: TreeFixtureBase<Void> {

    func testEmpty() throws {
      XCTAssertEqual(__root(), .nullptr)
    }

    #if TREE_INVARIANT_CHECKS
      func testRootInvaliant() throws {

        XCTAssertTrue(__tree_invariant(__root()))

        __nodes = [
          .init(__is_black_: true, __left_: nil, __right_: nil, __parent_: .end)
        ]

        __root(.nullptr)
        XCTAssertFalse(__tree_invariant(0))

        __root(0)
        XCTAssertTrue(__tree_invariant(__root()))

        __nodes = [
          .init(__is_black_: false, __left_: nil, __right_: nil, __parent_: .end)
        ]
        XCTAssertFalse(__tree_invariant(__root()))

        __nodes = [
          .init(__is_black_: true, __left_: nil, __right_: nil, __parent_: nil)
        ]
        XCTAssertFalse(__tree_invariant(__root()))
      }
    #endif

    #if TREE_INVARIANT_CHECKS
      func testRotate() throws {
        //      let tree = RedBlackTree___Tree.create(minimumCapacity: 8)

        __nodes = [
          .init(__is_black_: true, __left_: 1, __right_: 2, __parent_: .end),
          .init(__is_black_: false, __left_: nil, __right_: nil, __parent_: 0),
          .init(__is_black_: false, __left_: 3, __right_: 4, __parent_: 0),
          .init(__is_black_: true, __left_: nil, __right_: nil, __parent_: 2),
          .init(__is_black_: true, __left_: nil, __right_: nil, __parent_: 2),
        ]
        __root(0)

        let initial = __nodes

        XCTAssertFalse(__tree_invariant(__root()))
        __tree_left_rotate(__root())

        var next = initial
        next[0] = .init(__is_black_: true, __left_: 1, __right_: 3, __parent_: 2)
        next[2] = .init(__is_black_: false, __left_: 0, __right_: 4, __parent_: .end)
        next[3] = .init(__is_black_: true, __left_: nil, __right_: nil, __parent_: 0)

        XCTAssertEqual(__root(), 2)
        XCTAssertEqual(__nodes[0], next[0])
        XCTAssertEqual(__nodes[1], next[1])
        XCTAssertEqual(__nodes[2], next[2])
        XCTAssertEqual(__nodes[3], next[3])
        XCTAssertEqual(__nodes[4], next[4])

        __tree_right_rotate(2)
        XCTAssertEqual(__nodes, initial)
      }
    #endif

    #if TREE_INVARIANT_CHECKS
      func testBalancing0() throws {
        __root(.node(__nodes.count))
        __nodes.append(.init(__is_black_: false, __left_: nil, __right_: nil, __parent_: .end))
        XCTAssertEqual(__nodes.count, 1)
        XCTAssertNotEqual(__root(), nil)
        XCTAssertEqual(__left_(__root()), nil)
        XCTAssertEqual(__right_(__root()), nil)
        XCTAssertFalse(__tree_invariant(__root()))
        __tree_balance_after_insert(__root(), 0)
        XCTAssertTrue(__tree_invariant(__root()))
      }
    #endif
  }

  final class TreeBaseTests_OneNode: TreeFixtureBase<Void> {

    override func setUpWithError() throws {
      // Put setup code here. This method is called before the invocation of each test method in the class.
      try super.setUpWithError()
      __left_ = 0
      __nodes = [.node]
      __nodes[0].__is_black_ = true
      __nodes[0].__parent_ = .end
    }

    #if TREE_INVARIANT_CHECKS
      func testRootRedBlack() throws {
        __nodes[__root()].__is_black_ = true
        XCTAssertTrue(__tree_invariant(__root()))
        __nodes[__root()].__is_black_ = false
        XCTAssertFalse(__tree_invariant(__root()))
      }
    #endif
  }

  final class TreeBaseTests_TwoNode: TreeFixtureBase<Void> {

    override func setUpWithError() throws {
      // Put setup code here. This method is called before the invocation of each test method in the class.
      try super.setUpWithError()
      __nodes = [.node, .node]
      __nodes[0].__is_black_ = true
      __nodes[0].__parent_ = .end
      __left_ = 0
    }

    override func tearDownWithError() throws {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
      try super.setUpWithError()
    }

    func testIsLeftChild() throws {
      XCTAssertTrue(__tree_is_left_child(__root()))
      XCTAssertTrue(__tree_invariant(__root()))
      __nodes[0].__left_ = 1
      __nodes[1].__parent_ = 0
      XCTAssertTrue(__tree_is_left_child(1))
      XCTAssertTrue(__tree_invariant(__root()))
      __nodes[0].__left_ = .nullptr
      __nodes[0].__right_ = 1
      XCTAssertFalse(__tree_is_left_child(1))
      XCTAssertTrue(__tree_invariant(__root()))
    }
  }

  final class TreeTests_EmptyNode: TreeFixture<Int> {

    func testRemove3() throws {
      _ = __insert_unique(0)
      _ = __insert_unique(1)
      _ = __insert_unique(2)
      XCTAssertEqual(__tree_min(__root()), __begin_node)
      for i in 0..<3 {
        _ = ___erase_unique(i)
        if __root() != .nullptr {
          XCTAssertEqual(__tree_min(__root()), __begin_node)
        }
        XCTAssertEqual(size, 2 - i)
      }
    }

    func testRemove2() throws {
      for i in 0..<2 {
        _ = __insert_unique(i)
      }
      XCTAssertEqual(__tree_min(__root()), __begin_node)
      for i in 0..<2 {
        XCTAssertTrue(___erase_unique(i) == true, "i = \(i)")
        XCTAssertTrue(__tree_invariant(__root()))
        XCTAssertEqual(
          __root() == .nullptr ? .end : __tree_min(__root()),
          __begin_node)
        XCTAssertEqual(size, 1 - i, "i = \(i)")
      }
    }

    func testRemove7() throws {
      for i in 0..<7 {
        _ = __insert_unique(i)
      }
      XCTAssertEqual(__tree_min(__root()), __begin_node)
      for i in 0..<7 {
        XCTAssertTrue(___erase_unique(i) == true, "i = \(i)")
        XCTAssertTrue(__tree_invariant(__root()))
        XCTAssertEqual(
          __root() == .nullptr ? .end : __tree_min(__root()),
          __begin_node)
        XCTAssertEqual(size, 6 - i, "i = \(i)")
      }
    }

    func testFindEqual0() throws {
      do {
        var __parent: _NodePtr = .nullptr
        let __k = 5
        let __child = __find_equal(&__parent, __k)
        XCTAssertEqual(__parent, .end)
        XCTAssertEqual(__child, .__left_(.end))
      }
      do {
        __root(nil)
        var __parent: _NodePtr = .nullptr
        let __k = 5
        let __child = __find_equal(&__parent, __k)
        XCTAssertEqual(__parent, .end)
        XCTAssertEqual(__child, .__left_(.end))
      }
    }

    func testInsert0() throws {
      for i in 0..<10000 {
        XCTAssertTrue(__insert_unique(i).__inserted)
        XCTAssertTrue(__tree_invariant(__root()))
      }
    }
  }

  final class TreeTests0_10_20: TreeFixture0_10_20 {

    func testMin() {
      XCTAssertEqual(__tree_min(__root()), 1)
    }

    func testMax() {
      XCTAssertEqual(__tree_max(__root()), 2)
    }

    func testFindEqual1() throws {
      do {
        var __parent: _NodePtr = .nullptr
        let __k = -1
        let __child = __find_equal(&__parent, __k)
        XCTAssertEqual(__parent.index, __child.index)
        XCTAssertEqual(__parent, 1)
        XCTAssertEqual(__child, .__left_(1))
      }
      do {
        var __parent: _NodePtr = .nullptr
        let __k = 0
        let __child = __find_equal(&__parent, __k)
        XCTAssertNotEqual(__parent.index, __child.index)
        XCTAssertEqual(__parent, 1)
        XCTAssertEqual(__child, .__left_(0))
      }
      do {
        var __parent: _NodePtr = .nullptr
        let __k = 5
        let __child = __find_equal(&__parent, __k)
        XCTAssertEqual(__parent.index, __child.index)
        XCTAssertEqual(__parent, 1)
        XCTAssertEqual(__child, .__right_(1))
      }
      do {
        var __parent: _NodePtr = .nullptr
        let __k = 10
        let __child = __find_equal(&__parent, __k)
        XCTAssertNotEqual(__parent.index, __child.index)
        XCTAssertEqual(__parent, 0)
        XCTAssertEqual(__child, .__left_(.end))
      }
      do {
        var __parent: _NodePtr = .nullptr
        let __k = 15
        let __child = __find_equal(&__parent, __k)
        XCTAssertEqual(__parent.index, __child.index)
        XCTAssertEqual(__parent, 2)
        XCTAssertEqual(__child, .__left_(2))
      }
      do {
        var __parent: _NodePtr = .nullptr
        let __k = 20
        let __child = __find_equal(&__parent, __k)
        XCTAssertNotEqual(__parent.index, __child.index)
        XCTAssertEqual(__parent, 2)
        XCTAssertEqual(__child, .__right_(0))
      }
      do {
        var __parent: _NodePtr = .nullptr
        let __k = 21
        let __child = __find_equal(&__parent, __k)
        XCTAssertEqual(__parent.index, __child.index)
        XCTAssertEqual(__parent, 2)
        XCTAssertEqual(__child, .__right_(2))
      }
    }
  }

  final class TreeTests0_1_2_3_4_5_6: TreeFixture0_1_2_3_4_5_6 {

    func testMin() {
      XCTAssertEqual(__tree_min(__root()), 2)
    }

    func testMax() {
      XCTAssertEqual(__tree_max(__root()), 6)
    }
  }
#endif
