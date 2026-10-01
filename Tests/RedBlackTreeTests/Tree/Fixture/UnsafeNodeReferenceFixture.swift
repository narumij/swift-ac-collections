//
//  UnsafeNodeReferenceFixture.swift
//  swift-ac-collections
//

#if DEBUG
  @testable import RedBlackTreeCollections

  /// `UnsafeNode`の参照レイアウト計算だけで生メモリ領域を構成するFixture。
  /// `_advanced(with:count:)`による各Node位置を検査できるが、生木(`UnsafeTreeV2`)や
  /// `RawBuffer`(`_BucketAllocator`/`_Bucket`)の計算には依存しない。
  struct UnsafeNodeReferenceFixture<Payload>: ~Copyable {

    let storage: UnsafeMutableRawPointer
    let firstNode: UnsafeMutablePointer<UnsafeNode>
    let capacity: Int

    init(capacity: Int) {
      precondition(capacity > 0)
      self.capacity = capacity
      let pairAlignment = UnsafeNode._referenceAlignment(with: Payload.self)

      storage = UnsafeMutableRawPointer.allocate(
        byteCount: UnsafeNode._referenceAllocationByteCount(
          with: Payload.self,
          capacity: capacity),
        alignment: pairAlignment)
      firstNode = UnsafeNode._referenceFirstNode(in: storage, with: Payload.self)
    }

    func node(at index: Int) -> UnsafeMutablePointer<UnsafeNode> {
      precondition((0..<capacity).contains(index))
      return index == 0 ? firstNode : firstNode._advanced(with: Payload.self, count: index)
    }

    func payload(at index: Int) -> UnsafeMutablePointer<Payload> {
      node(at: index).__value_(as: Payload.self)
    }

    /// `UnsafeNode`参照計算によるNode/Payload一組の歩幅。
    var pairStride: Int {
      UnsafeNode._referenceStride(with: Payload.self)
    }

    deinit {
      storage.deallocate()
    }
  }
#endif
