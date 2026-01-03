#if DEBUG
extension UnsafeTree {

  package func ___NodePtr(_ p: Int) -> _NodePtr {
    switch p {
    case .nullptr:
      return nullptr
    case .end:
      return end
    default:
      return _header[p] ?? nullptr
    }
  }
}

extension UnsafeTree {

  package func __left_(_ p: Int) -> Int {
    __left_(___NodePtr(p)).pointee.___node_id_
  }

  package func __left_(_ p: Int,_ l: Int) {
    __left_(___NodePtr(p), ___NodePtr(l))
  }

  package func __right_(_ p: Int) -> Int {
    __right_(___NodePtr(p)).pointee.___node_id_
  }
  
  package func __right_(_ p: Int,_ l: Int) {
    __right_(___NodePtr(p), ___NodePtr(l))
  }

  package func __parent_(_ p: Int) -> Int {
    __parent_(___NodePtr(p)).pointee.___node_id_
  }
  
  package func __parent_(_ p: Int,_ l: Int) {
    __parent_(___NodePtr(p), ___NodePtr(l))
  }

  package func __is_black_(_ p: Int) -> Bool {
    __is_black_(___NodePtr(p))
  }

  package func __is_black_(_ p: Int, _ b: Bool) {
    __is_black_(___NodePtr(p), b)
  }
  
  package func __value_(_ p: Int) -> _Value {
    __value_(___NodePtr(p))
  }
  
  package func ___element(_ p: Int, _ __v: _Value) {
    ___element(___NodePtr(p), __v)
  }
}

extension UnsafeTree {

  package func destroy(_ p: Int) {
    _header.___pushRecycle(_header[p])
  }
}

extension UnsafeMutablePointer where Pointee == UnsafeNode {
  package var index: Int { pointee.___node_id_ }
}

extension Optional where Wrapped == UnsafeMutablePointer<UnsafeNode> {
  package var index: Int { self?.pointee.___node_id_ ?? .nullptr }
}
#endif
