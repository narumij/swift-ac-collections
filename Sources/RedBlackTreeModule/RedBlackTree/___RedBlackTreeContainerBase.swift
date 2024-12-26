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

import Collections

// TODO: 整頓

@usableFromInline
protocol ___RedBlackTreeContainerBase: ___RedBlackTreeAllocatorBase, ___RedBlackTreeContainerRead, EndProtocol, ValueComparer {}

extension ___RedBlackTreeContainerBase {

#if false
  @inlinable
  func __ref_(_ rhs: _NodeRef) -> _NodePtr {
    _read { tree in
      tree.__ref_(rhs)
    }
  }
#endif

  @inlinable
  func __find_leaf_high(_ __parent: inout _NodePtr, _ __v: _Key) -> _NodeRef {
    _read { tree in
      tree.__find_leaf_high(&__parent, __v)
    }
  }

  @inlinable
  func __find_equal(_ __parent: inout _NodePtr, _ __v: _Key) -> _NodeRef {
    _read { tree in
      tree.__find_equal(&__parent, __v)
    }
  }

  @inlinable
  func find(_ __v: _Key) -> _NodePtr {
    _read { tree in
      tree.find(__v)
    }
  }

  @inlinable
  func
    __equal_range_multi(_ __k: _Key) -> (_NodePtr, _NodePtr)
  {
    _read { tree in
      tree.__equal_range_multi(__k)
    }
  }
}

extension ___RedBlackTreeContainerBase {
  
  @inlinable @inline(__always)
  func ___value_for(_ __k: _Key) -> Element?
  {
    _read {
      let __ptr = $0.find(__k)
      return __ptr < 0 ? nil : ___elements[__ptr]
    }
  }
}

extension ___RedBlackTreeContainerBase {

  @inlinable @inline(__always)
  func ___contains(_ __k: _Key) -> Bool where _Key: Equatable {
    _read { tree in
      let it = tree.__lower_bound(__k, tree.__root(), tree.__left_)
      guard it >= 0 else { return false }
      return Self.__key(tree.__element_ptr[it]) == __k
    }
  }

  @inlinable @inline(__always)
  func ___min() -> Element? {
    _read { tree in
      tree.__root() == .nullptr ? nil : tree.___element(tree.__tree_min(tree.__root()))
    }
  }

  @inlinable @inline(__always)
  func ___max() -> Element? {
    _read { tree in
      tree.__root() == .nullptr ? nil : tree.___element(tree.__tree_max(tree.__root()))
    }
  }
}

extension ___RedBlackTreeContainerBase {

  @inlinable @inline(__always)
  func ___index_lower_bound(_ __k: _Key) -> ___Index {
    _read { tree in
      ___Index(tree.__lower_bound(__k, tree.__root(), .end))
    }
  }

  @inlinable @inline(__always)
  func ___index_upper_bound(_ __k: _Key) -> ___Index {
    _read { tree in
      ___Index(tree.__upper_bound(__k, tree.__root(), .end))
    }
  }
}

extension ___RedBlackTreeContainerBase {

  @inlinable @inline(__always)
  func ___distance(__last: _NodePtr) -> Int {
    _read { tree in
      tree.distance(__l: tree.__begin_node, __r: __last)
    }
  }
}

extension ___RedBlackTreeContainerBase {

  @inlinable @inline(__always)
  func ___index_prev(_ i: ___Index) -> ___Index {
    let i = i.pointer
    return _read { tree in
      guard i != tree.__begin_node, i == tree.__end_node() || ___is_valid(i) else {
        fatalError(.invalidIndex)
      }
      return ___Index(tree.__tree_prev_iter(i))
    }
  }

  @inlinable @inline(__always)
  func ___index_next(_ i: ___Index) -> ___Index {
    let i = i.pointer
    return _read { tree in
      guard i != tree.__end_node(), ___is_valid(i) else {
        fatalError(.invalidIndex)
      }
      return ___Index(tree.__tree_next_iter(i))
    }
  }
}

