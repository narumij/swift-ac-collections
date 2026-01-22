//
//  _UnsafeNodeFreshPooDeallocator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/12.
//

// インデックス等で`__tree_`を共有する設計だったが、デアロケータを共有する設計に移行する
// 生成されて以後はこのオブジェクトが保持するメモリの寿命を一元で管理する
@usableFromInline
package final class _TiedRawBuffer:
  ManagedBuffer<_TiedRawBuffer.Header, Void>, _UnsafeNodePtrType
{
  public typealias _BucketPointer = UnsafeMutablePointer<_Bucket>

  @nonobjc
  @inlinable
  static func create(
    bucket: _BucketPointer?,
    deallocator: _BucketAllocator
  )
    -> _TiedRawBuffer
  {
    let storage = _TiedRawBuffer.create(minimumCapacity: 0) { managedBuffer in
      return Header(bucketHead: bucket, deallocator: deallocator)
    }
    return unsafeDowncast(storage, to: _TiedRawBuffer.self)
  }

  @nonobjc
  @inlinable
  public func isTriviallyIdentical(to other: _TiedRawBuffer) -> Bool {
    self === other
  }

  @inlinable
  deinit {
    withUnsafeMutablePointerToHeader { header in
      header.pointee.deallocate()
    }
  }
}

extension _TiedRawBuffer {

  @frozen
  public
    struct Header
  {

    @inlinable
    internal init(
      bucketHead: _TiedRawBuffer.Header._BucketPointer? = nil,
      deallocator: _BucketAllocator,
      isValueAccessAllowed: Bool = true
    ) {
      self.bucketHead = bucketHead
      self.deallocator = deallocator
      self.isValueAccessAllowed = isValueAccessAllowed
    }

    @usableFromInline
    typealias _BucketPointer = UnsafeMutablePointer<_Bucket>

    @usableFromInline var bucketHead: _BucketPointer?
    @usableFromInline let deallocator: _BucketAllocator
    @usableFromInline var isValueAccessAllowed: Bool

    @inlinable
    func deallocate() {
      deallocator.deallocate(bucket: bucketHead)
    }

    @inlinable
    subscript(___node_id_: Int) -> _NodePtr? {
      assert(___node_id_ >= 0)
      var remaining = ___node_id_
      var p = bucketHead?.accessor(_value: deallocator.memoryLayout)
      while let h = p {
        let cap = h.capacity
        if remaining < cap {
          return h[remaining]
        }
        remaining -= cap
        p = h.next(_value: deallocator.memoryLayout)
      }
      assert(false)
      return nil
    }
  }

  @nonobjc
  @inlinable
  subscript(___node_id_: Int) -> _NodePtr? {
    header[___node_id_]
  }

  @nonobjc
  @usableFromInline
  var isValueAccessAllowed: Bool {
    get { header.isValueAccessAllowed }
    set { withUnsafeMutablePointerToHeader { $0.pointee.isValueAccessAllowed = newValue } }
  }
}

/// The type-punned empty singleton storage instance.
@usableFromInline
nonisolated(unsafe) package let _emptyDeallocator =
  _TiedRawBuffer
  .create(bucket: nil, deallocator: .init(valueType: Void.self, deinitialize: { _ in }))
