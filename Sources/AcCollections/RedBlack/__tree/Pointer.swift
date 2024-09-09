import Foundation

enum RawOffset: Equatable {
    case none
    case offset(Int)
}

extension RawOffset: ExpressibleByNilLiteral {
    init(nilLiteral: ()) {
        self = .none
    }
}

extension RawOffset {
    init<T>(offset: UnsafeOffset<T>) {
        switch offset {
        case .none:
            self = .none
        case .offset(_, let o):
            self = .offset(o)
        }
    }
    var index: Int? {
        if case .offset(let int) = self {
            return int
        }
        return nil
    }
}

enum UnsafeOffset<Pointee> {
    case none
    case offset(UnsafeMutableBufferPointer<Pointee>, Int)
}

extension UnsafeOffset: ExpressibleByNilLiteral {
    init(nilLiteral: ()) {
        self = .none
    }
}

extension UnsafeOffset: Equatable {
    static func == (lhs: UnsafeOffset<Pointee>, rhs: UnsafeOffset<Pointee>) -> Bool {
        switch lhs {
        case .none:
            if case .none = rhs {
                return true
            } else {
                return false
            }
        case .offset(let _ptr_l, let l):
            if case .none = rhs {
                return false
            } else if case .offset(let _ptr_r, let r) = lhs {
                return (_ptr_l.baseAddress! + l) == (_ptr_r.baseAddress! + r)
            } else {
                return false
            }
        }
    }
}

extension UnsafeOffset {
    init(pointer: UnsafeMutableBufferPointer<Pointee>, offset: RawOffset) {
        switch offset {
        case .none:
            self = .none
        case .offset(let o):
            self = .offset(pointer, o)
        }
    }
    var index: Int? {
        if case .offset(_, let int) = self {
            return int
        }
        return nil
    }
    static func node(pointer: UnsafeMutableBufferPointer<Pointee>,_ n: Int) -> Self {
        .offset(pointer, n)
    }
}

struct Item: Equatable {
    var isBlack: Bool
    var parent: Int?
    var left: Int?
    var right: Int?
}

extension UnsafeOffset where Pointee == Item {
    
    typealias Pointer = UnsafeOffset<Item>

    var __right_: Pointer {
        get {
            if case .offset(let ptr, let int) = self,
               let r = ptr[int].right {
                return .offset(ptr, r)
            }
            return .none
        }
        nonmutating set {
            switch self {
            case .offset(let ptr, let int):
                if case .offset(_, let n) = newValue {
                    ptr[int].right = n
                } else {
                    ptr[int].right = nil
                }
            case .none:
                break
            }
        }
    }
    var __parent_: Pointer {
        get {
            if case .offset(let ptr, let int) = self,
               let p = ptr[int].parent {
                return .offset(ptr, p)
            }
            return .none
        }
        nonmutating set {
            switch self {
            case .offset(let ptr, let int):
                if case .offset(_, let n) = newValue {
                    ptr[int].parent = n
                } else {
                    ptr[int].parent = nil
                }
            case .none:
                break
            }
        }
    }
    var __is_black_: Bool {
        get {
            if case .offset(let ptr, let int) = self {
                return ptr[int].isBlack
            }
            return false
        }
        nonmutating set {
            switch self {
            case .offset(let ptr, let int):
                ptr[int].isBlack = newValue
            case .none:
                break
            }
        }
    }
    var __left_: Pointer {
        get {
            if case .offset(let ptr, let int) = self,
               let l = ptr[int].left {
                return .offset(ptr, l)
            }
            return .none
        }
        nonmutating set {
            switch self {
            case .offset(let ptr, let int):
                if case .offset(_, let n) = newValue {
                    ptr[int].left = n
                } else {
                    ptr[int].left = nil
                }
            case .none:
                break
            }
        }
    }
    func __parent_unsafe() -> Self { __parent_ }
}

extension UnsafeOffset where Pointee == Item {

    enum Reference {
        case __parent_(Pointer)
        case __left_(Pointer)
        case __right_(Pointer)
        var referencee: Pointer {
            get {
                switch self {
                case .__parent_(let unsafeOffset):
                    return unsafeOffset.__parent_
                case .__left_(let unsafeOffset):
                    return unsafeOffset.__left_
                case .__right_(let unsafeOffset):
                    return unsafeOffset.__right_
                }
            }
            nonmutating set {
                switch self {
                case .__parent_(let unsafeOffset):
                    unsafeOffset.__parent_ = newValue
                case .__left_(let unsafeOffset):
                    unsafeOffset.__left_ = newValue
                case .__right_(let unsafeOffset):
                    unsafeOffset.__right_ = newValue
                }
            }
        }
    }
    
    var __parent_ref: Reference {
        .__parent_(self)
    }
    
    var __left_ref: Reference {
        .__left_(self)
    }
    
    var __right_ref: Reference {
        .__right_(self)
    }
}
