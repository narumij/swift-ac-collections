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

public typealias ___TreeBase = ValueComparer & CompareTrait & ThreeWayComparator

@_fixed_layout
@_objc_non_lazy_realization
public final class ___Tree<Base>: ManagedBuffer<
  ___Tree<Base>.Header,
  ___Tree<Base>.Node
>
where Base: ___TreeBase {

  @inlinable
  deinit {
    self.withUnsafeMutablePointers { header, elements in
      elements.deinitialize(count: header.pointee.initializedCount)
      header.deinitialize(count: 1)
    }
  }
}

extension ___Tree {

  @nonobjc
  @inlinable
  @inline(__always)
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

  @nonobjc
  @inlinable
  @inline(__always)
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

  @frozen
  public struct Node {

    @usableFromInline
    internal var __value_: _Value
    @usableFromInline
    internal var __left_: _NodePtr
    @usableFromInline
    internal var __parent_: _NodePtr
    @usableFromInline
    internal var __right_: _NodePtr
    @usableFromInline
    internal var __is_black_: Bool

    @inlinable
    @inline(__always)
    init(
      __is_black_: Bool = false,
      __left_: _NodePtr = .nullptr,
      __right_: _NodePtr = .nullptr,
      __parent_: _NodePtr = .nullptr,
      __value_: _Value
    ) {
      self.__is_black_ = __is_black_
      self.__left_ = __left_
      self.__right_ = __right_
      self.__parent_ = __parent_
      self.__value_ = __value_
    }
  }
}

extension ___Tree.Node: Equatable where ___Tree._Value: Equatable {}
extension ___Tree.Node: Hashable where ___Tree._Value: Hashable {}

extension ___Tree {

  public typealias Tree = ___Tree<Base>

  public typealias Base = Base

  @usableFromInline
  internal typealias Manager = ManagedBufferPointer<Header, Node>

  @usableFromInline
  internal typealias Storage = ___Storage<Base>
}

extension ___Tree {

  @frozen
  public struct Header {

    @inlinable
    @inline(__always)
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

extension ___Tree.Header: Equatable {}
extension ___Tree.Header: Hashable {}

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

  @nonobjc
  @inlinable
  @inline(__always)
  internal var __header_ptr: UnsafeMutablePointer<Header> {
    withUnsafeMutablePointerToHeader({ $0 })
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal var __node_ptr: UnsafeMutablePointer<Node> {
    withUnsafeMutablePointerToElements({ $0 })
  }

  @nonobjc
  @inlinable
  internal var _header: Header {
    @inline(__always) _read {
      yield __header_ptr.pointee
    }
    @inline(__always) _modify {
      yield &__header_ptr.pointee
    }
  }

  @nonobjc
  @inlinable
  public subscript(_ pointer: _NodePtr) -> _Value {
    @inline(__always) _read {
      assert(___initialized_contains(pointer))
      yield __node_ptr[pointer].__value_
    }
    @inline(__always) _modify {
      assert(___initialized_contains(pointer))
      yield &__node_ptr[pointer].__value_
    }
  }

  #if AC_COLLECTIONS_INTERNAL_CHECKS
    @usableFromInline
    internal var copyCount: UInt {
      get { __header_ptr.pointee.copyCount }
      set { __header_ptr.pointee.copyCount = newValue }
    }
  #endif
}

extension ___Tree {
  /// O(1)
  @nonobjc
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
  @nonobjc
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
  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___clearDestroy() {
    _header.destroyNode = .nullptr
    _header.destroyCount = 0
  }
}

extension ___Tree {

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___is_garbaged(_ p: _NodePtr) -> Bool {
    __node_ptr[p].__parent_ == .nullptr
  }
}

#if AC_COLLECTIONS_INTERNAL_CHECKS
  extension ___Tree {

    /// O(*k*)
    @usableFromInline
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

  @nonobjc
  @inlinable
  @inline(__always)
  internal func __construct_node(_ k: _Value) -> _NodePtr {
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

  @nonobjc
  @inlinable
  @inline(__always)
  internal func destroy(_ p: _NodePtr) {
    ___pushDestroy(p)
  }
}

extension ___Tree {

