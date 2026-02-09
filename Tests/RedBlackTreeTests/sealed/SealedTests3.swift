//
//  SealdTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/08.
//

#if !COMPATIBLE_ATCODER_2025
  import RedBlackTreeModule
  import XCTest

  final class SealedTests3: XCTestCase {

    typealias SUT = RedBlackTreeKeyOnlyRangeView<RedBlackTreeSet<Int>>

    var _a = RedBlackTreeSet<Int>(0..<20)

    override func setUpWithError() throws {
      // Put setup code here. This method is called before the invocation of each test method in the class.
      _a = .init(0..<20)
    }

    override func tearDownWithError() throws {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSomething() throws {
      let a: SUT = _a[_a.startIndex..<_a.endIndex]
      var b: SUT = a
      XCTAssertTrue(b.isValid(index: a.startIndex))
      XCTAssertTrue(a.isValid(index: b.startIndex))
      XCTAssertEqual(a.startIndex, b.startIndex)
      let b0 = b.startIndex
      b.removeFirst()  // この時点でCoWが発生する
      XCTAssertTrue(b0.isValid)  // 発行元(a)に対するチェックは有効を示す
      XCTAssertTrue(a.isValid(index: b0))  // 直感に反するが致し方なし
      XCTAssertEqual(b.sorted(), Array(1..<20))

      XCTAssertFalse(b.isValid(index: b0))  // とはいえこれがfalseにならないと困る.

      // 簡略化したメンタルモデルがイメージできない状況なので、すこし困っている
    }

    func testSomething1() throws {
      let a: SUT = _a[_a.startIndex..<_a.endIndex]
      var b: SUT = a
      XCTAssertTrue(b.isValid(index: a.startIndex))
      XCTAssertTrue(a.isValid(index: b.startIndex))
      XCTAssertEqual(a.startIndex, b.startIndex)
      b.removeLast()  // この時点でCoWが発生する
      let b0 = b.startIndex
      b.removeFirst()  // CoWが発生しない
      XCTAssertTrue(b0.isValid)  // bそのものは有効
      XCTAssertFalse(b.isValid(index: b0))
      XCTAssertTrue(a.isValid(index: b0))  // aにとっては有効なまま
      XCTAssertEqual(b.sorted(), Array(1..<19))
    }

    func testSomething2() throws {
      var a: SUT = _a[_a.startIndex..<_a.endIndex]
      XCTAssertTrue(a.isValid(index: a.startIndex))
      let a0 = a.startIndex
      a.removeFirst()
      XCTAssertTrue(a0.isValid)  // 発行元に対するチェックは無効を示す
      XCTAssertFalse(a.isValid(index: a0))
      XCTAssertEqual(a.sorted(), Array(1..<20))
    }
  }
#endif
