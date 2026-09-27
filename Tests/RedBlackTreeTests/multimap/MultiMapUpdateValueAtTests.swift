import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

#if !COMPATIBLE_ATCODER_2025
  extension MultiMapTests {

    func testUpdateValueAtReplacesValueAndReturnsOldValue() {
      var map: Target<Int, String> = [1: "old"]
      let index = map.startIndex

      let oldValue = map.updateValue("new", at: index)

      XCTAssertEqual(oldValue, "old")
      XCTAssertEqual(map[index].key, 1)
      XCTAssertEqual(map[index].value, "new")
    }

    func testUpdateValueAtReplacesOnlySpecifiedDuplicatePosition() {
      var map: Target<Int, String> = [(1, "first"), (1, "middle"), (1, "last")]
      let index = map.index(after: map.startIndex)

      let oldValue = map.updateValue("new", at: index)

      XCTAssertEqual(oldValue, "middle")
      XCTAssertEqual(map.map(\.key), [1, 1, 1])
      XCTAssertEqual(map.map(\.value), ["first", "new", "last"])
    }

    func testUpdateValueAtEndIndexReturnsNilWithoutChangingMap() {
      var map: Target<Int, String> = [1: "value"]

      let oldValue = map.updateValue("new", at: map.endIndex)

      XCTAssertNil(oldValue)
      XCTAssertEqual(map.map(\.key), [1])
      XCTAssertEqual(map.map(\.value), ["value"])
    }

    func testUpdateValueAtPreservesValueSemanticsAfterCopy() {
      var map: Target<Int, String> = [1: "old"]
      let index = map.startIndex
      let copy = map

      let oldValue = map.updateValue("new", at: index)

      XCTAssertEqual(oldValue, "old")
      XCTAssertEqual(map[index].value, "new")
      XCTAssertEqual(copy[copy.startIndex].value, "old")
    }
  }
#endif
