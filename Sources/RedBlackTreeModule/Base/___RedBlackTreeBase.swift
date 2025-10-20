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

@usableFromInline
protocol ___RedBlackTreeIndexing {
  associatedtype Index
  func ___index(_ rawValue: _NodePtr) -> Index
  func ___index_or_nil(_ p: _NodePtr?) -> Index?
}

// コレクションの内部実装
@usableFromInline
protocol ___RedBlackTreeBase:
  ___RedBlackTree___,
  ___TreeBase
where
  Tree == ___Tree<Self>,
  Storage == ___Storage<Self>
{
  associatedtype _Value
  associatedtype Storage
  var _storage: Tree.Storage { get set }
}

extension ___RedBlackTreeBase {

  @inlinable
  var __tree_: Tree {
    @inline(__always) _read {
      yield _storage.tree
    }
  }
}

extension ___RedBlackTreeBase {

  @inlinable
  @inline(__always)
  var ___count: Int {
    __tree_.count
  }

  @inlinable
  @inline(__always)
  var ___is_empty: Bool {
    __tree_.___is_empty
  }

  @inlinable
  @inline(__always)
  var ___capacity: Int {
    __tree_.___capacity
  }
}

// MARK: - Index

extension ___RedBlackTreeBase {

  @usableFromInline
  typealias Index = Tree.Index

  @inlinable
  @inline(__always)
  func ___index(_ p: _NodePtr) -> Index {
    __tree_.makeIndex(rawValue: p)
  }

  @inlinable
  @inline(__always)
  func ___index_or_nil(_ p: _NodePtr) -> Index? {
    p == .nullptr ? nil : ___index(p)
  }

  @inlinable
  @inline(__always)
  func ___index_or_nil(_ p: _NodePtr?) -> Index? {
    p.map { ___index($0) }
  }
}

extension ___RedBlackTreeBase {

  @inlinable
  @inline(__always)
  public func ___start() -> _NodePtr {
    __tree_.__begin_node_
  }

  @inlinable
  @inline(__always)
  public func ___end() -> _NodePtr {
    __tree_.___end()
  }

  @inlinable
  @inline(__always)
  func ___index_start() -> Index {
    ___index(__tree_.__begin_node_)
  }

  @inlinable
  @inline(__always)
  func ___index_end() -> Index {
    ___index(__tree_.___end())
  }
}

extension ___RedBlackTreeBase {

  @inlinable
  @inline(__always)
  func ___contains(_ __k: _Key) -> Bool {
    __tree_.__count_unique(__k) != 0
  }
}

extension ___RedBlackTreeBase {

  @inlinable
  @inline(__always)
  func ___min() -> _Value? {
    __tree_.__root() == .nullptr ? nil : __tree_[__tree_.__tree_min(__tree_.__root())]
  }

  @inlinable
  @inline(__always)
  func ___max() -> _Value? {
    __tree_.__root() == .nullptr ? nil : __tree_[__tree_.__tree_max(__tree_.__root())]
  }
}

extension ___RedBlackTreeBase {

  @inlinable
  @inline(__always)
  public func ___lower_bound(_ __k: _Key) -> _NodePtr {
    __tree_.lower_bound(__k)
  }

  @inlinable
  @inline(__always)
  public func ___upper_bound(_ __k: _Key) -> _NodePtr {
    __tree_.upper_bound(__k)
  }

  @inlinable
  @inline(__always)
  func ___index_lower_bound(_ __k: _Key) -> Index {
    ___index(___lower_bound(__k))
  }

  @inlinable
  @inline(__always)
  func ___index_upper_bound(_ __k: _Key) -> Index {
    ___index(___upper_bound(__k))
  }
}

extension ___RedBlackTreeBase {

  @inlinable
  @inline(__always)
  var ___first: _Value? {
    ___is_empty ? nil : __tree_[__tree_.__begin_node_]
  }

  @inlinable
  @inline(__always)
  var ___last: _Value? {
    ___is_empty ? nil : __tree_[__tree_.__tree_prev_iter(__tree_.__end_node())]
  }
}

extension ___RedBlackTreeBase {

  @inlinable
  @inline(__always)
  func ___first_index(of member: _Key) -> Index? {
    let ptr = __tree_.__ptr_(__tree_.__find_equal(member).__child)
    return ___index_or_nil(ptr)
  }

  @inlinable
  @inline(__always)
  func ___first_index(where predicate: (_Value) throws -> Bool) rethrows -> Index? {
    var result: Index?
    try __tree_.___for_each(__p: __tree_.__begin_node_, __l: __tree_.__end_node()) { __p, cont in
      if try predicate(__tree_[__p]) {
        result = ___index(__p)
        cont = false
      }
    }
    return result
  }
}

extension ___RedBlackTreeBase {

