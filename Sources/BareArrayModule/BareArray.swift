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

/// 競技プログラミング用1次元配列
///
/// ヒープ領域に確保される軽量な配列です。
/// 動的計画法などで利用する大きな配列を簡潔に記述できます。
///
/// 要素は連続したメモリ領域に格納され、C言語の配列に近いアクセス性能を持ちます。
/// この型は要素を所有し、配列の破棄時にすべての要素を破棄します。
// MEMO: 以下の記述は冗長に感じるので使用しないことにした
// `Element`が`Sendable`なら、配列も`Sendable`です。
// `-Ounchecked`では、記載された事前条件の実行時検査が省略される場合があります。
@safe public struct BareArray<Element>: ~Copyable {

  /// `count`個の要素を`value`で初期化します。
  ///
  /// - Parameters:
  ///   - value: 各位置へ格納する値。
  ///   - count: 要素数。
  /// - Precondition: `count`は0以上でなければなりません。
  /// - Complexity: O(`count`)
  @inlinable
  public init(repeating value: Element, count: Int) {
    precondition(count >= 0)
    let capacity = count
    unsafe self.payload = .allocate(capacity: capacity)
    unsafe self.payload.initialize(repeating: value, count: capacity)
    self.count = count
  }

  /// `value`を`count`回呼び、その返り値を添字順に格納します。
  ///
  /// `count`が0のとき、`f`は呼ばれません。
  ///
  /// - Parameters:
  ///   - count: 要素数。
  ///   - value: 各要素を添字順に生成するクロージャ。
  /// - Precondition: `count`は0以上でなければなりません。
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

extension BareArray {

  /// 有効な要素位置である`0..<count`を返します。
  ///
  /// - Complexity: O(1)
  @inlinable
  public var indices: Range<Int> { 0..<count }
}

extension BareArray: @unchecked Sendable where Element: Sendable {}

/// 競技プログラミング用多次元配列
///
/// ヒープ領域に確保される軽量な多次元配列です。
/// 動的計画法などで利用する大きな配列を簡潔に記述できます。
///
/// 要素は連続したメモリ領域に格納され、C言語の配列に近いアクセス性能を持ちます。
/// 座標accessでは`width`が最内軸、`height`が最外軸です。
/// この型は要素を所有し、配列の破棄時にすべての要素を破棄します。
// MEMO: 以下の記述は冗長に感じるので使用しないことにした
// `Element`が`Sendable`なら、配列も`Sendable`です。
// `-Ounchecked`では、記載された事前条件の実行時検査が省略される場合があります。
@safe public struct BareArray2D<Element>: ~Copyable {

  /// `width * height`個の要素を`value`で初期化します。
  ///
  /// いずれかの次元が0なら空のstorageを作ります。
  ///
  /// - Parameters:
  ///   - value: 各位置へ格納する値。
  ///   - width: 最内軸の要素数。
  ///   - height: 最外軸の要素数。
  /// - Precondition: 各次元は0以上で、その積を`Int`で表現できなければなりません。
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

  /// `f`を`width * height`回呼び、その返り値を連続するstorageへ順に格納します。
  ///
  /// いずれかの次元が0なら`f`は呼ばれません。
  ///
  /// - Parameters:
  ///   - width: 最内軸の要素数。
  ///   - height: 最外軸の要素数。
  ///   - f: 各要素をstorage順に生成するクロージャ。
  /// - Precondition: 各次元は0以上で、その積を`Int`で表現できなければなりません。
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

extension BareArray2D {

  /// 外側の軸に有効な位置である`0..<height`を返します。
  ///
  /// - Complexity: O(1)
  @inlinable
  public var indices: Range<Int> { 0..<height }
}

extension BareArray2D: @unchecked Sendable where Element: Sendable {}

/// 競技プログラミング用多次元配列
///
/// ヒープ領域に確保される軽量な多次元配列です。
/// 動的計画法などで利用する大きな配列を簡潔に記述できます。
///
/// 要素は連続したメモリ領域に格納され、C言語の配列に近いアクセス性能を持ちます。
/// 座標accessでは`width`が最内軸、`depth`が最外軸です。
/// この型は要素を所有し、配列の破棄時にすべての要素を破棄します。
// MEMO: 以下の記述は冗長に感じるので使用しないことにした
// `Element`が`Sendable`なら、配列も`Sendable`です。
// `-Ounchecked`では、記載された事前条件の実行時検査が省略される場合があります。
@safe public struct BareArray3D<Element>: ~Copyable {

  /// `width * height * depth`個の要素を`value`で初期化します。
  ///
  /// いずれかの次元が0なら空のstorageを作ります。
  ///
  /// - Parameters:
  ///   - value: 各位置へ格納する値。
  ///   - width: 最内軸の要素数。
  ///   - height: 中間軸の要素数。
  ///   - depth: 最外軸の要素数。
  /// - Precondition: 各次元は0以上で、その積を`Int`で表現できなければなりません。
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

  /// `f`を要素数と同じ回数呼び、その返り値を連続するstorageへ順に格納します。
  ///
  /// いずれかの次元が0なら`f`は呼ばれません。
  ///
  /// - Parameters:
  ///   - width: 最内軸の要素数。
  ///   - height: 中間軸の要素数。
  ///   - depth: 最外軸の要素数。
  ///   - f: 各要素をstorage順に生成するクロージャ。
  /// - Precondition: 各次元は0以上で、その積を`Int`で表現できなければなりません。
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

extension BareArray3D {

