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

public final class ___Tree<VC>: ManagedBuffer<
  ___Tree<VC>.Header,
  ___Tree<VC>.Node
>
where VC: ValueComparer & CompareTrait {

  @inlinable
  deinit {
    self.withUnsafeMutablePointers { header, elements in
      elements.deinitialize(count: header.pointee.initializedCount)
      header.deinitialize(count: 1)
    }
  }
}

extension ___Tree {

  @inlinable
  internal static func create(
    minimumCapacity capacity: Int
  ) -> Tree {

    let storage = Tree.create(minimumCapacity: capacity) { managedBuffer in
      Header(
        capacity: managedBuffer.capacity,
        __left_: .nullptr,
        __begin_node: .end,
        __initialized_count: 0,
        __destroy_count: 0,
        __destroy_node: .nullptr)
    }

    return unsafeDowncast(storage, to: Tree.self)
  }

  @inlinable
  internal func copy(minimumCapacity: Int? = nil) -> Tree {

    let capacity = minimumCapacity ?? self._header.capacity
    let __left_ = self._header.__left_
    let __begin_node = self._header.__begin_node
    let __initialized_count = self._header.initializedCount
    let __destroy_count = self._header.destroyCount
    let __destroy_node = self._header.destroyNode
    #if AC_COLLECTIONS_INTERNAL_CHECKS
      let copyCount = self._header.copyCount
    #endif

    let newStorage = Tree.create(minimumCapacity: capacity)

    newStorage._header.__left_ = __left_
    newStorage._header.__begin_node = __begin_node
    newStorage._header.initializedCount = __initialized_count
    newStorage._header.destroyCount = __destroy_count
    newStorage._header.destroyNode = __destroy_node
    #if AC_COLLECTIONS_INTERNAL_CHECKS
      newStorage._header.copyCount = copyCount &+ 1
    #endif

    self.withUnsafeMutablePointerToElements { oldNodes in
      newStorage.withUnsafeMutablePointerToElements { newNodes in
        newNodes.initialize(from: oldNodes, count: __initialized_count)
      }
    }

    return newStorage
  }
}

extension ___Tree {

  public struct Node: ___tree_base_node {

    @usableFromInline
    internal var __value_: Element
    @usableFromInline
    internal var __left_: _NodePtr
    @usableFromInline
    internal var __right_: _NodePtr
    @usableFromInline
    internal var __parent_: _NodePtr
    @usableFromInline
    internal var __is_black_: Bool

    @inlinable
    init(
      __is_black_: Bool = false,
      __left_: _NodePtr = .nullptr,
      __right_: _NodePtr = .nullptr,
      __parent_: _NodePtr = .nullptr,
      __value_: Element
    ) {
      self.__is_black_ = __is_black_
      self.__left_ = __left_
      self.__right_ = __right_
      self.__parent_ = __parent_
      self.__value_ = __value_
    }
  }
}

extension ___Tree {

  public
    typealias Tree = ___Tree<VC>

  @usableFromInline
  internal typealias VC = VC

  @usableFromInline
  internal typealias Manager = ManagedBufferPointer<Header, Node>
}

extension ___Tree {

  public struct Header: ___tree_root_node {

    @inlinable
    init(
      capacity: Int,
      __left_: _NodePtr,
      __begin_node: _NodePtr,
      __initialized_count: Int,
      __destroy_count: Int,
      __destroy_node: _NodePtr
    ) {
      self.capacity = capacity
      self.__left_ = __left_
      self.__begin_node = __begin_node
      self.initializedCount = __initialized_count
      self.destroyCount = __destroy_count
      self.destroyNode = __destroy_node
    }

    @usableFromInline
    internal var capacity: Int

    @usableFromInline
    internal var __left_: _NodePtr = .nullptr

    @usableFromInline
    internal var __begin_node: _NodePtr = .end

    @usableFromInline
    internal var initializedCount: Int

    @usableFromInline
    internal var destroyCount: Int

    @usableFromInline
    internal var destroyNode: _NodePtr = .end

    #if AC_COLLECTIONS_INTERNAL_CHECKS
      @usableFromInline
      var copyCount: UInt = 0
    #endif
  }
}

