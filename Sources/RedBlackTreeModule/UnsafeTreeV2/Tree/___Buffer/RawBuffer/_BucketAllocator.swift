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
package struct _BucketAllocator {

  static func create() -> Self {
    .init(valueType: Void.self, deinitialize: { _ in })
  }

  @inlinable
  @inline(__always)
  public init<_Value>(
    valueType: _Value.Type, deinitialize: @escaping (UnsafeMutableRawPointer) -> Void
  ) {
    self.memoryLayout = MemoryLayout<_Value>._memoryLayout
    self._pair = .init(UnsafeNode.self, _Value.self)
    self.deinitialize = deinitialize
  }

  public typealias _BucketPointer = UnsafeMutablePointer<_Bucket>
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

  @usableFromInline
  let memoryLayout: _MemoryLayout

  @usableFromInline
  package let _pair: _MemoryLayout

  @usableFromInline
  let deinitialize: (UnsafeMutableRawPointer) -> Void

  @inlinable
  func deinitializeEndNode(_ b: _BucketPointer) {
    UnsafeMutableRawPointer(b.advanced(by: 1))
      .assumingMemoryBound(to: UnsafeNode.self)
      .deinitialize(count: 1)
  }

  @inlinable
  func deinitializeNodeAndValues(isHead: Bool, _ b: _BucketPointer) {
    var it = b._counts(isHead: isHead, memoryLayout: memoryLayout)
    while let p = it.pop() {
      if p.pointee.___needs_deinitialize {
        deinitialize(p.advanced(by: 1))
      } else {
        p.deinitialize(count: 1)
      }
    }
    #if DEBUG
      do {
        var it = b._capacities(isHead: isHead, memoryLayout: memoryLayout)
        while let p = it.pop() {
          p.pointee.___node_id_ = .debug
        }
      }
    #endif
  }

  @inlinable
  func deallocHeadBucket(_ b: _BucketPointer) {
    deinitializeEndNode(b)
    deinitializeNodeAndValues(isHead: true, b)
    b.deinitialize(count: 1)
    UnsafeMutableRawPointer(b)._deallocate()
  }

  @inlinable
  func deallocBucket(_ b: _BucketPointer) {
    deinitializeNodeAndValues(isHead: false, b)
    b.deinitialize(count: 1)
    UnsafeMutableRawPointer(b)._deallocate()
  }

  @inlinable
  public func deinitialize(bucket b: _BucketPointer?) {
    var reserverHead = b
    var isHead = true
    while let h = reserverHead {
      reserverHead = h.pointee.next
      deinitializeNodeAndValues(isHead: isHead, h)
      h.pointee.count = 0
      isHead = false
    }
  }

  @inlinable
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

  @inlinable
  @inline(__always)
  public func createHeadBucket(capacity: Int, nullptr: _NodePtr) -> (
    _BucketPointer, capacity: Int
  ) {

    let (bytes, alignment) = otherCapacity(capacity: capacity)

    let header_storage = UnsafeMutableRawPointer._allocate(
      byteCount: bytes + MemoryLayout<UnsafeNode>.stride,
      alignment: alignment)

    let header = UnsafeMutableRawPointer(header_storage)
      .assumingMemoryBound(to: _Bucket.self)

    let endNode = UnsafeMutableRawPointer(header.advanced(by: 1))
      .bindMemory(to: UnsafeNode.self, capacity: 1)

    endNode.initialize(to: .create(id: .end))
    header.initialize(to: .init(capacity: capacity))

    #if DEBUG
      do {
        var it = header._capacities(isHead: true, memoryLayout: memoryLayout)
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

    let (bytes, alignment) = otherCapacity(capacity: capacity)

    let header_storage = UnsafeMutableRawPointer._allocate(
      byteCount: bytes,
      alignment: alignment)

    let header = UnsafeMutableRawPointer(header_storage)
      .assumingMemoryBound(to: _Bucket.self)

    header.initialize(to: .init(capacity: capacity))

    #if DEBUG
      do {
        var it = header._capacities(isHead: false, memoryLayout: memoryLayout)
        while let p = it.pop() {
          p.pointee.___node_id_ = .debug
        }
      }
    #endif

    return (header, capacity)
  }

  @usableFromInline
  package func otherCapacity(capacity: Int) -> (
    bytes: Int, alignment: Int
  ) {
    let a0 = MemoryLayout<UnsafeNode>.alignment
    let a1 = memoryLayout.alignment
    let s2 = MemoryLayout<_Bucket>.stride
    let s01 = _pair.stride
    let offset01 = max(0, a1 - a0)
    let size = s2 + (capacity == 0 ? 0 : s01 * capacity + offset01)
    let alignment = max(a0, a1)
    return (size, alignment)
  }
}
