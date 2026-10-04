import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections

  /// RawBufferと原木参照計算という独立した二経路のレイアウト一致を検証する。
  /// RawBuffer固有のbucketを扱うため、原木ターゲットではなくここに置く。
  final class UnsafeNodeRawBufferLayoutAgreementTests: XCTestCase {
    func testReferenceLayoutMatchesRawBufferCalculations() {
      check(Int8.self)
      check(Int.self)
      check(SIMD16<Double>.self)
      check(RedBlackTreePair<Int32, SIMD4<Float>>.self)
    }

    private func check<Payload>(_ payload: Payload.Type) {
      let allocator = _BucketAllocator(valueType: payload) { _ in }
      XCTAssertEqual(UnsafeNode._referenceAlignment(with: payload), allocator.pairLayout.alignment)
      XCTAssertEqual(UnsafeNode._referenceStride(with: payload), allocator.pairLayout.stride)

      for prefix in [0, MemoryLayout<_Bucket>.stride, 3 * MemoryLayout<_Bucket>.stride] {
        XCTAssertEqual(
          UnsafeNode._referenceAllocationByteCount(prefix: prefix, with: payload, capacity: 0),
          prefix)
        for capacity in [1, 2, 3, 16] {
          let byteCount = UnsafeNode._referenceAllocationByteCount(
            prefix: prefix, with: payload, capacity: capacity)
          XCTAssertEqual(byteCount, allocator._allocationSize(prefix: prefix, capacity: capacity))
          let raw = UnsafeMutableRawPointer.allocate(
            byteCount: byteCount, alignment: allocator.pairLayout.alignment)
          defer { raw.deallocate() }
          let storage = raw.advanced(by: prefix)
          let reference = UnsafeNode._referenceFirstNode(in: storage, with: payload)
          let header = raw.assumingMemoryBound(to: _Bucket.self)
          let rawBuffer = header.start(
            storage: storage, payloadOrPairAlignment: allocator.pairLayout.alignment)
          XCTAssertEqual(reference, rawBuffer)
        }
      }
    }
  }
#endif
