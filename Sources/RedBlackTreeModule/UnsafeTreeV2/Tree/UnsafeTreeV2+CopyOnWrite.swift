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

import Foundation

extension UnsafeTreeV2BufferHeader {

  @inlinable
  @inline(__always)
  internal mutating func executeCapacityGrow(_ newCapacity: Int) {
    guard freshPoolCapacity < newCapacity else { return }
    pushFreshBucket(capacity: newCapacity - freshPoolCapacity)
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal func executeCapacityGrow(_ newCapacity: Int) {
    withMutableHeader {
      $0.executeCapacityGrow(newCapacity)
    }
  }
}

extension UnsafeTreeV2 {

  // 以前の名残でクラスメソッド経由となっている。取り除くリファクタリングをして構わない

  @inlinable
  @inline(__always)
  internal static func ensureCapacity(tree: inout UnsafeTreeV2, linearly: Bool = false) {
    tree._ensureCapacity(linearly: linearly)
  }

  @inlinable
  @inline(__always)
  internal static func ensureCapacity(
    tree: inout UnsafeTreeV2, minimumCapacity: Int, linearly: Bool = false
  ) {
    tree._ensureCapacity(to: minimumCapacity, linearly: linearly)
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
    //    return _ensureUnique()

    let isTreeUnique = _buffer.isUniqueReference()
    let isPoolUnique =
      _buffer.header._deallocator == nil
      ? true : isKnownUniquelyReferenced(&_buffer.header._deallocator!)

    if isTreeUnique, isPoolUnique {
      /* NOP */
    } else {
      self = self.copy()
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
  internal mutating func _ensureUniqueAndCapacity(
    to minimumCapacity: Int? = nil, linearly: Bool = false
  ) {

    let isUnique = _buffer.isUniqueReference()

    let growthCapacity: Int? = withMutableHeader { header in

      let minimumCapacity = minimumCapacity ?? (header.count + 1)

      let shouldExpand = header.freshPoolCapacity < minimumCapacity

      guard shouldExpand || !isUnique else { return nil }

      let growthCapacity = header._growthCapacity(to: minimumCapacity, linearly: linearly)

      if !isUnique {
        return growthCapacity
      }

      if shouldExpand {
        assert(isReadOnly == false)
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
  internal mutating func _ensureCapacity(linearly: Bool = false) {
    _ensureCapacity(to: count + 1, linearly: linearly)
  }

  @inlinable @inline(__always)
  internal mutating func _ensureCapacity(to minimumCapacity: Int, linearly: Bool = false) {
    guard capacity < minimumCapacity else { return }
    let newCapacity = withHeader {
      header in header._growthCapacity(to: minimumCapacity, linearly: linearly)
    }
    if isReadOnly {
      self = self.copy(minimumCapacity: newCapacity)
    } else {
      assert(isReadOnly == false)
      executeCapacityGrow(newCapacity)
    }
  }
}

extension UnsafeTreeV2 {

  @inlinable @inline(__always)
  internal mutating func _ensureCapacity(limit: Int, linearly: Bool = false) {
    _ensureCapacity(to: count + 1, limit: limit, linearly: linearly)
  }

  @inlinable @inline(__always)
  internal mutating func _ensureCapacity(
    to minimumCapacity: Int, limit: Int, linearly: Bool = false
  ) {
    guard capacity < minimumCapacity else { return }
    let newCapacity = withHeader { header in
      min(limit, header._growthCapacity(to: capacity, linearly: linearly))
    }
    if isReadOnly {
      self = self.copy(minimumCapacity: newCapacity)
    } else {
      executeCapacityGrow(newCapacity)
    }
  }
}

extension UnsafeTreeV2BufferHeader {

  @inlinable
  @inline(__always)
  internal func _growthCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

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

    // https://atcoder.jp/contests/abc411/submissions/72430351

    return Swift.max(minimumCapacity, freshPoolCapacity + max(freshPoolCapacity / 8, 1))
  }
}
