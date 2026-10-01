import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections

  /// `Implements/__tree/unsafe_node/unsafe_node+pointer.swift`の生メモリレイアウト計算
  /// (`_advanced`系・`__raw_payload_`・`__value_`)を、`UnsafeNodeReferenceFixture`
  /// (生メモリ直接アロケート、生木/`RawBuffer`を経由しない)経由で検証する。
  final class TreeFoundamentalMemoryLayoutTests: XCTestCase {

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
