//
//  MultiSetBoundsExpressionTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/14.
//

#if DEBUG
  import XCTest
  import RedBlackTreeCollections

  final class RedBlackTreeMultiSetBoundExpressionTests: RedBlackTreeTestCase {

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

    func testViewCount() throws {
      XCTAssertEqual(a[lowerBound(0)..<upperBound(2)].count, 3)
    }

    func testEraseBound() throws {
      var b = a
      let removed = b.erase(find(1))
      XCTAssertEqual(removed, 1)
      XCTAssertEqual(Array(b), [0, 2])
    }

    func testSubscriptBoundsView() throws {
      let view = a[lowerBound(0)..<upperBound(2)]
      XCTAssertEqual(Array(view), [0, 1, 2])
    }

    func testSubscriptBoundsModifyPopFirst() throws {
      var b = RedBlackTreeMultiSet<Int>([0, 1, 1, 2])
      let removed = b[lowerBound(0)..<upperBound(1)].popFirst()
      XCTAssertEqual(removed, 0)
      XCTAssertEqual(Array(b), [1, 1, 2])
    }

    func testEqualRangeMulti() throws {
      let view = a[equalRange(1)]
      XCTAssertEqual(Array(view), [1])

      let b = RedBlackTreeMultiSet<Int>([0, 1, 1, 2])
      let view2 = b[equalRange(1)]
      XCTAssertEqual(Array(view2), [1, 1])
    }

    func testEraseRangeWhere() throws {
      var b = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4])
      b.erase(lowerBound(0)..<upperBound(4)) { $0 % 2 == 0 }
      XCTAssertEqual(Array(b), [1, 3])
    }

    func testEraesBounds() throws {
      var b = RedBlackTreeMultiSet<Int>([0, 1, 1, 2, 3])
      b.erase(lowerBound(1)..<upperBound(2))
      XCTAssertEqual(Array(b), [0, 3])
    }

    /// 下端が上端より後ろにある逆向きの範囲は空の範囲として扱い、何も削除しないこと。
    /// 同値要素の区間を逆向きに指定した場合も同じであること。
    func testEraseReversedBoundsRemovesNothing() throws {
      var b = RedBlackTreeMultiSet<Int>([0, 1, 1, 2, 3])
      b.erase(upperBound(10)..<lowerBound(-10))
      XCTAssertEqual(Array(b), [0, 1, 1, 2, 3])
      b.erase(upperBound(1)..<lowerBound(1))
      XCTAssertEqual(Array(b), [0, 1, 1, 2, 3])
    }

    /// 逆向きの範囲では、条件クロージャを一度も呼ばず、何も削除しないこと。
    func testEraseReversedBoundsWhereRemovesNothingAndSkipsPredicate() throws {
      var b = RedBlackTreeMultiSet<Int>([0, 1, 1, 2, 3])
      var calls = 0
      b.erase(upperBound(1)..<lowerBound(1)) { _ in
        calls += 1
        return true
      }
      XCTAssertEqual(calls, 0)
      XCTAssertEqual(Array(b), [0, 1, 1, 2, 3])
    }

    /// 空のMultiSetに対するBound範囲のeraseは、無駄なCoW(共有される空シングルトン
    /// バッファからの退避)を発生させないこと。
    func testEraseBoundsOnEmptyMultiSetDoesNotCopy() throws {
      var b = RedBlackTreeMultiSet<Int>()
      XCTAssertEqual(b._copyCount, 0)
      b.erase(lowerBound(0)..<upperBound(10))
      XCTAssertEqual(b._copyCount, 0, "空の削除はバッファのコピーを発生させないはず")
      b.erase(lowerBound(0)..<upperBound(10)) { _ in true }
      XCTAssertEqual(b._copyCount, 0, "空の削除はバッファのコピーを発生させないはず")
      XCTAssertTrue(b.isEmpty)
    }

    /// 空のMultiSetに対するIndex範囲・範囲式・全範囲のeraseは、無駄なCoW(共有される空シングルトン
    /// バッファからの退避)を発生させず、`endIndex`を返すこと。
    func testEraseIndexRangeOnEmptyMultiSetDoesNotCopy() throws {
      var b = RedBlackTreeMultiSet<Int>()
      XCTAssertEqual(b._copyCount, 0)
      let range: RedBlackTreeIndexRange = b.equalRange(0)
      XCTAssertEqual(b.erase(range), b.endIndex)
      XCTAssertEqual(b._copyCount, 0, "空の削除はバッファのコピーを発生させないはず")
      b.erase(range) { _ in true }
      XCTAssertEqual(b._copyCount, 0, "空の削除はバッファのコピーを発生させないはず")
      XCTAssertEqual(b.erase(b.startIndex..<b.endIndex), b.endIndex)
      XCTAssertEqual(b._copyCount, 0, "空の削除はバッファのコピーを発生させないはず")
      b.erase(b.startIndex..<b.endIndex) { _ in true }
      XCTAssertEqual(b._copyCount, 0, "空の削除はバッファのコピーを発生させないはず")
      XCTAssertEqual(b.erase(...), b.endIndex)
      XCTAssertEqual(b._copyCount, 0, "空の削除はバッファのコピーを発生させないはず")
      XCTAssertTrue(b.isEmpty)
    }

    func testLessThanAndOrEqualMulti() throws {
      let b = RedBlackTreeMultiSet<Int>([0, 1, 1, 2])

      XCTAssertEqual(b[.lessThan(-1)], nil)
      XCTAssertEqual(b[.lessThan(0)], nil)
      XCTAssertEqual(b[.lessThan(1)], 0)
      XCTAssertEqual(b[.lessThan(2)], 1)
      XCTAssertEqual(b[.lessThan(3)], 2)

      XCTAssertEqual(b[.lessThanOrEqual(-1)], nil)
      XCTAssertEqual(b[.lessThanOrEqual(0)], 0)
      XCTAssertEqual(b[.lessThanOrEqual(1)], 1)
      XCTAssertEqual(b[.lessThanOrEqual(2)], 2)
      XCTAssertEqual(b[.lessThanOrEqual(3)], 2)
    }

    func testLessGreaterHelpers() throws {
      XCTAssertEqual(a[.lessThan(1)], 0)
      XCTAssertEqual(a[.greaterThan(1)], 2)
      XCTAssertEqual(a[.lessThanOrEqual(1)], 1)
      XCTAssertEqual(a[.greaterThanOrEqual(1)], 1)
    }

    func testBoundRangeOperators() throws {
      let view1 = a[lowerBound(0)..<upperBound(2)]
      XCTAssertEqual(Array(view1), [0, 1, 2])

      let view2 = a[lowerBound(0)...lowerBound(1)]
      XCTAssertEqual(Array(view2), [0, 1])

      let view3 = a[..<upperBound(1)]
      XCTAssertEqual(Array(view3), [0, 1])

      let view4 = a[...upperBound(1)]
      XCTAssertEqual(Array(view4), [0, 1, 2])

      let view5 = a[lowerBound(1)...]
      XCTAssertEqual(Array(view5), [1, 2])
    }

    func testIsValidBoundsInvalidDoesNotCrash() throws {
      XCTAssertFalse(a.isValid(upperBound(10)..<lowerBound(-10)))
      XCTAssertTrue(a[upperBound(10)..<lowerBound(-10)].isEmpty)
      XCTAssertEqual(Array(a[upperBound(10)..<lowerBound(-10)]), [])
    }
  }
#endif

  import RedBlackTreeCollections
  import XCTest

  final class RedBlackTreeMultiSetBoundDistanceTests: RedBlackTreeTestCase {

    /// Bound式どうしの`distance(from:to:)`は、評価した2位置の間の要素数を返すこと。
    func testDistanceBetweenBoundExpressions() {
      let c = RedBlackTreeMultiSet<Int>([0, 1, 1, 2, 2, 2, 3])
      XCTAssertEqual(c.distance(from: lowerBound(1), to: upperBound(2)), 5, "同値キーをすべて含む")
      XCTAssertEqual(c.distance(from: lowerBound(2), to: upperBound(2)), 3, "同値キーの区間")
      XCTAssertEqual(c.distance(from: start(), to: end()), c.count)
      XCTAssertEqual(c.distance(from: lowerBound(2), to: lowerBound(2)), 0)
    }
  }
