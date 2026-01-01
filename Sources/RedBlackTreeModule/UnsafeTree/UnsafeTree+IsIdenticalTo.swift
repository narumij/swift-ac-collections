extension UnsafeTree {

  @nonobjc
  @inlinable
  @inline(__always)
  internal func isIdentical(to other: UnsafeTree) -> Bool {
    self === other
  }
}

extension UnsafeTree: Hashable where _Value: Hashable {

  @inlinable
  public func hash(into hasher: inout Hasher) {
    fatalError()
  }
}
