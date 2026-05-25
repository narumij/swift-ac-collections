//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project
//
// Copyright (c) 2024 - 2026 narumij.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.
//
//===----------------------------------------------------------------------===//

// NOTE: 性能過敏なので修正する場合は必ず計測しながら行うこと
@frozen
@usableFromInline
package struct UnsafeTreeV2BufferHeader {
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  public typealias _NodeRef = UnsafeMutablePointer<_NodePtr>

  @inlinable
  internal init<_PayloadValue: ~Copyable>(_ t: _PayloadValue.Type, nullptr: _NodePtr, capacity: Int)
  {
    let allocator = _BucketAllocator(valueType: _PayloadValue.self) {
      $0.assumingMemoryBound(to: _PayloadValue.self)
        .deinitialize(count: 1)
    }
    self.init(allocator: allocator, nullptr: nullptr, capacity: capacity)
  }

  @inlinable
  internal init(allocator: _BucketAllocator, nullptr: _NodePtr, capacity: Int) {
    let head = allocator.createHeadBucket(capacity: capacity, nullptr: nullptr)
    self.recycleHead = nullptr
    self.nullptr = nullptr
    self.begin_ptr = head.begin_ptr
    self.root_ptr = _ref(to: &head.end_ptr.pointee.__left_)
    self.freshBucketAllocator = allocator
    self.pushFreshBucket(head: head)
    assert(begin_ptr.pointee == head.end_ptr, "空の木の初期条件を満たしていること")
  }

  @usableFromInline var count: Int = 0
  @usableFromInline var recycleHead: _NodePtr
  @usableFromInline var freshPoolCapacity: Int = 0
  @usableFromInline var freshBucketCurrent: _BucketQueue?
  @usableFromInline var freshPoolUsedCount: Int = 0
  @usableFromInline var freshBucketHead: _BucketPointer?
  @usableFromInline var freshBucketLast: _BucketPointer?
  @usableFromInline let nullptr: _NodePtr
  @usableFromInline let begin_ptr: _NodeRef
  @usableFromInline var root_ptr: _NodeRef
  @usableFromInline var freshBucketAllocator: _BucketAllocator

  /// IndexやIteratorを結ぶ共有メモリオブジェクトの内部プロパティ
  ///
  /// - WARNING: 外部から変更しないこと。未定義動作や過剰開放となります。
  @usableFromInline var _tied: _TiedRawBuffer?

  @usableFromInline var _lazyDetach: _LazyTie?

  #if DEBUG
    @usableFromInline var freshBucketCount: Int = 0
  #endif

  #if AC_COLLECTIONS_INTERNAL_CHECKS
    /// CoWの発火回数を観察するためのプロパティ
    @usableFromInline internal var copyCount: UInt = 0
  #endif
}

extension UnsafeTreeV2BufferHeader {

  /// `_Payload`のstrideとalignement
  @inlinable
  var payloadLayout: _MemoryLayout {
    freshBucketAllocator.payload
  }

  @inlinable
  var end_ptr: _NodePtr {
    freshBucketHead!.end_ptr
  }

  @inlinable
  var __root: _NodePtr {
    @inline(__always)
    @_transparent
    unsafeAddress {
      UnsafePointer(root_ptr)
    }
    @inline(__always)
    @_transparent
    nonmutating unsafeMutableAddress {
      root_ptr
    }
  }

  @inlinable
  internal func __root_ptr() -> _NodeRef { root_ptr }

  /// IndexやIteratorとのメモリ共有が発生してないことを示す
  @usableFromInline
  var isRawBufferUniquelyOwned: Bool {
    _tied == nil
  }

  @inlinable
  mutating func isLazyDetachUniquelyOwned() -> Bool {
    guard let _ = _lazyDetach else { return true }
    return isKnownUniquelyReferenced(&_lazyDetach!)
  }
  /// IndexやIteratorを結ぶ共有メモリ
  ///
  /// ヘッダーにとっては解放責任のデタッチ先
  ///
  /// - WARNING: 触ると生成されるので不必要に触らないこと
  @usableFromInline
  var tiedRawBuffer: _TiedRawBuffer {
    mutating get {
      // TODO: 一度の保証付きの実装にすること
      if _tied == nil {
        _tied = .create(
          bucket: freshBucketHead,
          deallocator: freshBucketAllocator)
      }
      return _tied!
    }
  }

