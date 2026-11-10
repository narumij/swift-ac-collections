//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project.
//
// Copyright (c) 2024-2026 narumij.
// Licensed under the Apache License v2.0.
//
// SPDX-License-Identifier: Apache-2.0
//
// This implementation includes code derived from LLVM libc++'s red-black tree
// implementation, originally distributed under the Apache License v2.0 with
// LLVM Exceptions.
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by
// narumij.
//
//===----------------------------------------------------------------------===//

import Synchronization

@usableFromInline
let _lazyDetachLock = Mutex<Void>(())

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
    self.root_ptr = head.end_ptr.pointer(to: \.__left_)!
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

  // IndexやIteratorを結ぶ共有メモリオブジェクトの内部プロパティ
  //
  // - WARNING: 外部から変更しないこと。未定義動作や過剰開放となります。
  @usableFromInline var _tied: _TiedRawBuffer?

  #if ENABLE_EXPERIMENTAL_TSAN_SAFE
  // 試作: _lazyDetachの実体はmallocしたセルに置き、ヘッダはそのポインタだけを持つ
  // （セルの解放は未対応）
  @usableFromInline var lazyDetachPointer: UnsafeMutablePointer<_LazyTie>?

  // TODO: 全削除の際にnilにする動作が追加されている。常に一意でないことに関して再考慮すること。
  @inlinable
  var _lazyDetach: _LazyTie? {
    @inline(__always)
    get { lazyDetachPointer?.pointee }
    @inline(__always)
    set {
      guard let newValue else {
        lazyDetachPointer = nil
        return
      }
      if let p = lazyDetachPointer {
        p.pointee = newValue
      } else {
        let p = UnsafeMutablePointer<_LazyTie>.allocate(capacity: 1)
        p.initialize(to: newValue)
        lazyDetachPointer = p
      }
    }
  }
  #else
  // TODO: 全削除の際にnilにする動作が追加されている。常に一意でないことに関して再考慮すること。
  @usableFromInline var _lazyDetach: _LazyTie?
  #endif

  #if DEBUG
    @usableFromInline var freshBucketCount: Int = 0
  #endif

  #if _TREE_COPY_COUNTER
    // CoWの発火回数を観察するためのプロパティ
    @usableFromInline internal var copyCount: UInt = 0
  #endif
}

extension UnsafeTreeV2BufferHeader {

  @inlinable
  var nodeLayout: _MemoryLayout {
    freshBucketAllocator.nodeLayout
  }

  // `_Payload`のstrideとalignement
  @inlinable
  var payloadLayout: _MemoryLayout {
    freshBucketAllocator.payloadLayout
  }

  @inlinable
  var pairLayout: _MemoryLayout {
    freshBucketAllocator.pairLayout
  }

  @inlinable
  var end_ptr: _NodePtr {
    @inline(__always)
    _read {
      yield freshBucketHead!.end_ptr
    }
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

  // IndexやIteratorとのメモリ共有が発生してないことを示す
  @usableFromInline
  var isRawBufferUniquelyOwned: Bool {
    _tied == nil
  }

  @inlinable
  mutating func isLazyDetachUniquelyOwned() -> Bool {
    #if ENABLE_EXPERIMENTAL_TSAN_SAFE
    guard let p = lazyDetachPointer else { return true }
    return isKnownUniquelyReferenced(&p.pointee)
    #else
    guard let _ = _lazyDetach else { return true }
    return isKnownUniquelyReferenced(&_lazyDetach!)
    #endif
  }

  // IndexやIteratorを結ぶ共有メモリ
  //
  // ヘッダーにとっては解放責任のデタッチ先
  //
  // - WARNING: 触ると生成されるので不必要に触らないこと
  @usableFromInline
  var tiedRawBuffer: _TiedRawBuffer {
    mutating get {
      if _tied == nil {
        _tied = .create(
          bucket: freshBucketHead,
          deallocator: freshBucketAllocator)
      }
      return _tied!
    }
  }

  #if false
  @inlinable
  var lazyDetach: _LazyTie {
    mutating get {
      if _lazyDetach == nil {
        _lazyDetach = .create()
      }
      return _lazyDetach!
    }
  }
  #else
  @inlinable
  var lazyDetach: _LazyTie {
    mutating get {
      if _lazyDetach == nil {
        _createLazyDetachLocked()
      }
      return _lazyDetach!
    }
  }
  
  @usableFromInline
  @inline(never)
  mutating func _createLazyDetachLocked() {
    _lazyDetachLock.withLock { _ in
      if _lazyDetach == nil {
        let t = _LazyTie.create()
        atomicMemoryFence(ordering: .releasing)
        _lazyDetach = t
      }
    }
  }
  #endif

  @usableFromInline
  internal mutating func deinitialize() {
    ___flushFreshPool()
    ___flushRecyclePool()
    begin_ptr.pointee = end_ptr
    end_ptr.pointee.__left_ = nullptr
    if _lazyDetach != nil {
      _lazyDetach?.release()
      _lazyDetach = .create()
    }
  }
}

extension UnsafeTreeV2BufferHeader {

  @inlinable
  mutating func index(_ p: _NodePtr) -> _LazyTieWrappedPtrV2 {
    assert(p != .nullptr)
    return .unchecked(p, end_ptr: end_ptr, lazyDetach: lazyDetach)
  }
  
  @inlinable
  mutating func index(_ p: _NodePtr) -> _LazyTiedPtrV2 {
    assert(p != .nullptr)
    return .unchecked(p, end_ptr: end_ptr, lazyDetach: lazyDetach)
  }
  
