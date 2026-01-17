// Copyright 2024-2026 narumij
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2025 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

@usableFromInline
typealias Deallocator = _UnsafeNodeFreshPoolV3DeallocatorR2

//extension UnsafeTreeV2Buffer {

  @frozen
  public struct UnsafeTreeV2BufferHeader: _UnsafeNodeRecyclePool {
    public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

    @inlinable
    @inline(__always)
    internal init<_Value>(_ t: _Value.Type,nullptr: _NodePtr) {
      self.nullptr = nullptr
      self.recycleHead = nullptr
      self.freshBucketAllocator = .init(valueType: _Value.self) {
        $0.assumingMemoryBound(to: _Value.self)
          .deinitialize(count: 1)
      }
    }

    @usableFromInline var count: Int = 0
    @usableFromInline var recycleHead: _NodePtr
    @usableFromInline var freshPoolCapacity: Int = 0
    @usableFromInline var freshBucketCurrent: _BucketPointer?
    @usableFromInline var freshPoolUsedCount: Int = 0
    @usableFromInline var freshBucketHead: _BucketPointer?
    @usableFromInline var freshBucketLast: _BucketPointer?
    @usableFromInline let nullptr: _NodePtr
    @usableFromInline
    var freshBucketAllocator: _UnsafeNodeFreshBucketAllocator
    #if DEBUG
      @usableFromInline var freshBucketCount: Int = 0
    #endif

    @inlinable @inline(__always)
    var __end_node: _NodePtr? {
      freshBucketHead.map {
        UnsafeMutableRawPointer($0.advanced(by: 1))
          .assumingMemoryBound(to: UnsafeNode.self)
      }
    }

    @usableFromInline var _deallocator: Deallocator?

    @inlinable @inline(__always)
    var needsDealloc: Bool {
      _deallocator == nil
    }

    @inlinable @inline(__always)
    var deallocator: Deallocator {
      mutating get {
        // TODO: 一度の保証付きの実装にすること
        if _deallocator == nil {
          _deallocator = .create(
            bucket: freshBucketHead,
            deallocator: freshBucketAllocator)
        }
        return _deallocator!
      }
    }

    #if DEBUG
      @inlinable
      @inline(__always)
      mutating func createDeallocator() {
        _ = deallocator
      }
    #endif

    #if AC_COLLECTIONS_INTERNAL_CHECKS
      /// CoWの発火回数を観察するためのプロパティ
      @usableFromInline internal var copyCount: UInt = 0
    #endif

    @inlinable
    @inline(__always)
    internal mutating func deinitialize() {
      ___flushFreshPool()
      ___flushRecyclePool()
    }
  }
//}

/* ------------ V3のインライン化はじまり  -------------  */

extension UnsafeTreeV2BufferHeader {
  @usableFromInline typealias _Bucket = _UnsafeNodeFreshBucket
  @usableFromInline typealias _BucketPointer = UnsafeMutablePointer<_UnsafeNodeFreshBucket>
}

extension UnsafeTreeV2BufferHeader {

  /*
   NOTE:
   Normally, FreshPool may grow by adding multiple buckets.
   However, immediately after CoW, callers MUST ensure that
   only a single bucket exists to support index-based access.
   */

  @inlinable
  @inline(__always)
  //  @usableFromInline
  mutating func pushFreshHeadBucket(capacity: Int) {
    assert(freshBucketHead == nil || capacity != 0)
    let (pointer, capacity) = freshBucketAllocator.createHeadBucket(
      capacity: capacity, nullptr: nullptr)
    freshBucketHead = pointer
    freshBucketCurrent = pointer
    freshBucketLast = pointer
    freshPoolCapacity += capacity
    #if DEBUG
      freshBucketCount += 1
    #endif
  }

  @inlinable
  @inline(__always)
  //  @usableFromInline
  mutating func pushFreshBucket(capacity: Int) {
    assert(freshBucketHead == nil || capacity != 0)
    let (pointer, capacity) = freshBucketAllocator.createBucket(capacity: capacity)
    freshBucketLast?.pointee.next = pointer
    freshBucketLast = pointer
    freshPoolCapacity += capacity
    #if DEBUG
      freshBucketCount += 1
    #endif
  }

  @inlinable
  @inline(__always)
  mutating func popFresh() -> _NodePtr? {
    if let p = freshBucketCurrent?.pointee.pop() {
      return p
    }
    freshBucketCurrent = freshBucketCurrent?.pointee.next
    return freshBucketCurrent?.pointee.pop()
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
  @inline(__always)
  subscript(___node_id_: Int) -> _NodePtr {
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
    return nullptr
  }
}

extension UnsafeTreeV2BufferHeader {

  @inlinable
  @inline(__always)
  mutating func ___flushFreshPool() {
    freshBucketAllocator.deinitialize(freshBucketHead)
    freshPoolUsedCount = 0
    freshBucketCurrent = freshBucketHead
  }

  @inlinable
  @inline(__always)
  mutating func ___deallocFreshPool() {
    freshBucketAllocator.deallocate(freshBucketHead)
  }
}

extension UnsafeTreeV2BufferHeader {
  // TODO: ジェネリクスが外れたらPOOL V3に戻す
  @inlinable
  @inline(__always)
  var freshPoolNumBytes: Int {
    var bytes = 0
    var p = freshBucketHead
    while let h = p {
      bytes += h.pointee.count * freshBucketAllocator.nodeValueStride
      p = h.pointee.next
    }
    return bytes
  }
}

extension UnsafeTreeV2BufferHeader {
  // TODO: ジェネリクスが外れたらPOOL V3に戻す
  @inlinable
  @inline(__always)
  func makeFreshBucketIterator<T>() -> _UnsafeNodeFreshBucketIterator<T> {
    return _UnsafeNodeFreshBucketIterator<T>(bucket: freshBucketHead)
  }
}

extension UnsafeTreeV2BufferHeader {
  
  @usableFromInline typealias Iterator = _UnsafeNodeFreshPoolIterator
  
  @inlinable
  @inline(__always)
  func makeFreshPoolIterator<T>() -> _UnsafeNodeFreshPoolIterator<T> {
    return _UnsafeNodeFreshPoolIterator<T>(bucket: freshBucketHead, nullptr: nullptr)
  }
}

extension UnsafeTreeV2BufferHeader {

  // TODO: いろいろ試すための壁で、いまは余り意味が無いのでタイミングでインライン化する
  // Headerに移すのが妥当かも。そうすれば_Value依存が消せる
  @inlinable
  @inline(__always)
  mutating public
    func ___popFresh() -> _NodePtr
  {
    assert(freshPoolUsedCount < freshPoolCapacity)
    guard let p = popFresh() else {
      return nullptr
    }
    assert(p.pointee.___node_id_ == .debug)
//    UnsafeNode.bindValue(_Value.self, p)
    p.initialize(to: nullptr.create(id: freshPoolUsedCount))
    freshPoolUsedCount += 1
    count += 1
    return p
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

/* ------------ V3のインライン化おわり  -------------  */

extension UnsafeTreeV2BufferHeader {

  @inlinable
  @inline(__always)
  public mutating func __construct_node<T>(_ k: T) -> _NodePtr {
    #if DEBUG
      assert(recycleCount >= 0)
    #endif
    let p = recycleHead.pointerIndex == .nullptr ? ___popFresh() : ___popRecycle()
    p.__value_().initialize(to: k)
    assert(p.pointee.___node_id_ >= 0)
    return p
  }
}
