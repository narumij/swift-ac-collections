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
  
  @inlinable @inline(__always)
  public func bitCeil(_ n: Int) -> Int {
    n <= 1 ? 1 : 1 << (Int.bitWidth - (n - 1).leadingZeroBitCount)
  }
  
  @inlinable @inline(__always)
  public func growthFormula(count: Int) -> Int {
    // アロケーターにとって負担が軽そうな、2のべき付近を要求することにした。
    // ヘッダー込みで確保するべきかどうかは、ManagedBufferのソースをみておらず不明。
    // はみ出して大量に無駄にするよりはましなので、ヘッダー込みでサイズ計算することにしている。
    let rawSize = bitCeil(MemoryLayout<Header>.stride + MemoryLayout<Node>.stride * count)
    return (rawSize - MemoryLayout<Header>.stride) / MemoryLayout<Node>.stride
  }

  @inlinable
  @inline(__always)
  func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        _header.initializedCount,
        minimumCapacity)
    }

    if minimumCapacity <= 4 {
      return Swift.max(
      _header.initializedCount,
      minimumCapacity
      )
    }

    if minimumCapacity <= 12 {
      return Swift.max(
      _header.initializedCount,
      _header.capacity + (minimumCapacity - _header.capacity) * 2
      )
    }
    
    // 手元の環境だと、サイズ24まではピタリのサイズを確保することができる
    // 小さなサイズの成長を抑制すると、ABC385Dでの使用メモリが抑えられやすい
    // 実行時間も抑制されやすいが、なぜなのかはまだ不明
    
    // ABC385Dの場合、アロケータープールなんかで使いまわしが効きやすいからなのではと予想している。
    
    return Swift.max(
      _header.initializedCount,
      growthFormula(count: minimumCapacity))
  }

  @inlinable
  @inline(__always)
  func copy() -> Tree {
    copy(minimumCapacity: _header.initializedCount)
  }

  @inlinable
  @inline(__always)
  func copy(growthCapacityTo capacity: Int, linearly: Bool) -> Tree {
    copy(
      minimumCapacity:
        growCapacity(to: capacity, linearly: linearly))
  }

  @inlinable
  @inline(__always)
  func copy(growthCapacityTo capacity: Int, limit: Int, linearly: Bool) -> Tree {
    copy(
      minimumCapacity:
        Swift.min(
          growCapacity(to: capacity, linearly: linearly),
          limit))
  }
}

extension ___RedBlackTree.___Tree {

  @inlinable
  @inline(__always)
  static func _isKnownUniquelyReferenced(tree: inout Tree) -> Bool {
    #if !DISABLE_COPY_ON_WRITE
      isKnownUniquelyReferenced(&tree)
    #else
      true
    #endif
  }

  @inlinable
  @inline(__always)
  static func ensureUniqueAndCapacity(tree: inout Tree) {
    ensureUniqueAndCapacity(tree: &tree, minimumCapacity: tree._header.count + 1)
  }

  @inlinable
  @inline(__always)
  static func ensureUniqueAndCapacity(tree: inout Tree, minimumCapacity: Int) {
    let shouldExpand = tree._header.capacity < minimumCapacity
    if shouldExpand || !_isKnownUniquelyReferenced(tree: &tree) {
      tree = tree.copy(growthCapacityTo: minimumCapacity, linearly: false)
    }
  }

  @inlinable
  @inline(__always)
  static func ensureCapacity(tree: inout Tree) {
    ensureCapacity(tree: &tree, minimumCapacity: tree._header.count + 1)
  }

  @inlinable
  @inline(__always)
  static func ensureCapacity(tree: inout Tree, minimumCapacity: Int) {
    if tree._header.capacity < minimumCapacity {
      tree = tree.copy(growthCapacityTo: minimumCapacity, linearly: false)
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
      tree = .create(minimumCapacity: minimumCapacity)
    }
    @usableFromInline
    typealias _Tree = Tree
    @nonobjc
    @usableFromInline
    final var tree: Tree
    @nonobjc
    @inlinable
    @inline(__always)
    final var count: Int { tree.count }
    @nonobjc
    @inlinable
    @inline(__always)
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
    final func copy(growthCapacityTo capacity: Int,
                    linearly: Bool) -> Storage
    {
      .init(__tree: tree.copy(growthCapacityTo: capacity,
                              linearly: linearly))
    }
    @nonobjc
    @inlinable
    @inline(__always)
    final func copy(growthCapacityTo capacity: Int,
                    limit: Int,
                    linearly: Bool) -> Storage
    {
      .init(__tree: tree.copy(growthCapacityTo: capacity,
                              limit: limit,
                              linearly: linearly))
    }
    @nonobjc
    @inlinable
    @inline(__always)
    final func isKnownUniquelyReferenced_tree() -> Bool {
      #if !DISABLE_COPY_ON_WRITE
        isKnownUniquelyReferenced(&tree)
      #else
        true
      #endif
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
  mutating func _ensureUniqueAndCapacity(to minimumCapacity: Int, limit: Int, linearly: Bool = false) {
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
  mutating func _ensureCapacity(to minimumCapacity: Int, linearly: Bool = false) {
    if _storage.capacity < minimumCapacity {
      _storage = _storage.copy(growthCapacityTo: minimumCapacity,
                               linearly: linearly)
    }
    assert(_storage.capacity >= minimumCapacity)
    assert(_storage.tree.header.initializedCount <= _storage.capacity)
  }

  @inlinable
  @inline(__always)
  mutating func _ensureCapacity(to minimumCapacity: Int, limit: Int, linearly: Bool = false) {
    if _storage.capacity < minimumCapacity {
      _storage = _storage.copy(growthCapacityTo: minimumCapacity,
                               limit: limit,
                               linearly: linearly)
    }
    assert(_storage.capacity >= minimumCapacity)
    assert(_storage.tree.header.initializedCount <= _storage.capacity)
  }
}
