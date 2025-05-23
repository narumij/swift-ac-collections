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

extension ___RedBlackTree {

  public final class ___Tree<VC>: ManagedBuffer<
    ___RedBlackTree.___Tree<VC>.Header,
    ___RedBlackTree.___Tree<VC>.Node
  >
  where VC: ValueComparer {

    @inlinable
    deinit {
      self.withUnsafeMutablePointers { header, elements in
        elements.deinitialize(count: header.pointee.initializedCount)
        header.deinitialize(count: 1)
      }
    }
  }
}

extension ___RedBlackTree.___Tree {

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

extension ___RedBlackTree.___Tree {

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

extension ___RedBlackTree.___Tree {

  public
    typealias Tree = ___RedBlackTree.___Tree<VC>

  public
    typealias RawPointer = ___RedBlackTree.RawPointer

  @usableFromInline
  internal typealias VC = VC

  @usableFromInline
  internal typealias Manager = ManagedBufferPointer<Header, Node>
}

extension ___RedBlackTree.___Tree {

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

extension ___RedBlackTree.___Tree.Header {

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

extension ___RedBlackTree.___Tree {

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
    get { __header_ptr.pointee }
    @inline(__always)
    _modify { yield &__header_ptr.pointee }
  }

  @inlinable
  internal subscript(_ pointer: _NodePtr) -> Element {
    @inline(__always)
    get {
      assert(0 <= pointer && pointer < _header.initializedCount)
      return __node_ptr[pointer].__value_
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

extension ___RedBlackTree.___Tree {
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

#if AC_COLLECTIONS_INTERNAL_CHECKS
  extension ___RedBlackTree.___Tree {

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

extension ___RedBlackTree.___Tree {

  @inlinable @inline(__always)
  internal func ___is_valid(_ p: _NodePtr) -> Bool {
    0..<_header.initializedCount ~= p && __node_ptr[p].__parent_ != .nullptr
  }
}

extension ___RedBlackTree.___Tree {

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

extension ___RedBlackTree.___Tree {

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
  internal var __begin_node: _NodePtr {
    get { __header_ptr.pointee.__begin_node }
    _modify {
      yield &__header_ptr.pointee.__begin_node
    }
  }
}

extension ___RedBlackTree.___Tree {

  @inlinable @inline(__always)
  internal func __value_(_ p: _NodePtr) -> _Key {
    __key(__node_ptr[p].__value_)
  }
}

extension ___RedBlackTree.___Tree {

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

extension ___RedBlackTree.___Tree: FindProtocol {}
extension ___RedBlackTree.___Tree: FindEqualProtocol {}
extension ___RedBlackTree.___Tree: FindLeafProtocol {}
extension ___RedBlackTree.___Tree: EqualProtocol {}
extension ___RedBlackTree.___Tree: InsertNodeAtProtocol {}
extension ___RedBlackTree.___Tree: InsertMultiProtocol {}
extension ___RedBlackTree.___Tree: InsertLastProtocol {}
extension ___RedBlackTree.___Tree: RemoveProtocol {}
extension ___RedBlackTree.___Tree: MergeProtocol {}
extension ___RedBlackTree.___Tree: HandleProtocol {}
extension ___RedBlackTree.___Tree: EraseProtocol {}
extension ___RedBlackTree.___Tree: EraseUniqueProtocol {}
extension ___RedBlackTree.___Tree: EraseMultiProtocol {}
extension ___RedBlackTree.___Tree: BoundProtocol {}
extension ___RedBlackTree.___Tree: InsertUniqueProtocol {}
extension ___RedBlackTree.___Tree: CountProtocol {}
extension ___RedBlackTree.___Tree: MemberProtocol {}
extension ___RedBlackTree.___Tree: DistanceProtocol {}
extension ___RedBlackTree.___Tree: CompareProtocol {}
extension ___RedBlackTree.___Tree: CompareMultiProtocol {}

extension ___RedBlackTree.___Tree {
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

extension ___RedBlackTree.___Tree {

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

extension ___RedBlackTree.___Tree {

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

extension ___RedBlackTree.___Tree {

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

extension ___RedBlackTree.___Tree {

  /// O(1)
  @inlinable
  internal func __eraseAll() {
    _header.clear()
    ___clearDestroy()
  }
}

extension ___RedBlackTree.___Tree {

  @inlinable @inline(__always)
  internal var ___is_empty: Bool {
    count == 0
  }

  @inlinable @inline(__always)
  internal var ___capacity: Int {
    _header.capacity
  }

  @inlinable @inline(__always)
  internal func ___begin() -> _NodePtr {
    _header.__begin_node
  }

  @inlinable @inline(__always)
  internal func ___end() -> _NodePtr {
    .end
  }
}

extension ___RedBlackTree.___Tree {
  @inlinable
  internal func ___is_valid_index(_ i: _NodePtr) -> Bool {
    if i == .nullptr { return false }
    if i == .end { return true }
    return ___is_valid(i)
  }
}

extension ___RedBlackTree.___Tree {

  @inlinable @inline(__always)
  internal var ___sorted: [Element] {
    var result = [Element]()
    ___for_each_ { member in
      result.append(member)
    }
    return result
  }
}
