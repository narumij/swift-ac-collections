import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections

  /// `Implements/__tree/unsafe_node/unsafe_node+pointer.swift`の生メモリレイアウト計算
  /// (`_advanced`系・`__raw_payload_`・`__value_`)を、`UnsafeNodeReferenceFixture`
  /// (生メモリ直接アロケート、生木/`RawBuffer`を経由しない)経由で検証する。
  final class TreeFoundamentalMemoryLayoutTests: XCTestCase {

    /// 参照計算がNodeより強いpayload alignmentも満たすこと。
    func testReferenceLayout_accountsForStrongPayloadAlignment() {
      typealias Payload = SIMD16<Double>
      let alignment = UnsafeNode._referenceAlignment(with: Payload.self)
      let stride = UnsafeNode._referenceStride(with: Payload.self)
      let byteCount = UnsafeNode._referenceAllocationByteCount(with: Payload.self, capacity: 3)

      XCTAssertEqual(
        alignment,
        max(MemoryLayout<UnsafeNode>.alignment, MemoryLayout<Payload>.alignment))
      XCTAssertEqual(stride % alignment, 0)
      XCTAssertLessThanOrEqual(byteCount, stride * 3 + alignment - 1)

      let raw = UnsafeMutableRawPointer.allocate(byteCount: byteCount, alignment: alignment)
      defer { raw.deallocate() }
      let first = UnsafeNode._referenceFirstNode(in: raw, with: Payload.self)

      XCTAssertEqual(Int(bitPattern: first) % MemoryLayout<UnsafeNode>.alignment, 0)
      XCTAssertEqual(
        Int(bitPattern: first.__value_(as: Payload.self)) % MemoryLayout<Payload>.alignment,
        0)
    }

    /// 参照計算がRawBufferのpair layout・開始位置・確保byte数と一致すること。
    func testReferenceLayout_matchesRawBufferCalculations() {
      checkReferenceLayoutMatchesRawBuffer(Int8.self)
      checkReferenceLayoutMatchesRawBuffer(Int.self)
      checkReferenceLayoutMatchesRawBuffer(SIMD16<Double>.self)
      checkReferenceLayoutMatchesRawBuffer(RedBlackTreePair<Int32, SIMD4<Float>>.self)
    }

    private func checkReferenceLayoutMatchesRawBuffer<Payload>(_ payload: Payload.Type) {
      let allocator = _BucketAllocator(valueType: payload) { _ in }
      XCTAssertEqual(
        UnsafeNode._referenceAlignment(with: payload),
        allocator.pairLayout.alignment)
      XCTAssertEqual(
        UnsafeNode._referenceStride(with: payload),
        allocator.pairLayout.stride)

      for prefix in [0, MemoryLayout<_Bucket>.stride, 3 * MemoryLayout<_Bucket>.stride] {
        for capacity in [1, 2, 3, 16] {
          XCTAssertEqual(
            UnsafeNode._referenceAllocationByteCount(
              prefix: prefix,
              with: payload,
              capacity: capacity),
            allocator._allocationSize(prefix: prefix, capacity: capacity))

          let byteCount = UnsafeNode._referenceAllocationByteCount(
            prefix: prefix,
            with: payload,
            capacity: capacity)
          let raw = UnsafeMutableRawPointer.allocate(
            byteCount: byteCount,
            alignment: allocator.pairLayout.alignment)
          defer { raw.deallocate() }
          let storage = raw.advanced(by: prefix)
          let reference = UnsafeNode._referenceFirstNode(in: storage, with: payload)

          let header = raw.assumingMemoryBound(to: _Bucket.self)
          let rawBuffer = header.start(
            storage: storage,
            payloadOrPairAlignment: allocator.pairLayout.alignment)
          XCTAssertEqual(reference, rawBuffer)
        }
      }
    }

    /// `_advanced(with: Payload.self, count:)`で1個先に進めた場合、Node直後に
    /// Payloadが続くレイアウトが保たれ、`count: -1`で元の位置に戻ること。
    func testAdvancedWithPayloadType_roundTripsAndKeepsAlignment() {
      checkAdvancedWithPayloadType(Int32.self)
      checkAdvancedWithPayloadType(SIMD4<Float>.self)
      checkAdvancedWithPayloadType(RedBlackTreePair<Int, Int>.self)
      checkAdvancedWithPayloadType(RedBlackTreePair<Int32, SIMD4<Float>>.self)
    }

    private func checkAdvancedWithPayloadType<Payload>(
      _ type: Payload.Type,
      file: StaticString = #filePath,
      line: UInt = #line
    ) {
      let fixture = UnsafeNodeReferenceFixture<Payload>(capacity: 4)
//      defer { fixture.deallocate() }

      let first = fixture.node(at: 0)
      let second = first._advanced(with: Payload.self, count: 1)

      XCTAssertEqual(
        second._advanced(with: Payload.self, count: -1), first,
        "\(Payload.self): 往復で元の位置に戻らない", file: file, line: line)
      XCTAssertEqual(
        Int(bitPattern: second) % MemoryLayout<UnsafeNode>.alignment, 0,
        "\(Payload.self): 2個目のノードがアライメントされていない", file: file, line: line)
      XCTAssertEqual(
        Int(bitPattern: fixture.payload(at: 1)) % MemoryLayout<Payload>.alignment, 0,
        "\(Payload.self): 2個目のpayloadがアライメントされていない", file: file, line: line)
    }

    /// `_advanced(with stride: Int, count:)`(歩幅を直接指定するオーバーロード)が、
    /// `MemoryLayout<UnsafeNode>.stride + stride`を1単位として進むこと。
    func testAdvancedWithRawStride_movesByNodeStridePlusGivenStride() {
      let fixture = UnsafeNodeReferenceFixture<Int64>(capacity: 4)
//      defer { fixture.deallocate() }

      let first = fixture.node(at: 0)
      let extraStride = 16
      let advanced = first._advanced(with: extraStride, count: 1)

      XCTAssertEqual(
        UnsafeMutableRawPointer(first).distance(to: UnsafeMutableRawPointer(advanced)),
        MemoryLayout<UnsafeNode>.stride + extraStride)
      XCTAssertEqual(advanced._advanced(with: extraStride, count: -1), first)
    }

    /// `__raw_payload_`が`self.advanced(by: 1)`と同じ生ポインタを返すこと。
    func testRawPayload_pointsImmediatelyAfterNode() {
      let fixture = UnsafeNodeReferenceFixture<Int32>(capacity: 2)
//      defer { fixture.deallocate() }
      let node = fixture.node(at: 0)
      XCTAssertEqual(node.__raw_payload_, UnsafeMutableRawPointer(node.advanced(by: 1)))
    }

    /// 型推論版`__value_()`(無引数)が、明示的型指定版`__value_(as:)`と同じアドレスを
    /// 返すこと。
    func testValueTypeInference_matchesExplicitTypeVersion() {
      let fixture = UnsafeNodeReferenceFixture<Int32>(capacity: 2)
//      defer { fixture.deallocate() }
      let node = fixture.node(at: 0)
      let inferred: UnsafeMutablePointer<Int32> = node.__value_()
      XCTAssertEqual(inferred, node.__value_(as: Int32.self))
    }
  }
#endif
