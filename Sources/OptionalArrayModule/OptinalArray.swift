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
/// subscriptへ`nil`を代入すると、設定済みの要素を破棄して未設定状態へ戻します。
public struct OptionalArray1D<Element>: ~Copyable {

  @usableFromInline let count: Int
  @usableFromInline let hasPayload: UnsafeMutablePointer<Bool>
  @usableFromInline let payload: UnsafeMutablePointer<Element>

  @inlinable
  public init(capacity: Int) {
    self.count = capacity
    self.hasPayload = .allocate(capacity: capacity)
    unsafe self.hasPayload.initialize(repeating: false, count: capacity)
    self.payload = .allocate(capacity: capacity)
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

  /// すべての要素を破棄し、各slotを未設定状態へ戻します。
  @inlinable
  public func removeAll() {
    for i in 0..<count {
      if unsafe hasPayload[i] {
        unsafe (payload + i).deinitialize(count: 1)
      }
    }
    unsafe hasPayload.update(repeating: false, count: count)
  }

  /// 指定位置の要素を取得または更新します。
  ///
  /// 未設定の位置からは`nil`を返します。非`nil`の値を代入するとその位置へ要素を構築し、
  /// `nil`を代入すると既存要素をちょうど一度破棄します。
  ///
  /// - Precondition: `position`が`indices`に含まれること。
  @inlinable
  public subscript(position: Int) -> Element? {

    @inline(__always)
    get {
      precondition(0 <= position && position < count)
      guard unsafe hasPayload[position] else {
        return nil
      }
      return unsafe payload[position]
    }

    @inline(__always)
    _modify {
      precondition(0 <= position && position < count)
      var value = unsafe hasPayload[position] ? (payload + position).move() : nil
      defer {
        if let value {
          unsafe hasPayload[position] = true
          unsafe (payload + position).initialize(to: value)
        } else {
          // `.move()`済み(または元々未初期化)のスロットはすでに未初期化状態なので、
          // ここであらためて`deinitialize`してはいけない(二重解放になる)。
          unsafe hasPayload[position] = false
        }
      }
      yield &value
    }
  }
}

extension OptionalArray1D {
  
  public var indices: Range<Int> { 0..<count }
}

extension OptionalArray1D: @unchecked Sendable where Element: Sendable { }

extension OptionalArray1D {

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
    unsafe self.hasPayload.initialize(repeating: false, count: capacity)
    self.payload = .allocate(capacity: capacity)
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

  @inlinable
  public func removeAll() {
    for i in 0..<capacity {
      if unsafe hasPayload[i] {
        unsafe (payload + i).deinitialize(count: 1)
      }
    }
    unsafe hasPayload.update(repeating: false, count: capacity)
  }

  @inlinable
  public subscript(position: Int) -> OptionalArray1DView<Element> {
    @inline(__always)
    get {
      precondition(0 <= position && position < height)
      return unsafe .init(
        hasPayload: hasPayload + width * position,
        payload: payload + width * position,
        count: width)
    }

    @inline(__always)
    set {
      // The mutation has already been applied through the pointer-backed View.
      // This setter only completes writeback for a chained subscript expression.
      /* NOP */
    }
  }
}

extension OptionalArray2D {

  public var indices: Range<Int> { 0..<height }
}

extension OptionalArray2D: @unchecked Sendable where Element: Sendable { }

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
    unsafe self.hasPayload.initialize(repeating: false, count: capacity)
    self.payload = .allocate(capacity: capacity)
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

  @inlinable
  public func removeAll() {
    for i in 0..<capacity {
      if unsafe hasPayload[i] {
        unsafe (payload + i).deinitialize(count: 1)
      }
    }
    unsafe hasPayload.update(repeating: false, count: capacity)
  }

  @inlinable
  public subscript(position: Int) -> OptionalArray2DView<Element> {
    @inline(__always)
    get {
      precondition(0 <= position && position < depth)
      return unsafe .init(
        hasPayload: hasPayload + width * height * position,
        payload: payload + width * height * position,
        width: width, height: height)
    }

    @inline(__always)
    set {
      // The mutation has already been applied through the pointer-backed View.
      // This setter only completes writeback for a chained subscript expression.
      /* NOP */
    }
  }
}

extension OptionalArray3D {

  public var indices: Range<Int> { 0..<depth }
}

extension OptionalArray3D: @unchecked Sendable where Element: Sendable { }

