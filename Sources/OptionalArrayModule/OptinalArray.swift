// コピペで提出に使っていただいて構いません。
// 提出の際のライセンス記載は不要です。

/// メモ化用配列
///
/// 配列ベースのメモ化に用いる配列です。
/// 未初期化値の番兵を用意することなく利用できます。
public struct OptionalArray1D<Element>: ~Copyable {

  @usableFromInline let count: Int
  @usableFromInline let hasPayload: UnsafeMutablePointer<Bool>
  @usableFromInline let payload: UnsafeMutablePointer<Element>

  @inlinable
  public init(capacity: Int) {
    self.count = capacity
    self.hasPayload = .allocate(capacity: capacity)
    self.hasPayload.initialize(repeating: false, count: capacity)
    self.payload = .allocate(capacity: capacity)
  }

  deinit {
    for i in 0..<count {
      if hasPayload[i] {
        (payload + i).deinitialize(count: 1)
      }
    }
    payload.deallocate()
    hasPayload.deinitialize(count: count)
    hasPayload.deallocate()
  }

  @inlinable
  public func removeAll() {
    for i in 0..<count {
      if hasPayload[i] {
        (payload + i).deinitialize(count: 1)
      }
    }
    hasPayload.update(repeating: false, count: count)
  }

  @inlinable
  public subscript(position: Int) -> Element? {

    @inline(__always)
    get {
      precondition(position < count)
      guard hasPayload[position] else {
        return nil
      }
      return payload[position]
    }

    @inline(__always)
    _modify {
      precondition(position < count)
      var value = hasPayload[position] ? (payload + position).move() : nil
      defer {
        if let value {
          hasPayload[position] = true
          (payload + position).initialize(to: value)
        } else {
          hasPayload[position] = false
          (payload + position).deinitialize(count: 1)
        }
      }
      yield &value
    }
  }
}

extension OptionalArray1D {
  
  public var indices: Range<Int> { 0..<count }
}

extension OptionalArray1D {

  @inlinable
  var description: String {
    var result = [(Int, Element)]()
    for i in 0..<count {
      if hasPayload[i] {
        result.append((i, payload[i]))
      }
    }
    return result.description
  }
}

/// メモ化用配列
///
/// 配列ベースのメモ化に用いる配列です。
/// 未初期化値の番兵を用意することなく利用できます。
@frozen
public struct OptionalArray2D<Element>: ~Copyable {

  @usableFromInline let hasPayload: UnsafeMutablePointer<Bool>
  @usableFromInline let payload: UnsafeMutablePointer<Element>
  @usableFromInline let width: Int
  @usableFromInline let height: Int
  @usableFromInline let capacity: Int

  @inlinable
  public init(width: Int, height: Int) {
    self.capacity = height * width
    self.hasPayload = .allocate(capacity: capacity)
    self.hasPayload.initialize(repeating: false, count: capacity)
    self.payload = .allocate(capacity: capacity)
    self.width = width
    self.height = height
  }

  deinit {
    for i in 0..<capacity {
      if hasPayload[i] {
        (payload + i).deinitialize(count: 1)
      }
    }
    payload.deallocate()
    hasPayload.deinitialize(count: capacity)
    hasPayload.deallocate()
  }

  @inlinable
  public func removeAll() {
    for i in 0..<capacity {
      if hasPayload[i] {
        (payload + i).deinitialize(count: 1)
      }
    }
    hasPayload.update(repeating: false, count: capacity)
  }

  @inlinable
  public subscript(position: Int) -> OptionalArray1DView<Element> {
    @inline(__always)
    get {
      precondition(position < height)
      return .init(
        hasPayload: hasPayload + width * position,
        payload: payload + width * position,
        count: width)
    }

    @inline(__always)
    set {
      /* NOP */
    }
  }
}

extension OptionalArray2D {

  public var indices: Range<Int> { 0..<height }
}

/// メモ化用配列
///
/// 配列ベースのメモ化に用いる配列です。
/// 未初期化値の番兵を用意することなく利用できます。
@frozen
public struct OptionalArray3D<Element>: ~Copyable {

  @usableFromInline let hasPayload: UnsafeMutablePointer<Bool>
  @usableFromInline let payload: UnsafeMutablePointer<Element>
  @usableFromInline let width: Int
  @usableFromInline let height: Int
  @usableFromInline let depth: Int
  @usableFromInline let capacity: Int

  @inlinable
  public init(width: Int, height: Int, depth: Int) {
    self.capacity = height * width * depth
    self.hasPayload = .allocate(capacity: capacity)
    self.hasPayload.initialize(repeating: false, count: capacity)
    self.payload = .allocate(capacity: capacity)
    self.width = width
    self.height = height
    self.depth = depth
  }

  deinit {
    for i in 0..<capacity {
      if hasPayload[i] {
        (payload + i).deinitialize(count: 1)
      }
    }
    payload.deallocate()
    hasPayload.deinitialize(count: capacity)
    hasPayload.deallocate()
  }

  @inlinable
  public func removeAll() {
    for i in 0..<capacity {
      if hasPayload[i] {
        (payload + i).deinitialize(count: 1)
      }
    }
    hasPayload.update(repeating: false, count: capacity)
  }

