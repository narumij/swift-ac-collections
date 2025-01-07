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

@usableFromInline
enum StorageCapacity {

  @inlinable
  @inline(__always)
  //  public static var growthFactor: Double { 1.5 }
  //  public static var growthFactor: Double { 1.618 }  // Golden Ratio
  //  public static var growthFactor: Double { 1.7 }
  public static var growthFactor: Double { 1.7320508075688772 } // root 3
  //  public static var growthFactor: Double { 1.75 }
  //  public static var growthFactor: Double { 1.8 }

  @inlinable @inline(__always)
  public static func growthFormula(count: Int) -> Int {
    Int((growthFactor * Double(count)).rounded(.up))
  }
}

extension ___RedBlackTree.___Tree {
  
  @inlinable
  @inline(__always)
  func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        _header.initializedCount,
        minimumCapacity)
    }

    return Swift.max(
      _header.initializedCount,
      StorageCapacity.growthFormula(count: _header.count),
      minimumCapacity)
  }
}

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
      minimumCapacity: tree.header.capacity)
  }

  @inlinable
  static func makeEnsureUniqueAndCapacity(tree: inout Tree, minimumCapacity: Int) {
    tree = tree.copy(
      minimumCapacity: tree.growCapacity(to: minimumCapacity, linearly: false))
    assert(minimumCapacity <= tree._header.capacity)
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
      tree = .create(minimumCapacity: minimumCapacity)
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
    final func copy(newCapacity: Int) -> Storage {
      .init(__tree: tree.copy(minimumCapacity: newCapacity))
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
    #if !DISABLE_COPY_ON_WRITE
      if !_isKnownUniquelyReferenced_LV2() {
        _storage = _storage.copy()
      }
    #endif
  }

  @inlinable
  @inline(__always)
  mutating func _strongEnsureUniqueAndCapacity() {
    #if !DISABLE_COPY_ON_WRITE
      _ensureUniqueAndCapacity(minimumCapacity: _storage.count + 1)
      assert(_storage.capacity > 0)
    #endif
  }

  @inlinable
  @inline(__always)
  mutating func _strongEnsureUniqueAndCapacity(minimumCapacity: Int) {
    #if !DISABLE_COPY_ON_WRITE
      let shouldExpand = _storage.capacity < minimumCapacity
      if shouldExpand || !_isKnownUniquelyReferenced_LV2() {
        _storage = _storage.copy(
          newCapacity: _storage.tree.growCapacity(to: minimumCapacity, linearly: false))
      }
      assert(_storage.tree.capacity == _storage.tree.header.capacity)
      assert(_storage.capacity == _storage.tree.header.capacity)
      assert(_storage.capacity >= minimumCapacity)
      assert(_storage.tree.header.initializedCount <= _storage.capacity)
    #endif
  }

  @inlinable
  @inline(__always)
  mutating func _ensureUnique() {
    #if !DISABLE_COPY_ON_WRITE
      if !_isKnownUniquelyReferenced_LV1() {
        _storage = _storage.copy()
      }
    #endif
  }

  @inlinable
  @inline(__always)
  mutating func _ensureUniqueAndCapacity() {
    #if !DISABLE_COPY_ON_WRITE
      _ensureUniqueAndCapacity(minimumCapacity: _storage.count + 1)
      assert(_storage.capacity > 0)
    #endif
  }

  @inlinable
  @inline(__always)
  mutating func _ensureUniqueAndCapacity(minimumCapacity: Int) {
    #if !DISABLE_COPY_ON_WRITE
      let shouldExpand = _storage.capacity < minimumCapacity
      if shouldExpand || !_isKnownUniquelyReferenced_LV1() {
        _storage = _storage.copy(
          newCapacity: _storage.tree.growCapacity(to: minimumCapacity, linearly: false))
      }
      assert(_storage.tree.capacity == _storage.tree.header.capacity)
      assert(_storage.capacity == _storage.tree.header.capacity)
      assert(_storage.capacity >= minimumCapacity)
      assert(_storage.tree.header.initializedCount <= _storage.capacity)
    #endif
  }

  @inlinable
  @inline(__always)
  mutating func ___shrinkCapacity() {
    _storage = _storage.copy(newCapacity: _storage.tree.header.initializedCount)
  }
}
