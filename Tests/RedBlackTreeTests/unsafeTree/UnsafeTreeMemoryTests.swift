//
//  UnsafeTreeMemoryTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/07.
//

import RedBlackTreeModule
import XCTest

final class UnsafeTreeMemoryTests: XCTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testExample() throws {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    // Any test you write for XCTest can be annotated as throws and async.
    // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
    // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
  }

  func testSizes() throws {
    XCTAssertLessThanOrEqual(MemoryLayout<UnsafeNode>.size, 64)
    XCTAssertLessThanOrEqual(MemoryLayout<_Bucket>.size, 64)
  }

  func testStride() throws {
    #if !DEBUG
      XCTAssertEqual(MemoryLayout<UnsafeNode>.stride, 40)
    #endif
  }

  func testAligments0() throws {
    XCTAssertEqual(
      MemoryLayout<UnsafeNode>.alignment,
      MemoryLayout<UnsafeTreeV2BufferHeader>.alignment)
  }

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
}
