//
//  _UnsafeNodeFreshPooDeallocator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/12.
//

// インデックス等で`__tree_`を共有する設計だったが、デアロケータを共有する設計に移行する
// 生成されて以後はこのオブジェクトが保持するメモリの寿命を一元で管理する
@usableFromInline
package final class _UnsafeNodeFreshPoolV3Deallocator: UnsafeTreePointer {

  public typealias _BucketPointer = UnsafeMutablePointer<_UnsafeNodeFreshBucket>

  @inlinable
  internal init(
    freshBucketHead: _BucketPointer?,
    stride: Int,
    deinitialize: @escaping (_NodePtr) -> Void,
    nullptr: _NodePtr
  ) {
    self.freshBucketHead = freshBucketHead
    self.stride = stride
    self.deinitialize = deinitialize
    self.nullptr = nullptr
  }

  @usableFromInline let nullptr: _NodePtr
  @usableFromInline let stride: Int
  @usableFromInline let deinitialize: (_NodePtr) -> Void
  @usableFromInline var freshBucketHead: _BucketPointer?
  @usableFromInline var isBaseDeallocated: Bool = false

  @inlinable
  @inline(__always)
  public func isTriviallyIdentical(to other: _UnsafeNodeFreshPoolDeallocator) -> Bool {
    self === other
  }

  @inlinable
  @inline(__always)
  func deinitializeNodes(_ b: _BucketPointer) {
    var first = b == freshBucketHead
    let bucket = b.pointee
    var i = 0
    let count = bucket.count
    var p = bucket.start
    if first {
      first = false
      // バケット先頭の場合、NodeValueの前にEnd Nodeが先混まれているので、それを解放する
      UnsafeMutableRawPointer(b.advanced(by: 1))
        .assumingMemoryBound(to: UnsafeNode.self)
        .deinitialize(count: 1)
      p = UnsafeMutableRawPointer(b.advanced(by: 1))
        .advanced(by: MemoryLayout<UnsafeNode>.stride)
        .assumingMemoryBound(to: UnsafeNode.self)
    }
    while i < count {
      let c = p
      p = p._advanced(raw: stride)
      deinitialize(c)
      i += 1
    }
  }

  @inlinable
  deinit {
    var reserverHead = freshBucketHead
    while let h = reserverHead {
      UnsafeMutableRawPointer(h.advanced(by: 1))
        .assumingMemoryBound(to: UnsafeNode.self)
        .deinitialize(count: 1)
      reserverHead = h.pointee.next
      deinitializeNodes(h)
      h.deinitialize(count: 1)
      h.deallocate()
    }
  }

  @inlinable
  @inline(__always)
  subscript(___node_id_: Int) -> _NodePtr {
    assert(___node_id_ >= 0)
    var remaining = ___node_id_
    var p = freshBucketHead
    while let h = p {
      let cap = h.pointee.capacity
      if remaining < cap {
        return h.pointee[remaining]
      }
      remaining -= cap
      p = h.pointee.next
    }
    return nullptr
  }
}
