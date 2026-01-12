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

extension UnsafeTreeV2 {

  // TODO: grow関連の名前が混乱気味なので整理する
  @inlinable
  @inline(__always)
  public func executeCapacityGrow(_ newCapacity: Int) {
    guard capacity < newCapacity else { return }
    withMutableHeader { $0.pushFreshBucket(capacity: newCapacity - capacity) }
  }
}

extension UnsafeTreeV2 {
  
  
  @inlinable
  @inline(__always)
  internal func copy() -> UnsafeTreeV2 {
    copy(minimumCapacity: capacity)
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal func copy(growthCapacityTo capacity: Int, linearly: Bool) -> UnsafeTreeV2 {
    copy(
      minimumCapacity:
        growCapacity(to: capacity, linearly: linearly))
  }

  @inlinable
  @inline(__always)
  internal func copy(growthCapacityTo capacity: Int, limit: Int, linearly: Bool) -> UnsafeTreeV2 {
    copy(
      minimumCapacity:
        Swift.min(
          growCapacity(to: capacity, linearly: linearly),
          limit))
  }
  
  @inlinable
  @inline(__always)
  internal func growthCapacity(to capacity: Int, linearly: Bool) {
    executeCapacityGrow(growCapacity(to: capacity, linearly: linearly))
  }

  @inlinable
  @inline(__always)
  internal func growthCapacity(to capacity: Int, limit: Int, linearly: Bool) {
    executeCapacityGrow(Swift.min(growCapacity(to: capacity, linearly: linearly), limit))
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal static func _isKnownUniquelyReferenced(tree: inout UnsafeTreeV2) -> Bool {
    #if !DISABLE_COPY_ON_WRITE
    !tree.isReadOnly && tree._buffer.isUniqueReference()
    #else
      true
    #endif
  }

  @inlinable
  @inline(__always)
  internal static func ensureUniqueAndCapacity(tree: inout UnsafeTreeV2) {
    ensureUniqueAndCapacity(tree: &tree, minimumCapacity: tree.count + 1)
  }

  @inlinable
  @inline(__always)
  internal static func ensureUniqueAndCapacity(tree: inout UnsafeTreeV2, minimumCapacity: Int) {
    let shouldExpand = tree.capacity < minimumCapacity
    if !_isKnownUniquelyReferenced(tree: &tree) {
      tree = tree.copy(growthCapacityTo: minimumCapacity, linearly: false)
    } else if shouldExpand {
      _ = tree.growCapacity(to: minimumCapacity, linearly: false)
    }
  }

  @inlinable
  @inline(__always)
  internal static func ensureCapacity(tree: inout UnsafeTreeV2) {
    ensureCapacity(tree: &tree, minimumCapacity: tree.count + 1)
  }

  @inlinable
  @inline(__always)
  internal static func ensureCapacity(tree: inout UnsafeTreeV2, minimumCapacity: Int) {
    if tree.capacity < minimumCapacity {
      tree.growthCapacity(to: minimumCapacity, linearly: false)
    }
  }
}
