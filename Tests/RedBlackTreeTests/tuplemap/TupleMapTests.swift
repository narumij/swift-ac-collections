//
//  TupleMapTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/06/16.
//

import XCTest

@testable import RedBlackTreeModule

final class TupleMapTests: XCTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testInit() throws {
    let a: RedBlackTreeTupleMap<Int, Int> = [1: 1]
    let b: RedBlackTreeTupleMap<Int, Int, Int> = [(1, 1): 1]
    let c: RedBlackTreeTupleMap<Int, Int, Int, Int> = [(1, 1, 1): 1]
    let d: RedBlackTreeTupleMap<Int, Int, Int, Int, Int> = [(1, 1, 1, 1): 1]
    XCTAssertEqual(a[1], 1)
    XCTAssertEqual(b[(1, 1)], 1)
    XCTAssertEqual(c[(1, 1, 1)], 1)
    XCTAssertEqual(d[(1, 1, 1, 1)], 1)
  }

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }

}
