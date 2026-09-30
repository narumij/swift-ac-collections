import RedBlackTreeCollections
import XCTest

/// `RedBlackTreeKeyValueRangeView`(`Dictionary`/`MultiMap`のRangeViewが返す型)の仕様。
/// ジェネリックな共有Viewのため、代表としてDictionaryのインスタンスで検証する。
#if !COMPATIBLE_ATCODER_2025
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
  }
#endif
