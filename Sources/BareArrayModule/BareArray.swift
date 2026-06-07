/// 競技プログラミング用多次元配列
///
/// ヒープ領域に確保される軽量な多次元配列です。
/// 動的計画法などで利用する大きな配列を簡潔に記述できます。
///
/// 要素は連続したメモリ領域に格納され、C言語の配列に近いアクセス性能を持ちます。
public struct BareArray<Element>: ~Copyable {

  @inlinable
  init(repeating value: Element, count: Int) {
    let capacity = count
    self.payload = .allocate(capacity: capacity)
    self.payload.initialize(repeating: value, count: capacity)
    self.count = count
  }

  @inlinable
  init(count: Int, _ f: () -> Element) {
    let capacity = count
    self.payload = .allocate(capacity: capacity)
    for i in 0..<count {
      (payload + i).initialize(to: f())
    }
    self.count = count
  }

  @usableFromInline let count: Int
  @usableFromInline let payload: UnsafeMutablePointer<Element>

  @inlinable
  public subscript(position: Int) -> Element {
    @inline(__always)
    unsafeAddress {
      precondition(0 <= position && position < count)
      return UnsafePointer(payload + position)
    }
    @inline(__always)
    unsafeMutableAddress {
      precondition(position < count)
      return payload + position
    }
  }

  deinit {
    self.payload.deinitialize(count: count)
    self.payload.deallocate()
  }
}

extension BareArray {

  public var indices: Range<Int> { 0..<count }
}

/// 競技プログラミング用多次元配列
///
/// ヒープ領域に確保される軽量な多次元配列です。
/// 動的計画法などで利用する大きな配列を簡潔に記述できます。
///
/// 要素は連続したメモリ領域に格納され、C言語の配列に近いアクセス性能を持ちます。
public struct BareArray2D<Element>: ~Copyable {

  @inlinable
  init(repeating value: Element, width: Int, height: Int) {
    self.capacity = height * width
    self.payload = .allocate(capacity: capacity)
    self.payload.initialize(repeating: value, count: capacity)
    self.width = width
    self.height = height
  }

  @inlinable
  init(width: Int, height: Int, _ f: () -> Element) {
    self.capacity = height * width
    self.payload = .allocate(capacity: capacity)
    for i in 0..<capacity {
      (payload + i).initialize(to: f())
    }
    self.width = width
    self.height = height
  }

  @usableFromInline let capacity: Int
  @usableFromInline let payload: UnsafeMutablePointer<Element>
  @usableFromInline let width: Int
  @usableFromInline let height: Int

