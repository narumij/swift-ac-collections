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
protocol NewContainer: ValueComparer {
  associatedtype Element
  var tree: Tree { get set }
}

extension NewContainer {
  public typealias Tree = ___RedBlackTree.___Buffer<Self, Element>
}

extension NewContainer {

  @inlinable
  mutating func ensureUnique() {
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

extension NewContainer {

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
    tree.header.capacity
  }

  @inlinable @inline(__always)
  public func ___begin() -> _NodePtr {
    tree.__begin_node
  }

  @inlinable @inline(__always)
  public func ___end() -> _NodePtr {
    .end
  }
}

// MARK: - Index

extension NewContainer {

  @usableFromInline
  typealias ___Index = ___RedBlackTree.Index

  @inlinable @inline(__always)
  func ___index_begin() -> ___Index {
    ___Index(tree.___begin())
  }

  @inlinable @inline(__always)
  func ___index_end() -> ___Index {
    ___Index(tree.___end())
  }
}

extension NewContainer {

  @inlinable @inline(__always)
  func ___index_lower_bound(_ __k: _Key) -> ___Index {
    ___Index(tree.__lower_bound(__k, tree.__root(), .end))
  }

  @inlinable @inline(__always)
  func ___index_upper_bound(_ __k: _Key) -> ___Index {
    ___Index(tree.__upper_bound(__k, tree.__root(), .end))
  }
}

extension NewContainer {

  @inlinable @inline(__always)
  func ___index_prev(_ i: ___Index) -> ___Index {
    let i = i.pointer
    guard i != tree.__begin_node, i == tree.__end_node() || tree.___is_valid(i) else {
      fatalError(.invalidIndex)
    }
    return ___Index(tree.__tree_prev_iter(i))
  }

  @inlinable @inline(__always)
  func ___index_next(_ i: ___Index) -> ___Index {
    let i = i.pointer
    guard i != tree.__end_node(), tree.___is_valid(i) else {
      fatalError(.invalidIndex)
    }
    return ___Index(tree.__tree_next_iter(i))
  }
}

extension NewContainer {

  @inlinable
  func ___index(_ i: ___Index, offsetBy distance: Int, type: String) -> ___Index {
    ___Index(pointer(i.pointer, offsetBy: distance))
  }

  @inlinable
  func ___index(
    _ i: ___Index, offsetBy distance: Int, limitedBy limit: ___Index, type: String
  ) -> ___Index? {
    ___Index?(
      pointer(
        i.pointer, offsetBy: distance, limitedBy: limit.pointer))
  }

  @inlinable
  @inline(__always)
  func pointer(
    _ ptr: _NodePtr, offsetBy distance: Int, limitedBy limit: _NodePtr? = .none
  ) -> _NodePtr {
    guard ptr == tree.___end() || tree.___is_valid(ptr) else {
      fatalError(.invalidIndex)
    }
    return distance > 0
      ? pointer(ptr, nextBy: UInt(distance), limitedBy: limit)
      : pointer(ptr, prevBy: UInt(abs(distance)), limitedBy: limit)
  }

  @inlinable
  @inline(__always)
  func pointer(
    _ ptr: _NodePtr, prevBy distance: UInt, limitedBy limit: _NodePtr? = .none
  ) -> _NodePtr {
    var ptr = ptr
    var distance = distance
    while distance != 0, ptr != limit {
      // __begin_nodeを越えない
      guard ptr != tree.__begin_node else {
        fatalError(.outOfBounds)
      }
      ptr = tree.__tree_prev_iter(ptr)
      distance -= 1
    }
    guard distance == 0 else {
      return .nullptr
    }
    assert(ptr != .nullptr)
    return ptr
  }

  @inlinable
  @inline(__always)
  func pointer(
    _ ptr: _NodePtr, nextBy distance: UInt, limitedBy limit: _NodePtr? = .none
  ) -> _NodePtr {
    var ptr = ptr
    var distance = distance
    while distance != 0, ptr != limit {
      // __end_node()を越えない
      guard ptr != tree.__end_node() else {
        fatalError(.outOfBounds)
      }
      ptr = tree.__tree_next_iter(ptr)
      distance -= 1
    }
    guard distance == 0 else {
      return .nullptr
    }
    assert(ptr != .nullptr)
    return ptr
  }
}

extension NewContainer {

  @inlinable
  public func ___first_index(of member: _Key) -> ___Index? {
    var __parent = _NodePtr.nullptr
    let ptr = tree.__ref_(tree.__find_equal(&__parent, member))
    return ___Index?(ptr)
  }

