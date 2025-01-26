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
  typealias ___Index = Tree.Pointer

  @inlinable @inline(__always)
  func ___index(_ p: _NodePtr) -> ___Index {
    .init(__tree: _tree, pointer: p)
  }

  @inlinable @inline(__always)
  func ___index_or_nil(_ p: _NodePtr) -> ___Index? {
    p == .nullptr ? nil : ___index(p)
  }

  @inlinable @inline(__always)
  func ___index_or_nil(_ p: _NodePtr?) -> ___Index? {
    p.map { ___index($0) }
  }

  @inlinable @inline(__always)
  func ___index_start() -> ___Index {
    ___index(_tree.___begin())
  }

  @inlinable @inline(__always)
  func ___index_end() -> ___Index {
    ___index(_tree.___end())
  }

  @inlinable @inline(__always)
  public func ___ptr_start() -> _NodePtr {
    _tree.___begin()
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
    ___index(_tree.index(before: i))
  }

  @inlinable @inline(__always)
  func ___index(after i: _NodePtr) -> ___Index {
    ___index(_tree.index(after: i))
  }

  @inlinable @inline(__always)
  public func ___form_index(before i: inout _NodePtr) {
    _tree.formIndex(before: &i)
  }

  @inlinable @inline(__always)
  public func ___form_index(after i: inout _NodePtr) {
    _tree.formIndex(after: &i)
  }
}

extension ___RedBlackTreeBase {

  @inlinable @inline(__always)
  func ___index(_ i: _NodePtr, offsetBy distance: Int) -> ___Index {
    ___index(_tree.index(i, offsetBy: distance))
  }

  @inlinable @inline(__always)
  func ___index(
    _ i: _NodePtr, offsetBy distance: Int, limitedBy limit: _NodePtr
  ) -> ___Index? {
    ___index_or_nil(_tree.index(i, offsetBy: distance, limitedBy: limit))
  }

  @inlinable @inline(__always)
  public func ___form_index(_ i: inout _NodePtr, offsetBy distance: Int) {
    _tree.formIndex(&i, offsetBy: distance)
  }

  @inlinable @inline(__always)
  public func ___form_index(_ i: inout _NodePtr, offsetBy distance: Int, limitedBy limit: _NodePtr)
    -> Bool
  {
    _tree.formIndex(&i, offsetBy: distance, limitedBy: limit)
  }
}

extension ___RedBlackTreeBase {

  @inlinable
  func ___first_index(of member: _Key) -> ___Index? {
    var __parent = _NodePtr.nullptr
    let ptr = _tree.__ptr_(_tree.__find_equal(&__parent, member))
    return ___index_or_nil(ptr)
  }

  @inlinable
  func ___first_index(where predicate: (Element) throws -> Bool) rethrows -> ___Index? {
    var result: ___Index?
    try _tree.___for_each(__p: _tree.__begin_node, __l: _tree.__end_node()) { __p, cont in
      if try predicate(_tree[__p]) {
        result = ___index(__p)
        cont = false
      }
    }
    return result
  }
}

extension ___RedBlackTreeBase {

  @inlinable @inline(__always)
  public func ___distance(from start: _NodePtr, to end: _NodePtr) -> Int {
    _tree.___signed_distance(start, end)
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
  extension ___RedBlackTreeStorageLifetime {
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
  public mutating func ___std_erase(_ ptr: Tree.RawPointer) -> Tree.RawPointer {
    Tree.RawPointer(_tree.erase(ptr.rawValue))
  }

  // C++風の削除コードが書きたい場合にこっそり(!?)つかうもの
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func ___std_erase(_ ptr: Tree.Pointer) -> Tree.Pointer {
    Tree.Pointer(__tree: _tree, pointer: _tree.erase(ptr.rawValue))
  }
}

// MARK: -

@usableFromInline
protocol ___RedBlackTreeSubSequenceBase {
  associatedtype Base: ValueComparer
  var _subSequence: Base.Tree.SubSequence { get }
}

extension ___RedBlackTreeSubSequenceBase {
  @inlinable
  @inline(__always)
  internal var _tree: ___Tree { _subSequence._tree }
}

extension ___RedBlackTreeSubSequenceBase {
  
  @usableFromInline
  typealias ___Tree = Base.Tree
  @usableFromInline
  typealias ___Index = Base.Tree.Pointer
  @usableFromInline
  typealias ___SubSequence = Base.Tree.SubSequence
  @usableFromInline
  typealias ___Element = Base.Tree.SubSequence.Element
  
  @inlinable @inline(__always)
  internal var ___start_index: ___Index {
    ___Index(__tree: _tree, pointer: _subSequence.startIndex)
  }

  @inlinable @inline(__always)
  internal var ___end_index: ___Index {
    ___Index(__tree: _tree, pointer: _subSequence.endIndex)
  }

  @inlinable @inline(__always)
  internal var ___count: Int {
    _subSequence.count
  }

  @inlinable @inline(__always)
  internal func ___for_each(_ body: (___Element) throws -> Void) rethrows {
    try _subSequence.forEach(body)
  }

  @inlinable @inline(__always)
  internal func ___distance(from start: ___Index, to end: ___Index) -> Int {
    _subSequence.distance(from: start.rawValue, to: end.rawValue)
  }

  @inlinable @inline(__always)
  internal func ___index(after i: ___Index) -> ___Index {
    ___Index(__tree: _tree, pointer: _subSequence.index(after: i.rawValue))
  }

  @inlinable @inline(__always)
  internal func ___form_index(after i: inout ___Index) {
    _subSequence.formIndex(after: &i.rawValue)
  }

  @inlinable @inline(__always)
  internal func ___index(before i: ___Index) -> ___Index {
    ___Index(__tree: _tree, pointer: _subSequence.index(before: i.rawValue))
  }

  @inlinable @inline(__always)
  internal func ___form_index(before i: inout ___Index) {
    _subSequence.formIndex(before: &i.rawValue)
  }

  @inlinable @inline(__always)
  internal func ___index(_ i: ___Index, offsetBy distance: Int) -> ___Index {
    ___Index(__tree: _tree, pointer: _subSequence.index(i.rawValue, offsetBy: distance))
  }

  @inlinable @inline(__always)
  internal func ___form_index(_ i: inout ___Index, offsetBy distance: Int) {
    _subSequence.formIndex(&i.rawValue, offsetBy: distance)
  }

  @inlinable @inline(__always)
  internal func ___index(_ i: ___Index, offsetBy distance: Int, limitedBy limit: ___Index) -> ___Index? {

    if let i = _subSequence.index(i.rawValue, offsetBy: distance, limitedBy: limit.rawValue) {
      return ___Index(__tree: _tree, pointer: i)
    } else {
      return nil
    }
  }

  @inlinable @inline(__always)
  internal func ___form_index(_ i: inout ___Index, offsetBy distance: Int, limitedBy limit: ___Index)
    -> Bool
  {
    return _subSequence.formIndex(&i.rawValue, offsetBy: distance, limitedBy: limit.rawValue)
  }
}
