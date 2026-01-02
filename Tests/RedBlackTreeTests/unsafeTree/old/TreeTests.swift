import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

#if DEBUG
  final class TreeBaseTests_EmptyNode: TreeFixtureBase<Void> {

    func testEmpty() throws {
      XCTAssertEqual(__root, .nullptr)
    }

    #if TREE_INVARIANT_CHECKS
      func testRootInvaliant() throws {

        XCTAssertTrue(__tree_invariant(__root))

        __nodes = [
          .init(__is_black_: true, __left_: .nullptr, __right_: .nullptr, __parent_: .end)
        ]

        __root = .nullptr
        XCTAssertFalse(__tree_invariant(0))

        __root = 0
        XCTAssertTrue(__tree_invariant(__root))

        __nodes = [
          .init(__is_black_: false, __left_: .nullptr, __right_: .nullptr, __parent_: .end)
        ]
        XCTAssertFalse(__tree_invariant(__root))

        __nodes = [
          .init(__is_black_: true, __left_: .nullptr, __right_: .nullptr, __parent_: .nullptr)
        ]
        XCTAssertFalse(__tree_invariant(__root))
      }
    #endif

    #if TREE_INVARIANT_CHECKS
      func testRotate() throws {

        __nodes = [
          .init(__is_black_: true, __left_: 1, __right_: 2, __parent_: .end),
          .init(__is_black_: false, __left_: .nullptr, __right_: .nullptr, __parent_: 0),
          .init(__is_black_: false, __left_: 3, __right_: 4, __parent_: 0),
          .init(__is_black_: true, __left_: .nullptr, __right_: .nullptr, __parent_: 2),
          .init(__is_black_: true, __left_: .nullptr, __right_: .nullptr, __parent_: 2),
        ]
        __root = 0

        let initial = __nodes

        XCTAssertFalse(__tree_invariant(__root))
        __tree_left_rotate(__root)

        var next = initial
        next[0] = .init(__is_black_: true, __left_: 1, __right_: 3, __parent_: 2)
        next[2] = .init(__is_black_: false, __left_: 0, __right_: 4, __parent_: .end)
        next[3] = .init(__is_black_: true, __left_: .nullptr, __right_: .nullptr, __parent_: 0)

        XCTAssertEqual(__root, 2)
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
        __root = .node(__nodes.count)
        __nodes.append(.init(__is_black_: false, __left_: .nullptr, __right_: .nullptr, __parent_: .end))
        XCTAssertEqual(__nodes.count, 1)
        XCTAssertNotEqual(__root, nil)
        XCTAssertEqual(__left_(__root), .nullptr)
        XCTAssertEqual(__right_(__root), .nullptr)
        XCTAssertFalse(__tree_invariant(__root))
        __tree_balance_after_insert(__root, 0)
        XCTAssertTrue(__tree_invariant(__root))
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
        __nodes[__root].__is_black_ = true
        XCTAssertTrue(__tree_invariant(__root))
        __nodes[__root].__is_black_ = false
        XCTAssertFalse(__tree_invariant(__root))
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
      XCTAssertTrue(__tree_is_left_child(__root))
      XCTAssertTrue(__tree_invariant(__root))
      __nodes[0].__left_ = 1
      __nodes[1].__parent_ = 0
      XCTAssertTrue(__tree_is_left_child(1))
      XCTAssertTrue(__tree_invariant(__root))
      __nodes[0].__left_ = .nullptr
      __nodes[0].__right_ = 1
      XCTAssertFalse(__tree_is_left_child(1))
      XCTAssertTrue(__tree_invariant(__root))
    }
  }

  final class TreeTests_EmptyNode: TreeFixture<Int> {

    func testRemove3() throws {
      _ = __insert_unique(0)
      _ = __insert_unique(1)
      _ = __insert_unique(2)
      XCTAssertEqual(__tree_min(__root), __begin_node_)
      for i in 0..<3 {
        _ = ___erase_unique(i)
        if __root != .nullptr {
          XCTAssertEqual(__tree_min(__root), __begin_node_)
        }
        XCTAssertEqual(__size_, 2 - i)
      }
    }

    func testRemove2() throws {
      for i in 0..<2 {
        _ = __insert_unique(i)
      }
      XCTAssertEqual(__tree_min(__root), __begin_node_)
      for i in 0..<2 {
        XCTAssertTrue(___erase_unique(i) == true, "i = \(i)")
        XCTAssertTrue(__tree_invariant(__root))
        XCTAssertEqual(
          __root == .nullptr ? .end : __tree_min(__root),
          __begin_node_)
        XCTAssertEqual(__size_, 1 - i, "i = \(i)")
      }
    }

    func testRemove7() throws {
      for i in 0..<7 {
        _ = __insert_unique(i)
      }
      XCTAssertEqual(__tree_min(__root), __begin_node_)
      for i in 0..<7 {
        XCTAssertTrue(___erase_unique(i) == true, "i = \(i)")
        XCTAssertTrue(__tree_invariant(__root))
        XCTAssertEqual(
          __root == .nullptr ? .end : __tree_min(__root),
          __begin_node_)
        XCTAssertEqual(__size_, 6 - i, "i = \(i)")
      }
    }

    func testFindEqual0() throws {
      do {
        let __k = 5
        let (__parent, __child) = __find_equal(__k)
        XCTAssertEqual(__parent, .end)
        XCTAssertEqual(__child, __left_ref(.end))
      }
      do {
        __root = .nullptr
        let __k = 5
        let (__parent, __child) = __find_equal(__k)
        XCTAssertEqual(__parent, .end)
        XCTAssertEqual(__child, __left_ref(.end))
      }
    }

    func testInsert0() throws {
      for i in 0..<10000 {
        XCTAssertTrue(__insert_unique(i).__inserted)
        XCTAssertTrue(__tree_invariant(__root))
      }
    }
  }

  final class TreeTests0_10_20: TreeFixture0_10_20 {

    func testMin() {
      XCTAssertEqual(__tree_min(__root), 1)
    }

    func testMax() {
      XCTAssertEqual(__tree_max(__root), 2)
    }

    func testFindEqual1() throws {
      do {
        let __k = -1
        let (__parent, __child) = __find_equal(__k)
        XCTAssertEqual(__parent.index, __child.index)
        XCTAssertEqual(__parent, 1)
        XCTAssertEqual(__child, __left_ref(1))
      }
      do {
        let __k = 0
        let (__parent, __child) = __find_equal(__k)
        XCTAssertNotEqual(__parent.index, __child.index)
        XCTAssertEqual(__parent, 1)
        XCTAssertEqual(__child, __left_ref(0))
      }
      do {
        let __k = 5
        let (__parent, __child) = __find_equal(__k)
        XCTAssertEqual(__parent.index, __child.index)
        XCTAssertEqual(__parent, 1)
        XCTAssertEqual(__child, __right_ref(1))
      }
      do {
        let __k = 10
        let (__parent, __child) = __find_equal(__k)
        XCTAssertNotEqual(__parent.index, __child.index)
        XCTAssertEqual(__parent, 0)
        XCTAssertEqual(__child, __left_ref(.end))
      }
      do {
        let __k = 15
        let (__parent, __child) = __find_equal(__k)
        XCTAssertEqual(__parent.index, __child.index)
        XCTAssertEqual(__parent, 2)
        XCTAssertEqual(__child, __left_ref(2))
      }
      do {
        let __k = 20
        let (__parent, __child) = __find_equal(__k)
        XCTAssertNotEqual(__parent.index, __child.index)
        XCTAssertEqual(__parent, 2)
        XCTAssertEqual(__child, __right_ref(0))
      }
      do {
        let __k = 21
        let (__parent, __child) = __find_equal(__k)
        XCTAssertEqual(__parent.index, __child.index)
        XCTAssertEqual(__parent, 2)
        XCTAssertEqual(__child, __right_ref(2))
      }
    }
  }

  final class TreeTests0_1_2_3_4_5_6: TreeFixture0_1_2_3_4_5_6 {

    func testMin() {
      XCTAssertEqual(__tree_min(__root), 2)
    }

    func testMax() {
      XCTAssertEqual(__tree_max(__root), 6)
    }
  }

  final class TreeTests_EmptyNode_Misc: TreeFixture<Int> {

    override func setUpWithError() throws {
      // Put setup code here. This method is called before the invocation of each test method in the class.
      clear()
      _ = __insert_unique(0)
      _ = __insert_unique(1)
      _ = __insert_unique(2)
      _ = __insert_unique(3)
      _ = __insert_unique(4)
      _ = __insert_unique(5)
    }

    override func tearDownWithError() throws {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
      clear()
    }

    func testMisc() throws {
      XCTAssertTrue(___ptr_less_than(lower_bound(0), lower_bound(1)))
      XCTAssertTrue(___ptr_less_than(lower_bound(1), lower_bound(2)))
      XCTAssertTrue(___ptr_less_than(lower_bound(2), lower_bound(3)))
      XCTAssertTrue(___ptr_less_than(lower_bound(3), lower_bound(4)))
      XCTAssertTrue(___ptr_less_than(lower_bound(4), lower_bound(5)))
      XCTAssertTrue(___ptr_less_than(lower_bound(5), .end))
      XCTAssertFalse(___ptr_less_than(lower_bound(0), lower_bound(0)))
      XCTAssertFalse(___ptr_less_than(lower_bound(1), lower_bound(1)))
      XCTAssertFalse(___ptr_less_than(lower_bound(2), lower_bound(2)))
      XCTAssertFalse(___ptr_less_than(lower_bound(3), lower_bound(3)))
      XCTAssertFalse(___ptr_less_than(lower_bound(4), lower_bound(4)))
      XCTAssertFalse(___ptr_less_than(lower_bound(5), lower_bound(5)))
      XCTAssertFalse(___ptr_less_than(.end, .end))
      XCTAssertFalse(___ptr_less_than(lower_bound(1), lower_bound(0)))
      XCTAssertFalse(___ptr_less_than(lower_bound(2), lower_bound(1)))
      XCTAssertFalse(___ptr_less_than(lower_bound(3), lower_bound(2)))
      XCTAssertFalse(___ptr_less_than(lower_bound(4), lower_bound(3)))
      XCTAssertFalse(___ptr_less_than(lower_bound(5), lower_bound(4)))
      XCTAssertFalse(___ptr_less_than(.end, lower_bound(5)))
    }

    func testMisc2() throws {
      XCTAssertFalse(___ptr_greator_than(lower_bound(0), lower_bound(1)))
      XCTAssertFalse(___ptr_greator_than(lower_bound(1), lower_bound(2)))
      XCTAssertFalse(___ptr_greator_than(lower_bound(2), lower_bound(3)))
      XCTAssertFalse(___ptr_greator_than(lower_bound(3), lower_bound(4)))
      XCTAssertFalse(___ptr_greator_than(lower_bound(4), lower_bound(5)))
      XCTAssertFalse(___ptr_greator_than(lower_bound(5), .end))
      XCTAssertFalse(___ptr_greator_than(lower_bound(0), lower_bound(0)))
      XCTAssertFalse(___ptr_greator_than(lower_bound(1), lower_bound(1)))
      XCTAssertFalse(___ptr_greator_than(lower_bound(2), lower_bound(2)))
      XCTAssertFalse(___ptr_greator_than(lower_bound(3), lower_bound(3)))
      XCTAssertFalse(___ptr_greator_than(lower_bound(4), lower_bound(4)))
      XCTAssertFalse(___ptr_greator_than(lower_bound(5), lower_bound(5)))
      XCTAssertFalse(___ptr_greator_than(.end, .end))
      XCTAssertTrue(___ptr_greator_than(lower_bound(1), lower_bound(0)))
      XCTAssertTrue(___ptr_greator_than(lower_bound(2), lower_bound(1)))
      XCTAssertTrue(___ptr_greator_than(lower_bound(3), lower_bound(2)))
      XCTAssertTrue(___ptr_greator_than(lower_bound(4), lower_bound(3)))
      XCTAssertTrue(___ptr_greator_than(lower_bound(5), lower_bound(4)))
      XCTAssertTrue(___ptr_greator_than(.end, lower_bound(5)))
    }

    func testMisc3() throws {
      XCTAssertTrue(___ptr_less_than_or_equal(lower_bound(0), lower_bound(1)))
      XCTAssertTrue(___ptr_less_than_or_equal(lower_bound(1), lower_bound(2)))
      XCTAssertTrue(___ptr_less_than_or_equal(lower_bound(2), lower_bound(3)))
      XCTAssertTrue(___ptr_less_than_or_equal(lower_bound(3), lower_bound(4)))
      XCTAssertTrue(___ptr_less_than_or_equal(lower_bound(4), lower_bound(5)))
      XCTAssertTrue(___ptr_less_than_or_equal(lower_bound(5), .end))
      XCTAssertTrue(___ptr_less_than_or_equal(lower_bound(0), lower_bound(0)))
      XCTAssertTrue(___ptr_less_than_or_equal(lower_bound(1), lower_bound(1)))
      XCTAssertTrue(___ptr_less_than_or_equal(lower_bound(2), lower_bound(2)))
      XCTAssertTrue(___ptr_less_than_or_equal(lower_bound(3), lower_bound(3)))
      XCTAssertTrue(___ptr_less_than_or_equal(lower_bound(4), lower_bound(4)))
      XCTAssertTrue(___ptr_less_than_or_equal(lower_bound(5), lower_bound(5)))
      XCTAssertTrue(___ptr_less_than_or_equal(.end, .end))
      XCTAssertFalse(___ptr_less_than_or_equal(lower_bound(1), lower_bound(0)))
      XCTAssertFalse(___ptr_less_than_or_equal(lower_bound(2), lower_bound(1)))
      XCTAssertFalse(___ptr_less_than_or_equal(lower_bound(3), lower_bound(2)))
      XCTAssertFalse(___ptr_less_than_or_equal(lower_bound(4), lower_bound(3)))
      XCTAssertFalse(___ptr_less_than_or_equal(lower_bound(5), lower_bound(4)))
      XCTAssertFalse(___ptr_less_than_or_equal(.end, lower_bound(5)))
    }

    func testMisc4() throws {
      XCTAssertFalse(___ptr_greator_than_or_equal(lower_bound(0), lower_bound(1)))
      XCTAssertFalse(___ptr_greator_than_or_equal(lower_bound(1), lower_bound(2)))
      XCTAssertFalse(___ptr_greator_than_or_equal(lower_bound(2), lower_bound(3)))
      XCTAssertFalse(___ptr_greator_than_or_equal(lower_bound(3), lower_bound(4)))
      XCTAssertFalse(___ptr_greator_than_or_equal(lower_bound(4), lower_bound(5)))
      XCTAssertFalse(___ptr_greator_than_or_equal(lower_bound(5), .end))
      XCTAssertTrue(___ptr_greator_than_or_equal(lower_bound(0), lower_bound(0)))
      XCTAssertTrue(___ptr_greator_than_or_equal(lower_bound(1), lower_bound(1)))
      XCTAssertTrue(___ptr_greator_than_or_equal(lower_bound(2), lower_bound(2)))
      XCTAssertTrue(___ptr_greator_than_or_equal(lower_bound(3), lower_bound(3)))
      XCTAssertTrue(___ptr_greator_than_or_equal(lower_bound(4), lower_bound(4)))
      XCTAssertTrue(___ptr_greator_than_or_equal(lower_bound(5), lower_bound(5)))
      XCTAssertTrue(___ptr_greator_than_or_equal(.end, .end))
      XCTAssertTrue(___ptr_greator_than_or_equal(lower_bound(1), lower_bound(0)))
      XCTAssertTrue(___ptr_greator_than_or_equal(lower_bound(2), lower_bound(1)))
      XCTAssertTrue(___ptr_greator_than_or_equal(lower_bound(3), lower_bound(2)))
      XCTAssertTrue(___ptr_greator_than_or_equal(lower_bound(4), lower_bound(3)))
      XCTAssertTrue(___ptr_greator_than_or_equal(lower_bound(5), lower_bound(4)))
      XCTAssertTrue(___ptr_greator_than_or_equal(.end, lower_bound(5)))
    }

    func testMisc5() throws {
      XCTAssertFalse(___ptr_closed_range_contains(lower_bound(1), lower_bound(4), lower_bound(0)))
      XCTAssertTrue(___ptr_closed_range_contains(lower_bound(1), lower_bound(4), lower_bound(1)))
      XCTAssertTrue(___ptr_closed_range_contains(lower_bound(1), lower_bound(4), lower_bound(4)))
      XCTAssertFalse(___ptr_closed_range_contains(lower_bound(1), lower_bound(4), lower_bound(5)))
      XCTAssertFalse(___ptr_closed_range_contains(lower_bound(1), lower_bound(4), __end_node))
      XCTAssertFalse(___ptr_closed_range_contains(lower_bound(2), lower_bound(3), lower_bound(1)))
      XCTAssertTrue(___ptr_closed_range_contains(lower_bound(2), lower_bound(3), lower_bound(2)))
      XCTAssertTrue(___ptr_closed_range_contains(lower_bound(2), lower_bound(3), lower_bound(3)))
      XCTAssertFalse(___ptr_closed_range_contains(lower_bound(2), lower_bound(3), lower_bound(4)))
      XCTAssertFalse(___ptr_closed_range_contains(lower_bound(2), lower_bound(3), __end_node))
    }
  }
#endif
