import Foundation

protocol TreeNodeProtocol: Equatable {
    var isBlack: Bool { get set }
    var parent: BasePtr { get set }
    var left: BasePtr { get set }
    var right: BasePtr { get set }
}

protocol NodeItemProtocol: TreeNodeProtocol {
    associatedtype Element: Equatable
    var __value_: Element { get set }
}

protocol TreeHandleProtocol: Equatable {
    associatedtype NodeItem: NodeItemProtocol
    var __left_: BasePtr { get nonmutating set }
    subscript(index: Int) -> NodeItem { get nonmutating set }
}

enum HandlePtr<Handle>: Equatable where Handle: TreeHandleProtocol {
    case none
    case end(Handle)
    case node(Handle,Int)
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

extension HandlePtr: ___tree_node_pointer_protocol {
    static var nullptr: Self { .none }
}

extension HandlePtr.Reference: ___tree_node_reference_protocol {
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
                return handle.__left_.handlePtr(handle)
            case .none:
                fatalError()
            }
        }
        nonmutating set {
            switch self {
            case .node(let handle, let int):
                handle[int].left = newValue.basePtr
            case .end(let handle):
                handle.__left_ = newValue.basePtr
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
    
    public var __self_ref: Reference {
        switch self {
        case __parent_.__left_:
            return .__left_(__parent_)
        case __parent_.__right_:
            return .__right_(__parent_)
        default:
            return .none
        }
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
