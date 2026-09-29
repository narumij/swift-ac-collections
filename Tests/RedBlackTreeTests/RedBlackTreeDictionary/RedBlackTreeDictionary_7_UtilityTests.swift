import RedBlackTreeCollections
import XCTest

final class RedBlackTreeDictionaryUtilityTests: RedBlackTreeTestCase {

  func test_keysAndValues_followKeyOrder() {
    let dictionary: RedBlackTreeDictionary = [3: "c", 1: "a", 2: "b"]

    #if !COMPATIBLE_ATCODER_2025
      // TODO: これは変だから調査が必要
      XCTAssertEqual(Array(dictionary.keys), [1, 2, 3])
      XCTAssertEqual(Array(dictionary.values), ["a", "b", "c"])
    #endif
  }

  func test_mapValues_transformsValuesAndPreservesKeys() {
    let dictionary: RedBlackTreeDictionary = [1: 10, 2: 20]

    let result = dictionary.mapValues { "value=\($0)" }

    XCTAssertEqual(result[1], "value=10")
    XCTAssertEqual(result[2], "value=20")
    XCTAssertEqual(result.map(\.key), [1, 2])
  }

  func test_compactMapValues_omitsNilResults() {
    let dictionary: RedBlackTreeDictionary = [1: 10, 2: 20, 3: 30]

    let result = dictionary.compactMapValues { $0 >= 20 ? String($0) : nil }

    XCTAssertNil(result[1])
    XCTAssertEqual(result[2], "20")
    XCTAssertEqual(result[3], "30")
  }

  func test_filter_returnsDictionaryContainingMatchingEntries() {
    let dictionary: RedBlackTreeDictionary = [1: "a", 2: "b", 3: "c", 4: "d"]

    let result = dictionary.filter { $0.key.isMultiple(of: 2) }

    XCTAssertEqual(result.map(\.key), [2, 4])
    XCTAssertEqual(result[2], "b")
    XCTAssertEqual(result[4], "d")
  }

  func test_copyOnWrite_mutatingCopyPreservesOriginal() {
    let original: RedBlackTreeDictionary = [1: "a", 2: "b"]
    var copy = original

    copy[2] = "changed"
    copy[3] = "c"

    XCTAssertEqual(original[2], "b")
    XCTAssertNil(original[3])
    XCTAssertEqual(copy[2], "changed")
    XCTAssertEqual(copy[3], "c")
  }

  #if !COMPATIBLE_ATCODER_2025
    func test_valuesSwapAt_swapsValuesWithoutChangingKeys() {
      var dictionary: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c"]
      let first = dictionary.startIndex
      let last = dictionary.index(before: dictionary.endIndex)

      dictionary.values.swapAt(first, last)

      XCTAssertEqual(dictionary.map(\.key), [1, 2, 3])
      XCTAssertEqual(dictionary.map(\.value), ["c", "b", "a"])
    }

    func test_valuesSwapAt_sameIndexDoesNothing() {
      var dictionary: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b"]
      let index = dictionary.startIndex

      dictionary.values.swapAt(index, index)

      XCTAssertEqual(dictionary.map(\.value), ["a", "b"])
    }

    func test_valuesSwapAt_preservesValueSemanticsAfterCopy() {
      var dictionary: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c"]
      let first = dictionary.startIndex
      let last = dictionary.index(before: dictionary.endIndex)
      let copy = dictionary

      dictionary.values.swapAt(first, last)

      XCTAssertEqual(dictionary.map(\.value), ["c", "b", "a"])
      XCTAssertEqual(copy.map(\.value), ["a", "b", "c"])
    }

    func test_subrangeValuesSwapAt_swapsValuesInsideExplicitIndexRange() {
      var dictionary: RedBlackTreeDictionary<Int, String> = [
        1: "outside-before",
        2: "first",
        3: "middle",
        4: "last",
        5: "outside-after",
      ]
      let lower = dictionary.index(dictionary.startIndex, offsetBy: 1)
      let upper = dictionary.index(dictionary.startIndex, offsetBy: 4)
      let last = dictionary.index(before: upper)

      dictionary[lower..<upper].values.swapAt(lower, last)

      XCTAssertEqual(dictionary.map(\.key), [1, 2, 3, 4, 5])
      XCTAssertEqual(
        dictionary.map(\.value),
        ["outside-before", "last", "middle", "first", "outside-after"])
    }

    func test_subrangeValuesSwapAt_preservesValueSemanticsAfterCopy() {
      var dictionary: RedBlackTreeDictionary<Int, String> = [
        1: "outside-before",
        2: "first",
        3: "last",
        4: "outside-after",
      ]
      let lower = dictionary.index(dictionary.startIndex, offsetBy: 1)
      let upper = dictionary.index(dictionary.startIndex, offsetBy: 3)
      let last = dictionary.index(before: upper)
      let copy = dictionary

      dictionary[lower..<upper].values.swapAt(lower, last)

      XCTAssertEqual(
        dictionary.map(\.value),
        ["outside-before", "last", "first", "outside-after"])
      XCTAssertEqual(
        copy.map(\.value),
        ["outside-before", "first", "last", "outside-after"])
    }
  #endif
}
