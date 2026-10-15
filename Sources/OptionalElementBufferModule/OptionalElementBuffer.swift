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

/// An array for memoization.
///
/// Stores memoized values without requiring a sentinel value for unset slots.
/// Each slot is either unset or holds one owned `Element`.
/// Passing `nil` to `setElement(_:at:)` destroys the set element and returns the slot to the unset state.
/// This type cannot be copied. `setElement(_:at:)` and `removeAll()` are nonmutating, so
/// you can also update the contents of a buffer stored in a `let` binding.
/// The array is `Sendable` when `Element` is `Sendable`.
/// With `-Ounchecked`, runtime checks for the documented preconditions may be omitted.
@safe public struct OptionalElementBuffer<Element>: ~Copyable {

  @usableFromInline let count: Int
  @usableFromInline let hasPayload: UnsafeMutablePointer<Bool>
  @usableFromInline let payload: UnsafeMutablePointer<Element>

  /// Creates an array with `capacity` unset slots.
  ///
  /// Creates an empty array when `capacity` is zero.
  ///
  /// - Parameter capacity: The number of slots.
  /// - Precondition: `capacity` must be nonnegative.
  /// - Complexity: O(`capacity`)
  @inlinable
  public init(capacity: Int) {
    precondition(capacity >= 0)
    self.count = capacity
    unsafe self.hasPayload = .allocate(capacity: capacity)
    unsafe self.hasPayload.initialize(repeating: false, count: capacity)
    unsafe self.payload = .allocate(capacity: capacity)
  }

  deinit {
    for i in 0..<count {
      if unsafe hasPayload[i] {
        unsafe (payload + i).deinitialize(count: 1)
      }
    }
    unsafe payload.deallocate()
    unsafe hasPayload.deinitialize(count: count)
    unsafe hasPayload.deallocate()
  }

  /// Destroys every set element and returns each slot to the unset state.
  ///
  /// The slot count and allocated storage are preserved, so every position can be reused.
  ///
  /// - Complexity: O(`indices.count`)
  @inlinable
  public func removeAll() {
    for i in 0..<count {
      if unsafe hasPayload[i] {
        unsafe (payload + i).deinitialize(count: 1)
      }
    }
    unsafe hasPayload.update(repeating: false, count: count)
  }

}

extension OptionalElementBuffer {

  /// Returns `0..<capacity`, the valid slot positions.
  ///
  /// - Complexity: O(1)
  public var indices: Range<Int> { 0..<count }

  /// Returns the element at `position`. Returns `nil` if it is unset.
  ///
  /// - Precondition: `position` must be in `0..<capacity`.
  @inlinable
  public func element(at position: Int) -> Element? {
    precondition(0 <= position && position < count)
    guard unsafe hasPayload[position] else { return nil }
    return unsafe payload[position]
  }

  // MEMO: mutableにすると実行検査が増えるので競技プログラミングとしてうれしくない
  // 一般供用としてはmutable必須なので、一般供用不可となる
  /// Sets the element at `position`. Passing `nil` returns the slot to the unset state.
  ///
  /// - Precondition: `position` must be in `0..<capacity`.
  @inlinable
  public func setElement(_ newValue: consuming Element?, at position: Int) {
    precondition(0 <= position && position < count)
    if unsafe hasPayload[position] {
      unsafe (payload + position).deinitialize(count: 1)
    }
    if let newValue = consume newValue {
      unsafe (payload + position).initialize(to: newValue)
      unsafe hasPayload[position] = true
    } else {
      unsafe hasPayload[position] = false
    }
  }
}

extension OptionalElementBuffer: @unchecked Sendable where Element: Sendable {}

extension OptionalElementBuffer {

  @inlinable
  var description: String {
    var result = [(Int, Element)]()
    for i in 0..<count {
      if unsafe hasPayload[i] {
        result.append((i, unsafe payload[i]))
      }
    }
    return result.description
  }
}

/// An array for memoization.
///
/// Stores memoized values without requiring a sentinel value for unset slots.
/// Each slot is either unset or holds one owned `Element`.
/// Coordinates are ordered `(x, y)`, with `width` as the innermost axis and `height` as the outermost axis.
/// This type cannot be copied. `setElement(_:at:_:)` and `removeAll()` are nonmutating, so
/// you can also update the contents of a buffer stored in a `let` binding.
/// The array is `Sendable` when `Element` is `Sendable`.
/// With `-Ounchecked`, runtime checks for the documented preconditions may be omitted.
@frozen
@safe public struct OptionalElementBuffer2D<Element>: ~Copyable {

  @usableFromInline let hasPayload: UnsafeMutablePointer<Bool>
  @usableFromInline let payload: UnsafeMutablePointer<Element>
  @usableFromInline let width: Int
  @usableFromInline let height: Int
  @usableFromInline let capacity: Int