  @inlinable
  public subscript(position: Int) -> OptionalArray2DView<Element> {
    @inline(__always)
    get {
      precondition(position < depth)
      return .init(
        hasPayload: hasPayload + width * height * position,
        payload: payload + width * height * position,
        width: width, height: height)
    }

    @inline(__always)
    set {
      /* NOP */
    }
  }
}

extension OptionalArray3D {

  public var indices: Range<Int> { 0..<depth }
}

@frozen
public struct OptionalArray4D<Element>: ~Copyable {

  @usableFromInline let hasPayload: UnsafeMutablePointer<Bool>
  @usableFromInline let payload: UnsafeMutablePointer<Element>
  @usableFromInline let size0: Int
  @usableFromInline let size1: Int
  @usableFromInline let size2: Int
  @usableFromInline let size3: Int
  @usableFromInline let capacity: Int

  @inlinable
  public init(size0: Int, size1: Int, size2: Int, size3: Int) {
    self.capacity = size0 * size1 * size2 * size3
    self.hasPayload = .allocate(capacity: capacity)
    self.hasPayload.initialize(repeating: false, count: capacity)
    self.payload = .allocate(capacity: capacity)
    self.size0 = size0
    self.size1 = size1
    self.size2 = size2
    self.size3 = size3
  }

  deinit {
    for i in 0..<capacity {
      if hasPayload[i] {
        (payload + i).deinitialize(count: 1)
      }
    }
    payload.deallocate()
    hasPayload.deinitialize(count: capacity)
    hasPayload.deallocate()
  }

  @inlinable
  public func removeAll() {
    for i in 0..<capacity {
      if hasPayload[i] {
        (payload + i).deinitialize(count: 1)
      }
    }
    hasPayload.update(repeating: false, count: capacity)
  }

  @inlinable
  public subscript(position: Int) -> OptionalArray3DView<Element> {
    @inline(__always)
    get {
      precondition(position < size3)
      return .init(
        hasPayload: hasPayload + size0 * size1 * size2 * position,
        payload: payload + size0 * size1 * size2 * position,
        width: size0,
        height: size1,
        depth: size2)
    }

    @inline(__always)
    set {
      /* NOP */
    }
  }
}

extension OptionalArray4D {

  public var indices: Range<Int> { 0..<size3 }
}

// MARK: -

public struct OptionalArray1DView<Element> {

  @inlinable
  internal init(
    hasPayload: UnsafeMutablePointer<Bool>,
    payload: UnsafeMutablePointer<Element>,
    count: Int
  ) {
    self.count = count
    self.hasPayload = hasPayload
    self.payload = payload
  }
  @usableFromInline var count: Int
  @usableFromInline let hasPayload: UnsafeMutablePointer<Bool>
  @usableFromInline let payload: UnsafeMutablePointer<Element>

  @inlinable
  public subscript(position: Int) -> Element? {

    @inline(__always)
    get {
      precondition(position < count)
      guard hasPayload[position] else {
        return nil
      }
      return payload[position]
    }

    @inline(__always)
    _modify {
      precondition(position < count)
      var value = hasPayload[position] ? (payload + position).move() : nil
      defer {
        if let value {
          hasPayload[position] = true
          (payload + position).initialize(to: value)
        } else {
          hasPayload[position] = false
          (payload + position).deinitialize(count: 1)
        }
      }
      yield &value
    }
  }
}

extension OptionalArray1DView {
  var indices: Range<Int> { 0..<count }
}

public struct OptionalArray2DView<Element> {

  @inlinable
  internal init(
    hasPayload: UnsafeMutablePointer<Bool>,
    payload: UnsafeMutablePointer<Element>,
    width: Int, height: Int
  ) {
    self.hasPayload = hasPayload
    self.payload = payload
    self.width = width
    self.height = height
  }

  @usableFromInline let hasPayload: UnsafeMutablePointer<Bool>
  @usableFromInline let payload: UnsafeMutablePointer<Element>
  @usableFromInline let width: Int
  @usableFromInline let height: Int

  @inlinable
  public subscript(position: Int) -> OptionalArray1DView<Element> {
    @inline(__always)
    get {
      precondition(position < height)
      return .init(
        hasPayload: hasPayload + width * position,
        payload: payload + width * position,
        count: width)
    }

    @inline(__always)
    set {
      /* NOP */
    }
  }
}

extension OptionalArray2DView {
  var indices: Range<Int> { 0..<height }
}

public struct OptionalArray3DView<Element> {

  @inlinable
  internal init(
    hasPayload: UnsafeMutablePointer<Bool>,
    payload: UnsafeMutablePointer<Element>,
    width: Int, height: Int, depth: Int
  ) {
    self.hasPayload = hasPayload
    self.payload = payload
    self.width = width
    self.height = height
    self.depth = depth
  }

  @usableFromInline let hasPayload: UnsafeMutablePointer<Bool>
  @usableFromInline let payload: UnsafeMutablePointer<Element>
  @usableFromInline let width: Int
  @usableFromInline let height: Int
  @usableFromInline let depth: Int

  @inlinable
  public subscript(position: Int) -> OptionalArray2DView<Element> {
    @inline(__always)
    get {
      precondition(position < height)
      return .init(
        hasPayload: hasPayload + width * position,
        payload: payload + width * position,
        width: width,
        height: height)
    }

    @inline(__always)
    set {
      /* NOP */
    }
  }
}

extension OptionalArray3DView {
  var indices: Range<Int> { 0..<depth }
}
