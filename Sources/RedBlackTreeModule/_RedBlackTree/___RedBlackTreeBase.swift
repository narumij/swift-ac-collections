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

// 単に公開可能なTreeを知っているというだけの状態
// 下のモノと混ぜたかったが混ぜるとなぜかコンパイルエラーとなるのでわけてある
public protocol ___RedBlackTree {
  associatedtype Tree
}

// コレクション実装の基点
public protocol ___RedBlackTree___ {
  associatedtype Tree
}

// コレクションの内部実装
@usableFromInline
protocol ___RedBlackTreeBase:
  ___RedBlackTree___,
  ValueComparer
where
  Tree == ___Tree<Self>,
  Storage == ___Storage<Self>
{
  associatedtype Element
  associatedtype Storage
  var _storage: Tree.Storage { get set }
}

extension ___RedBlackTreeBase {

  @inlinable @inline(__always)
  var _tree_: Tree { _storage.tree }
}

extension ___RedBlackTreeBase {

  @inlinable @inline(__always)
  var ___count: Int {
    _tree_.count
  }

  @inlinable @inline(__always)
  var ___is_empty: Bool {
    _tree_.___is_empty
  }

  @inlinable @inline(__always)
  var ___capacity: Int {
    _tree_.___capacity
  }
}

// MARK: - Index

extension ___RedBlackTreeBase {

  @usableFromInline
  typealias Index = Tree.Index

  @inlinable @inline(__always)
  func ___iter(_ p: _NodePtr) -> Index {
    _tree_.makeIndex(rawValue: p)
  }

  @inlinable @inline(__always)
  func ___raw(_ p: _NodePtr) -> RawIndex {
    _tree_.makeRawIndex(rawValue: p)
  }

  @inlinable @inline(__always)
  func ___iter_or_nil(_ p: _NodePtr) -> Index? {
    p == .nullptr ? nil : ___iter(p)
  }

  @inlinable @inline(__always)
  func ___iter_or_nil(_ p: _NodePtr?) -> Index? {
    p.map { ___iter($0) }
  }

  @inlinable @inline(__always)
  public func ___start() -> _NodePtr {
    _tree_.__begin_node
  }

  @inlinable @inline(__always)
  public func ___end() -> _NodePtr {
    _tree_.___end()
  }

  @inlinable @inline(__always)
  public func ___raw_index_start() -> RawIndex {
    ___raw(___start())
  }

  @inlinable @inline(__always)
  public func ___raw_index_end() -> RawIndex {
    ___raw(___end())
  }

  @inlinable @inline(__always)
  func ___iter_start() -> Index {
    ___iter(_tree_.__begin_node)
  }

  @inlinable @inline(__always)
  func ___iter_end() -> Index {
    ___iter(_tree_.___end())
  }
}

extension ___RedBlackTreeBase {

  @inlinable @inline(__always)
  public func ___lower_bound(_ __k: _Key) -> _NodePtr {
    _tree_.lower_bound(__k)
  }

  @inlinable @inline(__always)
  public func ___upper_bound(_ __k: _Key) -> _NodePtr {
    _tree_.upper_bound(__k)
  }

  @inlinable @inline(__always)
  public func ___raw_index_lower_bound(_ __k: _Key) -> RawIndex {
    ___raw(_tree_.lower_bound(__k))
  }

  @inlinable @inline(__always)
  public func ___raw_index_upper_bound(_ __k: _Key) -> RawIndex {
    ___raw(_tree_.upper_bound(__k))
  }

  @inlinable @inline(__always)
  func ___iter_lower_bound(_ __k: _Key) -> Index {
    ___iter(___lower_bound(__k))
  }

  @inlinable @inline(__always)
  func ___iter_upper_bound(_ __k: _Key) -> Index {
    ___iter(___upper_bound(__k))
  }
}

extension ___RedBlackTreeBase {

  @inlinable
  func ___first_iter(of member: _Key) -> Index? {
    var __parent = _NodePtr.nullptr
    let ptr = _tree_.__ptr_(_tree_.__find_equal(&__parent, member))
    return ___iter_or_nil(ptr)
  }

