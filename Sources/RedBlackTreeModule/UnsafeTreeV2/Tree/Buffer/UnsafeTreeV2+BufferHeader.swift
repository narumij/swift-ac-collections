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
package struct UnsafeTreeV2BufferHeader: _RecyclePool {
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

  @inlinable
  @inline(__always)
  internal init<_PayloadValue>(_ t: _PayloadValue.Type, nullptr: _NodePtr, capacity: Int) {
    let allocator = _BucketAllocator(valueType: _PayloadValue.self) {
      $0.assumingMemoryBound(to: _PayloadValue.self)
        .deinitialize(count: 1)
    }
    self.init(allocator: allocator, nullptr: nullptr, capacity: capacity)
  }

  @inlinable
  @inline(__always)
  internal init(allocator: _BucketAllocator, nullptr: _NodePtr, capacity: Int) {
    let (head, _) = allocator.createHeadBucket(capacity: capacity, nullptr: nullptr)
    self.recycleHead = nullptr
    self.nullptr = nullptr
    self.begin_ptr = head.begin_ptr
    self.root_ptr = _ref(to: &head.end_ptr.pointee.__left_)
    self.freshBucketAllocator = allocator
    self.pushFreshBucket(head: head)
    assert(begin_ptr.pointee == head.end_ptr)
  }

  @usableFromInline var count: Int = 0
  @usableFromInline var recycleHead: _NodePtr
  @usableFromInline var freshPoolCapacity: Int = 0
  @usableFromInline var freshBucketCurrent: _BucketQueue?
  @usableFromInline var freshPoolUsedCount: Int = 0
  @usableFromInline var freshBucketHead: _BucketPointer?
  @usableFromInline var freshBucketLast: _BucketPointer?
  @usableFromInline let nullptr: _NodePtr
  @usableFromInline var begin_ptr: _NodeRef
  @usableFromInline var root_ptr: _NodeRef
  @usableFromInline var freshBucketAllocator: _BucketAllocator

  /// IndexやIteratorを結ぶ共有メモリオブジェクトの内部プロパティ
  ///
  /// - WARNING: 外部から変更しないこと。未定義動作や過剰開放となります。
  @usableFromInline var _tied: _TiedRawBuffer?

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
  var payload: _MemoryLayout {
    freshBucketAllocator.payload
  }

  @inlinable
  var end_ptr: _NodePtr {
    freshBucketHead!.end_ptr
  }

  @inlinable
  var __root: _NodePtr {
    get { root_ptr.pointee }
    nonmutating set { root_ptr.pointee = newValue }
  }

  @inlinable
  internal func __root_ptr() -> _NodeRef { root_ptr }

  /// IndexやIteratorとのメモリ共有が発生してないことを示す
  @usableFromInline
  var isRawBufferUniquelyOwned: Bool {
    _tied == nil
  }

  /// IndexやIteratorを結ぶ共有メモリ
  ///
  /// ヘッダーにとっては解放責任のデタッチ先
  ///
  /// - WARNING: 触ると生成されるので不必要に触らないこと
  @inlinable
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
  
  /// 確保済みメモリの内容を未初期化に戻し、木を空にする
  @inlinable
  internal mutating func deinitialize() {
    ___flushFreshPool()
    ___flushRecyclePool()
    begin_ptr.pointee = end_ptr
    end_ptr.pointee.__left_ = nullptr
  }
}

#if false
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
      freshBucketCurrent = head.queue(payload: payload)
      freshBucketLast = head
      freshPoolCapacity += head.pointee.capacity
      #if DEBUG
        freshBucketCount += 1
      #endif
    }

    @inlinable
    mutating func pushFreshBucket(capacity: Int) {
      assert(freshBucketHead == nil || capacity != 0)
      let (pointer, _) = freshBucketAllocator.createBucket(capacity: capacity)
      freshBucketLast?.pointee.next = pointer
      freshBucketLast = pointer
      freshPoolCapacity += capacity
      #if DEBUG
        freshBucketCount += 1
      #endif
    }

    @inlinable
    mutating func popFresh() -> _NodePtr? {
      if let p = freshBucketCurrent?.pop() {
        return p
      }
      freshBucketCurrent = freshBucketCurrent?.next(payload: payload)
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
      assert(___tracking_tag >= 0)
      var remaining = ___tracking_tag
      var p = freshBucketHead?.accessor(payload: payload)
      while let h = p {
        let cap = h.capacity
        if remaining < cap {
          return h[remaining]
        }
        remaining -= cap
        p = h.next(payload: payload)
      }
      return nullptr
    }
  }

  extension UnsafeTreeV2BufferHeader {

    @usableFromInline
    mutating func ___flushFreshPool() {
      freshBucketAllocator.deinitialize(bucket: freshBucketHead)
      freshPoolUsedCount = 0
      freshBucketCurrent = freshBucketHead?.queue(payload: payload)
    }

    @usableFromInline
    mutating func ___deallocFreshPool() {
      assert(_tied == nil)
      freshBucketAllocator.deallocate(bucket: freshBucketHead)
    }
  }

  #if false
    extension UnsafeTreeV2BufferHeader {
      @inlinable
      func makeFreshBucketIterator<T>() -> _UnsafeNodeFreshBucketIterator<T> {
        return _UnsafeNodeFreshBucketIterator<T>(bucket: freshBucketHead)
      }
    }
  #endif

  extension UnsafeTreeV2BufferHeader {

    @usableFromInline typealias UsedIterator = _FreshPoolUsedIterator

    @inlinable
    func makeUsedNodeIterator<T>() -> _FreshPoolUsedIterator<T> {
      return _FreshPoolUsedIterator<T>(bucket: freshBucketHead)
    }
  }

  #if DEBUG
    extension UnsafeTreeV2BufferHeader {

      @inlinable
      @inline(__always)
      var freshPoolActualCapacity: Int {
        var count = 0
        var p = freshBucketHead
        while let h = p {
          count += h.pointee.capacity
          p = h.pointee.next
        }
        return count
      }

      @inlinable
      @inline(__always)
      var freshPoolActualCount: Int {
        var count = 0
        var p = freshBucketHead
        while let h = p {
          count += h.pointee.count
          p = h.pointee.next
        }
        return count
      }
    }
  #endif

/* ------------ _FreshPoolのインライン化おわり  -------------  */

#endif

extension UnsafeTreeV2BufferHeader {

  @inlinable
  mutating public
    func ___popFresh() -> _NodePtr
  {
    assert(freshPoolUsedCount < freshPoolCapacity)
    guard let p = popFresh() else {
      return nullptr
    }
    assert(p.pointee.___tracking_tag == .debug)
    #if true
      p.initialize(to: nullptr.pointee)
      p.pointee.___tracking_tag = freshPoolUsedCount
    #else
      p.initialize(to: .create(id: freshPoolUsedCount))
    #endif
    freshPoolUsedCount += 1
    count += 1
    return p
  }
}

extension UnsafeTreeV2BufferHeader {

  @inlinable
  @inline(__always)
  public mutating func __construct_raw_node() -> _NodePtr {
    #if DEBUG
      assert(recycleCount >= 0)
    #endif
    let p = recycleHead == nullptr ? ___popFresh() : ___popRecycle()
    assert(p.pointee.___tracking_tag >= 0)
    return p
  }

  public mutating func __construct_node<T>(_ k: T) -> _NodePtr {
    #if DEBUG
      assert(recycleCount >= 0)
    #endif
    let p = recycleHead == nullptr ? ___popFresh() : ___popRecycle()
    p.__value_().initialize(to: k)
    assert(p.pointee.___tracking_tag >= 0)
    return p
  }
}
