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
  internal init(bucket: _BucketPointer?,
                deallocator: _UnsafeNodeFreshBucketAllocator)
  {
    self.freshBucketHead = bucket
    self.freshPoolDeallocator = deallocator
  }
  
  @usableFromInline var freshBucketHead: _BucketPointer?
  @usableFromInline var isBaseDeallocated: Bool = false
  @usableFromInline let freshPoolDeallocator: _UnsafeNodeFreshBucketAllocator
  
  @inlinable
  @inline(__always)
  public func isTriviallyIdentical(to other: _UnsafeNodeFreshPoolDeallocator) -> Bool {
    self === other
  }
  
  @inlinable
  deinit {
    freshPoolDeallocator.deallocate(freshBucketHead)
  }
  
  @inlinable
  @inline(__always)
  subscript(___node_id_: Int) -> _NodePtr? {
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
    assert(false)
    return nil
  }
}
