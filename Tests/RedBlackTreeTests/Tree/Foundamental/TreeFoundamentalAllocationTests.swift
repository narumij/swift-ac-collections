import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections

  @available(anyAppleOS 26.0, *)
  final class TreeFoundamentalAllocationTests: RedBlackTreeTestCase {

    private final class LifetimeProbe {
      let value: Int
      let onDeinit: () -> Void

      init(value: Int, onDeinit: @escaping () -> Void) {
        self.value = value
        self.onDeinit = onDeinit
      }

      deinit {
        onDeinit()
      }
    }

    /// constructがノードとpayloadを隣接領域へ初期化し、所有数とtagを進めること。
    func testConstructNode_initializesMetadataPayloadAndUniqueTags() {
      let fixture = TreeOwnedNodeFixture<Int>()
      let first = fixture.__construct_node(10)
      let second = fixture.__construct_node(20)
      defer {
        fixture.destroy(second)
        fixture.destroy(first)
      }

      XCTAssertEqual(fixture.allocationCount, 2)
      XCTAssertEqual(first.pointee.___tracking_tag, 0)
      XCTAssertEqual(second.pointee.___tracking_tag, 1)
      XCTAssertTrue(first.pointee.___has_payload_content)
      XCTAssertTrue(second.pointee.___has_payload_content)
      XCTAssertEqual(first.__value_(as: Int.self).pointee, 10)
      XCTAssertEqual(second.__value_(as: Int.self).pointee, 20)
      XCTAssertEqual(first.__left_, .nullptr)
      XCTAssertEqual(first.__right_, .nullptr)
      XCTAssertEqual(first.__parent_, .nullptr)
    }

    /// destroyが非trivial payloadをちょうど一度破棄し、生メモリ所有を解放すること。
    func testDestroy_deinitializesPayloadAndReleasesOwnership() {
      var deinitCount = 0
      let fixture = TreeOwnedNodeFixture<LifetimeProbe>()
      let node = fixture.__construct_node(
        LifetimeProbe(value: 42) { deinitCount += 1 })

      XCTAssertEqual(node.__value_(as: LifetimeProbe.self).pointee.value, 42)
      XCTAssertEqual(fixture.allocationCount, 1)
      XCTAssertEqual(deinitCount, 0)

      fixture.destroy(node)

      XCTAssertEqual(fixture.allocationCount, 0)
      XCTAssertEqual(deinitCount, 1)
    }

    /// payloadのalignmentがUnsafeNodeより大きい場合も、型付きポインタが正しく整列すること。
    func testConstructNode_honorsPayloadAlignment() {
      typealias Payload = SIMD16<Double>
      let fixture = TreeOwnedNodeFixture<Payload>()
      let value = Payload(repeating: 3.5)
      let node = fixture.__construct_node(value)
      defer { fixture.destroy(node) }

      let payload = node.__value_(as: Payload.self)
      XCTAssertEqual(Int(bitPattern: payload) % MemoryLayout<Payload>.alignment, 0)
      XCTAssertEqual(payload.pointee, value)
    }
  }
#endif
