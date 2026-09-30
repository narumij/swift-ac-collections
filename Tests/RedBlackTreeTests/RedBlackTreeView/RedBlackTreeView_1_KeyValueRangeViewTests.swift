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

    func test_eraseWhere_onStandaloneViewRemovesOnlyMatchingElements() {
      var dictionary: RedBlackTreeDictionary = [1: "a", 2: "b", 3: "c", 4: "d"]

      dictionary[...].erase(where: { $0.key.isMultiple(of: 2) })

      XCTAssertEqual(dictionary.map(\.key), [1, 3])
    }
  }
#endif
