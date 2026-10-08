#if DEBUG
  @testable import RedBlackTreeCollections

  /// 原木のallocation/deallocation系プロトコルを、生木やRawBufferを経由せず検査するFixture。
  /// 各ノードは`UnsafeNode`とpayloadを同じ生メモリ領域へ構築し、所有権をFixtureに集約する。
  @available(anyAppleOS 26.0, *)
  struct TreeOwnedNodeFixture<Payload>: ~Copyable, _UnsafeNodePtrType,
    _PayloadValueType, AllocationInterface, DellocationInterface
  {
    typealias _PayloadValue = Payload

    private final class Storage {
      struct Allocation {
        let raw: UnsafeMutableRawPointer
        let node: UnsafeMutablePointer<UnsafeNode>
      }

      var allocations: [Allocation] = []
      var nextTag: _TrackingTag = 0

      deinit {
        precondition(allocations.isEmpty, "TreeOwnedNodeFixture leaked nodes")
      }
    }

    private let storage = Storage()

    func __construct_node(_ value: Payload) -> _NodePtr {
      let alignment = UnsafeNode._referenceAlignment(with: Payload.self)
      let byteCount = UnsafeNode._referenceAllocationByteCount(
        with: Payload.self,
        capacity: 1)
      let raw = UnsafeMutableRawPointer.allocate(byteCount: byteCount, alignment: alignment)
      let node = UnsafeNode._referenceFirstNode(in: raw, with: Payload.self)

      #if os(Linux)
        let payload = node.__value_(as: Payload.self)
        print(
          "TreeOwnedNodeFixture.construct",
          "payloadType=\(Payload.self)",
          "byteCount=\(byteCount)",
          "alignment=\(alignment)",
          "raw=\(raw)",
          "node=\(node)",
          "payload=\(payload)",
          "rawEnd=\(raw.advanced(by: byteCount))")
      #endif

      node.initialize(to: .create(tag: storage.nextTag, nullptr: .nullptr))
      node.__value_(as: Payload.self).initialize(to: value)
      node.pointee.___has_payload_content = true

      storage.nextTag += 1
      storage.allocations.append(.init(raw: raw, node: node))
      return node
    }

    func destroy(_ node: _NodePtr) {
      guard let index = storage.allocations.firstIndex(where: { $0.node == node }) else {
        preconditionFailure("destroy received a node not owned by this fixture")
      }

      #if os(Linux)
        print(
          "TreeOwnedNodeFixture.destroy",
          "payloadType=\(Payload.self)",
          "node=\(node)",
          "payload=\(node.__value_(as: Payload.self))")
      #endif

      node.__value_(as: Payload.self).deinitialize(count: 1)
      node.deinitialize(count: 1)
      storage.allocations[index].raw.deallocate()
      storage.allocations.remove(at: index)
    }

    var allocationCount: Int {
      storage.allocations.count
    }
  }
#endif
