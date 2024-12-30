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
  public typealias Tree = ___RedBlackTree.___Tree<Self>
}

@usableFromInline
protocol ___RedBlackTreeBase: ValueComparer {
  associatedtype Element
  var tree: Tree { get set }
}

extension ___RedBlackTreeBase {

  @inlinable
  public mutating func ___checkUnique() -> Bool {
    Tree._isKnownUniquelyReferenced(tree: &tree)
  }

  @inlinable
  public mutating func ensureUnique() {
    Tree.ensureUnique(tree: &tree)
  }

  @inlinable
  mutating func ensureUniqueAndCapacity(minimumCapacity: Int) {
    Tree.ensureUniqueAndCapacity(tree: &tree, minimumCapacity: minimumCapacity)
  }

  @inlinable
  mutating func ensureUniqueAndCapacity() {
    Tree.ensureUniqueAndCapacity(tree: &tree)
  }
}

extension ___RedBlackTreeBase {

  @inlinable @inline(__always)
  public var ___count: Int {
    tree.count
  }

  @inlinable @inline(__always)
  public var ___isEmpty: Bool {
    tree.count == 0
  }

  @inlinable @inline(__always)
  public var ___capacity: Int {
    // tree.capacityはバイトサイズになるので注意
    tree.header.capacity
  }
}

// MARK: - Index

extension ___RedBlackTreeBase {

  @usableFromInline
  typealias ___Index = Tree.TreePointer
  
  @inlinable @inline(__always)
  func ___index(_ p: _NodePtr) -> ___Index {
    .init(__tree: tree, pointer: p)
  }
  
  @inlinable @inline(__always)
  func ___index_or_nil(_ p: _NodePtr) -> ___Index? {
    p == .nullptr ? nil : ___index(p)
  }

  @inlinable @inline(__always)
  func ___index_or_nil(_ p: _NodePtr?) -> ___Index? {
    p.map{ ___index($0) }
  }

  @inlinable @inline(__always)
  func ___index_start() -> ___Index {
    ___index(tree.___begin())
  }

  @inlinable @inline(__always)
  func ___index_end() -> ___Index {
    ___index(tree.___end())
  }
  
  @inlinable @inline(__always)
  func ___ptr_start() -> _NodePtr {
    tree.___begin()
  }

  @inlinable @inline(__always)
  func ___ptr_end() -> _NodePtr {
    tree.___end()
  }
}

extension ___RedBlackTreeBase {

  @inlinable @inline(__always)
  public func ___ptr_lower_bound(_ __k: _Key) -> _NodePtr {
    tree.lower_bound(__k)
  }

  @inlinable @inline(__always)
  public func ___ptr_upper_bound(_ __k: _Key) -> _NodePtr {
    tree.upper_bound(__k)
  }
  
  @inlinable @inline(__always)
  public func ___index_lower_bound(_ __k: _Key) -> ___Index {
    ___index(___ptr_lower_bound(__k))
  }

  @inlinable @inline(__always)
  public func ___index_upper_bound(_ __k: _Key) -> ___Index {
    ___index(___ptr_upper_bound(__k))
  }
}

extension ___RedBlackTreeBase {

  @inlinable @inline(__always)
  func ___index(before i: _NodePtr) -> ___Index {
    ___index(tree.index(before: i))
  }

  @inlinable @inline(__always)
  func ___index(after i: _NodePtr) -> ___Index {
    ___index(tree.index(after: i))
  }
}

extension ___RedBlackTreeBase {

  @inlinable
  @inline(__always)
  func ___index(_ i: _NodePtr, offsetBy distance: Int) -> ___Index {
    ___index(tree.index(i, offsetBy: distance))
  }

  @inlinable
  func ___index(
    _ i: _NodePtr, offsetBy distance: Int, limitedBy limit: _NodePtr) -> ___Index? {
    ___index_or_nil(tree.index(i, offsetBy: distance, limitedBy: limit))
  }
}

extension ___RedBlackTreeBase {

  @inlinable
  public func ___first_index(of member: _Key) -> ___Index? {
    var __parent = _NodePtr.nullptr
    let ptr = tree.__ref_(tree.__find_equal(&__parent, member))
    return ___index_or_nil(ptr)
  }

