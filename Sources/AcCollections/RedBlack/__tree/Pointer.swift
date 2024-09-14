import Foundation

protocol __tree_node_const_protocol: Equatable, ExpressibleByNilLiteral, CustomDebugStringConvertible {
    associatedtype __node_ptr_type
    where __node_ptr_type == Self
    var __left_:   __node_ptr_type { get }
    var __right_:  __node_ptr_type { get }
    var __parent_: __node_ptr_type { get }
    var __is_black_: Bool  { get }
    func __parent_unsafe() -> __node_ptr_type
    static var nullptr: Self { get }
}

protocol ___tree_node_protocol: __tree_node_const_protocol {
    var __left_:   __node_ptr_type { get nonmutating set }
    var __right_:  __node_ptr_type { get nonmutating set }
    var __parent_: __node_ptr_type { get nonmutating set }
    var __is_black_: Bool  { get nonmutating set }
}

protocol ___tree_node_value_protocol: ___tree_node_protocol {
    associatedtype __value_type
    var __value_: __value_type { get nonmutating set }
}

protocol ___tree_node_ref_protocol: ___tree_node_protocol {
    associatedtype __node_ref_type
    where __node_ref_type: ___ref_protocol,
          __node_ref_type.__wrapped_type == __node_ptr_type
    var __parent_ref: __node_ref_type { get }
    var __left_ref:   __node_ref_type { get }
    var __right_ref:  __node_ref_type { get }
}

protocol ___tree_node_ptr_protocol:
    ___tree_node_protocol & ___tree_node_value_protocol & ___tree_node_ref_protocol
{
    
}

// 内部イテレータと外部イテレータを別々に実装すること
