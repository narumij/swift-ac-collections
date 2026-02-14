//
//  SetRangeExpressionTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/14.
//

#if !COMPATIBLE_ATCODER_2025
  import RedBlackTreeModule
  import XCTest

  final class SetRangeExpressionTests: RedBlackTreeTestCase {

    func testUnboundedRangeView() {
      let set = RedBlackTreeSet(0..<5)
      XCTAssertTrue(set.isValid(...))

      let view = set[...]
      XCTAssertEqual(view.count, 5)
      XCTAssertEqual(view.first, 0)
      XCTAssertEqual(view.last, 4)
      XCTAssertEqual(Array(view), [0, 1, 2, 3, 4])
      XCTAssertEqual(view.reversed(), [4, 3, 2, 1, 0])
    }

    func testHalfOpenRangeView() {
      let set = RedBlackTreeSet(0..<10)
      let lower = set.index(set.startIndex, offsetBy: 2)
      let upper = set.index(set.startIndex, offsetBy: 6)

      XCTAssertTrue(set.isValid(lower..<upper))

      let view = set[lower..<upper]
      XCTAssertEqual(view.count, 4)
      XCTAssertEqual(view.first, 2)
      XCTAssertEqual(view.last, 5)
      XCTAssertEqual(Array(view), [2, 3, 4, 5])
    }

    func testClosedRangeView() {
      let set = RedBlackTreeSet(0..<10)
      let lower = set.index(set.startIndex, offsetBy: 2)
      let upper = set.index(set.startIndex, offsetBy: 5)

      let view = set[lower...upper]
      XCTAssertEqual(view.count, 4)
      XCTAssertEqual(view.first, 2)
      XCTAssertEqual(view.last, 5)
      XCTAssertEqual(Array(view), [2, 3, 4, 5])
    }

    func testPartialRanges() {
      let set = RedBlackTreeSet(0..<6)
      let upper = set.index(set.startIndex, offsetBy: 3)
      let lower = set.index(set.startIndex, offsetBy: 3)

      let toView = set[..<upper]
      XCTAssertEqual(Array(toView), [0, 1, 2])

      let throughView = set[...upper]
      XCTAssertEqual(Array(throughView), [0, 1, 2, 3])

      let fromView = set[lower...]
      XCTAssertEqual(Array(fromView), [3, 4, 5])
    }

    func testSubscriptModifyPopFirst() {
      var set = RedBlackTreeSet(0..<6)
      let lower = set.index(set.startIndex, offsetBy: 1)
      let upper = set.index(set.startIndex, offsetBy: 5)

      let removed = set[lower..<upper].popFirst()
      XCTAssertEqual(removed, 1)
      XCTAssertEqual(Array(set), [0, 2, 3, 4, 5])
    }

    func testSubscriptModifyRemoveFirst() {
      var set = RedBlackTreeSet(0..<6)
      let lower = set.index(set.startIndex, offsetBy: 1)
      let upper = set.index(set.startIndex, offsetBy: 5)

      let removed = set[lower..<upper].removeFirst()
      XCTAssertEqual(removed, 1)
      XCTAssertEqual(Array(set), [0, 2, 3, 4, 5])
    }

    func testSubscriptModifyRemoveLast() {
      var set = RedBlackTreeSet(0..<6)
      let lower = set.index(set.startIndex, offsetBy: 1)
      let upper = set.index(set.startIndex, offsetBy: 5)

      let removed = set[lower..<upper].removeLast()
      XCTAssertEqual(removed, 4)
      XCTAssertEqual(Array(set), [0, 1, 2, 3, 5])
    }

    func testSubscriptModifyErase() {
      var set = RedBlackTreeSet(0..<8)
      let lower = set.index(set.startIndex, offsetBy: 2)
      let upper = set.index(set.startIndex, offsetBy: 6)

      set[lower..<upper].erase()
      XCTAssertEqual(Array(set), [0, 1, 6, 7])
    }

    func testSubscriptModifyEraseWhere() {
      var set = RedBlackTreeSet(0..<8)
      let lower = set.index(set.startIndex, offsetBy: 1)
      let upper = set.index(set.startIndex, offsetBy: 7)

      set[lower..<upper].erase { $0 % 2 == 0 }
      XCTAssertEqual(Array(set), [0, 1, 3, 5, 7])
    }

    func testSubscriptModifyUnboundedPopFirst() {
      var set = RedBlackTreeSet(0..<5)
      let removed = set[...].popFirst()
      XCTAssertEqual(removed, 0)
      XCTAssertEqual(Array(set), [1, 2, 3, 4])
    }

    func testEraseRangeWhereFromSet() {
      var set = RedBlackTreeSet(0..<8)
      let lower = set.index(set.startIndex, offsetBy: 1)
      let upper = set.index(set.startIndex, offsetBy: 7)

      set.erase(lower..<upper) { $0 % 2 == 0 }
      XCTAssertEqual(Array(set), [0, 1, 3, 5, 7])
    }

    func testEraseUnboundedRange() {
      var set = RedBlackTreeSet(0..<3)
      set.erase(...)
      XCTAssertTrue(set.isEmpty)
    }

    func testEraseUnboundedRange2() {
      var set = RedBlackTreeSet(0..<3)
      set[...].erase()
      XCTAssertTrue(set.isEmpty)
    }

    func testEraseRange() {
      var set = RedBlackTreeSet(0..<8)
      let lower = set.index(set.startIndex, offsetBy: 2)
      let upper = set.index(set.startIndex, offsetBy: 6)

      set.erase(lower..<upper)
      XCTAssertEqual(Array(set), [0, 1, 6, 7])
    }

    func testEraseRangeWithPredicate() {
      var set = RedBlackTreeSet(0..<8)
      let lower = set.index(set.startIndex, offsetBy: 1)
      let upper = set.index(set.startIndex, offsetBy: 7)

      set.erase(lower..<upper) { $0 % 2 == 0 }
      XCTAssertEqual(Array(set), [0, 1, 3, 5, 7])
    }

    func testEraseRangeFromDifferentTreeMutatesTargetAfterCoWMatch() {
      var source = RedBlackTreeSet(0..<8)
      var target = RedBlackTreeSet(100..<108)
      let lower = source.index(source.startIndex, offsetBy: 2)
      let upper = source.index(source.startIndex, offsetBy: 6)

      target.erase(lower..<upper)
      // CoW救済方針の都合、これを落とすことが出来ない

      XCTAssertEqual(Array(source), [0, 1, 2, 3, 4, 5, 6, 7])
      XCTAssertEqual(Array(target), [100, 101, 106, 107])
    }
  }
#endif
