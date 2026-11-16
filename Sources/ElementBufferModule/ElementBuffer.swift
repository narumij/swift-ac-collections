//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project.
//
// Copyright (c) 2024-2026 narumij.
// Licensed under the Apache License v2.0.
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

// コピペで提出に使っていただいて構いません。
// 提出の際のライセンス記載は不要です。

// TODO: コピペでAtCoder提出可能なこと

/// A one-dimensional buffer for competitive programming and Swift 6.4 general-purpose use.
///
/// A lightweight array allocated on the heap.
/// Use this type to express large arrays for dynamic programming and similar tasks concisely.
///
/// Elements are stored in contiguous memory, providing access performance similar to a C array.
/// This type owns its elements and destroys all of them when the array is destroyed.
/// This type is noncopyable and cannot be duplicated implicitly.
// MEMO: 以下の記述は冗長に感じるので使用しないことにした
// `Element`が`Sendable`なら、配列も`Sendable`です。
// `-Ounchecked`では、記載された事前条件の実行時検査が省略される場合があります。
@safe public struct ElementBuffer<Element>: ~Copyable {

  /// Initializes `count` elements to `value`.
  ///
  /// - Parameters:
  ///   - value: The value to store at each position.
  ///   - count: The number of elements.
  /// - Precondition: `count` must be nonnegative.
  /// - Complexity: O(`count`)
  @inlinable
  public init(repeating value: Element, count: Int) {
    precondition(count >= 0)
    let capacity = count
    unsafe self.payload = .allocate(capacity: capacity)
    unsafe self.payload.initialize(repeating: value, count: capacity)
    self.count = count
  }

  /// Calls `value` `count` times and stores the results in index order.
  ///
  /// Does not call `value` when `count` is zero.
  ///
  /// - Parameters:
  ///   - count: The number of elements.
  ///   - value: A closure that produces each element in index order.
  /// - Precondition: `count` must be nonnegative.
  /// - Complexity: O(`count`)
  @inlinable
  public init(count: Int, _ value: () -> Element) {
    precondition(count >= 0)
    let capacity = count
    unsafe self.payload = .allocate(capacity: capacity)
    for i in 0..<count {
      unsafe (payload + i).initialize(to: value())
    }
    self.count = count
  }

  @inlinable
  @unsafe internal init(payload: UnsafeMutablePointer<Element>, count: Int) {
    self.count = count
    unsafe self.payload = payload
  }

  @usableFromInline let count: Int
  @usableFromInline let payload: UnsafeMutablePointer<Element>

  deinit {
    unsafe self.payload.deinitialize(count: count)
    unsafe self.payload.deallocate()
  }

  @inlinable
  func clone() -> Self {
    let payload = UnsafeMutablePointer<Element>.allocate(capacity: count)
    unsafe payload.initialize(from: self.payload, count: count)
    return unsafe .init(payload: payload, count: count)
  }
}

extension ElementBuffer {

  /// Returns `0..<count`, the valid element positions.
  ///
  /// - Complexity: O(1)
  @inlinable
  public var indices: Range<Int> { 0..<count }
}

extension ElementBuffer: @unchecked Sendable where Element: Sendable {}

/// A multidimensional buffer for competitive programming and Swift 6.4 general-purpose use.
///
/// A lightweight multidimensional array allocated on the heap.
/// Use this type to express large arrays for dynamic programming and similar tasks concisely.
///
/// Elements are stored in contiguous memory, providing access performance similar to a C array.
/// For coordinate access, `width` is the innermost axis and `height` is the outermost axis.
/// This type owns its elements and destroys all of them when the array is destroyed.
/// This type is noncopyable and cannot be duplicated implicitly.
// MEMO: 以下の記述は冗長に感じるので使用しないことにした
// `Element`が`Sendable`なら、配列も`Sendable`です。
// `-Ounchecked`では、記載された事前条件の実行時検査が省略される場合があります。
@safe public struct ElementBuffer2D<Element>: ~Copyable {

