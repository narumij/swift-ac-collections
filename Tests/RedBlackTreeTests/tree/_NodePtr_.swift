import Foundation
import RedBlackTreeModule

extension _TrackingTag {
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

extension _TrackingTag {
  var index: Int! { self }
}
