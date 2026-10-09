#if DEBUG
  @testable import RedBlackTreeCollections
  import XCTest

  final class RedBlackTreeSetRemovalInternalXCTests: RedBlackTreeTestCase, _UnsafeNodePtrType {

    func testUncheckedRemovalAdvancesTheBeginNodeUntilEmpty() {
      var set = RedBlackTreeSet(0..<5)

      for expected in 0..<5 {
        let removed = set.__tree_._unchecked_remove(at: set.__tree_.__begin_node_)
        XCTAssertEqual(removed.payload, expected)
        XCTAssertEqual(set + [], Array((expected + 1)..<5))
      }

      XCTAssertTrue(set.isEmpty)
    }

    func testEmplaceHintUniqueInsertsNewKeyRejectsDuplicateThenInsertsAnotherNewKey() {
      var set = RedBlackTreeSet<Int>(0..<10)
      set.__tree_.ensureCapacity()

      let hint = set._start

      // 新規挿入
      do {
        let (h, inserted) = set.__tree_.__emplace_hint_unique(hint, nil, -1)
        XCTAssertTrue(inserted)
        XCTAssertEqual(set.__tree_.__get_value(h), -1)
        XCTAssertEqual(set.count, 11)
        XCTAssertTrue(set.contains(-1))
      }

      // 重複
      do {
        let (h, inserted) = set.__tree_.__emplace_hint_unique(hint, nil, -1)
        XCTAssertFalse(inserted)
        XCTAssertEqual(set.__tree_.__get_value(h), -1)
        XCTAssertEqual(set.count, 11)
      }

      // 別の新規挿入
      do {
        let (h, inserted) = set.__tree_.__emplace_hint_unique(hint, nil, -2)
        XCTAssertTrue(inserted)
        XCTAssertEqual(set.__tree_.__get_value(h), -2)
        XCTAssertEqual(set.count, 12)
        XCTAssertTrue(set.contains(-2))
      }
    }

    func testFindEqualWithHintCoversEveryBranch() {
      let nullnode = _NodePtr.nullptr.pointee

      var set = RedBlackTreeSet<Int>(stride(from: 0, through: 90, by: 10))
      set.__tree_.ensureCapacity()

      let tree = set.__tree_

      func node(_ key: Int) -> _NodePtr {
        let (_, child) = tree.__find_equal(key)
        XCTAssertNotEqual(child.pointee, tree.nullptr)
        return child.pointee
      }

      var dummy = tree.nullptr

      func find(_ hint: _NodePtr, _ value: Int) -> (_NodePtr, _NodeRef, _NodePtr) {
        dummy = .nullptr
        let (parent, child) = tree.__find_equal(hint, &dummy, value)
        XCTAssertEqual(tree.nullptr.pointee, nullnode)
        return (parent, child, dummy)
      }

      // v == *hint
      do {
        let hint = node(40)
        let (parent, child, dummy) = find(hint, 40)
        XCTAssertEqual(parent, hint)
        XCTAssertEqual(child.pointee, hint)
        XCTAssertEqual(dummy, hint)
      }

      // before: hint == begin → prior == begin → hint.left == nullptr
      do {
        let hint = node(0)
        let (_, child, _) = find(hint, -5)
        XCTAssertEqual(child.pointee, tree.nullptr)
      }

      // before: prev < v < hint, hint.left != nullptr → return (prior, prior.right)
      do {
        let hint = stride(from: 0, through: 90, by: 10)
          .map(node)
          .first { $0.__left_ != tree.nullptr }!
        let prior = tree.__tree_prev_iter(hint)
        let value = (tree.__get_value(prior) + tree.__get_value(hint)) / 2

        let (parent, child, _) = find(hint, value)
        XCTAssertEqual(parent, prior)
        XCTAssertEqual(child.pointee, tree.nullptr)
      }

      // before: v <= prev(hint) → fallback __find_equal(v)
      do {
        let hint = node(50)
        let (_, child, _) = find(hint, 5)
        XCTAssertEqual(child.pointee, tree.nullptr)
      }

      // after: hint == maximum → next == end → hint.right == nullptr
      do {
        let hint = node(90)
        let (_, child, _) = find(hint, 95)
        XCTAssertEqual(child.pointee, tree.nullptr)
      }

      // after: hint < v < next, hint.right != nullptr → return (next, next.left)
      do {
        let hint = stride(from: 0, through: 90, by: 10)
          .map(node)
          .first { $0.__right_ != tree.nullptr }!
        let next = tree.__tree_next_iter(hint)
        let value = (tree.__get_value(hint) + tree.__get_value(next)) / 2

        let (parent, child, _) = find(hint, value)
        XCTAssertEqual(parent, next)
        XCTAssertEqual(child.pointee, tree.nullptr)
      }

      // after: next <= v → fallback __find_equal(v)
      do {
        let hint = node(40)
        let (_, child, _) = find(hint, 85)
        XCTAssertEqual(child.pointee, tree.nullptr)
      }

      // hint == end
      do {
        let (_, child, _) = find(tree.end, 95)
        XCTAssertEqual(child.pointee, tree.nullptr)
      }
    }

    /// 挿入・削除を繰り返しても、破棄済みスロットが再利用されバケットが増えないこと
    func testRepeatedInsertAndRemoveReusesSlotsWithoutGrowingFreshPool() {
      var set = RedBlackTreeSet<Int>(minimumCapacity: 100)

      for _ in 0..<1000 {
        for i in 0..<100 {
          set.insert(i)
        }
        for i in 0..<100 {
          set.remove(i)
        }
      }

      XCTAssertEqual(set.__tree_._buffer.header.freshBucketHead?.pointee.count, 100)
      XCTAssertEqual(set.capacity, 100)
    }

    /// removeAll(keepingCapacity: true)がバケット自体を保持したまま再利用可能な状態に戻すこと
    func testRemoveAllKeepingCapacityPreservesFreshBucketForReuse() {
      var set = RedBlackTreeSet<Int>(minimumCapacity: 100)
      let head = set.__tree_._buffer.header.freshBucketHead
      XCTAssertEqual(set.__tree_._buffer.header.freshPoolActualCapacity, 100)

      for i in 0..<100 {
        set.insert(i)
      }
      for i in 0..<100 {
        set.remove(i)
      }
      XCTAssertEqual(set.__tree_._buffer.header.freshPoolActualCapacity, 100)

      set.removeAll(keepingCapacity: true)
      XCTAssertEqual(set.__tree_._buffer.header.freshPoolActualCapacity, 100)
      XCTAssertEqual(set.__tree_._buffer.header.freshBucketHead, head)
      XCTAssertEqual(set.capacity, 100)
    }

    /// removeAll(keepingCapacity: false)がバケットを解放し、容量0の状態に戻すこと
    func testRemoveAllWithoutKeepingCapacityReleasesFreshBucket() {
      var set = RedBlackTreeSet<Int>()
      let head = set.__tree_._buffer.header.freshBucketHead
      XCTAssertEqual(set.__tree_._buffer.header.freshPoolActualCapacity, 0)

      for i in 0..<100 {
        set.insert(i)
      }
      for i in 0..<100 {
        set.remove(i)
      }
      set.removeAll(keepingCapacity: false)

      XCTAssertEqual(set.__tree_._buffer.header.freshPoolActualCapacity, 0)
      XCTAssertEqual(set.__tree_._buffer.header.freshBucketHead, head)
      XCTAssertEqual(set.capacity, 0)
    }
  }
#endif
