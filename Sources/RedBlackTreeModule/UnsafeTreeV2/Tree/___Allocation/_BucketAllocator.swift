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
// ## special node on Primari Bucket
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
// Inspired by the TrailingArray technique from Swift Collections.
//
@frozen
@usableFromInline
struct _BucketAllocator {
  
  static func create() -> Self {
    .init(valueType: Void.self, deinitialize: { _ in })
  }

  @inlinable
  @inline(__always)
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
//  @inline(__always)
  func deinitializeEndNode(_ b: _BucketPointer) {
    UnsafeMutableRawPointer(b.advanced(by: 1))
      .assumingMemoryBound(to: UnsafeNode.self)
      .deinitialize(count: 1)
  }

  @inlinable
//  @inline(__always)
  func deinitializeNodeAndValues(isHead: Bool, _ b: _BucketPointer) {
    var it = b._counts(isHead: isHead, memoryLayout: _value)
    while let p = it.pop() {
      if p.pointee.___needs_deinitialize {
        deinitialize(p.advanced(by: 1))
      } else {
        p.deinitialize(count: 1)
      }
    }
    #if DEBUG
      do {
        var it = b._capacities(isHead: isHead, memoryLayout: _value)
        while let p = it.pop() {
          p.pointee.___node_id_ = .debug
        }
      }
    #endif
  }

  @inlinable
//  @inline(__always)
  func deallocHeadBucket(_ b: _BucketPointer) {
    deinitializeEndNode(b)
    deinitializeNodeAndValues(isHead: true, b)
    b.deinitialize(count: 1)
    UnsafeMutableRawPointer(b)._deallocate()
  }

  @inlinable
//  @inline(__always)
  func deallocBucket(_ b: _BucketPointer) {
    deinitializeNodeAndValues(isHead: false, b)
    b.deinitialize(count: 1)
    UnsafeMutableRawPointer(b)._deallocate()
  }

  @inlinable
//  @inline(__always)
  public func deinitialize(bucket b: _BucketPointer?) {
    var reserverHead = b
    var isHead = true
    while let h = reserverHead {
      reserverHead = h.pointee.next
      deinitializeNodeAndValues(isHead: isHead,h)
      h.pointee.count = 0
      isHead = false
    }
  }

  @inlinable
//  @inline(__always)
  public func deallocate(bucket b: _BucketPointer?) {
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

//  @inlinable
//  @inline(__always)
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

    let (capacity, bytes, _, alignment) = pagedCapacity(capacity: capacity)

    let header_storage = UnsafeMutableRawPointer._allocate(
      byteCount: bytes + MemoryLayout<UnsafeNode>.stride,
      alignment: alignment)

    let header = UnsafeMutableRawPointer(header_storage)
      .assumingMemoryBound(to: _UnsafeNodeFreshBucket.self)

    let endNode = UnsafeMutableRawPointer(header.advanced(by: 1))
      .bindMemory(to: UnsafeNode.self, capacity: 1)

    endNode.initialize(to: .create(id: .end))
    header.initialize(to: .init(capacity: capacity))

    #if DEBUG
      do {
        var it = header._capacities(isHead: true, memoryLayout: _value)
        while let p = it.pop() {
          p.pointee.___node_id_ = .debug
        }
      }
    #endif

    return (header, capacity)
  }

  @inlinable
  @inline(__always)
  public func createBucket(capacity: Int) -> (_BucketPointer, capacity: Int) {

    assert(capacity != 0)

    let (capacity, bytes, _, alignment) = pagedCapacity(capacity: capacity)

    let header_storage = UnsafeMutableRawPointer._allocate(
      byteCount: bytes,
      alignment: alignment)

    let header = UnsafeMutableRawPointer(header_storage)
      .assumingMemoryBound(to: _UnsafeNodeFreshBucket.self)
    
    header.initialize(to: .init(capacity: capacity))

    #if DEBUG
      do {
        var it = header._capacities(isHead: false, memoryLayout: _value)
        while let p = it.pop() {
          p.pointee.___node_id_ = .debug
        }
      }
    #endif

    return (header, capacity)
  }

//  @inlinable
//  @inline(__always)
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

//  @inlinable
//  @inline(__always)
  func end(from head: _BucketPointer) -> _NodePtr {
    UnsafeMutableRawPointer(head.advanced(by: 1))
      .assumingMemoryBound(to: UnsafeNode.self)
  }

  @usableFromInline
//  @inlinable
//  @inline(never)
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
