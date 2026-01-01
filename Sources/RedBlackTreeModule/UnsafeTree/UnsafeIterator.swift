@usableFromInline
struct UnsafeNodeIterator<_Value>: IteratorProtocol {

  @usableFromInline
  typealias Header = UnsafeNodeFreshBucket<_Value>

  @usableFromInline
  typealias HeaderPointer = UnsafeMutablePointer<Header>

  @usableFromInline
  typealias ElementPointer = UnsafeMutablePointer<UnsafeNode>

  @inlinable
  @inline(__always)
  internal init(pointer: HeaderPointer?) {
    self.pointer = pointer
  }

  @usableFromInline
  var pointer: HeaderPointer?

  @usableFromInline
  var offset: Int = 0

  @inlinable
  @inline(__always)
  mutating func next() -> ElementPointer? {

    while let h = pointer, offset == h.pointee.count {
      pointer = h.pointee.next
      offset = 0
    }

    guard let h = pointer else {
      return nil
    }

    defer { offset += 1 }

    // nodePointer(from:) + advance を使う
    let base = UnsafePair<_Value>.pointer(from: h.pointee.storage)
    return offset == 0
      ? base
      : UnsafePair<_Value>.advance(base, offset)
  }
}

@usableFromInline
struct UnsafeNodeConsumingIterator<_Value>: IteratorProtocol {

  @usableFromInline
  typealias Header = UnsafeNodeFreshBucket<_Value>
  @usableFromInline
  typealias HeaderPointer = UnsafeMutablePointer<Header>
  @usableFromInline
  typealias ElementPointer = UnsafeMutablePointer<UnsafeNode>

  @inlinable
  @inline(__always)
  internal init(pointer: HeaderPointer?) {
    self.pointer = pointer
  }

  @usableFromInline
  var pointer: HeaderPointer?

  @usableFromInline
  var offset: Int = 0

  @inlinable
  @inline(__always)
  mutating func next() -> ElementPointer? {

    while let h = pointer, offset == h.pointee.capacity {
      pointer = h.pointee.next
      offset = 0
    }

    guard let h = pointer else {
      return nil
    }

    //    defer {
    //      offset += 1
    //      h.pointee.count += 1
    //    }

    defer {
      offset += 1
      h.pointee.count += 1
      h.pointee.current =
        h.pointee.count < h.pointee.capacity
        ? UnsafePair<_Value>.advance(h.pointee.start, h.pointee.count)
        : nil
    }

    let base = UnsafePair<_Value>.pointer(from: h.pointee.storage)
    return offset == 0
      ? base
      : UnsafePair<_Value>.advance(base, offset)
  }
}
