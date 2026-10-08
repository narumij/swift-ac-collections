import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiMapRemovalTests: RedBlackTreeTestCase {

  func test_popFirstAndPopLast_removeOneExtremeEntry() {
    var map: RedBlackTreeMultiMap = [(1, "a"), (1, "b"), (2, "c"), (3, "d")]

    XCTAssertEqual(map.popFirst()?.value, "a")
    #if !COMPATIBLE_ATCODER_2025
      XCTAssertEqual(map.popLast()?.value, "d")
      XCTAssertEqual(map.map(\.value), ["b", "c"])
    #endif

    var empty = RedBlackTreeMultiMap<Int, String>()
    XCTAssertNil(empty.popFirst())
    #if !COMPATIBLE_ATCODER_2025
      XCTAssertNil(empty.popLast())
    #endif
  }

  /// 空のMultiMapへの削除操作はトラップしない以上、無駄なCoW(共有される空
  /// シングルトンバッファからの退避)も発生させないこと。
  func test_popFirstAndPopLast_onEmptyMultiMap_doNotTriggerCopyOnWrite() {
    #if AC_COLLECTIONS_INTERNAL_CHECKS
      var empty = RedBlackTreeMultiMap<Int, String>()
      XCTAssertEqual(empty._copyCount, 0)

      XCTAssertNil(empty.popFirst())
      XCTAssertEqual(empty._copyCount, 0)

      #if !COMPATIBLE_ATCODER_2025
        XCTAssertNil(empty.popLast())
        XCTAssertEqual(empty._copyCount, 0)
      #endif

      empty.removeAll(keepingCapacity: true)
      XCTAssertEqual(empty._copyCount, 0, "空のMultiMapへのremoveAll(keepingCapacity: true)は退避コピーを発生させないはず")

      #if !COMPATIBLE_ATCODER_2025
        var predicateCalled = false
        empty.erase(where: { _ in
          predicateCalled = true
          return true
        })
        XCTAssertFalse(predicateCalled, "空のMultiMapへのerase(where:)は述語を呼ばないはず")
        XCTAssertEqual(empty._copyCount, 0, "空のMultiMapへのerase(where:)は退避コピーを発生させないはず")
      #endif
    #endif
  }

  func test_removeFirstAndRemoveLast_followKeyOrder() {
    var map: RedBlackTreeMultiMap = [(1, "a"), (1, "b"), (2, "c"), (3, "d")]

    XCTAssertEqual(map.removeFirst().value, "a")
    XCTAssertEqual(map.removeLast().value, "d")
    XCTAssertEqual(map.map(\.value), ["b", "c"])
  }

  #if !COMPATIBLE_ATCODER_2025
    func test_removeAt_removesOnlyTheSelectedDuplicate() {
      var map: RedBlackTreeMultiMap = [(1, "a"), (1, "b"), (1, "c"), (2, "d")]
      let middle = map.index(after: map.startIndex)

      let removed = map.remove(at: middle)

      XCTAssertEqual(removed.key, 1)
      XCTAssertEqual(removed.value, "b")
      XCTAssertEqual(map.map(\.value), ["a", "c", "d"])
    }

    func test_eraseUnique_removesOneEntryForKey() {
      var map: RedBlackTreeMultiMap = [(1, "a"), (1, "b"), (2, "c")]

      XCTAssertTrue(map.eraseUnique(1))
      XCTAssertEqual(map.count(forKey: 1), 1)
      XCTAssertFalse(map.eraseUnique(3))
    }

    func test_eraseMulti_removesEveryEntryForKey() {
      var map: RedBlackTreeMultiMap = [(1, "a"), (1, "b"), (2, "c")]

      XCTAssertEqual(map.eraseMulti(1), 2)
      XCTAssertEqual(map.map(\.key), [2])
      XCTAssertEqual(map.eraseMulti(1), 0)
    }

    func test_eraseWhere_removesEveryMatchingEntry() {
      var map: RedBlackTreeMultiMap = [(1, "a"), (1, "b"), (2, "c"), (3, "d")]

      map.erase { $0.key.isMultiple(of: 2) || $0.value == "b" }

      XCTAssertEqual(map.map(\.value), ["a", "d"])
    }
  #endif

  func test_removeAll_clearsEntriesAndHonorsCapacityChoice() {
    var keepingCapacity = RedBlackTreeMultiMap(keysWithValues: (0..<10).map { ($0, $0) })
    let originalCapacity = keepingCapacity.capacity

    keepingCapacity.removeAll(keepingCapacity: true)
    XCTAssertTrue(keepingCapacity.isEmpty)
    XCTAssertEqual(keepingCapacity.capacity, originalCapacity)

    var releasingCapacity = RedBlackTreeMultiMap(keysWithValues: (0..<10).map { ($0, $0) })
    releasingCapacity.removeAll()
    XCTAssertTrue(releasingCapacity.isEmpty)
  }

  /// popFirst/popLast/eraseMulti/removeAllが、保持していた参照型の値(重複キーを含む)を
  /// 正しく解放すること(二重解放やリークがないこと)
  func test_variousRemovalMethods_releaseRetainedReferenceValuesExactlyOnce() {
    final class DeinitializeCounter {
      nonisolated(unsafe) static var count = 0
      init() { Self.count += 1 }
      deinit { Self.count -= 1 }
    }

    var map = RedBlackTreeMultiMap<Int, DeinitializeCounter>(
      keysWithValues: [1, 1, 2, 3, 3].map { ($0, DeinitializeCounter()) })
    XCTAssertEqual(DeinitializeCounter.count, 5)

    _ = map.popFirst()
    XCTAssertEqual(DeinitializeCounter.count, 4)

    #if !COMPATIBLE_ATCODER_2025
      _ = map.popLast()
      XCTAssertEqual(DeinitializeCounter.count, 3)
    #endif

    #if !COMPATIBLE_ATCODER_2025
      let erasedCount = map.eraseMulti(3)
      XCTAssertEqual(erasedCount, 1)
      XCTAssertEqual(DeinitializeCounter.count, 2, "キー検索に値の一時生成は不要なので、削除された分だけ減ること")
    #endif

    map.removeAll()
    XCTAssertEqual(DeinitializeCounter.count, 0)
  }
}

#if !COMPATIBLE_ATCODER_2025
  import RedBlackTreeCollections
  import XCTest

  final class RedBlackTreeMultiMapEraseIndexTests: RedBlackTreeTestCase {

    /// `erase(_:)`はIndexの位置の組を取り除き、その次の位置を返すこと。
    func testEraseIndexReturnsFollowingIndex() {
      var m = RedBlackTreeMultiMap<Int, String>(keysWithValues: [(1, "a"), (2, "b"), (2, "c"), (3, "d")])
      let next = m.erase(m.index(after: m.startIndex))
      XCTAssertEqual(m[next].value, "c")
      XCTAssertEqual(m.map(\.value), ["a", "c", "d"])
      let last = m.erase(m.index(before: m.endIndex))
      XCTAssertEqual(last, m.endIndex)
    }
  }
#endif
