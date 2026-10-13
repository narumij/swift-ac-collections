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

/// メモ化用配列
///
/// 配列ベースのメモ化に用いる配列です。
/// 未初期化値の番兵を用意することなく利用できます。
/// 各slotは未設定状態、または一つの`Element`を所有する設定済み状態のどちらかです。
/// `setElement(_:at:)`へ`nil`を渡すと、設定済みの要素を破棄して未設定状態へ戻します。
/// `Element`が`Sendable`なら、配列も`Sendable`です。
/// `-Ounchecked`では、記載された事前条件の実行時検査が省略される場合があります。
@safe public struct OptionalElementBuffer<Element>: ~Copyable {

  @usableFromInline let count: Int
  @usableFromInline let hasPayload: UnsafeMutablePointer<Bool>
  @usableFromInline let payload: UnsafeMutablePointer<Element>

  /// `capacity`個の未設定slotを持つ配列を作ります。
  ///
  /// `capacity`が0なら空の配列を作ります。
  ///
  /// - Parameter capacity: slot数。
  /// - Precondition: `capacity`は0以上でなければなりません。
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

  /// 設定済みの要素をすべて破棄し、各slotを未設定状態へ戻します。
  ///
  /// slot数と確保済みstorageは保持され、各位置を再利用できます。
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

  /// 有効なslot位置である`0..<capacity`を返します。
  ///
  /// - Complexity: O(1)
  public var indices: Range<Int> { 0..<count }

  /// `position`の要素を返します。未設定なら`nil`を返します。
  @inlinable
  public func element(at position: Int) -> Element? {
    precondition(0 <= position && position < count)
    guard unsafe hasPayload[position] else { return nil }
    return unsafe payload[position]
  }

  /// `position`の要素を設定します。`nil`はslotを未設定状態へ戻します。
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

extension OptionalElementBuffer: @unchecked Sendable where Element: Sendable { }

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

/// メモ化用配列
///
/// 配列ベースのメモ化に用いる配列です。
/// 未初期化値の番兵を用意することなく利用できます。
/// 各slotは未設定状態、または一つの`Element`を所有する設定済み状態のどちらかです。
/// 座標は`(x, y)`の順で、`width`が最内軸、`height`が最外軸です。
/// `Element`が`Sendable`なら、配列も`Sendable`です。
/// `-Ounchecked`では、記載された事前条件の実行時検査が省略される場合があります。
@frozen
@safe public struct OptionalElementBuffer2D<Element>: ~Copyable {

  @usableFromInline let hasPayload: UnsafeMutablePointer<Bool>
  @usableFromInline let payload: UnsafeMutablePointer<Element>
  @usableFromInline let width: Int
  @usableFromInline let height: Int
  @usableFromInline let capacity: Int

  /// `width * height`個の未設定slotを持つ配列を作ります。
  ///
  /// いずれかの次元が0なら要素を持たない配列を作ります。
  ///
  /// - Parameters:
  ///   - width: 最内軸のslot数。
  ///   - height: 最外軸のslot数。
  /// - Precondition: 各次元は0以上で、その積を`Int`で表現できなければなりません。
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

  /// 設定済みの要素をすべて破棄し、各slotを未設定状態へ戻します。
  ///
  /// shapeと確保済みstorageは保持され、各位置を再利用できます。
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

  /// 外側の軸に有効な位置である`0..<height`を返します。
  ///
  /// - Complexity: O(1)
  public var indices: Range<Int> { 0..<height }

  /// `(x, y)`の要素を返します。未設定なら`nil`を返します。
  @inlinable
  public func element(at x: Int, _ y: Int) -> Element? {
    precondition(0 <= x && x < width)
    precondition(0 <= y && y < height)
    let offset = y * width + x
    guard unsafe hasPayload[offset] else { return nil }
    return unsafe payload[offset]
  }

  /// `(x, y)`の要素を設定します。`nil`はslotを未設定状態へ戻します。
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

extension OptionalElementBuffer2D: @unchecked Sendable where Element: Sendable { }

/// メモ化用配列
///
/// 配列ベースのメモ化に用いる配列です。
/// 未初期化値の番兵を用意することなく利用できます。
/// 各slotは未設定状態、または一つの`Element`を所有する設定済み状態のどちらかです。
/// 座標は`(x, y, z)`の順で、`width`が最内軸、`depth`が最外軸です。
/// `Element`が`Sendable`なら、配列も`Sendable`です。
/// `-Ounchecked`では、記載された事前条件の実行時検査が省略される場合があります。
@frozen
@safe public struct OptionalElementBuffer3D<Element>: ~Copyable {

