import Foundation

protocol ___tree_iterator_base_protocol: ___tree_const_base
where __value_type == __iter_pointer.__value_type
{
    associatedtype __iter_pointer: ___tree_node_value_protocol
    var __ptr_: __iter_pointer { get set }
    var __end_: __iter_pointer { get }
    var __begin_: __iter_pointer { get }
    
    associatedtype __value_type
}

extension ___tree_iterator_base_protocol {
    @discardableResult
    mutating func next() -> __value_type! {
        assert(__ptr_ != __end_)
        __ptr_ = Self.__tree_next_iter(__ptr_)
        if __ptr_ != __end_ {
            return __ptr_.__value_
        }
        return nil
    }
    @discardableResult
    mutating func prev() -> __value_type! {
        assert(__ptr_ != __begin_)
        __ptr_ = Self.__tree_prev_iter(__ptr_)
        return __ptr_.__value_
    }
    mutating func next(_ n: Int) -> Self {
        var it = self
        (0..<n).forEach{ _ in it.next() }
        return it
    }
    mutating func prev(_ n: Int) -> Self {
        var it = self
        (0..<n).forEach{ _ in it.prev() }
        return it
    }
}

protocol ___tree_iterator_protocol: ___tree_iterator_base_protocol, Equatable
where __iter_pointer: ___tree_node_ptr_protocol {
    func value() -> pointer.__value_type
    func pointer() -> pointer
}

extension ___tree_iterator_protocol {
    typealias reference = __iter_pointer.__node_ref_type
    typealias pointer = __iter_pointer.__node_ptr_type
}

