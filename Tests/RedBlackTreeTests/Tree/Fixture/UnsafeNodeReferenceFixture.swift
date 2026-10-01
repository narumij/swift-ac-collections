//
//  UnsafeNodeReferenceFixture.swift
//  swift-ac-collections
//

#if DEBUG
  @testable import RedBlackTreeCollections

  /// `UnsafeNode._advanced(with:count:)`(原木が参照計算として使う素朴なNode+Payload
  /// 歩幅の式)を、生メモリへ直接アロケートした領域に対して呼び出し、実際の並び
  /// (先頭ノードからのオフセット)を測定するFixture。生木(`UnsafeTreeV2`)や
  /// `RawBuffer`(`_BucketAllocator`/`_Bucket`)を経由しない。
  struct UnsafeNodeReferenceFixture<Payload> {

    let storage: UnsafeMutableRawPointer
    let firstNode: UnsafeMutablePointer<UnsafeNode>

    init(capacity: Int) {
      precondition(capacity > 0)
      let nodeStride = MemoryLayout<UnsafeNode>.stride
      let pairAlignment = max(MemoryLayout<UnsafeNode>.alignment, MemoryLayout<Payload>.alignment)
      let roughPairSize = nodeStride + MemoryLayout<Payload>.stride

      storage = UnsafeMutableRawPointer.allocate(
        byteCount: roughPairSize * (capacity + 1) + pairAlignment,
        alignment: pairAlignment)

      let firstPayload =
        storage
        .advanced(by: nodeStride)
        .alignedUp(toMultipleOf: MemoryLayout<Payload>.alignment)
      firstNode = firstPayload
        .advanced(by: -nodeStride)
        .assumingMemoryBound(to: UnsafeNode.self)
    }

    func node(at index: Int) -> UnsafeMutablePointer<UnsafeNode> {
      index == 0 ? firstNode : firstNode._advanced(with: Payload.self, count: index)
    }

    func payload(at index: Int) -> UnsafeMutablePointer<Payload> {
      node(at: index).__value_(as: Payload.self)
    }

    /// 先頭ノードから2番目のノードまでの実測バイト距離(組の歩幅)
    var pairStride: Int {
      UnsafeMutableRawPointer(firstNode)
        .distance(to: UnsafeMutableRawPointer(node(at: 1)))
    }

    func deallocate() {
      storage.deallocate()
    }
  }
#endif
