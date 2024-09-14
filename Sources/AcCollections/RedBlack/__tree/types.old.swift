//
//  File.swift
//  
//
//  Created by narumij on 2024/09/10.
//

import Foundation

#if false
protocol __tree_end_node {
    associatedtype pointer
    var __left_: pointer { get nonmutating set }
}

protocol __tree_node_base: __tree_end_node {
    var __right_: pointer { get nonmutating set }
    associatedtype __parent_pointer
    var __parent_: __parent_pointer { get nonmutating set }
    var __is_black_: Bool { get nonmutating set }
    func __parent_unsafe() -> __parent_pointer
}

extension __tree_node_base {
    func __set_parent(_ __p: pointer) { __parent_ = __p as! __parent_pointer }
}

protocol __tree_node: __tree_node_base {
    associatedtype __node_value_type
    var __value_: __node_value_type { get nonmutating set }
    associatedtype __node_value_ptr_type
    var pointer: __node_value_ptr_type { get }
    associatedtype __node_value_ref_type
    var reference: __node_value_ref_type { get }
}

protocol __node_base_pointer: __tree_node_base, Equatable, ExpressibleByNilLiteral
where pointer == Self, __parent_pointer == Self
{ }

protocol __node_pointer: __node_base_pointer & __tree_node { }


protocol __end_node_pointer { }
protocol __iter_pointer { }

protocol __tree_iterator: Equatable {
    associatedtype _Node: __node_pointer
//    associatedtype _node_base_pointer: __node_base_pointer
//    associatedtype _end_node_pointer: __end_node_pointer
//    associatedtype _iter_pointer: __iter_pointer
//    var __ptr_: _iter_pointer { get set }
    var pointer: pointer { get }
    var reference: reference { get }
    func next()
    func prev()
}

extension __tree_iterator {
    typealias reference = _Node.__node_value_ref_type
    typealias pointer = _Node.__node_value_ptr_type
}

protocol __const_iterator {
    associatedtype Iteratee
    var iteratee: Iteratee { get }
}

protocol __iterator: __const_iterator {
    var iteratee: Iteratee { get nonmutating set }
}

protocol __const_ref: Equatable, ExpressibleByNilLiteral {
    associatedtype Referencee
    var referencee: Referencee { get  }
}

protocol _node_value_ptr {
    associatedtype __node_value_type
    var __value_:  __node_value_type { get }
}

protocol _node_ref_ptr {
    associatedtype    Ref: ___tree_node_reference_protocol
//    var __self_ref:   Ref { get }
    var __parent_ref: Ref { get }
    var __left_ref:   Ref { get }
    var __right_ref:  Ref { get }
}

protocol _node_base_ref: ___tree_node_reference_protocol { }

protocol ___tree_base_find: ___tree_base_with_value
where _NodePtr: _node_ref_ptr, _NodePtr.Ref == _NodeRef, _NodePtr == _NodeRef.Referencee
{
    associatedtype _NodePtr: __node_pointer
    associatedtype _NodeRef
    var __root: _NodePtr { get }
    var __end_node: _NodePtr { get }
}

protocol __RedBlackTree: ___tree_base & ___tree_base_find & ___tree_find_base where _NodePtr: ___tree_node_pointer_base_protocol {
    var __root_ptr: _NodePtr { get }
    var __begin_node: _NodePtr { get nonmutating set }
    func __construct_node() -> __node_holder
    func destroy(_: _NodePtr)
    var size: Int { get nonmutating set }
    associatedtype __tree_iterator
    func iterator(_ : _NodeRef) -> __tree_iterator
    func
    __insert_node_at(
        _ __parent: _NodePtr, _ __child: _NodeRef,
        _ __new_node: _NodePtr)
}

extension __RedBlackTree {
    typealias __node_holder = _NodePtr
}
#endif
