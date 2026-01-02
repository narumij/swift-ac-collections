extension UnsafeTree {
  @nonobjc
  @inlinable
  @inline(__always)
  package func __left_(_ p: Int) -> Int {
    _header[p]?.pointee.__left_?.pointee.___node_id_ ?? .nullptr
  }
}

extension UnsafeTree {
  @nonobjc
  @inlinable
  @inline(__always)
  package func destroy(_ p: Int) {
    _header.___pushRecycle(_header[p])
  }
}
