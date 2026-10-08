import XCTest
import RedBlackTreeFixture

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

    /// poison済み領域へNodeとpayloadを別色で実際に塗り、各領域が重ならず、
    /// alignment gap/pair paddingと末尾guardを侵食しないこと。
    func testReferenceLayout_coloringHasNoOverlapOrOutOfBoundsWrite() {
      checkReferenceLayoutColoring(Int8.self)
      checkReferenceLayoutColoring(Int.self)
      checkReferenceLayoutColoring(SIMD16<Double>.self)
      checkReferenceLayoutColoring(RedBlackTreePair<Int32, SIMD4<Float>>.self)
    }

    private func checkReferenceLayoutColoring<Payload>(_ payload: Payload.Type) {
      let poison: UInt8 = 0xE8
      let prefixColor: UInt8 = 0xA1
      let nodeColor: UInt8 = 0xB2
      let payloadColor: UInt8 = 0xC3
      let guardColor: UInt8 = 0xD4
      let guardByteCount = 32

      for prefix in [0, MemoryLayout<UInt>.stride, 3 * MemoryLayout<UInt>.stride] {
        for capacity in [1, 2, 3, 16] {
          let byteCount = UnsafeNode._referenceAllocationByteCount(
            prefix: prefix,
            with: payload,
            capacity: capacity)
          let alignment = UnsafeNode._referenceAlignment(with: payload)
          let stride = UnsafeNode._referenceStride(with: payload)
          let raw = UnsafeMutableRawPointer.allocate(
            byteCount: byteCount + guardByteCount,
            alignment: alignment)
          defer { raw.deallocate() }

          raw.initializeMemory(as: UInt8.self, repeating: poison, count: byteCount)
          raw.advanced(by: byteCount)
            .initializeMemory(as: UInt8.self, repeating: guardColor, count: guardByteCount)
          raw.initializeMemory(as: UInt8.self, repeating: prefixColor, count: prefix)

          let first = UnsafeNode._referenceFirstNode(
            in: raw.advanced(by: prefix),
            with: payload)
          for index in 0..<capacity {
            let node = UnsafeMutableRawPointer(first).advanced(by: stride * index)
            node.initializeMemory(
              as: UInt8.self,
              repeating: nodeColor,
              count: MemoryLayout<UnsafeNode>.stride)
            node.advanced(by: MemoryLayout<UnsafeNode>.stride)
              .initializeMemory(
                as: UInt8.self,
                repeating: payloadColor,
                count: MemoryLayout<Payload>.stride)
          }

          var counts: [UInt8: Int] = [:]
          for offset in 0..<byteCount {
            counts[raw.load(fromByteOffset: offset, as: UInt8.self), default: 0] += 1
          }
          XCTAssertEqual(counts[prefixColor] ?? 0, prefix, "\(Payload.self), prefix \(prefix)")
          XCTAssertEqual(
            counts[nodeColor] ?? 0,
            MemoryLayout<UnsafeNode>.stride * capacity,
            "\(Payload.self), prefix \(prefix)")
          XCTAssertEqual(
            counts[payloadColor] ?? 0,
            MemoryLayout<Payload>.stride * capacity,
            "\(Payload.self), prefix \(prefix)")
          XCTAssertEqual(
            counts[poison] ?? 0,
            byteCount - prefix
              - MemoryLayout<UnsafeNode>.stride * capacity
              - MemoryLayout<Payload>.stride * capacity,
            "\(Payload.self), prefix \(prefix)")

          for offset in 0..<guardByteCount {
            XCTAssertEqual(
              raw.load(fromByteOffset: byteCount + offset, as: UInt8.self),
              guardColor,
              "\(Payload.self), prefix \(prefix), guard offset \(offset)")
          }
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