  @nonobjc
  @inlinable
  @inline(__always)
  internal var count: Int {
    __header_ptr.pointee.count
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal var __size_: Int {
    get { __header_ptr.pointee.count }
    set { /* NOP */  }
  }

  @nonobjc
  @inlinable
  public var __begin_node_: _NodePtr {
    @inline(__always)
    _read { yield __header_ptr.pointee.__begin_node }
    @inline(__always)
    _modify {
      yield &__header_ptr.pointee.__begin_node
    }
  }
}

extension ___Tree {

  @nonobjc
  @inlinable
  @inline(__always)
  public func __get_value(_ p: _NodePtr) -> _Key {
    Base.__key(__node_ptr[p].__value_)
  }
}

extension ___Tree {

  public typealias _Value = Base._Value

  public typealias _Key = Base._Key

  @nonobjc
  @inlinable
  @inline(__always)
  internal func __value_(_ p: _NodePtr) -> Base._Value {
    __node_ptr[p].__value_
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___element(_ p: _NodePtr, _ __v: Base._Value) {
    __node_ptr[p].__value_ = __v
  }
}

extension ___Tree: FindProtocol {}
extension ___Tree: FindEqualProtocol {}
extension ___Tree: FindLeafProtocol {}
extension ___Tree: EqualProtocol {}
extension ___Tree: InsertNodeAtProtocol {}
extension ___Tree: InsertUniqueProtocol {}
extension ___Tree: InsertMultiProtocol {}
extension ___Tree: InsertLastProtocol {}
extension ___Tree: RemoveProtocol {}
extension ___Tree: EraseProtocol {}
extension ___Tree: EraseUniqueProtocol {}
extension ___Tree: EraseMultiProtocol {}
extension ___Tree: BoundProtocol {}
extension ___Tree: CountProtocol {}
extension ___Tree: TreeNodeProtocol {}
extension ___Tree: DistanceProtocol {}
extension ___Tree: CompareProtocol {}
extension ___Tree: CompareUniqueProtocol {}
extension ___Tree: CompareMultiProtocol {}
extension ___Tree: ValueComparator {}

extension ___Tree {
  @nonobjc
  @inlinable
  @inline(__always)
  internal func __parent_(_ p: _NodePtr) -> _NodePtr {
    assert(!___is_null_or_end(p))
    assert(___initialized_contains(p))
    return __node_ptr[p].__parent_
  }
  @nonobjc
  @inlinable
  @inline(__always)
  internal func __left_(_ p: _NodePtr) -> _NodePtr {
    ___is_null_or_end(p) ? _header.__left_ : __node_ptr[p].__left_
  }
  @nonobjc
  @inlinable
  @inline(__always)
  internal func __left_unsafe(_ p: _NodePtr) -> _NodePtr {
    assert(!___is_null_or_end(p))
    assert(___initialized_contains(p))
    return __node_ptr[p].__left_
  }
  @nonobjc
  @inlinable
  @inline(__always)
  internal func __right_(_ p: _NodePtr) -> _NodePtr {
    assert(!___is_null_or_end(p))
    assert(___initialized_contains(p))
    return __node_ptr[p].__right_
  }
  @nonobjc
  @inlinable
  @inline(__always)
  internal func __is_black_(_ p: _NodePtr) -> Bool {
    assert(!___is_null_or_end(p))
    assert(___initialized_contains(p))
    return __node_ptr[p].__is_black_
  }
  @nonobjc
  @inlinable
  @inline(__always)
  internal func __parent_unsafe(_ p: _NodePtr) -> _NodePtr {
    // 現在、beginに対する__tree_prev_iter(..)が不定動作となっている
    // 以下のコードで修正は可能だが、バランシングへの性能影響が大きいので
    // 呼び出し側でチェックする運用となっている
    // ___is_null_or_end(p) ? .nullptr : __parent_(p)
    assert(!___is_null_or_end(p))
    assert(___initialized_contains(p))
    return __parent_(p)
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func __root() -> _NodePtr {
    __header_ptr.pointee.__left_
  }
}

extension ___Tree {

