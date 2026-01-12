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

@usableFromInline
typealias UnsafeTreeV2Growth = UnsafeTreeAllcation6_9

@usableFromInline
protocol ___UnsafeCopyOnWriteV2: UnsafeTreeV2Growth {
  associatedtype Base: ___TreeBase
  var __tree_: UnsafeTreeV2<Base> { get set }
}

extension ___UnsafeCopyOnWriteV2 {

  @inlinable
  @inline(__always)
  internal mutating func _isBaseKnownUnique() -> Bool {
    #if true
    return __tree_.isUniqueReference()
    #else
      return true
    #endif
  }

  @inlinable
  @inline(__always)
  internal mutating func _isKnownUniquelyReferenced_LV1() -> Bool {
    #if !DISABLE_COPY_ON_WRITE
      #if !USE_SIMPLE_COPY_ON_WRITE || COMPATIBLE_ATCODER_2025
        return !__tree_.isReadOnly && _isBaseKnownUnique()
      #else
        return __tree_.isUniqueReference()
      #endif
    #else
      return true
    #endif
  }

  @inlinable
  @inline(__always)
  internal mutating func _isKnownUniquelyReferenced_LV2() -> Bool {
    #if !DISABLE_COPY_ON_WRITE
      if !_isKnownUniquelyReferenced_LV1() {
        return false
      }
      if !__tree_.isUniqueReference() {
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
    #if false
      let shouldExpand = __tree_.capacity < minimumCapacity
      let newCapacity = growCapacity(to: minimumCapacity, linearly: false)
      if !_isKnownUniquelyReferenced_LV1() {
        __tree_ = __tree_.copy(minimumCapacity: newCapacity)
        _updateRefCounter()
      } else if shouldExpand {
        __tree_.executeCapacityGrow(newCapacity)
      }
      assert(__tree_.initializedCount <= __tree_.capacity)
    #else
      let isUnique = _isKnownUniquelyReferenced_LV1()
      __tree_._ensureUniqueAndCapacity(to: minimumCapacity, isUnique: isUnique)
    #endif
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
    let newCapacity = growCapacity(to: minimumCapacity, linearly: linearly)
    if !_isKnownUniquelyReferenced_LV1() {
      __tree_ = __tree_.copy(minimumCapacity: newCapacity)
    } else if shouldExpand {
      __tree_.executeCapacityGrow(newCapacity)
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
      let newCapacity = growCapacity(to: minimumCapacity, linearly: false)
      __tree_.executeCapacityGrow(newCapacity)
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
    if __tree_.capacity < min(limit, minimumCapacity) {
      let newCapacity = min(limit, growCapacity(to: minimumCapacity, linearly: linearly))
      __tree_.executeCapacityGrow(newCapacity)
    }
  }
}

extension UnsafeTreeV2 {
  @inlinable
  @inline(__always)
  internal mutating func isUniqueReference() -> Bool {
    _buffer.isUniqueReference()
  }
}

extension UnsafeTreeV2 {
  @inlinable
  @inline(__always)
  internal mutating func _ensureUnique(
    isUnique: Bool,
    transform: (UnsafeTreeV2<Base>) throws -> UnsafeTreeV2<Base>
  )
    rethrows -> Bool
  {
    let isCopied = _ensureUnique(isUnique: isUnique)
    self = try transform(self)
    return isCopied
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal mutating func _ensureUnique(isUnique: Bool) -> Bool {
    if !isUnique {
      self = self.copy()
      return true
    }
    return false
  }
}

extension UnsafeTreeV2 {

  @inlinable @inline(__always)
  mutating func _ensureUniqueAndCapacity(isUnique: Bool) {
    _ensureUniqueAndCapacity(to: count + 1, isUnique: isUnique)
  }

  @inlinable
  @inline(__always)
  mutating func _ensureUniqueAndCapacity(
    to minimumCapacity: Int,
    isUnique: Bool
  ) {
    let shouldExpand = capacity < minimumCapacity
    let newCapacity = growCapacity(to: minimumCapacity, linearly: false)
    guard shouldExpand || !isUnique else { return }
    if !isUnique {
      self = self.copy(minimumCapacity: newCapacity)
    } else if shouldExpand {
      executeCapacityGrow(newCapacity)
    }
    assert(initializedCount <= capacity)
  }
}

extension UnsafeTreeV2 {

  @inlinable @inline(__always)
  internal mutating func _ensureCapacity(limit: Int, linearly: Bool = false) {
    _ensureCapacity(to: count + 1, limit: limit, linearly: linearly)
  }

  @inlinable @inline(__always)
  internal mutating func _ensureCapacity(to minimumCapacity: Int, limit: Int, linearly: Bool) {
    if capacity < minimumCapacity {
      let newCapacity = min(limit, growCapacity(to: capacity, linearly: false))
      executeCapacityGrow(newCapacity)
    }
  }
}
