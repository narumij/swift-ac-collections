extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal func withHeader<R>(
    _ body: (UnsafeTreeV2Buffer<_Value>.Header) throws -> R
  )
    rethrows -> R
  {
    // withUnsafeMutablePointerToHeaderだとスタックが一個ふえてみづらいので
    try _buffer.withUnsafeMutablePointers { header, _ in
      return try body(header.pointee)
    }
  }

  @inlinable
  @inline(__always)
  internal func withMutableHeader<R>(
    _ body: (inout UnsafeTreeV2Buffer<_Value>.Header) throws -> R
  )
    rethrows -> R
  {
    // withUnsafeMutablePointerToHeaderだとスタックが一個ふえてみづらいので
    try _buffer.withUnsafeMutablePointers { header, _ in
      return try body(&header.pointee)
    }
  }

  @inlinable
  @inline(__always)
  internal func withOrigin<R>(
    _ body: (UnsafeTreeV2Origin) throws -> R
  )
    rethrows -> R
  {
    // withUnsafeMutablePointerToElementsだとスタックが一個ふえてみづらいので
    try _buffer.withUnsafeMutablePointers { _, origin in
      return try body(origin.pointee)
    }
  }

  @inlinable
  @inline(__always)
  internal func withMutableOrigin<R>(
    _ body: (inout UnsafeTreeV2Origin) throws -> R
  )
    rethrows -> R
  {
    // withUnsafeMutablePointerToElementsだとスタックが一個ふえてみづらいので
    try _buffer.withUnsafeMutablePointers { _, origin in
      return try body(&origin.pointee)
    }
  }

  @inlinable
  @inline(__always)
  internal func withImmutables<R>(
    _ body: (
      UnsafeTreeV2Buffer<_Value>.Header,
      UnsafeTreeV2Origin
    ) throws -> R
  ) rethrows -> R {
    try _buffer.withUnsafeMutablePointers { header, elements in
      return try body(header.pointee, elements.pointee)
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
}
