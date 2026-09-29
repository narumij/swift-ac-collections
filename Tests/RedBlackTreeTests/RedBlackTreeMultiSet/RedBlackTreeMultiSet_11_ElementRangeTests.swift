import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultisetSubSequenceTests: RedBlackTreeTestCase {

  func test_halfOpenElementRange_preservesEveryMatchingDuplicate() {
    let multiset = RedBlackTreeMultiSet([0, 1, 1, 2, 3, 3, 3, 4])

    let elements = multiset.elements(in: 1..<3)

    XCTAssertEqual(Array(elements), [1, 1, 2])
    XCTAssertEqual(Array(elements.reversed()), [2, 1, 1])
  }

  func test_closedElementRange_includesUpperBoundDuplicates() {
    let multiset = RedBlackTreeMultiSet([0, 1, 1, 2, 3, 3, 3, 4])

    let elements = multiset.elements(in: 1...3)

    XCTAssertEqual(Array(elements), [1, 1, 2, 3, 3, 3])
    XCTAssertEqual(elements.first, 1)
    XCTAssertEqual(elements.count, 6)
  }

  func test_elementRange_isEmptyWhenNoMemberMatches() {
    let multiset = RedBlackTreeMultiSet([1, 1, 3, 3])

    XCTAssertTrue(multiset.elements(in: 2..<3).isEmpty)
    XCTAssertTrue(multiset.elements(in: 4...5).isEmpty)
  }

  func test_elementRange_bounds_arePositionsInTheOriginalMultiset() {
    let multiset = RedBlackTreeMultiSet([1, 1, 2, 2, 2, 3, 4])
    let elements = multiset.elements(in: 2..<3)

    XCTAssertEqual(elements.startIndex, multiset.lowerBound(2))
    XCTAssertEqual(elements.endIndex, multiset.lowerBound(3))
    XCTAssertEqual(elements.map { $0 }, [2, 2, 2])
  }

  func test_singleValueClosedRange_selectsAllEquivalentMembers() {
    let multiset = RedBlackTreeMultiSet([1, 1, 2, 2, 2, 3, 4])
    let elements = multiset.elements(in: 2...2)

    XCTAssertEqual(Array(elements), [2, 2, 2])
    XCTAssertEqual(elements.startIndex, multiset.lowerBound(2))
    XCTAssertEqual(elements.endIndex, multiset.upperBound(2))
  }
}
