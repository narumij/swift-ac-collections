public struct SubBuffer<Element> {

  @inlinable
  internal init(payload: UnsafeMutablePointer<Element>, count: Int) {
    self.count = count
    self.payload = payload
  }

  @usableFromInline let count: Int
  @usableFromInline let payload: UnsafeMutablePointer<Element>

  @inlinable
  public subscript(position: Int) -> Element {
    @inline(__always)
    unsafeAddress {
      return UnsafePointer(payload + position)
    }
    @inline(__always)
    unsafeMutableAddress {
      return payload + position
    }
  }
}

extension SubBuffer: Sequence {

  public var indices: Range<Int> { 0..<count }

  public func makeIterator() -> Iterator {
    .init(count: count, payload: payload)
  }

  public struct Iterator: IteratorProtocol {
    var current: Int = 0
    var count: Int
    var payload: UnsafePointer<Element>
    public mutating func next() -> Element? {
      guard current < count else { return nil }
      defer { current += 1 }
      return payload[current]
    }
  }
}

public struct SubBuffer2D<Element> {

  @inlinable
  internal init(payload: UnsafeMutablePointer<Element>, W: Int, H: Int) {
    self.capacity = H * W
    self.payload = payload
    self.size = (W, H)
  }

  @usableFromInline let capacity: Int
  @usableFromInline let payload: UnsafeMutablePointer<Element>
  @usableFromInline let size: (width: Int, height: Int)

  @inlinable
  public subscript(position: Int) -> SubBuffer<Element> {
    @inline(__always)
    get {
      .init(payload: payload + size.width * position, count: size.width)
    }

    @inline(__always)
    set {
      /* NOP */
    }
  }
}

public struct RawBuffer2D<Element>: ~Copyable {

  @inlinable
  init(repeating value: Element, W: Int, H: Int) {
    self.capacity = H * W
    self.payload = .allocate(capacity: capacity)
    self.payload.initialize(repeating: value, count: capacity)
    self.size = (W, H)
  }

  @usableFromInline let capacity: Int
  @usableFromInline let size: (width: Int, height: Int)
  @usableFromInline let payload: UnsafeMutablePointer<Element>

  @inlinable
  public subscript(position: Int) -> SubBuffer<Element> {
    @inline(__always)
    get {
      .init(payload: payload + size.width * position, count: size.width)
    }

    @inline(__always)
    set {
      /* NOP */
    }
  }

  deinit {
    self.payload.deinitialize(count: capacity)
    self.payload.deallocate()
  }
}

public struct RawBuffer3D<Element>: ~Copyable {

  @inlinable
  init(repeating value: Element, W: Int, H: Int, D: Int) {
    self.capacity = H * W * D
    self.payload = .allocate(capacity: capacity)
    self.payload.initialize(repeating: value, count: capacity)
    self.size = (W, H, D)
  }

  @usableFromInline let capacity: Int
  @usableFromInline let size: (width: Int, height: Int, depth: Int)
  @usableFromInline let payload: UnsafeMutablePointer<Element>

  @inlinable
  public subscript(position: Int) -> SubBuffer2D<Element> {
    @inline(__always)
    get {
      .init(payload: payload + size.width * size.height * position, W: size.width, H: size.height)
    }

    @inline(__always)
    set {
      /* NOP */
    }
  }

  deinit {
    self.payload.deinitialize(count: capacity)
    self.payload.deallocate()
  }
}
