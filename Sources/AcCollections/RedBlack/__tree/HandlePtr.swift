import Foundation

protocol TreeHandleProtocol: ___tree_const_base {
    associatedtype NodeItem: NodeItemProtocol
    var __begin: BasePtr { get }
    var __end_left_: BasePtr { get nonmutating set }
    subscript(index: Int) -> NodeItem { get nonmutating set }
}

enum HandlePtr<Handle> where Handle: TreeHandleProtocol {
    case none
    case end(Handle)
    case node(Handle,Int)
}

extension HandlePtr: Equatable {
    static func == (lhs: HandlePtr<Handle>, rhs: HandlePtr<Handle>) -> Bool {
        switch (lhs, rhs) {
        case (.none,.none):
            return true
        case (.end,.end):
            return true
        case (.node(_,let l),.node(_,let r)):
            return l == r
        default:
            break
        }
        return false
    }
}

extension HandlePtr: ExpressibleByNilLiteral {
    init(nilLiteral: ()) {
        self = .none
    }
}

extension HandlePtr: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .none:
            return ".none"
        case .end(_):
            return ".end"
        case .node(_, let int):
            return ".node(\(int))"
        }
    }
}

extension HandlePtr {
    var basePtr: BasePtr {
        switch self {
        case .node(_, let int):
            return .node(int)
        case .end(_):
            return .end
        case .none:
            return .none
        }
    }
}

extension HandlePtr {
    var index: Int? {
        switch self {
        case .node(_, let int):
            return int
        case .end(_):
            return nil
        case .none:
            return nil
        }
    }
}

extension HandlePtr: ___tree_node_ptr_protocol {
    static var nullptr: Self { .none }
}

extension HandlePtr.Reference: ___ref_protocol {
    static var nullptr: Self { .none }
}

extension HandlePtr {
    
    public var __right_: HandlePtr {
        get {
            switch self {
            case .node(let handle, let int):
                return handle[int].right.handlePtr(handle)
            default:
                fatalError()
            }
        }
        nonmutating set {
            switch self {
            case .node(let handle, let int):
                handle[int].right = newValue.basePtr
            default:
                fatalError()
            }
        }
    }
    public var __parent_: HandlePtr {
        get {
            switch self {
            case .node(let handle, let int):
                return handle[int].parent.handlePtr(handle)
            default:
                fatalError()
            }
        }
        nonmutating set {
            switch self {
            case .node(let handle, let int):
                handle[int].parent = newValue.basePtr
            default:
                fatalError()
            }
        }
    }
    public var __is_black_: Bool {
        get {
            switch self {
            case .node(let handle, let int):
                return handle[int].isBlack
            default:
                fatalError()
            }
        }
        nonmutating set {
            switch self {
            case .node(let handle, let int):
                handle[int].isBlack = newValue
            default:
                fatalError()
            }
        }
    }
    public var __left_: HandlePtr {
        get {
            switch self {
            case .node(let handle, let int):
                return handle[int].left.handlePtr(handle)
            case .end(let handle):
                return handle.__end_left_.handlePtr(handle)
            case .none:
                fatalError()
            }
        }
        nonmutating set {
            switch self {
            case .node(let handle, let int):
                handle[int].left = newValue.basePtr
            case .end(let handle):
                handle.__end_left_ = newValue.basePtr
            case .none:
                fatalError()
            }
        }
    }
    public var __value_: Handle.NodeItem.Element {
        get {
            switch self {
            case .node(let handle, let int):
                return handle[int].__value_
            default:
                fatalError()
            }
        }
        nonmutating set {
            switch self {
            case .node(let handle,let int):
                handle[int].__value_ = newValue
            default:
                fatalError()
            }
        }
    }

    public func __parent_unsafe() -> HandlePtr { __parent_ }
}

extension HandlePtr {
    
    public typealias __node_ref_type = HandlePtr<Handle>.Reference

    public enum Reference {
        public init(nilLiteral: ()) {
            self = .none
        }
        case none
        case __parent_(HandlePtr<Handle>)
        case __left_(HandlePtr<Handle>)
        case __right_(HandlePtr<Handle>)
        public var referencee: HandlePtr<Handle> {
            get {
                switch self {
                case .__parent_(let p):
                    return p.__parent_
                case .__left_(let l):
                    return l.__left_
                case .__right_(let r):
                    return r.__right_
                default:
                    break
                }
                fatalError()
            }
            nonmutating set {
                switch self {
                case .__parent_(let p):
                    p.__parent_ = newValue
                case .__left_(let l):
                    l.__left_ = newValue
                case .__right_(let r):
                    r.__right_ = newValue
                default:
                    fatalError()
                }
            }
        }
    }
    
    public var __parent_ref: Reference {
        .__parent_(self)
    }
    
    public var __left_ref: Reference {
        .__left_(self)
    }
    
    public var __right_ref: Reference {
        .__right_(self)
    }
    
    public enum _ValueRef {
        case __value_(HandlePtr<Handle>)
        var referencee: Handle.NodeItem.Element {
            get {
                switch self {
                case .__value_(let v):
                    return v.__value_
                }
            }
            nonmutating set {
                switch self {
                case .__value_(let v):
                    v.__value_ = newValue
                }
            }
        }
    }
    
    var __value_ref: _ValueRef {
        .__value_(self)
    }
}

extension HandlePtr: ___tree_node_iter_protocol {
    
    var __is_end_: Bool {
        switch self {
        case .end(_):
            return true
        default:
            return false
        }
    }
    var __is_begin: Bool {
        switch self {
        case .node(let handle,_):
            return handle.__begin == self.basePtr
        default:
            return false
        }
    }
    mutating func next() -> __value_type? {
        assert(!__ptr_.__is_end_)
        self = Handle.__tree_next_iter(__ptr_)
        if !__ptr_.__is_end_ {
            return __ptr_.__value_
        }
        return nil
    }
    mutating func prev() -> __value_type? {
        if __is_begin {
            return nil
        }
        self = Handle.__tree_prev_iter(self)
        return __value_
    }
    static func -= (lhs: inout HandlePtr<Handle>, rhs: Int) {
        for _ in 0..<rhs {
            _ = lhs.prev()
        }
    }
    static func += (lhs: inout HandlePtr<Handle>, rhs: Int) {
        for _ in 0..<rhs {
            _ = lhs.next()
        }
    }
    var __ptr_: Self { self }
}

protocol HandlePtrFactory {
    associatedtype Handle: TreeHandleProtocol
    var handle: Handle { get }
}

extension HandlePtrFactory {
    func __node(_ n: Int) -> HandlePtr<Handle> { .node(handle, n) }
    func __end() -> HandlePtr<Handle> { .end(handle) }
    func __none() -> HandlePtr<Handle> { .none }
}

