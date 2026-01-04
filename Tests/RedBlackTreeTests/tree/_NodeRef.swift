import Foundation
import RedBlackTreeModule

extension _PointerIndexRef {
  var index: Int! {
    switch self {
    case .__right_(let p):
      return p
    case .__left_(let p):
      return p
    }
  }
}
