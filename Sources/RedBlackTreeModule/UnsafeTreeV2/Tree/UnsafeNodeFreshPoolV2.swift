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
  var _freshPoolCapacity: Int? { get set }
}

extension UnsafeNodeFreshPoolV2 {
  @usableFromInline
  var freshPoolCapacity: Int {
    get { _freshPoolCapacity ?? freshPool.capacity }
    set { _freshPoolCapacity = newValue }
  }

  @usableFromInline
  var freshPoolUsedCount: Int {
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

  @usableFromInline
  subscript(___node_id_: Int) -> _NodePtr {
    assert(freshPool[___node_id_] != nil)
    return freshPool[___node_id_]
  }

  @usableFromInline
  mutating func pushFreshBucket(capacity: Int) {
    assert(capacity > 0)
    freshPool.reserveCapacity(minimumCapacity: freshPool.capacity + capacity)
  }

  @usableFromInline
  mutating func popFresh() -> _NodePtr? {
    defer { freshPool.used += 1 }
    return self[freshPool.used]
  }

  @usableFromInline
  mutating func ___popFresh() -> _NodePtr {
    let p = self[freshPool.used]
    assert(p != nil)
    assert(p.pointee.___node_id_ == .nullptr)
    p.initialize(to: UnsafeNode(___node_id_: freshPoolUsedCount))
    assert(p.pointee.__left_ != nil)
    assert(p.pointee.__right_ != nil)
    assert(p.pointee.__parent_ != nil)
    freshPool.used += 1
    count += 1
    return p
  }

  @usableFromInline
  mutating func ___flushFreshPool() {
    freshPool.dispose()
    count = 0
  }

  @usableFromInline
  mutating func ___cleanFreshPool() {
    freshPool.removeAllKeepingCapacity()
    _freshPoolCapacity = nil
  }
}

extension UnsafeNodeFreshPoolV2 {

  @inlinable
  @inline(__always)
  func makeFreshPoolIterator() -> UnsafeNodeFreshPoolV2Iterator<_Value> {
    return UnsafeNodeFreshPoolV2Iterator<_Value>(
      elements: freshPool.array, count: freshPool.used)
  }
}
