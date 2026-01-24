//
//  BucketCountTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/02.
//

import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

#if DEBUG && ALLOCATION_DRILL && false
  final class BucketCountTests: RedBlackTreeTestCase {

    func testExample1() throws {
      var f = RedBlackTreeSet<Int>()
      allocationChunkSize = 1
      for i in 0..<10 {
        f.reserveCapacity(i)
      }
      XCTAssertEqual(f.__tree_.header.freshBucketCount, 9)
    }

    func testExample2() throws {
      var f = RedBlackTreeSet<Int>()
      allocationChunkSize = 2
      for i in 0..<10 {
        f.reserveCapacity(i)
      }
      XCTAssertEqual(f.__tree_.header.freshBucketCount, 5)
    }

    func testExample3() throws {
      var f = RedBlackTreeSet<Int>()
      allocationChunkSize = 3
      for i in 0..<10 {
        f.reserveCapacity(i)
      }
      XCTAssertEqual(f.__tree_.header.freshBucketCount, 3)
    }
  }
#endif
