import Foundation
import RedBlackTreeModule

extension _RawTrackingTag {
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

extension _RawTrackingTag {
  var index: Int! { self }
}