  /// Creates an array with `width * height` unset slots.
  ///
  /// Creates an array with no elements if any dimension is zero.
  ///
  /// - Parameters:
  ///   - width: The number of slots along the innermost axis.
  ///   - height: The number of slots along the outermost axis.
  /// - Precondition: Every dimension must be nonnegative, and their product must be representable as an `Int`.
  /// - Complexity: O(`width * height`)
  @inlinable
  public init(width: Int, height: Int) {
    precondition(width >= 0 && height >= 0)
    let (capacity, overflow) = height.multipliedReportingOverflow(by: width)
    precondition(!overflow)
    self.capacity = capacity
    unsafe self.hasPayload = .allocate(capacity: capacity)
    unsafe self.hasPayload.initialize(repeating: false, count: capacity)
    unsafe self.payload = .allocate(capacity: capacity)
    self.width = width
    self.height = height
  }

  deinit {
    for i in 0..<capacity {
      if unsafe hasPayload[i] {
        unsafe (payload + i).deinitialize(count: 1)
      }
    }
    unsafe payload.deallocate()
    unsafe hasPayload.deinitialize(count: capacity)
    unsafe hasPayload.deallocate()
  }

  /// Destroys every set element and returns each slot to the unset state.
  ///
  /// The shape and allocated storage are preserved, so every position can be reused.
  ///
  /// - Complexity: O(`width * height`)
  @inlinable
  public func removeAll() {
    for i in 0..<capacity {
      if unsafe hasPayload[i] {
        unsafe (payload + i).deinitialize(count: 1)
      }
    }
    unsafe hasPayload.update(repeating: false, count: capacity)
  }

}

extension OptionalElementBuffer2D {

  /// Returns `0..<height`, the valid positions along the outermost axis.
  ///
  /// - Complexity: O(1)
  public var indices: Range<Int> { 0..<height }

  /// Returns the element at `(x, y)`. Returns `nil` if it is unset.
  ///
  /// - Precondition: `x` must be in `0..<width`, and `y` must be in `0..<height`.
  @inlinable
  public func element(at x: Int, _ y: Int) -> Element? {
    precondition(0 <= x && x < width)
    precondition(0 <= y && y < height)
    let offset = y * width + x
    guard unsafe hasPayload[offset] else { return nil }
    return unsafe payload[offset]
  }

  // MEMO: mutableにすると実行検査が増えるので競技プログラミングとしてうれしくない
  // 一般供用としてはmutable必須なので、一般供用不可となる
  /// Sets the element at `(x, y)`. Passing `nil` returns the slot to the unset state.
  ///
  /// - Precondition: `x` must be in `0..<width`, and `y` must be in `0..<height`.
  @inlinable
  public func setElement(_ newValue: consuming Element?, at x: Int, _ y: Int) {
    precondition(0 <= x && x < width)
    precondition(0 <= y && y < height)
    let offset = y * width + x
    if unsafe hasPayload[offset] {
      unsafe (payload + offset).deinitialize(count: 1)
    }
    if let newValue = consume newValue {
      unsafe (payload + offset).initialize(to: newValue)
      unsafe hasPayload[offset] = true
    } else {
      unsafe hasPayload[offset] = false
    }
  }
}

extension OptionalElementBuffer2D: @unchecked Sendable where Element: Sendable {}

/// An array for memoization.
///
/// Stores memoized values without requiring a sentinel value for unset slots.
/// Each slot is either unset or holds one owned `Element`.
/// Coordinates are ordered `(x, y, z)`, with `width` as the innermost axis and `depth` as the outermost axis.
/// This type cannot be copied. `setElement(_:at:_:_:)` and `removeAll()` are nonmutating, so
/// you can also update the contents of a buffer stored in a `let` binding.
/// The array is `Sendable` when `Element` is `Sendable`.
/// With `-Ounchecked`, runtime checks for the documented preconditions may be omitted.
@frozen
@safe public struct OptionalElementBuffer3D<Element>: ~Copyable {

  @usableFromInline let hasPayload: UnsafeMutablePointer<Bool>
  @usableFromInline let payload: UnsafeMutablePointer<Element>
  @usableFromInline let width: Int
  @usableFromInline let height: Int
  @usableFromInline let depth: Int
  @usableFromInline let capacity: Int