extension ___Tree.Header {

  @inlinable
  @inline(__always)
  internal var count: Int {
    initializedCount - destroyCount
  }

  @inlinable
  @inline(__always)
  internal mutating func clear() {
    __begin_node = .end
    __left_ = .nullptr
    initializedCount = 0
  }
}

extension ___Tree {

  @inlinable
  internal var __header_ptr: UnsafeMutablePointer<Header> {
    withUnsafeMutablePointerToHeader({ $0 })
  }

  @inlinable
  internal var __node_ptr: UnsafeMutablePointer<Node> {
    withUnsafeMutablePointerToElements({ $0 })
  }

  @inlinable
  internal var _header: Header {
    @inline(__always)
    //    get { __header_ptr.pointee }
    _read { yield __header_ptr.pointee }
    @inline(__always)
    _modify { yield &__header_ptr.pointee }
  }

  @inlinable
  public subscript(_ pointer: _NodePtr) -> Element {
    @inline(__always)
    //    get {
    //      assert(0 <= pointer && pointer < _header.initializedCount)
    //      return __node_ptr[pointer].__value_
    //    }
    _read {
      assert(0 <= pointer && pointer < _header.initializedCount)
      yield __node_ptr[pointer].__value_
    }
    @inline(__always)
    _modify {
      assert(0 <= pointer && pointer < _header.initializedCount)
      yield &__node_ptr[pointer].__value_
    }
  }

  #if AC_COLLECTIONS_INTERNAL_CHECKS
    @inlinable
    internal var copyCount: UInt {
      get { __header_ptr.pointee.copyCount }
      set { __header_ptr.pointee.copyCount = newValue }
    }
  #endif
}

extension ___Tree {
  /// O(1)
  @inlinable
  @inline(__always)
  internal func ___pushDestroy(_ p: _NodePtr) {
    assert(_header.destroyNode != p)
    assert(_header.initializedCount <= _header.capacity)
    assert(_header.destroyCount <= _header.capacity)
    assert(_header.destroyNode != p)
    __node_ptr[p].__left_ = _header.destroyNode
    __node_ptr[p].__right_ = p
    __node_ptr[p].__parent_ = .nullptr
    __node_ptr[p].__is_black_ = false
    _header.destroyNode = p
    _header.destroyCount += 1
  }
  /// O(1)
  @inlinable
  @inline(__always)
  internal func ___popDetroy() -> _NodePtr {
    assert(_header.destroyCount > 0)
    let p = __node_ptr[_header.destroyNode].__right_
    _header.destroyNode = __node_ptr[p].__left_
    _header.destroyCount -= 1
    return p
  }
  /// O(1)
  @inlinable
  internal func ___clearDestroy() {
    _header.destroyNode = .nullptr
    _header.destroyCount = 0
  }
}

extension ___Tree {

  @inlinable @inline(__always)
  internal func ___is_garbaged(_ p: _NodePtr) -> Bool {
    __node_ptr[p].__parent_ == .nullptr
  }
}

#if AC_COLLECTIONS_INTERNAL_CHECKS
  extension ___Tree {

    /// O(*k*)
    var ___destroyNodes: [_NodePtr] {
      if _header.destroyNode == .nullptr {
        return []
      }
      var nodes: [_NodePtr] = [_header.destroyNode]
      while let l = nodes.last, __left_(l) != .nullptr {
        nodes.append(__left_(l))
      }
      return nodes
    }
  }
#endif

extension ___Tree {

  @inlinable
  internal func __construct_node(_ k: Element) -> _NodePtr {
    if _header.destroyCount > 0 {
      let p = ___popDetroy()
      __node_ptr[p].__value_ = k
      return p
    }
    assert(capacity - count >= 1)
    let index = _header.initializedCount
    (__node_ptr + index).initialize(to: Node(__value_: k))
    _header.initializedCount += 1
    assert(_header.initializedCount <= _header.capacity)
    return index
  }

  @inlinable
  internal func destroy(_ p: _NodePtr) {
    ___pushDestroy(p)
  }
}

extension ___Tree {

  @inlinable
  internal var count: Int {
    __header_ptr.pointee.count
  }

