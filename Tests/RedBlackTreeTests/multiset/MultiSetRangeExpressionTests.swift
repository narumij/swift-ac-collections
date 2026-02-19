//
//  MultiSetRangeExpressionTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/14.
//

#if !COMPATIBLE_ATCODER_2025
  import RedBlackTreeModule
  import XCTest

  final class MultiSetRangeExpressionTests: RedBlackTreeTestCase {

    func testUnboundedRangeView() {
      let set = RedBlackTreeMultiSet([0, 1, 1, 2, 3, 4])
      XCTAssertTrue(set.isValid(...))

      let view = set[...]
      XCTAssertEqual(view.count, 6)
      XCTAssertEqual(view.first, 0)
      XCTAssertEqual(view.last, 4)
      XCTAssertEqual(Array(view), [0, 1, 1, 2, 3, 4])
      XCTAssertEqual(view.reversed(), [4, 3, 2, 1, 1, 0])
    }

    func testHalfOpenRangeView() {
      let set = RedBlackTreeMultiSet([0, 1, 1, 2, 3, 4])
      let lower = set.index(set.startIndex, offsetBy: 1)
      let upper = set.index(set.startIndex, offsetBy: 5)

      XCTAssertTrue(set.isValid(lower..<upper))

      let view = set[lower..<upper]
      XCTAssertEqual(view.count, 4)
      XCTAssertEqual(view.first, 1)
      XCTAssertEqual(view.last, 3)
      XCTAssertEqual(Array(view), [1, 1, 2, 3])
    }

    func testClosedRangeView() {
      let set = RedBlackTreeMultiSet([0, 1, 1, 2, 3, 4])
      let lower = set.index(set.startIndex, offsetBy: 1)
      let upper = set.index(set.startIndex, offsetBy: 4)

      let view = set[lower...upper]
      XCTAssertEqual(view.count, 4)
      XCTAssertEqual(view.first, 1)
      XCTAssertEqual(view.last, 3)
      XCTAssertEqual(Array(view), [1, 1, 2, 3])
    }

    func testPartialRanges() {
      let set = RedBlackTreeMultiSet([0, 1, 1, 2, 3, 4])
      let upper = set.index(set.startIndex, offsetBy: 3)
      let lower = set.index(set.startIndex, offsetBy: 3)

      let toView = set[..<upper]
      XCTAssertEqual(Array(toView), [0, 1, 1])

      let throughView = set[...upper]
      XCTAssertEqual(Array(throughView), [0, 1, 1, 2])

      let fromView = set[lower...]
      XCTAssertEqual(Array(fromView), [2, 3, 4])
    }

    func testSubscriptModifyPopFirst() {
      var set = RedBlackTreeMultiSet([0, 1, 1, 2, 3, 4])
      let lower = set.index(set.startIndex, offsetBy: 1)
      let upper = set.index(set.startIndex, offsetBy: 5)

      let removed = set[lower..<upper].popFirst()
      XCTAssertEqual(removed, 1)
      XCTAssertEqual(Array(set), [0, 1, 2, 3, 4])
    }

    func testSubscriptModifyRemoveFirst() {
      var set = RedBlackTreeMultiSet([0, 1, 1, 2, 3, 4])
      let lower = set.index(set.startIndex, offsetBy: 1)
      let upper = set.index(set.startIndex, offsetBy: 5)

      let removed = set[lower..<upper].removeFirst()
      XCTAssertEqual(removed, 1)
      XCTAssertEqual(Array(set), [0, 1, 2, 3, 4])
    }

    func testSubscriptModifyRemoveLast() {
      var set = RedBlackTreeMultiSet([0, 1, 1, 2, 3, 4])
      let lower = set.index(set.startIndex, offsetBy: 1)
      let upper = set.index(set.startIndex, offsetBy: 5)

      let removed = set[lower..<upper].removeLast()
      XCTAssertEqual(removed, 3)
      XCTAssertEqual(Array(set), [0, 1, 1, 2, 4])
    }

    func testSubscriptModifyErase() {
      var set = RedBlackTreeMultiSet([0, 1, 1, 2, 3, 4])
      let lower = set.index(set.startIndex, offsetBy: 1)
      let upper = set.index(set.startIndex, offsetBy: 5)

      set[lower..<upper].erase()
      XCTAssertEqual(Array(set), [0, 4])
    }

    func testSubscriptModifyEraseWhere() {
      var set = RedBlackTreeMultiSet([0, 1, 1, 2, 3, 4, 5])
      let lower = set.index(set.startIndex, offsetBy: 1)
      let upper = set.index(set.startIndex, offsetBy: 6)

      set[lower..<upper].erase { $0 % 2 == 0 }
      XCTAssertEqual(Array(set), [0, 1, 1, 3, 5])
    }

    func testSubscriptModifyUnboundedPopFirst() {
      var set = RedBlackTreeMultiSet([0, 1, 1, 2, 3])
      let removed = set[...].popFirst()
      XCTAssertEqual(removed, 0)
      XCTAssertEqual(Array(set), [1, 1, 2, 3])
    }

    func testEraseUnboundedRange() {
      var set = RedBlackTreeMultiSet([0, 1, 1, 2, 3])
      set.erase(...)
      XCTAssertTrue(set.isEmpty)
    }

    func testEraseRange() {
      var set = RedBlackTreeMultiSet([0, 1, 1, 2, 3, 4])
      let lower = set.index(set.startIndex, offsetBy: 1)
      let upper = set.index(set.startIndex, offsetBy: 5)

      set.erase(lower..<upper)
      XCTAssertEqual(Array(set), [0, 4])
    }

    func testEraseRangeWithPredicate() {
      var set = RedBlackTreeMultiSet([0, 1, 1, 2, 3, 4, 5])
      let lower = set.index(set.startIndex, offsetBy: 1)
      let upper = set.index(set.startIndex, offsetBy: 6)

      set.erase(lower..<upper) { $0 % 2 == 0 }
      XCTAssertEqual(Array(set), [0, 1, 1, 3, 5])
    }

    func testIndexRangeIsValid() {
      let set = RedBlackTreeMultiSet([0, 1, 1, 2, 3, 4, 5])
      let range = set.equalRange(1)
      XCTAssertTrue(set.isValid(range))
      XCTAssertEqual(Array(set[range]), [1, 1])
    }

    func testSubscriptModifyIndexRangeErase() {
      var set = RedBlackTreeMultiSet([0, 1, 1, 2, 3, 4, 5])
      let range = set.equalRange(1)

      set[range].erase()
      XCTAssertEqual(Array(set), [0, 2, 3, 4, 5])
    }

    func testEraseIndexRange() {
      var set = RedBlackTreeMultiSet([0, 1, 1, 2, 3, 4, 5])
      let range = set.equalRange(1)

      set.erase(range)
      XCTAssertEqual(Array(set), [0, 2, 3, 4, 5])
    }

    func testEraseIndexRangeWithPredicate() {
      var set = RedBlackTreeMultiSet([0, 1, 1, 2, 3, 4, 5])
      let range = set.equalRange(1)

      set.erase(range) { $0 == 1 }
      XCTAssertEqual(Array(set), [0, 2, 3, 4, 5])
    }

    func testEqualRange() {
      let set = RedBlackTreeMultiSet([0, 1, 1, 2, 3, 4, 5])
      XCTAssertEqual(Array(set[set.equalRange(1)]), [1, 1])
    }
  }
#endif
