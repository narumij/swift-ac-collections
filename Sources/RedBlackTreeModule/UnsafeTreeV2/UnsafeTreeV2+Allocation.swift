//@usableFromInline
//protocol UnsafeTreeAllocationHeader {
//  var initializedCount: Int { get }
//  var freshBucketCount: Int { get }
//}

@usableFromInline
protocol UnsafeTreeAllcationBodyV2 {
//  associatedtype Header: UnsafeTreeAllocationHeader
  associatedtype _Value
//  var _header: Header { get }
  var capacity: Int { get }
  var count: Int { get }
  var initializedCount: Int { get }
}

extension UnsafeTreeV2: UnsafeTreeAllcationBodyV2 {}
//extension UnsafeTree.Header: UnsafeTreeAllocationHeader {}

// TODO: 確保サイズ毎所要時間をのアロケーションとデアロケーションの両方で測ること

#if ALLOCATION_DRILL
extension UnsafeTree: UnsafeTreeAllcationDrill {}
#else
extension UnsafeTreeV2: UnsafeTreeAllcation2V2 {}
#endif

#if ALLOCATION_DRILL
extension RedBlackTreeSet {
  public mutating func pushFreshBucket(capacity: Int) {
    __tree_.header.pushFreshBucket(capacity: capacity)
  }
}
#endif

public nonisolated(unsafe) var allocationChunkSizeV2: Int = 0

@usableFromInline
protocol UnsafeTreeAllcationDrillV2: UnsafeTreeAllcationBody {}

extension UnsafeTreeAllcationDrillV2 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {
    Swift.max(minimumCapacity, freshPoolCapacity + allocationChunkSize)
  }
}

@usableFromInline
protocol UnsafeTreeAllcation2V2: UnsafeTreeAllcationBodyV2 {}

extension UnsafeTreeAllcation2V2 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        initializedCount,
        minimumCapacity)
    }

    let s0 = MemoryLayout<UnsafeNode>.stride
    let s1 = MemoryLayout<_Value>.stride
    let s2 = MemoryLayout<UnsafeNodeFreshBucket>.stride
    let a2 = 0 // MemoryLayout<UnsafeNodeFreshBucket<_Value>>.alignment

    if minimumCapacity <= 2 {
      return 3
    }

    if minimumCapacity <= 64 {
      return Swift.max(minimumCapacity, count + ((16 - 1) * (s0 + s1) - s2 - a2) / (s0 + s1))
    }

    if minimumCapacity < 4096 {
      return Swift.max(minimumCapacity, count + ((32 - 1) * (s0 + s1) - s2 - a2) / (s0 + s1))
    }

    if minimumCapacity <= 8192 {
      return Swift.max(minimumCapacity, count + ((16 - 1) * (s0 + s1) - s2 - a2) / (s0 + s1))
    }
    
    if minimumCapacity <= 100000 {
      return Swift.max(minimumCapacity, count + ((512 - 1) * (s0 + s1) - s2 - a2) / (s0 + s1))
    }
    
    return Swift.max(minimumCapacity, count + ((1024 * 2 - 1) * (s0 + s1) - s2 - a2) / (s0 + s1))
  }
}

