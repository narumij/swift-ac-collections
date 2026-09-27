import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

#if !COMPATIBLE_ATCODER_2025
  extension MultiMapTests {

    func testValuesSwapAtSwapsValuesWithoutChangingKeys() {
      var map: Target<Int, String> = [1: "a", 2: "b", 3: "c"]
      let first = map.startIndex
      let last = map.index(before: map.endIndex)

      map.values.swapAt(first, last)

      XCTAssertEqual(map.map(\.key), [1, 2, 3])
      XCTAssertEqual(map.map(\.value), ["c", "b", "a"])
    }

    func testValuesSwapAtDistinguishesDuplicateKeysByPosition() {
      var map: Target<Int, String> = [(1, "a"), (1, "b"), (1, "c")]
      let first = map.startIndex
      let last = map.index(first, offsetBy: 2)

      map.values.swapAt(first, last)

      XCTAssertEqual(map.map(\.key), [1, 1, 1])
      XCTAssertEqual(map.map(\.value), ["c", "b", "a"])
    }

    func testValuesSwapAtSameIndexDoesNothing() {
      var map: Target<Int, String> = [1: "a", 2: "b"]
      let index = map.startIndex

      map.values.swapAt(index, index)

      XCTAssertEqual(map.map(\.value), ["a", "b"])
    }

    func testValuesSwapAtPreservesValueSemanticsAfterCopy() {
      var map: Target<Int, String> = [1: "a", 2: "b", 3: "c"]
      let first = map.startIndex
      let last = map.index(before: map.endIndex)
      let copy = map

      map.values.swapAt(first, last)

      XCTAssertEqual(map.map(\.value), ["c", "b", "a"])
      XCTAssertEqual(copy.map(\.value), ["a", "b", "c"])
    }
  }
#endif
