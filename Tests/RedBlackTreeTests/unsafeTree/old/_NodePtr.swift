import RedBlackTreeModule

#if USE_UNSAFE_TREE
  extension UnsafeMutablePointer where Pointee == UnsafeNode {
    package var index: Int! { pointee.___node_id_ }
  }

  extension Optional where Wrapped == UnsafeMutablePointer<UnsafeNode> {
    package var index: Int! { self?.pointee.___node_id_ }
  }
#endif
