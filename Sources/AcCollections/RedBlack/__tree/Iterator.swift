import Foundation

protocol ___iter_protocol: Equatable, ExpressibleByNilLiteral {
    associatedtype __value_type
    mutating func next() -> __value_type?
    mutating func prev() -> __value_type?
    static func += (lhs: inout Self, rhs: Int)
    static func -= (lhs: inout Self, rhs: Int)
}

protocol ___tree_node_iter_protocol: ___tree_node_ptr_protocol & ___iter_protocol {
    
    var __ptr_: Self { get }
    func value() -> __value_type
    func pointer() -> Self
    func __get_np() -> Self
}

extension ___tree_node_iter_protocol {
    var __ptr_: Self { self }
    func value() -> __value_type { __value_ }
    func pointer() -> Self { self }
    func __get_np() -> Self { self }
}