  @inlinable
  var lazyDetach: _LazyTie {
    mutating get {
      // TODO: 一度の保証付きの実装にすること
      if _lazyDetach == nil {
        _lazyDetach = .create()
      }
      return _lazyDetach!
    }
  }

  /// 確保済みメモリの内容を未初期化に戻し、木を空にする
  @usableFromInline
  internal mutating func deinitialize() {
    ___flushFreshPool()
    ___flushRecyclePool()
    begin_ptr.pointee = end_ptr
    end_ptr.pointee.__left_ = nullptr
  }
}

#if USE_FRESH_POOL_PROTOCOL
  extension UnsafeTreeV2BufferHeader: _FreshPool {}
#else
  /* ------------ _FreshPoolのインライン化はじまり  -------------  */

  extension UnsafeTreeV2BufferHeader {
    public typealias _BucketPointer = UnsafeMutablePointer<_Bucket>
  }

  extension UnsafeTreeV2BufferHeader {

    /*
     NOTE:
     Normally, FreshPool may grow by adding multiple buckets.
     However, immediately after CoW, callers MUST ensure that
     only a single bucket exists to support index-based access.
     */

    @inlinable
    mutating func pushFreshBucket(head: _BucketPointer) {
      freshBucketHead = head
      freshBucketCurrent = head.queue(payloadLayout: payloadLayout)
      freshBucketLast = head
      freshPoolCapacity += head.pointee.capacity
      #if DEBUG
        freshBucketCount += 1
      #endif
    }

    @inlinable
    mutating func pushFreshBucket(additionalCapacity: Int) {
      assert(freshBucketHead == nil || additionalCapacity != 0, "先頭のみ容量0を許容し、移行は容量0を許容しないこと")
      let pointer = freshBucketAllocator.createBucket(bucketCapacity: additionalCapacity)
      freshBucketLast?.pointee.next = pointer
      freshBucketLast = pointer
      freshPoolCapacity &+= additionalCapacity
      #if DEBUG
        freshBucketCount &+= 1
      #endif
    }

    @inlinable
    mutating func popFresh() -> _NodePtr? {
      if let p = freshBucketCurrent?.pop() {
        return p
      }
      freshBucketCurrent = freshBucketCurrent?.next(payload: payloadLayout)
      return freshBucketCurrent?.pop()
    }
  }

  extension UnsafeTreeV2BufferHeader {

    /*
     IMPORTANT:
     After a Copy-on-Write operation, node access is performed via index-based
     lookup. To guarantee O(1) address resolution and avoid bucket traversal,
     the FreshPool must contain exactly ONE bucket at this point.

     Invariant:
       - During and immediately after CoW, `reserverBucketCount == 1`
       - Index-based access relies on a single contiguous bucket

     Violating this invariant may cause excessive traversal or undefined behavior.
    */
    @inlinable
    subscript(___tracking_tag: _TrackingTag) -> _NodePtr {
      assert(___tracking_tag >= 0, "特殊ノードの取得要求をされないこと")
      var remaining = Int(truncatingIfNeeded: ___tracking_tag)
      var p = freshBucketHead?.accessor(payload: payloadLayout)
      while let h = p {
        let cap = h.capacity
        if remaining < cap {
          return h[remaining]
        }
        remaining -= cap
        p = h.next(payload: payloadLayout)
      }
      return nullptr
    }
  }

  extension UnsafeTreeV2BufferHeader {

    @usableFromInline
    mutating func ___flushFreshPool() {
      freshBucketAllocator.deinitialize(bucket: freshBucketHead)
      freshPoolUsedCount = 0
      freshBucketCurrent = freshBucketHead?.queue(payloadLayout: payloadLayout)
    }

    @usableFromInline
    mutating func ___deallocFreshPool() {
      assert(_tied == nil, "メモリ管理権が移行されていないこと")
      freshBucketAllocator.deallocate(bucket: freshBucketHead)
    }
  }

  extension UnsafeTreeV2BufferHeader {

    @usableFromInline typealias UsedIterator = _FreshPoolUsedIterator

    @inlinable
    func makeUsedNodeIterator<T>() -> _FreshPoolUsedIterator<T> {
      return _FreshPoolUsedIterator<T>(bucket: freshBucketHead)
    }
  }

