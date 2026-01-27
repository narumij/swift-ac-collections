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

    // TODO: 実際にメモリを確保し、要素数分たどり、末尾が一致または収まるか確認する

    // TODO: advanceでのalignedUpを削っても大丈夫かどうか引き続き検討

    // TODO: FIXME
    #if false
      func testAlignment1() throws {
        typealias _PayloadValue = UInt8
        typealias Fixture = FreshPoolFixture<_PayloadValue>
        XCTAssertEqual(MemoryLayout<_PayloadValue>.alignment, 1)
        for i in [0, 1, 256, 1024] {
          do {
            let (size1, alignment1) = Fixture.allocationSize(capacity: i)
            let (size2, alignment2) = Fixture.allocationSize2(capacity: i)
            XCTAssertEqual(size1, size2)
            XCTAssertEqual(alignment1, alignment2)
          }
          do {
            let (size1, alignment1) = UnsafePair<_PayloadValue>.allocationSize(capacity: i)
            let (size2, alignment2) = Fixture._allocationSize2(capacity: i)
            XCTAssertEqual(size1, size2, "capacity = \(i) [\(size1), \(size2)]")
            XCTAssertEqual(alignment1, alignment2)
          }
        }
      }

      func testAlignment2() throws {
        typealias _PayloadValue = UInt16
        typealias Fixture = FreshPoolFixture<_PayloadValue>
        XCTAssertEqual(MemoryLayout<_PayloadValue>.alignment, 2)
        for i in [0, 1, 256, 1024] {
          do {
            let (size1, alignment1) = Fixture.allocationSize(capacity: i)
            let (size2, alignment2) = Fixture.allocationSize2(capacity: i)
            XCTAssertEqual(size1, size2)
          }
          do {
            let (size1, alignment1) = UnsafePair<_PayloadValue>.allocationSize(capacity: i)
            let (size2, alignment2) = Fixture._allocationSize2(capacity: i)
            XCTAssertEqual(size1, size2)
          }
        }
      }

      func testAlignment4() throws {
        typealias _PayloadValue = UInt32
        typealias Fixture = FreshPoolFixture<_PayloadValue>
        XCTAssertEqual(MemoryLayout<_PayloadValue>.alignment, 4)
        for i in [0, 1, 256, 1024] {
          do {
            let (size1, alignment1) = Fixture.allocationSize(capacity: i)
            let (size2, alignment2) = Fixture.allocationSize2(capacity: i)
            XCTAssertEqual(size1, size2)
          }
          do {
            let (size1, alignment1) = UnsafePair<_PayloadValue>.allocationSize(capacity: i)
            let (size2, alignment2) = Fixture._allocationSize2(capacity: i)
            XCTAssertEqual(size1, size2)
          }
        }
      }

      func testAlignment8() throws {
        typealias _PayloadValue = Int
        typealias Fixture = FreshPoolFixture<_PayloadValue>
        XCTAssertEqual(MemoryLayout<_PayloadValue>.alignment, 8)
        for i in [0, 1, 256, 1024] {
          do {
            let (size1, alignment1) = Fixture.allocationSize(capacity: i)
            let (size2, alignment2) = Fixture.allocationSize2(capacity: i)
            XCTAssertEqual(size1, size2)
            XCTAssertEqual(alignment1, MemoryLayout<_PayloadValue>.alignment)
            XCTAssertEqual(alignment2, MemoryLayout<_PayloadValue>.alignment)
          }
          do {
            let (size1, alignment1) = UnsafePair<_PayloadValue>.allocationSize(capacity: i)
            let (size2, alignment2) = Fixture._allocationSize2(capacity: i)
            XCTAssertEqual(size1, size2)
            XCTAssertEqual(alignment1, MemoryLayout<_PayloadValue>.alignment)
            XCTAssertEqual(alignment2, MemoryLayout<_PayloadValue>.alignment)
          }
        }
      }

      func testAlignment16() throws {
        typealias _PayloadValue = SIMD4<Float>
        typealias Fixture = FreshPoolFixture<_PayloadValue>
        XCTAssertEqual(MemoryLayout<_PayloadValue>.alignment, 16)
        for i in [0, 1, 256, 1024] {
          do {
            let (size1, alignment1) = Fixture.allocationSize(capacity: i)
            let (size2, alignment2) = Fixture.allocationSize2(capacity: i)
            XCTAssertEqual(size1, size2)
            XCTAssertEqual(alignment1, MemoryLayout<_PayloadValue>.alignment)
            XCTAssertEqual(alignment2, MemoryLayout<_PayloadValue>.alignment)
          }
          do {
            let (size1, alignment1) = UnsafePair<_PayloadValue>.allocationSize(capacity: i)
            let (size2, alignment2) = Fixture._allocationSize2(capacity: i)
            XCTAssertEqual(size1, size2)
            XCTAssertEqual(alignment1, MemoryLayout<_PayloadValue>.alignment)
            XCTAssertEqual(alignment2, MemoryLayout<_PayloadValue>.alignment)
          }
        }
      }

      func testAllocationSize0() throws {
        typealias _PayloadValue = Int32
        typealias Fixture = FreshPoolFixture<_PayloadValue>
        typealias Raw = UnsafeRawPointer
        for _capacity in [2, 3, 5, 7, 11, 13, 1024, 1024 * 32] {
          let (_, bytes, stride, alignment) = Fixture.pagedCapacity(capacity: _capacity)
          let (bucket, capacity) = FreshPoolFixture<_PayloadValue>.createBucket(capacity: _capacity)
          XCTAssertEqual(bucket.pointee.stride, stride)
          //        XCTAssertEqual(bucket.pointee.alignment, alignment)
          var p = bucket.pointee.start
          var pp = UnsafeMutableRawPointer(bucket.pointee.start)
          for _ in 0..<capacity {
            p = bucket.pointee.advance(p)
            pp = pp.advanced(by: stride)
            XCTAssertEqual(p, pp)
            XCTAssertEqual(
              Raw(UnsafePair<_PayloadValue>.valuePointer(p)),
              Raw(UnsafePair<_PayloadValue>.valuePointer(p)).alignedUp(for: _PayloadValue.self))
            XCTAssertEqual(
              Raw(p.advanced(by: 1)).alignedUp(for: _PayloadValue.self), Raw(p.advanced(by: 1)))
          }

          do {
            let diff = Raw(bucket.pointee.start) - Raw(bucket)
            let minimum = MemoryLayout<_UnsafeNodeFreshBucket>.stride
            let maximum =
              minimum + max(0, MemoryLayout<_PayloadValue>.alignment - MemoryLayout<UnsafeNode>.alignment)
            XCTAssertLessThanOrEqual(minimum, maximum)
            XCTAssertLessThanOrEqual(minimum, diff)
            XCTAssertLessThanOrEqual(diff, maximum)
          }

          do {
            let diff = Raw(bucket).advanced(by: bytes) - Raw(p)
            let minimum = 0
            let maximum = max(
              0, MemoryLayout<_PayloadValue>.alignment - MemoryLayout<UnsafeNode>.alignment)
            XCTAssertLessThanOrEqual(minimum, maximum)
            XCTAssertLessThanOrEqual(minimum, diff)
            XCTAssertLessThanOrEqual(diff, maximum)
          }

          do {
            let diff =
              Raw(bucket).advanced(by: bytes)
              - Raw(
                Raw(bucket.pointee.advance(p, offset: -1).advanced(by: 1))
                  .assumingMemoryBound(to: _PayloadValue.self).advanced(by: 1))
            let minimum = 0
            let maximum = max(
              0, MemoryLayout<_PayloadValue>.alignment - MemoryLayout<UnsafeNode>.alignment)
            XCTAssertLessThanOrEqual(minimum, maximum)
            XCTAssertLessThanOrEqual(minimum, diff)
            XCTAssertLessThanOrEqual(diff, maximum)
          }

          do {
            let stride = (
              bucket: MemoryLayout<_UnsafeNodeFreshBucket>.stride,
              element: MemoryLayout<_PayloadValue>.stride + MemoryLayout<UnsafeNode>.stride
            )
            let minimum = 0
            let maximum = max(
              0, MemoryLayout<_PayloadValue>.alignment - MemoryLayout<UnsafeNode>.alignment)

            let diff = Raw(bucket).advanced(by: stride.bucket + capacity * stride.element) - Raw(p)
            XCTAssertLessThanOrEqual(minimum, maximum)
            XCTAssertLessThanOrEqual(minimum, diff)
            XCTAssertLessThanOrEqual(diff, maximum)
          }

          bucket.pointee.clear(_PayloadValue.self)
          bucket.deinitialize(count: 1)
          bucket.deallocate()
        }
      }

      func testAllocationSize1() throws {
        typealias _PayloadValue = Int
        typealias Fixture = FreshPoolFixture<_PayloadValue>
        typealias Raw = UnsafeRawPointer
        for _capacity in [2, 3, 5, 7, 11, 13, 1024, 1024 * 32] {
          let (_, bytes, stride, alignment) = Fixture.pagedCapacity(capacity: _capacity)
          let (bucket, capacity) = FreshPoolFixture<_PayloadValue>.createBucket(capacity: _capacity)
          XCTAssertEqual(bucket.pointee.stride, stride)
          //        XCTAssertEqual(bucket.pointee.alignment, alignment)
          var p = bucket.pointee.start
          var pp = UnsafeMutableRawPointer(bucket.pointee.start)
          for _ in 0..<capacity {
            p = bucket.pointee.advance(p)
            pp = pp.advanced(by: stride)
            XCTAssertEqual(p, pp)
            XCTAssertEqual(
              Raw(UnsafePair<_PayloadValue>.valuePointer(p)),
              Raw(UnsafePair<_PayloadValue>.valuePointer(p)).alignedUp(for: _PayloadValue.self))
            XCTAssertEqual(
              Raw(p.advanced(by: 1)).alignedUp(for: _PayloadValue.self), Raw(p.advanced(by: 1)))
          }

          do {
            let diff = Raw(bucket.pointee.start) - Raw(bucket)
            let minimum = MemoryLayout<_UnsafeNodeFreshBucket>.stride
            let maximum =
              minimum + max(0, MemoryLayout<_PayloadValue>.alignment - MemoryLayout<UnsafeNode>.alignment)
            XCTAssertLessThanOrEqual(minimum, maximum)
            XCTAssertLessThanOrEqual(minimum, diff)
            XCTAssertLessThanOrEqual(diff, maximum)
          }

          do {
            let diff = Raw(bucket).advanced(by: bytes) - Raw(p)
            let minimum = 0
            let maximum = max(
              0, MemoryLayout<_PayloadValue>.alignment - MemoryLayout<UnsafeNode>.alignment)
            XCTAssertLessThanOrEqual(minimum, maximum)
            XCTAssertLessThanOrEqual(minimum, diff)
            XCTAssertLessThanOrEqual(diff, maximum)
          }

          do {
            let diff =
              Raw(bucket).advanced(by: bytes)
              - Raw(
                Raw(bucket.pointee.advance(p, offset: -1).advanced(by: 1))
                  .assumingMemoryBound(to: _PayloadValue.self).advanced(by: 1))
            let minimum = 0
            let maximum = max(
              0, MemoryLayout<_PayloadValue>.alignment - MemoryLayout<UnsafeNode>.alignment)
            XCTAssertLessThanOrEqual(minimum, maximum)
            XCTAssertLessThanOrEqual(minimum, diff)
            XCTAssertLessThanOrEqual(diff, maximum)
          }

          do {
            let stride = (
              bucket: MemoryLayout<_UnsafeNodeFreshBucket>.stride,
              element: MemoryLayout<_PayloadValue>.stride + MemoryLayout<UnsafeNode>.stride
            )
            let minimum = 0
            let maximum = max(
              0, MemoryLayout<_PayloadValue>.alignment - MemoryLayout<UnsafeNode>.alignment)

            let diff = Raw(bucket).advanced(by: stride.bucket + capacity * stride.element) - Raw(p)
            XCTAssertLessThanOrEqual(minimum, maximum)
            XCTAssertLessThanOrEqual(minimum, diff)
            XCTAssertLessThanOrEqual(diff, maximum)
          }

          bucket.pointee.clear(_PayloadValue.self)
          bucket.deinitialize(count: 1)
          bucket.deallocate()
        }
      }

      func testAllocationSize2() throws {
        typealias _PayloadValue = SIMD4<Float>
        typealias Fixture = FreshPoolFixture<_PayloadValue>
        typealias Raw = UnsafeRawPointer
        for _capacity in [2, 3, 5, 7, 11, 13, 1024, 1024 * 32] {
          let (_, bytes, stride, alignment) = Fixture.pagedCapacity(capacity: _capacity)
          let (bucket, capacity) = FreshPoolFixture<_PayloadValue>.createBucket(capacity: _capacity)
          XCTAssertEqual(bucket.pointee.stride, stride)
          //        XCTAssertEqual(bucket.pointee.alignment, alignment)
          var p = bucket.pointee.start
          var pp = UnsafeMutableRawPointer(bucket.pointee.start)
          for _ in 0..<capacity {
            p = bucket.pointee.advance(p)
            pp = pp.advanced(by: stride)
            XCTAssertEqual(p, pp)
            XCTAssertEqual(
              Raw(UnsafePair<_PayloadValue>.valuePointer(p)),
              Raw(UnsafePair<_PayloadValue>.valuePointer(p)).alignedUp(for: _PayloadValue.self))
            XCTAssertEqual(
              Raw(p.advanced(by: 1)).alignedUp(for: _PayloadValue.self), Raw(p.advanced(by: 1)))
          }

          do {
            let diff = Raw(bucket.pointee.start) - Raw(bucket)
            let minimum = MemoryLayout<_UnsafeNodeFreshBucket>.stride
            let maximum =
              minimum + max(0, MemoryLayout<_PayloadValue>.alignment - MemoryLayout<UnsafeNode>.alignment)
            XCTAssertLessThanOrEqual(minimum, maximum)
            XCTAssertLessThanOrEqual(minimum, diff)
            XCTAssertLessThanOrEqual(diff, maximum)
          }

          do {
            let diff = Raw(bucket).advanced(by: bytes) - Raw(p)
            let minimum = 0
            let maximum = max(
              0, MemoryLayout<_PayloadValue>.alignment - MemoryLayout<UnsafeNode>.alignment)
            XCTAssertLessThanOrEqual(minimum, maximum)
            XCTAssertLessThanOrEqual(minimum, diff)
            XCTAssertLessThanOrEqual(diff, maximum)
          }

          do {
            let diff =
              Raw(bucket).advanced(by: bytes)
              - Raw(
                Raw(bucket.pointee.advance(p, offset: -1).advanced(by: 1))
                  .assumingMemoryBound(to: _PayloadValue.self).advanced(by: 1))
            let minimum = 0
            let maximum = max(
              0, MemoryLayout<_PayloadValue>.alignment - MemoryLayout<UnsafeNode>.alignment)
            XCTAssertLessThanOrEqual(minimum, maximum)
            XCTAssertLessThanOrEqual(minimum, diff)
            XCTAssertLessThanOrEqual(diff, maximum)
          }

          // TODO: FIXME
          throw XCTSkip("Bucketのサイズ変更を未反映の為スキップ")
          do {
            let stride = (
              bucket: MemoryLayout<_UnsafeNodeFreshBucket>.stride,
              element: MemoryLayout<_PayloadValue>.stride + MemoryLayout<UnsafeNode>.stride
            )
            let minimum = 0
            let maximum = max(
              0, MemoryLayout<_PayloadValue>.alignment - MemoryLayout<UnsafeNode>.alignment)

            let diff = Raw(bucket).advanced(by: stride.bucket + capacity * stride.element) - Raw(p)
            XCTAssertLessThanOrEqual(minimum, maximum)
            XCTAssertLessThanOrEqual(minimum, diff)
            XCTAssertLessThanOrEqual(diff, maximum)
          }

          XCTAssertEqual(
            Raw(bucket)
              .advanced(
                by:
                  MemoryLayout<_UnsafeNodeFreshBucket>.stride + capacity
                  * (MemoryLayout<_PayloadValue>.stride + MemoryLayout<UnsafeNode>.stride)
                  + max(0, MemoryLayout<UnsafeNode>.alignment - MemoryLayout<_PayloadValue>.alignment))
              - Raw(p), 0)
          bucket.pointee.clear(_PayloadValue.self)
          bucket.deinitialize(count: 1)
          bucket.deallocate()
        }
      }
    #endif
    func testPerformanceExample() throws {
      // This is an example of a performance test case.
      self.measure {
        // Put the code you want to measure the time of here.
      }
    }

  }
#endif