  /// Initializes `width * height` elements to `value`.
  ///
  /// Creates empty storage if any dimension is zero.
  ///
  /// - Parameters:
  ///   - value: The value to store at each position.
  ///   - width: The number of elements along the innermost axis.
  ///   - height: The number of elements along the outermost axis.
  /// - Precondition: Every dimension must be nonnegative, and their product must be representable as an `Int`.
  /// - Complexity: O(`width * height`)
  @inlinable
  public init(repeating value: Element, width: Int, height: Int) {
    precondition(width >= 0 && height >= 0)
    let (capacity, overflow) = height.multipliedReportingOverflow(by: width)
    precondition(!overflow)
    self.capacity = capacity
    unsafe self.payload = .allocate(capacity: capacity)
    unsafe self.payload.initialize(repeating: value, count: capacity)
    self.width = width
    self.height = height
  }

  /// Calls `f` `width * height` times and stores the results sequentially in contiguous storage.
  ///
  /// Does not call `f` if any dimension is zero.
  ///
  /// - Parameters:
  ///   - width: The number of elements along the innermost axis.
  ///   - height: The number of elements along the outermost axis.
  ///   - f: A closure that produces each element in storage order.
  /// - Precondition: Every dimension must be nonnegative, and their product must be representable as an `Int`.
  /// - Complexity: O(`width * height`)
  @inlinable
  public init(width: Int, height: Int, _ f: () -> Element) {
    precondition(width >= 0 && height >= 0)
    let (capacity, overflow) = height.multipliedReportingOverflow(by: width)
    precondition(!overflow)
    self.capacity = capacity
    unsafe self.payload = .allocate(capacity: capacity)
    for i in 0..<capacity {
      unsafe (payload + i).initialize(to: f())
    }
    self.width = width
    self.height = height
  }

  @inlinable
  @unsafe internal init(payload: UnsafeMutablePointer<Element>, width: Int, height: Int) {
    self.capacity = height * width
    unsafe self.payload = payload
    self.width = width
    self.height = height
  }

  @usableFromInline let capacity: Int
  @usableFromInline let payload: UnsafeMutablePointer<Element>
  @usableFromInline let width: Int
  @usableFromInline let height: Int

  deinit {
    unsafe self.payload.deinitialize(count: capacity)
    unsafe self.payload.deallocate()
  }

  @inlinable
  func clone() -> Self {
    let payload = UnsafeMutablePointer<Element>.allocate(capacity: capacity)
    unsafe payload.initialize(from: self.payload, count: capacity)
    return unsafe .init(payload: payload, width: width, height: height)
  }
}

extension ElementBuffer2D {

  /// Returns `0..<height`, the valid positions along the outermost axis.
  ///
  /// - Complexity: O(1)
  @inlinable
  public var indices: Range<Int> { 0..<height }
}

extension ElementBuffer2D: @unchecked Sendable where Element: Sendable {}

/// A multidimensional buffer for competitive programming and Swift 6.4 general-purpose use.
///
/// A lightweight multidimensional array allocated on the heap.
/// Use this type to express large arrays for dynamic programming and similar tasks concisely.
///
/// Elements are stored in contiguous memory, providing access performance similar to a C array.
/// For coordinate access, `width` is the innermost axis and `depth` is the outermost axis.
/// This type owns its elements and destroys all of them when the array is destroyed.
/// This type is noncopyable and cannot be duplicated implicitly.
// MEMO: 以下の記述は冗長に感じるので使用しないことにした
// `Element`が`Sendable`なら、配列も`Sendable`です。
// `-Ounchecked`では、記載された事前条件の実行時検査が省略される場合があります。
@safe public struct ElementBuffer3D<Element>: ~Copyable {

