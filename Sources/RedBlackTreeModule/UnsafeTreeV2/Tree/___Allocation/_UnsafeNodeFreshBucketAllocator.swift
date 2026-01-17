//
//  _UnsafeNodeFreshBucketDeallocator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/15.
//

// # Memory Layout
//
// ## Primary Bucket
// |Bucket|Node||Node|Value|Node|Value|...
//              ^--start
// ^-- head
//
// ## Secondary and other Buckets
// |Bucket||Node|Value|Node|Value|...
//         ^--start
// ^-- next
//
// ## special node
// |Bucket|Node||Node|Value|Node|Value|...
//          ^-- end node (end->left == root)
//
// ## memory layout gap
// |Bucket||Node|Value|Node|Value|...
//        ^^-- bucket has alignment gap
//
//
// ## Initial Capacity 0
// |Bucket|Node|
//
// ## Resever Capacity to 1
// |Bucket|Node|
// |Bucket||Node|Value|
//
// ## Reserve Capacity to 2
// |Bucket|Node|
// |Bucket||Node|Value|
// |Bucket||Node|Value|
//
// ## then Copy on Write occurs
// |Bucket|Node||Node|Value|Node|Value|.......
//                                    ^-- inlined
//
@usableFromInline
struct _UnsafeNodeFreshBucketAllocator {

  @inlinable
  public init<_Value>(
    valueType: _Value.Type, deinitialize: @escaping (UnsafeMutableRawPointer) -> Void
  ) {
    self._value = (MemoryLayout<_Value>.stride, MemoryLayout<_Value>.alignment)
    self.nodeValueStride = MemoryLayout<UnsafeNode>.stride + MemoryLayout<_Value>.stride
    self.deinitialize = deinitialize
  }

  public typealias _BucketPointer = UnsafeMutablePointer<_UnsafeNodeFreshBucket>
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

  @usableFromInline
  let _value: (stride: Int, alignment: Int)

  @usableFromInline
  let nodeValueStride: Int

  @usableFromInline
  let deinitialize: (UnsafeMutableRawPointer) -> Void

  @inlinable
  @inline(__always)
  func deinitializeEndNode(_ b: _BucketPointer) {
    UnsafeMutableRawPointer(b.advanced(by: 1))
      .assumingMemoryBound(to: UnsafeNode.self)
      .deinitialize(count: 1)
  }

  @inlinable
  @inline(__always)
  func deinitializeNodeAndValues(_ b: _BucketPointer) {
    let bucket = b.pointee
    var i = 0
    let count = bucket.count
    var p = bucket.start
    while i < count {
      let c = p
      p = advance(p)
      if i < count, c.pointee.___needs_deinitialize {
        deinitialize(c.advanced(by: 1))
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
          p = advance(p)
          c += 1
        }
      }
    #endif
  }

  @inlinable
  @inline(__always)
  func deallocHeadBucket(_ b: _BucketPointer) {
    deinitializeEndNode(b)
    deinitializeNodeAndValues(b)
    b.deinitialize(count: 1)
    UnsafeMutableRawPointer(b)._deallocate()
  }

  @inlinable
  @inline(__always)
  func deallocBucket(_ b: _BucketPointer) {
    deinitializeNodeAndValues(b)
    b.deinitialize(count: 1)
    UnsafeMutableRawPointer(b)._deallocate()
  }

  @inlinable
  @inline(__always)
  public func deinitialize(_ b: _BucketPointer?) {
    var reserverHead = b
    while let h = reserverHead {
      reserverHead = h.pointee.next
      deinitializeNodeAndValues(h)
      h.pointee.count = 0
    }
  }

  @inlinable
  @inline(__always)
  public func deallocate(_ b: _BucketPointer?) {
    var reserverHead = b
    while let h = reserverHead {
      reserverHead = h.pointee.next
      if h == b {
        deallocHeadBucket(h)
      } else {
        deallocBucket(h)
      }
    }
  }

  @inlinable
  @inline(__always)
  func advance(_ p: _NodePtr, _ n: Int = 1) -> _NodePtr {
    UnsafeMutableRawPointer(p)
      .advanced(by: nodeValueStride * n)
      .assumingMemoryBound(to: UnsafeNode.self)
  }

  @inlinable
  @inline(__always)
  public func createHeadBucket(capacity: Int, nullptr: _NodePtr) -> (
    _BucketPointer, capacity: Int
  ) {

    let (capacity, bytes, stride, alignment) = pagedCapacity(capacity: capacity)

    let header_storage = UnsafeMutableRawPointer._allocate(
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
          start: pointer(from: storage),
          capacity: capacity,
          strice: stride))

    #if DEBUG
      do {
        var c = 0
        var p = header.pointee.start
        while c < capacity {
          p.pointee.___node_id_ = .debug
          p = advance(p)
          c += 1
        }
      }
    #endif

    return (header, capacity)
  }

  @inlinable
  @inline(__always)
  public func createBucket(capacity: Int) -> (_BucketPointer, capacity: Int) {

    assert(capacity != 0)

    let (capacity, bytes, stride, alignment) = pagedCapacity(capacity: capacity)

    let header_storage = UnsafeMutableRawPointer._allocate(
      byteCount: bytes,
      alignment: alignment)

    let header = UnsafeMutableRawPointer(header_storage)
      .assumingMemoryBound(to: _UnsafeNodeFreshBucket.self)

    let storage = UnsafeMutableRawPointer(header.advanced(by: 1))

    header.initialize(
      to:
        .init(
          start: pointer(from: storage),
          capacity: capacity,
          strice: stride))

    #if DEBUG
      do {
        var c = 0
        var p = header.pointee.start
        while c < capacity {
          p.pointee.___node_id_ = .debug
          p = advance(p)
          c += 1
        }
      }
    #endif

    return (header, capacity)
  }

  @inlinable
  @inline(__always)
  func pointer(from storage: UnsafeMutableRawPointer) -> _NodePtr {
    let headerAlignment = MemoryLayout<UnsafeNode>.alignment
    let elementAlignment = _value.alignment

    if elementAlignment <= headerAlignment {
      return storage.assumingMemoryBound(to: UnsafeNode.self)
    }

    return storage.advanced(by: MemoryLayout<UnsafeNode>.stride)
      .alignedUp(toMultipleOf: _value.alignment)
      .advanced(by: -MemoryLayout<UnsafeNode>.stride)
      .assumingMemoryBound(to: UnsafeNode.self)
  }

  @inlinable
  @inline(__always)
  func end(from head: _BucketPointer) -> _NodePtr {
    UnsafeMutableRawPointer(head.advanced(by: 1))
      .assumingMemoryBound(to: UnsafeNode.self)
  }

  @inlinable
  @inline(__always)
  func pagedCapacity(capacity: Int) -> (
    capacity: Int, bytes: Int, stride: Int, alignment: Int
  ) {

    let s0 = MemoryLayout<UnsafeNode>.stride
    let a0 = MemoryLayout<UnsafeNode>.alignment
    let s1 = _value.stride
    let a1 = _value.alignment
    let s2 = MemoryLayout<_UnsafeNodeFreshBucket>.stride
    let s01 = s0 + s1
    let offset01 = max(0, a1 - a0)
    let size = s2 + (capacity == 0 ? 0 : s01 * capacity + offset01)
    let alignment = max(a0, a1)

    return (capacity, size, s01, alignment)
  }
}