  @inlinable
  @inline(__always)
  public func ___first(where predicate: (_Value) throws -> Bool) rethrows -> _Value? {
    var result: _Value?
    try __tree_.___for_each(__p: __tree_.__begin_node_, __l: __tree_.__end_node()) { __p, cont in
      if try predicate(__tree_[__p]) {
        result = __tree_[__p]
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
  public mutating func ___remove(at ptr: _NodePtr) -> _Value? {
    guard !__tree_.___is_subscript_null(ptr) else {
      return nil
    }
    let e = __tree_[ptr]
    _ = __tree_.erase(ptr)
    return e
  }

  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func ___remove(from: _NodePtr, to: _NodePtr) -> _NodePtr {
    guard !__tree_.___is_end(from) else {
      return .end
    }
    __tree_.___ensureValidRange(begin: from, end: to)
    return __tree_.erase(from, to)
  }

  @inlinable
  @inline(__always)
  public mutating func ___remove(
    from: _NodePtr, to: _NodePtr, forEach action: (_Value) throws -> Void
  )
    rethrows
  {
    guard !__tree_.___is_end(from) else {
      return
    }
    __tree_.___ensureValidRange(begin: from, end: to)
    return try __tree_.___erase(from, to, action)
  }

  @inlinable
  @inline(__always)
  public mutating func ___remove<Result>(
    from: _NodePtr, to: _NodePtr,
    into initialResult: Result,
    _ updateAccumulatingResult: (inout Result, _Value) throws -> Void
  ) rethrows -> Result {
    guard !__tree_.___is_end(from) else {
      return initialResult
    }
    __tree_.___ensureValidRange(begin: from, end: to)
    return try __tree_.___erase(from, to, into: initialResult, updateAccumulatingResult)
  }

  @inlinable
  @inline(__always)
  public mutating func ___remove<Result>(
    from: _NodePtr, to: _NodePtr,
    _ initialResult: Result,
    _ nextPartialResult: (Result, _Value) throws -> Result
  ) rethrows -> Result {
    guard !__tree_.___is_end(from) else {
      return initialResult
    }
    __tree_.___ensureValidRange(begin: from, end: to)
    return try __tree_.___erase(from, to, initialResult, nextPartialResult)
  }
}

extension ___RedBlackTreeBase {

  @inlinable
  @inline(__always)
  mutating func ___removeAll(keepingCapacity keepCapacity: Bool = false) {

    if keepCapacity {
      __tree_.__eraseAll()
    } else {
      _storage = .create(withCapacity: 0)
    }
  }
}

// MARK: - Etc

extension ___RedBlackTreeBase {

  @inlinable
  @inline(__always)
  func ___value_for(_ __k: _Key) -> _Value? {
    let __ptr = __tree_.find(__k)
    return ___is_null_or_end(__ptr) ? nil : __tree_[__ptr]
  }
}

extension ___RedBlackTreeBase {

  /// releaseビルドでは無効化されています
  @inlinable
  @inline(__always)
  public func ___tree_invariant() -> Bool {
    __tree_.__tree_invariant(__tree_.__root())
  }

  #if AC_COLLECTIONS_INTERNAL_CHECKS
    public var _copyCount: UInt {
      get { _storage.tree.copyCount }
      set { _storage.tree.copyCount = newValue }
    }
  #endif
}

#if AC_COLLECTIONS_INTERNAL_CHECKS
  extension ___RedBlackTreeCopyOnWrite {
    public mutating func _checkUnique() -> Bool {
      _isKnownUniquelyReferenced_LV2()
    }
  }
#endif

extension ___RedBlackTreeBase {

  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func ___erase(_ ptr: _NodePtr) -> _NodePtr {
    __tree_.erase(ptr)
  }

  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func ___erase(_ ptr: Index) -> Index {
    ___index(__tree_.erase(ptr.rawValue))
  }
}

extension ___RedBlackTreeBase {

  @inlinable
  @inline(__always)
  public var ___key_comp: (_Key, _Key) -> Bool {
    __tree_.value_comp
  }

  @inlinable
  @inline(__always)
  public var ___value_comp: (_Value, _Value) -> Bool {
    { __tree_.value_comp(Self.__key($0), Self.__key($1)) }
  }
}

extension ___RedBlackTreeBase {

  @inlinable
  @inline(__always)
  public func ___prev(_ i: _NodePtr) -> _NodePtr {
    __tree_.__tree_prev_iter(i)
  }

  @inlinable
  @inline(__always)
  public func ___next(_ i: _NodePtr) -> _NodePtr {
    __tree_.__tree_next_iter(i)
  }

  @inlinable
  @inline(__always)
  public func ___advanced(_ i: _NodePtr, by distance: Int) -> _NodePtr {
    __tree_.___tree_adv_iter(i, by: distance)
  }
}

extension ___RedBlackTreeBase {

  @inlinable
  @inline(__always)
  public func ___is_valid(_ index: _NodePtr) -> Bool {
    !__tree_.___is_subscript_null(index)
  }

  @inlinable
  @inline(__always)
  public func ___is_valid_range(_ p: _NodePtr, _ l: _NodePtr) -> Bool {
    !__tree_.___is_range_null(p, l)
  }

  @inlinable
  @inline(__always)
  public func ___is_garbaged(_ index: _NodePtr) -> Bool {
    __tree_.___is_garbaged(index)
  }
}