  /// Initializes `width * height * depth` elements to `value`.
  ///
  /// Creates empty storage if any dimension is zero.
  ///
  /// - Parameters:
  ///   - value: The value to store at each position.
  ///   - width: The number of elements along the innermost axis.
  ///   - height: The number of elements along the middle axis.
  ///   - depth: The number of elements along the outermost axis.
  /// - Precondition: Every dimension must be nonnegative, and their product must be representable as an `Int`.
  /// - Complexity: O(`width * height * depth`)
  @inlinable
  public init(repeating value: Element, width: Int, height: Int, depth: Int) {
    precondition(width >= 0 && height >= 0 && depth >= 0)
    if width == 0 || height == 0 || depth == 0 {
      self.capacity = 0
    } else {
      let (plane, overflow0) = height.multipliedReportingOverflow(by: width)
      let (capacity, overflow1) = plane.multipliedReportingOverflow(by: depth)
      precondition(!overflow0 && !overflow1)
      self.capacity = capacity
    }
    unsafe self.payload = .allocate(capacity: capacity)
    unsafe self.payload.initialize(repeating: value, count: capacity)
    self.width = width
    self.height = height
    self.depth = depth
  }

  /// Calls `f` once for each element and stores the results sequentially in contiguous storage.
  ///
  /// Does not call `f` if any dimension is zero.
  ///
  /// - Parameters:
  ///   - width: The number of elements along the innermost axis.
  ///   - height: The number of elements along the middle axis.
  ///   - depth: The number of elements along the outermost axis.
  ///   - f: A closure that produces each element in storage order.
  /// - Precondition: Every dimension must be nonnegative, and their product must be representable as an `Int`.
  /// - Complexity: O(`width * height * depth`)
  @inlinable
  public init(width: Int, height: Int, depth: Int, _ f: () -> Element) {
    precondition(width >= 0 && height >= 0 && depth >= 0)
    if width == 0 || height == 0 || depth == 0 {
      self.capacity = 0
    } else {
      let (plane, overflow0) = width.multipliedReportingOverflow(by: height)
      let (capacity, overflow1) = plane.multipliedReportingOverflow(by: depth)
      precondition(!overflow0 && !overflow1)
      self.capacity = capacity
    }
    unsafe self.payload = .allocate(capacity: capacity)
    for i in 0..<capacity {
      unsafe (payload + i).initialize(to: f())
    }
    self.width = width
    self.height = height
    self.depth = depth
  }

  @inlinable
  @unsafe internal init(
    payload: UnsafeMutablePointer<Element>, width: Int, height: Int, depth: Int
  ) {
    self.capacity = width * height * depth
    unsafe self.payload = payload
    self.width = width
    self.height = height
    self.depth = depth
  }

  @usableFromInline let capacity: Int
  @usableFromInline let payload: UnsafeMutablePointer<Element>
  @usableFromInline let width: Int
  @usableFromInline let height: Int
  @usableFromInline let depth: Int

  deinit {
    unsafe self.payload.deinitialize(count: capacity)
    unsafe self.payload.deallocate()
  }

  @inlinable
  func clone() -> Self {
    let payload = UnsafeMutablePointer<Element>.allocate(capacity: capacity)
    unsafe payload.initialize(from: self.payload, count: capacity)
    return unsafe .init(payload: payload, width: width, height: height, depth: depth)
  }
}

extension ElementBuffer3D {

  /// Returns `0..<depth`, the valid positions along the outermost axis.
  ///
  /// - Complexity: O(1)
  @inlinable
  public var indices: Range<Int> { 0..<depth }
}

extension ElementBuffer3D: @unchecked Sendable where Element: Sendable {}

/// A four-dimensional array that owns elements in contiguous memory.
///
/// For coordinate access, `size0` is the innermost axis and `size3` is the outermost axis;
/// the `size0` axis advances fastest in storage.
/// This type owns its elements and destroys all of them when the array is destroyed.
/// This type is noncopyable and cannot be duplicated implicitly.
// MEMO: 以下の記述は冗長に感じるので使用しないことにした
// `Element`が`Sendable`なら、配列も`Sendable`です。
// `-Ounchecked`では、記載された事前条件の実行時検査が省略される場合があります。
@safe public struct ElementBuffer4D<Element>: ~Copyable {