  @inlinable
  public func ___first_index(where predicate: (Element) throws -> Bool) rethrows -> ___Index? {
    var result: ___Index?
    try tree.___for_each(__p: tree.__begin_node, __l: tree.__end_node()) { __p, cont in
      if try predicate(___elements(__p)) {
        result = ___Index(__p)
        cont = false
      }
    }
    return result
  }
}

extension NewContainer {

  @inlinable
  public func ___distance(from start: ___Index, to end: ___Index) -> Int {
    tree.distance(__l: start.pointer, __r: end.pointer)
  }
}

// MARK: - Sequence

extension NewContainer {

  public typealias EnumeratedElement = (position: ___Index, element: Element)
}

extension NewContainer {

  // TODO: ひとだんらくしたら、inline化して取り除く
  @inlinable func ___elements(_ p: _NodePtr) -> Element {
    tree[p].__value_
  }

  public typealias ___EnumeratedSequence = UnfoldSequence<EnumeratedElement, Tree.SafeSequenceState>

  @inlinable
  public func ___enumerated_sequence(from: ___Index, to: ___Index)
    -> ___EnumeratedSequence
  {
    return sequence(state: tree.___begin(from.pointer, to: to.pointer)) { state in
      guard tree.___end(state) else { return nil }
      defer { tree.___next(&state) }
      return (___Index(state.current), ___elements(state.current))
    }
  }
  
  @inlinable
  public func ___enumerated_sequence__(from: ___Index, to: ___Index)
    -> [EnumeratedElement]
  {
    var result = [EnumeratedElement]()
    tree.___for_each(__p: from.pointer, __l: to.pointer) { __p, _ in
      result.append((___Index(__p), ___elements(__p)))
    }
    return result
  }

  @inlinable @inline(__always)
  public var ___enumerated_sequence__: [EnumeratedElement] {
    ___enumerated_sequence__(from: ___index_begin(), to: ___index_end())
  }

  @inlinable
  public func ___element_sequence__<T>(
    from: ___Index, to: ___Index, transform: (Element) throws -> T
  )
    rethrows -> [T]
  {
    var result = [T]()
    try tree.___for_each(__p: from.pointer, __l: to.pointer) { __p, _ in
      result.append(try transform(___elements(__p)))
    }
    return result
  }

  @inlinable
  public func ___element_sequence__(
    from: ___Index, to: ___Index, isIncluded: (Element) throws -> Bool
  )
    rethrows -> [Element]
  {
    var result = [Element]()
    try tree.___for_each(__p: from.pointer, __l: to.pointer) { __p, _ in
      if try isIncluded(___elements(__p)) {
        result.append(___elements(__p))
      }
    }
    return result
  }

  @inlinable
  public func ___element_sequence__<T>(
    from: ___Index, to: ___Index, _ initial: T, _ folding: (T, Element) throws -> T
  )
    rethrows -> T
  {
    var result = initial
    try tree.___for_each(__p: from.pointer, __l: to.pointer) { __p, _ in
      result = try folding(result, ___elements(__p))
    }
    return result
  }

  @inlinable
  public func ___element_sequence__<T>(
    from: ___Index, to: ___Index, into initial: T, _ folding: (inout T, Element) throws -> Void
  )
    rethrows -> T
  {
    var result = initial
    try tree.___for_each(__p: from.pointer, __l: to.pointer) { __p, _ in
      try folding(&result, ___elements(__p))
    }
    return result
  }

  @inlinable
  public func ___element_sequence__(from: ___Index, to: ___Index)
    -> [Element]
  {
    var result = [Element]()
    tree.___for_each(__p: from.pointer, __l: to.pointer) { __p, _ in
      result.append(___elements(__p))
    }
    return result
  }

  @inlinable
  public func ___element_sequence__<T>(_ transform: (Element) throws -> T)
    rethrows -> [T]
  {
    try ___element_sequence__(from: ___index_begin(), to: ___index_end(), transform: transform)
  }

  @inlinable @inline(__always)
  public var ___element_sequence__: [Element] {
    ___element_sequence__(from: ___index_begin(), to: ___index_end())
  }
}

extension NewContainer {
  @inlinable @inline(__always)
  public var ___ptr_sequence__: [_NodePtr] {
    var result = [_NodePtr]()
    tree.___for_each(__p: tree.__begin_node, __l: tree.__end_node()) { __p, _ in
      result.append(__p)
    }
    return result
  }
}

// MARK: - Remove

extension NewContainer {

  @inlinable
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
    let e = ___elements(ptr)
    ensureUnique()
    _ = tree.erase(ptr)
    return e
  }

  @inlinable
  @discardableResult
  mutating func ___remove(from: _NodePtr, to: _NodePtr) -> _NodePtr {
    guard from != .end else {
      return .end
    }
    guard tree.___is_valid(from), to == .end || tree.___is_valid(to) else {
      fatalError(.invalidIndex)
    }
    ensureUnique()
    return tree.erase(from, to)
  }

