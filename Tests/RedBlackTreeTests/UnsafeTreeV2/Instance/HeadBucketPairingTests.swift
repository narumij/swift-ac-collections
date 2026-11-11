//
//  HeadBucketPairingTests.swift
//  swift-ac-collections
//
//  RBT-111: 先頭バケットを木のオブジェクトの要素領域に同居させる構成（USE_HEAD_BUCKET_PAIRING）の確認。
//

import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections

  final class HeadBucketPairingTests: RedBlackTreeTestCase {

    #if USE_HEAD_BUCKET_PAIRING && !COMPATIBLE_ATCODER_2025 && !USE_LAZY_DETACH
      /// 要素領域の先頭は1バイト境界しか保証されないため、先頭バケットはpairのalignmentへ切り上げて置かれる。
      /// 各種payload型と容量について、先頭バケット・begin_ptr・endノード・各ノード・各payloadが整列し、
      /// 最後のpayloadの末尾まで木のオブジェクトの要素領域に収まること。
      func testHeadBucketFitsAlignedInsideTreeStorage() throws {
        for n in [0] + (0..<10).map({ 1 << $0 }) + [3, 7, 100] {
          try checkPairedHeadBucket(Int8.self, capacity: n)
          try checkPairedHeadBucket(Int.self, capacity: n)
          try checkPairedHeadBucket(Int128.self, capacity: n)
          try checkPairedHeadBucket(SIMD3<Int>.self, capacity: n)
          try checkPairedHeadBucket(SIMD16<Double>.self, capacity: n)
          try checkPairedHeadBucket(SIMD32<Int>.self, capacity: n)
          try checkPairedHeadBucket(RedBlackTreePair<Int32, Int32>.self, capacity: n)
          try checkPairedHeadBucket(RedBlackTreePair<Int, SIMD4<Int>>.self, capacity: n)
          try checkPairedHeadBucket(RedBlackTreePair<String, Int>.self, capacity: n)
        }
      }

      func checkPairedHeadBucket<_PayloadValue>(_ t: _PayloadValue.Type, capacity: Int) throws {
        let storage = UnsafeTreeV2Buffer.create(
          _PayloadValue.self, minimumCapacity: capacity, nullptr: .nullptr)
        let elementCount = storage.capacity
        storage.withUnsafeMutablePointers { header, elements in
          let lower = UnsafeMutableRawPointer(elements)
          let upper = lower.advanced(by: elementCount)
          let head = try! XCTUnwrap(header.pointee.freshBucketHead)
          let label = "\(_PayloadValue.self) capacity \(capacity)"

          XCTAssertEqual(head.pointee.capacity, capacity, label)
          XCTAssertLessThanOrEqual(lower, UnsafeMutableRawPointer(head), label)
          XCTAssertEqual(
            Int(bitPattern: head) % MemoryLayout<_Bucket>.alignment, 0, label)
          XCTAssertEqual(
            Int(bitPattern: head.begin_ptr)
              % MemoryLayout<UnsafeMutablePointer<UnsafeNode>>.alignment, 0, label)
          XCTAssertEqual(
            Int(bitPattern: head.end_ptr) % MemoryLayout<UnsafeNode>.alignment, 0, label)
          XCTAssertEqual(header.pointee.end_ptr, head.end_ptr, label)
          XCTAssertEqual(header.pointee.begin_ptr, head.begin_ptr, label)
          XCTAssertLessThanOrEqual(
            UnsafeMutableRawPointer(head.end_ptr.advanced(by: 1)), upper, label)

          guard capacity != 0 else { return }
          let accessor = try! XCTUnwrap(head.accessor(pairLayout: MemoryLayout<_PayloadValue>._pairLayout))
          for i in 0..<capacity {
            let node = accessor[i]
            let payload = node.__value_(as: _PayloadValue.self)
            XCTAssertEqual(Int(bitPattern: node) % MemoryLayout<UnsafeNode>.alignment, 0, label)
            XCTAssertEqual(
              Int(bitPattern: payload) % MemoryLayout<_PayloadValue>.alignment, 0, label)
            XCTAssertLessThan(UnsafeMutableRawPointer(head.end_ptr), UnsafeMutableRawPointer(node), label)
          }
          let lastPayloadEnd = UnsafeMutableRawPointer(
            accessor[capacity - 1].__value_(as: _PayloadValue.self)
          ).advanced(by: MemoryLayout<_PayloadValue>.size)
          XCTAssertLessThanOrEqual(lastPayloadEnd, upper, label)
        }
      }
    #endif

    private final class DeinitCounter: Comparable {
      nonisolated(unsafe) static var live = 0
      let value: Int
      init(_ value: Int) {
        self.value = value
        Self.live += 1
      }
      deinit { Self.live -= 1 }
      static func < (lhs: DeinitCounter, rhs: DeinitCounter) -> Bool { lhs.value < rhs.value }
      static func == (lhs: DeinitCounter, rhs: DeinitCounter) -> Bool { lhs.value == rhs.value }
    }

    /// 先頭バケットに収まる要素も、容量を超えて追加されたバケットの要素も、
    /// 木を手放したときにちょうど一度ずつ解放されること。
    func testPayloadsInHeadAndAddedBucketsAreReleasedOnce() {
      DeinitCounter.live = 0
      do {
        var set = RedBlackTreeSet<DeinitCounter>(minimumCapacity: 4)
        for i in 0..<4 { _ = set.insert(DeinitCounter(i)) }
        for i in 4..<40 { _ = set.insert(DeinitCounter(i)) }
        XCTAssertEqual(DeinitCounter.live, 40)
        _ = set.remove(DeinitCounter(0))
        _ = set.remove(DeinitCounter(39))
        XCTAssertEqual(DeinitCounter.live, 38)
        XCTAssertEqual(set.count, 38)
      }
      XCTAssertEqual(DeinitCounter.live, 0)
    }

    /// removeAll(keepingCapacity:)で中身だけを消した木を、そのまま再利用して手放しても、
    /// 二重解放・解放漏れが起きないこと。
    func testRemoveAllKeepingCapacityThenReuseReleasesOnce() {
      DeinitCounter.live = 0
      do {
        var set = RedBlackTreeSet<DeinitCounter>((0..<16).map { DeinitCounter($0) })
        set.removeAll(keepingCapacity: true)
        XCTAssertEqual(DeinitCounter.live, 0)
        for i in 0..<8 { _ = set.insert(DeinitCounter(i)) }
        XCTAssertEqual(DeinitCounter.live, 8)
      }
      XCTAssertEqual(DeinitCounter.live, 0)
    }

    /// 共有中の木をコピーして変更しても、それぞれの先頭バケットの要素が各木の寿命どおりに解放されること。
    func testCopiesReleaseTheirOwnHeadBucketPayloads() {
      DeinitCounter.live = 0
      do {
        let original = RedBlackTreeSet<DeinitCounter>((0..<8).map { DeinitCounter($0) })
        do {
          var copy = original
          _ = copy.insert(DeinitCounter(100))
          XCTAssertEqual(DeinitCounter.live, 9)
        }
        XCTAssertEqual(DeinitCounter.live, 8)
        XCTAssertEqual(original.map(\.value), Array(0..<8))
      }
      XCTAssertEqual(DeinitCounter.live, 0)
    }
  }
#endif
