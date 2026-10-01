import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections

  @available(anyAppleOS 26.0, *)
  final class TreeFoundamentalMutationTests: RedBlackTreeTestCase {

    private final class State {
      let owned = TreeOwnedNodeFixture<Int>()
      let endNode: UnsafeMutablePointer<UnsafeNode>
      var beginNode: UnsafeMutablePointer<UnsafeNode>
      var size = 0

      init() {
        endNode = .allocate(capacity: 1)
        endNode.initialize(to: .create(tag: .end, nullptr: .nullptr))
        beginNode = endNode
      }

      deinit {
        precondition(size == 0)
        precondition(owned.allocationCount == 0)
        endNode.deinitialize(count: 1)
        endNode.deallocate()
      }
    }

    /// 生のノード所有fixtureへ原木の探索・挿入・削除プロトコルだけを合成したハーネス。
    /// 生木や公開Collectionを経由せず、payloadの構築・破棄まで同じ経路で検査する。
    private struct MutationTree: ~Copyable, _UnsafeNodePtrType, TreeAlgorithmBaseProtocol_ptr,
      TreeAlgorithmProtocol_ptr, InsertNodeAtProtocol_ptr, FindLeafProtocol_ptr,
      FindEqualInterface, FindEqualProtocol_ptr_old, InsertUniqueProtocol_ptr,
      InsertMultiProtocol, RemoveProtocol_ptr, EraseProtocol, FindProtocol_find_equal_ptr,
      EraseUniqueProtocol, InsertLastProtocol_ptr
    {
      typealias _PayloadValue = Int
      typealias _Key = Int
      typealias __node_value_type = Int

      let state: State

      var nullptr: _NodePtr { .nullptr }
      var end: _NodePtr { state.endNode }
      var __end_node: _NodePtr { state.endNode }
      var __root: _NodePtr { state.endNode.__left_ }
      var __begin_node_: _NodePtr {
        get { state.beginNode }
        nonmutating set { state.beginNode = newValue }
      }
      var __size_: Int {
        get { state.size }
        nonmutating set { state.size = newValue }
      }

      func __root_ptr() -> _NodeRef {
        state.endNode.__left_ref
      }

      func __construct_node(_ value: Int) -> _NodePtr {
        state.owned.__construct_node(value)
      }

      func destroy(_ node: _NodePtr) {
        state.owned.destroy(node)
      }

      func __key(_ value: Int) -> Int {
        value
      }

      func __get_value(_ node: _NodePtr) -> Int {
        node.__value_(as: Int.self).pointee
      }

      func value_comp(_ lhs: Int, _ rhs: Int) -> Bool {
        lhs < rhs
      }
    }

    private func values(_ tree: borrowing MutationTree) -> [Int] {
      var result: [Int] = []
      var node = tree.__begin_node_
      while node != tree.end {
        result.append(tree.__get_value(node))
        node = tree.__tree_next_iter(node)
      }
      return result
    }

    /// unique挿入がroot/begin/sizeを更新し、重複時には余分なallocationを作らないこと。
    func testUniqueInsertion_buildsValidTreeAndRejectsDuplicate() {
      let state = State()
      let tree = MutationTree(state: state)

      for value in [20, 10, 30, 5, 15, 25, 35] {
        let result = tree.__insert_unique(value)
        XCTAssertTrue(result.__inserted)
        XCTAssertEqual(tree.__get_value(result.__r), value)
        XCTAssertTrue(tree.__tree_invariant(tree.__root))
      }

      let duplicate = tree.__insert_unique(20)
      XCTAssertFalse(duplicate.__inserted)
      XCTAssertEqual(tree.__get_value(duplicate.__r), 20)
      XCTAssertEqual(tree.__size_, 7)
      XCTAssertEqual(state.owned.allocationCount, 7)
      XCTAssertEqual(values(tree), [5, 10, 15, 20, 25, 30, 35])

      _ = tree.erase(tree.__begin_node_, tree.end)
      XCTAssertEqual(tree.__size_, 0)
      XCTAssertEqual(tree.__root, .nullptr)
      XCTAssertEqual(tree.__begin_node_, tree.end)
    }

    /// multi挿入が同値要素を保持し、単体eraseと範囲eraseがpayloadを一度ずつ破棄すること。
    func testMultiInsertionAndErasure_preserveOrderAndOwnership() {
      let state = State()
      let tree = MutationTree(state: state)

      for value in [20, 10, 30, 20, 5, 25, 35, 20] {
        _ = tree.__insert_multi(value)
        XCTAssertTrue(tree.__tree_invariant(tree.__root))
      }
      XCTAssertEqual(values(tree), [5, 10, 20, 20, 20, 25, 30, 35])
      XCTAssertEqual(tree.__size_, 8)

      let first = tree.find(5)
      let successor = tree.erase(first)
      XCTAssertEqual(tree.__get_value(successor), 10)
      XCTAssertEqual(tree.__begin_node_, successor)
      XCTAssertEqual(state.owned.allocationCount, 7)
      XCTAssertTrue(tree.__tree_invariant(tree.__root))

      _ = tree.erase(tree.__begin_node_, tree.end)
      XCTAssertEqual(tree.__size_, 0)
      XCTAssertEqual(state.owned.allocationCount, 0)
      XCTAssertEqual(tree.__root, .nullptr)
      XCTAssertEqual(tree.__begin_node_, tree.end)
    }

    /// key削除が欠落時に何も変更せず、存在時には次ノードを保ったまま木を再平衡すること。
    func testEraseUnique_handlesMissingAndEachStructuralPosition() {
      let state = State()
      let tree = MutationTree(state: state)
      for value in [4, 2, 6, 1, 3, 5, 7] {
        _ = tree.__insert_unique(value)
      }

      XCTAssertFalse(tree.___erase_unique(99))
      XCTAssertEqual(tree.__size_, 7)

      for value in [1, 6, 4, 2, 3, 5, 7] {
        XCTAssertTrue(tree.___erase_unique(value))
        XCTAssertFalse(values(tree).contains(value))
        XCTAssertTrue(tree.__tree_invariant(tree.__root))
      }
      XCTAssertEqual(tree.__size_, 0)
      XCTAssertEqual(state.owned.allocationCount, 0)
      XCTAssertEqual(tree.__begin_node_, tree.end)
    }

    /// 末尾挿入位置の計算が空木と非空木で正しいparent/child参照を返すこと。
    func testMaximumReference_handlesEmptyAndNonEmptyTree() {
      let state = State()
      let tree = MutationTree(state: state)

      let emptyMaximum = tree.___max_ref()
      XCTAssertEqual(emptyMaximum.__parent, tree.end)
      XCTAssertEqual(emptyMaximum.__child, tree.end.__left_ref)

      _ = tree.__insert_unique(10)
      _ = tree.__insert_unique(30)
      let maximum = tree.___max_ref()
      XCTAssertEqual(tree.__get_value(maximum.__parent), 30)
      XCTAssertEqual(maximum.__child, maximum.__parent.__right_ref)

      _ = tree.erase(tree.__begin_node_, tree.end)
      XCTAssertEqual(state.owned.allocationCount, 0)
    }

  }
#endif
