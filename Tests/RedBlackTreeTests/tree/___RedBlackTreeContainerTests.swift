//
//  BaseNodeContainerTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2024/09/17.
//

import XCTest

// 結構ディープな内容なので温存する必要がある

#if DEBUG && !USE_UNSAFE_TREE
  @testable import RedBlackTreeModule

  final class ___RedBlackTreeContainerTests: XCTestCase {

    func fixtureEmpty(_ tree: inout RedBlackTreeSet<Int>) {
      tree.__nodes = []
      tree.__root(.nullptr)
      XCTAssertTrue(tree.___tree_invariant())
    }

    func fixture0_10_20(_ tree: inout RedBlackTreeSet<Int>) {
      tree.__nodes = [
        .init(__is_black_: true, __left_: 1, __right_: 2, __parent_: .end),
        .init(__is_black_: false, __left_: .nullptr, __right_: .nullptr, __parent_: 0),
        .init(__is_black_: false, __left_: .nullptr, __right_: .nullptr, __parent_: 0),
      ]
      tree.___elements = [
        10,
        0,
        20,
      ]
      tree.__root(0)
      tree.__tree_.__begin_node_ = 1
      XCTAssertTrue(tree.___tree_invariant())
    }

    func fixture0_1_2_3_4_5_6(_ tree: inout RedBlackTreeSet<Int>) {
      tree.__nodes = [
        .init(__is_black_: true, __left_: 1, __right_: 4, __parent_: .end),
        .init(__is_black_: false, __left_: 2, __right_: 3, __parent_: 0),
        .init(__is_black_: true, __left_: .nullptr, __right_: .nullptr, __parent_: 1),
        .init(__is_black_: true, __left_: .nullptr, __right_: .nullptr, __parent_: 1),
        .init(__is_black_: false, __left_: 5, __right_: 6, __parent_: 0),
        .init(__is_black_: true, __left_: .nullptr, __right_: .nullptr, __parent_: 4),
        .init(__is_black_: true, __left_: .nullptr, __right_: .nullptr, __parent_: 4),
      ]
      tree.___elements = [
        3,
        1,
        0,
        2,
        4,
        5,
        6,
      ]
      tree.__root(0)
      //        tree.___header.size = tree.___nodes.count
      XCTAssertEqual(tree.___header.initializedCount, 7)
      tree.___header.__begin_node = 2
      XCTAssertTrue(tree.___tree_invariant())
    }

    func testRootInvaliant() throws {

      var tree = RedBlackTreeSet<Int>(minimumCapacity: capacity)
      XCTAssertTrue(tree.___tree_invariant())

      tree.__nodes = [
        .init(__is_black_: true, __left_: .nullptr, __right_: .nullptr, __parent_: .end)
      ]

      #if TREE_INVARIANT_CHECKS
        tree.__root(.nullptr)
        XCTAssertFalse(tree.__tree_.__tree_invariant(0))

        tree.__root(0)
        XCTAssertTrue(tree.__tree_.__tree_invariant(tree.__root()))
      #endif

      #if TREE_INVARIANT_CHECKS
        tree.__nodes = [
          .init(__is_black_: false, __left_: .nullptr, __right_: .nullptr, __parent_: .end)
        ]
        XCTAssertFalse(tree.__tree_.__tree_invariant(tree.__root()))

        tree.__nodes = [
          .init(__is_black_: true, __left_: .nullptr, __right_: .nullptr, __parent_: .nullptr)
        ]
        XCTAssertFalse(tree.__tree_.__tree_invariant(tree.__root()))
      #endif
    }

    func testFixtures() {

      var tree = RedBlackTreeSet<Int>(minimumCapacity: capacity)
      fixtureEmpty(&tree)
      fixture0_10_20(&tree)
      fixture0_1_2_3_4_5_6(&tree)
    }

    func testMin() {
      var tree = RedBlackTreeSet<Int>(minimumCapacity: capacity)
      fixture0_10_20(&tree)
      XCTAssertEqual(tree.__tree_min(tree.__root()), 1)
      fixture0_1_2_3_4_5_6(&tree)
      XCTAssertEqual(tree.__tree_min(tree.__root()), 2)
    }

    func testMax() {
      var tree = RedBlackTreeSet<Int>(minimumCapacity: capacity)
      fixture0_10_20(&tree)
      XCTAssertEqual(tree.__tree_max(tree.__root()), 2)
      fixture0_1_2_3_4_5_6(&tree)
      XCTAssertEqual(tree.__tree_max(tree.__root()), 6)
    }

    let capacity = 32

    func testRotate() throws {
      var tree = RedBlackTreeSet<Int>(minimumCapacity: capacity)

      tree.__nodes = [
        .init(__is_black_: true, __left_: 1, __right_: 2, __parent_: .end),
        .init(__is_black_: false, __left_: .nullptr, __right_: .nullptr, __parent_: 0),
        .init(__is_black_: false, __left_: 3, __right_: 4, __parent_: 0),
        .init(__is_black_: true, __left_: .nullptr, __right_: .nullptr, __parent_: 2),
        .init(__is_black_: true, __left_: .nullptr, __right_: .nullptr, __parent_: 2),
      ]
      tree.__root(0)

      let initial = tree.__nodes

      #if TREE_INVARIANT_CHECKS
        XCTAssertFalse(tree.___tree_invariant())
      #endif

      tree.__tree_left_rotate(tree.__root())

      var next = initial
      next[0] = .init(__is_black_: true, __left_: 1, __right_: 3, __parent_: 2)
      next[2] = .init(__is_black_: false, __left_: 0, __right_: 4, __parent_: .end)
      next[3] = .init(__is_black_: true, __left_: .nullptr, __right_: .nullptr, __parent_: 0)

      XCTAssertEqual(tree.__left_, 2)
      XCTAssertEqual(tree.__nodes[0], next[0])
      XCTAssertEqual(tree.__nodes[1], next[1])
      XCTAssertEqual(tree.__nodes[2], next[2])
      XCTAssertEqual(tree.__nodes[3], next[3])
      XCTAssertEqual(tree.__nodes[4], next[4])

      tree.__tree_right_rotate(2)

      XCTAssertEqual(tree.__nodes, initial)
    }

    func testBalancing0() throws {
      var tree = RedBlackTreeSet<Int>(minimumCapacity: capacity)
      fixtureEmpty(&tree)
      tree.__left_ = .node(tree.__nodes.count)
      tree.__nodes.append(
        .init(__is_black_: false, __left_: .nullptr, __right_: .nullptr, __parent_: .end))
      tree.__tree_.__begin_node_ = 0
      XCTAssertEqual(tree.__nodes.count, 1)
      XCTAssertNotEqual(tree.__root(), nil)
      XCTAssertNotEqual(tree.__tree_.__parent_(tree.__root()), nil)
      XCTAssertEqual(tree.__left_(tree.__root()), .nullptr)
      XCTAssertEqual(tree.__right_(tree.__root()), .nullptr)
      #if TREE_INVARIANT_CHECKS
        XCTAssertFalse(tree.___tree_invariant())
      #endif
      tree.__tree_balance_after_insert(tree.__root(), 0)
      #if TREE_INVARIANT_CHECKS
        XCTAssertTrue(tree.___tree_invariant())
      #endif
    }

    func testRemove3() throws {

      let tree = RedBlackTreeSet<Int>(minimumCapacity: capacity)
      _ = tree.__tree_.__insert_unique(0)
      _ = tree.__tree_.__insert_unique(1)
      _ = tree.__tree_.__insert_unique(2)
      XCTAssertEqual(tree.__tree_.__tree_min(tree.__tree_.__root), tree.___header.__begin_node)
      for i in 0..<3 {
        _ = tree.__tree_.___erase_unique(i)
        if tree.__root() != .nullptr {
          XCTAssertEqual(
            tree.__tree_.__tree_min(tree.__tree_.__root), tree.___header.__begin_node)
        }
        XCTAssertEqual(tree._count, 2 - i)
      }
    }

    func testRemove2() throws {

      let tree = RedBlackTreeSet<Int>(minimumCapacity: capacity)
      for i in 0..<2 {
        _ = tree.__tree_.__insert_unique(i)
      }
      //        fixture0_1_2_3_4_5_6(&tree)
      XCTAssertEqual(tree.__tree_.__tree_min(tree.__tree_.__root), tree.___header.__begin_node)
      for i in 0..<2 {
        XCTAssertTrue(tree.__tree_.___erase_unique(i), "i = \(i)")
        print("__root():", tree.__root())
        XCTAssertTrue(tree.___tree_invariant())
        XCTAssertEqual(
          tree.__root() == .nullptr ? .end : tree.__tree_.__tree_min(tree.__tree_.__root),
          tree.___header.__begin_node)
        XCTAssertEqual(tree._count, 1 - i, "i = \(i)")
      }
    }

    func testRemove7() throws {

      let tree = RedBlackTreeSet<Int>(minimumCapacity: capacity)
      for i in 0..<7 {
        _ = tree.__tree_.__insert_unique(i)
      }
      //        fixture0_1_2_3_4_5_6(&tree)
      XCTAssertEqual(tree.__tree_.__tree_min(tree.__tree_.__root), tree.___header.__begin_node)
      for i in 0..<7 {
        XCTAssertTrue(tree.__tree_.___erase_unique(i), "i = \(i)")
        print("__root():", tree.__root())
        XCTAssertTrue(tree.___tree_invariant())
        XCTAssertEqual(
          tree.__root == .nullptr ? .end : tree.__tree_.__tree_min(tree.__tree_.__root),
          tree.___header.__begin_node)
        XCTAssertEqual(tree._count, 6 - i, "i = \(i)")
      }
    }

    func testFindEqual0() throws {
      var tree = RedBlackTreeSet<Int>(minimumCapacity: capacity)
      fixtureEmpty(&tree)
      do {
        let __k = 5
        let (__parent, __child) = tree.__tree_.__find_equal(__k)
        XCTAssertEqual(__parent, .end)
        XCTAssertEqual(__child, tree.__tree_.__left_ref(.end))
      }
      do {
        tree.__left_ = .nullptr
        let __k = 5
        let (__parent, __child) = tree.__tree_.__find_equal(__k)
        XCTAssertEqual(__parent, .end)
        XCTAssertEqual(__child, tree.__tree_.__left_ref(.end))
      }
    }

    func testFindEqual1() throws {
      var tree = RedBlackTreeSet<Int>(minimumCapacity: capacity)
      fixture0_10_20(&tree)
      do {
        let __k = -1
        let (__parent, __child) = tree.__tree_.__find_equal(__k)
        XCTAssertEqual(__parent.index, __child.index)
        XCTAssertEqual(__parent, 1)
        XCTAssertEqual(__child, tree.__tree_.__left_ref(1))
      }
      do {
        let __k = 0
        let (__parent, __child) = tree.__tree_.__find_equal(__k)
        XCTAssertNotEqual(__parent.index, __child.index)
        XCTAssertEqual(__parent, 1)
        XCTAssertEqual(__child, tree.__tree_.__left_ref(0))
      }
      do {
        let __k = 5
        let (__parent, __child) = tree.__tree_.__find_equal(__k)
        XCTAssertEqual(__parent.index, __child.index)
        XCTAssertEqual(__parent, 1)
        XCTAssertEqual(__child, tree.__tree_.__right_ref(1))
      }
      do {
        let __k = 10
        let (__parent, __child) = tree.__tree_.__find_equal(__k)
        XCTAssertNotEqual(__parent.index, __child.index)
        XCTAssertEqual(__parent, 0)
        XCTAssertEqual(__child, tree.__tree_.__left_ref(.end))
      }
      do {
        let __k = 15
        let (__parent, __child) = tree.__tree_.__find_equal(__k)
        XCTAssertEqual(__parent.index, __child.index)
        XCTAssertEqual(__parent, 2)
        XCTAssertEqual(__child, tree.__tree_.__left_ref(2))
      }
      do {
        let __k = 20
        let (__parent, __child) = tree.__tree_.__find_equal(__k)
        XCTAssertNotEqual(__parent.index, __child.index)
        XCTAssertEqual(__parent, 2)
        XCTAssertEqual(__child, tree.__tree_.__right_ref(0))
      }
      do {
        let __k = 21
        let (__parent, __child) = tree.__tree_.__find_equal(__k)
        XCTAssertEqual(__parent.index, __child.index)
        XCTAssertEqual(__parent, 2)
        XCTAssertEqual(__child, tree.__tree_.__right_ref(2))
      }
    }

    func testInsert0() throws {

      let tree = RedBlackTreeSet<Int>(minimumCapacity: 10000)
      //      fixtureEmpty(&tree)
      for i in 0..<10000 {
        XCTAssertTrue(tree.__tree_.__insert_unique(i).__inserted)
      }
      XCTAssertTrue(tree.___tree_invariant())
    }

    #if ENABLE_PERFORMANCE_TESTING
      func testPerformanceExample() throws {

        throw XCTSkip()

        // 分解前 1.04 sec
        // 分解後 1.82 sec (ただしリリースビルドでの速度変化なし)

        var tree = RedBlackTreeSet<Int>()
        fixtureEmpty(&tree)
        tree.reserveCapacity(1_000_000)

        self.measure {
          // Put the code you want to measure the time of here.
          for i in 0..<1_000_000 {
            _ = tree.__tree_.__insert_unique(i)
          }
        }
      }
    #endif
  }
#endif
