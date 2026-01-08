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
  @usableFromInline
  var freshPoolCapacity: Int {
    get { freshPool.capacity }
    set { fatalError() }
  }

  @usableFromInline
  var freshPoolUsedCount: Int {
    get { freshPool.used }
    set { fatalError() }
  }
  
  @usableFromInline
  var freshPoolActualCount: Int {
    fatalError()
  }

  #if DEBUG
    @usableFromInline
    var freshBucketCount: Int { -1 }
  #endif

  @usableFromInline
  subscript(___node_id_: Int) -> _NodePtr {
    fatalError()
  }

  @usableFromInline
  func pushFreshBucket(capacity: Int) {
    fatalError()
  }

  @usableFromInline
  func popFresh() -> _NodePtr? {
    fatalError()
  }

  @usableFromInline
  mutating func ___popFresh() -> _NodePtr {
    fatalError()
  }

  @usableFromInline
  func ___flushFreshPool() {
    fatalError()
  }

  @usableFromInline
  func ___cleanFreshPool() {
    fatalError()
  }
}

extension UnsafeNodeFreshPoolV2 {

  @inlinable
  @inline(__always)
  func makeFreshPoolIterator() -> UnsafeNodeFreshPoolV2Iterator<_Value> {
    return UnsafeNodeFreshPoolV2Iterator<_Value>(
      elements: freshPool.array!.pointee, count: freshPool.used)
  }
}
