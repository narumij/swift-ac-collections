import RedBlackTreeCollections
import XCTest

/// `RedBlackTreeKeyValueRangeView`(`Dictionary`/`MultiMap`のRangeViewが返す型)の仕様。
/// ジェネリックな共有Viewのため、代表としてDictionaryのインスタンスで検証する。
  final class RedBlackTreeKeyValueRangeViewTests: RedBlackTreeTestCase {

    func test_sorted_returnsElementsAlreadyInKeyOrder() {
      let dictionary: RedBlackTreeDictionary = [3: "c", 1: "a", 2: "b"]
      let view = dictionary[...]

      XCTAssertEqual(view.sorted().map(\.key), [1, 2, 3])
    }

    func test_keys_returnsJustTheKeysInOrder() {
      let dictionary: RedBlackTreeDictionary = [3: "c", 1: "a", 2: "b"]
      let view = dictionary[...]

      XCTAssertEqual(Array(view.keys), [1, 2, 3])
    }

    func test_values_returnsJustTheValuesInKeyOrder() {
      let dictionary: RedBlackTreeDictionary = [3: "c", 1: "a", 2: "b"]
      let view = dictionary[...]

      XCTAssertEqual(Array(view.values), ["a", "b", "c"])
    }

    func test_isElementAndIsEnd_respectViewBounds() {
      let dictionary = RedBlackTreeDictionary<Int, String>(
        uniqueKeysWithValues: (0..<5).map { ($0, "\($0)") })
      let lower = dictionary.index(after: dictionary.startIndex)
      let inside = dictionary.index(after: lower)
      let upper = dictionary.index(before: dictionary.endIndex)
      let view = dictionary[lower..<upper]

      XCTAssertFalse(view.isElement(at: dictionary.startIndex))
      XCTAssertTrue(view.isElement(at: lower))
      XCTAssertTrue(view.isElement(at: inside))
      XCTAssertFalse(view.isElement(at: upper))
      XCTAssertFalse(view.isElement(at: dictionary.endIndex))

      XCTAssertFalse(view.isEnd(lower))
      XCTAssertTrue(view.isEnd(upper))
      XCTAssertFalse(view.isEnd(dictionary.endIndex))
    }

    func test_removeFirstAndRemoveLast_removeEndpointsAndReturnRemovedElement() {
      var dictionary: RedBlackTreeDictionary = [1: "a", 2: "b", 3: "c"]

      XCTAssertEqual(dictionary[...].removeFirst().key, 1)
      XCTAssertEqual(dictionary.map(\.key), [2, 3])

      XCTAssertEqual(dictionary[...].removeLast().key, 3)
      XCTAssertEqual(dictionary.map(\.key), [2])
    }

    /// 空のビューに対する削除系操作は、トラップしない以上、無駄なCoW
    /// (共有される空シングルトンバッファからの退避)も発生させないこと。
    func test_removalMethods_onEmptyView_doNotTriggerCopyOnWrite() {
      #if AC_COLLECTIONS_INTERNAL_CHECKS
        var empty = RedBlackTreeDictionary<Int, String>()
        XCTAssertEqual(empty._copyCount, 0)

        XCTAssertNil(empty[...].popFirst())
        XCTAssertEqual(empty._copyCount, 0)

        XCTAssertNil(empty[...].popLast())
        XCTAssertEqual(empty._copyCount, 0)

        empty[...].erase()
        XCTAssertEqual(empty._copyCount, 0)

        empty[...].erase(where: { _ in true })
        XCTAssertEqual(empty._copyCount, 0)
      #endif
    }

    func test_eraseWhere_onStandaloneViewRemovesOnlyMatchingElements() {
      var dictionary: RedBlackTreeDictionary = [1: "a", 2: "b", 3: "c", 4: "d"]

      dictionary[...].erase(where: { $0.key.isMultiple(of: 2) })

      XCTAssertEqual(dictionary.map(\.key), [1, 3])
    }

    func test_elementsEqual_trueForSameKeyValuePairsInKeyOrder() {
      let a: RedBlackTreeDictionary = [1: "a", 2: "b"]
      let b: RedBlackTreeDictionary = [2: "b", 1: "a"]

      XCTAssertTrue(a[...].elementsEqual(b[...], by: ==))
    }

    func test_lexicographicallyPrecedes_comparesLengthAfterCommonPrefix() {
      let shorter: RedBlackTreeDictionary = [1: "a"]
      let longer: RedBlackTreeDictionary = [1: "a", 2: "b"]

      XCTAssertTrue(shorter[...].lexicographicallyPrecedes(longer[...], by: <))
      XCTAssertFalse(longer[...].lexicographicallyPrecedes(shorter[...], by: <))
    }

    /// popFirst/popLast/erase()/erase(where:)が、保持していた参照型の値を
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

      _ = dictionary[...].popFirst()
      XCTAssertEqual(DeinitializeCounter.count, 3)

      _ = dictionary[...].popLast()
      XCTAssertEqual(DeinitializeCounter.count, 2)

      dictionary[...].erase(where: { $0.key == 1 })
      XCTAssertEqual(DeinitializeCounter.count, 1)

      _ = dictionary[...].erase()
      XCTAssertEqual(DeinitializeCounter.count, 0)
    }

    /// `elementsEqual(_:)`はキーと値の組を順に比べ、`lexicographicallyPrecedes(_:)`は辞書順で比べること。
    func test_elementsEqualAndLexicographicallyPrecedes_compareKeyValuePairsInOrder() {
      let dictionary: RedBlackTreeDictionary = [1: "a", 2: "b", 3: "c"]
      let view = dictionary[...]
      XCTAssertTrue(view.elementsEqual([(key: 1, value: "a"), (key: 2, value: "b"), (key: 3, value: "c")]))
      XCTAssertFalse(view.elementsEqual([(key: 1, value: "a"), (key: 2, value: "x"), (key: 3, value: "c")]))
      XCTAssertFalse(view.elementsEqual([(key: 1, value: "a")]))
      XCTAssertTrue(view.lexicographicallyPrecedes([(key: 1, value: "a"), (key: 2, value: "c")]))
      XCTAssertFalse(view.lexicographicallyPrecedes([(key: 1, value: "a"), (key: 2, value: "b"), (key: 3, value: "c")]))
      XCTAssertTrue(view.lexicographicallyPrecedes([(key: 1, value: "a"), (key: 2, value: "b"), (key: 3, value: "c"), (key: 4, value: "d")]))
    }
  }
