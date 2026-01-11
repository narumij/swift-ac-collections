@frozen
@usableFromInline
struct UnsafeTreeV2CommonHandle<_Value> {
  @inlinable
  internal init(
    header: UnsafeMutablePointer<UnsafeTreeV2Buffer<_Value>.Header>,
    origin: UnsafeMutablePointer<UnsafeTreeV2Origin>
  ) {
    self.header = header
    self.origin = origin
  }
  public typealias _Value = _Value
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  @usableFromInline let header: UnsafeMutablePointer<UnsafeTreeV2Buffer<_Value>.Header>
  @usableFromInline let origin: UnsafeMutablePointer<UnsafeTreeV2Origin>
}

extension UnsafeTreeV2 {

  @usableFromInline
  typealias CommonHandle = UnsafeTreeV2CommonHandle<UnsafeTreeV2<Base>._Value>

  @inlinable
  @inline(__always)
  internal func withMutableHeader<R>(
    _ body: (inout UnsafeTreeV2Buffer<_Value>.Header) throws -> R
  )
    rethrows -> R
  {
    try _buffer.withUnsafeMutablePointerToHeader { header in
      return try body(&header.pointee)
    }
  }

  @inlinable
  @inline(__always)
  internal func withMutables<R>(
    _ body: (
      inout UnsafeTreeV2Buffer<_Value>.Header,
      inout UnsafeTreeV2Origin
    ) throws -> R
  ) rethrows -> R {
    try _buffer.withUnsafeMutablePointers { header, elements in
      return try body(&header.pointee, &elements.pointee)
    }
  }

  @inlinable
  @inline(__always)
  internal func withandler<R>(
    _ body: (UnsafeTreeV2CommonHandle<_Value>) throws -> R
  ) rethrows -> R {
    try _buffer.withUnsafeMutablePointers { header, elements in
      let handle = UnsafeTreeV2CommonHandle<_Value>(header: header, origin: elements)
      return try body(handle)
    }
  }
}
