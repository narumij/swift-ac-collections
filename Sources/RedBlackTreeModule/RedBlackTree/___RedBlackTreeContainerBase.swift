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

@usableFromInline
protocol ___RedBlackTreeContainerBase: EndProtocol, ValueComparer {
  associatedtype Element
  var ___header: ___RedBlackTree.___Header { get set }
  var ___nodes: [___RedBlackTree.___Node] { get set }
  var ___values: [Element] { get set }
}

extension ___RedBlackTreeContainerBase {

  @inlinable @inline(__always)
  public var ___count: Int {
    ___header.size
  }

  @inlinable @inline(__always)
  public var ___isEmpty: Bool {
    ___header.size == 0
  }

  @inlinable @inline(__always)
  public var ___capacity: Int {
    Swift.min(___values.capacity, ___nodes.capacity)
  }

  @inlinable @inline(__always)
  public func ___begin() -> _NodePtr {
    ___header.__begin_node
  }

  @inlinable @inline(__always)
  public func ___end() -> _NodePtr {
    .end
  }
}

extension ___RedBlackTreeContainerBase {

  @inlinable
  @inline(__always)
  func _read<R>(_ body: (___UnsafeHandle<Self>) throws -> R) rethrows -> R {
    return try withUnsafePointer(to: ___header) { header in
      try ___nodes.withUnsafeBufferPointer { nodes in
        try ___values.withUnsafeBufferPointer { values in
          try body(
            ___UnsafeHandle<Self>(
              __header_ptr: header,
              __node_ptr: nodes.baseAddress!,
              __value_ptr: values.baseAddress!))
        }
      }
    }
  }
}

extension ___RedBlackTreeContainerBase {

  @inlinable
  func __ref_(_ rhs: _NodeRef) -> _NodePtr {
    _read { tree in
      tree.__ref_(rhs)
    }
  }

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
  func ___contains(_ __k: _Key) -> Bool where _Key: Equatable {
    _read { tree in
      let it = tree.__lower_bound(__k, tree.__root(), tree.__left_)
      guard it >= 0 else { return false }
      return Self.__key(tree.__value_ptr[it]) == __k
    }
  }

  @inlinable @inline(__always)
  func ___min() -> Element? {
    _read { tree in
      let p = tree.__tree_min(tree.__root())
      return p == .end ? nil : tree.__value_(p)
    }
  }

  @inlinable @inline(__always)
  func ___max() -> Element? {
    _read { tree in
      let p = tree.__tree_max(tree.__root())
      return p == .end ? nil : tree.__value_(p)
    }
  }
}

extension ___RedBlackTreeContainerBase {

  @usableFromInline
  typealias ___Index = ___RedBlackTree.Index

  @inlinable @inline(__always)
  func ___index_begin() -> ___Index {
    ___Index(___begin())
  }

  @inlinable @inline(__always)
  func ___index_end() -> ___Index {
    ___Index(___end())
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
      __last == end() ? ___count : tree.distance(__first: tree.__begin_node, __last: __last)
    }
  }
}

extension ___RedBlackTreeContainerBase {

  @inlinable @inline(__always)
  func ___index_prev(_ i: ___Index, type: String) -> ___Index {
    let i = i.pointer
    return _read { tree in
      guard i != tree.__begin_node, i == tree.__end_node() || ___nodes[i].isValid else {
        fatalError("Attempting to access \(type) elements using an invalid index")
      }
      return ___Index(tree.__tree_prev_iter(i))
    }
  }

  @inlinable @inline(__always)
  func ___index_next(_ i: ___Index, type: String) -> ___Index {
    let i = i.pointer
    return _read { tree in
      guard i != tree.__end_node(), ___nodes[i].isValid else {
        fatalError("Attempting to access \(type) elements using an invalid index")
      }
      return ___Index(tree.__tree_next_iter(i))
    }
  }
}

extension ___RedBlackTreeContainerBase {

  @inlinable
  func ___index(_ i: ___Index, offsetBy distance: Int, type: String) -> ___Index {
    ___Index(pointer(i.pointer, offsetBy: distance, type: type))
  }

  @inlinable
  func ___index(
    _ i: ___Index, offsetBy distance: Int, limitedBy limit: ___Index, type: String
  ) -> ___Index? {
    ___Index?(
      pointer(
        i.pointer, offsetBy: distance, limitedBy: limit.pointer, type: type))
  }

