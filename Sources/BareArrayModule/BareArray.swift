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

/// 競技プログラミング用多次元配列
///
/// ヒープ領域に確保される軽量な多次元配列です。
/// 動的計画法などで利用する大きな配列を簡潔に記述できます。
///
/// 要素は連続したメモリ領域に格納され、C言語の配列に近いアクセス性能を持ちます。
public struct BareArray<Element>: ~Copyable {

  @inlinable
  public init(repeating value: Element, count: Int) {
    let capacity = count
    self.payload = .allocate(capacity: capacity)
    self.payload.initialize(repeating: value, count: capacity)
    self.count = count
  }

  @inlinable
  public init(count: Int, _ f: () -> Element) {
    let capacity = count
    self.payload = .allocate(capacity: capacity)
    for i in 0..<count {
      (payload + i).initialize(to: f())
    }
    self.count = count
  }

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

  @inlinable
  func clone() -> Self {
    let payload = UnsafeMutablePointer<Element>.allocate(capacity: count)
    payload.initialize(from: self.payload, count: count)
    return .init(payload: payload, count: count)
  }
}

extension BareArray {

  @inlinable
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
  public init(repeating value: Element, width: Int, height: Int) {
    self.capacity = height * width
    self.payload = .allocate(capacity: capacity)
    self.payload.initialize(repeating: value, count: capacity)
    self.width = width
    self.height = height
  }

  @inlinable
  public init(width: Int, height: Int, _ f: () -> Element) {
    self.capacity = height * width
    self.payload = .allocate(capacity: capacity)
    for i in 0..<capacity {
      (payload + i).initialize(to: f())
    }
    self.width = width
    self.height = height
  }

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

  @inlinable
  func clone() -> Self {
    let payload = UnsafeMutablePointer<Element>.allocate(capacity: capacity)
    payload.initialize(from: self.payload, count: capacity)
    return .init(payload: payload, width: width, height: height)
  }
}

extension BareArray2D {

  @inlinable
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
  public init(repeating value: Element, width: Int, height: Int, depth: Int) {
    self.capacity = height * width * depth
    self.payload = .allocate(capacity: capacity)
    self.payload.initialize(repeating: value, count: capacity)
    self.width = width
    self.height = height
    self.depth = depth
  }

  @inlinable
  public init(width: Int, height: Int, depth: Int, _ f: () -> Element) {
    self.capacity = width * height * depth
    self.payload = .allocate(capacity: capacity)
    for i in 0..<capacity {
      (payload + i).initialize(to: f())
    }
    self.width = width
    self.height = height
    self.depth = depth
  }

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

  @inlinable
  func clone() -> Self {
    let payload = UnsafeMutablePointer<Element>.allocate(capacity: capacity)
    payload.initialize(from: self.payload, count: capacity)
    return .init(payload: payload, width: width, height: height, depth: depth)
  }
}

extension BareArray3D {

  @inlinable
  public var indices: Range<Int> { 0..<depth }
}

public struct BareArray4D<Element>: ~Copyable {

  @inlinable
  public init(repeating value: Element, size0: Int, size1: Int, size2: Int, size3: Int) {
    self.capacity = size0 * size1 * size2 * size3
    self.payload = .allocate(capacity: capacity)
    self.payload.initialize(repeating: value, count: capacity)
    self.size0 = size0
    self.size1 = size1
    self.size2 = size2
    self.size3 = size3
  }

  @inlinable
  public init(size0: Int, size1: Int, size2: Int, size3: Int, _ f: () -> Element) {
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
  
  @inlinable
  internal init(payload: UnsafeMutablePointer<Element>, size0: Int, size1: Int, size2: Int, size3: Int) {
    self.capacity = size0 * size1 * size2 * size3
    self.payload = payload
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
  
  @inlinable
  func clone() -> Self {
    let payload = UnsafeMutablePointer<Element>.allocate(capacity: capacity)
    payload.initialize(from: self.payload, count: capacity)
    return .init(payload: payload, size0: size0, size1: size1, size2: size2, size3: size3)
  }
}

extension BareArray4D {

  @inlinable
  public var indices: Range<Int> { 0..<size3 }
}

// MARK: -

/// 要素アクセスの為の一時データ構造
///
/// 参照型の挙動をする
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

  @inlinable
  public var indices: Range<Int> { 0..<count }
}

/// 要素アクセスの為の一時データ構造
///
/// 参照型の挙動をする
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

  @inlinable
  public var indices: Range<Int> { 0..<height }
}

/// 要素アクセスの為の一時データ構造
///
/// 参照型の挙動をする
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

  @inlinable
  public var indices: Range<Int> { 0..<depth }
}
