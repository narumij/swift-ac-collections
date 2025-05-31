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

public enum ___RedBlackTree {}

extension ValueComparer {
  public typealias Tree = ___Tree<Self>
}

@usableFromInline
protocol ___RedBlackTreeBase: ValueComparer {
  associatedtype Element
  var _storage: Tree.Storage { get set }
}

extension ___RedBlackTreeBase {
  
  @inlinable @inline(__always)
  var _tree: Tree { _storage.tree }
}

extension ___RedBlackTreeBase {

  @inlinable @inline(__always)
  var ___count: Int {
    _tree.count
  }

  @inlinable @inline(__always)
  var ___is_empty: Bool {
    _tree.___is_empty
  }

  @inlinable @inline(__always)
  var ___capacity: Int {
    _tree.___capacity
  }
}

// MARK: - Index

extension ___RedBlackTreeBase {

  @usableFromInline
  typealias ___Iterator = Tree.___Iterator

  @usableFromInline
  typealias ___RawIndex = RawIndex

  @inlinable @inline(__always)
  func ___iter(_ p: _NodePtr) -> ___Iterator {
//    .init(__tree: _tree, rawValue: p)
    _tree.makeIndex(rawValue: p)
  }

  @inlinable @inline(__always)
  func ___iter_or_nil(_ p: _NodePtr) -> ___Iterator? {
    p == .nullptr ? nil : ___iter(p)
  }

  @inlinable @inline(__always)
  func ___iter_or_nil(_ p: _NodePtr?) -> ___Iterator? {
    p.map { ___iter($0) }
  }

  @inlinable @inline(__always)
  func ___iter_start() -> ___Iterator {
    ___iter(_tree.__begin_node)
  }

  @inlinable @inline(__always)
  func ___iter_end() -> ___Iterator {
    ___iter(_tree.___end())
  }

  @inlinable @inline(__always)
  public func ___ptr_start() -> _NodePtr {
    _tree.__begin_node
  }

  @inlinable @inline(__always)
  public func ___ptr_end() -> _NodePtr {
    _tree.___end()
  }
}

extension ___RedBlackTreeBase {

  @inlinable @inline(__always)
  public func ___ptr_lower_bound(_ __k: _Key) -> _NodePtr {
    _tree.lower_bound(__k)
  }

  @inlinable @inline(__always)
  public func ___ptr_upper_bound(_ __k: _Key) -> _NodePtr {
    _tree.upper_bound(__k)
  }

  @inlinable @inline(__always)
  public func ___raw_index_lower_bound(_ __k: _Key) -> ___RawIndex {
    _tree.makeRawIndex(rawValue: _tree.lower_bound(__k))
  }

  @inlinable @inline(__always)
  public func ___raw_index_upper_bound(_ __k: _Key) -> ___RawIndex {
    _tree.makeRawIndex(rawValue: _tree.upper_bound(__k))
  }

  @inlinable @inline(__always)
  public func ___iter_lower_bound(_ __k: _Key) -> ___Iterator {
    ___iter(___ptr_lower_bound(__k))
  }

  @inlinable @inline(__always)
  public func ___iter_upper_bound(_ __k: _Key) -> ___Iterator {
    ___iter(___ptr_upper_bound(__k))
  }
}

extension ___RedBlackTreeBase {

  @inlinable
  func ___first_iter(of member: _Key) -> ___Iterator? {
    var __parent = _NodePtr.nullptr
    let ptr = _tree.__ptr_(_tree.__find_equal(&__parent, member))
    return ___iter_or_nil(ptr)
  }

  @inlinable
  func ___first_iter(where predicate: (Element) throws -> Bool) rethrows -> ___Iterator? {
    var result: ___Iterator?
    try _tree.___for_each(__p: _tree.__begin_node, __l: _tree.__end_node()) { __p, cont in
      if try predicate(_tree[__p]) {
        result = ___iter(__p)
        cont = false
      }
    }
    return result
  }
}

// MARK: - Remove

extension ___RedBlackTreeBase {

  @inlinable
  @inline(__always)
  @discardableResult
  mutating func ___remove(at ptr: _NodePtr) -> Element? {
    guard
      !___is_null_or_end(ptr),
      _tree.___is_valid_index(ptr)
    else {
      return nil
    }
    let e = _tree[ptr]
    _ = _tree.erase(ptr)
    return e
  }

  @inlinable
  @inline(__always)
  @discardableResult
  mutating func ___remove(from: _NodePtr, to: _NodePtr) -> _NodePtr {
    guard from != .end else {
      return .end
    }
    guard
      _tree.___is_valid_index(from),
      _tree.___is_valid_index(to)
    else {
      fatalError(.invalidIndex)
    }
    return _tree.erase(from, to)
  }

  @inlinable
  @inline(__always)
  public mutating func ___remove(
    from: _NodePtr, to: _NodePtr, forEach action: (Element) throws -> Void
  )
    rethrows
  {
    guard from != .end else {
      return
    }
    guard
      _tree.___is_valid_index(from),
      _tree.___is_valid_index(to)
    else {
      fatalError(.invalidIndex)
    }
    return try _tree.___erase(from, to, action)
  }

