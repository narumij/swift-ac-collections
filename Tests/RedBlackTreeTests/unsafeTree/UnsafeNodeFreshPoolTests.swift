//
//  UnsafeNodeFreshPoolTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/07.
//

import XCTest

#if DEBUG
  @testable import RedBlackTreeModule

  struct FreshPoolFixture<_PayloadValue>: _FreshPool {
    var freshBucketCurrent: RedBlackTreeModule._BucketQueue?

    var payload: _MemoryLayout

    func didUpdateFreshBucketHead() {

    }

    typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
    var freshBucketHead: _BucketPointer?
    //    var freshBucketCurrent: _BucketPointer?
    var freshBucketLast: _BucketPointer?
    var freshPoolCapacity: Int = 0
    var freshPoolUsedCount: Int = 0
    var count: Int = 0
    var freshBucketCount: Int = 0
    var nullptr: _NodePtr { UnsafeNode.nullptr }
    var freshBucketAllocator: RedBlackTreeModule._BucketAllocator
  }

  final class UnsafeNodeFreshPoolTests: RedBlackTreeTestCase {

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

    func testPaged0() throws {
      do {
        let stride = 33
        let lz = Int.bitWidth - stride.leadingZeroBitCount
        XCTAssertEqual(lz, 6)
        XCTAssertEqual(1 << lz, 64)
        let mask = 1 << (lz - 1) - 1
        let offset = (stride & mask == 0) ? -1 : 0
        //      let shift = Int.bitWidth - masked.leadingZeroBitCount - 1
        XCTAssertFalse(stride & mask == 0)
        XCTAssertEqual(1 << (lz + offset), 64)
        XCTAssertEqual(1024 >> (lz + offset), 1024 / 64)
        //      XCTAssertEqual( 1 << shift, 64)
        //      XCTAssertEqual( 1024 >> shift, 1024 / 64)
      }
      do {
        let stride = 32
        let lz = Int.bitWidth - stride.leadingZeroBitCount
        XCTAssertEqual(lz, 6)
        XCTAssertEqual(1 << lz, 64)
        let mask = 1 << (lz - 1) - 1
        let offset = (stride & mask == 0) ? -1 : 0
        XCTAssertTrue(stride & mask == 0)
        XCTAssertEqual(1 << (lz + offset), 32)
        XCTAssertEqual(1024 >> (lz + offset), 1024 / 32)
        //      XCTAssertEqual( 1 << shift, 64)
        //      XCTAssertEqual( 1024 >> shift, 1024 / 64)
      }
    }

    func testPerformanceExample() throws {
      // This is an example of a performance test case.
      self.measure {
        // Put the code you want to measure the time of here.
      }
    }

  }
#endif
