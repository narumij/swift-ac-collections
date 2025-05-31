//
//  ___RedBlackTreeBase+CopyOnWrite.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/05/31.
//

@usableFromInline
protocol ___RedBlackTreeCopyOnWrite: ValueComparer {
  var _storage: Tree.Storage { get set }
}

extension ___RedBlackTreeCopyOnWrite {

  @inlinable
  @inline(__always)
  mutating func _isKnownUniquelyReferenced_LV1() -> Bool {
    #if !DISABLE_COPY_ON_WRITE
      isKnownUniquelyReferenced(&_storage)
    #else
      true
    #endif
  }

  @inlinable
  @inline(__always)
  mutating func _isKnownUniquelyReferenced_LV2() -> Bool {
    #if !DISABLE_COPY_ON_WRITE
      if !_isKnownUniquelyReferenced_LV1() {
        return false
      }
      if !_storage.isKnownUniquelyReferenced_tree() {
        return false
      }
    #endif
    return true
  }

  @inlinable
  @inline(__always)
  mutating func _ensureUnique() {
    if !_isKnownUniquelyReferenced_LV1() {
      _storage = _storage.copy()
    }
  }

  @inlinable
  @inline(__always)
  mutating func _strongEnsureUnique() {
    if !_isKnownUniquelyReferenced_LV2() {
      _storage = _storage.copy()
    }
  }

  @inlinable
  @inline(__always)
  mutating func _ensureUniqueAndCapacity() {
    _ensureUniqueAndCapacity(to: _storage.count + 1)
    assert(_storage.capacity > 0)
  }

  @inlinable
  @inline(__always)
  mutating func _ensureUniqueAndCapacity(to minimumCapacity: Int) {
    let shouldExpand = _storage.capacity < minimumCapacity
    if shouldExpand || !_isKnownUniquelyReferenced_LV1() {
      _storage = _storage.copy(growthCapacityTo: minimumCapacity, linearly: false)
    }
    assert(_storage.capacity >= minimumCapacity)
    assert(_storage.tree.header.initializedCount <= _storage.capacity)
  }
  
  @inlinable
  @inline(__always)
  mutating func _ensureUniqueAndCapacity(limit: Int, linearly: Bool = false) {
    _ensureUniqueAndCapacity(to: _storage.count + 1, limit: limit, linearly: linearly)
    assert(_storage.capacity > 0)
  }
  
  @inlinable
  @inline(__always)
  mutating func _ensureUniqueAndCapacity(to minimumCapacity: Int, limit: Int, linearly: Bool) {
    let shouldExpand = _storage.capacity < minimumCapacity
    if shouldExpand || !_isKnownUniquelyReferenced_LV1() {
      _storage = _storage.copy(growthCapacityTo: minimumCapacity,
                               limit: limit,
                               linearly: false)
    }
    assert(_storage.capacity >= minimumCapacity)
    assert(_storage.tree.header.initializedCount <= _storage.capacity)
  }

  @inlinable
  @inline(__always)
  mutating func _ensureCapacity() {
    let minimumCapacity = _storage.count + 1
    if _storage.capacity < minimumCapacity {
      _storage = _storage.copy(growthCapacityTo: minimumCapacity,
                               linearly: false)
    }
    assert(_storage.capacity >= minimumCapacity)
    assert(_storage.tree.header.initializedCount <= _storage.capacity)
  }

  @inlinable
  @inline(__always)
  mutating func _ensureCapacity(limit: Int, linearly: Bool = false) {
    _ensureCapacity(to: _storage.count + 1, limit: limit, linearly: linearly)
  }

  @inlinable
  @inline(__always)
  mutating func _ensureCapacity(to minimumCapacity: Int, limit: Int, linearly: Bool) {
    if _storage.capacity < minimumCapacity {
      _storage = _storage.copy(growthCapacityTo: minimumCapacity,
                               limit: limit,
                               linearly: linearly)
    }
    assert(_storage.capacity >= minimumCapacity)
    assert(_storage.tree.header.initializedCount <= _storage.capacity)
  }
}
