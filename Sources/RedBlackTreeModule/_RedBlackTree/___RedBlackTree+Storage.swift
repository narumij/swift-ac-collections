// Copyright 2024 narumij
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

import Foundation

extension ___RedBlackTree.___Tree {

  @inlinable
  static func _isKnownUniquelyReferenced(tree: inout Tree) -> Bool {
    isKnownUniquelyReferenced(&tree)
  }

  @inlinable
  static func ensureUnique(tree: inout Tree) {
    if !isKnownUniquelyReferenced(&tree) {
      makeEnsureUnique(tree: &tree)
    }
  }

  @inlinable
  static func ensureUniqueAndCapacity(tree: inout Tree) {
    ensureUniqueAndCapacity(tree: &tree, minimumCapacity: tree.count + 1)
  }

  @inlinable
  static func ensureUniqueAndCapacity(tree: inout Tree, minimumCapacity: Int) {
    let shouldExpand = tree.header.capacity < minimumCapacity
    if shouldExpand || !isKnownUniquelyReferenced(&tree) {
      makeEnsureUniqueAndCapacity(tree: &tree, minimumCapacity: minimumCapacity)
    }
  }

  @inlinable
  static func ensureCapacity(tree: inout Tree, minimumCapacity: Int) {
    if tree.header.capacity < minimumCapacity {
      makeEnsureUniqueAndCapacity(tree: &tree, minimumCapacity: minimumCapacity)
    }
  }

  @inlinable
  static func makeEnsureUnique(tree: inout Tree) {
    tree = tree.copy(
      newCapacity: tree.header.capacity)
  }

  @inlinable
  static func makeEnsureUniqueAndCapacity(tree: inout Tree, minimumCapacity: Int) {
    tree = tree.copy(
      newCapacity: _growCapacity(tree: &tree, to: minimumCapacity, linearly: false))
    assert(minimumCapacity <= tree.capacity)
  }

  @inlinable
  @inline(__always)
  internal static var growthFactor: Double { 1.75 }

  @inlinable
  internal static func _growCapacity(
    tree: inout Tree,
    to minimumCapacity: Int,
    linearly: Bool
  ) -> Int {

    if linearly {
      return Swift.max(
        tree.header.initializedCount,
        minimumCapacity)
    }

    return Swift.max(
      tree.header.initializedCount,
      Int((Self.growthFactor * Double(tree.count)).rounded(.up)),
      minimumCapacity)
  }
}

extension ___RedBlackTree.___Tree {}

extension ___RedBlackTree.___Tree {

  // コンテナに対するCoW責任をカバーする
  // それ以外はTree側の保持の仕方で管理する
  @_fixed_layout
  @usableFromInline
  final class Storage {
    @nonobjc
    @inlinable
    @inline(__always)
    init(__tree: Tree) {
      tree = __tree
    }
    @nonobjc
    @inlinable
    @inline(__always)
    init(minimumCapacity: Int) {
      tree = .create(withCapacity: minimumCapacity)
    }
    @usableFromInline
    typealias _Tree = Tree
    @usableFromInline
    final var tree: Tree
    @nonobjc
    @usableFromInline
    final var count: Int { tree.count }
    @nonobjc
    @usableFromInline
    final var capacity: Int { tree.header.capacity }
    @nonobjc
    @inlinable
    @inline(__always)
    internal static func create(
      withCapacity capacity: Int
    ) -> Storage {
      return .init(minimumCapacity: capacity)
    }
    @nonobjc
    @inlinable
    @inline(__always)
    final func copy() -> Storage {
      .init(__tree: tree.copy())
    }
    @nonobjc
    @inlinable
    @inline(__always)
    final func copy(minimumCapacity: Int) -> Storage {
      .init(__tree: tree.copy(newCapacity: minimumCapacity))
    }
    @nonobjc
    @inlinable
    @inline(__always)
    final func isKnownUniquelyReferenced_tree() -> Bool {
      isKnownUniquelyReferenced(&tree)
    }
  }
}

@usableFromInline
protocol ___RedBlackTreeStorageLifetime: ValueComparer {
  var _storage: Tree.Storage { get set }
}

extension ___RedBlackTreeStorageLifetime {

  @inlinable
  @inline(__always)
  mutating func _isKnownUniquelyReferenced_LV2() -> Bool {
    if !_isKnownUniquelyReferenced_LV1() {
      return false
    }
    if !_storage.isKnownUniquelyReferenced_tree() {
      return false
    }
    return true
  }

  @inlinable
  @inline(__always)
  mutating func _isKnownUniquelyReferenced_LV1() -> Bool {
    isKnownUniquelyReferenced(&_storage)
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
  mutating func _strongEnsureUniqueAndCapacity() {
    _ensureUniqueAndCapacity(minimumCapacity: _storage.count + 1)
    assert(_storage.capacity > 0)
  }

  @inlinable
  @inline(__always)
  mutating func _strongEnsureUniqueAndCapacity(minimumCapacity: Int) {
    let shouldExpand = _storage.capacity < minimumCapacity
    if shouldExpand || !_isKnownUniquelyReferenced_LV2() {
      _storage = _storage.copy(
        minimumCapacity: Tree._growCapacity(
          tree: &_storage.tree, to: minimumCapacity, linearly: false))
    }
    assert(_storage.capacity >= minimumCapacity)
    assert(_storage.tree.header.initializedCount <= _storage.capacity)
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
  mutating func _ensureUniqueAndCapacity() {
    _ensureUniqueAndCapacity(minimumCapacity: _storage.count + 1)
    assert(_storage.capacity > 0)
  }

  @inlinable
  @inline(__always)
  mutating func _ensureUniqueAndCapacity(minimumCapacity: Int) {
    let shouldExpand = _storage.capacity < minimumCapacity
    if shouldExpand || !_isKnownUniquelyReferenced_LV1() {
      _storage = _storage.copy(
        minimumCapacity: Tree._growCapacity(
          tree: &_storage.tree, to: minimumCapacity, linearly: false))
    }
    assert(_storage.capacity >= minimumCapacity)
    assert(_storage.tree.header.initializedCount <= _storage.capacity)
  }
}
