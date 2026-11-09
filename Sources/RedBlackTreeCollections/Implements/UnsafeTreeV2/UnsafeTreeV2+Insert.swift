//
//  UnsafeTreeV2+Insert.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/11/09.
//

extension UnsafeTreeV2 {

  @inlinable
  func ___simple_retrieve(_ __parent: _NodePtr) -> _NodePtr {
    __parent.___is_end ? __end_node : _buffer.header[__parent.trackingTag]
  }

  @inlinable
  func ___retrieve(
    _ __parent: _NodePtr,
    _ __child: _NodeRef
  ) -> (__parent: _NodePtr, __child: _NodeRef) {
    let __p = ___simple_retrieve(__parent)
    if __parent.__left_ref == __child {
      return (__p, __p.__left_ref)
    } else if __parent.__right_ref == __child {
      return (__p, __p.__right_ref)
    } else {
      fatalError("Invalid parent child pair.")
    }
  }
}

extension UnsafeTreeV2 {

  @inlinable
  mutating func ___insert_unique_if_not_present(
    _ __k: _PayloadValue
  ) -> (__r: _NodePtr, __inserted: Bool) {
    var (__parent, __child) = __find_equal(__key(__k))
    let __e = __end_node
    if __child.pointee != nullptr { return (__child.pointee, false) }
    ensureUniqueAndCapacity()  // これが問題で全体をupdate内には移せない

    if __e != __end_node {  // 木の不一致判定
      (__parent, __child) = ___retrieve(__parent, __child)
    }
    let __h = __construct_node(__k)
    __insert_node_at(__parent, __child, __h)
    return (__h, true)
  }
}

extension UnsafeTreeV2 where Base: ScalarValueTrait {
  
  public mutating func insert(
    _ newMember: _PayloadValue,
    hint: UnsafeIndexV3
  ) -> (inserted: Bool, indexAfterInsert: UnsafeIndexV3) {
    guard var __p = __purified_(hint).pointer else { fatalError() }
    var __dummy = nullptr
    
    // 問題が起きる可能性がすこしある
    var (__parent, __child) = __find_equal(__p, &__dummy, __key(newMember))

    if __child.pointee != nullptr {
      return (false, index(__child.pointee))
    }
    
    ensureUniqueAndCapacity()
    
    (__parent, __child) = ___retrieve(__parent, __child)
    __p = ___simple_retrieve(__p)
    
    let __h = __construct_node(newMember)
    __insert_node_at(__parent, __child, __h)
    
    return (true, index(__h))
  }
}
