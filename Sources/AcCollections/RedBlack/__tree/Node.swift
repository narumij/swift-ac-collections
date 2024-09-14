import Foundation

protocol ___tree_base_with_pointer_type: ___tree_base
where __node_ptr_type: ___tree_node_ptr_protocol,
      __node_ptr_type.__value_type == __value_type
{
    associatedtype __value_type
    static var value_comp: (__value_type, __value_type) -> Bool { get }
    associatedtype __node_ptr_type
}

protocol ___tree_base_with_reference_type: ___tree_base_with_pointer_type
where __node_ref_type: ___ref_protocol,
      __node_ref_type == __node_ptr_type.__node_ref_type,
      __node_ref_type.__wrapped_type == __node_ptr_type
{
    associatedtype __node_ref_type
}

protocol ___tree_base_with_iterator_type: ___tree_base_with_pointer_type
where __node_iter_type: ___tree_node_iter_protocol,
      __node_iter_type == __node_ptr_type
{
    associatedtype __node_iter_type
}

protocol ___tree_base_ptr_basic_members: ___tree_base
where Self: ___tree_base_with_pointer_type
{
    associatedtype __node_ptr_type
    var __root: __node_ptr_type { get nonmutating set }
    var __end_node: __node_ptr_type { get }
}

extension ___tree_base_ptr_basic_members {
    var __root: __node_ptr_type {
        get { __end_node.__left_ }
        nonmutating set { __end_node.__left_ = newValue }
    }
}

protocol ___tree_base_ptr_members: ___tree_base_ptr_basic_members {
    var __begin_node: __node_ptr_type { get nonmutating set }
    var size: Int { get nonmutating set }
}

protocol ___tree_base_ref_basic_members: ___tree_base
where Self: ___tree_base_with_reference_type
{
    associatedtype __node_ref_type
    var __root_ptr: __node_ref_type { get }
}

protocol ___tree_base_iter_basic_members: ___tree_base
where Self: ___tree_base_with_iterator_type
{
    func begin() -> __node_iter_type
    func end() -> __node_iter_type
}

protocol ___tree_find_base: ___tree_base, ___tree_base_with_reference_type {
    var __root: __node_ptr_type { get }
    var __end_node: __node_ptr_type { get }
    var __root_ptr: __node_ref_type { get }
    func addressof(_ ptr: __node_ref_type) -> __node_ref_type
}

extension ___tree_find_base {
    var __root_ptr: __node_ref_type {
        __end_node.__left_ref
    }
    func addressof(_ ptr: __node_ref_type) -> __node_ref_type { ptr }
}

protocol ___tree_insert_base: ___tree_base_with_reference_type & ___tree_base_ptr_members { }

protocol ___tree_find_leaf: ___tree_find_base, ___tree_base_iter_basic_members {
    
    func
    __find_leaf_low(_ __parent: inout __node_ptr_type, _ __v: __value_type) -> __node_ref_type

    func
    __find_leaf_high(_ __parent: inout __node_ptr_type, _ __v: __value_type) -> __node_ref_type
}

//protocol ___tree_clear_base: ___tree_find_base & ___tree_base_ptr_members {
//    func destroy(_: __node_ptr_type)
//}
//
//protocol ___tree_construct_base: ___tree_insert_base & ___tree_base_with_iterator_type {
//    func __construct_node(_ : __value_type) -> __node_ptr_type
//    func iterator(_ r: __node_ref_type) -> __node_iter_type
//    func
//    __find_equal(_ __parent: inout __node_ptr_type, _ __v: __value_type) -> __node_ref_type
//}

protocol ___tree_remove_base: ___tree_base_ptr_members & ___tree_base_with_iterator_type { }
