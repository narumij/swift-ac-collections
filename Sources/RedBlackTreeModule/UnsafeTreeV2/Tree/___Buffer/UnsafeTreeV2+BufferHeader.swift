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


@frozen
public struct UnsafeTreeV2BufferHeader: _UnsafeNodeRecyclePool {
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

  @inlinable
  internal init<_Value>(_ t: _Value.Type, nullptr: _NodePtr, capacity: Int) {
    let allocator = _UnsafeNodeFreshBucketAllocator(valueType: _Value.self) {
      $0.assumingMemoryBound(to: _Value.self)
        .deinitialize(count: 1)
    }
    let (head,_) = allocator.createHeadBucket(capacity: capacity, nullptr: nullptr)
    self.nullptr = nullptr
    self.recycleHead = nullptr
    self.freshBucketAllocator = allocator
    self.begin_ptr = head.end_ptr
    self.root_ptr = withUnsafeMutablePointer(to: &head.end_ptr.pointee.__left_) { $0 }
    self.pushFresBucket(head: head)
  }

  @usableFromInline var count: Int = 0
  @usableFromInline var recycleHead: _NodePtr
  @usableFromInline var freshPoolCapacity: Int = 0
  @usableFromInline var freshBucketCurrent: BucketHelper?
  @usableFromInline var freshPoolUsedCount: Int = 0
  @usableFromInline var freshBucketHead: _BucketPointer?
  @usableFromInline var freshBucketLast: _BucketPointer?
  @usableFromInline let nullptr: _NodePtr
  @usableFromInline var begin_ptr: _NodePtr
  @usableFromInline var root_ptr: _NodeRef
  @usableFromInline
  var freshBucketAllocator: _UnsafeNodeFreshBucketAllocator
  #if DEBUG
    @usableFromInline var freshBucketCount: Int = 0
  #endif
  
  @inlinable
  var memoryLayout: (stride: Int, alignment: Int) {
    freshBucketAllocator._value
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

  @usableFromInline var _deallocator: Deallocator?

  @inlinable
  var needsDealloc: Bool {
    _deallocator == nil
  }

  @inlinable
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
    mutating func createDeallocator() {
      _ = deallocator
    }
  #endif

  #if AC_COLLECTIONS_INTERNAL_CHECKS
    /// CoWの発火回数を観察するためのプロパティ
    @usableFromInline internal var copyCount: UInt = 0
  #endif

  @inlinable
  internal mutating func deinitialize() {
    ___flushFreshPool()
    ___flushRecyclePool()
    begin_ptr = end_ptr
    end_ptr.pointee.__left_ = nullptr
  }
}

#if false
extension UnsafeTreeV2BufferHeader: _UnsafeNodeFreshPoolV3 {}
#else
/* ------------ V3のインライン化はじまり  -------------  */

extension UnsafeTreeV2BufferHeader {
  public typealias _Bucket = _UnsafeNodeFreshBucket
  public typealias _BucketPointer = UnsafeMutablePointer<_UnsafeNodeFreshBucket>
}

extension UnsafeTreeV2BufferHeader {

  /*
   NOTE:
   Normally, FreshPool may grow by adding multiple buckets.
   However, immediately after CoW, callers MUST ensure that
   only a single bucket exists to support index-based access.
   */

  @inlinable
  mutating func pushFreshHeadBucket(capacity: Int) {
    assert(freshBucketHead == nil || capacity != 0)
    let (pointer, capacity) = freshBucketAllocator.createHeadBucket(
      capacity: capacity, nullptr: nullptr)
    freshBucketHead = pointer
    freshBucketCurrent = pointer.helper(_value: memoryLayout)
    freshBucketLast = pointer
    freshPoolCapacity += capacity
    #if DEBUG
      freshBucketCount += 1
    #endif
  }
  
  @inlinable
  mutating func pushFresBucket(head: _BucketPointer) {
    freshBucketHead = head
    freshBucketCurrent = head.helper(_value: memoryLayout)
    freshBucketLast = head
    freshPoolCapacity += head.pointee.capacity
    #if DEBUG
      freshBucketCount += 1
    #endif
  }

  @inlinable
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
  mutating func popFresh() -> _NodePtr? {
    if let p = freshBucketCurrent?.pop() {
      return p
    }
    freshBucketCurrent = freshBucketCurrent?.nextHelper(_value: memoryLayout)
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
  subscript(___node_id_: Int) -> _NodePtr {
    assert(___node_id_ >= 0)
    var remaining = ___node_id_
    var p = freshBucketHead?.helper(_value: memoryLayout)
    while let h = p {
      let cap = h.capacity
      if remaining < cap {
        return h[remaining]
      }
      remaining -= cap
      p = h.nextHelper(_value: memoryLayout)
    }
    return nullptr
  }
}

extension UnsafeTreeV2BufferHeader {

  @inlinable
  mutating func ___flushFreshPool() {
    freshBucketAllocator.deinitialize(bucket: freshBucketHead)
    freshPoolUsedCount = 0
    freshBucketCurrent = freshBucketHead?.helper(_value: memoryLayout)
  }

  @inlinable
  mutating func ___deallocFreshPool() {
    freshBucketAllocator.deallocate(bucket: freshBucketHead)
  }
}

extension UnsafeTreeV2BufferHeader {
  @inlinable
  func makeFreshBucketIterator<T>() -> _UnsafeNodeFreshBucketIterator<T> {
    return _UnsafeNodeFreshBucketIterator<T>(bucket: freshBucketHead)
  }
}

extension UnsafeTreeV2BufferHeader {

  @usableFromInline typealias Iterator = _UnsafeNodeFreshPoolIterator

  @inlinable
  func makeFreshPoolIterator<T>() -> _UnsafeNodeFreshPoolIterator<T> {
    return _UnsafeNodeFreshPoolIterator<T>(bucket: freshBucketHead, nullptr: nullptr)
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

#endif

extension UnsafeTreeV2BufferHeader {

  // TODO: いろいろ試すための壁で、いまは余り意味が無いのでタイミングでインライン化する
  // Headerに移すのが妥当かも。そうすれば_Value依存が消せる
  @inlinable
  mutating public
    func ___popFresh() -> _NodePtr
  {
    assert(freshPoolUsedCount < freshPoolCapacity)
    guard let p = popFresh() else {
      return nullptr
    }
    assert(p.pointee.___node_id_ == .debug)
    p.initialize(to: nullptr.create(id: freshPoolUsedCount))
    freshPoolUsedCount += 1
    count += 1
    return p
  }
}


extension UnsafeTreeV2BufferHeader {

  @inlinable
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