extension ___RedBlackTreeContainerBase {

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
    _ ptr: _NodePtr, offsetBy distance: Int, limitedBy limit: _NodePtr? = .none) -> _NodePtr {
    guard ptr == ___end() || ___is_valid(ptr) else {
      fatalError(.invalidIndex)
    }
    return distance > 0
      ? pointer(ptr, nextBy: UInt(distance), limitedBy: limit)
      : pointer(ptr, prevBy: UInt(abs(distance)), limitedBy: limit)
  }

  @inlinable
  @inline(__always)
  func pointer(
    _ ptr: _NodePtr, prevBy distance: UInt, limitedBy limit: _NodePtr? = .none) -> _NodePtr {
    _read { tree in
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
  }

  @inlinable
  @inline(__always)
  func pointer(
    _ ptr: _NodePtr, nextBy distance: UInt, limitedBy limit: _NodePtr? = .none) -> _NodePtr {
    _read { tree in
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
}

extension ___RedBlackTreeContainerBase {
  
  @inlinable
  public func ___distance(from start: ___RedBlackTree.Index, to end: ___RedBlackTree.Index) -> Int {
    _read { $0.distance(__l: start.pointer, __r: end.pointer) }
  }
}

extension ___RedBlackTreeContainerBase {
  
  @inlinable
  public func ___first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
    try _read { tree in
      var result: Element?
      try tree.___for_each(__p: tree.__begin_node, __l: tree.__end_node()) { __p, cont in
        if try predicate(___elements[__p]) {
          result = ___elements[__p]
          cont = false
        }
      }
      return result
    }
  }
  
  @inlinable
  public func ___first_index(of member: _Key) -> ___RedBlackTree.Index? {
    _read { tree in
      var __parent = _NodePtr.nullptr
      let ptr = tree.__ref_(tree.__find_equal(&__parent, member))
      return ___RedBlackTree.Index?(ptr)
    }
  }
  
  @inlinable
  public func ___first_index(where predicate: (Element) throws -> Bool) rethrows -> ___RedBlackTree.Index? {
    try _read { tree in
      var result: ___RedBlackTree.Index?
      try tree.___for_each(__p: tree.__begin_node, __l: tree.__end_node()) { __p, cont in
        if try predicate(___elements[__p]) {
          result = ___RedBlackTree.Index(__p)
          cont = false
        }
      }
      return result
    }
  }
}

extension ___RedBlackTreeContainerBase {

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

extension ___RedBlackTreeContainerBase {

  public typealias SafeSequenceState = (current: _NodePtr, next: _NodePtr, to: _NodePtr)
  public typealias UnsafeSequenceState = (current: _NodePtr, to: _NodePtr)
  public typealias EnumeratedElement = (position: ___RedBlackTree.Index, element: Element)

  @inlinable
  func ___next(_ ptr: _NodePtr, to: _NodePtr) -> _NodePtr {
    ptr == to ? ptr : _read { $0.__tree_next_iter(ptr) }
  }

  @inlinable @inline(__always)
  func ___begin(_ from: _NodePtr, to: _NodePtr) -> SafeSequenceState {
    (from, ___next(from, to: to), to)
  }

  @inlinable @inline(__always)
  func ___next(_ state: inout SafeSequenceState) {
    state.current = state.next
    state.next = ___next(state.next, to: state.to)
  }

  @inlinable @inline(__always)
  func ___end(_ state: SafeSequenceState) -> Bool {
    state.current != state.to
  }

  @inlinable @inline(__always)
  func ___begin(_ from: _NodePtr, to: _NodePtr) -> UnsafeSequenceState {
    (from, to)
  }

  @inlinable @inline(__always)
  func ___next(_ state: inout UnsafeSequenceState) {
    state.current = ___next(state.current, to: state.to)
  }

  @inlinable @inline(__always)
  func ___end(_ state: UnsafeSequenceState) -> Bool {
    state.current != state.to
  }

  public typealias ___EnumeratedSequence = UnfoldSequence<EnumeratedElement, SafeSequenceState>

  @inlinable
  public func ___enumerated_sequence(from: ___RedBlackTree.Index, to: ___RedBlackTree.Index)
    -> ___EnumeratedSequence
  {
    return sequence(state: ___begin(from.pointer, to: to.pointer)) { state in
      guard ___end(state) else { return nil }
      defer { ___next(&state) }
      return (___RedBlackTree.Index(state.current), ___elements[state.current])
    }
  }

  @inlinable @inline(__always)
  public var ___enumerated_sequence: ___EnumeratedSequence {
    ___enumerated_sequence(from: ___index_begin(), to: ___index_end())
  }

  @inlinable
  public func ___enumerated_sequence__(from: ___RedBlackTree.Index, to: ___RedBlackTree.Index)
    -> [EnumeratedElement]
  {
    return _read { tree in
      var result = [EnumeratedElement]()
      tree.___for_each(__p: from.pointer, __l: to.pointer) { __p, _ in
        result.append((___RedBlackTree.Index(__p),___elements[__p]))
      }
      return result
    }
  }

  @inlinable @inline(__always)
  public var ___enumerated_sequence__: [EnumeratedElement] {
    ___enumerated_sequence__(from: ___index_begin(), to: ___index_end())
  }

  @inlinable
  public func ___element_sequence__<T>(from: ___RedBlackTree.Index, to: ___RedBlackTree.Index, transform: (Element) throws -> T)
    rethrows -> [T]
  {
    try _read { tree in
      var result = [T]()
      try tree.___for_each(__p: from.pointer, __l: to.pointer) { __p, _ in
        result.append(try transform(___elements[__p]))
      }
      return result
    }
  }
  
  @inlinable
  public func ___element_sequence__(from: ___RedBlackTree.Index, to: ___RedBlackTree.Index, isIncluded: (Element) throws -> Bool)
    rethrows -> [Element]
  {
    try _read { tree in
      var result = [Element]()
      try tree.___for_each(__p: from.pointer, __l: to.pointer) { __p, _ in
        if try isIncluded(___elements[__p]) {
          result.append(___elements[__p])
        }
      }
      return result
    }
  }
  
  @inlinable
  public func ___element_sequence__<T>(from: ___RedBlackTree.Index, to: ___RedBlackTree.Index,_ initial: T,_ folding: (T, Element) throws -> T)
    rethrows -> T
  {
    try _read { tree in
      var result = initial
      try tree.___for_each(__p: from.pointer, __l: to.pointer) { __p, _ in
        result = try folding(result, ___elements[__p])
      }
      return result
    }
  }
  
  @inlinable
  public func ___element_sequence__<T>(from: ___RedBlackTree.Index, to: ___RedBlackTree.Index,into initial: T,_ folding: (inout T, Element) throws -> Void)
    rethrows -> T
  {
    try _read { tree in
      var result = initial
      try tree.___for_each(__p: from.pointer, __l: to.pointer) { __p, _ in
        try folding(&result, ___elements[__p])
      }
      return result
    }
  }

  @inlinable
  public func ___element_sequence__(from: ___RedBlackTree.Index, to: ___RedBlackTree.Index)
    -> [Element]
  {
    _read { tree in
      var result = [Element]()
      tree.___for_each(__p: from.pointer, __l: to.pointer) { __p, _ in
        result.append(___elements[__p])
      }
      return result
    }
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
