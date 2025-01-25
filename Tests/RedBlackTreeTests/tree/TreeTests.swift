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
  class TreeFixtureBase<Element>: XCTestCase, ___tree_root_node, MemberProtocol, RootProtocol,
    EndNodeProtocol,
    ___RedBlackTreeNodePoolProtocol
  {
    var __left_: _NodePtr = .nullptr
    var __begin_node: _NodePtr = .nullptr

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

    func ___initialize(_: Void) -> RedBlackTreeModule._NodePtr {
      let n = __nodes.count
      __nodes.append(.node)
      return n
    }

    func ___element(_ p: RedBlackTreeModule._NodePtr, _: Void) {
      /* NOP */
    }

    @inlinable
    func __root(_ p: _NodePtr) {
      __left_ = p
    }

    func clear() {
      __left_ = .nullptr
      __begin_node = .nullptr
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

  class TreeFixture0_10_20: TreeFixtureBase<Int> {

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

  class TreeFixture0_1_2_3_4_5_6: TreeFixtureBase<Int> {

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

  final class TreeEmptyTests: TreeFixtureBase<Void> {

    func testEmpty() throws {
      XCTAssertEqual(__root(), .nullptr)
    }
  }

  final class TreeOneNodeTests: TreeFixtureBase<Void> {

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

  final class TreeTwoNodeTests: TreeFixtureBase<Void> {

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

  final class TreeTests0_10_20: TreeFixture0_10_20 {

    func testMin() {
      XCTAssertEqual(__tree_min(__root()), 1)
    }

    func testMax() {
      XCTAssertEqual(__tree_max(__root()), 2)
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
