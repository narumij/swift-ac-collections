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

// DONE: V2のアイデアをV3と同じ方式で再度試す
// メモリ確保での時間増加よりも現状のpopのほうが時間が少ないので、V2のアイデアは試さない

// NOTE: 性能過敏なので修正する場合は必ず計測しながら行うこと
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

  var memoryLayout: _MemoryLayout { get }
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
  //  @inline(__always)
  mutating func pushFreshBucket(head: _BucketPointer) {
    freshBucketHead = head
    freshBucketCurrent = head.queue(memoryLayout: memoryLayout)
    freshBucketLast = head
    freshPoolCapacity += head.pointee.capacity
    #if DEBUG
      freshBucketCount += 1
    #endif
  }

  @inlinable
  //  @inline(__always)
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
  //  @inline(__always)
  mutating func popFresh() -> _NodePtr? {
    if let p = freshBucketCurrent?.pop() {
      return p
    }
    freshBucketCurrent = freshBucketCurrent?.next(memoryLayout: memoryLayout)
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
  @inline(__always)
  subscript(___raw_index: Int) -> _NodePtr {
    assert(___raw_index >= 0)
    var remaining = ___raw_index
    var p = freshBucketHead?.accessor(_value: memoryLayout)
    while let h = p {
      let cap = h.capacity
      if remaining < cap {
        return h[remaining]
      }
      remaining -= cap
      p = h.next(_value: memoryLayout)
    }
    return nullptr
  }
}

extension _FreshPool {

  @usableFromInline
  //  @inlinable
  //  @inline(__always)
  mutating func ___flushFreshPool() {
    freshBucketAllocator.deinitialize(bucket: freshBucketHead)
    freshPoolUsedCount = 0
    freshBucketCurrent = freshBucketHead?.queue(memoryLayout: memoryLayout)
  }

  @usableFromInline
  //  @inlinable
  //  @inline(__always)
  mutating func ___deallocFreshPool() {
    freshBucketAllocator.deallocate(bucket: freshBucketHead)
  }
}

// MARK: - 作業用サイズ計算

// MARK: - DEBUG

#if false
  extension _UnsafeNodeFreshPoolV3 {
    @inlinable
    @inline(__always)
    func makeFreshBucketIterator<T>() -> _UnsafeNodeFreshBucketIterator<T> {
      return _UnsafeNodeFreshBucketIterator<T>(bucket: freshBucketHead)
    }
  }
#endif

extension _FreshPool {

  @usableFromInline typealias PopIterator = _FreshPoolPopIterator

  @inlinable
  //  @inline(__always)
  func makeFreshPoolIterator<T>() -> _FreshPoolPopIterator<T> {
    return _FreshPoolPopIterator<T>(bucket: freshBucketHead)
  }
}

#if DEBUG && false
  extension _UnsafeNodeFreshPoolV3 {

    func dumpFreshPool(label: String = "") {
      print("==== FreshPoolV3 \(label) ====")
      print(" bucketCount:", freshBucketCount)
      print(" capacity:", freshPoolCapacity)
      print(" usedCount:", freshPoolActualCount)

      var i = 0
      var p = freshBucketHead
      while let h = p {
        h.pointee.dump(label: "bucket[\(i)]")
        p = h.pointee.next
        i += 1
      }
      print("===========================")
    }
  }
#endif

#if DEBUG
  extension _FreshPool {

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
