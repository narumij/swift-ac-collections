//
//  unsafe_tree+insert.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/18.
//

@usableFromInline
protocol InsertNodeAtProtocol_ptr:
  _UnsafeNodePtrType
    & InsertNodeAtInterface
    & BeginNodeInterface
    & EndNodeProtocol
    & RootInterface
    & SizeInterface
    & _nullptr_interface
    & TreeAlgorithmProtocol_ptr
{}

extension InsertNodeAtProtocol_ptr {

  @inlinable
  @inline(never)
  internal func
    __insert_node_at(
      _ __parent: _NodePtr, _ __child: _NodeRef,
      _ __new_node: _NodePtr
    )
  {
    var __new_node = __new_node
    __new_node.__left_ = nullptr
    __new_node.__right_ = nullptr
    __new_node.__parent_ = __parent
    // __new_node->__is_black_ is initialized in __tree_balance_after_insert
    __child.pointee = __new_node
    // unsafe operation not allowed
    if __begin_node_.__left_ != nullptr {
      __begin_node_ = __begin_node_.__left_
    }
    //    _std__tree_balance_after_insert(__end_node.__left_, __child.pointee)
    _std__tree_balance_after_insert(__root, __child.pointee)
    __size_ += 1
  }
}

@usableFromInline
protocol InsertUniqueProtocol_ptr:
  _UnsafeNodePtrType
    & KeyInterface
    & InsertNodeAtInterface
    & InsertUniqueInterface
    & FindEqualInterface
    & AllocationInterface
    & _nullptr_interface
{}

extension InsertUniqueProtocol_ptr {

  @inlinable
  @inline(never)
  internal func
    __insert_unique(_ x: _Value) -> (__r: _NodePtr, __inserted: Bool)
  {
    __emplace_unique_key_args(x)
  }

  @inlinable
  @inline(never)
  internal func
    __emplace_unique_key_args(_ __k: _Value)
    -> (__r: _NodePtr, __inserted: Bool)
  {
    let (__parent, __child) = __find_equal(__key(__k))
    let __r = __child
    if __child.pointee == nullptr {
      let __h = __construct_node(__k)
      __insert_node_at(__parent, __child, __h)
      return (__h, true)
    } else {
      // __insert_node_atで挿入した場合、__rが破損する
      // 既存コードの後続で使用しているのが実質Ptrなので、そちらを返すよう一旦修正
      // 今回初めて破損したrefを使用したようで既存コードでの破損ref使用は大丈夫そう
      return (__r.pointee, false)
    }
  }
}

@usableFromInline
protocol InsertLastProtocol_ptr:
  _UnsafeNodePtrType
    & InsertLastInterface
    & InsertNodeAtInterface
    & AllocationInterface
    & EndInterface
    & EndNodeProtocol
    & RootInterface
    & _nullptr_interface
{}

extension InsertLastProtocol_ptr {

  @inlinable
  @inline(__always)
  internal func ___max_ref() -> (__parent: _NodePtr, __child: _NodeRef) {
    if __root == nullptr {
      return (__end_node, __end_node.__left_ref)
    }
    let __parent = __tree_max(__root)
    return (__parent, __parent.__right_ref)
  }

  @inlinable
  @inline(__always)
  internal func
    ___emplace_hint_right(_ __parent: _NodePtr, _ __child: _NodeRef, _ __k: _Value)
    -> (__parent: _NodePtr, __child: _NodeRef)
  {
    let __p = __construct_node(__k)
    __insert_node_at(__parent, __child, __p)
    return (__p, __p.__right_ref)
  }

  // こちらのほうがAPIとしては収まりがいいが、かすかに上のモノの方が速い
  // 分岐の有無の差だとおもわれる
  @inlinable
  @inline(__always)
  internal func ___emplace_hint_right(_ __p: _NodePtr, _ __k: _Value) -> _NodePtr {
    let __child = __p == end ? __end_node.__left_ref : __p.__right_ref
    //                        ^--- これの差
    let __h = __construct_node(__k)
    __insert_node_at(__p, __child, __h)
    return __h
  }

  @inlinable
  @inline(__always)
  internal func ___emplace_hint_left(_ __p: _NodePtr, _ __k: _Value) -> _NodePtr {
    let __child = __p.__left_ref
    let __h = __construct_node(__k)
    __insert_node_at(__p, __child, __h)
    return __h
  }
}
