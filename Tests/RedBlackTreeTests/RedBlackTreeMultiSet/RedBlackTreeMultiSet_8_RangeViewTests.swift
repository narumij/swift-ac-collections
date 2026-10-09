import RedBlackTreeCollections
import XCTest

  final class RedBlackTreeMultiSetRangeViewTests: RedBlackTreeTestCase {

    func test_unboundedRangeView_containsEveryPosition() {
      let multiset = RedBlackTreeMultiSet([0, 1, 1, 2, 3, 4])
      let view = multiset[...]

      XCTAssertTrue(multiset.containsSubrange(...))
      XCTAssertEqual(Array(view), [0, 1, 1, 2, 3, 4])
      XCTAssertEqual(Array(view.reversed()), [4, 3, 2, 1, 1, 0])
    }

    func test_boundedRangeView_preservesDuplicatePositions() {
      let multiset = RedBlackTreeMultiSet([0, 1, 1, 1, 2, 3])
      let lower = multiset.index(multiset.startIndex, offsetBy: 2)
      let upper = multiset.index(multiset.startIndex, offsetBy: 4)
      let view = multiset[lower..<upper]

      XCTAssertTrue(multiset.containsSubrange(lower..<upper))
      XCTAssertEqual(Array(view), [1, 1])
      XCTAssertFalse(view.isElement(at: multiset.index(before: lower)))
      XCTAssertTrue(view.isElement(at: lower))
      XCTAssertTrue(view.isElement(at: multiset.index(after: lower)))
      XCTAssertFalse(view.isElement(at: upper))
    }

    func test_emptyRangeView_recognizesItsOwnEnd() {
      let multiset = RedBlackTreeMultiSet([0, 1, 1, 2])
      let index = multiset.index(multiset.startIndex, offsetBy: 2)
      let view = multiset[index..<index]

      XCTAssertTrue(view.isEmpty)
      XCTAssertFalse(view.isElement(at: index))
      XCTAssertTrue(view.isEnd(view.startIndex))
      XCTAssertTrue(view.isEnd(view.endIndex))
    }

    func test_closedAndPartialRangeViews_useIndexBounds() {
      let multiset = RedBlackTreeMultiSet([0, 1, 1, 2, 3, 4])
      let lower = multiset.index(multiset.startIndex, offsetBy: 1)
      let upper = multiset.index(multiset.startIndex, offsetBy: 3)

      XCTAssertEqual(Array(multiset[lower...upper]), [1, 1, 2])
      XCTAssertEqual(Array(multiset[..<upper]), [0, 1, 1])
      XCTAssertEqual(Array(multiset[...upper]), [0, 1, 1, 2])
      XCTAssertEqual(Array(multiset[upper...]), [2, 3, 4])
    }

    func test_mutatingRangeView_removesOnlyMemberInsideView() {
      var multiset = RedBlackTreeMultiSet([0, 1, 1, 2, 3, 4])
      let lower = multiset.index(multiset.startIndex, offsetBy: 1)
      let upper = multiset.index(multiset.startIndex, offsetBy: 5)

      XCTAssertEqual(multiset[lower..<upper].popFirst(), 1)

      XCTAssertEqual(Array(multiset), [0, 1, 2, 3, 4])
    }

    func test_eraseRangeAndPredicate_modifyOnlySelectedPositions() {
      var multiset = RedBlackTreeMultiSet([0, 1, 1, 2, 3, 4, 5])
      let lower = multiset.index(multiset.startIndex, offsetBy: 1)
      let upper = multiset.index(multiset.startIndex, offsetBy: 6)

      multiset.erase(lower..<upper) { $0.isMultiple(of: 2) }
      XCTAssertEqual(Array(multiset), [0, 1, 1, 3, 5])

      multiset[multiset.equalRange(1)].erase()
      XCTAssertEqual(Array(multiset), [0, 3, 5])
    }

    func test_containsSubrange_acceptsEqualRangeIndexRangeValue() {
      let multiset = RedBlackTreeMultiSet([0, 1, 1, 2])

      XCTAssertTrue(multiset.containsSubrange(multiset.equalRange(1)))
    }

    func test_unboundedRangeViewModify_mutatesThroughTheSubscript() {
      var multiset = RedBlackTreeMultiSet([0, 1, 2])

      XCTAssertEqual(multiset[...].popFirst(), 0)
      XCTAssertEqual(Array(multiset), [1, 2])
    }

    func test_eraseUnboundedRange_removesEveryMember() {
      var multiset = RedBlackTreeMultiSet([0, 1, 1, 2])

      multiset.erase(...)

      XCTAssertTrue(multiset.isEmpty)
    }
  }
