//
//  UnsafeNodeReferenceFixture.swift
//  swift-ac-collections
//

import RedBlackTreeCollections

  /// `UnsafeNode`の参照レイアウト計算だけで生メモリ領域を構成するFixture。
  /// `_advanced(with:count:)`による各Node位置を検査できるが、生木(`UnsafeTreeV2`)や
  /// `RawBuffer`(`_BucketAllocator`/`_Bucket`)の計算には依存しない。
  package struct UnsafeNodeReferenceFixture<Payload>: ~Copyable {

    package let storage: UnsafeMutableRawPointer
    package let firstNode: UnsafeMutablePointer<UnsafeNode>
    package let capacity: Int

    package init(capacity: Int) {
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

    package func node(at index: Int) -> UnsafeMutablePointer<UnsafeNode> {
      precondition((0..<capacity).contains(index))
      return index == 0 ? firstNode : firstNode._advanced(with: Payload.self, count: index)
    }

    package func payload(at index: Int) -> UnsafeMutablePointer<Payload> {
      node(at: index).__value_(as: Payload.self)
    }

    /// `UnsafeNode`参照計算によるNode/Payload一組の歩幅。
    package var pairStride: Int {
      UnsafeNode._referenceStride(with: Payload.self)
    }

    deinit {
      storage.deallocate()
    }
  }