  @inlinable
  internal var size: Int {
    get { __header_ptr.pointee.count }
    set { /* NOP */  }
  }

  @inlinable
  public var __begin_node: _NodePtr {
    _read { yield __header_ptr.pointee.__begin_node }
    _modify {
      yield &__header_ptr.pointee.__begin_node
    }
  }
}

extension ___Tree {

  @inlinable @inline(__always)
  internal func __value_(_ p: _NodePtr) -> _Key {
    __key(__node_ptr[p].__value_)
  }
}

extension ___Tree {

  public typealias Element = VC.Element

  @usableFromInline
  internal typealias _Key = VC._Key

  @inlinable @inline(__always)
  internal func value_comp(_ a: _Key, _ b: _Key) -> Bool {
    VC.value_comp(a, b)
  }

  @inlinable @inline(__always)
  internal func __key(_ e: VC.Element) -> VC._Key {
    VC.__key(e)
  }

  @inlinable @inline(__always)
  internal func ___element(_ p: _NodePtr) -> VC.Element {
    __node_ptr[p].__value_
  }

  @inlinable @inline(__always)
  internal func ___element(_ p: _NodePtr, _ __v: VC.Element) {
    __node_ptr[p].__value_ = __v
  }
}

extension ___Tree: FindProtocol {}
extension ___Tree: FindEqualProtocol {}
extension ___Tree: FindLeafProtocol {}
extension ___Tree: EqualProtocol {}
extension ___Tree: InsertNodeAtProtocol {}
extension ___Tree: InsertMultiProtocol {}
extension ___Tree: InsertLastProtocol {}
extension ___Tree: RemoveProtocol {}
extension ___Tree: MergeProtocol {}
extension ___Tree: HandleProtocol {}
extension ___Tree: EraseProtocol {}
extension ___Tree: EraseUniqueProtocol {}
extension ___Tree: EraseMultiProtocol {}
extension ___Tree: BoundProtocol {}
extension ___Tree: InsertUniqueProtocol {}
extension ___Tree: CountProtocol {}
extension ___Tree: MemberProtocol {}
extension ___Tree: DistanceProtocol {}
extension ___Tree: CompareProtocol {}
extension ___Tree: CompareUniqueProtocol {}
extension ___Tree: CompareMultiProtocol {}
extension ___Tree: Tree_IterateProtocol {}

extension ___Tree {
  @inlinable
  @inline(__always)
  internal func __parent_(_ p: _NodePtr) -> _NodePtr {
    __node_ptr[p].__parent_
  }
  @inlinable
  @inline(__always)
  internal func __left_(_ p: _NodePtr) -> _NodePtr {
    p == .end ? _header.__left_ : __node_ptr[p].__left_
  }
  @inlinable
  @inline(__always)
  internal func __right_(_ p: _NodePtr) -> _NodePtr {
    __node_ptr[p].__right_
  }
  @inlinable
  @inline(__always)
  internal func __is_black_(_ p: _NodePtr) -> Bool {
    __node_ptr[p].__is_black_
  }
  @inlinable
  @inline(__always)
  internal func __parent_unsafe(_ p: _NodePtr) -> _NodePtr {
    __parent_(p)
  }
}

extension ___Tree {

  @inlinable
  @inline(__always)
  internal func __is_black_(_ lhs: _NodePtr, _ rhs: Bool) {
    __node_ptr[lhs].__is_black_ = rhs
  }
  @inlinable
  @inline(__always)
  internal func __parent_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    __node_ptr[lhs].__parent_ = rhs
  }
  @inlinable
  @inline(__always)
  internal func __left_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    if lhs == .end {
      _header.__left_ = rhs
    } else {
      __node_ptr[lhs].__left_ = rhs
    }
  }
  @inlinable
  @inline(__always)
  internal func __right_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    __node_ptr[lhs].__right_ = rhs
  }
}

// MARK: -
extension ___Tree: CompareBothProtocol {
  @inlinable
  @inline(__always)
  var isMulti: Bool { VC.isMulti }
}

// MARK: -

extension ___Tree {

  @inlinable
  internal func
    ___erase(_ __f: _NodePtr, _ __l: _NodePtr, _ action: (Element) throws -> Void) rethrows
  {
    var __f = __f
    while __f != __l {
      try action(self[__f])
      __f = erase(__f)
    }
  }

