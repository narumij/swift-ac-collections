//
//  File.swift
//  
//
//  Created by narumij on 2024/09/12.
//

import Foundation
@testable import AcCollections

var _left: BasePtr = nil
var _data: [NodeItem] = []

struct NodeItem: Equatable, NodeItemProtocol {
    var isBlack: Bool
    var parent: BasePtr
    var left: BasePtr
    var right: BasePtr
    var __value_: Int
}

extension BasePtr: ___tree_node_ptr_protocol {
    public static var nullptr: Self { .none }
}

extension BasePtr.Reference: ___ref_protocol {
    public static var nullptr: BasePtr.Reference { .none }
}

extension BasePtr {
    static var __root: BasePtr {
        get { __end_node.__left_ }
        set { __end_node.__left_ = newValue }
    }
    static var __end_node: BasePtr {
        .end
    }
    static func ___construct_node() -> BasePtr {
        let node = BasePtr.node(_data.count)
        _data.append(.init(isBlack: false, parent: nil, left: nil, right: nil, __value_: 0))
        return node
    }
}

extension BasePtr {
    
    fileprivate static var data: [NodeItem] {
        get { _data }
        set { _data = newValue }
    }
    
    public var __right_: BasePtr {
        get {
            switch self {
            case .node(let int):
                return Self.data[int].right
            case .end:
//                fatalError()
                return .none
            case .none:
                return .none
            }
        }
        nonmutating set {
            switch self {
            case .node(let int):
                Self.data[int].right = newValue
            case .end:
                fatalError()
            case .none:
//                fatalError()
                break
            }
        }
    }
    public var __parent_: BasePtr {
        get {
            switch self {
            case .node(let int):
                return Self.data[int].parent
            case .end:
//                fatalError()
                return .none
            case .none:
                return .none
            }
        }
        nonmutating set {
            switch self {
            case .node(let int):
                Self.data[int].parent = newValue
            case .end:
//                fatalError()
                break
            case .none:
                fatalError()
            }
        }
    }
    public var __is_black_: Bool {
        get {
            switch self {
            case .node(let int):
                return Self.data[int].isBlack
            case .end:
                fatalError()
            case .none:
                fatalError()
            }
        }
        nonmutating set {
            switch self {
            case .node(let int):
                Self.data[int].isBlack = newValue
            case .end:
//                fatalError()
                break
            case .none:
                fatalError()
            }
        }
    }
    public var __left_: BasePtr {
        get {
            switch self {
            case .node(let int):
                return Self.data[int].left
            case .end:
                return _left
            case .none:
                return .none
            }
        }
        nonmutating set {
            switch self {
            case .node(let int):
                Self.data[int].left = newValue
            case .end:
                _left = newValue
            case .none:
                fatalError()
            }
        }
    }
    public var __value_: Int {
        get {
            switch self {
            case .node(let int):
                return Self.data[int].__value_
            case .end:
                fatalError()
            case .none:
                fatalError()
            }
        }
        nonmutating set {
            switch self {
            case .node(let int):
                Self.data[int].__value_ = newValue
            case .end:
                fatalError()
            case .none:
                fatalError()
            }
        }
    }

    public func __parent_unsafe() -> BasePtr { __parent_ }
}

extension BasePtr {

    public enum Reference {
        public init(nilLiteral: ()) {
            self = .none
        }
        case none
        case __parent_(BasePtr)
        case __left_(BasePtr)
        case __right_(BasePtr)
        public var referencee: BasePtr {
            get {
                switch self {
                case .__parent_(let p):
                    return p.__parent_
                case .__left_(let p):
                    return p.__left_
                case .__right_(let p):
                    return p.__right_
                default:
                    break
                }
                fatalError()
            }
            nonmutating set {
                switch self {
                case .__parent_(let p):
                    p.__parent_ = newValue
                case .__left_(let p):
                    p.__left_ = newValue
                case .__right_(let p):
                    p.__right_ = newValue
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
        if __parent_.__left_ == self {
            return .__left_(__parent_)
        }
        if __parent_.__right_ == self {
            return .__right_(__parent_)
        }
        return .none
    }
    
    public enum _ValueRef {
        case __value_(BasePtr)
        var referencee: Int {
            get {
                switch self {
                case .__value_(let p):
                    return p.__value_
                }
            }
            nonmutating set {
                switch self {
                case .__value_(let p):
                    p.__value_ = newValue
                }
            }
        }
    }
    
    var __value_ref: _ValueRef {
        .__value_(self)
    }
}
