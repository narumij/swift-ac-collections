//
//  UnsafeNodeFreshPoolV2.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/08.
//

// NOTE: 性能過敏なので修正する場合は必ず計測しながら行うこと
@usableFromInline
protocol UnsafeNodeFreshPoolV2 where _NodePtr == UnsafeMutablePointer<UnsafeNode> {

  associatedtype _Value
  associatedtype _NodePtr
  var freshPool: FreshPool<_Value> { get set }
  var count: Int { get set }
  var nullptr: _NodePtr { get }
}

extension UnsafeNodeFreshPoolV2 {
  
  @inlinable
  var freshPoolCapacity: Int {
    @inline(__always)
    get { freshPool.capacity }
    set { fatalError() }
  }

  @inlinable
  var freshPoolUsedCount: Int {
    @inline(__always)
    get { freshPool.used }
    set {
      #if DEBUG
        freshPool.used = newValue
      #endif
    }
  }

  @usableFromInline
  var freshPoolActualCount: Int {
    freshPool.used
  }

  #if DEBUG
    @usableFromInline
    var freshBucketCount: Int { -1 }
  #endif

  @inlinable
  @inline(__always)
  subscript(___node_id_: Int) -> _NodePtr {
    return freshPool[___node_id_]
  }

  @inlinable
  @inline(__always)
  mutating func pushFreshBucket(capacity: Int) {
    assert(capacity > 0)
    freshPool.reserveCapacity(minimumCapacity: freshPool.capacity + capacity)
  }

  @inlinable
  @inline(__always)
  mutating func popFresh() -> _NodePtr? {
    freshPool._popFresh(nullptr: nullptr)
  }

  @inlinable
  @inline(__always)
  mutating func ___popFresh() -> _NodePtr {
    let p = freshPool._popFresh(nullptr: nullptr)
    count += 1
    return p
  }

  @inlinable
  @inline(__always)
  mutating func ___deinitFreshPool() {
    freshPool.dispose()
//    count = 0
  }

  @inlinable
  @inline(__always)
  mutating func ___cleanFreshPool() {
    freshPool.removeAllKeepingCapacity()
  }
}

extension UnsafeNodeFreshPoolV2 {

  @inlinable
  @inline(__always)
  func makeFreshPoolIterator() -> UnsafeNodeFreshPoolV2Iterator<_Value> {
    return UnsafeNodeFreshPoolV2Iterator<_Value>(
      elements: freshPool.pointers, count: freshPool.used)
  }
}
