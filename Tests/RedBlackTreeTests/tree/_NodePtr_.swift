import Foundation
import RedBlackTreeModule

extension _PointerIndex {
  var offset: Int! {
    switch self {
    case .end:
      return nil
    case .nullptr:
      return nil
    default:
      return self
    }
  }
}

extension _PointerIndex {
  var index: Int! { self }
}
