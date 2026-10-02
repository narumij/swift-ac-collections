import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections

  @available(anyAppleOS 26.0, *)
  final class TreeFoundamentalAllocationTests: TreeTestCase {

    private enum ScalarLayout: _UnsafeNodePtrType, _ScalarBaseType {
      typealias _PayloadValue = Int
      typealias _Key = Int
    }

    private enum PairLayout: _UnsafeNodePtrType, _PairBaseType, _KeyValueElementType {
      typealias _PayloadValue = RedBlackTreePair<String, Int>
      typealias _Key = String
      typealias _MappedValue = Int
      typealias Element = (key: String, value: Int)
    }

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

    /// scalar payload用の原木ポインタhelperが、NodePtrとNodeRefの双方から同じ隣接領域を指すこと。
    func testScalarPointerHelpers_referenceTheOwnedPayload() {
      let fixture = TreeOwnedNodeFixture<Int>()
      let node = fixture.__construct_node(42)
      defer { fixture.destroy(node) }

      XCTAssertEqual(ScalarLayout.__payload_ptr(node), node.__value_(as: Int.self))
      XCTAssertEqual(ScalarLayout.__payload_(node), 42)
      XCTAssertEqual(ScalarLayout.__payload_buffer(node).count, 1)
      XCTAssertEqual(ScalarLayout.__payload_buffer(node).baseAddress, node.__value_(as: Int.self))
      XCTAssertEqual(ScalarLayout.__key_ptr(node), node.__value_(as: Int.self))
      XCTAssertEqual(ScalarLayout.__key_(node), 42)

      var nodeRef = node
      withUnsafeMutablePointer(to: &nodeRef) { ref in
        XCTAssertEqual(ScalarLayout.__payload_ptr(ref), node.__value_(as: Int.self))
        XCTAssertEqual(ScalarLayout.__payload_(ref), 42)
        XCTAssertEqual(ScalarLayout.__payload_buffer(ref).baseAddress, node.__value_(as: Int.self))
        XCTAssertEqual(ScalarLayout.__key_ptr(ref), node.__value_(as: Int.self))
        XCTAssertEqual(ScalarLayout.__key_(ref), 42)
      }
    }

    /// pair payload用helperが、key・mapped value・elementを同一payload内の正しい位置から得ること。
    func testPairPointerHelpers_referenceFieldsInsideOwnedPayload() {
      typealias Payload = RedBlackTreePair<String, Int>
      let fixture = TreeOwnedNodeFixture<Payload>()
      let node = fixture.__construct_node(.init(tuple: (key: "answer", value: 42)))
      defer { fixture.destroy(node) }

      XCTAssertEqual(PairLayout.__key_ptr(node).pointee, "answer")
      XCTAssertEqual(PairLayout.__key_(node), "answer")
      XCTAssertEqual(PairLayout.__mapped_value_ptr(node).pointee, 42)
      XCTAssertEqual(PairLayout.__mapped_value_(node), 42)
      XCTAssertEqual(PairLayout.__element__ptr(node).pointee.key, "answer")
      XCTAssertEqual(PairLayout.__element_(node).value, 42)

      var nodeRef = node
      withUnsafeMutablePointer(to: &nodeRef) { ref in
        XCTAssertEqual(PairLayout.__key_ptr(ref).pointee, "answer")
        XCTAssertEqual(PairLayout.__key_(ref), "answer")
        XCTAssertEqual(PairLayout.__mapped_value_ptr(ref).pointee, 42)
        XCTAssertEqual(PairLayout.__mapped_value_(ref), 42)
      }
    }
  }
#endif