/* ------------ _FreshPoolのインライン化おわり  -------------  */

#endif

#if USE_RECYCLE_POOL_PROTOCOL
  extension UnsafeTreeV2BufferHeader: _RecyclePool {}
#else
  /* ------------ _RecyclePoolのインライン化はじまり  -------------  */

  extension UnsafeTreeV2BufferHeader {

    @inlinable
    mutating func ___pushRecycle(_ p: _NodePtr) {
      assert(p.__parent_.___is_null || p.__slow_end() == end_ptr, "木が異なるのは不可")
      assert(p.pointee.___tracking_tag > .end, "特殊ポインタのリサイクル不可")
      assert(recycleHead != p, "過剰リサイクル不可")
      count -= 1
      #if DEBUG || true
        p.pointee.___recycle_count &+= 1
      #endif
      freshBucketAllocator.deinitialize(p.advanced(by: 1))
      #if DEBUG
        payloadDeinitializedCount += 1
      #endif
      #if GRAPHVIZ_DEBUG
        p.pointee.__right_ = nullptr
        p.pointee.__parent_ = nullptr
      #endif
      p.pointee.___has_payload_content = false
      p.pointee.__left_ = recycleHead
      recycleHead = p
    }

    @usableFromInline
    mutating func ___popRecycle() -> _NodePtr {
      let p = recycleHead
      recycleHead = p.pointee.__left_
      count += 1
      p.pointee.___has_payload_content = true
      return p
    }

    @usableFromInline
    mutating func ___flushRecyclePool() {
      recycleHead = nullptr
      count = 0  // これは不適切な気がする
    }
  }
/* ------------ _RecyclePoolのインライン化おわり  -------------  */
#endif

#if DEBUG
extension UnsafeTreeV2BufferHeader: _FreshPoolDebug {}
#endif

#if DEBUG || GRAPHVIZ_DEBUG
extension UnsafeTreeV2BufferHeader: _RecyclePoolDebug {}
#endif

extension UnsafeTreeV2BufferHeader {

  @inlinable
  mutating public func ___popFresh() -> _NodePtr {
    assert(freshPoolUsedCount < freshPoolCapacity, "未使用容量の残数が0ではないこと")
    guard let p = popFresh() else {
      return nullptr
    }
    assert(p.pointee.___tracking_tag == .debug, "未使用ノードであること")
    #if true
      p.initialize(to: nullptr.pointee)
      p.pointee.___tracking_tag = _TrackingTag(truncatingIfNeeded: freshPoolUsedCount)
    #else
      p.initialize(to: .create(id: freshPoolUsedCount))
    #endif
    #if DEBUG
      nodeInitializedCount += 1
    #endif
    freshPoolUsedCount += 1
    count += 1
    return p
  }
}

extension UnsafeTreeV2BufferHeader {

  public mutating func __construct_raw_node() -> _NodePtr {
    #if DEBUG
      assert(recycleCount >= 0, "リサイクル残がある場合は新規ノードを利用しないこと")
    #endif
    let p = recycleHead == nullptr ? ___popFresh() : ___popRecycle()
    assert(p.pointee.___tracking_tag >= 0, "特殊ノードではないこと")
    return p
  }

  public mutating func __construct_node<T>(_ k: T) -> _NodePtr {
    #if DEBUG
      assert(recycleCount >= 0, "リサイクル残がある場合は新規ノードを利用しないこと")
    #endif
    let p = recycleHead == nullptr ? ___popFresh() : ___popRecycle()
    p.__value_().initialize(to: k)
    #if DEBUG
      payloadInitializedCount += 1
    #endif
    assert(p.pointee.___tracking_tag >= 0, "特殊ノードではないこと")
    return p
  }
}