  @inlinable
  internal func
    ___erase<Result>(
      _ __f: _NodePtr, _ __l: _NodePtr, _ initialResult: Result,
      _ nextPartialResult: (Result, Element) throws -> Result
    ) rethrows -> Result
  {
    var result = initialResult
    var __f = __f
    while __f != __l {
      result = try nextPartialResult(result, self[__f])
      __f = erase(__f)
    }
    return result
  }

  @inlinable
  internal func
    ___erase<Result>(
      _ __f: _NodePtr, _ __l: _NodePtr, into initialResult: Result,
      _ updateAccumulatingResult: (inout Result, Element) throws -> Void
    ) rethrows -> Result
  {
    var result = initialResult
    var __f = __f
    while __f != __l {
      try updateAccumulatingResult(&result, self[__f])
      __f = erase(__f)
    }
    return result
  }
}

extension ___Tree {

  /// O(1)
  @inlinable
  internal func __eraseAll() {
    _header.clear()
    ___clearDestroy()
  }
}

extension ___Tree {

  @inlinable @inline(__always)
  internal var ___is_empty: Bool {
    count == 0
  }

  @inlinable @inline(__always)
  internal var ___capacity: Int {
    _header.capacity
  }

  @available(*, deprecated, renamed: "__begin_node")
  @inlinable @inline(__always)
  internal func ___begin() -> _NodePtr {
    _header.__begin_node
  }

  @inlinable @inline(__always)
  internal func ___end() -> _NodePtr {
    .end
  }
}

extension ___Tree {

  @inlinable @inline(__always)
  internal func ___contains(_ p: _NodePtr) -> Bool {
    0..<_header.initializedCount ~= p
  }

  @inlinable @inline(__always)
  internal func ___is_valid(_ p: _NodePtr) -> Bool {
    ___contains(p) && !___is_garbaged(p)
  }

  @inlinable
  internal func ___is_valid_index(_ i: _NodePtr) -> Bool {
    if i == .nullptr { return false }
    if i == .end { return true }
    return ___is_valid(i)
  }
}

// MARK: -

extension ___Tree {

  @inlinable
  @inline(__always)
  internal func ___for_each(
    __p: _NodePtr, __l: _NodePtr, body: (_NodePtr, inout Bool) throws -> Void
  )
    rethrows
  {
    var __p = __p
    var cont = true
    while cont, __p != __l {
      let __c = __p
      __p = __tree_next(__p)
      try body(__c, &cont)
    }
  }

  @inlinable
  @inline(__always)
  internal func ___for_each_(_ body: (Element) throws -> Void) rethrows {
    try ___for_each_(__p: __begin_node, __l: __end_node(), body: body)
  }

  @inlinable
  @inline(__always)
  internal func ___for_each_(__p: _NodePtr, __l: _NodePtr, body: (Element) throws -> Void)
    rethrows
  {
    var __p = __p
    while __p != __l {
      let __c = __p
      __p = __tree_next(__p)
      try body(self[__c])
    }
  }
}

// MARK: -

extension ___Tree {

  // この実装がないと、迷子になる?
  @inlinable
  internal func ___distance(from start: _NodePtr, to end: _NodePtr) -> Int {
    guard start == __end_node() || ___is_valid(start),
      end == __end_node() || ___is_valid(end)
    else {
      fatalError(.invalidIndex)
    }
    return ___signed_distance(start, end)
  }

  @inlinable
  @inline(__always)
  internal func ___index(after i: _NodePtr) -> _NodePtr {
    guard i != __end_node(), ___is_valid(i) else {
      fatalError(.invalidIndex)
    }
    return __tree_next(i)
  }

  @inlinable
  @inline(__always)
  internal func ___formIndex(after i: inout _NodePtr) {
    guard i != __end_node(), ___is_valid(i) else { fatalError(.invalidIndex) }
    i = __tree_next(i)
  }

  @inlinable
  @inline(__always)
  internal func ___index(before i: _NodePtr) -> _NodePtr {
    guard i != __begin_node, i == __end_node() || ___is_valid(i) else {
      fatalError(.invalidIndex)
    }
    return __tree_prev_iter(i)
  }

