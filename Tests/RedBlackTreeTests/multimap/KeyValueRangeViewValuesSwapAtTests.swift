import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

#if !COMPATIBLE_ATCODER_2025
  extension MultiMapTests {

    func testRangeValuesSwapAtSwapsOnlyValuesInRange() {
      var map: Target<Int, String> = [
        (0, "outside-before"),
        (1, "first"),
        (1, "middle"),
        (1, "last"),
        (2, "outside-after"),
      ]
      let range = map[1]
      let first = range.startIndex
      let last = map.index(before: range.endIndex)

      map[1].values.swapAt(first, last)

      XCTAssertEqual(map.map(\.key), [0, 1, 1, 1, 2])
      XCTAssertEqual(
        map.map(\.value),
        ["outside-before", "last", "middle", "first", "outside-after"])
    }

    func testRangeValuesSwapAtSameIndexDoesNothing() {
      var map: Target<Int, String> = [(1, "first"), (1, "last")]
      let index = map[1].startIndex

      map[1].values.swapAt(index, index)

      XCTAssertEqual(map.map(\.value), ["first", "last"])
    }

    func testRangeValuesSwapAtPreservesValueSemanticsAfterCopy() {
      var map: Target<Int, String> = [(1, "first"), (1, "middle"), (1, "last")]
      let range = map[1]
      let first = range.startIndex
      let last = map.index(before: range.endIndex)
      let copy = map

      map[1].values.swapAt(first, last)

      XCTAssertEqual(map.map(\.value), ["last", "middle", "first"])
      XCTAssertEqual(copy.map(\.value), ["first", "middle", "last"])
    }
  }
#endif
