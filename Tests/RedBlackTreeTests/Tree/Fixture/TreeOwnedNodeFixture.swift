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
      let nodeStride = MemoryLayout<UnsafeNode>.stride
      let payloadAlignment = MemoryLayout<Payload>.alignment
      let alignment = max(MemoryLayout<UnsafeNode>.alignment, MemoryLayout<Payload>.alignment)
      let byteCount = nodeStride + MemoryLayout<Payload>.stride + alignment - 1
      let raw = UnsafeMutableRawPointer.allocate(byteCount: byteCount, alignment: alignment)
      let payloadAddress = Int(bitPattern: raw) + nodeStride
      let alignedPayloadAddress =
        (payloadAddress + payloadAlignment - 1) / payloadAlignment * payloadAlignment
      let payload = UnsafeMutableRawPointer(bitPattern: alignedPayloadAddress)!
      let node = payload.advanced(by: -nodeStride).assumingMemoryBound(to: UnsafeNode.self)

      node.initialize(to: .create(tag: storage.nextTag, nullptr: .nullptr))
      payload.assumingMemoryBound(to: Payload.self).initialize(to: value)
      node.pointee.___has_payload_content = true

      storage.nextTag += 1
      storage.allocations.append(.init(raw: raw, node: node))
      return node
    }

    func destroy(_ node: _NodePtr) {
      guard let index = storage.allocations.firstIndex(where: { $0.node == node }) else {
        preconditionFailure("destroy received a node not owned by this fixture")
      }

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