  /// Initializes every element to `value`.
  ///
  /// Creates empty storage if any dimension is zero.
  ///
  /// - Parameters:
  ///   - value: The value to store at each position.
  ///   - size0: The number of elements along the innermost axis.
  ///   - size1: The number of elements along the second-innermost axis.
  ///   - size2: The number of elements along the third-innermost axis.
  ///   - size3: The number of elements along the outermost axis.
  /// - Precondition: Every dimension must be nonnegative, and their product must be representable as an `Int`.
  /// - Complexity: O(`size0 * size1 * size2 * size3`)
  @inlinable
  public init(repeating value: Element, size0: Int, size1: Int, size2: Int, size3: Int) {
    precondition(size0 >= 0 && size1 >= 0 && size2 >= 0 && size3 >= 0)
    if size0 == 0 || size1 == 0 || size2 == 0 || size3 == 0 {
      self.capacity = 0
    } else {
      let (plane, overflow0) = size0.multipliedReportingOverflow(by: size1)
      let (cube, overflow1) = plane.multipliedReportingOverflow(by: size2)
      let (capacity, overflow2) = cube.multipliedReportingOverflow(by: size3)
      precondition(!overflow0 && !overflow1 && !overflow2)
      self.capacity = capacity
    }
    unsafe self.payload = .allocate(capacity: capacity)
    unsafe self.payload.initialize(repeating: value, count: capacity)
    self.size0 = size0
    self.size1 = size1
    self.size2 = size2
    self.size3 = size3
  }

  /// Calls `f` once for each element and stores the results sequentially in contiguous storage.
  ///
  /// Does not call `f` if any dimension is zero.
  ///
  /// - Parameters:
  ///   - size0: The number of elements along the innermost axis.
  ///   - size1: The number of elements along the second-innermost axis.
  ///   - size2: The number of elements along the third-innermost axis.
  ///   - size3: The number of elements along the outermost axis.
  ///   - f: A closure that produces each element in storage order.
  /// - Precondition: Every dimension must be nonnegative, and their product must be representable as an `Int`.
  /// - Complexity: O(`size0 * size1 * size2 * size3`)
  @inlinable
  public init(size0: Int, size1: Int, size2: Int, size3: Int, _ f: () -> Element) {
    precondition(size0 >= 0 && size1 >= 0 && size2 >= 0 && size3 >= 0)
    if size0 == 0 || size1 == 0 || size2 == 0 || size3 == 0 {
      self.capacity = 0
    } else {
      let (plane, overflow0) = size0.multipliedReportingOverflow(by: size1)
      let (cube, overflow1) = plane.multipliedReportingOverflow(by: size2)
      let (capacity, overflow2) = cube.multipliedReportingOverflow(by: size3)
      precondition(!overflow0 && !overflow1 && !overflow2)
      self.capacity = capacity
    }
    unsafe self.payload = .allocate(capacity: capacity)
    for i in 0..<capacity {
      unsafe (payload + i).initialize(to: f())
    }
    self.size0 = size0
    self.size1 = size1
    self.size2 = size2
    self.size3 = size3
  }

  @inlinable
  @unsafe internal init(
    payload: UnsafeMutablePointer<Element>, size0: Int, size1: Int, size2: Int, size3: Int
  ) {
    self.capacity = size0 * size1 * size2 * size3
    unsafe self.payload = payload
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

  deinit {
    unsafe self.payload.deinitialize(count: capacity)
    unsafe self.payload.deallocate()
  }

  @inlinable
  func clone() -> Self {
    let payload = UnsafeMutablePointer<Element>.allocate(capacity: capacity)
    unsafe payload.initialize(from: self.payload, count: capacity)
    return unsafe .init(payload: payload, size0: size0, size1: size1, size2: size2, size3: size3)
  }
}

extension ElementBuffer4D {

  /// Returns `0..<size3`, the valid positions along the outermost axis.
  ///
  /// - Complexity: O(1)
  @inlinable
  public var indices: Range<Int> { 0..<size3 }
}

extension ElementBuffer4D: @unchecked Sendable where Element: Sendable {}

// MARK: -

extension ElementBuffer {

