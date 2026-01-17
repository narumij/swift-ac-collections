//
//  UnsafeIterator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/12.
//

// TODO: 利用時の寿命管理の確認
// 寿命延長を行わないので、利用側で寿命安全を守る必要がある

public struct UnsafeImmutableTree<Base: ___TreeBase>: UnsafeTreeNodeProtocol {

  public typealias _Key = Base._Key

  @usableFromInline
  init(__tree_ tree: UnsafeTreeV2<Base>) {
    self.nullptr = tree.nullptr
    self.__begin_node_ = tree.__begin_node_
    self.__end_node = tree.__end_node
    self.isMulti = tree.isMulti
    self.count = tree.count
    self.initializedCount = tree.initializedCount
  }

  public let nullptr: UnsafeMutablePointer<UnsafeNode>
  @usableFromInline let __begin_node_: _NodePtr
  @usableFromInline let __end_node: _NodePtr
  @usableFromInline let isMulti: Bool
  @usableFromInline let count: Int
  @usableFromInline let initializedCount: Int
}

extension UnsafeImmutableTree {

  public var end: UnsafeMutablePointer<UnsafeNode> {
    __end_node
  }
}

extension UnsafeImmutableTree: CompareBothProtocol, DistanceProtocol {

  @usableFromInline
  func value_comp(_ l: Base._Key, _ r: Base._Key) -> Bool {
    Base.value_comp(l, r)
  }

  @usableFromInline
  func __get_value(_ p: UnsafeMutablePointer<UnsafeNode>) -> Base._Key {
    Base.__key(p.__value_().pointee)
  }

  @usableFromInline
  var __root: UnsafeMutablePointer<UnsafeNode> {
    __end_node.pointee.__left_
  }

  @usableFromInline
  typealias __node_value_type = Base._Key
}

extension UnsafeImmutableTree: Validation {}

extension UnsafeImmutableTree {

  public func advanced(_ __ptr_: _NodePtr, by n: Int) -> _NodePtr {
    ___ensureValid(offset: __ptr_)
    var n = n
    var __ptr_ = __ptr_
    while n != 0 {
      if n < 0 {
        // 後ろと区別したくてnullptrにしてたが、一周回るとendなのでendにしてみる
        if __ptr_ == __begin_node_ { return __end_node }
        __ptr_ = __tree_prev_iter(__ptr_)
        n += 1
      } else {
        if __ptr_ == __end_node { return __end_node }
        __ptr_ = __tree_next_iter(__ptr_)
        n -= 1
      }
    }
    return __ptr_
  }
}

extension UnsafeImmutableTree {

  @inlinable
  @inline(__always)
  internal func isTriviallyIdentical(to other: UnsafeImmutableTree<Base>) -> Bool {
    self.__end_node == other.__end_node
  }
}

// MARK: -

extension UnsafeImmutableTree {

  // TODO: `__value_`も名前混乱があるので、調査し、必要なら修正すること
  @inlinable
  @inline(__always)
  package func __value_(_ p: _NodePtr) -> Base._Value {
    p.__value_().pointee
  }

  @inlinable
  @inline(__always)
  package func ___element(_ p: _NodePtr, _ __v: Base._Value) {
    p.__value_().pointee = __v
  }
}

// MARK: -

extension UnsafeImmutableTree {

  @inlinable
  @inline(__always)
  internal func
    sequence(_ __first: _NodePtr, _ __last: _NodePtr) -> ___UnsafeRemoveAwareWrapper<___UnsafeNaiveIterator>
  {
    .init(__tree_: self, start: __first, end: __last)
  }

  @inlinable
  @inline(__always)
  internal func
    unsafeSequence(_ __first: _NodePtr, _ __last: _NodePtr)
    -> ___UnsafePointersUnsafeV2
  {
    .init(__tree_: self, start: __first, end: __last)
  }

  @inlinable
  @inline(__always)
  internal func
    unsafeValues(_ __first: _NodePtr, _ __last: _NodePtr)
    -> ___UnsafeValueWrapper<Base, ___UnsafeNaiveIterator>
  {
    .init(__tree_: self, start: __first, end: __last)
  }
}

extension UnsafeImmutableTree {

  @inlinable
  @inline(__always)
  internal func
    ___for_each_(__p: _NodePtr, __l: _NodePtr, body: (_NodePtr) throws -> Void)
    rethrows
  {
    for __c in sequence(__p, __l) {
      try body(__c)
    }
  }

  @inlinable
  @inline(__always)
  internal func ___rev_for_each_(
    __p: _NodePtr, __l: _NodePtr, body: (_NodePtr) throws -> Void
  )
    rethrows
  {
    for __c in sequence(__p, __l).reversed() {
      try body(__c)
    }
  }
}

extension UnsafeImmutableTree {

  // この実装がないと、迷子になる?
  @inlinable
  @inline(__always)
  internal func
    ___distance(from start: _NodePtr, to end: _NodePtr) -> Int
  {
    guard
      !___is_offset_null(start),
      !___is_offset_null(end)
    else {
      fatalError(.invalidIndex)
    }
    return ___signed_distance(start, end)
  }
}
