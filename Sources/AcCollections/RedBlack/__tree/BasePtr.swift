import Foundation

enum BasePtr: Equatable {
    case none
    case end
    case node(Int)
}

extension BasePtr: ExpressibleByNilLiteral {
    init(nilLiteral: ()) {
        self = .none
    }
}

extension BasePtr: ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {
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
    var index: Int? {
        switch self {
        case .node(let offset):
            return offset
        case .none:
            return nil
        case .end:
            return nil
        }
    }
}