  #if swift(>=6.4)
    /// Returns a borrowed reference for reading and writing the element at `position`.
    ///
    /// The returned [MutableRef](https://developer.apple.com/documentation/swift/mutableref)
    /// does not own this buffer's storage, and its lifetime depends on the mutable borrow of `self`.
    /// Do not access this buffer elsewhere until you finish using the reference.
    ///
    /// - Parameter position: The position of the element to reference.
    /// - Returns: A mutable reference to the specified element.
    /// - Precondition: `position` must be contained in `indices`.
    /// - Complexity: O(1)
    @available(anyAppleOS 27.0, *)
    @inlinable
    @_lifetime(&self)
    public mutating func reference(at position: Int) -> MutableRef<Element> {
      precondition(0 <= position && position < count)
      return unsafe .init(unsafeAddress: payload + position, mutating: &self)
    }
  #endif

  // TODO: CI等で6.2テスト可能になったら6.4で提供不可にする
  //  #if swift(<6.4)
  /// Returns the element at `position`.
  ///
  /// - Parameter position: The position of the element to read.
  /// - Precondition: `position` must be contained in `indices`.
  /// - Complexity: O(1)
  @inlinable
  public func element(at position: Int) -> Element {
    precondition(0 <= position && position < count)
    return unsafe payload[position]
  }

  // MEMO: mutableにすると実行検査が増えるので競技プログラミングとしてうれしくない
  // Swift 6.2は競技供用。Swift 6.4の一般供用はmutating reference(at:)を中心とする。
  /// Replaces the element at `position` with `newValue`.
  ///
  /// The previous element is destroyed. Because this method is nonmutating, it can also update a buffer
  /// stored in a `let` binding.
  /// This competitive-programming access path does not synchronize concurrent access.
  /// For general-purpose use with Swift 6.4, prefer `reference(at:)` and its multidimensional variants.
  ///
  /// - Parameters:
  ///   - newValue: The value to store at the specified position.
  ///   - position: The position of the element to update.
  /// - Precondition: `position` must be contained in `indices`.
  /// - Complexity: O(1)
  @inlinable
  public func setElement(_ newValue: consuming Element, at position: Int) {
    precondition(0 <= position && position < count)
    unsafe payload[position] = newValue
  }
  //  #endif
}

extension ElementBuffer2D {

  #if swift(>=6.4)
    /// Returns a borrowed reference for reading and writing the element at coordinates `(x, y)`.
    ///
    /// The returned [MutableRef](https://developer.apple.com/documentation/swift/mutableref)
    /// does not own this buffer's storage, and its lifetime depends on the mutable borrow of `self`.
    /// Do not access this buffer elsewhere until you finish using the reference.
    ///
    /// ```swift
    /// if #available(macOS 27.0, iOS 27.0, tvOS 27.0, watchOS 27.0, visionOS 27.0, *) {
    ///   var table = ElementBuffer2D(repeating: 0, width: 4, height: 3)
    ///   do {
    ///     var cell = table.reference(at: 2, 1)
    ///     cell.value += 1
    ///     cell.value += 2
    ///   }
    ///   let value = table.element(at: 2, 1) // 3
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - x: The position along the innermost axis.
    ///   - y: The position along the outermost axis.
    /// - Returns: A mutable reference to the specified element.
    /// - Precondition: `x` must be in `0..<width`, and `y` must be in `0..<height`.
    /// - Complexity: O(1)
    @available(anyAppleOS 27.0, *)
    @inlinable
    @_lifetime(&self)
    public mutating func reference(at x: Int, _ y: Int) -> MutableRef<Element> {
      precondition(0 <= x && x < width)
      precondition(0 <= y && y < height)
      return unsafe .init(unsafeAddress: payload + y * width + x, mutating: &self)
    }
  #endif

  // TODO: CI等で6.2テスト可能になったら6.4で提供不可にする
  //  #if swift(<6.4)
  /// Returns the element at coordinates `(x, y)`.
  ///
  /// - Parameters:
  ///   - x: The position along the innermost axis.
  ///   - y: The position along the outermost axis.
  /// - Precondition: `x` must be in `0..<width`, and `y` must be in `0..<height`.
  /// - Complexity: O(1)
  @inlinable
  public func element(at x: Int, _ y: Int) -> Element {
    precondition(0 <= x && x < width)
    precondition(0 <= y && y < height)
    return unsafe payload[y * width + x]
  }

