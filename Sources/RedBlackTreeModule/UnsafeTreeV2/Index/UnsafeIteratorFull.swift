//
//  UnsafeIterator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/12.
//


@usableFromInline
struct UnsafeIteratorFull<Base: ___TreeBase & ___TreeIndex>: UnsafeTreeNodeProtocol {
  
  @usableFromInline
  init(__tree_ tree: UnsafeTreeV2<Base>) {
    self.init(nullptr: tree.nullptr,
          __begin_node_: tree.__begin_node_,
          __end_node: tree.__end_node,
          isMulti: tree.isMulti)
  }
  
  @usableFromInline
  internal init(nullptr: UnsafeMutablePointer<UnsafeNode>, __begin_node_: UnsafeIteratorFull<Base>._NodePtr, __end_node: UnsafeIteratorFull<Base>._NodePtr, isMulti: Bool) {
    self.nullptr = nullptr
    self.__begin_node_ = __begin_node_
    self.__end_node = __end_node
    self.isMulti = isMulti
  }
  
  
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  public typealias _NodeRef = UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>
  
  public var nullptr: UnsafeMutablePointer<UnsafeNode>
  @usableFromInline var __begin_node_: _NodePtr
  @usableFromInline var __end_node: _NodePtr
  @usableFromInline var isMulti: Bool

  @usableFromInline var end: UnsafeMutablePointer<UnsafeNode> {
    __end_node
  }
}

extension UnsafeIteratorFull: CompareBothProtocol, DistanceProtocol {
  
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
  
  @usableFromInline typealias _Key = Base._Key
}

extension UnsafeIteratorFull {

  @inlinable
  @inline(__always)
  internal func
    ___tree_adv_iter(_ i: _NodePtr, by distance: Int) -> _NodePtr
  {
//    ___ensureValid(offset: i)
    var distance = distance
    var result: _NodePtr = i
    while distance != 0 {
      if 0 < distance {
        if result == __end_node { return result }
        result = __tree_next_iter(result)
        distance -= 1
      } else {
        if result == __begin_node_ {
          // 後ろと区別したくてnullptrにしてたが、一周回るとendなのでendにしてみる
          result = end
          return result
        }
        result = __tree_prev_iter(result)
        distance += 1
      }
    }
    return result
  }
}
