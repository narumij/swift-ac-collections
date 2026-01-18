//
//  _UnsafeNodeFreshPooDeallocator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/12.
//

// インデックス等で`__tree_`を共有する設計だったが、デアロケータを共有する設計に移行する
// 生成されて以後はこのオブジェクトが保持するメモリの寿命を一元で管理する
@usableFromInline
package final class _UnsafeNodeFreshPoolV3Deallocator: _UnsafeNodePtrType {

  public typealias _BucketPointer = UnsafeMutablePointer<_UnsafeNodeFreshBucket>

  @inlinable
  internal init(
    bucket: _BucketPointer?,
    deallocator: _UnsafeNodeFreshBucketAllocator
  ) {
    self.freshBucketHead = bucket
    self.freshPoolDeallocator = deallocator
  }

  @usableFromInline var freshBucketHead: _BucketPointer?
  @usableFromInline var isBaseDeallocated: Bool = false
  @usableFromInline let freshPoolDeallocator: _UnsafeNodeFreshBucketAllocator

  @inlinable
  @inline(__always)
  public func isTriviallyIdentical(to other: _UnsafeNodeFreshPoolV3Deallocator) -> Bool {
    self === other
  }

  @inlinable
  deinit {
    freshPoolDeallocator.deallocate(bucket: freshBucketHead)
  }

  @inlinable
  @inline(__always)
  subscript(___node_id_: Int) -> _NodePtr? {
    assert(___node_id_ >= 0)
    var remaining = ___node_id_
    var p = freshBucketHead?.accessor(_value: freshPoolDeallocator._value)
    while let h = p {
      let cap = h.capacity
      if remaining < cap {
        return h[remaining]
      }
      remaining -= cap
      p = h.next(_value: freshPoolDeallocator._value)
    }
    assert(false)
    return nil
  }
}

@usableFromInline
package final class _UnsafeNodeFreshPoolV3DeallocatorR2:
  ManagedBuffer<_UnsafeNodeFreshPoolV3DeallocatorR2.Header, Void>, _UnsafeNodePtrType
{
  public typealias _BucketPointer = UnsafeMutablePointer<_UnsafeNodeFreshBucket>

  @inlinable
  static func create(
    bucket: _BucketPointer?,
    deallocator: _UnsafeNodeFreshBucketAllocator
  )
    -> _UnsafeNodeFreshPoolV3DeallocatorR2
  {
    let storage = _UnsafeNodeFreshPoolV3DeallocatorR2.create(minimumCapacity: 0) { managedBuffer in
      return Header(freshBucketHead: bucket, freshPoolDeallocator: deallocator)
    }
    return unsafeDowncast(storage, to: _UnsafeNodeFreshPoolV3DeallocatorR2.self)
  }

  @inlinable
  public func isTriviallyIdentical(to other: _UnsafeNodeFreshPoolV3DeallocatorR2) -> Bool {
    self === other
  }

  @inlinable
  deinit {
    withUnsafeMutablePointerToHeader { header in
      header.pointee.deallocate()
    }
  }
}

extension _UnsafeNodeFreshPoolV3DeallocatorR2 {

  @frozen
  public
    struct Header
  {

    @inlinable
    internal init(
      freshBucketHead: _UnsafeNodeFreshPoolV3DeallocatorR2.Header._BucketPointer? = nil,
      freshPoolDeallocator: _UnsafeNodeFreshBucketAllocator, isBaseDeallocated: Bool = false
    ) {
      self.freshBucketHead = freshBucketHead
      self.freshPoolDeallocator = freshPoolDeallocator
      self.isBaseDeallocated = isBaseDeallocated
    }

    @usableFromInline
    typealias _BucketPointer = UnsafeMutablePointer<_UnsafeNodeFreshBucket>

    @usableFromInline var freshBucketHead: _BucketPointer?
    @usableFromInline let freshPoolDeallocator: _UnsafeNodeFreshBucketAllocator
    @usableFromInline var isBaseDeallocated: Bool = false

    @inlinable
    func deallocate() {
      freshPoolDeallocator.deallocate(bucket: freshBucketHead)
    }

    @inlinable
    subscript(___node_id_: Int) -> _NodePtr? {
      assert(___node_id_ >= 0)
      var remaining = ___node_id_
      var p = freshBucketHead?.accessor(_value: freshPoolDeallocator._value)
      while let h = p {
        let cap = h.capacity
        if remaining < cap {
          return h[remaining]
        }
        remaining -= cap
        p = h.next(_value: freshPoolDeallocator._value)
      }
      assert(false)
      return nil
    }
  }

  @inlinable
  subscript(___node_id_: Int) -> _NodePtr? {
    header[___node_id_]
  }

  @usableFromInline
  var isBaseDeallocated: Bool {
    get { header.isBaseDeallocated }
    set { withUnsafeMutablePointerToHeader { $0.pointee.isBaseDeallocated = newValue } }
  }
}

/// The type-punned empty singleton storage instance.
@usableFromInline
nonisolated(unsafe) package let _emptyDeallocator =
  _UnsafeNodeFreshPoolV3DeallocatorR2
  .create(bucket: nil, deallocator: .init(valueType: Void.self, deinitialize: { _ in }))