  @inlinable
  @inline(__always)
  public mutating func ___remove<Result>(
    from: _NodePtr, to: _NodePtr,
    into initialResult: Result,
    _ updateAccumulatingResult: (inout Result, Element) throws -> Void
  ) rethrows -> Result {
    guard from != .end else {
      return initialResult
    }
    guard
      _tree.___is_valid_index(from),
      _tree.___is_valid_index(to)
    else {
      fatalError(.invalidIndex)
    }
    return try _tree.___erase(from, to, into: initialResult, updateAccumulatingResult)
  }

  @inlinable
  @inline(__always)
  public mutating func ___remove<Result>(
    from: _NodePtr, to: _NodePtr,
    _ initialResult: Result,
    _ nextPartialResult: (Result, Element) throws -> Result
  ) rethrows -> Result {
    guard from != .end else {
      return initialResult
    }
    guard
      _tree.___is_valid_index(from),
      _tree.___is_valid_index(to)
    else {
      fatalError(.invalidIndex)
    }
    return try _tree.___erase(from, to, initialResult, nextPartialResult)
  }
}

extension ___RedBlackTreeBase {

  @inlinable
  mutating func ___removeAll(keepingCapacity keepCapacity: Bool = false) {

    if keepCapacity {
      _tree.__eraseAll()
    } else {
      _storage = .create(withCapacity: 0)
    }
  }
}

// MARK: - Equatable

extension ___RedBlackTreeBase {

  @inlinable
  func ___equal_with(_ rhs: Self) -> Bool where Self: Sequence, Element: Equatable {
    _tree === rhs._tree || (___count == rhs.___count && zip(_tree, rhs._tree).allSatisfy(==))
  }

  @inlinable
  func ___equal_with<K, V>(_ rhs: Self) -> Bool
  where Self: Sequence, K: Equatable, V: Equatable, Element == (key: K, value: V) {
    _tree === rhs._tree || (___count == rhs.___count && zip(_tree, rhs._tree).allSatisfy(==))
  }
}

// MARK: - Etc

extension ___RedBlackTreeBase {

  @inlinable @inline(__always)
  func ___contains(_ __k: _Key) -> Bool where _Key: Equatable {
    _tree.__count_unique(__k) != 0
  }
}

extension ___RedBlackTreeBase {

  @inlinable @inline(__always)
  func ___min() -> Element? {
    _tree.__root() == .nullptr ? nil : _tree[_tree.__tree_min(_tree.__root())]
  }

  @inlinable @inline(__always)
  func ___max() -> Element? {
    _tree.__root() == .nullptr ? nil : _tree[_tree.__tree_max(_tree.__root())]
  }
}

extension ___RedBlackTreeBase {

  @inlinable @inline(__always)
  func ___value_for(_ __k: _Key) -> Element? {
    let __ptr = _tree.find(__k)
    return ___is_null_or_end(__ptr) ? nil : _tree[__ptr]
  }
}

extension ___RedBlackTreeBase {

  @inlinable
  public func ___first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
    var result: Element?
    try _tree.___for_each(__p: _tree.__begin_node, __l: _tree.__end_node()) { __p, cont in
      if try predicate(_tree[__p]) {
        result = _tree[__p]
        cont = false
      }
    }
    return result
  }
}

extension ___RedBlackTreeBase {

  @inlinable
  public func ___tree_invariant() -> Bool {
    _tree.__tree_invariant(_tree.__root())
  }

  #if AC_COLLECTIONS_INTERNAL_CHECKS
    @inlinable
    public var _copyCount: UInt {
      get { _storage.tree.copyCount }
      set { _storage.tree.copyCount = newValue }
    }
  #endif
}

#if AC_COLLECTIONS_INTERNAL_CHECKS
  extension ___RedBlackTreeCopyOnWrite {
    @inlinable
    public mutating func _checkUnique() -> Bool {
      _isKnownUniquelyReferenced_LV2()
    }
  }
#endif

extension ___RedBlackTreeBase {

  // C++風の削除コードが書きたい場合にこっそり(!?)つかうもの
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func ___std_erase(_ ptr: RawIndex) -> RawIndex {
    _tree.makeRawIndex(rawValue: _tree.erase(ptr.rawValue))
  }

  // C++風の削除コードが書きたい場合にこっそり(!?)つかうもの
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func ___std_erase(_ ptr: ___Iterator) -> ___Iterator {
//    Tree.___Iterator(__tree: _tree, rawValue: _tree.erase(ptr.rawValue))
    _tree.makeIndex(rawValue: _tree.erase(ptr.rawValue))
  }
}

extension ___RedBlackTreeBase {
  
  @inlinable
  @inline(__always)
  public var ___key_comp: (_Key, _Key) -> Bool {
    _tree.value_comp
  }
  
  @inlinable
  @inline(__always)
  public var ___value_comp: (Element, Element) -> Bool {
    { _tree.value_comp(_tree.__key($0), _tree.__key($1)) }
  }
}
