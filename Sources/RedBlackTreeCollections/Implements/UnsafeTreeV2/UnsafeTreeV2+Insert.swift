//
//  UnsafeTreeV2+Insert.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/11/09.
//

extension UnsafeTreeV2 {

  @inlinable
  func __simple_retrieve(_ __p: _NodePtr) -> _NodePtr {
    __p.___is_end ? __end_node : _buffer.header[__p.trackingTag]
  }

  @inlinable
  func __simple_retrieve(
    _ __parent: _NodePtr,
    _ __child: _NodeRef
  ) -> (__parent: _NodePtr, __child: _NodeRef) {
    let __p = __simple_retrieve(__parent)
    if __parent.__left_ref == __child {
      return (__p, __p.__left_ref)
    } else if __parent.__right_ref == __child {
      return (__p, __p.__right_ref)
    } else {
      fatalError("Invalid parent child pair.")
    }
  }
}

#if true
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
      (__parent, __child) = __simple_retrieve(__parent, __child)
    }
    let __h = __construct_node(__k)
    __insert_node_at(__parent, __child, __h)
    return (__h, true)
  }

  @inlinable
  mutating func __emplace_hint_unique_if_not_present(
    _ __k: _PayloadValue,_ __p: _NodePtr
  ) -> (__r: _NodePtr, __inserted: Bool) {
    
    var __dummy = nullptr
    let __e = __end_node

    // 問題が起きる可能性がすこしある
    var (__parent, __child) = __find_equal(__p, &__dummy, __key(__k))

    if __child.pointee != nullptr {
      return (__child.pointee, false)
    }
    
    ensureUniqueAndCapacity()
    
    if __e != __end_node {  // 木の不一致判定
      (__parent, __child) = __simple_retrieve(__parent, __child)
    }
    
    let __h = __construct_node(__k)
    __insert_node_at(__parent, __child, __h)
    
    return (__h, true)
  }
}

#else

// チューニング作業中
extension UnsafeTreeV2 where Base: ScalarValueTrait {

  @inlinable
  mutating func ___insert_unique_if_not_present(
    _ __k: _PayloadValue
  ) -> (__r: _NodePtr, __inserted: Bool) {
    var (__parent, __child) = update { $0.__find_equal(__key(__k)) }
    if __child.pointee != nullptr { return (__child.pointee, false) }
    
    let __e = __end_node
    ensureUniqueAndCapacity()  // これが問題で全体をupdate内には移せない
    if __e != __end_node {  // 木の不一致判定
      (__parent, __child) = __simple_retrieve(__parent, __child)
    }
    
    let __h = __construct_node(__k)
    __insert_node_at(__parent, __child, __h)
    return (__h, true)
  }

  @inlinable
  mutating func __emplace_hint_unique_if_not_present(
    _ __k: _PayloadValue,_ __p: _NodePtr
  ) -> (__r: _NodePtr, __inserted: Bool) {
    
    var __dummy = nullptr

    // 問題が起きる可能性がすこしある
    var (__parent, __child) = update { $0.__find_equal(__p, &__dummy, __key(__k)) }

    if __child.pointee != nullptr {
      return (__child.pointee, false)
    }
    
    let __e = __end_node
    ensureUniqueAndCapacity()
    if __e != __end_node {  // 木の不一致判定
      (__parent, __child) = __simple_retrieve(__parent, __child)
    }
    
    let __h = __construct_node(__k)
    __insert_node_at(__parent, __child, __h)
    return (__h, true)
  }
}

extension UnsafeTreeV2 where Base: PairValueTrait {

  @inlinable
  mutating func ___insert_unique_if_not_present(
    _ __k: _PayloadValue
  ) -> (__r: _NodePtr, __inserted: Bool) {
    var (__parent, __child) = update { $0.__find_equal(__key(__k)) }
    if __child.pointee != nullptr { return (__child.pointee, false) }
    let __e = __end_node
    ensureUniqueAndCapacity()  // これが問題で全体をupdate内には移せない

    if __e != __end_node {  // 木の不一致判定
      (__parent, __child) = __simple_retrieve(__parent, __child)
    }
    let __h = __construct_node(__k)
    __insert_node_at(__parent, __child, __h)
    return (__h, true)
  }

  @inlinable
  mutating func __emplace_hint_unique_if_not_present(
    _ __k: _PayloadValue,_ __p: _NodePtr
  ) -> (__r: _NodePtr, __inserted: Bool) {
    
    var __dummy = nullptr

    // 問題が起きる可能性がすこしある
    var (__parent, __child) = update { $0.__find_equal(__p, &__dummy, __key(__k)) }

    if __child.pointee != nullptr {
      return (__child.pointee, false)
    }
    
    let __e = __end_node
    ensureUniqueAndCapacity()
    if __e != __end_node {  // 木の不一致判定
      (__parent, __child) = __simple_retrieve(__parent, __child)
    }
    
    let __h = __construct_node(__k)
    __insert_node_at(__parent, __child, __h)
    return (__h, true)
  }
}
#endif
