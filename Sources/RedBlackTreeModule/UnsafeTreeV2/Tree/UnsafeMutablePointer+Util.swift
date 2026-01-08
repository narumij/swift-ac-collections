
extension UnsafeMutablePointer {
  @inlinable
  @inline(__always)
  func _assumingUnbound() -> UnsafeMutableRawPointer {
    UnsafeMutableRawPointer(self)
  }
}
