import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

#if !COMPATIBLE_ATCODER_2025
  extension DictionaryTests {

    func testValuesSwapAtSwapsValuesWithoutChangingKeys() {
      var dictionary: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c"]
      let first = dictionary.startIndex
      let last = dictionary.index(before: dictionary.endIndex)

      dictionary.values.swapAt(first, last)

      XCTAssertEqual(dictionary.map(\.key), [1, 2, 3])
      XCTAssertEqual(dictionary.map(\.value), ["c", "b", "a"])
    }

    func testValuesSwapAtSameIndexDoesNothing() {
      var dictionary: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b"]
      let index = dictionary.startIndex

      dictionary.values.swapAt(index, index)

      XCTAssertEqual(dictionary.map(\.value), ["a", "b"])
    }

    func testValuesSwapAtPreservesValueSemanticsAfterCopy() {
      var dictionary: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c"]
      let first = dictionary.startIndex
      let last = dictionary.index(before: dictionary.endIndex)
      let copy = dictionary

      dictionary.values.swapAt(first, last)

      XCTAssertEqual(dictionary.map(\.value), ["c", "b", "a"])
      XCTAssertEqual(copy.map(\.value), ["a", "b", "c"])
    }

    func testSubrangeValuesSwapAtSwapsValuesInsideExplicitIndexRange() {
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

    func testSubrangeValuesSwapAtPreservesValueSemanticsAfterCopy() {
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
  }
#endif