  @inlinable
  @inline(__always)
  internal func ___formIndex(before i: inout _NodePtr) {
    guard i == __end_node() || ___is_valid(i) else { fatalError(.invalidIndex) }
    i = __tree_prev_iter(i)
  }

  @inlinable
  @inline(__always)
  internal func ___index(_ i: _NodePtr, offsetBy distance: Int) -> _NodePtr {
    guard i == ___end() || ___is_valid(i) else { fatalError(.invalidIndex) }
    var distance = distance
    var i = i
    while distance != 0 {
      if 0 < distance {
        guard i != __end_node() else {
          fatalError(.outOfBounds)
        }
        i = ___index(after: i)
        distance -= 1
      } else {
        guard i != __begin_node else {
          fatalError(.outOfBounds)
        }
        i = ___index(before: i)
        distance += 1
      }
    }
    return i
  }

  @inlinable
  @inline(__always)
  internal func ___formIndex(_ i: inout _NodePtr, offsetBy distance: Int) {
    guard i == __end_node() || ___is_valid(i) else { fatalError(.invalidIndex) }
    i = ___index(i, offsetBy: distance)
  }

  @inlinable
  @inline(__always)
  internal func ___index(_ i: _NodePtr, offsetBy distance: Int, limitedBy limit: _NodePtr)
    -> _NodePtr?
  {
    guard i == ___end() || ___is_valid(i) else { fatalError(.invalidIndex) }
    var distance = distance
    var i = i
    while distance != 0 {
      if i == limit {
        return nil
      }
      if 0 < distance {
        guard i != __end_node() else {
          fatalError(.outOfBounds)
        }
        i = ___index(after: i)
        distance -= 1
      } else {
        guard i != __begin_node else {
          fatalError(.outOfBounds)
        }
        i = ___index(before: i)
        distance += 1
      }
    }
    return i
  }

  @inlinable
  @inline(__always)
  internal func ___formIndex(_ i: inout _NodePtr, offsetBy distance: Int, limitedBy limit: _NodePtr)
    -> Bool
  {
    guard i == __end_node() || ___is_valid(i) else { fatalError(.invalidIndex) }
    if let ii = ___index(i, offsetBy: distance, limitedBy: limit) {
      i = ii
      return true
    }
    return false
  }
}

// MARK: -

extension ___Tree: Sequence {

  @inlinable
  public __consuming func makeIterator() -> ElementIterator<Tree> {
    .init(tree: self, start: __begin_node, end: __end_node())
  }
}

// MARK: -

extension ___Tree: Tree_IndexProtocol {
  public typealias Index = ___Iterator
  @inlinable @inline(__always)
  func makeIndex(rawValue: _NodePtr) -> ___Iterator {
    .init(__tree: self, rawValue: rawValue)
  }
}

extension ___Tree: Tree_IndicesProtocol {
  public typealias Indices = ___IteratorSequence
  @inlinable @inline(__always)
  func makeIndices(start: _NodePtr, end: _NodePtr) -> Indices {
    .init(tree: self, start: start, end: end)
  }
}

extension ___Tree: Tree_RawIndexProtocol {
  @inlinable @inline(__always)
  public func makeRawIndex(rawValue: _NodePtr) -> RawIndex {
    .init(rawValue)
  }
}

extension ___Tree {
  
  @inlinable
  public func ___equiv(_ lhs: Element,_ rhs: Element) -> Bool {
    !value_comp(__key(lhs), __key(rhs)) &&
    !value_comp(__key(rhs), __key(lhs))
  }

  @inlinable
  public func ___tree_equiv(start: _NodePtr, end: _NodePtr, other: (tree: Tree, start: _NodePtr, end: _NodePtr)) -> Bool {
    var (l, r) = (start, other.start)
    if l == end { return r == other.end }
    while r != other.end,
          ___equiv(other.tree[r], self[l])
    {
      r = other.tree.__tree_next_iter(r)
      l = __tree_next_iter(l)
      if l == end {
        return r == other.end
      }
    }
    return false
  }
  
