//
//  MultiMapRangeExpressionTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/14.
//

#if !COMPATIBLE_ATCODER_2025
  import RedBlackTreeModule
  import XCTest

  final class MultiMapRangeExpressionTests: RedBlackTreeTestCase {

    func testUnboundedRangeView() {
      let map: RedBlackTreeMultiMap = [3: "c", 1: "a", 2: "b", 4: "d"]
      XCTAssertTrue(map.isValid(...))

      let view = map[...]
      XCTAssertEqual(view.count, 4)
      XCTAssertEqual(view.first?.key, 1)
      XCTAssertEqual(view.last?.key, 4)
      XCTAssertEqual(Array(view).map { $0.key }, [1, 2, 3, 4])
    }

    func testHalfOpenRangeView() {
      let map: RedBlackTreeMultiMap = [3: "c", 1: "a", 2: "b", 4: "d"]
      let lower = map.index(map.startIndex, offsetBy: 1)
      let upper = map.index(map.startIndex, offsetBy: 3)

      XCTAssertTrue(map.isValid(lower..<upper))

      let view = map[lower..<upper]
      XCTAssertEqual(view.count, 2)
      XCTAssertEqual(Array(view).map { $0.key }, [2, 3])
    }

    func testClosedRangeView() {
      let map: RedBlackTreeMultiMap = [3: "c", 1: "a", 2: "b", 4: "d"]
      let lower = map.index(map.startIndex, offsetBy: 1)
      let upper = map.index(map.startIndex, offsetBy: 2)

      let view = map[lower...upper]
      XCTAssertEqual(view.count, 2)
      XCTAssertEqual(Array(view).map { $0.key }, [2, 3])
    }

    func testPartialRanges() {
      let map: RedBlackTreeMultiMap = [3: "c", 1: "a", 2: "b", 4: "d"]
      let upper = map.index(map.startIndex, offsetBy: 2)
      let lower = map.index(map.startIndex, offsetBy: 2)

      let toView = map[..<upper]
      XCTAssertEqual(Array(toView).map { $0.key }, [1, 2])

      let throughView = map[...upper]
      XCTAssertEqual(Array(throughView).map { $0.key }, [1, 2, 3])

      let fromView = map[lower...]
      XCTAssertEqual(Array(fromView).map { $0.key }, [3, 4])
    }

    func testSubscriptModifyPopFirst() {
      var map: RedBlackTreeMultiMap = [3: "c", 1: "a", 2: "b", 4: "d"]
      let lower = map.index(map.startIndex, offsetBy: 1)
      let upper = map.index(map.startIndex, offsetBy: 3)

      let removed = map[lower..<upper].popFirst()
      XCTAssertEqual(removed?.key, 2)
      XCTAssertEqual(Array(map).map { $0.key }, [1, 3, 4])
    }

    func testSubscriptModifyRemoveFirst() {
      var map: RedBlackTreeMultiMap = [3: "c", 1: "a", 2: "b", 4: "d"]
      let lower = map.index(map.startIndex, offsetBy: 1)
      let upper = map.index(map.startIndex, offsetBy: 3)

      let removed = map[lower..<upper].removeFirst()
      XCTAssertEqual(removed.key, 2)
      XCTAssertEqual(Array(map).map { $0.key }, [1, 3, 4])
    }

    func testSubscriptModifyRemoveLast() {
      var map: RedBlackTreeMultiMap = [3: "c", 1: "a", 2: "b", 4: "d"]
      let lower = map.index(map.startIndex, offsetBy: 1)
      let upper = map.index(map.startIndex, offsetBy: 3)

      let removed = map[lower..<upper].removeLast()
      XCTAssertEqual(removed.key, 3)
      XCTAssertEqual(Array(map).map { $0.key }, [1, 2, 4])
    }

    func testSubscriptModifyErase() {
      var map: RedBlackTreeMultiMap = [3: "c", 1: "a", 2: "b", 4: "d"]
      let lower = map.index(map.startIndex, offsetBy: 1)
      let upper = map.index(map.startIndex, offsetBy: 3)

      map[lower..<upper].erase()
      XCTAssertEqual(Array(map).map { $0.key }, [1, 4])
    }

    func testSubscriptModifyEraseWhere() {
      var map: RedBlackTreeMultiMap = [3: "c", 1: "a", 2: "b", 4: "d", 5: "e"]
      let lower = map.index(map.startIndex, offsetBy: 1)
      let upper = map.index(map.startIndex, offsetBy: 4)

      map[lower..<upper].erase { $0.key % 2 == 0 }
      XCTAssertEqual(Array(map).map { $0.key }, [1, 3, 5])
    }

    func testSubscriptModifyUnboundedPopFirst() {
      var map: RedBlackTreeMultiMap = [3: "c", 1: "a", 2: "b"]
      let removed = map[...].popFirst()
      XCTAssertEqual(removed?.key, 1)
      XCTAssertEqual(Array(map).map { $0.key }, [2, 3])
    }

    func testEraseUnboundedRange() {
      var map: RedBlackTreeMultiMap = [3: "c", 1: "a", 2: "b"]
      map.erase(...)
      XCTAssertTrue(map.isEmpty)
    }

    func testEraseRange() {
      var map: RedBlackTreeMultiMap = [3: "c", 1: "a", 2: "b", 4: "d"]
      let lower = map.index(map.startIndex, offsetBy: 1)
      let upper = map.index(map.startIndex, offsetBy: 3)

      map.erase(lower..<upper)
      XCTAssertEqual(Array(map).map { $0.key }, [1, 4])
    }

    func testEraseRangeWithPredicate() {
      var map: RedBlackTreeMultiMap = [3: "c", 1: "a", 2: "b", 4: "d", 5: "e"]
      let lower = map.index(map.startIndex, offsetBy: 1)
      let upper = map.index(map.startIndex, offsetBy: 4)

      map.erase(lower..<upper) { $0.key % 2 == 0 }
      XCTAssertEqual(Array(map).map { $0.key }, [1, 3, 5])
    }

    func testIndexRangeIsValid() {
      let map: RedBlackTreeMultiMap = [3: "c", 1: "a", 1: "d", 2: "b", 4: "d", 5: "e"]
      let range = map.equalRange(1)
      XCTAssertTrue(map.isValid(range))
      XCTAssertEqual(Array(map[range]).map { $0.value }, ["a", "d"])
    }

    func testSubscriptModifyIndexRangeErase() {
      var map: RedBlackTreeMultiMap = [3: "c", 1: "a", 1: "d", 2: "b", 4: "d", 5: "e"]
      let range = map.equalRange(1)

      map[range].erase()
      XCTAssertEqual(Array(map).map { $0.key }, [2, 3, 4, 5])
    }

    func testEraseIndexRange() {
      var map: RedBlackTreeMultiMap = [3: "c", 1: "a", 1: "d", 2: "b", 4: "d", 5: "e"]
      let range = map.equalRange(1)

      map.erase(range)
      XCTAssertEqual(Array(map).map { $0.key }, [2, 3, 4, 5])
    }

    func testEraseIndexRangeWithPredicate() {
      var map: RedBlackTreeMultiMap = [3: "c", 1: "a", 1: "d", 2: "b", 4: "d", 5: "e"]
      let range = map.equalRange(1)

      map.erase(range) { $0.value == "a" }
      XCTAssertEqual(Array(map).filter { $0.key == 1 }.map { $0.value }, ["d"])
    }

    func testEqualRange() {
      let map: RedBlackTreeMultiMap = [3: "c", 1: "a", 1: "d", 2: "b", 4: "d", 5: "e"]
      XCTAssertEqual(Array(map[map.equalRange(1)].map(\.value)), ["a", "d"])
    }
  }
#endif
