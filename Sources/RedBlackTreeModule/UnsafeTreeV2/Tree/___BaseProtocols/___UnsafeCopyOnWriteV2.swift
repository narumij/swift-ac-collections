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
    return __tree_._buffer.isUniqueReference()
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
    if !__tree_._buffer.isUniqueReference() {
        return false
      }
    #endif
    return true
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureUnique(
    transform: (UnsafeTreeV2<Base>) throws -> UnsafeTreeV2<Base>
  )
    rethrows
  {
    __tree_._ensureUnique()
    __tree_ = try transform(__tree_)
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureUniqueAndCapacity() {
#if false
    _ensureUniqueAndCapacity(to: __tree_.count + 1)
#else
    __tree_._ensureUniqueAndCapacity()
#endif
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
      __tree_._ensureUniqueAndCapacity(to: minimumCapacity)
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
  internal mutating func _ensureUnique(
    transform: (UnsafeTreeV2<Base>) throws -> UnsafeTreeV2<Base>
  )
    rethrows
  {
    _ensureUnique()
    self = try transform(self)
  }
}

extension UnsafeTreeV2 {
  
  @inlinable
  @inline(__always)
  internal mutating func _ensureUnique() {
    let isUnique = _buffer.isUniqueReference()
    if !isUnique {
      self = self.copy()
    }
  }
  
  @inlinable
  @inline(__always)
  internal mutating func _strongEnsureUnique() {
    let isUnique = _buffer.isUniqueReference()
    if !isUnique {
      self = self.copy()
    }
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  mutating func _ensureUniqueAndCapacity(to minimumCapacity: Int? = nil) {
    
    let isUnique = _buffer.isUniqueReference()

    let growthCapacity: Int? = withMutableHeader { header in
      
      let minimumCapacity = minimumCapacity ?? (header.count + 1)
      
      let shouldExpand = header.freshPoolCapacity < minimumCapacity
      
      guard shouldExpand || !isUnique else { return nil }
      
      let growthCapacity = header.growthCapacity(to: minimumCapacity, linearly: false)
      
      if !isUnique {
        return growthCapacity
      }
      
      if shouldExpand {
        header.executeCapacityGrow(growthCapacity)
      }
      
      return nil
    }
    
    if let growthCapacity {
      self = self.copy(minimumCapacity: growthCapacity)
    }
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

extension UnsafeTreeV2Buffer.Header {

  @inlinable
  @inline(__always)
  internal func growthCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        freshPoolCapacity,
        minimumCapacity)
    }

    //    if minimumCapacity <= 2 {
    //      return Swift.max(minimumCapacity, 2)
    //    }
    //
    //    if minimumCapacity <= 4 {
    //      return Swift.max(minimumCapacity, 4)
    //    }

    return Swift.max(minimumCapacity, freshPoolCapacity + max(freshPoolCapacity / 4, 2))
  }
}

extension UnsafeTreeV2Buffer.Header {

  @inlinable
  @inline(__always)
  public mutating func executeCapacityGrow(_ newCapacity: Int) {
    guard freshPoolCapacity < newCapacity else { return }
    pushFreshBucket(capacity: newCapacity - freshPoolCapacity)
  }
}
