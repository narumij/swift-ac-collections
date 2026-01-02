extension UnsafeTree {

  package func ___NodePtr(_ p: Int) -> _NodePtr {
    _header[p]
  }
}

extension UnsafeTree {

  package func __left_(_ p: Int) -> Int {
    __left_(___NodePtr(p))?.pointee.___node_id_ ?? .nullptr
  }

  package func __right_(_ p: Int) -> Int {
    __right_(___NodePtr(p))?.pointee.___node_id_ ?? .nullptr
  }

  package func __parent_(_ p: Int) -> Int {
    __parent_(___NodePtr(p))?.pointee.___node_id_ ?? .nullptr
  }
}

extension UnsafeTree {

  package func destroy(_ p: Int) {
    _header.___pushRecycle(_header[p])
  }
}

extension UnsafeMutablePointer where Pointee == UnsafeNode {
  package var index: Int! { pointee.___node_id_ }
}

extension Optional where Wrapped == UnsafeMutablePointer<UnsafeNode> {
  package var index: Int! { self?.pointee.___node_id_ }
}
