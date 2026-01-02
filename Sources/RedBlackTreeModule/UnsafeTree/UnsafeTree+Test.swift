extension UnsafeTree {
  @nonobjc
  @inlinable
  @inline(__always)
  package func __left_(_ p: Int) -> Int {
    _header[p]?.pointee.___node_id_ ?? .nullptr
  }
}
