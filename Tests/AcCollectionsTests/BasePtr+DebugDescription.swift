import Foundation
@testable import AcCollections

extension BasePtr: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .none:
            return ".none"
        case .end:
            return ".end"
        case .node(let int):
            return ".node(\(int))"
        }
    }
}

