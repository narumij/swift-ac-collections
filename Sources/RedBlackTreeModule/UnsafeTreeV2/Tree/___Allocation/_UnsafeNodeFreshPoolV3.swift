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

// TODO: V2のアイデアをV3と同じ方式で再度試す

// NOTE: 性能過敏なので修正する場合は必ず計測しながら行うこと
@usableFromInline
protocol _UnsafeNodeFreshPoolV3: _ValueProtocol
where _NodePtr == UnsafeMutablePointer<UnsafeNode> {

  /*
   Design invariant:
   - FreshPool may consist of multiple buckets in general.
   - Immediately after CoW, the pool must be constrained to a single bucket
   because index-based access is performed.
   */

  associatedtype _NodePtr
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
}

extension _UnsafeNodeFreshPoolV3 {
  public typealias _Bucket = _UnsafeNodeFreshBucket
  public typealias _BucketPointer = UnsafeMutablePointer<_Bucket>
}

//#if USE_FRESH_POOL_V1
#if !USE_FRESH_POOL_V2
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
    mutating func pushFreshBucket(capacity: Int) {
      assert(freshBucketHead == nil || capacity != 0)
      let (pointer, capacity) = Self.createBucket(capacity: capacity, nullptr: nullptr)
      if freshBucketHead == nil {
        freshBucketHead = pointer
        didUpdateFreshBucketHead()
      }
      if freshBucketCurrent == nil {
        freshBucketCurrent = pointer
      }
      if let freshBucketLast {
        freshBucketLast.pointee.next = pointer
      }
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

    @inlinable
    @inline(__always)
    mutating func ___cleanFreshPool() {
      var reserverHead = freshBucketHead
      while let h = reserverHead {
        h.pointee.clear(_Value.self)
        reserverHead = h.pointee.next
      }
      freshPoolUsedCount = 0
      freshBucketCurrent = freshBucketHead
    }

    @inlinable
    @inline(__always)
    mutating func ___flushFreshPool() {
      ___deallocFreshPool()
      freshBucketHead = nil
      freshBucketCurrent = nil
      freshBucketLast = nil
      #if DEBUG
        freshBucketCount = 0
      #endif
      freshPoolCapacity = 0
      freshPoolUsedCount = 0
    }

    @inlinable
    @inline(__always)
    mutating func ___deallocFreshPool() {
      var reserverHead = freshBucketHead
      while let h = reserverHead {
        reserverHead = h.pointee.next
        Self.deinitializeNodes(h)
        h.deinitialize(count: 1)
        h.deallocate()
      }
    }
  }

  extension _UnsafeNodeFreshPoolV3 {

    @inlinable
    @inline(__always)
    func makeFreshPoolIterator() -> _UnsafeNodeFreshPoolIterator<_Value> {
      return _UnsafeNodeFreshPoolIterator<_Value>(bucket: freshBucketHead, nullptr: nullptr)
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

    // TODO: いろいろ試すための壁で、いまは余り意味が無いのでタイミングでインライン化する
    @inlinable
    @inline(__always)
    mutating public
      func ___popFresh() -> _NodePtr
    {
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
    static func deinitializeNodes(_ p: _BucketPointer) {
      let bucket = p.pointee
      var i = 0
      let count = bucket.count
      let capacity = bucket.capacity
      var p = bucket.start
      while i < capacity {
        let c = p
        p = UnsafePair<_Value>.advance(p)
        if i < count, c.pointee.___needs_deinitialize {
          UnsafePair<_Value>.deinitialize(c)
        } else {
          c.deinitialize(count: 1)
        }
        i += 1
      }
      #if DEBUG
        do {
          var c = 0
          var p = bucket.start
          while c < bucket.capacity {
            p.pointee.___node_id_ = .debug
            p = UnsafePair<_Value>.advance(p)
            c += 1
          }
        }
      #endif
    }

    @inlinable
    @inline(__always)
    static func createBucket(capacity: Int, nullptr: _NodePtr) -> (_BucketPointer, capacity: Int) {

#if USE_FRESH_POOL_V1 || USE_FRESH_POOL_V2
      assert(capacity != 0)
#endif

      let (capacity, bytes, stride, alignment) = pagedCapacity(capacity: capacity)

      let header_storage = UnsafeMutableRawPointer.allocate(
        byteCount: bytes + MemoryLayout<UnsafeNode>.stride,
        alignment: alignment)

      let header = UnsafeMutableRawPointer(header_storage)
        .assumingMemoryBound(to: _UnsafeNodeFreshBucket.self)
      
      // x競プロ用としては、分岐して節約するよりこの程度なら分岐けずるほうがいいかもしれない
      // o甘くなかった。いまの成長率設定ではメモリの無駄が多すぎる
      let endNode = UnsafeMutableRawPointer(header.advanced(by: 1))
        .bindMemory(to: UnsafeNode.self, capacity: 1)
      
      endNode.initialize(to: nullptr.create(id: .end))

      let storage = UnsafeMutableRawPointer(header.advanced(by: 1))
        .advanced(by: MemoryLayout<UnsafeNode>.stride)
      //      .alignedUp(toMultipleOf: alignment)

      header.initialize(
        to:
          .init(
            start: UnsafePair<_Value>.pointer(from: storage),
            capacity: capacity,
            strice: stride))

      #if DEBUG
        do {
          var c = 0
          var p = header.pointee.start
          while c < capacity {
            p.pointee.___node_id_ = .debug
            p = UnsafePair<_Value>.advance(p)
            c += 1
          }
        }
      #endif

      return (header, capacity)
    }
  }

  extension _UnsafeNodeFreshPoolV3 {

    @inlinable
    @inline(__always)
    //  @usableFromInline
    static func pagedCapacity(capacity: Int) -> (
      capacity: Int, bytes: Int, stride: Int, alignment: Int
    ) {

      let s0 = MemoryLayout<UnsafeNode>.stride
      let a0 = MemoryLayout<UnsafeNode>.alignment
      let s1 = MemoryLayout<_Value>.stride
      let a1 = MemoryLayout<_Value>.alignment
      let s2 = MemoryLayout<_UnsafeNodeFreshBucket>.stride
      let s01 = s0 + s1
      let offset01 = max(0, a1 - a0)
      let size = s2 + (capacity == 0 ? 0 : s01 * capacity + offset01)
      let alignment = max(a0, a1)

      /*
       512B未満はスルーに
       中間は要研究
       4KB以上は分割確保に
       */

      #if false
        // 1024B以下はsmall扱い。それ以上はページ扱い
        if size <= 1024 {
          return (capacity, size, s01, alignment)
        }
      #endif

      #if false
        // 割り算が重すぎと判断した場合、2のべきで近似して割り算代わりにシフトする
        // それよりもメモリ効率の方が問題のような気がしている
        let pagedSize = (size + 4095) & ~4095
        let lz = Int.bitWidth - s01.leadingZeroBitCount
        let mask = 1 << (lz - 1) - 1
        let offset = (s01 & mask == 0) ? -1 : 0
        let extra = (pagedSize - size) >> (lz + offset)

        assert(abs(size / 4096 - pagedSize / 4096) <= 1)
        return (
          capacity + extra,
          //      capacity,
          pagedSize,
          s01,
          alignment
        )
      #elseif false
        // 割り算バージョン
        // 性能上重要なので数値ベタ書き推奨かもしれない
        let pagedSize = (size + 4095) & ~4095
        assert(abs(size / 4096 - pagedSize / 4096) <= 1)
        return (
          capacity + (pagedSize - size) / (s01),
          //      capacity,
          pagedSize,
          s01,
          alignment
        )
      #else
        // キャパシティ変更しないバージョン
        return (capacity, size, s01, alignment)
      #endif
    }
  }

  // MARK: - 作業用サイズ計算

  #if DEBUG
    extension _UnsafeNodeFreshPoolV3 {

      @inlinable
      @inline(__always)
      static func allocationSize(capacity: Int) -> (size: Int, alignment: Int) {
        let (bufferSize, bufferAlignment) = UnsafePair<_Value>.allocationSize(capacity: capacity)
        return (bufferSize + MemoryLayout<_Bucket>.stride, bufferAlignment)
      }
    }

    extension _UnsafeNodeFreshPoolV3 {

      @inlinable
      @inline(__always)
      static func _allocationSize2(capacity: Int) -> (size: Int, alignment: Int) {
        let a0 = MemoryLayout<UnsafeNode>.alignment
        let a1 = MemoryLayout<_Value>.alignment
        let s0 = MemoryLayout<UnsafeNode>.stride
        let s1 = MemoryLayout<_Value>.stride
        let s01 = s0 + s1
        let offset01 = max(0, a1 - a0)
        return (capacity == 0 ? 0 : s01 * capacity + offset01, max(a0, a1))
      }
    }

    extension _UnsafeNodeFreshPoolV3 {

      @inlinable
      @inline(__always)
      static func allocationSize2(capacity: Int) -> (size: Int, alignment: Int) {
        let s0 = MemoryLayout<UnsafeNode>.stride
        let a0 = MemoryLayout<UnsafeNode>.alignment
        let s1 = MemoryLayout<_Value>.stride
        let a1 = MemoryLayout<_Value>.alignment
        let s2 = MemoryLayout<_UnsafeNodeFreshBucket>.stride
        let a2 = MemoryLayout<_UnsafeNodeFreshBucket>.alignment
        let s01 = s0 + s1
        let offset01 = max(0, a1 - a0)
        return (s2 + (capacity == 0 ? 0 : s01 * capacity + offset01), max(a0, a1))
      }
    }
  #endif

  // MARK: - DEBUG

  #if DEBUG
    extension _UnsafeNodeFreshPoolV3 {

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
#endif

#if DEBUG
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