  @inlinable
  mutating func index_or_nil(_ p: _NodePtr) -> _LazyTiedPtrV2? {
    assert(p != .nullptr)
    return p.___has_payload_content ? .some(index(p)) : .none
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
      freshBucketCurrent = head.queue(pairLayout: pairLayout)
      freshBucketLast = head
      freshPoolCapacity &+= head.pointee.capacity
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
      freshBucketCurrent = freshBucketCurrent?.next(pairLayout: pairLayout)
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
      assert(___tracking_tag < freshPoolUsedCount)
      var remaining = Int(truncatingIfNeeded: ___tracking_tag)
      var p = freshBucketHead?.accessor(pairLayout: pairLayout)
      while let h = p {
        let cap = h.capacity
        if remaining < cap {
          return h[remaining]
        }
        remaining &-= cap
        p = h.next(payload: pairLayout)
      }
      return nullptr
    }
  }

  extension UnsafeTreeV2BufferHeader {

    // TODO: 取り急ぎの修正なので、再度吟味すること
    @usableFromInline
    mutating func ___flushFreshPool() {
      freshBucketAllocator.flush(bucket: freshBucketHead)
      freshPoolUsedCount = 0
      freshBucketCurrent = freshBucketHead?.queue(pairLayout: pairLayout)
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
      return _FreshPoolUsedIterator<T>(bucket: freshBucketHead, nodeLayout: nodeLayout, pairLayout: pairLayout)
    }
  }

/* ------------ _FreshPoolのインライン化おわり  -------------  */

#endif

#if USE_RECYCLE_POOL_PROTOCOL
  extension UnsafeTreeV2BufferHeader: _RecyclePool {}
#else
  /* ------------ _RecyclePoolのインライン化はじまり  -------------  */

  extension UnsafeTreeV2BufferHeader {

    #if true
    @inlinable
    mutating func ___pushRecycle(_ p: _NodePtr) {
      assert(p.__parent_.___is_null || p.__slow_end() == end_ptr, "木が異なるのは不可")
      assert(p.pointee.___tracking_tag > .end, "特殊ポインタのリサイクル不可")
      assert(recycleHead != p, "過剰リサイクル不可")
      count &-= 1
      assert(count >= 0)
#if USE_RECYCLE_COUNT_OVERWRAP
      // 解放時に世代変更することで、解放チェックと世代チェックの双方を世代チェックで満たせる
      p.pointee.___recycle_count &+= 1
#else
      if p.pointee.___recycle_count < UnsafeNode.Seal.max {
        p.pointee.___recycle_count &+= 1
      }
#endif
      freshBucketAllocator.deinitialize(p.advanced(by: 1))
      #if _TREE_ALLOCATION_COUNTER
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
    #else
    // TODO: 性能確認
    @inlinable
    mutating func ___pushRecycle(_ p: _NodePtr) {
      freshBucketAllocator.deinitialize(p.advanced(by: 1))
      ___raw_pushRecycle(p)
    }
    #endif

    @inlinable
    mutating func ___raw_pushRecycle(_ p: _NodePtr) {
      assert(p.__parent_.___is_null || p.__slow_end() == end_ptr, "木が異なるのは不可")
      assert(p.pointee.___tracking_tag > .end, "特殊ポインタのリサイクル不可")
      assert(recycleHead != p, "過剰リサイクル不可")
      count &-= 1
      assert(count >= 0)
#if USE_RECYCLE_COUNT_OVERWRAP
      // 解放時に世代変更することで、解放チェックと世代チェックの双方を世代チェックで満たせる
      p.pointee.___recycle_count &+= 1
#else
      if p.pointee.___recycle_count < .max {
        p.pointee.___recycle_count &+= 1
      }
#endif
      #if _TREE_ALLOCATION_COUNTER
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
      count &+= 1
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
      p.initialize(to: UnsafeNode.template.pointee)
      p.pointee.___tracking_tag = _TrackingTag(truncatingIfNeeded: freshPoolUsedCount)
    #else
      p.initialize(
        to: .create(
          tag: _TrackingTag(truncatingIfNeeded: freshPoolUsedCount),
          nullptr: nullptr))
    #endif
    assert(p.pointee.___has_payload_content == true)
    #if _TREE_ALLOCATION_COUNTER
      nodeInitializedCount += 1
    #endif
    freshPoolUsedCount &+= 1
    count &+= 1
    return p
  }
}

extension UnsafeTreeV2BufferHeader {

  @inlinable
  public mutating func __construct_raw_node() -> _NodePtr {
    #if DEBUG
      assert(recycleCount >= 0, "リサイクル残がある場合は新規ノードを利用しないこと")
    #endif
    let p = recycleHead == nullptr ? ___popFresh() : ___popRecycle()
    assert(p.pointee.___tracking_tag >= 0, "特殊ノードではないこと")
    return p
  }

  @inlinable
  public mutating func __construct_node<T>(_ k: T) -> _NodePtr {
    #if DEBUG
      assert(recycleCount >= 0, "リサイクル残がある場合は新規ノードを利用しないこと")
    #endif
    let p = recycleHead == nullptr ? ___popFresh() : ___popRecycle()
    p.__value_().initialize(to: k)
    #if _TREE_ALLOCATION_COUNTER
      payloadInitializedCount += 1
    #endif
    assert(p.pointee.___tracking_tag >= 0, "特殊ノードではないこと")
    return p
  }
}
