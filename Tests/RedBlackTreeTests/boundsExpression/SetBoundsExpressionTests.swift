//
//  SetBoundsExpressionTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/08.
//

#if DEBUG && !COMPATIBLE_ATCODER_2025
  import XCTest
  import RedBlackTreeModule

  final class SetBoundsExpressionTests: XCTestCase {

    let a = RedBlackTreeSet<Int>(0..<3)

    override func setUpWithError() throws {
      // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
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
          end().advanced(by: -5, limit: start().advanced(by: 4))), .lowerOutOfBounds)
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
        .lowerOutOfBounds)
    }

    func testLimitedAdvance6() throws {
      XCTAssertEqual(
        a._error(start().advanced(by: 1).advanced(by: -5, limit: .debug(.null))),
        .lowerOutOfBounds)

      XCTAssertEqual(
        a._error(start().advanced(by: 2).advanced(by: -5, limit: .debug(.null))),
        .lowerOutOfBounds)

      XCTAssertEqual(
        a._error(start().advanced(by: 3).advanced(by: -5, limit: .debug(.null))),
        .lowerOutOfBounds)

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
    }
  }
#endif
