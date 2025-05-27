import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class RedBlackTreeSetRemoveTests: XCTestCase {

  /// popFirst() が空セットの場合に nil を返すこと
  func test_popFirst_empty() {
    var set = RedBlackTreeSet<Int>()
    let popped = set.popFirst()
    XCTAssertNil(popped, "空セットの場合、popFirst() は nil を返すこと")
  }

  /// popFirst() が要素を正しく取り出し、セットが更新されること
  func test_popFirst_nonEmpty() {
    var set = RedBlackTreeSet([1, 2, 3])
    let popped = set.popFirst()
    XCTAssertNotNil(popped, "空でないセットでは popFirst() が要素を返すこと")
    XCTAssertTrue([1, 2, 3].contains(popped!), "取り出した要素が元のセット内の要素であること")
    XCTAssertEqual(set.count, 2, "popFirst() 実行後、要素数が 1 減少すること")
    XCTAssertFalse(set.contains(popped!), "取り出した要素はセットから削除されていること")
  }

  /// remove(_:) が指定要素を削除し、要素数が減ること
  func test_remove_element() {
    var set = RedBlackTreeSet([1, 2, 3])
    let removed = set.remove(2)
    XCTAssertEqual(removed, 2, "指定要素が存在する場合、remove(_:) はその要素を返すこと")
    XCTAssertFalse(set.contains(2), "指定要素は削除されていること")
    XCTAssertEqual(set.count, 2, "要素数が1減ること")
  }

  /// remove(_:) が存在しない要素の場合 nil を返し、セットは変化しないこと
  func test_remove_nonexistent_element() {
    var set = RedBlackTreeSet([1, 2, 3])
    let removed = set.remove(10)
    XCTAssertNil(removed, "存在しない要素の場合、remove(_:) は nil を返すこと")
    XCTAssertEqual(set.count, 3, "要素数に変化はないこと")
  }

  /// remove(at:) が指定インデックスの要素を削除すること
  func test_remove_at() {
    var set = RedBlackTreeSet([1, 2, 3])
    let index = set.index(after: set.startIndex)
    let removed = set.remove(at: index)
    XCTAssertEqual(removed, 2, "指定インデックスの要素を正しく削除すること")
    XCTAssertFalse(set.contains(2), "指定インデックスの要素は削除されること")
  }

  #if DEBUG
    /// remove(at:) が指定インデックスの要素を削除すること
    func test_remove_at_raw() {
      var set = RedBlackTreeSet([1, 2, 3])
      let index = set.index(after: set.startIndex)
      let removed = set.remove(at: RedBlackTreeSet<Int>.RawIndex.unsafe(index.rawValue))
      XCTAssertEqual(removed, 2, "指定インデックスの要素を正しく削除すること")
      XCTAssertFalse(set.contains(2), "指定インデックスの要素は削除されること")
    }
  #endif

  /// removeFirst() が最初の要素を削除すること
  func test_removeFirst() {
    var set = RedBlackTreeSet([1, 2, 3])
    let removed = set.removeFirst()
    XCTAssertEqual(removed, 1, "最初の要素を削除すること")
    XCTAssertFalse(set.contains(1), "削除後、最初の要素はセットに含まれないこと")
  }

  /// removeLast() が最後の要素を削除すること
  func test_removeLast() {
    var set = RedBlackTreeSet([1, 2, 3])
    let removed = set.removeLast()
    XCTAssertEqual(removed, 3, "最後の要素を削除すること")
    XCTAssertFalse(set.contains(3), "削除後、最後の要素はセットに含まれないこと")
  }

  /// removeSubrange() が指定範囲の要素を削除すること
  func test_removeSubrange() {
    var set = RedBlackTreeSet([1, 2, 3, 4, 5])
    let start = set.index(after: set.startIndex)
    let end = set.index(start, offsetBy: 3)
    set.removeSubrange(start..<end)
    XCTAssertEqual(set.sorted(), [1, 5], "指定範囲の要素を削除すること")
  }

  /// removeAll() がセットを空にすること
  func test_removeAll() {
    var set = RedBlackTreeSet([1, 2, 3])
    set.removeAll()
    XCTAssertTrue(set.isEmpty, "removeAll() 実行後、セットは空になること")
  }

  /// remove(contentsOf:) が指定範囲の要素を削除すること（Range版）
  func test_remove_contentsOf_Range() {
    var set = RedBlackTreeSet([1, 2, 3, 4, 5])
    set.remove(contentsOf: 2..<5)
    XCTAssertEqual(set.sorted(), [1, 5], "指定Range内の要素を削除すること")
  }

  /// remove(contentsOf:) が指定範囲の要素を削除すること（ClosedRange版）
  func test_remove_contentsOf_ClosedRange() {
    var set = RedBlackTreeSet([1, 2, 3, 4, 5])
    set.remove(contentsOf: 2...4)
    XCTAssertEqual(set.sorted(), [1, 5], "指定ClosedRange内の要素を削除すること")
  }
}

