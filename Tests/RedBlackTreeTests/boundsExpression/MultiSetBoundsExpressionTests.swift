//
//  MultiSetBoundsExpressionTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/14.
//

#if DEBUG && !COMPATIBLE_ATCODER_2025
  import XCTest
  import RedBlackTreeModule

  final class MultiSetBoundsExpressionTests: XCTestCase {

    let a = RedBlackTreeMultiSet<Int>([0, 1, 2])

    func testAfter() throws {
      XCTAssertTrue(a.isValid(start()))
      XCTAssertEqual(a[start()], 0)

      XCTAssertTrue(a.isValid(start().after))
      XCTAssertEqual(a[start().after], 1)

      XCTAssertTrue(a.isValid(start().after.after))
      XCTAssertEqual(a[start().after.after], 2)

      XCTAssertFalse(a.isValid(start().after.after.after))
      XCTAssertEqual(a[start().after.after.after], nil)
    }

    func testEndIsInvalid() throws {
      XCTAssertFalse(a.isValid(end()))
      XCTAssertNil(a[end()])
    }

    func testLowerUpperBoundFind() throws {
      XCTAssertEqual(a[lowerBound(-1)], 0)
      XCTAssertEqual(a[lowerBound(0)], 0)
      XCTAssertEqual(a[lowerBound(1)], 1)
      XCTAssertEqual(a[lowerBound(2)], 2)
      XCTAssertEqual(a[lowerBound(3)], nil)

      XCTAssertEqual(a[upperBound(-1)], 0)
      XCTAssertEqual(a[upperBound(0)], 1)
      XCTAssertEqual(a[upperBound(1)], 2)
      XCTAssertEqual(a[upperBound(2)], nil)

      XCTAssertEqual(a[find(1)], 1)
      XCTAssertEqual(a[find(5)], nil)

      XCTAssertTrue(a.isValid(.last))
      XCTAssertEqual(a[.last], 2)
    }

    func testCountDistance() throws {
      XCTAssertEqual(a.count(lowerBound(0)..<upperBound(2)), 3)
      XCTAssertEqual(a.distance(lowerBound(0)..<upperBound(2)), 3)
      XCTAssertEqual(a.count(lowerBound(2)..<lowerBound(1)), nil)
    }

    func testEraseBound() throws {
      var b = a
      let removed = b.erase(find(1))
      XCTAssertEqual(removed, 1)
      XCTAssertEqual(Array(b), [0, 2])
    }

    func testEraseRangeWhere() throws {
      var b = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4])
      b.erase(lowerBound(0)..<upperBound(4)) { $0 % 2 == 0 }
      XCTAssertEqual(Array(b), [1, 3])
    }
  }
#endif
