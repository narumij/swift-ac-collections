//
//  UnsafeNodeFreshPoolTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/07.
//

import XCTest

#if DEBUG
  @testable import RedBlackTreeModule

  struct FreshPoolFixture<_Value>: UnsafeNodeFreshPool {
    typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
    var freshBucketHead: ReserverHeaderPointer?
    var freshBucketCurrent: ReserverHeaderPointer?
    var freshBucketLast: ReserverHeaderPointer?
    var freshPoolCapacity: Int = 0
    var freshPoolUsedCount: Int = 0
    var count: Int = 0
    var freshBucketCount: Int = 0
    var nullptr: _NodePtr { UnsafeNode.nullptr }
  }

  final class UnsafeNodeFreshPoolTests: XCTestCase {

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
        XCTAssertEqual( 1 << lz, 64)
        let mask = 1 << (lz - 1) - 1
        let offset = (stride & mask == 0) ? -1 : 0
        //      let shift = Int.bitWidth - masked.leadingZeroBitCount - 1
        XCTAssertFalse(stride & mask == 0)
        XCTAssertEqual( 1 << (lz + offset), 64)
        XCTAssertEqual( 1024 >> (lz + offset), 1024 / 64)
        //      XCTAssertEqual( 1 << shift, 64)
        //      XCTAssertEqual( 1024 >> shift, 1024 / 64)
      }
      do {
        let stride = 32
        let lz = Int.bitWidth - stride.leadingZeroBitCount
        XCTAssertEqual(lz, 6)
        XCTAssertEqual( 1 << lz, 64)
        let mask = 1 << (lz - 1) - 1
        let offset = (stride & mask == 0) ? -1 : 0
        XCTAssertTrue(stride & mask == 0)
        XCTAssertEqual( 1 << (lz + offset), 32)
        XCTAssertEqual( 1024 >> (lz + offset), 1024 / 32)
        //      XCTAssertEqual( 1 << shift, 64)
        //      XCTAssertEqual( 1024 >> shift, 1024 / 64)
      }
    }
    
    // TODO: 実際にメモリを確保し、要素数分たどり、末尾が一致または収まるか確認する

    func testAlignment1() throws {
      typealias _Value = UInt8
      typealias Fixture = FreshPoolFixture<_Value>
      XCTAssertEqual(MemoryLayout<_Value>.alignment, 1)
      for i in [0, 1, 256, 1024] {
        do {
          let (size1, alignment1) = Fixture.allocationSize(capacity: i)
          let (size2, alignment2) = Fixture.allocationSize2(capacity: i)
          XCTAssertEqual(size1, size2)
          XCTAssertEqual(alignment1, alignment2)
        }
        do {
          let (size1, alignment1) = UnsafePair<_Value>.allocationSize(capacity: i)
          let (size2, alignment2) = Fixture._allocationSize2(capacity: i)
          XCTAssertEqual(size1, size2, "capacity = \(i) [\(size1), \(size2)]")
          XCTAssertEqual(alignment1, alignment2)
        }
      }
    }

    func testAlignment2() throws {
      typealias _Value = UInt16
      typealias Fixture = FreshPoolFixture<_Value>
      XCTAssertEqual(MemoryLayout<_Value>.alignment, 2)
      for i in [0, 1, 256, 1024] {
        do {
          let (size1, alignment1) = Fixture.allocationSize(capacity: i)
          let (size2, alignment2) = Fixture.allocationSize2(capacity: i)
          XCTAssertEqual(size1, size2)
        }
        do {
          let (size1, alignment1) = UnsafePair<_Value>.allocationSize(capacity: i)
          let (size2, alignment2) = Fixture._allocationSize2(capacity: i)
          XCTAssertEqual(size1, size2)
        }
      }
    }

    func testAlignment4() throws {
      typealias _Value = UInt32
      typealias Fixture = FreshPoolFixture<_Value>
      XCTAssertEqual(MemoryLayout<_Value>.alignment, 4)
      for i in [0, 1, 256, 1024] {
        do {
          let (size1, alignment1) = Fixture.allocationSize(capacity: i)
          let (size2, alignment2) = Fixture.allocationSize2(capacity: i)
          XCTAssertEqual(size1, size2)
        }
        do {
          let (size1, alignment1) = UnsafePair<_Value>.allocationSize(capacity: i)
          let (size2, alignment2) = Fixture._allocationSize2(capacity: i)
          XCTAssertEqual(size1, size2)
        }
      }
    }

    func testAlignment8() throws {
      typealias _Value = Int
      typealias Fixture = FreshPoolFixture<_Value>
      XCTAssertEqual(MemoryLayout<_Value>.alignment, 8)
      for i in [0, 1, 256, 1024] {
        do {
          let (size1, alignment1) = Fixture.allocationSize(capacity: i)
          let (size2, alignment2) = Fixture.allocationSize2(capacity: i)
          XCTAssertEqual(size1, size2)
        }
        do {
          let (size1, alignment1) = UnsafePair<_Value>.allocationSize(capacity: i)
          let (size2, alignment2) = Fixture._allocationSize2(capacity: i)
          XCTAssertEqual(size1, size2)
        }
      }
    }

    func testAlignment16() throws {
      typealias _Value = SIMD4<Float>
      typealias Fixture = FreshPoolFixture<_Value>
      XCTAssertEqual(MemoryLayout<_Value>.alignment, 16)
      for i in [0, 1, 256, 1024] {
        do {
          let (size1, alignment1) = Fixture.allocationSize(capacity: i)
          let (size2, alignment2) = Fixture.allocationSize2(capacity: i)
          XCTAssertEqual(size1, size2)
        }
        do {
          let (size1, alignment1) = UnsafePair<_Value>.allocationSize(capacity: i)
          let (size2, alignment2) = Fixture._allocationSize2(capacity: i)
          XCTAssertEqual(size1, size2)
        }
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
