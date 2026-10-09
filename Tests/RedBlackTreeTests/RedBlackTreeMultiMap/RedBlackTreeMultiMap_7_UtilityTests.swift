import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiMapUtilityTests: RedBlackTreeTestCase {

  func test_isEmptyCountAndCapacity_describeStoredEntries() {
    var map = RedBlackTreeMultiMap<Int, String>()

    XCTAssertTrue(map.isEmpty)
    XCTAssertEqual(map.count, 0)

    map.reserveCapacity(10)
    XCTAssertGreaterThanOrEqual(map.capacity, 10)
    XCTAssertTrue(map.isEmpty)
  }

    func test_keysAndValues_followEntryOrderIncludingDuplicateKeys() {
      let map: RedBlackTreeMultiMap = [(1, "a"), (2, "c"), (1, "b")]

      XCTAssertEqual(Array(map.keys), [1, 1, 2])
      XCTAssertEqual(Array(map.values), ["a", "b", "c"])
    }

    func test_valuesSwapAt_changesValuesWithoutChangingKeys() {
      var map: RedBlackTreeMultiMap = [(1, "a"), (1, "b"), (2, "c")]
      let first = map.startIndex
      let last = map.index(before: map.endIndex)

      map.values.swapAt(first, last)

      XCTAssertEqual(map.map(\.key), [1, 1, 2])
      XCTAssertEqual(map.map(\.value), ["c", "b", "a"])
    }

    func test_valuesSwapAt_preservesValueSemanticsAfterCopy() {
      var map: RedBlackTreeMultiMap = [(1, "a"), (2, "b")]
      let copy = map

      map.values.swapAt(map.startIndex, map.index(before: map.endIndex))

      XCTAssertEqual(map.map(\.value), ["b", "a"])
      XCTAssertEqual(copy.map(\.value), ["a", "b"])
    }

  func test_copyOnWrite_mutatingCopyPreservesOriginal() {
    let original: RedBlackTreeMultiMap = [(1, "a"), (1, "b")]
    var copy = original

    copy.insert((2, "c"))

    XCTAssertEqual(original.map(\.value), ["a", "b"])
    XCTAssertEqual(copy.map(\.value), ["a", "b", "c"])
  }
}
