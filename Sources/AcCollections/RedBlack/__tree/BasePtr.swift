import Foundation

public enum BasePtr: Equatable {
    case none
    case end
    case node(Int)
}

extension BasePtr: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .none
    }
}

extension BasePtr: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .node(value)
    }
}

extension BasePtr {
    func handlePtr<Handle>(_ handle: Handle) -> HandlePtr<Handle> {
        switch self {
        case .node(let offset):
            return .node(handle, offset)
        case .end:
            return .end(handle)
        case .none:
            return .none
        }
    }
}

extension BasePtr {
    var index: Int! {
        switch self {
        case .node(let offset):
            return offset
        case .none:
            return nil
        case .end:
            return nil
        }
    }
    
    var isNode: Bool {
        if case .node(_) = self {
            return true
        }
        return false
    }
    
    var isNone: Bool {
        if case .none = self {
            return true
        }
        return false
    }
    
    var isEnd: Bool {
        if case .end = self {
            return true
        }
        return false
    }

}

