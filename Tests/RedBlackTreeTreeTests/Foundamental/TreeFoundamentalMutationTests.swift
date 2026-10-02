import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections

  @available(anyAppleOS 26.0, *)
  final class TreeFoundamentalMutationTests: TreeTestCase {

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
      EraseUniqueProtocol, InsertLastProtocol_ptr, FindHintEqualProtocol_ptr,
      EmplaceHintUniqueProtocol_ptr, FindHintLeafProtocol_ptr, EmplaceHintMultiProtocol_ptr
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

    /// `EqualProtocol_ptr`がまだ`~Copyable`ではない現行制約のため、multi eraseだけを
    /// 同じStateへ接続するCopyableアダプター。
    private struct CopyableMultiEraseTree: _UnsafeNodePtrType, TreeAlgorithmBaseProtocol_ptr,
      TreeAlgorithmProtocol_ptr, BoundAlgorithmProtocol_legacy_ptr, EqualProtocol_ptr,
      RemoveProtocol_ptr, EraseProtocol, EraseMultiProtocol
    {
      typealias _Key = Int
      typealias __node_value_type = Int
      typealias __compare_result = __int_compare_result

      let state: State

      var nullptr: _NodePtr { .nullptr }
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

      func __get_value(_ node: _NodePtr) -> Int {
        node.__value_(as: Int.self).pointee
      }

      func value_comp(_ lhs: Int, _ rhs: Int) -> Bool {
        lhs < rhs
      }

      func __lazy_synth_three_way_comparator(
        _ lhs: borrowing Int,
        _ rhs: borrowing Int
      ) -> __int_compare_result {
        __default_three_way_comparator(lhs, rhs)
      }

      func destroy(_ node: _NodePtr) {
        state.owned.destroy(node)
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

    /// `___emplace_hint_right`が、昇順range構築の専用経路として、直前に挿入した
    /// nodeとそのright参照を次の挿入位置へ返し続けること。
    func testEmplaceHintRight_buildsAscendingRangeFromReturnedInsertionPosition() {
      let state = State()
      let tree = MutationTree(state: state)
      var position = tree.___max_ref()

      for value in 0..<8 {
        position = tree.___emplace_hint_right(position.__parent, position.__child, value)
        XCTAssertEqual(tree.__get_value(position.__parent), value)
        XCTAssertEqual(position.__child, position.__parent.__right_ref)
        XCTAssertTrue(tree.__tree_invariant(tree.__root))
      }

      XCTAssertEqual(values(tree), Array(0..<8))
      XCTAssertEqual(tree.__size_, 8)
      XCTAssertEqual(state.owned.allocationCount, 8)

      _ = tree.erase(tree.__begin_node_, tree.end)
      XCTAssertEqual(state.owned.allocationCount, 0)
    }

    /// 通常挿入で構築済みの木に対するunique hint挿入が、key指定・payload由来key・
    /// 重複時の一時allocation破棄を正しく扱うこと。
    func testHintedUniqueInsertion_handlesKeyedDerivedAndDuplicatePaths() {
      let state = State()
      let tree = MutationTree(state: state)
      _ = tree.__insert_unique(10)
      _ = tree.__insert_unique(30)

      let keyed = tree.__emplace_hint_unique(tree.end, Optional(20), 20)
      XCTAssertTrue(keyed.__inserted)
      XCTAssertEqual(tree.__get_value(keyed.__r), 20)

      let keyedDuplicate = tree.__emplace_hint_unique(keyed.__r, Optional(20), 999)
      XCTAssertFalse(keyedDuplicate.__inserted)
      XCTAssertEqual(tree.__get_value(keyedDuplicate.__r), 20)

      let derived = tree.__emplace_hint_unique(tree.end, Optional<Int>.none, 25)
      XCTAssertTrue(derived.__inserted)
      let derivedDuplicate = tree.__emplace_hint_unique(derived.__r, Optional<Int>.none, 25)
      XCTAssertFalse(derivedDuplicate.__inserted)
      XCTAssertEqual(state.owned.allocationCount, 4)

      let split = tree.___emplace_hint_unique_(tree.end, 27, 27)
      XCTAssertTrue(split.__inserted)
      let splitDuplicate = tree.___emplace_hint_unique_(split.__r, 27, 1_000)
      XCTAssertFalse(splitDuplicate.__inserted)

      let multi = tree.__emplace_hint_multi(split.__r, 25)
      XCTAssertEqual(tree.__get_value(multi), 25)

      XCTAssertEqual(values(tree), [10, 20, 25, 25, 27, 30])
      XCTAssertTrue(tree.__tree_invariant(tree.__root))
      _ = tree.erase(tree.__begin_node_, tree.end)
      XCTAssertEqual(state.owned.allocationCount, 0)
    }

    /// multi key削除が同値範囲だけを破棄し、削除数と残存順序を保つこと。
    func testEraseMulti_removesEntireEquivalentRange() {
      let state = State()
      let mutation = MutationTree(state: state)
      for value in [20, 10, 20, 30, 20, 25] {
        _ = mutation.__insert_multi(value)
      }
      let eraser = CopyableMultiEraseTree(state: state)

      XCTAssertEqual(eraser.___erase_multi(99), 0)
      XCTAssertEqual(eraser.___erase_multi(20), 3)
      XCTAssertEqual(values(mutation), [10, 25, 30])
      XCTAssertEqual(mutation.__size_, 3)
      XCTAssertEqual(state.owned.allocationCount, 3)
      XCTAssertTrue(mutation.__tree_invariant(mutation.__root))

      _ = mutation.erase(mutation.__begin_node_, mutation.end)
      XCTAssertEqual(state.owned.allocationCount, 0)
    }

  }
#endif
