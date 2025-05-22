import Foundation

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

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

