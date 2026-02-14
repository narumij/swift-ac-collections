//
//  MultiMapBoundsExpressionTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/14.
//

#if DEBUG && !COMPATIBLE_ATCODER_2025
  import XCTest
  import RedBlackTreeModule

  final class MultiMapBoundsExpressionTests: XCTestCase {

    let a: RedBlackTreeMultiMap = [0: "a", 1: "b", 2: "c"]

    func testAfter() throws {
      XCTAssertTrue(a.isValid(start()))
      XCTAssertEqual(a[start()]?.key, 0)

      XCTAssertTrue(a.isValid(start().after))
      XCTAssertEqual(a[start().after]?.key, 1)

      XCTAssertTrue(a.isValid(start().after.after))
      XCTAssertEqual(a[start().after.after]?.key, 2)

      XCTAssertFalse(a.isValid(start().after.after.after))
      XCTAssertNil(a[start().after.after.after])
    }

    func testEndIsInvalid() throws {
      XCTAssertFalse(a.isValid(end()))
      XCTAssertNil(a[end()])
    }

    func testLowerUpperBoundFind() throws {
      XCTAssertEqual(a[lowerBound(-1)]?.key, 0)
      XCTAssertEqual(a[lowerBound(0)]?.key, 0)
      XCTAssertEqual(a[lowerBound(1)]?.key, 1)
      XCTAssertEqual(a[lowerBound(2)]?.key, 2)
      XCTAssertEqual(a[lowerBound(3)]?.key, nil)

      XCTAssertEqual(a[upperBound(-1)]?.key, 0)
      XCTAssertEqual(a[upperBound(0)]?.key, 1)
      XCTAssertEqual(a[upperBound(1)]?.key, 2)
      XCTAssertEqual(a[upperBound(2)]?.key, nil)

      XCTAssertEqual(a[find(1)]?.key, 1)
      XCTAssertEqual(a[find(5)]?.key, nil)

      XCTAssertTrue(a.isValid(.last))
      XCTAssertEqual(a[.last]?.key, 2)
    }

    func testCountDistance() throws {
      XCTAssertEqual(a.count(lowerBound(0)..<upperBound(2)), 3)
      XCTAssertEqual(a.distance(lowerBound(0)..<upperBound(2)), 3)
      XCTAssertEqual(a.count(lowerBound(2)..<lowerBound(1)), nil)
    }

    func testEraseBound() throws {
      var b: RedBlackTreeMultiMap = [0: "a", 1: "b", 2: "c"]
      let removed = b.erase(find(1))
      XCTAssertEqual(removed?.key, 1)
      XCTAssertEqual(Array(b).map { $0.key }, [0, 2])
    }

    func testSubscriptBoundsView() throws {
      let view = a[lowerBound(0)..<upperBound(2)]
      XCTAssertEqual(Array(view).map { $0.key }, [0, 1, 2])
    }

    func testSubscriptBoundsModifyPopFirst() throws {
      var b: RedBlackTreeMultiMap = [0: "a", 1: "b", 2: "c", 3: "d"]
      let removed = b[lowerBound(0)..<upperBound(1)].popFirst()
      XCTAssertEqual(removed?.key, 0)
      XCTAssertEqual(Array(b).map { $0.key }, [1, 2, 3])
    }

    func testEraseBounds() throws {
      var b: RedBlackTreeMultiMap = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
      b.erase(lowerBound(1)..<upperBound(3))
      XCTAssertEqual(Array(b).map { $0.key }, [0, 4])
    }

    func testRemoveBoundsWhere() throws {
      var b: RedBlackTreeMultiMap = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
      b.erase(lowerBound(0)..<upperBound(4)) { $0.key % 2 == 0 }
      XCTAssertEqual(Array(b).map { $0.key }, [1, 3])
    }
  }
#endif
