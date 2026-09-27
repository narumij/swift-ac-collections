import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

#if !COMPATIBLE_ATCODER_2025
  extension MultiMapTests {

    func testSwapValueAt() {
      var map: Target<Int, String> = [1: "a", 2: "b", 3: "c"]
      let first = map.firstIndex(of: 1)!
      let last = map.firstIndex(of: 3)!

      map.swapValueAt(first, last)

      XCTAssertEqual(map[first].key, 1)
      XCTAssertEqual(map[first].value, "c")
      XCTAssertEqual(map[last].key, 3)
      XCTAssertEqual(map[last].value, "a")
      XCTAssertEqual(map.map(\.key), [1, 2, 3])
      XCTAssertEqual(map.map(\.value), ["c", "b", "a"])
    }

    func testSwapValueAtSameIndexDoesNothing() {
      var map: Target<Int, String> = [1: "a", 2: "b"]
      let index = map.firstIndex(of: 1)!

      map.swapValueAt(index, index)

      XCTAssertEqual(map.map(\.key), [1, 2])
      XCTAssertEqual(map.map(\.value), ["a", "b"])
    }

    func testSwapValueAtDistinguishesEqualKeysByPosition() {
      var map: Target<Int, String> = [(1, "a"), (1, "b"), (1, "c")]
      let first = map.startIndex
      let last = map.index(first, offsetBy: 2)

      map.swapValueAt(first, last)

      XCTAssertEqual(map.map(\.key), [1, 1, 1])
      XCTAssertEqual(map.map(\.value), ["c", "b", "a"])
    }

    func testSwapValueAtPreservesValueSemanticsAfterCopy() {
      var map: Target<Int, String> = [1: "a", 2: "b", 3: "c"]
      let first = map.firstIndex(of: 1)!
      let last = map.firstIndex(of: 3)!
      let copy = map

      map.swapValueAt(first, last)

      XCTAssertEqual(map.map(\.value), ["c", "b", "a"])
      XCTAssertEqual(copy.map(\.value), ["a", "b", "c"])
      XCTAssertEqual(map[first].value, "c")
      XCTAssertEqual(map[last].value, "a")
    }
  }
#endif
