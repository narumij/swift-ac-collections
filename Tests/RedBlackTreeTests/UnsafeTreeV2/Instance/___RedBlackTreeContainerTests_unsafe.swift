//
//  ___RedBlackTreeContainerTests_unsafe.swift
//  swift-ac-collections
//
//  Created by narumij on 2024/09/17.
//
#if false
import XCTest

// 木の開発のブートストラップに該当する部分。結構ディープな内容なので温存する必要がある
// テストのセットアップがマニアックでしんどい

#if DEBUG
  @testable import RedBlackTreeCollections

  final class ___RedBlackTreeContainerTests: RedBlackTreeTestCase {

    let capacity = 32

    func fixtureEmpty(_ tree: inout RedBlackTreeSet<Int>) {
      tree.___applyFixture(nodes: [], elements: [])
      tree.__root(tree.nullptr)
      XCTAssertTrue(tree.___tree_invariant())
    }

    func fixture0_10_20(_ tree: inout RedBlackTreeSet<Int>) {
      tree.___applyFixture(
        nodes: [
          .init(__is_black_: true, __left_: 1, __right_: 2, __parent_: .end),
          .init(__is_black_: false, __left_: .nullptr, __right_: .nullptr, __parent_: 0),
          .init(__is_black_: false, __left_: .nullptr, __right_: .nullptr, __parent_: 0),
        ],
        elements: [
          10,
          0,
          20,
        ])
      tree.__root(tree.___NodePtr(0))
      tree.__tree_.__begin_node_ = tree.___NodePtr(1)
      XCTAssertTrue(tree.___tree_invariant())
    }

    func fixture0_1_2_3_4_5_6(_ tree: inout RedBlackTreeSet<Int>) {
      tree.___applyFixture(
        nodes: [
          .init(__is_black_: true, __left_: 1, __right_: 4, __parent_: .end),
          .init(__is_black_: false, __left_: 2, __right_: 3, __parent_: 0),
          .init(__is_black_: true, __left_: .nullptr, __right_: .nullptr, __parent_: 1),
          .init(__is_black_: true, __left_: .nullptr, __right_: .nullptr, __parent_: 1),
          .init(__is_black_: false, __left_: 5, __right_: 6, __parent_: 0),
          .init(__is_black_: true, __left_: .nullptr, __right_: .nullptr, __parent_: 4),
          .init(__is_black_: true, __left_: .nullptr, __right_: .nullptr, __parent_: 4),
        ],
        elements: [
          3,
          1,
          0,
          2,
          4,
          5,
          6,
        ])
      tree.__root(tree.___NodePtr(0))
      XCTAssertEqual(tree.___header.freshPoolUsedCount, 7)
      tree.__begin_node_ = tree.___NodePtr(2)
      XCTAssertTrue(tree.___tree_invariant())
    }

    /// `__tree_invariant`が、正しい木(黒root・rootの親がend)ではtrueを返し、
    /// 不正な構成(rootをnullptrに差し替える/rootを赤にする/親をend以外にする)では
    /// falseを返すこと。
    func testRootInvaliant() throws {

      var tree = RedBlackTreeSet<Int>(minimumCapacity: capacity)
      XCTAssertTrue(tree.___tree_invariant())

      tree.___applyFixture(
        nodes: [
          .init(__is_black_: true, __left_: .nullptr, __right_: .nullptr, __parent_: .end)
        ],
        elements: [0])

      #if TREE_INVARIANT_CHECKS
        tree.__root(tree.nullptr)
        XCTAssertFalse(tree.__tree_.__tree_invariant(tree.___NodePtr(0)))

        tree.__root(tree.___NodePtr(0))
        XCTAssertTrue(tree.__tree_.__tree_invariant(tree.__root))
      #endif

      #if TREE_INVARIANT_CHECKS
        tree.___applyFixture(
          nodes: [
            .init(__is_black_: false, __left_: .nullptr, __right_: .nullptr, __parent_: .end)
          ],
          elements: [0])
        XCTAssertFalse(tree.__tree_.__tree_invariant(tree.__root))

        tree.___applyFixture(
          nodes: [
            .init(__is_black_: true, __left_: .nullptr, __right_: .nullptr, __parent_: .nullptr)
          ],
          elements: [0])
        XCTAssertFalse(tree.__tree_.__tree_invariant(tree.__root))
      #endif
    }

    /// 3つのヘルパーFixture(空・3要素・7要素)が、それぞれ適用後に`___tree_invariant`を
    /// 満たす正しい木を作れること(以降のテストが使うFixtureヘルパー自体の健全性確認)。
    func testFixtures() {

      var tree = RedBlackTreeSet<Int>(minimumCapacity: capacity)
      fixtureEmpty(&tree)
      fixture0_10_20(&tree)
      fixture0_1_2_3_4_5_6(&tree)
    }

    /// `__tree_min`が、固定したFixtureに対して正しい最小値ノードのindexを返すこと。
    func testMin() {
      var tree = RedBlackTreeSet<Int>(minimumCapacity: capacity)
      fixture0_10_20(&tree)
      XCTAssertEqual(tree.__tree_min(tree.__root).index, 1)
      fixture0_1_2_3_4_5_6(&tree)
      XCTAssertEqual(tree.__tree_min(tree.__root).index, 2)
    }

    /// `__tree_max`が、固定したFixtureに対して正しい最大値ノードのindexを返すこと。
    func testMax() {
      var tree = RedBlackTreeSet<Int>(minimumCapacity: capacity)
      fixture0_10_20(&tree)
      XCTAssertEqual(tree.__tree_max(tree.__root).index, 2)
      fixture0_1_2_3_4_5_6(&tree)
      XCTAssertEqual(tree.__tree_max(tree.__root).index, 6)
    }

    /// `__tree_left_rotate`/`__tree_right_rotate`が、固定した5ノード構成に対して
    /// 期待通りの構造変化をし、左回転の後に右回転すると元の形に戻ること(可逆性)。
    func testRotate() throws {
      var tree = RedBlackTreeSet<Int>(minimumCapacity: capacity)

      tree.___applyFixture(
        nodes: [
          .init(__is_black_: true, __left_: 1, __right_: 2, __parent_: .end),
          .init(__is_black_: false, __left_: .nullptr, __right_: .nullptr, __parent_: 0),
          .init(__is_black_: false, __left_: 3, __right_: 4, __parent_: 0),
          .init(__is_black_: true, __left_: .nullptr, __right_: .nullptr, __parent_: 2),
          .init(__is_black_: true, __left_: .nullptr, __right_: .nullptr, __parent_: 2),
        ],
        elements: [100, 101, 102, 103, 104])
      tree.__root(tree.___NodePtr(0))

      let initial = tree.__nodes

      #if TREE_INVARIANT_CHECKS
        XCTAssertFalse(tree.___tree_invariant())
      #endif

      tree.__tree_left_rotate(tree.__root)

      var next = initial
      next[0] = .init(__is_black_: true, __left_: 1, __right_: 3, __parent_: 2)
      next[2] = .init(__is_black_: false, __left_: 0, __right_: 4, __parent_: .end)
      next[3] = .init(__is_black_: true, __left_: .nullptr, __right_: .nullptr, __parent_: 0)

      XCTAssertEqual(tree.__left_.index, 2)
      XCTAssertEqual(tree.__nodes[0], next[0])
      XCTAssertEqual(tree.__nodes[1], next[1])
      XCTAssertEqual(tree.__nodes[2], next[2])
      XCTAssertEqual(tree.__nodes[3], next[3])
      XCTAssertEqual(tree.__nodes[4], next[4])

      tree.__tree_right_rotate(tree.___NodePtr(2))

      XCTAssertEqual(tree.__nodes, initial)
    }

    /// 単一の赤いrootに対して`__tree_balance_after_insert`を呼ぶと、
    /// 不変条件を満たす形(黒root)に補正されること。
    func testBalancing0() throws {
      var tree = RedBlackTreeSet<Int>(minimumCapacity: capacity)
      fixtureEmpty(&tree)
      tree.___applyFixture(
        nodes: [
          .init(__is_black_: false, __left_: .nullptr, __right_: .nullptr, __parent_: .end)
        ],
        elements: [0])
      tree.__left_ = tree.___NodePtr(0)
      tree.__tree_.__begin_node_ = tree.___NodePtr(0)
      XCTAssertEqual(tree.__nodes.count, 1)
      XCTAssertNotEqual(tree.__root, tree.nullptr)
      #if TREE_INVARIANT_CHECKS
        XCTAssertFalse(tree.___tree_invariant())
      #endif
      tree.__tree_balance_after_insert(tree.__root, tree.___NodePtr(0))
      #if TREE_INVARIANT_CHECKS
        XCTAssertTrue(tree.___tree_invariant())
      #endif
    }

    /// 3要素を挿入した後、`___erase_unique`で1つずつ削除していく過程で、
    /// `__begin_node_`(最小値ノード)が常に正しく更新され続けること。
    func testRemove3() throws {

      let tree = RedBlackTreeSet<Int>(minimumCapacity: capacity)
      _ = tree.__tree_.__insert_unique(0)
      _ = tree.__tree_.__insert_unique(1)
      _ = tree.__tree_.__insert_unique(2)
      XCTAssertEqual(tree.__tree_.__tree_min(tree.__tree_.__root), tree.__begin_node_)
      for i in 0..<3 {
        _ = tree.__tree_.___erase_unique(i)
        if tree.__root.index != .nullptr {
          XCTAssertEqual(
            tree.__tree_.__tree_min(tree.__tree_.__root), tree.__begin_node_)
        }
        XCTAssertEqual(tree._count, 2 - i)
      }
    }

    /// (testRemove3と同じ観点、2要素版) 削除していく過程で`__begin_node_`と
    /// `___tree_invariant`・`count`が常に正しいこと。
    func testRemove2() throws {

      let tree = RedBlackTreeSet<Int>(minimumCapacity: capacity)
      for i in 0..<2 {
        _ = tree.__tree_.__insert_unique(i)
      }
      //        fixture0_1_2_3_4_5_6(&tree)
      XCTAssertEqual(tree.__tree_.__tree_min(tree.__tree_.__root), tree.__begin_node_)
      for i in 0..<2 {
        XCTAssertTrue(tree.__tree_.___erase_unique(i), "i = \(i)")
        print("__root():", tree.__root.index)
        XCTAssertTrue(tree.___tree_invariant())
        XCTAssertEqual(
          tree.__root == tree.nullptr ? tree._end : tree.__tree_.__tree_min(tree.__tree_.__root),
          tree.__begin_node_)
        XCTAssertEqual(tree._count, 1 - i, "i = \(i)")
      }
    }

    /// (testRemove3と同じ観点、7要素版) より大きい木でも削除過程で`__begin_node_`と
    /// `___tree_invariant`・`count`が常に正しいこと。
    func testRemove7() throws {

      let tree = RedBlackTreeSet<Int>(minimumCapacity: capacity)
      for i in 0..<7 {
        _ = tree.__tree_.__insert_unique(i)
      }
      //        fixture0_1_2_3_4_5_6(&tree)
      XCTAssertEqual(tree.__tree_.__tree_min(tree.__tree_.__root), tree.__begin_node_)
      for i in 0..<7 {
        XCTAssertTrue(tree.__tree_.___erase_unique(i), "i = \(i)")
        print("__root():", tree.__root.index)
        XCTAssertTrue(tree.___tree_invariant())
        XCTAssertEqual(
          tree.__root == tree.nullptr ? tree._end : tree.__tree_.__tree_min(tree.__tree_.__root),
          tree.__begin_node_)
        XCTAssertEqual(tree._count, 6 - i, "i = \(i)")
      }
    }

    /// 空の木に対して`__find_equal`を呼ぶと、親がend・挿入先の参照がendの左子を
    /// 指す状態(どこにも要素が無いので、endの左へ挿入すべき)になること。
    func testFindEqual0() throws {
      var tree = RedBlackTreeSet<Int>(minimumCapacity: capacity)
      fixtureEmpty(&tree)
      do {
        let __k = 5
        let (__parent, __child) = tree.__tree_.__find_equal(__k)
        XCTAssertEqual(__parent.index, .end)
        XCTAssertEqual(__child, tree.___NodePtr(.end).__left_ref)
      }
      do {
        tree.__left_ = tree.nullptr
        let __k = 5
        let (__parent, __child) = tree.__tree_.__find_equal(__k)
        XCTAssertEqual(__parent.index, .end)
        XCTAssertEqual(__child, tree.___NodePtr(.end).__left_ref)
      }
    }

    /// 3要素(0,10,20)の木に対し、木に無い値も含む様々なキーで`__find_equal`を呼んだ際の
    /// 挿入位置(親ノードと挿入先参照)が、BSTの探索ルールどおりになること。
    func testFindEqual1() throws {
      var tree = RedBlackTreeSet<Int>(minimumCapacity: capacity)
      fixture0_10_20(&tree)
      do {
        let __k = -1
        let (__parent, __child) = tree.__tree_.__find_equal(__k)
        //        XCTAssertEqual(__parent, tree.__tree_.__ptr_(__child))
        XCTAssertEqual(__parent.index, 1)
        XCTAssertEqual(__child, tree.___NodePtr(1).__left_ref)
      }
      do {
        let __k = 0
        let (__parent, __child) = tree.__tree_.__find_equal(__k)
        //        XCTAssertEqual(__parent, tree.__tree_.__ptr_(__child))
        XCTAssertEqual(__parent.index, 1)
        XCTAssertEqual(__child, tree.___NodePtr(0).__left_ref)
      }
      do {
        let __k = 5
        let (__parent, __child) = tree.__tree_.__find_equal(__k)
        //        XCTAssertEqual(__parent, tree.__tree_.__ptr_(__child))
        XCTAssertEqual(__parent.index, 1)
        XCTAssertEqual(__child, tree.___NodePtr(1).__right_ref)
      }
      do {
        let __k = 10
        let (__parent, __child) = tree.__tree_.__find_equal(__k)
        //        XCTAssertEqual(__parent, tree.__tree_.__ptr_(__child))
        XCTAssertEqual(__parent.index, 0)
        XCTAssertEqual(__child, tree.___NodePtr(.end).__left_ref)
      }
      do {
        let __k = 15
        let (__parent, __child) = tree.__tree_.__find_equal(__k)
        //        XCTAssertEqual(__parent, tree.__tree_.__ptr_(__child))
        XCTAssertEqual(__parent.index, 2)
        XCTAssertEqual(__child, tree.___NodePtr(2).__left_ref)
      }
      do {
        let __k = 20
        let (__parent, __child) = tree.__tree_.__find_equal(__k)
        //        XCTAssertEqual(__parent, tree.__tree_.__ptr_(__child))
        XCTAssertEqual(__parent.index, 2)
        XCTAssertEqual(__child, tree.___NodePtr(0).__right_ref)
      }
      do {
        let __k = 21
        let (__parent, __child) = tree.__tree_.__find_equal(__k)
        //        XCTAssertEqual(__parent, tree.__tree_.__ptr_(__child))
        XCTAssertEqual(__parent.index, 2)
        XCTAssertEqual(__child, tree.___NodePtr(2).__right_ref)
      }
    }

    /// 10000要素を`__insert_unique`で挿入していくと、全て新規挿入
    /// (`__inserted == true`)となり、最終的に`___tree_invariant`を満たすこと。
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
#endif
