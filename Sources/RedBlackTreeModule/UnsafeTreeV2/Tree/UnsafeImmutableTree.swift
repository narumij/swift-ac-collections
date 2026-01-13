//
//  UnsafeIterator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/12.
//

@usableFromInline
struct UnsafeImmutableTree<Base: ___TreeBase>: UnsafeTreeNodeProtocol {

  @usableFromInline typealias _Key = Base._Key

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

  @usableFromInline var end: UnsafeMutablePointer<UnsafeNode> {
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
    Base.__key(UnsafePair<Base._Value>.valuePointer(p).pointee)
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
