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

// NOTE: 性能過敏なので修正する場合は必ず計測しながら行うこと
@usableFromInline
protocol UnsafeNodeFreshPool where _NodePtr == UnsafeMutablePointer<UnsafeNode> {

  /*
   Design invariant:
   - FreshPool may consist of multiple buckets in general.
   - Immediately after CoW, the pool must be constrained to a single bucket
     because index-based access is performed.
  */

  associatedtype _Value
  associatedtype _NodePtr
  var freshBucketHead: ReserverHeaderPointer? { get set }
  var freshBucketCurrent: ReserverHeaderPointer? { get set }
  var freshBucketLast: ReserverHeaderPointer? { get set }
  var freshBucketCount: Int { get set }
  var freshPoolCapacity: Int { get set }
}

extension UnsafeNodeFreshPool {
  public typealias ReserverHeader = UnsafeNodeFreshBucket
  public typealias ReserverHeaderPointer = UnsafeMutablePointer<ReserverHeader>
}

extension UnsafeNodeFreshPool {

  @inlinable
  @inline(__always)
  var nullptr: UnsafeMutablePointer<UnsafeNode> {
    UnsafeNode.nullptr
  }
  
  /*
   NOTE:
   Normally, FreshPool may grow by adding multiple buckets.
   However, immediately after CoW, callers MUST ensure that
   only a single bucket exists to support index-based access.
   */
  @inlinable
  @inline(__always)
  mutating func pushFreshBucket(capacity: Int) {
    assert(capacity != 0)
    let pointer = Self.createBucket(capacity: capacity)
    if freshBucketHead == nil {
      freshBucketHead = pointer
    }
    if freshBucketCurrent == nil {
      freshBucketCurrent = pointer
    }
    if let freshBucketLast {
      freshBucketLast.pointee.next = pointer
    }
    freshBucketLast = pointer
    self.freshPoolCapacity += capacity
    freshBucketCount += 1
  }

  @inlinable
  @inline(__always)
  mutating func popFresh() -> _NodePtr? {
    if let p = freshBucketCurrent?.pointee.pop() {
      return p
    }
    nextBucket()
    return freshBucketCurrent?.pointee.pop()
  }

  @inlinable
  @inline(__always)
  mutating func nextBucket() {
    freshBucketCurrent = freshBucketCurrent?.pointee.next
  }

  @inlinable
  @inline(__always)
  func ___clearFresh() {
    var reserverHead = freshBucketHead
    while let h = reserverHead {
      h.pointee.clear(_Value.self)
      reserverHead = h.pointee.next
    }
  }

  @inlinable
  @inline(__always)
  func ___disposeFreshPool() {
    var reserverHead = freshBucketHead
    while let h = reserverHead {
      reserverHead = h.pointee.next
      Self.deinitializeNodes(h)
      h.deinitialize(count: 1)
      UnsafeRawPointer(h).deallocate()
    }
  }
}

extension UnsafeNodeFreshPool {

  @inlinable
  @inline(__always)
  func makeInitializedIterator() -> UnsafeInitializedNodeIterator<_Value> {
    return UnsafeInitializedNodeIterator<_Value>(bucket: freshBucketHead)
  }
}

extension UnsafeNodeFreshPool {

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


extension UnsafeNodeFreshPool {

  // TODO: いろいろ試すための壁で、いまは余り意味が無いのでタイミングでインライン化する
  @inlinable
  @inline(__always)
  mutating public
    func ___node_alloc() -> _NodePtr
  {
    let p = popFresh()
    assert(p != nil)
    assert(p?.pointee.___node_id_ == -2)
    return p ?? nullptr
  }
}

extension UnsafeNodeFreshPool {

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

#if DEBUG
  extension UnsafeNodeFreshPool {

    func dumpFreshPool(label: String = "") {
      print("==== FreshPool \(label) ====")
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
