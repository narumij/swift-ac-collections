//
//  ___UnsafeCopyOnWriteV2.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/05.
//

//@usableFromInline
//typealias ReferenceCounter = ManagedBufferPointer<Void,Void>
//
//extension ManagedBufferPointer where Header == Void, Element == Void {
//  
//  @inlinable
//  @inline(__always)
//  static func create() -> Self {
//    .init(unsafeBufferObject: ManagedBuffer<Void,Void>.create(minimumCapacity: 0) { _ in })
//  }
//}

@usableFromInline
typealias ReferenceCounter = ManagedBuffer<Void,Void>

extension ManagedBuffer where Header == Void, Element == Void {
  
  @inlinable
  @inline(__always)
  static func create() -> ManagedBuffer {
    ManagedBuffer<Void,Void>.create(minimumCapacity: 0) { _ in }
  }
}

@usableFromInline
protocol ___UnsafeCopyOnWriteV2 {
  associatedtype Base: ___TreeBase
  var referenceCounter: ReferenceCounter { get set }
  var __tree_: UnsafeTreeV2<Base> { get set }
}

extension ___UnsafeCopyOnWriteV2 {
  
  @inlinable
  @inline(__always)
  internal mutating func _isKnownUniquelyReferenced_LV1() -> Bool {
    #if !DISABLE_COPY_ON_WRITE
    __tree_._buffer.buffer !== _emptyTreeStorage &&
    isKnownUniquelyReferenced(&referenceCounter)
    #else
      true
    #endif
  }

  @inlinable
  @inline(__always)
  internal mutating func _isKnownUniquelyReferenced_LV2() -> Bool {
    #if !DISABLE_COPY_ON_WRITE
      if !_isKnownUniquelyReferenced_LV1() {
        return false
      }
      if !__tree_._buffer.isUniqueReference() {
        return false
      }
    #endif
    return true
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureUnique() {
    if !_isKnownUniquelyReferenced_LV1() {
      __tree_ = __tree_.copy()
    }
  }

  @inlinable
  @inline(__always)
  internal mutating func _strongEnsureUnique() {
    if !_isKnownUniquelyReferenced_LV2() {
      __tree_ = __tree_.copy()
    }
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureUnique(
    transform: (UnsafeTreeV2<Base>) throws -> UnsafeTreeV2<Base>
  )
    rethrows
  {
    _ensureUnique()
    __tree_ = try transform(__tree_)
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureUniqueAndCapacity() {
    _ensureUniqueAndCapacity(to: __tree_.count + 1)
    assert(__tree_.capacity > 0)
    assert(__tree_.capacity > __tree_.count)
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureUniqueAndCapacity(to minimumCapacity: Int) {
    let shouldExpand = __tree_.capacity < minimumCapacity
    if !_isKnownUniquelyReferenced_LV1() {
      __tree_ = __tree_.copy(growthCapacityTo: minimumCapacity, linearly: false)
    } else if shouldExpand {
      __tree_.growthCapacity(to: minimumCapacity, linearly: false)
    }
    assert(__tree_.capacity >= minimumCapacity)
    assert(__tree_.initializedCount <= __tree_.capacity)
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureUniqueAndCapacity(limit: Int, linearly: Bool = false) {
    _ensureUniqueAndCapacity(to: __tree_.count + 1, limit: limit, linearly: linearly)
    assert(__tree_.capacity > 0)
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureUniqueAndCapacity(
    to minimumCapacity: Int, limit: Int, linearly: Bool
  ) {
    let shouldExpand = __tree_.capacity < minimumCapacity
    if !_isKnownUniquelyReferenced_LV1() {
      __tree_ = __tree_.copy(
        growthCapacityTo: minimumCapacity,
        limit: limit,
        linearly: false)
    } else if shouldExpand {
      __tree_.growthCapacity(to: minimumCapacity, limit: limit, linearly: false)
    }
    assert(__tree_.capacity >= minimumCapacity)
    assert(__tree_.initializedCount <= __tree_.capacity)
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureCapacity() {
    _ensureCapacity(amount: 1)
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureCapacity(amount: Int) {
    let minimumCapacity = __tree_.count + amount
    if __tree_.capacity < minimumCapacity {
      __tree_.growthCapacity(to: minimumCapacity, linearly: false)
    }
    assert(__tree_.capacity >= minimumCapacity)
    assert(__tree_.initializedCount <= __tree_.capacity)
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureCapacity(limit: Int, linearly: Bool = false) {
    _ensureCapacity(to: __tree_.count + 1, limit: limit, linearly: linearly)
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureCapacity(to minimumCapacity: Int, limit: Int, linearly: Bool) {
    if __tree_.capacity < minimumCapacity {
      __tree_.growthCapacity(to: minimumCapacity, limit: limit, linearly: false)
    }
    assert(__tree_.capacity >= minimumCapacity)
    assert(__tree_.initializedCount <= __tree_.capacity)
  }
}