  /// Creates an array with `width * height * depth` unset slots.
  ///
  /// Creates an array with no elements if any dimension is zero.
  ///
  /// - Parameters:
  ///   - width: The number of slots along the innermost axis.
  ///   - height: The number of slots along the middle axis.
  ///   - depth: The number of slots along the outermost axis.
  /// - Precondition: Every dimension must be nonnegative, and their product must be representable as an `Int`.
  /// - Complexity: O(`width * height * depth`)
  @inlinable
  public init(width: Int, height: Int, depth: Int) {
    precondition(width >= 0 && height >= 0 && depth >= 0)
    // 0の次元があれば積は0。途中の積だけがoverflowする入力を拒否しないよう、先に判定する。
    if width == 0 || height == 0 || depth == 0 {
      self.capacity = 0
    } else {
      let (plane, overflow0) = height.multipliedReportingOverflow(by: width)
      let (capacity, overflow1) = plane.multipliedReportingOverflow(by: depth)
      precondition(!overflow0 && !overflow1)
      self.capacity = capacity
    }
    unsafe self.hasPayload = .allocate(capacity: capacity)
    unsafe self.hasPayload.initialize(repeating: false, count: capacity)
    unsafe self.payload = .allocate(capacity: capacity)
    self.width = width
    self.height = height
    self.depth = depth
  }

  deinit {
    for i in 0..<capacity {
      if unsafe hasPayload[i] {
        unsafe (payload + i).deinitialize(count: 1)
      }
    }
    unsafe payload.deallocate()
    unsafe hasPayload.deinitialize(count: capacity)
    unsafe hasPayload.deallocate()
  }

  /// Destroys every set element and returns each slot to the unset state.
  ///
  /// The shape and allocated storage are preserved, so every position can be reused.
  ///
  /// - Complexity: O(`width * height * depth`)
  @inlinable
  public func removeAll() {
    for i in 0..<capacity {
      if unsafe hasPayload[i] {
        unsafe (payload + i).deinitialize(count: 1)
      }
    }
    unsafe hasPayload.update(repeating: false, count: capacity)
  }

}

extension OptionalElementBuffer3D {

  /// Returns `0..<depth`, the valid positions along the outermost axis.
  ///
  /// - Complexity: O(1)
  public var indices: Range<Int> { 0..<depth }
}

extension OptionalElementBuffer3D {

  /// Returns the element at `(x, y, z)`. Returns `nil` if it is unset.
  ///
  /// - Precondition: `x`, `y`, and `z`
  ///   must be in `0..<width`, `0..<height`, and `0..<depth`, respectively.
  @inlinable
  public func element(at x: Int, _ y: Int, _ z: Int) -> Element? {
    precondition(0 <= x && x < width)
    precondition(0 <= y && y < height)
    precondition(0 <= z && z < depth)
    let offset = (z * height + y) * width + x
    guard unsafe hasPayload[offset] else { return nil }
    return unsafe payload[offset]
  }

  // MEMO: mutableにすると実行検査が増えるので競技プログラミングとしてうれしくない
  // 一般供用としてはmutable必須なので、一般供用不可となる
  /// Sets the element at `(x, y, z)`. Passing `nil` returns the slot to the unset state.
  ///
  /// - Precondition: `x`, `y`, and `z`
  ///   must be in `0..<width`, `0..<height`, and `0..<depth`, respectively.
  @inlinable
  public func setElement(_ newValue: consuming Element?, at x: Int, _ y: Int, _ z: Int) {
    precondition(0 <= x && x < width)
    precondition(0 <= y && y < height)
    precondition(0 <= z && z < depth)
    let offset = (z * height + y) * width + x
    if unsafe hasPayload[offset] {
      unsafe (payload + offset).deinitialize(count: 1)
    }
    if let newValue = consume newValue {
      unsafe (payload + offset).initialize(to: newValue)
      unsafe hasPayload[offset] = true
    } else {
      unsafe hasPayload[offset] = false
    }
  }
}

extension OptionalElementBuffer3D: @unchecked Sendable where Element: Sendable {}

/// An array for memoization.
///
/// Stores memoized values without requiring a sentinel value for unset slots.
/// Each slot is either unset or holds one owned `Element`.
/// Coordinates are ordered `(x, y, z, w)`, with `size0` as the innermost axis and
/// `size3` as the outermost axis.
/// This type cannot be copied. `setElement(_:at:_:_:_:)` and `removeAll()` are nonmutating, so
/// you can also update the contents of a buffer stored in a `let` binding.
/// The array is `Sendable` when `Element` is `Sendable`.
/// With `-Ounchecked`, runtime checks for the documented preconditions may be omitted.
@frozen
@safe public struct OptionalElementBuffer4D<Element>: ~Copyable {

  @usableFromInline let hasPayload: UnsafeMutablePointer<Bool>
  @usableFromInline let payload: UnsafeMutablePointer<Element>
  @usableFromInline let size0: Int
  @usableFromInline let size1: Int
  @usableFromInline let size2: Int
  @usableFromInline let size3: Int
  @usableFromInline let capacity: Int

