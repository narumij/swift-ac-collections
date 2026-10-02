import RedBlackTreeCollections
import XCTest

final class RedBlackTreeDictionaryRemovalTests: RedBlackTreeTestCase {

  func test_removeValueForKey_returnsRemovedValue() {
    var dictionary: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c"]

    XCTAssertNil(dictionary.removeValue(forKey: 0))
    XCTAssertEqual(dictionary.removeValue(forKey: 2), "b")
    XCTAssertEqual(dictionary.map(\.key), [1, 3])
  }

  func test_removeAt_removesSelectedEntry() {
    var dictionary: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c"]
    let index = dictionary.firstIndex(of: 2)!

    let removed = dictionary.remove(at: index)

    XCTAssertEqual(removed.key, 2)
    XCTAssertEqual(removed.value, "b")
    XCTAssertEqual(dictionary.map(\.key), [1, 3])
  }

  #if !COMPATIBLE_ATCODER_2025
    func test_erase_returnsTheFollowingIndex() {
      var dictionary: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c"]
      let removed = dictionary.firstIndex(of: 2)!

      let next = dictionary.erase(removed)

      XCTAssertEqual(dictionary[next].key, 3)
      XCTAssertEqual(dictionary.map(\.key), [1, 3])
    }

    func test_eraseWhere_removesEveryMatchingEntry() {
      var dictionary: RedBlackTreeDictionary<Int, String> = [
        1: "keep",
        2: "remove",
        3: "keep",
        4: "remove",
      ]

      dictionary.erase { $0.key.isMultiple(of: 2) }

      XCTAssertEqual(dictionary.map(\.key), [1, 3])
    }
  #endif

  func test_popFirst_returnsNilOrRemovesLowestKey() {
    var empty = RedBlackTreeDictionary<Int, String>()
    var dictionary: RedBlackTreeDictionary<Int, String> = [3: "c", 1: "a", 2: "b"]

    XCTAssertNil(empty.popFirst())
    XCTAssertEqual(dictionary.popFirst()?.key, 1)
    XCTAssertEqual(dictionary.map(\.key), [2, 3])
  }

  /// 空の辞書への削除操作はトラップしない以上、無駄なCoW(共有される空シングルトン
  /// バッファからの退避)も発生させないこと。
  func test_removalMethods_onEmptyDictionary_doNotTriggerCopyOnWrite() {
    #if AC_COLLECTIONS_INTERNAL_CHECKS
      var empty = RedBlackTreeDictionary<Int, String>()
      XCTAssertEqual(empty._copyCount, 0)

      XCTAssertNil(empty.popFirst())
      XCTAssertEqual(empty._copyCount, 0)

      #if !COMPATIBLE_ATCODER_2025
        XCTAssertNil(empty.popLast())
        XCTAssertEqual(empty._copyCount, 0)
      #endif

      XCTAssertNil(empty.removeValue(forKey: 1))
      XCTAssertEqual(empty._copyCount, 0)

      empty.removeAll(keepingCapacity: true)
      XCTAssertEqual(empty._copyCount, 0, "空の辞書へのremoveAll(keepingCapacity: true)は退避コピーを発生させないはず")
    #endif
  }

  func test_removeFirstAndRemoveLast_followKeyOrder() {
    var dictionary: RedBlackTreeDictionary<Int, String> = [3: "c", 1: "a", 2: "b"]

    XCTAssertEqual(dictionary.removeFirst().key, 1)
    XCTAssertEqual(dictionary.removeLast().key, 3)
    XCTAssertEqual(dictionary.first?.key, 2)
    XCTAssertEqual(dictionary.last?.key, 2)
  }

  func test_removeAll_clearsEntriesAndHonorsCapacityChoice() {
    var keepingCapacity = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<10).map { ($0, $0) })
    let originalCapacity = keepingCapacity.capacity

    keepingCapacity.removeAll(keepingCapacity: true)
    XCTAssertTrue(keepingCapacity.isEmpty)
    XCTAssertEqual(keepingCapacity.capacity, originalCapacity)

    var releasingCapacity = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<10).map { ($0, $0) })
    releasingCapacity.removeAll()
    XCTAssertTrue(releasingCapacity.isEmpty)
  }

  /// popFirst/popLast/removeValue(forKey:)/removeAllが、保持していた参照型の値を
  /// 正しく解放すること(二重解放やリークがないこと)
  func test_variousRemovalMethods_releaseRetainedReferenceValuesExactlyOnce() {
    final class DeinitializeCounter {
      nonisolated(unsafe) static var count = 0
      init() { Self.count += 1 }
      deinit { Self.count -= 1 }
    }

    var dictionary = RedBlackTreeDictionary<Int, DeinitializeCounter>(
      uniqueKeysWithValues: (0..<4).map { ($0, DeinitializeCounter()) })
    XCTAssertEqual(DeinitializeCounter.count, 4)

    _ = dictionary.popFirst()
    XCTAssertEqual(DeinitializeCounter.count, 3)

    #if !COMPATIBLE_ATCODER_2025
      _ = dictionary.popLast()
      XCTAssertEqual(DeinitializeCounter.count, 2)
    #endif

    _ = dictionary.removeValue(forKey: 1)
    #if COMPATIBLE_ATCODER_2025
      XCTAssertEqual(DeinitializeCounter.count, 2)
    #else
      XCTAssertEqual(DeinitializeCounter.count, 1)
    #endif

    dictionary.removeAll()
    XCTAssertEqual(DeinitializeCounter.count, 0)
  }

  #if false
    // これはつかわないこと。
    // 既知の未修正バグの再現テスト(TESTING.mdの「保留中の判断・懸念」2026-10-03 JST参照)。
    // subscript(key:)への nil 代入は、Valueが参照型の場合に二重解放でクラッシュする
    // (.move()済みのValueを、erase側のpushRecycleが再度deinitializeしてしまうため)。
    // 修正されるまで有効化しないこと。有効化するとプロセスがSIGTRAPで落ち、テストスイート全体が完走しない。
    func test_subscriptAssignNil_releasesRetainedReferenceValue_knownBug() {
      final class DeinitializeCounter {
        nonisolated(unsafe) static var count = 0
        init() { Self.count += 1 }
        deinit { Self.count -= 1 }
      }

      var dictionary = RedBlackTreeDictionary<Int, DeinitializeCounter>(
        uniqueKeysWithValues: (0..<3).map { ($0, DeinitializeCounter()) })
      XCTAssertEqual(DeinitializeCounter.count, 3)

      dictionary[1] = nil

      XCTAssertEqual(DeinitializeCounter.count, 2)
    }
  #endif
}
