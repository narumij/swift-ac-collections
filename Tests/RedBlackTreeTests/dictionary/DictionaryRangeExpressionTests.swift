//
//  DictionaryRangeExpressionTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/14.
//

#if !COMPATIBLE_ATCODER_2025
import RedBlackTreeModule
import XCTest

final class DictionaryRangeExpressionTests: RedBlackTreeTestCase {

  func testUnboundedRangeView() {
    let dict: RedBlackTreeDictionary = [3: "c", 1: "a", 2: "b", 4: "d"]
    XCTAssertTrue(dict.isValid(...))

    let view = dict[...]
    XCTAssertEqual(view.count, 4)
    XCTAssertEqual(view.first?.key, 1)
    XCTAssertEqual(view.last?.key, 4)
    XCTAssertEqual(Array(view).map { $0.key }, [1, 2, 3, 4])
  }

  func testHalfOpenRangeView() {
    let dict: RedBlackTreeDictionary = [3: "c", 1: "a", 2: "b", 4: "d"]
    let lower = dict.index(dict.startIndex, offsetBy: 1)
    let upper = dict.index(dict.startIndex, offsetBy: 3)

    XCTAssertTrue(dict.isValid(lower..<upper))

    let view = dict[lower..<upper]
    XCTAssertEqual(view.count, 2)
    XCTAssertEqual(Array(view).map { $0.key }, [2, 3])
  }

  func testClosedRangeView() {
    let dict: RedBlackTreeDictionary = [3: "c", 1: "a", 2: "b", 4: "d"]
    let lower = dict.index(dict.startIndex, offsetBy: 1)
    let upper = dict.index(dict.startIndex, offsetBy: 2)

    let view = dict[lower...upper]
    XCTAssertEqual(view.count, 2)
    XCTAssertEqual(Array(view).map { $0.key }, [2, 3])
  }

  func testPartialRanges() {
    let dict: RedBlackTreeDictionary = [3: "c", 1: "a", 2: "b", 4: "d"]
    let upper = dict.index(dict.startIndex, offsetBy: 2)
    let lower = dict.index(dict.startIndex, offsetBy: 2)

    let toView = dict[..<upper]
    XCTAssertEqual(Array(toView).map { $0.key }, [1, 2])

    let throughView = dict[...upper]
    XCTAssertEqual(Array(throughView).map { $0.key }, [1, 2, 3])

    let fromView = dict[lower...]
    XCTAssertEqual(Array(fromView).map { $0.key }, [3, 4])
  }

  func testSubscriptModifyPopFirst() {
    var dict: RedBlackTreeDictionary = [3: "c", 1: "a", 2: "b", 4: "d"]
    let lower = dict.index(dict.startIndex, offsetBy: 1)
    let upper = dict.index(dict.startIndex, offsetBy: 3)

    let removed = dict[lower..<upper].popFirst()
    XCTAssertEqual(removed?.key, 2)
    XCTAssertEqual(Array(dict).map { $0.key }, [1, 3, 4])
  }

  func testSubscriptModifyRemoveFirst() {
    var dict: RedBlackTreeDictionary = [3: "c", 1: "a", 2: "b", 4: "d"]
    let lower = dict.index(dict.startIndex, offsetBy: 1)
    let upper = dict.index(dict.startIndex, offsetBy: 3)

    let removed = dict[lower..<upper].removeFirst()
    XCTAssertEqual(removed.key, 2)
    XCTAssertEqual(Array(dict).map { $0.key }, [1, 3, 4])
  }

  func testSubscriptModifyRemoveLast() {
    var dict: RedBlackTreeDictionary = [3: "c", 1: "a", 2: "b", 4: "d"]
    let lower = dict.index(dict.startIndex, offsetBy: 1)
    let upper = dict.index(dict.startIndex, offsetBy: 3)

    let removed = dict[lower..<upper].removeLast()
    XCTAssertEqual(removed.key, 3)
    XCTAssertEqual(Array(dict).map { $0.key }, [1, 2, 4])
  }

  func testSubscriptModifyErase() {
    var dict: RedBlackTreeDictionary = [3: "c", 1: "a", 2: "b", 4: "d"]
    let lower = dict.index(dict.startIndex, offsetBy: 1)
    let upper = dict.index(dict.startIndex, offsetBy: 3)

    dict[lower..<upper].erase()
    XCTAssertEqual(Array(dict).map { $0.key }, [1, 4])
  }

  func testSubscriptModifyEraseWhere() {
    var dict: RedBlackTreeDictionary = [3: "c", 1: "a", 2: "b", 4: "d", 5: "e"]
    let lower = dict.index(dict.startIndex, offsetBy: 1)
    let upper = dict.index(dict.startIndex, offsetBy: 4)

    dict[lower..<upper].erase { $0.key % 2 == 0 }
    XCTAssertEqual(Array(dict).map { $0.key }, [1, 3, 5])
  }

  func testSubscriptModifyUnboundedPopFirst() {
    var dict: RedBlackTreeDictionary = [3: "c", 1: "a", 2: "b"]
    let removed = dict[...].popFirst()
    XCTAssertEqual(removed?.key, 1)
    XCTAssertEqual(Array(dict).map { $0.key }, [2, 3])
  }

  func testEraseUnboundedRange() {
    var dict: RedBlackTreeDictionary = [3: "c", 1: "a", 2: "b"]
    dict.erase(...)
    XCTAssertTrue(dict.isEmpty)
  }

  func testEraseRange() {
    var dict: RedBlackTreeDictionary = [3: "c", 1: "a", 2: "b", 4: "d"]
    let lower = dict.index(dict.startIndex, offsetBy: 1)
    let upper = dict.index(dict.startIndex, offsetBy: 3)

    dict.erase(lower..<upper)
    XCTAssertEqual(Array(dict).map { $0.key }, [1, 4])
  }

  func testEraseRangeWithPredicate() {
    var dict: RedBlackTreeDictionary = [3: "c", 1: "a", 2: "b", 4: "d", 5: "e"]
    let lower = dict.index(dict.startIndex, offsetBy: 1)
    let upper = dict.index(dict.startIndex, offsetBy: 4)

    dict.erase(lower..<upper) { $0.key % 2 == 0 }
    XCTAssertEqual(Array(dict).map { $0.key }, [1, 3, 5])
  }
}
#endif