  /// Creates an array with `size0 * size1 * size2 * size3` unset slots.
  ///
  /// Creates an array with no elements if any dimension is zero.
  ///
  /// - Parameters:
  ///   - size0: The number of slots along the innermost axis.
  ///   - size1: The number of slots along the second-innermost axis.
  ///   - size2: The number of slots along the third-innermost axis.
  ///   - size3: The number of slots along the outermost axis.
  /// - Precondition: Every dimension must be nonnegative, and their product must be representable as an `Int`.
  /// - Complexity: O(`size0 * size1 * size2 * size3`)
  @inlinable
  public init(size0: Int, size1: Int, size2: Int, size3: Int) {
    precondition(size0 >= 0 && size1 >= 0 && size2 >= 0 && size3 >= 0)
    // 0の次元があれば積は0。途中の積だけがoverflowする入力を拒否しないよう、先に判定する。
    if size0 == 0 || size1 == 0 || size2 == 0 || size3 == 0 {
      self.capacity = 0
    } else {
      let (plane, overflow0) = size0.multipliedReportingOverflow(by: size1)
      let (cube, overflow1) = plane.multipliedReportingOverflow(by: size2)
      let (capacity, overflow2) = cube.multipliedReportingOverflow(by: size3)
      precondition(!overflow0 && !overflow1 && !overflow2)
      self.capacity = capacity
    }
    unsafe self.hasPayload = .allocate(capacity: capacity)
    unsafe self.hasPayload.initialize(repeating: false, count: capacity)
    unsafe self.payload = .allocate(capacity: capacity)
    self.size0 = size0
    self.size1 = size1
    self.size2 = size2
    self.size3 = size3
  }

  deinit {
    for i in 0..<capacity {
      if unsafe hasPayload[i] {
        unsafe (payload + i).deinitialize(count: 1)
      }
    }
    unsafe payload.deallocate()
    unsafe hasPayload.deinitialize(count: capacity)
    unsafe hasPayload.deallocate()
  }

  /// Destroys every set element and returns each slot to the unset state.
  ///
  /// The shape and allocated storage are preserved, so every position can be reused.
  ///
  /// - Complexity: O(`size0 * size1 * size2 * size3`)
  @inlinable
  public func removeAll() {
    for i in 0..<capacity {
      if unsafe hasPayload[i] {
        unsafe (payload + i).deinitialize(count: 1)
      }
    }
    unsafe hasPayload.update(repeating: false, count: capacity)
  }

}

extension OptionalElementBuffer4D {

  /// Returns `0..<size3`, the valid positions along the outermost axis.
  ///
  /// - Complexity: O(1)
  public var indices: Range<Int> { 0..<size3 }

  /// Returns the element at `(x, y, z, w)`. Returns `nil` if it is unset.
  ///
  /// - Precondition: `x`, `y`, `z`, and `w`
  ///   must be in `0..<size0`, `0..<size1`, `0..<size2`, and `0..<size3`, respectively.
  @inlinable
  public func element(at x: Int, _ y: Int, _ z: Int, _ w: Int) -> Element? {
    precondition(0 <= x && x < size0)
    precondition(0 <= y && y < size1)
    precondition(0 <= z && z < size2)
    precondition(0 <= w && w < size3)
    let offset = ((w * size2 + z) * size1 + y) * size0 + x
    guard unsafe hasPayload[offset] else { return nil }
    return unsafe payload[offset]
  }

  // MEMO: mutableにすると実行検査が増えるので競技プログラミングとしてうれしくない
  // 一般供用としてはmutable必須なので、一般供用不可となる
  /// Sets the element at `(x, y, z, w)`. Passing `nil` returns the slot to the unset state.
  ///
  /// - Precondition: `x`, `y`, `z`, and `w`
  ///   must be in `0..<size0`, `0..<size1`, `0..<size2`, and `0..<size3`, respectively.
  @inlinable
  public func setElement(
    _ newValue: consuming Element?, at x: Int, _ y: Int, _ z: Int, _ w: Int
  ) {
    precondition(0 <= x && x < size0)
    precondition(0 <= y && y < size1)
    precondition(0 <= z && z < size2)
    precondition(0 <= w && w < size3)
    let offset = ((w * size2 + z) * size1 + y) * size0 + x
    if unsafe hasPayload[offset] {
      unsafe (payload + offset).deinitialize(count: 1)
    }
    if let newValue = consume newValue {
      unsafe (payload + offset).initialize(to: newValue)
      unsafe hasPayload[offset] = true
    } else {
      unsafe hasPayload[offset] = false
    }
  }
}

extension OptionalElementBuffer4D: @unchecked Sendable where Element: Sendable {}
