//
//  _UnsafeNodeFreshPooDeallocator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/12.
//

// インデックス等で`__tree_`を共有する設計だったが、デアロケータを共有する設計に移行する
// 生成されて以後はこのオブジェクトが保持するメモリの寿命を一元で管理する
@usableFromInline
final class _UnsafeNodeFreshPoolDeallocator<_Value> {
  @inlinable
  internal init(source: some _UnsafeNodeFreshPool) {
    self.freshPool = .init(source: source)
  }
  @usableFromInline var freshPool: FreshPool
  @usableFromInline
  struct FreshPool: _UnsafeNodeFreshPool {
    @inlinable
    internal init(source: some _UnsafeNodeFreshPool) {
      self.freshBucketHead = source.freshBucketHead
      self.freshBucketCurrent = source.freshBucketCurrent
      self.freshBucketLast = source.freshBucketLast
      self.freshPoolCapacity = source.freshPoolCapacity
      self.freshPoolUsedCount = source.freshPoolUsedCount
      self.count = source.count
      self.nullptr = source.nullptr
      self.freshBucketCount = source.freshBucketCount
    }
    @usableFromInline var freshBucketHead: _BucketPointer?
    @usableFromInline var freshBucketCurrent: _BucketPointer?
    @usableFromInline var freshBucketLast: _BucketPointer?
    @usableFromInline var freshPoolCapacity: Int
    @usableFromInline var freshPoolUsedCount: Int
    @usableFromInline var count: Int
    @usableFromInline var nullptr: UnsafeMutablePointer<UnsafeNode>
    @usableFromInline var freshBucketCount: Int
  }
  deinit {
    freshPool.___deallocFreshPool()
  }
}