  @nonobjc
  @inlinable
  @inline(__always)
  internal func __is_black_(_ lhs: _NodePtr, _ rhs: Bool) {
    assert(!___is_null_or_end(lhs))
    assert(___initialized_contains(lhs))
    __node_ptr[lhs].__is_black_ = rhs
  }
  @nonobjc
  @inlinable
  @inline(__always)
  internal func __parent_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    assert(!___is_null_or_end(lhs))
    assert(___initialized_contains(lhs))
    __node_ptr[lhs].__parent_ = rhs
  }
  @nonobjc
  @inlinable
  @inline(__always)
  internal func __left_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    if lhs == .end {
      _header.__left_ = rhs
    } else {
      assert(___initialized_contains(lhs))
      __node_ptr[lhs].__left_ = rhs
    }
  }
  @nonobjc
  @inlinable
  @inline(__always)
  internal func __right_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    assert(!___is_null_or_end(lhs))
    assert(___initialized_contains(lhs))
    __node_ptr[lhs].__right_ = rhs
  }
}

// MARK: -
extension ___Tree: CompareBothProtocol {
  @nonobjc
  @inlinable
  @inline(__always)
  var isMulti: Bool { Base.isMulti }
}

// MARK: -

extension ___Tree {

  @nonobjc
  @inlinable
  @inline(__always)
  internal func
    ___erase(_ __f: _NodePtr, _ __l: _NodePtr, _ action: (_Value) throws -> Void) rethrows
  {
    var __f = __f
    while __f != __l {
      try action(self[__f])
      __f = erase(__f)
    }
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func
    ___erase<Result>(
      _ __f: _NodePtr, _ __l: _NodePtr, _ initialResult: Result,
      _ nextPartialResult: (Result, _Value) throws -> Result
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

  @nonobjc
  @inlinable
  @inline(__always)
  internal func
    ___erase<Result>(
      _ __f: _NodePtr, _ __l: _NodePtr, into initialResult: Result,
      _ updateAccumulatingResult: (inout Result, _Value) throws -> Void
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
  @nonobjc
  @inlinable
  @inline(__always)
  internal func __eraseAll() {
    _header.clear()
    ___clearDestroy()
  }
}

extension ___Tree {

  @nonobjc
  @inlinable
  @inline(__always)
  internal var ___is_empty: Bool {
    count == 0
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal var ___capacity: Int {
    _header.capacity
  }

  @available(*, deprecated, renamed: "__begin_node")
  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___begin() -> _NodePtr {
    _header.__begin_node
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___end() -> _NodePtr {
    .end
  }
}

extension ___Tree {

  /// - Complexity: O(1)
  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___is_begin(_ p: _NodePtr) -> Bool {
    p == __begin_node_
  }

  /// - Complexity: O(1)
  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___is_end(_ p: _NodePtr) -> Bool {
    p == .end
  }

  /// - Complexity: O(1)
  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___is_root(_ p: _NodePtr) -> Bool {
    p == __root()
  }

  /// - Complexity: O(1)
  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___initialized_contains(_ p: _NodePtr) -> Bool {
    0..<_header.initializedCount ~= p
  }

  /// 真の場合、操作は失敗する
  ///
  /// 添え字アクセスチェック用
  ///
  /// endを無効として扱う
  /// - Complexity: O(1)
  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___is_subscript_null(_ p: _NodePtr) -> Bool {

    // 初期化済みチェックでnullptrとendは除外される
    //    return !___initialized_contains(p) || ___is_garbaged(p)
    // begin -> false
    // end -> true
    return ___is_null_or_end(p) || _header.initializedCount <= p || ___is_garbaged(p)
  }

  /// 真の場合、操作は失敗する
  ///
  /// beginを有効として扱う
  ///
  /// endを無効として扱う
  /// - Complexity: O(1)
  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___is_next_null(_ p: _NodePtr) -> Bool {
    ___is_subscript_null(p)
  }

  /// 真の場合、操作は失敗する
  ///
  /// beginを無効として扱う
  ///
  /// endを有効として扱う
  /// - Complexity: O(1)
  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___is_prev_null(_ p: _NodePtr) -> Bool {

    // begin -> true
    // end -> false
    return p == .nullptr || _header.initializedCount <= p || ___is_begin(p) || ___is_garbaged(p)
  }

  /// 真の場合、操作は失敗する
  ///
  /// 範囲チェック用
  ///
  /// endを有効として扱う
  /// - Complexity: O(1)
  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___is_offset_null(_ p: _NodePtr) -> Bool {
    return p == .nullptr || _header.initializedCount <= p || ___is_garbaged(p)
  }

  /// 真の場合、操作は失敗する
  ///
  /// `end..<end`のケースを有効として扱う
  ///
  /// ベースコレクションの場合、回収済みでさえなければ、`start..<end`に必ず含まれているので、範囲チェックを省略している
  /// - Complexity: O(1)
  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___is_range_null(_ p: _NodePtr, _ l: _NodePtr) -> Bool {
    // end..<endのケースを許可するため、左辺を___is_offset_nullとしている
    ___is_offset_null(p) || ___is_offset_null(l)
  }
}

extension ___Tree {

  @nonobjc
  @inlinable
  @inline(__always)
  func ___ensureValid(after i: _NodePtr) {
    if ___is_next_null(i) {
      fatalError(.invalidIndex)
    }
  }

  @nonobjc
  @inlinable
  @inline(__always)
  func ___ensureValid(before i: _NodePtr) {
    if ___is_prev_null(i) {
      fatalError(.invalidIndex)
    }
  }

  @nonobjc
  @inlinable
  @inline(__always)
  func ___ensureValid(offset i: _NodePtr) {
    if ___is_offset_null(i) {
      fatalError(.invalidIndex)
    }
  }

  @nonobjc
  @inlinable
  @inline(__always)
  func ___ensureValid(subscript i: _NodePtr) {
    if ___is_subscript_null(i) {
      fatalError(.invalidIndex)
    }
  }

  @nonobjc
  @inlinable
  @inline(__always)
  func ___ensureValid(begin i: _NodePtr, end j: _NodePtr) {
    if ___is_range_null(i, j) {
      fatalError(.invalidIndex)
    }
  }
}

// MARK: -

extension ___Tree {

  @nonobjc
  @inlinable
  @inline(__always)
  func sequence(_ __first: _NodePtr, _ __last: _NodePtr) -> ___SafePointers<Base> {
    .init(tree: self, start: __first, end: __last)
  }

  @nonobjc
  @inlinable
  @inline(__always)
  func unsafeSequence(_ __first: _NodePtr, _ __last: _NodePtr) -> ___UnsafePointers<Base> {
    .init(tree: self, __first: __first, __last: __last)
  }
  
  @nonobjc
  @inlinable
  @inline(__always)
  func unsafeValues(_ __first: _NodePtr, _ __last: _NodePtr) -> ___UnsafeValues<Base> {
    .init(tree: self, __first: __first, __last: __last)
  }
}

extension ___Tree {

  @nonobjc
  @inlinable
  @inline(__always)
  func ___for_each_(__p: _NodePtr, __l: _NodePtr, body: (_NodePtr) throws -> Void)
    rethrows
  {
    for __c in sequence(__p, __l) {
      try body(__c)
    }
  }

  @nonobjc
  @inlinable
  @inline(__always)
  func ___rev_for_each_(__p: _NodePtr, __l: _NodePtr, body: (_NodePtr) throws -> Void)
    rethrows
  {
    for __c in sequence(__p, __l).reversed() {
      try body(__c)
    }
  }
}

extension ___Tree {

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___for_each(
    __p: _NodePtr, __l: _NodePtr, body: (_NodePtr, inout Bool) throws -> Void
  )
    rethrows
  {
    for __c in sequence(__p, __l) {
      var cont = true
      try body(__c, &cont)
      if !cont {
        break
      }
    }
  }
}

// MARK: -

extension ___Tree {

  // この実装がないと、迷子になる?
  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___distance(from start: _NodePtr, to end: _NodePtr) -> Int {
    guard
      !___is_offset_null(start),
      !___is_offset_null(end)
    else {
      fatalError(.invalidIndex)
    }
    return ___signed_distance(start, end)
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___index(after i: _NodePtr) -> _NodePtr {
    ___ensureValid(after: i)
    return __tree_next(i)
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___formIndex(after i: inout _NodePtr) {
    i = ___index(after: i)
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___index(before i: _NodePtr) -> _NodePtr {
    ___ensureValid(before: i)
    return __tree_prev_iter(i)
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___formIndex(before i: inout _NodePtr) {
    i = ___index(before: i)
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___index(_ i: _NodePtr, offsetBy distance: Int) -> _NodePtr {
    ___ensureValid(offset: i)
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
        guard i != __begin_node_ else {
          fatalError(.outOfBounds)
        }
        i = ___index(before: i)
        distance += 1
      }
    }
    return i
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___formIndex(_ i: inout _NodePtr, offsetBy distance: Int) {
    i = ___index(i, offsetBy: distance)
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___index(_ i: _NodePtr, offsetBy distance: Int, limitedBy limit: _NodePtr)
    -> _NodePtr?
  {
    ___ensureValid(offset: i)
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
        guard i != __begin_node_ else {
          fatalError(.outOfBounds)
        }
        i = ___index(before: i)
        distance += 1
      }
    }
    return i
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___formIndex(_ i: inout _NodePtr, offsetBy distance: Int, limitedBy limit: _NodePtr)
    -> Bool
  {
    if let ii = ___index(i, offsetBy: distance, limitedBy: limit) {
      i = ii
      return true
    }
    return false
  }
}

// MARK: -

extension ___Tree {

  public typealias _Values = RedBlackTreeIterator<Base>.Values

  @nonobjc
  @inlinable
  @inline(__always)
  func makeIterator() -> _Values {
    .init(tree: self, start: __begin_node_, end: __end_node())
  }
}

extension ___Tree where Base: KeyValueComparer {

  public typealias _KeyValues = RedBlackTreeIterator<Base>.KeyValues

  @nonobjc
  @inlinable
  @inline(__always)
  func makeIterator() -> _KeyValues {
    .init(tree: self, start: __begin_node_, end: __end_node())
  }
}

// MARK: -

extension ___Tree {

  @nonobjc
  @inlinable
  @inline(__always)
  public func ___tree_adv_iter(_ i: _NodePtr, by distance: Int) -> _NodePtr {
    ___ensureValid(offset: i)
    var distance = distance
    var result: _NodePtr = i
    while distance != 0 {
      if 0 < distance {
        if result == __end_node() { return result }
        result = __tree_next_iter(result)
        distance -= 1
      } else {
        if result == __begin_node_ {
          // 後ろと区別したくてnullptrにしてたが、一周回るとendなのでendにしてみる
          result = .end
          return result
        }
        result = __tree_prev_iter(result)
        distance += 1
      }
    }
    return result
  }
}

// MARK: -

extension ___Tree {

  public typealias Index = RedBlackTreeIndex<Base>

  @nonobjc
  @inlinable
  @inline(__always)
  func makeIndex(rawValue: _NodePtr) -> Index {
    .init(tree: self, rawValue: rawValue)
  }
}

extension ___Tree {

  public typealias Indices = RedBlackTreeIndices<Base>

  @nonobjc
  @inlinable
  @inline(__always)
  func makeIndices(start: _NodePtr, end: _NodePtr) -> Indices {
    .init(tree: self, start: start, end: end)
  }
}

extension ___Tree where Base: KeyValueComparer {

  @nonobjc
  @inlinable
  @inline(__always)
  func ___mapped_value(_ __p: _NodePtr) -> Base._MappedValue {
    Base.___mapped_value(self[__p])
  }

  @nonobjc
  @inlinable
  @inline(__always)
  func ___with_mapped_value<T>(_ __p: _NodePtr, _ f: (inout Base._MappedValue) throws -> T)
    rethrows -> T
  {
    try Base.___with_mapped_value(&self[__p], f)
  }
}

extension ___Tree {

  @nonobjc
  @inlinable
  @inline(__always)
  func ___filter(
    _ __first: _NodePtr,
    _ __last: _NodePtr,
    _ isIncluded: (_Value) throws -> Bool
  )
    rethrows -> ___Tree
  {
    var tree: Tree = .create(minimumCapacity: 0)
    var (__parent, __child) = tree.___max_ref()
    for __p in unsafeSequence(__first, __last)
    where try isIncluded(__value_(__p)) {
      Tree.ensureCapacity(tree: &tree)
      (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __value_(__p))
      assert(tree.__tree_invariant(tree.__root()))
    }
    return tree
  }
}

extension ___Tree where Base: KeyValueComparer {

  @nonobjc
  @inlinable
  @inline(__always)
  func ___mapValues<Other>(
    _ __first: _NodePtr,
    _ __last: _NodePtr,
    _ transform: (Base._MappedValue) throws -> Other._MappedValue
  )
    rethrows -> ___Tree<Other>
  where
    Other: KeyValueComparer,
    Other._Key == Base._Key
  {
    let other = ___Tree<Other>.create(minimumCapacity: count)
    var (__parent, __child) = other.___max_ref()
    for __p in unsafeSequence(__first, __last) {
      let __mapped_value = try transform(___mapped_value(__p))
      (__parent, __child) = other.___emplace_hint_right(
        __parent, __child, Other.__value_(__get_value(__p), __mapped_value))
      assert(other.__tree_invariant(other.__root()))
    }
    return other
  }

  @nonobjc
  @inlinable
  @inline(__always)
  func ___compactMapValues<Other>(
    _ __first: _NodePtr,
    _ __last: _NodePtr,
    _ transform: (Base._MappedValue) throws -> Other._MappedValue?
  )
    rethrows -> ___Tree<Other>
  where
    Other: KeyValueComparer,
    Other._Key == Base._Key
  {
    var other = ___Tree<Other>.create(minimumCapacity: count)
    var (__parent, __child) = other.___max_ref()
    for __p in unsafeSequence(__first, __last) {
      guard let __mv = try transform(___mapped_value(__p)) else { continue }
      ___Tree<Other>.ensureCapacity(tree: &other)
      (__parent, __child) = other.___emplace_hint_right(
        __parent, __child, Other.__value_(__get_value(__p), __mv))
      assert(other.__tree_invariant(other.__root()))
    }
    return other
  }
}

extension ___Tree {

  @nonobjc
  @inlinable
  @inline(__always)
  public static var isMulti: Bool { Base.isMulti }
}

extension ___Tree {
  
  @nonobjc
  @inlinable
  @inline(__always)
  func isIdentical(to other: ___Tree) -> Bool {
    self === other
  }
}

extension ___Tree: Equatable where _Value: Equatable {
  
  @inlinable
  @inline(__always)
  public static func == (lhs: ___Tree<Base>, rhs: ___Tree<Base>) -> Bool {
    
    if lhs.count != rhs.count {
      return false
    }
    
    if lhs.count == 0 || lhs.isIdentical(to: rhs) {
      return true
    }
    
    return lhs.elementsEqual(lhs.__begin_node_,
                             lhs.__end_node(),
                             rhs.unsafeValues(rhs.__begin_node_, rhs.__end_node()),
                             by: ==)
  }
}

extension ___Tree: Comparable where _Value: Comparable {
  
  @inlinable
  @inline(__always)
  public static func < (lhs: ___Tree<Base>, rhs: ___Tree<Base>) -> Bool {
    !lhs.isIdentical(to: rhs) &&
    lhs.lexicographicallyPrecedes(
      lhs.__begin_node_,
      lhs.__end_node(),
      rhs.unsafeValues(rhs.__begin_node_, rhs.__end_node()),
      by: <)
  }
}

extension ___Tree: Hashable where _Value: Hashable {
  
  @inlinable
  public func hash(into hasher: inout Hasher) {
    hasher.combine(header)
    for node in unsafeValues(__begin_node_, __end_node()) {
      hasher.combine(node)
    }
  }
}

extension ___Tree {
  
  @inlinable
  public func elementsEqual<OtherSequence>(_ __first: _NodePtr, _ __last: _NodePtr,_ other: OtherSequence, by areEquivalent: (_Value, OtherSequence.Element) throws -> Bool) rethrows -> Bool where OtherSequence : Sequence {
    try unsafeValues(__first, __last).elementsEqual(other, by: areEquivalent)
  }
}

extension ___Tree {

  @inlinable
  public func lexicographicallyPrecedes<OtherSequence>(_ __first: _NodePtr, _ __last: _NodePtr,_ other: OtherSequence, by areInIncreasingOrder: (_Value, _Value) throws -> Bool) rethrows -> Bool where OtherSequence : Sequence, _Value == OtherSequence.Element {
    try unsafeValues(__first, __last).lexicographicallyPrecedes(other, by: areInIncreasingOrder)
  }
}

extension ___Tree {
  
  @inlinable
  public func ___copy_to_array(_ __first: _NodePtr, _ __last: _NodePtr) -> [_Value] {
    let count = __distance(__first, __last)
    return .init(unsafeUninitializedCapacity: count) { buffer, initializedCount in
      initializedCount = count
      var buffer = buffer.baseAddress!
      var __first = __first
      while __first != __last {
        buffer.initialize(to: self[__first])
        buffer = buffer + 1
        __first = __tree_next_iter(__first)
      }
    }
  }
  
  @inlinable
  public func ___copy_to_array<T>(_ __first: _NodePtr, _ __last: _NodePtr, transform: (_Value) -> T) -> [T] {
    let count = __distance(__first, __last)
    return .init(unsafeUninitializedCapacity: count) { buffer, initializedCount in
      initializedCount = count
      var buffer = buffer.baseAddress!
      var __first = __first
      while __first != __last {
        buffer.initialize(to: transform(self[__first]))
        buffer = buffer + 1
        __first = __tree_next_iter(__first)
      }
    }
  }
}