extension RedBlackTreeSetRemoveTests {

  /// removeFirstが空のときはエラーを投げること
  func test_removeFirst_throws_whenEmpty() {
    //    var set = RedBlackTreeSet<Int>()
    //    XCTAssertThrowsError({
    //      _ = set.removeFirst()
    //    }(), "removeFirst() should preconditionFailure when empty")
  }

  /// removeFirstが1要素のとき正しく動作すること
  func test_removeFirst_singleElement() {
    var set = RedBlackTreeSet([10])
    let removed = set.removeFirst()
    XCTAssertEqual(removed, 10)
    XCTAssertTrue(set.isEmpty)
  }

  /// removeFirstが複数要素のとき先頭要素を削除すること
  func test_removeFirst_multipleElements() {
    var set = RedBlackTreeSet([1, 2, 3])
    let removed = set.removeFirst()
    XCTAssertEqual(removed, 1)
    XCTAssertEqual(set.sorted(), [2, 3])
  }

  /// removeLastが空のときはエラーを投げること
  func test_removeLast_throws_whenEmpty() {
    //    var set = RedBlackTreeSet<Int>()
    //    XCTAssertThrowsError({
    //      _ = set.removeLast()
    //    }(), "removeLast() should preconditionFailure when empty")
  }

  /// removeLastが1要素のとき正しく動作すること
  func test_removeLast_singleElement() {
    var set = RedBlackTreeSet([20])
    let removed = set.removeLast()
    XCTAssertEqual(removed, 20)
    XCTAssertTrue(set.isEmpty)
  }

  /// removeLastが複数要素のとき末尾要素を削除すること
  func test_removeLast_multipleElements() {
    var set = RedBlackTreeSet([4, 5, 6])
    let removed = set.removeLast()
    XCTAssertEqual(removed, 6)
    XCTAssertEqual(set.sorted(), [4, 5])
  }
}

extension RedBlackTreeSetRemoveTests {

  /// remove後にindexが無効化されること
  func test_isValid_index_afterRemoval() {
    // 事前条件: 集合に[1, 2, 3, 4, 5]
    var set = RedBlackTreeSet([1, 2, 3, 4, 5])
    let index = set.index(after: set.startIndex)  // index pointing to element 2

    // 実行: 削除（2を削除する）
    let element = set[index]
    XCTAssertEqual(element, 2)
    _ = set.remove(element)

    // 事後条件:
    // - 削除したindexは無効になること
    XCTAssertFalse(set.isValid(index: index), "削除後、当該indexは無効になること")
  }
}

extension RedBlackTreeSetRemoveTests {

  /// SubSequence内で削除後にindexが無効化されること
  func test_isValid_index_inSubSequence_afterRemoval() {
    // 事前条件: 集合に[1, 2, 3, 4, 5]
    var set = RedBlackTreeSet([1, 2, 3, 4, 5])
    let sub = set[set.index(after: set.startIndex)..<set.index(before: set.endIndex)]  // [2,3,4]
    let subIndex = sub.startIndex  // index pointing to 2

    // 実行: 削除（2を削除する）
    let element = sub[subIndex]
    XCTAssertEqual(element, 2)
    _ = set.remove(element)

    // 事後条件:
    // - 削除したindexは無効になること
    XCTAssertFalse(sub.isValid(index: subIndex), "削除後、SubSequenceのindexは無効になること")
  }

  #if DEBUG
    /// SubSequence内で削除後にrawIndexが無効化されること
    func test_isValid_rawIndex_inSubSequence_afterRemoval() {
      // 事前条件: 集合に[1, 2, 3, 4, 5]
      var set = RedBlackTreeSet([1, 2, 3, 4, 5])
      let sub = set[set.index(after: set.startIndex)..<set.index(before: set.endIndex)]  // [2,3,4]
      let subIndex = sub.startIndex  // index pointing to 2

      // 実行: 削除（2を削除する）
      let element = sub[subIndex]
      XCTAssertEqual(element, 2)
      _ = set.remove(element)

      // 事後条件:
      // - 削除したindexは無効になること
      XCTAssertFalse(
        sub.isValid(index: RedBlackTreeSet<Int>.RawIndex.unsafe(subIndex.rawValue)),
        "削除後、SubSequenceのindexは無効になること")
    }
  #endif
}
