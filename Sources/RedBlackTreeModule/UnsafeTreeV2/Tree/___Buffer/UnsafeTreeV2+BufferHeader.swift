//
//  UnsafeTreeV2+BufferHeader.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/12.
//

extension UnsafeTreeV2Buffer {

  @frozen
  public struct Header: _UnsafeNodeRecyclePool {
    public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

    @inlinable
    @inline(__always)
    internal init(nullptr: _NodePtr) {
      self.nullptr = nullptr
      self.recycleHead = nullptr
    }

    //#if USE_FRESH_POOL_V1
    #if !USE_FRESH_POOL_V2
      @usableFromInline let nullptr: _NodePtr
      @usableFromInline var freshBucketCurrent: _BucketPointer?
      @usableFromInline var freshPoolCapacity: Int = 0
      @usableFromInline var freshPoolUsedCount: Int = 0
      @usableFromInline var recycleHead: _NodePtr
      @usableFromInline var freshBucketHead: _BucketPointer?
      @usableFromInline var freshBucketLast: _BucketPointer?
      @usableFromInline var count: Int = 0
      #if DEBUG
        @usableFromInline var freshBucketCount: Int = 0
      #endif
    #else
      @usableFromInline var recycleHead: _NodePtr
      @usableFromInline let nullptr: _NodePtr
      @usableFromInline var freshPool: FreshPool<_Value> = .init()
      @usableFromInline var count: Int = 0
    #endif

    #if AC_COLLECTIONS_INTERNAL_CHECKS
      /// CoWの発火回数を観察するためのプロパティ
      @usableFromInline internal var copyCount: UInt = 0
    #endif

    @inlinable
    @inline(__always)
    internal mutating func clear(keepingCapacity keepCapacity: Bool = false) {
      if keepCapacity {
        ___cleanFreshPool()
      } else {
        ___flushFreshPool()
      }
      ___flushRecyclePool()
    }
  }
}

//#if USE_FRESH_POOL_V1
#if !USE_FRESH_POOL_V2
  extension UnsafeTreeV2Buffer.Header: _UnsafeNodeFreshPool {}
#else
  extension UnsafeTreeV2Buffer.Header: UnsafeNodeFreshPoolV2 {}
#endif

extension UnsafeTreeV2Buffer.Header {

  @inlinable
  @inline(__always)
  public mutating func __construct_node(_ k: _Value) -> _NodePtr {
    #if DEBUG
      assert(recycleCount >= 0)
    #endif
    let p = recycleHead.pointerIndex == .nullptr ? ___popFresh() : ___popRecycle()
    UnsafeNode.initializeValue(p, to: k)
    assert(p.pointee.___node_id_ >= 0)
    return p
  }
}

extension UnsafeTreeV2Buffer.Header {
  @inlinable
  mutating func tearDown() {
    //#if USE_FRESH_POOL_V1
    #if !USE_FRESH_POOL_V2
      ___flushFreshPool()
      count = 0
    #else
      freshPool.dispose()
      freshPool = .init()
      count = 0
    #endif
    ___flushRecyclePool()
  }
}
