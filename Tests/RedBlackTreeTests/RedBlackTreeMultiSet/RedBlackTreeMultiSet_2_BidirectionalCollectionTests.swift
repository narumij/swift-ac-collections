import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiSetBidirectionalCollectionTests: RedBlackTreeTestCase {

  func test_indicesTraverseDuplicatesInSortedOrder() {
    let multiset = RedBlackTreeMultiSet([3, 1, 2, 2])
    var index = multiset.startIndex
    var elements: [Int] = []

    while index != multiset.endIndex {
      elements.append(multiset[index])
      index = multiset.index(after: index)
    }

    XCTAssertEqual(elements, [1, 2, 2, 3])
  }

  func test_indexBefore_traversesDuplicatesInReverseOrder() {
    let multiset = RedBlackTreeMultiSet([3, 1, 2, 2])
    var index = multiset.endIndex
    var elements: [Int] = []

    while index != multiset.startIndex {
      index = multiset.index(before: index)
      elements.append(multiset[index])
    }

    XCTAssertEqual(elements, [3, 2, 2, 1])
  }

  func test_distanceAndOffsetIncludeDuplicatePositions() {
    let multiset = RedBlackTreeMultiSet([1, 2, 2, 3])

    XCTAssertEqual(multiset.distance(from: multiset.startIndex, to: multiset.endIndex), 4)
    XCTAssertEqual(multiset[multiset.index(multiset.startIndex, offsetBy: 2)], 2)
    XCTAssertEqual(multiset.index(multiset.endIndex, offsetBy: -4), multiset.startIndex)
  }

  func test_limitedOffset_stopsAtLimit() {
    let multiset = RedBlackTreeMultiSet([1, 2, 2, 3])

    XCTAssertEqual(
      multiset.index(multiset.startIndex, offsetBy: 4, limitedBy: multiset.endIndex),
      multiset.endIndex)
    XCTAssertNil(multiset.index(multiset.startIndex, offsetBy: 5, limitedBy: multiset.endIndex))
    XCTAssertNil(multiset.index(multiset.endIndex, offsetBy: -5, limitedBy: multiset.startIndex))
  }

  func test_formIndex_supportsForwardAndBackwardMovement() {
    let multiset = RedBlackTreeMultiSet([1, 2, 2, 3])
    var index = multiset.startIndex

    multiset.formIndex(after: &index)
    XCTAssertEqual(multiset[index], 2)
    multiset.formIndex(&index, offsetBy: 2)
    XCTAssertEqual(multiset[index], 3)
    multiset.formIndex(before: &index)
    XCTAssertEqual(multiset[index], 2)
  }
}
