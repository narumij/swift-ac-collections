import RedBlackTreeCollections
import XCTest

  final class RedBlackTreeSetElementRangeTests: RedBlackTreeTestCase {

    func testElementRangeExposesItsBounds() {
      let set = RedBlackTreeSet(0..<10)
      let elements = set.elements(in: 2..<6)

      XCTAssertEqual(elements.count, 4)
      XCTAssertEqual(elements.first, 2)
      XCTAssertEqual(elements.last, 5)
    }

    func testElementRangeIteratesInSortedOrder() {
      let set: RedBlackTreeSet = [1, 2, 3, 4, 5, 6, 7]
      let elements = set.elements(in: 2..<6)

      XCTAssertEqual(Array(elements), [2, 3, 4, 5])
      XCTAssertEqual(elements.sorted(), [2, 3, 4, 5])
    }

    func testElementRangeSupportsReverseIteration() {
      let set: RedBlackTreeSet = [1, 2, 3, 4, 5, 6, 7]
      let elements = set.elements(in: 2..<6)

      XCTAssertEqual(Array(elements.reversed()), [5, 4, 3, 2])
    }
  }
