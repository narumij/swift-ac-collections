import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiMapElementRangeTests: RedBlackTreeTestCase {

  func test_halfOpenElementRange_usesKeyBoundsAndPreservesDuplicates() {
    let map: RedBlackTreeMultiMap = [(1, "a"), (2, "b"), (2, "c"), (3, "d"), (4, "e")]

    let elements = map.elements(in: 2..<4)

    XCTAssertEqual(elements.map(\.key), [2, 2, 3])
    XCTAssertEqual(elements.map(\.value), ["b", "c", "d"])
  }

  func test_closedElementRange_includesUpperBoundDuplicates() {
    let map: RedBlackTreeMultiMap = [(1, "a"), (2, "b"), (2, "c"), (3, "d"), (3, "e")]

    let elements = map.elements(in: 2...3)

    XCTAssertEqual(elements.map(\.value), ["b", "c", "d", "e"])
  }

  func test_elementRange_supportsForwardAndReverseIteration() {
    let map: RedBlackTreeMultiMap = [(1, "a"), (2, "b"), (2, "c"), (3, "d")]
    let elements = map.elements(in: 2...3)

    XCTAssertEqual(elements.map(\.value), ["b", "c", "d"])
    XCTAssertEqual(elements.reversed().map(\.value), ["d", "c", "b"])
  }

  func test_elementRange_isEmptyWhenNoKeyMatches() {
    let map: RedBlackTreeMultiMap = [(1, "a"), (3, "c")]

    XCTAssertTrue(map.elements(in: 2..<3).isEmpty)
    XCTAssertTrue(map.elements(in: 4...5).isEmpty)
  }
}
