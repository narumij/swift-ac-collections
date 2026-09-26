//
//  UnsafeTreeMemoryTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/07.
//

import RedBlackTreeCollections
import XCTest

final class UnsafeTreeMemoryTests: RedBlackTreeTestCase {

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

    XCTAssertEqual(MemoryLayout<RedBlackTreePair<Int32, Int32>>.size, 8)
    XCTAssertEqual(MemoryLayout<RedBlackTreePair<Int32, Int>>.size, 16)
    XCTAssertEqual(MemoryLayout<RedBlackTreePair<Int, Int32>>.size, 12)
    XCTAssertEqual(MemoryLayout<RedBlackTreePair<Int, Int>>.size, 16)
    XCTAssertEqual(MemoryLayout<RedBlackTreePair<Int32, SIMD4<Float>>>.size, 32)
    XCTAssertEqual(MemoryLayout<RedBlackTreePair<SIMD4<Float>, Int32>>.size, 20)
    XCTAssertEqual(MemoryLayout<RedBlackTreePair<Int, SIMD4<Int>>>.size, 48)
    XCTAssertEqual(MemoryLayout<RedBlackTreePair<SIMD4<Int>, Int>>.size, 40)
  }

  func testStride() throws {

    #if !DEBUG
      XCTAssertEqual(MemoryLayout<_Bucket>.size, 24)
    #endif

    #if !DEBUG && USE_COMPACT_NODE_METADATA
      XCTAssertEqual(MemoryLayout<UnsafeNode>.stride, 32)
    #endif

    #if !DEBUG && !USE_COMPACT_NODE_METADATA
      XCTAssertEqual(MemoryLayout<UnsafeNode>.stride, 40)
    #endif
  }

  func testAligments0() throws {
    XCTAssertEqual(
      MemoryLayout<UnsafeNode>.alignment,
      MemoryLayout<UnsafeTreeV2BufferHeader>.alignment)
  }

  func testPairAlignmentsAndStrides() throws {
    XCTAssertEqual(MemoryLayout<RedBlackTreePair<Int32, Int32>>.alignment, 4)
    XCTAssertEqual(MemoryLayout<RedBlackTreePair<Int32, Int32>>.stride, 8)

    XCTAssertEqual(MemoryLayout<RedBlackTreePair<Int32, Int>>.alignment, 8)
    XCTAssertEqual(MemoryLayout<RedBlackTreePair<Int32, Int>>.stride, 16)

    XCTAssertEqual(MemoryLayout<RedBlackTreePair<Int, Int32>>.alignment, 8)
    XCTAssertEqual(MemoryLayout<RedBlackTreePair<Int, Int32>>.stride, 16)

    XCTAssertEqual(MemoryLayout<RedBlackTreePair<Int, Int>>.alignment, 8)
    XCTAssertEqual(MemoryLayout<RedBlackTreePair<Int, Int>>.stride, 16)

    XCTAssertEqual(MemoryLayout<RedBlackTreePair<Int32, SIMD4<Float>>>.alignment, 16)
    XCTAssertEqual(MemoryLayout<RedBlackTreePair<Int32, SIMD4<Float>>>.stride, 32)

    XCTAssertEqual(MemoryLayout<RedBlackTreePair<SIMD4<Float>, Int32>>.alignment, 16)
    XCTAssertEqual(MemoryLayout<RedBlackTreePair<SIMD4<Float>, Int32>>.stride, 32)

    XCTAssertEqual(MemoryLayout<RedBlackTreePair<Int, SIMD4<Int>>>.alignment, 16)
    XCTAssertEqual(MemoryLayout<RedBlackTreePair<Int, SIMD4<Int>>>.stride, 48)

    XCTAssertEqual(MemoryLayout<RedBlackTreePair<SIMD4<Int>, Int>>.alignment, 16)
    XCTAssertEqual(MemoryLayout<RedBlackTreePair<SIMD4<Int>, Int>>.stride, 48)
  }

  #if ENABLE_PERFORMANCE_TESTING
  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  #endif
}
