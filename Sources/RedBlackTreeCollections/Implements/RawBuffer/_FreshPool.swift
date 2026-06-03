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

#if USE_FRESH_POOL_PROTOCOL
  // NOTE: 性能過敏なので修正する場合は必ず計測しながら行うこと
  // とはいえ、これは作業用。実際にはBufferHeaderにコピペインライン化している
  @usableFromInline
  protocol _FreshPool: _UnsafeNodePtrType {

    /*
     Design invariant:
     - FreshPool may consist of multiple buckets in general.
     - Immediately after CoW, the pool must be constrained to a single bucket
     because index-based access is performed.
     */

    var freshBucketHead: _BucketPointer? { get set }
    var freshBucketCurrent: _BucketQueue? { get set }
    var freshBucketLast: _BucketPointer? { get set }
    var freshPoolCapacity: Int { get set }
    var freshPoolUsedCount: Int { get set }
    var count: Int { get set }
    var nullptr: _NodePtr { get }
    #if DEBUG
      var freshBucketCount: Int { get set }
    #endif
    var freshBucketAllocator: _BucketAllocator { get }

    var payloadLayout: _MemoryLayout { get }
  }

  extension _FreshPool {
    public typealias _BucketPointer = UnsafeMutablePointer<_Bucket>
  }

  extension _FreshPool {

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
      freshPoolCapacity += additionalCapacity
      #if DEBUG
        freshBucketCount += 1
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

  extension _FreshPool {

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
      var remaining = ___tracking_tag
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

  extension _FreshPool {

    @usableFromInline
    mutating func ___flushFreshPool() {
      freshBucketAllocator.deinitialize(bucket: freshBucketHead)
      freshPoolUsedCount = 0
      freshBucketCurrent = freshBucketHead?.queue(payloadLayout: payloadLayout)
    }

    @usableFromInline
    mutating func ___deallocFreshPool() {
      //      assert(_tied == nil, "メモリ管理権が移行されていないこと")
      freshBucketAllocator.deallocate(bucket: freshBucketHead)
    }
  }

  // MARK: - 作業用サイズ計算

  extension _FreshPool {

    @usableFromInline typealias UsedIterator = _FreshPoolUsedIterator

    @inlinable
    func makeUsedNodeIterator<T>() -> _FreshPoolUsedIterator<T> {
      return _FreshPoolUsedIterator<T>(bucket: freshBucketHead)
    }
  }

// MARK: - DEBUG

#endif

#if DEBUG
  @usableFromInline
  protocol _FreshPoolDebug: _UnsafeNodePtrType {
    var freshBucketHead: _BucketPointer? { get set }
    var freshBucketCurrent: _BucketQueue? { get set }
    var freshBucketLast: _BucketPointer? { get set }
    var freshPoolCapacity: Int { get set }
    var freshPoolUsedCount: Int { get set }
    var count: Int { get set }
    var nullptr: _NodePtr { get }
    var freshBucketCount: Int { get set }
    var freshBucketAllocator: _BucketAllocator { get }
    var payloadLayout: _MemoryLayout { get }
  }

  extension _FreshPoolDebug {

    public typealias _BucketPointer = UnsafeMutablePointer<_Bucket>

    @inlinable
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
