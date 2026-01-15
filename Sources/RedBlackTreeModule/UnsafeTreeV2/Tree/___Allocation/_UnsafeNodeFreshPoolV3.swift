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
protocol _UnsafeNodeFreshPoolV3: _ValueProtocol, UnsafeTreePointer {

  /*
   Design invariant:
   - FreshPool may consist of multiple buckets in general.
   - Immediately after CoW, the pool must be constrained to a single bucket
   because index-based access is performed.
   */

  var freshBucketHead: _BucketPointer? { get set }
  var freshBucketCurrent: _BucketPointer? { get set }
  var freshBucketLast: _BucketPointer? { get set }
  var freshPoolCapacity: Int { get set }
  var freshPoolUsedCount: Int { get set }
  var count: Int { get set }
  var nullptr: _NodePtr { get }
  #if DEBUG
    var freshBucketCount: Int { get set }
  #endif
  func didUpdateFreshBucketHead()
  var freshBucketAllocator: _UnsafeNodeFreshBucketAllocator { get }
}

extension _UnsafeNodeFreshPoolV3 {
  public typealias _Bucket = _UnsafeNodeFreshBucket
  public typealias _BucketPointer = UnsafeMutablePointer<_UnsafeNodeFreshBucket>
}

extension _UnsafeNodeFreshPoolV3 {

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
    didUpdateFreshBucketHead()
    freshBucketCurrent = pointer
    freshBucketLast = pointer
    self.freshPoolCapacity += capacity
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
    self.freshPoolCapacity += capacity
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

extension _UnsafeNodeFreshPoolV3 {

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
    UnsafeNode.bindValue(_Value.self, p)
    p.initialize(to: nullptr.create(id: freshPoolUsedCount))
    freshPoolUsedCount += 1
    count += 1
    return p
  }
}

extension _UnsafeNodeFreshPoolV3 {

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

extension _UnsafeNodeFreshPoolV3 {

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

extension _UnsafeNodeFreshPoolV3 {

  @inlinable
  @inline(__always)
  func makeFreshPoolIterator() -> _UnsafeNodeFreshPoolIterator<_Value> {
    return _UnsafeNodeFreshPoolIterator<_Value>(bucket: freshBucketHead, nullptr: nullptr)
  }
}

// MARK: - 作業用サイズ計算

// MARK: - DEBUG

#if DEBUG
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
  extension _UnsafeNodeFreshPoolV3 {

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

  extension _UnsafeNodeFreshPoolV3 {

    @inlinable
    @inline(__always)
    var freshPoolNumBytes: Int {
      var bytes = 0
      var p = freshBucketHead
      while let h = p {
        bytes += h.pointee.count * (MemoryLayout<UnsafeNode>.stride + MemoryLayout<_Value>.stride)
        p = h.pointee.next
      }
      return bytes
    }
  }

  extension _UnsafeNodeFreshPoolV3 {

    @inlinable
    @inline(__always)
    func makeFreshBucketIterator() -> _UnsafeNodeFreshBucketIterator<_Value> {
      return _UnsafeNodeFreshBucketIterator<_Value>(bucket: freshBucketHead)
    }
  }
#endif
