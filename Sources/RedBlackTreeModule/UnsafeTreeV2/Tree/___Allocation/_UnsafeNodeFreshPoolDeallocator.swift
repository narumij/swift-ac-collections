//
//  _UnsafeNodeFreshPooDeallocator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/12.
//

// インデックス等で`__tree_`を共有する設計だったが、デアロケータを共有する設計に移行する
// 生成されて以後はこのオブジェクトが保持するメモリの寿命を一元で管理する
@usableFromInline
final class _UnsafeNodeFreshPoolDeallocator {
  
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  public typealias _BucketPointer = UnsafeMutablePointer<_UnsafeNodeFreshBucket>
  
  @inlinable
  internal init(freshBucketHead: _BucketPointer?,
                stride: Int,
                deinitialize: @escaping (_NodePtr) -> Void)
  {
    self.freshBucketHead = freshBucketHead
    self.stride = stride
    self.deinitialize = deinitialize
  }
  
  @usableFromInline let stride: Int
  @usableFromInline let deinitialize: (_NodePtr) -> Void
  @usableFromInline var freshBucketHead: _BucketPointer?
  @usableFromInline var isBaseDeallocated: Bool = false

  @inlinable
  @inline(__always)
  public func isIdentical(to other: _UnsafeNodeFreshPoolDeallocator) -> Bool {
    self === other
  }
  
  @inlinable
  @inline(__always)
  func deinitializeNodes(_ p: _BucketPointer) {
    let bucket = p.pointee
    var i = 0
    let count = bucket.count
    var p = bucket.start
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
      reserverHead = h.pointee.next
      deinitializeNodes(h)
      h.deinitialize(count: 1)
      h.deallocate()
    }
  }
}
