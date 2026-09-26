import Foundation
import RedBlackTreeCollections

#if false
extension _TrackingTag {
  var offset: Int! {
    switch self {
    case .end:
      return nil
    case .nullptr:
      return nil
    default:
      return Int(self)
    }
  }
}
#endif

extension _TrackingTag {
  var index: _TrackingTag! { self }
}