  @inlinable
  public func ___first_index(where predicate: (Element) throws -> Bool) rethrows -> ___Index? {
    var result: ___Index?
    try tree.___for_each(__p: tree.__begin_node, __l: tree.__end_node()) { __p, cont in
      if try predicate(tree[__p]) {
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
  public func ___distance(from start: _NodePtr, to end: _NodePtr) -> Int {
    tree.___signed_distance(start, end)
  }
}

// MARK: - Remove

extension ___RedBlackTreeBase {

  @inlinable
  @inline(__always)
  @discardableResult
  mutating func ___remove(at ptr: _NodePtr) -> Element? {
    guard
      // 下二つのコメントアウトと等価
      0 <= ptr,
      // ptr != .nullptr,
      // ptr != .end,
      tree.___is_valid(ptr)
      //        ___nodes[ptr].isValid
    else {
      return nil
    }
    let e = tree[ptr]
    _ = tree.erase(ptr)
    return e
  }

  @inlinable
  @inline(__always)
  @discardableResult
  mutating func ___remove(from: _NodePtr, to: _NodePtr) -> _NodePtr {
    guard from != .end else {
      return .end
    }
    guard tree.___is_valid(from), to == .end || tree.___is_valid(to) else {
      fatalError(.invalidIndex)
    }
    return tree.erase(from, to)
  }

  @inlinable
  @inline(__always)
  public mutating func ___remove(from: _NodePtr, to: _NodePtr, forEach action: (Element) throws -> Void)
    rethrows
  {
    guard from != .end else {
      return
    }
    guard tree.___is_valid(from), to == .end || tree.___is_valid(to) else {
      fatalError(.invalidIndex)
    }
    return try tree.___erase(from, to, action)
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
    guard tree.___is_valid(from), to == .end || tree.___is_valid(to) else {
      fatalError(.invalidIndex)
    }
    return try tree.___erase(from, to, into: initialResult, updateAccumulatingResult)
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
    guard tree.___is_valid(from), to == .end || tree.___is_valid(to) else {
      fatalError(.invalidIndex)
    }
    return try tree.___erase(from, to, initialResult, nextPartialResult)
  }
}

extension ___RedBlackTreeBase {

  @inlinable
  mutating func ___removeAll(keepingCapacity keepCapacity: Bool = false) {

    if keepCapacity {
      tree.__eraseAll()
    } else {
      tree = .create(withCapacity: 0)
    }
  }
}

// MARK: - Equatable

extension ___RedBlackTreeBase {

  @inlinable
  func ___equal_with(_ rhs: Self) -> Bool where Self: Sequence, Element: Equatable {
    tree === rhs.tree ||
    (___count == rhs.___count && zip(self, rhs).allSatisfy(==))
  }

  @inlinable
  func ___equal_with<K, V>(_ rhs: Self) -> Bool
  where Self: Sequence, K: Equatable, V: Equatable, Element == (key: K, value: V) {
    tree === rhs.tree ||
    (___count == rhs.___count && zip(self, rhs).allSatisfy(==))
  }
}

// MARK: - Etc

extension ___RedBlackTreeBase {

  @inlinable @inline(__always)
  func ___contains(_ __k: _Key) -> Bool where _Key: Equatable {
    tree.__count_multi(__k: __k) != 0
  }
}

extension ___RedBlackTreeBase {

  @inlinable @inline(__always)
  func ___min() -> Element? {
    tree.__root() == .nullptr ? nil : tree[tree.__tree_min(tree.__root())]
  }

  @inlinable @inline(__always)
  func ___max() -> Element? {
    tree.__root() == .nullptr ? nil : tree[tree.__tree_max(tree.__root())]
  }
}

extension ___RedBlackTreeBase {

  @inlinable @inline(__always)
  func ___value_for(_ __k: _Key) -> Element? {
    let __ptr = tree.find(__k)
    return __ptr < 0 ? nil : tree[__ptr]
  }
}

extension ___RedBlackTreeBase {

  @inlinable
  public func ___first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
    var result: Element?
    try tree.___for_each(__p: tree.__begin_node, __l: tree.__end_node()) { __p, cont in
      if try predicate(tree[__p]) {
        result = tree[__p]
        cont = false
      }
    }
    return result
  }
}