  @inlinable
  func ___first_iter(where predicate: (Element) throws -> Bool) rethrows -> Index? {
    var result: Index?
    try _tree_.___for_each(__p: _tree_.__begin_node, __l: _tree_.__end_node()) { __p, cont in
      if try predicate(_tree_[__p]) {
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
  public mutating func ___remove(at ptr: _NodePtr) -> Element? {
    guard
      !___is_null_or_end(ptr),
      _tree_.___is_valid_index(ptr)
    else {
      return nil
    }
    let e = _tree_[ptr]
    _ = _tree_.erase(ptr)
    return e
  }

  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func ___remove(from: _NodePtr, to: _NodePtr) -> _NodePtr {
    guard from != .end else {
      return .end
    }
    guard
      _tree_.___is_valid_index(from),
      _tree_.___is_valid_index(to)
    else {
      fatalError(.invalidIndex)
    }
    return _tree_.erase(from, to)
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
      _tree_.___is_valid_index(from),
      _tree_.___is_valid_index(to)
    else {
      fatalError(.invalidIndex)
    }
    return try _tree_.___erase(from, to, action)
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
      _tree_.___is_valid_index(from),
      _tree_.___is_valid_index(to)
    else {
      fatalError(.invalidIndex)
    }
    return try _tree_.___erase(from, to, into: initialResult, updateAccumulatingResult)
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
      _tree_.___is_valid_index(from),
      _tree_.___is_valid_index(to)
    else {
      fatalError(.invalidIndex)
    }
    return try _tree_.___erase(from, to, initialResult, nextPartialResult)
  }
}

extension ___RedBlackTreeBase {

  @inlinable
  mutating func ___removeAll(keepingCapacity keepCapacity: Bool = false) {

    if keepCapacity {
      _tree_.__eraseAll()
    } else {
      _storage = .create(withCapacity: 0)
    }
  }
}

// MARK: - Equatable

extension ___RedBlackTreeBase {

  @inlinable
  func ___equal_with(_ rhs: Self) -> Bool where Self: Sequence, Element: Equatable {
    _tree_ === rhs._tree_ || (___count == rhs.___count && zip(_tree_, rhs._tree_).allSatisfy(==))
  }

  @inlinable
  func ___equal_with<K, V>(_ rhs: Self) -> Bool
  where Self: Sequence, K: Equatable, V: Equatable, Element == (key: K, value: V) {
    _tree_ === rhs._tree_ || (___count == rhs.___count && zip(_tree_, rhs._tree_).allSatisfy(==))
  }
}

// MARK: - Etc

extension ___RedBlackTreeBase {

  @inlinable @inline(__always)
  func ___contains(_ __k: _Key) -> Bool where _Key: Equatable {
    _tree_.__count_unique(__k) != 0
  }
}

extension ___RedBlackTreeBase {

  @inlinable @inline(__always)
  func ___min() -> Element? {
    _tree_.__root() == .nullptr ? nil : _tree_[_tree_.__tree_min(_tree_.__root())]
  }

  @inlinable @inline(__always)
  func ___max() -> Element? {
    _tree_.__root() == .nullptr ? nil : _tree_[_tree_.__tree_max(_tree_.__root())]
  }
}

extension ___RedBlackTreeBase {

  @inlinable @inline(__always)
  func ___value_for(_ __k: _Key) -> Element? {
    let __ptr = _tree_.find(__k)
    return ___is_null_or_end(__ptr) ? nil : _tree_[__ptr]
  }
}

extension ___RedBlackTreeBase {

  @inlinable
  public func ___first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
    var result: Element?
    try _tree_.___for_each(__p: _tree_.__begin_node, __l: _tree_.__end_node()) { __p, cont in
      if try predicate(_tree_[__p]) {
        result = _tree_[__p]
        cont = false
      }
    }
    return result
  }
}

extension ___RedBlackTreeBase {

  @inlinable
  public func ___tree_invariant() -> Bool {
    _tree_.__tree_invariant(_tree_.__root())
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
  public mutating func ___erase(_ ptr: _NodePtr) -> _NodePtr {
    _tree_.erase(ptr)
  }

  // C++風の削除コードが書きたい場合にこっそり(!?)つかうもの
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func ___std_erase(_ ptr: RawIndex) -> RawIndex {
    _tree_.makeRawIndex(rawValue: _tree_.erase(ptr.rawValue))
  }

  // C++風の削除コードが書きたい場合にこっそり(!?)つかうもの
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func ___std_erase(_ ptr: Index) -> Index {
    //    Tree.___Iterator(__tree: _tree, rawValue: _tree.erase(ptr.rawValue))
    _tree_.makeIndex(rawValue: _tree_.erase(ptr.rawValue))
  }
}

extension ___RedBlackTreeBase {

  @inlinable
  @inline(__always)
  public var ___key_comp: (_Key, _Key) -> Bool {
    _tree_.value_comp
  }

  @inlinable
  @inline(__always)
  public var ___value_comp: (Element, Element) -> Bool {
    { _tree_.value_comp(_tree_.__key($0), _tree_.__key($1)) }
  }
}

//extension ___RedBlackTreeBase {
//  
//  func ___convert(_ rawIndex: RawIndex) -> Index {
//    _tree_.makeIndex(rawValue: rawIndex.rawValue)
//  }
//  
//  func ___convert(_ rawIndex: Index) -> RawIndex {
//    _tree_.makeRawIndex(rawValue: rawIndex.rawValue)
//  }
//}

extension ___RedBlackTreeBase {
  
  @inlinable
  @inline(__always)
  public mutating func ___element(at ptr: _NodePtr) -> Element? {
    guard
      !___is_null_or_end(ptr),
      _tree_.___is_valid_index(ptr)
    else {
      return nil
    }
    return _tree_[ptr]
  }
  
  @inlinable
  @inline(__always)
  public __consuming func ___makeIterator() -> NodeIterator<Tree> {
    NodeIterator(tree: _tree_, start: _tree_.__begin_node, end: _tree_.__end_node())
  }
  
  @inlinable
  @inline(__always)
  public __consuming func ___makeIterator() -> NodeElementIterator<Tree> {
    NodeElementIterator(tree: _tree_, start: _tree_.__begin_node, end: _tree_.__end_node())
  }
}
