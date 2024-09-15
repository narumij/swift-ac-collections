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

protocol ___tree_base_ptr_basic_members: ___tree_base_with_pointer_type
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
}

protocol ___tree_base_size_member {
    var size: Int { get nonmutating set }
}

protocol ___tree_base_ref_basic_members: ___tree_base_with_reference_type {
    associatedtype __node_ref_type
    var __root_ptr: __node_ref_type { get }
}

protocol ___tree_base_iter_basic_members: ___tree_base_with_iterator_type & ___tree_base_ptr_members {
    func begin() -> __node_iter_type
    func end() -> __node_iter_type
}

extension ___tree_base_iter_basic_members {
    func begin() -> __node_iter_type { __begin_node }
    func end() -> __node_iter_type { __end_node }
}

protocol ___tree_insert_base: ___tree_base_with_reference_type & ___tree_base_ptr_members & ___tree_base_size_member { }

protocol ___tree_find_base: ___tree_base_with_reference_type, ___tree_base_ptr_basic_members {
    var __root_ptr: __node_ref_type { get }
    func addressof(_ ptr: __node_ref_type) -> __node_ref_type
}

extension ___tree_find_base {
    var __root_ptr: __node_ref_type { __end_node.__left_ref }
    func addressof(_ ptr: __node_ref_type) -> __node_ref_type { ptr }
}

protocol ___tree_find_leaf: ___tree_find_base, ___tree_base_iter_basic_members {
    
    func
    __find_leaf_low(_ __parent: inout __node_ptr_type, _ __v: __value_type) -> __node_ref_type

    func
    __find_leaf_high(_ __parent: inout __node_ptr_type, _ __v: __value_type) -> __node_ref_type
}

protocol ___tree_remove_base: ___tree_base_with_iterator_type & ___tree_base_ptr_members & ___tree_base_size_member {
}

protocol ___tree_erase_unique: ___tree_remove_base & ___tree_base_iter_basic_members {
    associatedtype iterator where iterator == __node_iter_type
    func find(_ __v: __value_type) -> __node_iter_type
    func destroy(_ k: __node_ptr_type)
}

protocol ___tree_find: ___tree_insert_base & ___tree_find_base & ___tree_base_iter_basic_members & ___tree_remove_base {
}

protocol ___tree_insert_unique: ___tree_find {
    
    func __construct_node(_ k: __value_type) -> __node_ptr_type
}