  @inlinable
  public subscript(position: Int) -> BareArray1DView<Element> {

    @inline(__always)
    get {
      precondition(0 <= position && position < height)
      return .init(payload: payload + width * position, count: width)
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

extension BareArray2D {

  public var indices: Range<Int> { 0..<height }
}

/// 競技プログラミング用多次元配列
///
/// ヒープ領域に確保される軽量な多次元配列です。
/// 動的計画法などで利用する大きな配列を簡潔に記述できます。
///
/// 要素は連続したメモリ領域に格納され、C言語の配列に近いアクセス性能を持ちます。
public struct BareArray3D<Element>: ~Copyable {

  @inlinable
  init(repeating value: Element, width: Int, height: Int, depth: Int) {
    self.capacity = height * width * depth
    self.payload = .allocate(capacity: capacity)
    self.payload.initialize(repeating: value, count: capacity)
    self.width = width
    self.height = height
    self.depth = depth
  }

  @inlinable
  init(width: Int, height: Int, depth: Int, _ f: () -> Element) {
    self.capacity = height * width * depth
    self.payload = .allocate(capacity: capacity)
    for i in 0..<capacity {
      (payload + i).initialize(to: f())
    }
    self.width = width
    self.height = height
    self.depth = depth
  }

  @usableFromInline let capacity: Int
  @usableFromInline let payload: UnsafeMutablePointer<Element>
  @usableFromInline let width: Int
  @usableFromInline let height: Int
  @usableFromInline let depth: Int

  @inlinable
  public subscript(position: Int) -> BareArray2DView<Element> {

    @inline(__always)
    get {
      precondition(0 <= position && position < depth)
      return .init(payload: payload + width * height * position, width: width, height: height)
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

extension BareArray3D {

  public var indices: Range<Int> { 0..<depth }
}

public struct BareArray4D<Element>: ~Copyable {

  @inlinable
  init(repeating value: Element, size0: Int, size1: Int, size2: Int, size3: Int) {
    self.capacity = size0 * size1 * size2 * size3
    self.payload = .allocate(capacity: capacity)
    self.payload.initialize(repeating: value, count: capacity)
    self.size0 = size0
    self.size1 = size1
    self.size2 = size2
    self.size3 = size3
  }

  @inlinable
  init(size0: Int, size1: Int, size2: Int, size3: Int, _ f: () -> Element) {
    self.capacity = size0 * size1 * size2 * size3
    self.payload = .allocate(capacity: capacity)
    for i in 0..<capacity {
      (payload + i).initialize(to: f())
    }
    self.size0 = size0
    self.size1 = size1
    self.size2 = size2
    self.size3 = size3
  }

  @usableFromInline let capacity: Int
  @usableFromInline let payload: UnsafeMutablePointer<Element>
  @usableFromInline let size0: Int
  @usableFromInline let size1: Int
  @usableFromInline let size2: Int
  @usableFromInline let size3: Int

  @inlinable
  public subscript(position: Int) -> BareArray3DView<Element> {

    @inline(__always)
    get {
      precondition(0 <= position && position < size3)
      return .init(
        payload: payload + size0 * size1 * size2 * position, width: size0, height: size1,
        depth: size2)
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

extension BareArray4D {

  public var indices: Range<Int> { 0..<size3 }
}

// MARK: -

public struct BareArray1DView<Element> {

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
      precondition(position < count)
      return UnsafePointer(payload + position)
    }
    @inline(__always)
    unsafeMutableAddress {
      precondition(position < count)
      return payload + position
    }
  }
}

extension BareArray1DView {

  public var indices: Range<Int> { 0..<count }
}

public struct BareArray2DView<Element> {

  @inlinable
  internal init(payload: UnsafeMutablePointer<Element>, width: Int, height: Int) {
    self.capacity = height * width
    self.payload = payload
    self.width = width
    self.height = height
  }

  @usableFromInline let capacity: Int
  @usableFromInline let payload: UnsafeMutablePointer<Element>
  @usableFromInline let width: Int
  @usableFromInline let height: Int

  @inlinable
  public subscript(position: Int) -> BareArray1DView<Element> {

    @inline(__always)
    get {
      precondition(position < height)
      return .init(payload: payload + width * position, count: width)
    }

    @inline(__always)
    set {
      /* NOP */
    }
  }
}

extension BareArray2DView {

  public var indices: Range<Int> { 0..<height }
}

public struct BareArray3DView<Element> {

  @inlinable
  internal init(payload: UnsafeMutablePointer<Element>, width: Int, height: Int, depth: Int) {
    self.capacity = height * width
    self.payload = payload
    self.width = width
    self.height = height
    self.depth = depth
  }

  @usableFromInline let capacity: Int
  @usableFromInline let payload: UnsafeMutablePointer<Element>
  @usableFromInline let width: Int
  @usableFromInline let height: Int
  @usableFromInline let depth: Int

  @inlinable
  public subscript(position: Int) -> BareArray2DView<Element> {

    @inline(__always)
    get {
      precondition(position < depth)
      return .init(payload: payload + width * height * position, width: width, height: height)
    }

    @inline(__always)
    set {
      /* NOP */
    }
  }
}

extension BareArray3DView {

  public var indices: Range<Int> { 0..<depth }
}
