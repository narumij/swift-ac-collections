//
//  ___RedBlackTree+Storage.swift
//  swift-ac-collections
//
//  Created by narumij on 2024/12/31.
//

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

extension ___RedBlackTree.___Tree {
  
  @usableFromInline
  class LifeStorage {
    
    private var _tree: Tree?
    
    @inlinable init() { }
    
    @usableFromInline
    func set(_tree: Tree) {
      self._tree = _tree
    }
  }
}

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
    final var lifeStorage: Tree.LifeStorage = .init()
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
    deinit {
      lifeStorage.set(_tree: tree)
    }
  }
}

@usableFromInline
protocol ___RedBlackTreeStorageLifetime: ValueComparer {
  var storage: Tree.Storage { get set }
}

extension ___RedBlackTreeStorageLifetime {
  
  @inlinable
  @inline(__always)
  mutating func _isKnownUniquelyReferenced() -> Bool {
    if !isKnownUniquelyReferenced(&storage) {
      return false
    }
    if !storage.isKnownUniquelyReferenced_tree() {
      return false
    }
    return true
  }

  @inlinable
  @inline(__always)
  mutating func _ensureUnique() {
    if !_isKnownUniquelyReferenced() {
      storage = storage.copy()
    }
  }

  @inlinable
  @inline(__always)
  mutating func _ensureUniqueAndCapacity() {
    _ensureUniqueAndCapacity(minimumCapacity: storage.count + 1)
  }

  @inlinable
  @inline(__always)
  mutating func _ensureUniqueAndCapacity(minimumCapacity: Int) {
    let shouldExpand = storage.capacity < minimumCapacity
    if shouldExpand || !_isKnownUniquelyReferenced() {
      storage = storage.copy(minimumCapacity: Tree._growCapacity(tree: &storage.tree, to: minimumCapacity, linearly: false))
    }
    assert(storage.capacity >= minimumCapacity)
    assert(storage.tree.header.initializedCount <= storage.capacity)
  }
}

@usableFromInline
protocol ___RedBlackTreeNonStorageLifetime: ValueComparer {
  var tree: Tree { get set }
}

extension ___RedBlackTreeNonStorageLifetime {
  
  @inlinable
  public mutating func _isKnownUniquelyReferenced() -> Bool {
    Tree._isKnownUniquelyReferenced(tree: &tree)
  }

  @inlinable
  public mutating func _ensureUnique() {
    Tree.ensureUnique(tree: &tree)
  }

  @inlinable
  mutating func _ensureUniqueAndCapacity() {
    Tree.ensureUniqueAndCapacity(tree: &tree)
  }
  
  @inlinable
  mutating func _ensureUniqueAndCapacity(minimumCapacity: Int) {
    Tree.ensureUniqueAndCapacity(tree: &tree, minimumCapacity: minimumCapacity)
  }
}