  @inlinable
  @inline(__always)
  func pointer(
    _ ptr: _NodePtr, offsetBy distance: Int, limitedBy limit: _NodePtr? = .none, type: String
  ) -> _NodePtr {
    guard ptr == ___end() || ___nodes[ptr].isValid else {
      fatalError("Attempting to access \(type) elements using an invalid index")
    }
    return distance > 0
      ? pointer(ptr, nextBy: UInt(distance), limitedBy: limit, type: type)
      : pointer(ptr, prevBy: UInt(abs(distance)), limitedBy: limit, type: type)
  }

  @inlinable
  @inline(__always)
  func pointer(
    _ ptr: _NodePtr, prevBy distance: UInt, limitedBy limit: _NodePtr? = .none, type: String
  ) -> _NodePtr {
    _read { tree in
      var ptr = ptr
      var distance = distance
      while distance != 0, ptr != limit {
        // __begin_nodeを越えない
        guard ptr != tree.__begin_node else {
          fatalError("\(type) index is out of Bound.")
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
    _ ptr: _NodePtr, nextBy distance: UInt, limitedBy limit: _NodePtr? = .none, type: String
  ) -> _NodePtr {
    _read { tree in
      var ptr = ptr
      var distance = distance
      while distance != 0, ptr != limit {
        // __end_node()を越えない
        guard ptr != tree.__end_node() else {
          fatalError("\(type) index is out of Bound.")
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
  func ___equal_with(_ rhs: Self) -> Bool where Element: Equatable {
    ___count == rhs.___count &&
    zip(___element_sequence, rhs.___element_sequence).allSatisfy(==)
  }

  @inlinable
  func ___equal_with<K, V>(_ rhs: Self) -> Bool
  where K: Equatable, V: Equatable, Element == (key: K, value: V) {
    ___count == rhs.___count &&
    zip(___element_sequence, rhs.___element_sequence).allSatisfy(==)
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

  /// 将来的にも公開メンバーであるかどうかは保証されません。
  @inlinable
  public func ___enumerated_sequence(from: ___RedBlackTree.Index, to: ___RedBlackTree.Index) -> ___EnumeratedSequence {
    return sequence(state: ___begin(from.pointer, to: to.pointer)) { state in
      guard ___end(state) else { return nil }
      defer { ___next(&state) }
      return (___RedBlackTree.Index(state.current), ___values[state.current])
    }
  }

  @inlinable
  public var ___enumerated_sequence: ___EnumeratedSequence {
    ___enumerated_sequence(from: ___index_begin(), to: ___index_end())
  }

  /// 将来的にも公開メンバーであるかどうかは保証されません。
  @inlinable
  public func ___index_sequence(from: ___RedBlackTree.Index, to: ___RedBlackTree.Index) -> UnfoldSequence<___RedBlackTree.Index, SafeSequenceState> {
    return sequence(state: ___begin(from.pointer, to: to.pointer)) { state in
      guard ___end(state) else { return nil }
      defer { ___next(&state) }
      return ___RedBlackTree.Index(state.current)
    }
  }

  /// 将来的にも公開メンバーであるかどうかは保証されません。
  @inlinable
  public var ___index_sequence: UnfoldSequence<___RedBlackTree.Index, SafeSequenceState> {
    ___index_sequence(from: ___index_begin(), to: ___index_end())
  }

  /// 将来的にも公開メンバーであるかどうかは保証されません。
  @inlinable
  public func ___element_sequence(from: ___RedBlackTree.Index, to: ___RedBlackTree.Index) -> UnfoldSequence<Element, UnsafeSequenceState> {
    return sequence(state: ___begin(from.pointer, to: to.pointer)) { state in
      guard ___end(state) else { return nil }
      defer { ___next(&state) }
      return ___values[state.current]
    }
  }

  /// 将来的にも公開メンバーであるかどうかは保証されません。
  @inlinable
  public var ___element_sequence: UnfoldSequence<Element, UnsafeSequenceState> {
    ___element_sequence(from: ___index_begin(), to: ___index_end())
  }

  @inlinable
  func ___ptr_sequence(from: _NodePtr, to: _NodePtr) -> UnfoldSequence<_NodePtr, SafeSequenceState> {
    return sequence(state: ___begin(from, to: to)) { state in
      guard ___end(state) else { return nil }
      defer { ___next(&state) }
      return state.current
    }
  }

  @inlinable
  var ___ptr_sequence: UnfoldSequence<_NodePtr, SafeSequenceState> {
    ___ptr_sequence(from: ___begin(), to: ___end())
  }
}