  @inlinable
  mutating func ___remove(from: _NodePtr, to: _NodePtr, forEach action: (Element) throws -> Void)
    rethrows
  {
    guard from != .end else {
      return
    }
    guard tree.___is_valid(from), to == .end || tree.___is_valid(to) else {
      fatalError(.invalidIndex)
    }
    ensureUnique()
    return try tree.___erase(from, to, action)
  }

  @inlinable
  mutating func ___remove<Result>(
    from: _NodePtr, to: _NodePtr, into initialResult: Result,
    _ updateAccumulatingResult: (inout Result, Element) throws -> Void
  ) rethrows -> Result {
    guard from != .end else {
      return initialResult
    }
    guard tree.___is_valid(from), to == .end || tree.___is_valid(to) else {
      fatalError(.invalidIndex)
    }
    ensureUnique()
    return try tree.___erase(from, to, into: initialResult, updateAccumulatingResult)
  }

  @inlinable
  mutating func ___remove<Result>(
    from: _NodePtr, to: _NodePtr, _ initialResult: Result,
    _ nextPartialResult: (Result, Element) throws -> Result
  ) rethrows -> Result {
    guard from != .end else {
      return initialResult
    }
    guard tree.___is_valid(from), to == .end || tree.___is_valid(to) else {
      fatalError(.invalidIndex)
    }
    ensureUnique()
    return try tree.___erase(from, to, initialResult, nextPartialResult)
  }

  @inlinable
  public mutating func ___remove(
    from: ___Index, to: ___Index, forEach action: (Element) throws -> Void
  ) rethrows {
    try ___remove(from: from.pointer, to: to.pointer, forEach: action)
  }

  @inlinable
  public mutating func ___remove<Result>(
    from: ___Index, to: ___Index, into initialResult: Result,
    _ updateAccumulatingResult: (inout Result, Element) throws -> Void
  ) rethrows -> Result {
    try ___remove(from: from.pointer, to: to.pointer, into: initialResult, updateAccumulatingResult)
  }

  @inlinable
  public mutating func ___remove<Result>(
    from: ___Index, to: ___Index, _ initialResult: Result,
    _ nextPartialResult: (Result, Element) throws -> Result
  ) rethrows -> Result {
    try ___remove(from: from.pointer, to: to.pointer, initialResult, nextPartialResult)
  }
}

extension NewContainer {

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

extension NewContainer {

  @inlinable
  func ___equal_with(_ rhs: Self) -> Bool where Element: Equatable {
    ___count == rhs.___count && zip(___element_sequence__, rhs.___element_sequence__).allSatisfy(==)
  }

  @inlinable
  func ___equal_with<K, V>(_ rhs: Self) -> Bool
  where K: Equatable, V: Equatable, Element == (key: K, value: V) {
    ___count == rhs.___count && zip(___element_sequence__, rhs.___element_sequence__).allSatisfy(==)
  }
}

// MARK: - Etc

extension NewContainer {

  @inlinable @inline(__always)
  func ___contains(_ __k: _Key) -> Bool where _Key: Equatable {
    let it = tree.__lower_bound(__k, tree.__root(), tree.__left_)
    guard it >= 0 else { return false }
    return Self.__key(___elements(it)) == __k
  }
}

extension NewContainer {

  @inlinable @inline(__always)
  func ___min() -> Element? {
    tree.__root() == .nullptr ? nil : tree.___element(tree.__tree_min(tree.__root()))
  }

  @inlinable @inline(__always)
  func ___max() -> Element? {
    tree.__root() == .nullptr ? nil : tree.___element(tree.__tree_max(tree.__root()))
  }
}

extension NewContainer {

  @inlinable @inline(__always)
  func ___value_for(_ __k: _Key) -> Element? {
    let __ptr = tree.find(__k)
    return __ptr < 0 ? nil : ___elements(__ptr)
  }
}

extension NewContainer {

  @inlinable
  public func ___first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
    var result: Element?
    try tree.___for_each(__p: tree.__begin_node, __l: tree.__end_node()) { __p, cont in
      if try predicate(___elements(__p)) {
        result = ___elements(__p)
        cont = false
      }
    }
    return result
  }
}

// MARK: - InitializeHelper

//extension NewContainer {
//  public struct Iterator: IteratorProtocol {
//    @usableFromInline
//    internal init(it: Tree.Iterator) {
//      self.it = it
//    }
//    var it: Tree.Iterator
//    public mutating func next() -> Element? {
//      it.next()
//    }
//  }
//  @inlinable public func makeIterator() -> Iterator {
//    .init(it: tree.makeIterator())
//  }
//}