  @usableFromInline let hasPayload: UnsafeMutablePointer<Bool>
  @usableFromInline let payload: UnsafeMutablePointer<Element>
  @usableFromInline let width: Int
  @usableFromInline let height: Int
  @usableFromInline let depth: Int
  @usableFromInline let capacity: Int

  /// `width * height * depth`個の未設定slotを持つ配列を作ります。
  ///
  /// いずれかの次元が0なら要素を持たない配列を作ります。
  ///
  /// - Parameters:
  ///   - width: 最内軸のslot数。
  ///   - height: 中間軸のslot数。
  ///   - depth: 最外軸のslot数。
  /// - Precondition: 各次元は0以上で、その積を`Int`で表現できなければなりません。
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

  /// 設定済みの要素をすべて破棄し、各slotを未設定状態へ戻します。
  ///
  /// shapeと確保済みstorageは保持され、各位置を再利用できます。
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

  /// 外側の軸に有効な位置である`0..<depth`を返します。
  ///
  /// - Complexity: O(1)
  public var indices: Range<Int> { 0..<depth }
}

extension OptionalElementBuffer3D {

  /// `(x, y, z)`の要素を返します。未設定なら`nil`を返します。
  @inlinable
  public func element(at x: Int, _ y: Int, _ z: Int) -> Element? {
    precondition(0 <= x && x < width)
    precondition(0 <= y && y < height)
    precondition(0 <= z && z < depth)
    let offset = (z * height + y) * width + x
    guard unsafe hasPayload[offset] else { return nil }
    return unsafe payload[offset]
  }

  /// `(x, y, z)`の要素を設定します。`nil`はslotを未設定状態へ戻します。
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

extension OptionalElementBuffer3D: @unchecked Sendable where Element: Sendable { }

/// メモ化用配列
///
/// 配列ベースのメモ化に用いる配列です。
/// 未初期化値の番兵を用意することなく利用できます。
/// 各slotは未設定状態、または一つの`Element`を所有する設定済み状態のどちらかです。
/// 座標は`(x, y, z, w)`の順で、`size0`が最内軸、
/// `size3`が最外軸です。
/// `Element`が`Sendable`なら、配列も`Sendable`です。
/// `-Ounchecked`では、記載された事前条件の実行時検査が省略される場合があります。
@frozen
@safe public struct OptionalElementBuffer4D<Element>: ~Copyable {

  @usableFromInline let hasPayload: UnsafeMutablePointer<Bool>
  @usableFromInline let payload: UnsafeMutablePointer<Element>
  @usableFromInline let size0: Int
  @usableFromInline let size1: Int
  @usableFromInline let size2: Int
  @usableFromInline let size3: Int
  @usableFromInline let capacity: Int

  /// `size0 * size1 * size2 * size3`個の未設定slotを持つ配列を作ります。
  ///
  /// いずれかの次元が0なら要素を持たない配列を作ります。
  ///
  /// - Parameters:
  ///   - size0: 最内軸のslot数。
  ///   - size1: 内側から2番目の軸のslot数。
  ///   - size2: 内側から3番目の軸のslot数。
  ///   - size3: 最外軸のslot数。
  /// - Precondition: 各次元は0以上で、その積を`Int`で表現できなければなりません。
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

  /// 設定済みの要素をすべて破棄し、各slotを未設定状態へ戻します。
  ///
  /// shapeと確保済みstorageは保持され、各位置を再利用できます。
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

  /// 外側の軸に有効な位置である`0..<size3`を返します。
  ///
  /// - Complexity: O(1)
  public var indices: Range<Int> { 0..<size3 }

  /// `(x, y, z, w)`の要素を返します。未設定なら`nil`を返します。
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

  /// `(x, y, z, w)`の要素を設定します。`nil`はslotを未設定状態へ戻します。
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

extension OptionalElementBuffer4D: @unchecked Sendable where Element: Sendable { }