  @inlinable
  func ___tree_equiv(_ other: Tree) -> Bool {
    ___tree_equiv(start: __begin_node, end: __end_node(),
                  other: (other, other.__begin_node, other.__end_node()))
  }

  @inlinable
  func ___tree_equiv_key_value<Key,Value>(start: _NodePtr, end: _NodePtr, other: (tree: Tree, start: _NodePtr, end: _NodePtr)) -> Bool
  where Element == _KeyValueTuple_<Key,Value>, Value: Equatable
  {
    var (l, r) = (start, other.start)
    if l == end { return r == other.end }
    while r != other.end,
          ___equiv(other.tree[r], self[l]),
          other.tree[r].value == self[l].value
    {
      r = other.tree.__tree_next_iter(r)
      l = __tree_next_iter(l)
      if l == end {
        return r == other.end
      }
    }
    return false
  }

  @inlinable
  func ___tree_equiv_key_value<Key,Value>(_ other: Tree) -> Bool
  where Element == _KeyValueTuple_<Key,Value>, Value: Equatable
  {
    ___tree_equiv_key_value(start: __begin_node, end: __end_node(),
                            other: (other, other.__begin_node, other.__end_node()))
  }
  
  @inlinable
  func ___tree_equiv<Other>(start: _NodePtr, end: _NodePtr, other r: Other) -> Bool
  where Other: Sequence, Other.Element == VC.Element
  {
    var l = start
    var r = r.makeIterator()
    if l == end { return r.next() == nil }
    while let rv = r.next(), ___equiv(self[l], rv)
    {
      l = __tree_next_iter(l)
      if l == end { return r.next() == nil }
    }
    return false
  }

  @inlinable
  func ___tree_equiv<Other>(with r: Other) -> Bool
  where Other: Sequence, Other.Element == VC.Element
  {
    ___tree_equiv(start: __begin_node, end: __end_node(), other: r)
  }
}

extension ___Tree {
  
  @inlinable
  func ___element_key_comp(_ lhs: Element,_ rhs: Element) -> Bool {
    value_comp(__key(lhs), __key(rhs))
  }
  
  @inlinable
  public func ___tree_compare(start: _NodePtr, end: _NodePtr, other: (tree: Tree, start: _NodePtr, end: _NodePtr)) -> Bool {
    var (l, r) = (start, other.start)
    while r != other.end
    {
      if l == end || ___element_key_comp(self[l], other.tree[r]) {
        return true
      }
      if ___element_key_comp(other.tree[r], self[l]) {
        return false
      }
      r = other.tree.__tree_next_iter(r)
      l = __tree_next_iter(l)
    }
    return false
  }
  
  @inlinable
  func ___tree_compare(_ other: Tree) -> Bool {
    ___tree_compare(start: __begin_node, end: __end_node(),
                    other: (other, other.__begin_node, other.__end_node()))
  }
  
  @inlinable
  func ___element_key_value_comp<Key,Value>(_ lhs: Element,_ rhs: Element) -> Bool
  where Element == _KeyValueTuple_<Key,Value>, Value: Comparable
  {
    value_comp(__key(lhs), __key(rhs)) || (!value_comp(__key(lhs), __key(rhs)) && lhs.value < rhs.value)
  }

  @inlinable
  public func ___tree_compare_key_value<Key,Value>(start: _NodePtr, end: _NodePtr, other: (tree: Tree, start: _NodePtr, end: _NodePtr)) -> Bool
  where Element == _KeyValueTuple_<Key,Value>, Value: Comparable
  {
    var (l, r) = (start, other.start)
    while r != other.end
    {
      if l == end || ___element_key_value_comp(self[l], other.tree[r]) {
        return true
      }
      if ___element_key_value_comp(other.tree[r], self[l]) {
        return false
      }
      r = other.tree.__tree_next_iter(r)
      l = __tree_next_iter(l)
    }
    return false
  }

  @inlinable
  func ___tree_compare_key_value<Key,Value>(_ other: Tree) -> Bool
  where Element == _KeyValueTuple_<Key,Value>, Value: Comparable
  {
    ___tree_compare_key_value(start: __begin_node, end: __end_node(),
                              other: (other, other.__begin_node, other.__end_node()))
  }
}