  // MEMO: mutableにすると実行検査が増えるので競技プログラミングとしてうれしくない
  // Swift 6.2は競技供用。Swift 6.4の一般供用はmutating reference(at:)を中心とする。
  /// Replaces the element at coordinates `(x, y)` with `newValue`.
  ///
  /// The previous element is destroyed. Because this method is nonmutating, it can also update a buffer
  /// stored in a `let` binding.
  /// This competitive-programming access path does not synchronize concurrent access.
  /// For general-purpose use with Swift 6.4, prefer `reference(at:)` and its multidimensional variants.
  ///
  /// - Parameters:
  ///   - newValue: The value to store at the specified position.
  ///   - x: The position along the innermost axis.
  ///   - y: The position along the outermost axis.
  /// - Precondition: `x` must be in `0..<width`, and `y` must be in `0..<height`.
  /// - Complexity: O(1)
  @inlinable
  public func setElement(_ newValue: consuming Element, at x: Int, _ y: Int) {
    precondition(0 <= x && x < width)
    precondition(0 <= y && y < height)
    unsafe payload[y * width + x] = newValue
  }
  //  #endif
}

extension ElementBuffer3D {

  #if swift(>=6.4)
    /// Returns a borrowed reference for reading and writing the element at coordinates `(x, y, z)`.
    ///
    /// The returned [MutableRef](https://developer.apple.com/documentation/swift/mutableref)
    /// does not own this buffer's storage, and its lifetime depends on the mutable borrow of `self`.
    /// Do not access this buffer elsewhere until you finish using the reference.
    ///
    /// - Parameters:
    ///   - x: The position along the innermost axis.
    ///   - y: The position along the middle axis.
    ///   - z: The position along the outermost axis.
    /// - Returns: A mutable reference to the specified element.
    /// - Precondition: `x`, `y`, and `z` must be in `0..<width`, `0..<height`, and `0..<depth`, respectively.
    /// - Complexity: O(1)
    @available(anyAppleOS 27.0, *)
    @inlinable
    @_lifetime(&self)
    public mutating func reference(at x: Int, _ y: Int, _ z: Int) -> MutableRef<Element> {
      precondition(0 <= x && x < width)
      precondition(0 <= y && y < height)
      precondition(0 <= z && z < depth)
      return unsafe .init(unsafeAddress: payload + (z * height + y) * width + x, mutating: &self)
    }
  #endif

  // TODO: CI等で6.2テスト可能になったら6.4で提供不可にする
  //  #if swift(<6.4)
  /// Returns the element at coordinates `(x, y, z)`.
  ///
  /// - Parameters:
  ///   - x: The position along the innermost axis.
  ///   - y: The position along the middle axis.
  ///   - z: The position along the outermost axis.
  /// - Precondition: `x`, `y`, and `z` must be in `0..<width`, `0..<height`, and `0..<depth`, respectively.
  /// - Complexity: O(1)
  @inlinable
  public func element(at x: Int, _ y: Int, _ z: Int) -> Element {
    precondition(0 <= x && x < width)
    precondition(0 <= y && y < height)
    precondition(0 <= z && z < depth)
    return unsafe payload[(z * height + y) * width + x]
  }

  // MEMO: mutableにすると実行検査が増えるので競技プログラミングとしてうれしくない
  // Swift 6.2は競技供用。Swift 6.4の一般供用はmutating reference(at:)を中心とする。
  /// Replaces the element at coordinates `(x, y, z)` with `newValue`.
  ///
  /// The previous element is destroyed. Because this method is nonmutating, it can also update a buffer
  /// stored in a `let` binding.
  /// This competitive-programming access path does not synchronize concurrent access.
  /// For general-purpose use with Swift 6.4, prefer `reference(at:)` and its multidimensional variants.
  ///
  /// - Parameters:
  ///   - newValue: The value to store at the specified position.
  ///   - x: The position along the innermost axis.
  ///   - y: The position along the middle axis.
  ///   - z: The position along the outermost axis.
  /// - Precondition: `x`, `y`, and `z` must be in `0..<width`, `0..<height`, and `0..<depth`, respectively.
  /// - Complexity: O(1)
  @inlinable
  public func setElement(_ newValue: consuming Element, at x: Int, _ y: Int, _ z: Int) {
    precondition(0 <= x && x < width)
    precondition(0 <= y && y < height)
    precondition(0 <= z && z < depth)
    unsafe payload[(z * height + y) * width + x] = newValue
  }
  //  #endif
}

extension ElementBuffer4D {

