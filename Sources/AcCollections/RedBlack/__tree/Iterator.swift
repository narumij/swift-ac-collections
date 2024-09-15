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

// MARK: -

public protocol SequenceTree {
    associatedtype Element
    func value(_ p: BasePtr) -> Element
    func next(_ p: BasePtr) -> BasePtr
    func prev(_ p: BasePtr) -> BasePtr
    func begin() -> BasePtr
    func end() -> BasePtr
}

public struct BaseIterator<Tree>: Comparable, IteratorProtocol where Tree: SequenceTree {
    nonmutating func current() -> Tree.Element? {
        return __ptr_ != __tree_.end() ? __tree_.value(__ptr_) : nil
    }
    public mutating func next() -> Tree.Element? {
        defer {
            if __ptr_ != __end_ {
                __ptr_ = __tree_.next(__ptr_)
            }
        }
        return current()
    }
    mutating func prev() -> Tree.Element? {
        if __ptr_ != __begin {
            __ptr_ = __tree_.prev(__ptr_)
        }
        return current()
    }
    var __tree_: Tree
    var __ptr_: BasePtr
    var __begin: BasePtr
    var __end_: BasePtr
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.__ptr_ == rhs.__ptr_
    }
    public static func < (lhs: Self, rhs: Self) -> Bool {
        fatalError("not implemented yet")
    }
    static func + (lhs: Self, rhs: Int) -> Self {
        var l = lhs
        for _ in 0 ..< rhs {
            _ = l.next()
        }
        return l
    }
    static func - (lhs: Self, rhs: Int) -> Self {
        var l = lhs
        for _ in 0 ..< rhs {
            _ = l.prev()
        }
        return l
    }
}

