//
//  SetBoundsExpressionTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/08.
//

#if DEBUG && !COMPATIBLE_ATCODER_2025
  import XCTest
  import RedBlackTreeCollections

  final class RedBlackTreeSetBoundExpressionTests: RedBlackTreeTestCase {

    let a = RedBlackTreeSet<Int>(0..<3)

    override func setUpWithError() throws {
      // Put setup code here. This method is called before the invocation of each test method in the class.
      try super.setUpWithError()
    }

    override func tearDownWithError() throws {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
      try super.tearDownWithError()
    }

    func testAfter() throws {
      XCTAssertTrue(a.isValid(start()))
      XCTAssertEqual(a[start()], 0)

      XCTAssertTrue(a.isValid(start().after))
      XCTAssertEqual(a[start().after], 1)

      XCTAssertTrue(a.isValid(start().after.after))
      XCTAssertEqual(a[start().after.after], 2)

      XCTAssertFalse(a.isValid(start().after.after.after))
      XCTAssertEqual(a[start().after.after.after], nil)

      a._withSealed(start().after.after.after, end()) { a, b in
        // 終端となる
        XCTAssertEqual(a, b)
        // 終端まではエラーが発生しない
        XCTAssertEqual(a.error, nil)
      }

      XCTAssertFalse(a.isValid(start().after.after.after.after))
      XCTAssertEqual(a[start().after.after.after.after], nil)

      a._withSealed(start().after.after.after.after, end()) { a, b in
        // 終端の次はnull相当
        XCTAssertNotEqual(a, b)
        // 終端の次は内部エラーとなる
        XCTAssertEqual(a.error, .upperOutOfBounds)
      }
    }

    func testBefore() throws {

      XCTAssertFalse(a.isValid(end()))
      XCTAssertNil(a[end()])

      XCTAssertTrue(a.isValid(end().before))
      XCTAssertTrue(a.isValid(end().before.before))
      XCTAssertTrue(a.isValid(end().before.before.before))

      // エラーではない
      XCTAssertNil(a._error(end().before.before.before))
      XCTAssertFalse(a.isValid(end().before.before.before.before))

      // 内部エラー
      XCTAssertEqual(a._error(end().before.before.before.before), .lowerOutOfBounds)
    }

    func testAdvancePositive() throws {
      XCTAssertTrue(a.isValid(start()))
      XCTAssertTrue(a.isValid(start().advanced(by: 1)))
      XCTAssertTrue(a._isEqual(start().advanced(by: 1), start().after))
      XCTAssertTrue(a.isValid(start().advanced(by: 2)))
      XCTAssertTrue(a._isEqual(start().advanced(by: 2), start().after.after))

      XCTAssertFalse(a.isValid(start().advanced(by: 3)))
      XCTAssertTrue(a._isEqual(start().advanced(by: 3), start().after.after.after))
      XCTAssertTrue(a._isEqual(start().advanced(by: 3), end()))
      XCTAssertNil(a._error(start().advanced(by: 3)))

      XCTAssertFalse(a.isValid(start().advanced(by: 4)))
      XCTAssertTrue(a._isEqual(start().advanced(by: 4), start().after.after.after.after))
      XCTAssertEqual(a._error(start().advanced(by: 4)), .upperOutOfBounds)
      XCTAssertFalse(a._isEqual(start().advanced(by: 4), end()))
    }

    func testAdvanceNegative() throws {
      XCTAssertFalse(a.isValid(end()))
      XCTAssertTrue(a.isValid(end().advanced(by: -1)))
      XCTAssertTrue(a._isEqual(end().advanced(by: -1), end().before))
      XCTAssertTrue(a.isValid(end().advanced(by: -2)))
      XCTAssertTrue(a._isEqual(end().advanced(by: -2), end().before.before))
      XCTAssertTrue(a.isValid(end().advanced(by: -3)))
      XCTAssertTrue(a._isEqual(end().advanced(by: -3), end().before.before.before))
      XCTAssertFalse(a.isValid(end().advanced(by: -4)))
      XCTAssertTrue(a._isEqual(end().advanced(by: -4), end().before.before.before.before))
      XCTAssertFalse(a.isValid(end().advanced(by: -5)))
      XCTAssertTrue(a._isEqual(end().advanced(by: -5), end().before.before.before.before.before))
      XCTAssertEqual(a._error(end().advanced(by: -5)), .lowerOutOfBounds)
    }

    func testAdvance() throws {
      // 内部的にエラー
      XCTAssertEqual(a._error(start().advanced(by: -1)), .lowerOutOfBounds)
      // 内部的にエラー
      XCTAssertEqual(a._error(end().advanced(by: 1)), .upperOutOfBounds)
    }

    func testLimitedAdvance() throws {
      // start()で止まる
      XCTAssertTrue(
        a._isEqual(
          start().advanced(by: -1, limit: start()), start()))
      // end()で止まる
      XCTAssertTrue(
        a._isEqual(
          end().advanced(by: 1, limit: end()), end()))
    }

    func testLimitedAdvance2() throws {
      XCTAssertTrue(
        a._isEqual(
          end().advanced(by: -5, limit: start()), start()))
      XCTAssertTrue(
        a._isEqual(
          end().advanced(by: -5, limit: start().advanced(by: 1)), start().advanced(by: 1)))
      XCTAssertTrue(
        a._isEqual(
          end().advanced(by: -5, limit: start().advanced(by: 2)), start().advanced(by: 2)))
      XCTAssertTrue(
        a._isEqual(
          end().advanced(by: -5, limit: start().advanced(by: 3)), start().advanced(by: 3)))
      XCTAssertEqual(
        a._error(
          end().advanced(by: -5, limit: start().advanced(by: 4))), .upperOutOfBounds)
    }

    func testLimitedAdvance3() throws {
      XCTAssertTrue(
        a._isEqual(
          start().advanced(by: 5, limit: start()), start()))
      XCTAssertTrue(
        a._isEqual(
          start().advanced(by: 5, limit: start().advanced(by: 1)), start().advanced(by: 1)))
      XCTAssertTrue(
        a._isEqual(
          start().advanced(by: 5, limit: start().advanced(by: 2)), start().advanced(by: 2)))
      XCTAssertTrue(
        a._isEqual(
          start().advanced(by: 5, limit: start().advanced(by: 3)), start().advanced(by: 3)))
      XCTAssertEqual(
        a._error(
          start().advanced(by: 5, limit: start().advanced(by: 4))), .upperOutOfBounds)
    }

    func testLimitedAdvance4() throws {

      XCTAssertTrue(
        a._isEqual(
          start().advanced(by: 1).advanced(by: -5, limit: start().advanced(by: 1)),
          start().advanced(by: 1)))
      XCTAssertTrue(
        a._isEqual(
          start().advanced(by: 2).advanced(by: -5, limit: start().advanced(by: 2)),
          start().advanced(by: 2)))
      XCTAssertTrue(
        a._isEqual(
          start().advanced(by: 3).advanced(by: -5, limit: start().advanced(by: 3)),
          start().advanced(by: 3)))
      XCTAssertTrue(
        a._isEqual(
          start().advanced(by: 4).advanced(by: -5, limit: start().advanced(by: 4)),
          start().advanced(by: 4)))
    }

    func testLimitedAdvance5() throws {
      XCTAssertEqual(
        a._error(start().advanced(by: 1).advanced(by: -5, limit: start().advanced(by: 2))),
        .lowerOutOfBounds)

      XCTAssertEqual(
        a._error(start().advanced(by: 2).advanced(by: -5, limit: start().advanced(by: 3))),
        .lowerOutOfBounds)

      XCTAssertEqual(
        a._error(start().advanced(by: 3).advanced(by: -5, limit: start().advanced(by: 4))),
        .upperOutOfBounds)
    }

    func testLimitedAdvance6() throws {
      XCTAssertEqual(
        a._error(start().advanced(by: 1).advanced(by: -5, limit: .debug(.null))),
        .null)

      XCTAssertEqual(
        a._error(start().advanced(by: 2).advanced(by: -5, limit: .debug(.null))),
        .null)

      XCTAssertEqual(
        a._error(start().advanced(by: 3).advanced(by: -5, limit: .debug(.null))),
        .null)

      XCTAssertEqual(
        a._error(.debug(.null).advanced(by: -5, limit: .debug(.null))),
        .null)
    }

    func testLowerBound() throws {
      XCTAssertTrue(a._isEqual(lowerBound(-2), start().advanced(by: 0)))
      XCTAssertTrue(a._isEqual(lowerBound(-1), start().advanced(by: 0)))
      XCTAssertTrue(a._isEqual(lowerBound(0), start().advanced(by: 0)))
      XCTAssertTrue(a._isEqual(lowerBound(1), start().advanced(by: 1)))
      XCTAssertTrue(a._isEqual(lowerBound(2), start().advanced(by: 2)))
      XCTAssertTrue(a._isEqual(lowerBound(3), start().advanced(by: 3)))
      XCTAssertTrue(a._isEqual(lowerBound(4), end()))
      XCTAssertTrue(a._isEqual(lowerBound(5), end()))
    }

    func testUpperBound() throws {
      XCTAssertTrue(a._isEqual(upperBound(-2), start().advanced(by: 0)))
      XCTAssertTrue(a._isEqual(upperBound(-1), start().advanced(by: 0)))
      XCTAssertTrue(a._isEqual(upperBound(0), start().advanced(by: 1)))
      XCTAssertTrue(a._isEqual(upperBound(1), start().advanced(by: 2)))
      XCTAssertTrue(a._isEqual(upperBound(2), start().advanced(by: 3)))
      XCTAssertTrue(a._isEqual(upperBound(3), end()))
      XCTAssertTrue(a._isEqual(upperBound(4), end()))
    }

    func testFind() throws {
      XCTAssertTrue(a._isEqual(find(-1), end()))
      XCTAssertTrue(a._isEqual(find(0), start().advanced(by: 0)))
      XCTAssertTrue(a._isEqual(find(1), start().advanced(by: 1)))
      XCTAssertTrue(a._isEqual(find(2), start().advanced(by: 2)))
      XCTAssertTrue(a._isEqual(find(3), start().advanced(by: 3)))
      XCTAssertTrue(a._isEqual(find(4), end()))
      XCTAssertTrue(a._isEqual(find(5), end()))
    }

    func testLast() throws {
      XCTAssertTrue(a._isEqual(.last, end().before))
      XCTAssertEqual(a[last()], 2)
    }

    func testViewCountAndEraseBound() throws {
      var b = RedBlackTreeSet<Int>(0..<3)
      XCTAssertEqual(b[lowerBound(0)..<upperBound(2)].count, 3)

      let removed = b.erase(find(1))
      XCTAssertEqual(removed, 1)
      XCTAssertEqual(Array(b), [0, 2])
    }

    func testSubscriptBoundsModifyPopFirst() throws {
      var b = RedBlackTreeSet<Int>(0..<4)
      let removed = b[lowerBound(0)..<upperBound(2)].popFirst()
      XCTAssertEqual(removed, 0)
      XCTAssertEqual(Array(b), [1, 2, 3])
    }

    func testEraseBounds() throws {
      var b = RedBlackTreeSet<Int>(0..<5)
      b.erase(lowerBound(1)..<upperBound(3))
      XCTAssertEqual(Array(b), [0, 4])
    }

    func testEraseBoundsWhere() throws {
      var b = RedBlackTreeSet<Int>(0..<5)
      b.erase(lowerBound(0)..<upperBound(4)) { $0 % 2 == 0 }
      XCTAssertEqual(Array(b), [1, 3])
    }

    /// 下端が上端より後ろにある逆向きの範囲は空の範囲として扱い、何も削除しないこと。
    func testEraseReversedBoundsRemovesNothing() throws {
      var b = RedBlackTreeSet<Int>(0..<5)
      b.erase(upperBound(10)..<lowerBound(-10))
      XCTAssertEqual(Array(b), [0, 1, 2, 3, 4])
      b.erase(lowerBound(3)..<lowerBound(1))
      XCTAssertEqual(Array(b), [0, 1, 2, 3, 4])
    }

    /// 逆向きの範囲では、条件クロージャを一度も呼ばず、何も削除しないこと。
    func testEraseReversedBoundsWhereRemovesNothingAndSkipsPredicate() throws {
      var b = RedBlackTreeSet<Int>(0..<5)
      var calls = 0
      b.erase(lowerBound(3)..<lowerBound(1)) { _ in
        calls += 1
        return true
      }
      XCTAssertEqual(calls, 0)
      XCTAssertEqual(Array(b), [0, 1, 2, 3, 4])
    }

    /// 空のSetに対するBound範囲のeraseは、無駄なCoW(共有される空シングルトン
    /// バッファからの退避)を発生させないこと。
    func testEraseBoundsOnEmptySetDoesNotCopy() throws {
      var b = RedBlackTreeSet<Int>()
      XCTAssertEqual(b._copyCount, 0)
      b.erase(lowerBound(0)..<upperBound(10))
      XCTAssertEqual(b._copyCount, 0, "空の削除はバッファのコピーを発生させないはず")
      b.erase(lowerBound(0)..<upperBound(10)) { _ in true }
      XCTAssertEqual(b._copyCount, 0, "空の削除はバッファのコピーを発生させないはず")
      XCTAssertTrue(b.isEmpty)
    }

    /// 空のSetに対するIndex範囲・範囲式・全範囲のeraseは、無駄なCoW(共有される空シングルトン
    /// バッファからの退避)を発生させず、`endIndex`を返すこと。
    func testEraseIndexRangeOnEmptySetDoesNotCopy() throws {
      var b = RedBlackTreeSet<Int>()
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

    func testIsValidBoundsInvalidDoesNotCrash() throws {
      XCTAssertFalse(a.isValid(upperBound(10)..<lowerBound(-10)))
      XCTAssertTrue(a[upperBound(10)..<lowerBound(-10)].isEmpty)
      XCTAssertEqual(Array(a[upperBound(10)..<lowerBound(-10)]), [])
    }

    func testLessThanAllKeys() throws {
      let cases: [(key: Int, expected: Int?)] = [
        (-1, nil),
        (0, nil),
        (1, 0),
        (2, 1),
        (3, 2),
        (4, 2),
      ]

      for (key, expected) in cases {
        XCTAssertEqual(a[.lessThan(key)], expected, "key=\(key)")
        XCTAssertEqual(a.isValid(.lessThan(key)), expected != nil, "key=\(key)")
      }
    }

    func testLessThanOrEqualAllKeys() throws {
      let cases: [(key: Int, expected: Int?)] = [
        (-1, nil),
        (0, 0),
        (1, 1),
        (2, 2),
        (3, 2),
      ]

      for (key, expected) in cases {
        XCTAssertEqual(a[.lessThanOrEqual(key)], expected, "key=\(key)")
        XCTAssertEqual(a.isValid(.lessThanOrEqual(key)), expected != nil, "key=\(key)")
      }
    }

    /// `.find(_:)`は等しい要素を指し、等しい要素が無ければendを指すこと
    func testFindAllKeys() throws {
      let cases: [(key: Int, expected: Int?)] = [
        (-1, nil),
        (0, 0),
        (1, 1),
        (2, 2),
        (3, nil),
      ]

      for (key, expected) in cases {
        XCTAssertEqual(a[.find(key)], expected, "key=\(key)")
        XCTAssertEqual(a.isValid(.find(key)), expected != nil, "key=\(key)")
      }
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

    func testEqualRange() throws {
      let view = a[equalRange(1)]
      XCTAssertEqual(Array(view), [1])
    }

    /// 単一のBoundExpressionによる添字アクセスが対応する要素(またはendではnil)を返すこと
    func testSingleBoundSubscriptReturnsElementOrNilAtEnd() throws {
      let multiplesOfFive = RedBlackTreeSet<Int>((0..<100).filter { $0 % 5 == 0 })

      XCTAssertEqual(multiplesOfFive[.start], 0)
      XCTAssertEqual(multiplesOfFive[.lowerBound(0)], 0)
      XCTAssertEqual(multiplesOfFive[.lowerBound(3)], 5)
      XCTAssertEqual(multiplesOfFive[.upperBound(5)], 10)
      XCTAssertNil(multiplesOfFive[.end])
    }

    #if DEBUG
      /// 別の木由来のindexを内包したBoundExpressionが、ALLOW_CROSS_TREE_INDEXの設定通りに解決されること
      func testBoundExpressionFromAnotherTreeResolvesAccordingToCrossTreeIndexTrait() throws {
        let other = RedBlackTreeSet<Int>(0..<3)

        for i in 0..<3 {
          let otherBound = RedBlackTreeBoundExpression<Int>.index(
            other.index(other.startIndex, offsetBy: i))

          #if ALLOW_CROSS_TREE_INDEX
            XCTAssertNotNil(a[otherBound])
          #else
            XCTAssertNil(a[otherBound])
          #endif
        }
      }
    #endif
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  import RedBlackTreeCollections
  import XCTest

  final class RedBlackTreeSetBoundDistanceTests: RedBlackTreeTestCase {

    /// Bound式どうしの`distance(from:to:)`は、評価した2位置の間の要素数を返すこと。
    func testDistanceBetweenBoundExpressions() {
      let c = RedBlackTreeSet<Int>(0..<10)
      XCTAssertEqual(c.distance(from: lowerBound(2), to: lowerBound(7)), 5)
      XCTAssertEqual(c.distance(from: lowerBound(2), to: upperBound(7)), 6)
      XCTAssertEqual(c.distance(from: start(), to: end()), c.count)
      XCTAssertEqual(c.distance(from: lowerBound(4), to: lowerBound(4)), 0)
    }
  }
#endif