  /// 外側の軸に有効な位置である`0..<depth`を返します。
  ///
  /// - Complexity: O(1)
  @inlinable
  public var indices: Range<Int> { 0..<depth }
}

extension BareArray3D: @unchecked Sendable where Element: Sendable {}

/// 連続したメモリ領域に要素を所有する4次元配列です。
///
/// 座標accessでは`size0`が最内軸、`size3`が最外軸で、
/// storage上では`size0`の軸が最も速く進みます。
/// この型は要素を所有し、配列の破棄時にすべての要素を破棄します。
// MEMO: 以下の記述は冗長に感じるので使用しないことにした
// `Element`が`Sendable`なら、配列も`Sendable`です。
// `-Ounchecked`では、記載された事前条件の実行時検査が省略される場合があります。
@safe public struct BareArray4D<Element>: ~Copyable {

  /// 全要素を`value`で初期化します。
  ///
  /// いずれかの次元が0なら空のstorageを作ります。
  ///
  /// - Parameters:
  ///   - value: 各位置へ格納する値。
  ///   - size0: 最内軸の要素数。
  ///   - size1: 内側から2番目の軸の要素数。
  ///   - size2: 内側から3番目の軸の要素数。
  ///   - size3: 最外軸の要素数。
  /// - Precondition: 各次元は0以上で、その積を`Int`で表現できなければなりません。
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

  /// `f`を要素数と同じ回数呼び、その返り値を連続するstorageへ順に格納します。
  ///
  /// いずれかの次元が0なら`f`は呼ばれません。
  ///
  /// - Parameters:
  ///   - size0: 最内軸の要素数。
  ///   - size1: 内側から2番目の軸の要素数。
  ///   - size2: 内側から3番目の軸の要素数。
  ///   - size3: 最外軸の要素数。
  ///   - f: 各要素をstorage順に生成するクロージャ。
  /// - Precondition: 各次元は0以上で、その積を`Int`で表現できなければなりません。
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

extension BareArray4D {

  /// 外側の軸に有効な位置である`0..<size3`を返します。
  ///
  /// - Complexity: O(1)
  @inlinable
  public var indices: Range<Int> { 0..<size3 }
}

extension BareArray4D: @unchecked Sendable where Element: Sendable {}

// MARK: -

extension BareArray {

  @available(anyAppleOS 27.0, *)
  @inlinable
  @_lifetime(&self)
  public mutating func reference(at position: Int) -> MutableRef<Element> {
    precondition(0 <= position && position < count)
    return unsafe .init(unsafeAddress: payload + position, mutating: &self)
  }

  @inlinable
  public func element(at position: Int) -> Element {
    precondition(0 <= position && position < count)
    return unsafe payload[position]
  }

  @inlinable
  public func setElement(_ newValue: consuming Element, at position: Int) {
    precondition(0 <= position && position < count)
    unsafe payload[position] = newValue
  }
}

extension BareArray2D {

  @available(anyAppleOS 27.0, *)
  @inlinable
  @_lifetime(&self)
  public mutating func reference(at x: Int, _ y: Int) -> MutableRef<Element> {
    precondition(0 <= x && x < width)
    precondition(0 <= y && y < height)
    return unsafe .init(unsafeAddress: payload + y * width + x, mutating: &self)
  }

  @inlinable
  public func element(at x: Int, _ y: Int) -> Element {
    precondition(0 <= x && x < width)
    precondition(0 <= y && y < height)
    return unsafe payload[y * width + x]
  }

  @inlinable
  public func setElement(_ newValue: consuming Element, at x: Int, _ y: Int) {
    precondition(0 <= x && x < width)
    precondition(0 <= y && y < height)
    unsafe payload[y * width + x] = newValue
  }
}

extension BareArray3D {

  @available(anyAppleOS 27.0, *)
  @inlinable
  @_lifetime(&self)
  public mutating func reference(at x: Int, _ y: Int, _ z: Int) -> MutableRef<Element> {
    precondition(0 <= x && x < width)
    precondition(0 <= y && y < height)
    precondition(0 <= z && z < depth)
    return unsafe .init(unsafeAddress: payload + (z * height + y) * width + x, mutating: &self)
  }

  @inlinable
  public func element(at x: Int, _ y: Int, _ z: Int) -> Element {
    precondition(0 <= x && x < width)
    precondition(0 <= y && y < height)
    precondition(0 <= z && z < depth)
    return unsafe payload[(z * height + y) * width + x]
  }

  @inlinable
  public func setElement(_ newValue: consuming Element, at x: Int, _ y: Int, _ z: Int) {
    precondition(0 <= x && x < width)
    precondition(0 <= y && y < height)
    precondition(0 <= z && z < depth)
    unsafe payload[(z * height + y) * width + x] = newValue
  }
}

extension BareArray4D {

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

  @inlinable
  public func element(at x: Int, _ y: Int, _ z: Int, _ w: Int) -> Element {
    precondition(0 <= x && x < size0)
    precondition(0 <= y && y < size1)
    precondition(0 <= z && z < size2)
    precondition(0 <= w && w < size3)
    return unsafe payload[((w * size2 + z) * size1 + y) * size0 + x]
  }

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
}