/// メモ化用配列
///
/// 配列ベースのメモ化に用いる配列です。
/// 未初期化値の番兵を用意することなく利用できます。
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
    unsafe self.hasPayload.initialize(repeating: false, count: capacity)
    self.payload = .allocate(capacity: capacity)
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

  @inlinable
  public func removeAll() {
    for i in 0..<capacity {
      if unsafe hasPayload[i] {
        unsafe (payload + i).deinitialize(count: 1)
      }
    }
    unsafe hasPayload.update(repeating: false, count: capacity)
  }

  @inlinable
  public subscript(position: Int) -> OptionalArray3DView<Element> {
    @inline(__always)
    get {
      precondition(0 <= position && position < size3)
      return unsafe .init(
        hasPayload: hasPayload + size0 * size1 * size2 * position,
        payload: payload + size0 * size1 * size2 * position,
        width: size0,
        height: size1,
        depth: size2)
    }

    @inline(__always)
    set {
      // The mutation has already been applied through the pointer-backed View.
      // This setter only completes writeback for a chained subscript expression.
      /* NOP */
    }
  }
}

extension OptionalArray4D {

  public var indices: Range<Int> { 0..<size3 }
}

extension OptionalArray4D: @unchecked Sendable where Element: Sendable { }

// MARK: -

/// 要素アクセスの為の一時データ構造
///
/// 親の多次元配列が所有する一部分を参照します。View自身はstorageを所有しません。
/// 親配列の生存中だけ使用でき、Viewを親配列より長く保持してはいけません。
/// Viewを通じた変更は親配列の同じ要素へ反映されます。
public struct OptionalArray1DView<Element> {

  @inlinable
  @unsafe internal init(
    hasPayload: UnsafeMutablePointer<Bool>,
    payload: UnsafeMutablePointer<Element>,
    count: Int
  ) {
    self.count = count
    self.hasPayload = unsafe hasPayload
    self.payload = unsafe payload
  }
  @usableFromInline var count: Int
  @usableFromInline let hasPayload: UnsafeMutablePointer<Bool>
  @usableFromInline let payload: UnsafeMutablePointer<Element>

  /// 指定位置の要素を取得または更新します。
  ///
  /// `nil`を代入すると親配列が所有する既存要素を破棄し、そのslotを未設定状態へ戻します。
  ///
  /// - Precondition: `position`がこのViewの有効範囲に含まれること。
  @inlinable
  public subscript(position: Int) -> Element? {

    @inline(__always)
    get {
      precondition(0 <= position && position < count)
      guard unsafe hasPayload[position] else {
        return nil
      }
      return unsafe payload[position]
    }

    @inline(__always)
    _modify {
      precondition(0 <= position && position < count)
      var value = unsafe hasPayload[position] ? (payload + position).move() : nil
      defer {
        if let value {
          unsafe hasPayload[position] = true
          unsafe (payload + position).initialize(to: value)
        } else {
          // `.move()`済み(または元々未初期化)のスロットはすでに未初期化状態なので、
          // ここであらためて`deinitialize`してはいけない(二重解放になる)。
          unsafe hasPayload[position] = false
        }
      }
      yield &value
    }
  }
}

extension OptionalArray1DView {
  public var indices: Range<Int> { 0..<count }
}

/// 要素アクセスの為の一時データ構造
///
/// 親配列のstorageを所有せずに参照する2次元Viewです。
/// 親配列の生存中だけ使用でき、Viewを通じた変更は親配列へ反映されます。
public struct OptionalArray2DView<Element> {

  @inlinable
  @unsafe internal init(
    hasPayload: UnsafeMutablePointer<Bool>,
    payload: UnsafeMutablePointer<Element>,
    width: Int, height: Int
  ) {
    self.hasPayload = unsafe hasPayload
    self.payload = unsafe payload
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
      precondition(0 <= position && position < height)
      return unsafe .init(
        hasPayload: hasPayload + width * position,
        payload: payload + width * position,
        count: width)
    }

    @inline(__always)
    set {
      // The mutation has already been applied through the pointer-backed View.
      // This setter only completes writeback for a chained subscript expression.
      /* NOP */
    }
  }
}

extension OptionalArray2DView {
  public var indices: Range<Int> { 0..<height }
}

/// 要素アクセスの為の一時データ構造
///
/// 親配列のstorageを所有せずに参照する3次元Viewです。
/// 親配列の生存中だけ使用でき、Viewを通じた変更は親配列へ反映されます。
public struct OptionalArray3DView<Element> {

  @inlinable
  @unsafe internal init(
    hasPayload: UnsafeMutablePointer<Bool>,
    payload: UnsafeMutablePointer<Element>,
    width: Int, height: Int, depth: Int
  ) {
    self.hasPayload = unsafe hasPayload
    self.payload = unsafe payload
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
      precondition(0 <= position && position < depth)
      return unsafe .init(
        hasPayload: hasPayload + width * height * position,
        payload: payload + width * height * position,
        width: width,
        height: height)
    }

    @inline(__always)
    set {
      // The mutation has already been applied through the pointer-backed View.
      // This setter only completes writeback for a chained subscript expression.
      /* NOP */
    }
  }
}

extension OptionalArray3DView {
  public var indices: Range<Int> { 0..<depth }
}

// Bare Naked Ladies オマージュかもしれない
