//
//  SealdTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/08.
//

#if !COMPATIBLE_ATCODER_2025
  import RedBlackTreeModule
  import XCTest

  final class SealedTests2: RedBlackTreeTestCase {
    
    typealias SUT = RedBlackTreeSet<Int>

    var a = SUT()

    override func setUpWithError() throws {
      // Put setup code here. This method is called before the invocation of each test method in the class.
      try super.setUpWithError()
      a = .init(0..<20)
    }

    override func tearDownWithError() throws {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
      a = .init()
      try super.tearDownWithError()
    }

    func testSomething() throws {
      var b = a
      XCTAssertTrue(b.isValid(a.startIndex))
      XCTAssertTrue(a.isValid(b.startIndex))
      XCTAssertEqual(a.startIndex, b.startIndex)
      let b0 = b.startIndex
      b.removeFirst()  // この時点でCoWが発生する
      XCTAssertTrue(b0.isValid)  // 発行元(a)に対するチェックは有効を示す
      XCTAssertTrue(a.isValid(b0))  // 直感に反するが致し方なし
      XCTAssertEqual(b.sorted(), Array(1..<20))

      XCTAssertFalse(b.isValid(b0))  // とはいえこれがfalseにならないと困る.

      // 簡略化したメンタルモデルがイメージできない状況なので、すこし困っている
    }

    func testSomething1() throws {
      var b = a
      XCTAssertTrue(b.isValid(a.startIndex))
      XCTAssertTrue(a.isValid(b.startIndex))
      XCTAssertEqual(a.startIndex, b.startIndex)
      b.removeLast()  // この時点でCoWが発生する
      let b0 = b.startIndex
      b.removeFirst()  // CoWが発生しない
      XCTAssertFalse(b0.isValid)
      XCTAssertFalse(b.isValid(b0))
      XCTAssertFalse(a.isValid(b0))
      XCTAssertEqual(b.sorted(), Array(1..<19))
    }

    func testSomething2() throws {
      XCTAssertTrue(a.isValid(a.startIndex))
      let a0 = a.startIndex
      a.removeFirst()
      XCTAssertFalse(a0.isValid)  // 発行元に対するチェックは無効を示す
      XCTAssertFalse(a.isValid(a0))
      XCTAssertEqual(a.sorted(), Array(1..<20))
    }
  }
#endif
