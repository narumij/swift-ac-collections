import Foundation
import RedBlackTreeModule

extension _NodePtr {
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

extension _NodePtr {
  var index: Int! { self }
}

#if USE_UNSAFE_TREE
  extension UnsafeMutablePointer where Pointee == UnsafeNode {
    package var index: Int! { pointee.___node_id_ }
  }

  extension Optional where Wrapped == UnsafeMutablePointer<UnsafeNode> {
    package var index: Int! { self?.pointee.___node_id_ }
  }
#endif
