import Foundation
import RedBlackTreeModule

extension _NodeRef {
  var index: Int! {
    #if USE_ENUM_NODE_REF
      switch self {
      case .__right_(let p):
        return p
      case .__left_(let p):
        return p
      }
    #else
      switch self {
      case ~0:
        return .end
      default:
        return .init(bitPattern: self & ~(1 << (Self.bitWidth - 1)))
      }
    #endif
  }
}