  #if swift(>=6.4)
    /// Returns a borrowed reference for reading and writing the element at coordinates `(x, y, z, w)`.
    ///
    /// The returned [MutableRef](https://developer.apple.com/documentation/swift/mutableref)
    /// does not own this buffer's storage, and its lifetime depends on the mutable borrow of `self`.
    /// Do not access this buffer elsewhere until you finish using the reference.
    ///
    /// - Parameters:
    ///   - x: The position along the `size0` axis.
    ///   - y: The position along the `size1` axis.
    ///   - z: The position along the `size2` axis.
    ///   - w: The position along the `size3` axis.
    /// - Returns: A mutable reference to the specified element.
    /// - Precondition: Each coordinate must be in its corresponding `0..<sizeN` range.
    /// - Complexity: O(1)
    @available(anyAppleOS 27.0, *)
    @inlinable
    @_lifetime(&self)
    public mutating func reference(at x: Int, _ y: Int, _ z: Int, _ w: Int) -> MutableRef<Element> {
      precondition(0 <= x && x < size0)
      precondition(0 <= y && y < size1)
      precondition(0 <= z && z < size2)
      precondition(0 <= w && w < size3)
      return unsafe .init(
        unsafeAddress:
          payload + ((w * size2 + z) * size1 + y) * size0 + x,
        mutating: &self)
    }
  #endif

  // TODO: CI等で6.2テスト可能になったら6.4で提供不可にする
  //  #if swift(<6.4)
  /// Returns the element at coordinates `(x, y, z, w)`.
  ///
  /// - Parameters:
  ///   - x: The position along the `size0` axis.
  ///   - y: The position along the `size1` axis.
  ///   - z: The position along the `size2` axis.
  ///   - w: The position along the `size3` axis.
  /// - Precondition: Each coordinate must be in its corresponding `0..<sizeN` range.
  /// - Complexity: O(1)
  @inlinable
  public func element(at x: Int, _ y: Int, _ z: Int, _ w: Int) -> Element {
    precondition(0 <= x && x < size0)
    precondition(0 <= y && y < size1)
    precondition(0 <= z && z < size2)
    precondition(0 <= w && w < size3)
    return unsafe payload[((w * size2 + z) * size1 + y) * size0 + x]
  }

  // MEMO: mutableにすると実行検査が増えるので競技プログラミングとしてうれしくない
  // Swift 6.2は競技供用。Swift 6.4の一般供用はmutating reference(at:)を中心とする。
  /// Replaces the element at coordinates `(x, y, z, w)` with `newValue`.
  ///
  /// The previous element is destroyed. Because this method is nonmutating, it can also update a buffer
  /// stored in a `let` binding.
  /// This competitive-programming access path does not synchronize concurrent access.
  /// For general-purpose use with Swift 6.4, prefer `reference(at:)` and its multidimensional variants.
  ///
  /// - Parameters:
  ///   - newValue: The value to store at the specified position.
  ///   - x: The position along the `size0` axis.
  ///   - y: The position along the `size1` axis.
  ///   - z: The position along the `size2` axis.
  ///   - w: The position along the `size3` axis.
  /// - Precondition: Each coordinate must be in its corresponding `0..<sizeN` range.
  /// - Complexity: O(1)
  @inlinable
  public func setElement(
    _ newValue: consuming Element, at x: Int, _ y: Int, _ z: Int, _ w: Int
  ) {
    precondition(0 <= x && x < size0)
    precondition(0 <= y && y < size1)
    precondition(0 <= z && z < size2)
    precondition(0 <= w && w < size3)
    unsafe payload[((w * size2 + z) * size1 + y) * size0 + x] = newValue
  }
  //  #endif
}
