// Copyright 2024-2025 narumij
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
// Copyright © 2003-2024 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

// コンテナに対するCoW責任をカバーする
// それ以外はTree側の保持の仕方で管理する
@_fixed_layout
@usableFromInline
final class UnsafeStorage<Base: ___TreeBase> {

  public typealias Tree = UnsafeTree<Base>

  @nonobjc
  @inlinable
  @inline(__always)
  internal init(tree: Tree) {
    self.tree = tree
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal init(minimumCapacity: Int) {
    tree = .create(minimumCapacity: minimumCapacity)
  }

  @usableFromInline
  typealias _Tree = Tree

  @nonobjc
  @usableFromInline
  internal var tree: Tree

  @nonobjc
  @inlinable
  @inline(__always)
  internal var count: Int { tree.count }

  @nonobjc
  @inlinable
  @inline(__always)
  internal var capacity: Int { tree.freshPoolCapacity }

  @nonobjc
  @inlinable
  @inline(__always)
  internal static func create(
    withCapacity capacity: Int
  ) -> UnsafeStorage {
    return .init(minimumCapacity: capacity)
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func copy() -> UnsafeStorage {
    .init(tree: tree.copy())
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func copy(
    growthCapacityTo capacity: Int,
    linearly: Bool
  ) -> UnsafeStorage {
    .init(
      tree: tree.copy(
        growthCapacityTo: capacity,
        linearly: linearly))
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func copy(
    growthCapacityTo capacity: Int,
    limit: Int,
    linearly: Bool
  ) -> UnsafeStorage {
    .init(
      tree: tree.copy(
        growthCapacityTo: capacity,
        limit: limit,
        linearly: linearly))
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ensure(
    growthCapacityTo capacity: Int,
    linearly: Bool
  ) {
      tree.growthCapacity(
        to: capacity,
        linearly: linearly)
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ensure(
    growthCapacityTo capacity: Int,
    limit: Int,
    linearly: Bool
  ) {
      tree.growthCapacity(
        to: capacity,
        limit: limit,
        linearly: linearly)
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func isKnownUniquelyReferenced_tree() -> Bool {
    #if !DISABLE_COPY_ON_WRITE
      isKnownUniquelyReferenced(&tree)
    #else
      true
    #endif
  }
}
