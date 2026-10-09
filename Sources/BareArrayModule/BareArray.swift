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
/// ヒープ領域に確保される軽量な多次元配列です。
/// 動的計画法などで利用する大きな配列を簡潔に記述できます。
///
/// 要素は連続したメモリ領域に格納され、C言語の配列に近いアクセス性能を持ちます。
/// この型は要素を所有し、配列の破棄時にすべての要素を破棄します。
/// `Element`が`Sendable`なら、配列も`Sendable`です。
/// `-Ounchecked`では、記載された事前条件の実行時検査が省略される場合があります。
public struct BareArray<Element>: ~Copyable {

  /// `count`個の要素を`value`で初期化します。
  ///
  /// - Precondition: `count`は0以上でなければなりません。
  /// - Complexity: O(`count`)
  @inlinable
  public init(repeating value: Element, count: Int) {
    precondition(count >= 0)
    let capacity = count
    self.payload = .allocate(capacity: capacity)
    unsafe self.payload.initialize(repeating: value, count: capacity)
    self.count = count
  }

  /// `f`を`count`回呼び、その返り値を添字順に格納します。
  ///
  /// `count`が0のとき、`f`は呼ばれません。
  ///
  /// - Precondition: `count`は0以上でなければなりません。
  /// - Complexity: O(`count`)
  @inlinable
  public init(count: Int, _ f: () -> Element) {
    precondition(count >= 0)
    let capacity = count
    self.payload = .allocate(capacity: capacity)
    for i in 0..<count {
      unsafe (payload + i).initialize(to: f())
    }
    self.count = count
  }

  @inlinable
  @unsafe internal init(payload: UnsafeMutablePointer<Element>, count: Int) {
    self.count = count
    self.payload = unsafe payload
  }

  @usableFromInline let count: Int
  @usableFromInline let payload: UnsafeMutablePointer<Element>

  /// `position`の要素へアクセスします。
  ///
  /// 値を置き換えると、以前の要素は破棄されます。
  ///
  /// - Precondition: `position`は`indices`に含まれなければなりません。
  /// - Complexity: O(1)
  @inlinable
  public subscript(position: Int) -> Element {
    @inline(__always)
    unsafeAddress {
      precondition(0 <= position && position < count)
      return unsafe UnsafePointer(payload + position)
    }
    @inline(__always)
    unsafeMutableAddress {
      precondition(0 <= position && position < count)
      return unsafe payload + position
    }
  }

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

extension BareArray: @unchecked Sendable where Element: Sendable { }

/// 競技プログラミング用多次元配列
///
/// ヒープ領域に確保される軽量な多次元配列です。
/// 動的計画法などで利用する大きな配列を簡潔に記述できます。
///
/// 要素は連続したメモリ領域に格納され、C言語の配列に近いアクセス性能を持ちます。
/// 連鎖subscriptは`array[y][x]`の順で、`width`が最内軸、`height`が最外軸です。
/// この型は要素を所有し、配列の破棄時にすべての要素を破棄します。
/// `Element`が`Sendable`なら、配列も`Sendable`です。
/// `-Ounchecked`では、記載された事前条件の実行時検査が省略される場合があります。
public struct BareArray2D<Element>: ~Copyable {

  /// `width * height`個の要素を`value`で初期化します。
  ///
  /// いずれかの次元が0なら空のstorageを作ります。
  ///
  /// - Precondition: 各次元は0以上で、その積を`Int`で表現できなければなりません。
  /// - Complexity: O(`width * height`)
  @inlinable
  public init(repeating value: Element, width: Int, height: Int) {
    precondition(width >= 0 && height >= 0)
    let (capacity, overflow) = height.multipliedReportingOverflow(by: width)
    precondition(!overflow)
    self.capacity = capacity
    self.payload = .allocate(capacity: capacity)
    unsafe self.payload.initialize(repeating: value, count: capacity)
    self.width = width
    self.height = height
  }

  /// `f`を`width * height`回呼び、その返り値を連続するstorageへ順に格納します。
  ///
  /// いずれかの次元が0なら`f`は呼ばれません。
  ///
  /// - Precondition: 各次元は0以上で、その積を`Int`で表現できなければなりません。
  /// - Complexity: O(`width * height`)
  @inlinable
  public init(width: Int, height: Int, _ f: () -> Element) {
    precondition(width >= 0 && height >= 0)
    let (capacity, overflow) = height.multipliedReportingOverflow(by: width)
    precondition(!overflow)
    self.capacity = capacity
    self.payload = .allocate(capacity: capacity)
    for i in 0..<capacity {
      unsafe (payload + i).initialize(to: f())
    }
    self.width = width
    self.height = height
  }

  @inlinable
  @unsafe internal init(payload: UnsafeMutablePointer<Element>, width: Int, height: Int) {
    self.capacity = height * width
    self.payload = unsafe payload
    self.width = width
    self.height = height
  }

  @usableFromInline let capacity: Int
  @usableFromInline let payload: UnsafeMutablePointer<Element>
  @usableFromInline let width: Int
  @usableFromInline let height: Int

  /// `position`番目の行を参照する非所有Viewを返します。
  ///
  /// 返されたViewからの変更はこの配列へ反映されます。Viewはこの配列の生存中だけ使用してください。
  /// setterは連鎖要素書き込みのwriteback専用です。同じ位置から返された同一storage・同一shapeの
  /// Viewだけを受け入れ、別のViewの代入は契約違反です。
  ///
  /// - Precondition: `position`は`indices`に含まれなければなりません。
  /// - Complexity: O(1)
  @inlinable
  public subscript(position: Int) -> BareArray1DView<Element> {

    @inline(__always)
    get {
      precondition(0 <= position && position < height)
      return unsafe .init(payload: payload + width * position, count: width)
    }

    @inline(__always)
    set {
      precondition(0 <= position && position < height)
      precondition(newValue.payload == payload + width * position)
      precondition(newValue.count == width)
    }
  }

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

extension BareArray2D: @unchecked Sendable where Element: Sendable { }

/// 競技プログラミング用多次元配列
///
/// ヒープ領域に確保される軽量な多次元配列です。
/// 動的計画法などで利用する大きな配列を簡潔に記述できます。
///
/// 要素は連続したメモリ領域に格納され、C言語の配列に近いアクセス性能を持ちます。
/// 連鎖subscriptは`array[z][y][x]`の順で、`width`が最内軸、`depth`が最外軸です。
/// この型は要素を所有し、配列の破棄時にすべての要素を破棄します。
/// `Element`が`Sendable`なら、配列も`Sendable`です。
/// `-Ounchecked`では、記載された事前条件の実行時検査が省略される場合があります。
public struct BareArray3D<Element>: ~Copyable {

  /// `width * height * depth`個の要素を`value`で初期化します。
  ///
  /// いずれかの次元が0なら空のstorageを作ります。
  ///
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
    self.payload = .allocate(capacity: capacity)
    unsafe self.payload.initialize(repeating: value, count: capacity)
    self.width = width
    self.height = height
    self.depth = depth
  }

  /// `f`を要素数と同じ回数呼び、その返り値を連続するstorageへ順に格納します。
  ///
  /// いずれかの次元が0なら`f`は呼ばれません。
  ///
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
    self.payload = .allocate(capacity: capacity)
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
    self.payload = unsafe payload
    self.width = width
    self.height = height
    self.depth = depth
  }

  @usableFromInline let capacity: Int
  @usableFromInline let payload: UnsafeMutablePointer<Element>
  @usableFromInline let width: Int
  @usableFromInline let height: Int
  @usableFromInline let depth: Int

  /// `position`番目の面を参照する非所有Viewを返します。
  ///
  /// 返されたViewからの変更はこの配列へ反映されます。Viewはこの配列の生存中だけ使用してください。
  /// setterは連鎖要素書き込みのwriteback専用です。同じ位置の同一storage・同一shapeのViewだけを受け入れ、
  /// 別のViewの代入は契約違反です。
  ///
  /// - Precondition: `position`は`indices`に含まれなければなりません。
  /// - Complexity: O(1)
  @inlinable
  public subscript(position: Int) -> BareArray2DView<Element> {

    @inline(__always)
    get {
      precondition(0 <= position && position < depth)
      return unsafe .init(
        payload: payload + width * height * position, width: width, height: height)
    }

    @inline(__always)
    set {
      precondition(0 <= position && position < depth)
      precondition(newValue.payload == payload + width * height * position)
      precondition(newValue.width == width && newValue.height == height)
    }
  }

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

extension BareArray3D: @unchecked Sendable where Element: Sendable { }

/// 連続したメモリ領域に要素を所有する4次元配列です。
///
/// 連鎖subscriptは`array[w][z][y][x]`の順です。`size0`が最内軸、`size3`が最外軸で、
/// storage上では`size0`の軸が最も速く進みます。
/// この型は要素を所有し、配列の破棄時にすべての要素を破棄します。
/// `Element`が`Sendable`なら、配列も`Sendable`です。
/// `-Ounchecked`では、記載された事前条件の実行時検査が省略される場合があります。
public struct BareArray4D<Element>: ~Copyable {

  /// 全要素を`value`で初期化します。
  ///
  /// いずれかの次元が0なら空のstorageを作ります。
  ///
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
    self.payload = .allocate(capacity: capacity)
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
    self.payload = .allocate(capacity: capacity)
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
    self.payload = unsafe payload
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

  /// `position`番目の3次元領域を参照する非所有Viewを返します。
  ///
  /// `position`は`size3`の軸を選びます。返されたViewからの変更はこの配列へ反映されます。
  /// Viewはこの配列の生存中だけ使用してください。setterは連鎖要素書き込みのwriteback専用です。
  /// 同じ位置の同一storage・同一shapeのViewだけを受け入れ、別のViewの代入は契約違反です。
  ///
  /// - Precondition: `position`は`indices`に含まれなければなりません。
  /// - Complexity: O(1)
  @inlinable
  public subscript(position: Int) -> BareArray3DView<Element> {

    @inline(__always)
    get {
      precondition(0 <= position && position < size3)
      return unsafe .init(
        payload: payload + size0 * size1 * size2 * position, width: size0, height: size1,
        depth: size2)
    }

    @inline(__always)
    set {
      precondition(0 <= position && position < size3)
      precondition(newValue.payload == payload + size0 * size1 * size2 * position)
      precondition(
        newValue.width == size0 && newValue.height == size1 && newValue.depth == size2)
    }
  }

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

extension BareArray4D: @unchecked Sendable where Element: Sendable { }

// MARK: -

/// 所有配列の連続する1次元領域を参照する非所有Viewです。
///
/// Viewからの変更は所有配列の同じ要素へ反映されます。Viewはstorageの寿命を延長しないため、
/// 元の所有配列の生存中だけ使用してください。
/// `-Ounchecked`では、記載された事前条件の実行時検査が省略される場合があります。
public struct BareArray1DView<Element> {

  @inlinable
  @unsafe internal init(payload: UnsafeMutablePointer<Element>, count: Int) {
    self.count = count
    self.payload = unsafe payload
  }

  @usableFromInline let count: Int
  @usableFromInline let payload: UnsafeMutablePointer<Element>

  /// `position`の要素へアクセスします。
  ///
  /// 値を置き換えると、所有配列のstorageにあった以前の要素は破棄されます。
  ///
  /// - Precondition: `position`は`indices`に含まれなければなりません。
  /// - Complexity: O(1)
  @inlinable
  public subscript(position: Int) -> Element {
    @inline(__always)
    unsafeAddress {
      precondition(0 <= position && position < count)
      return unsafe UnsafePointer(payload + position)
    }
    @inline(__always)
    unsafeMutableAddress {
      precondition(0 <= position && position < count)
      return unsafe payload + position
    }
  }
}

extension BareArray1DView {

  /// このViewで有効な位置である`0..<count`を返します。
  ///
  /// - Complexity: O(1)
  @inlinable
  public var indices: Range<Int> { 0..<count }
}

/// 所有配列の連続する2次元領域を参照する非所有Viewです。
///
/// 連鎖subscriptは`view[y][x]`の順です。Viewからの変更は所有配列へ反映されます。
/// Viewはstorageの寿命を延長しないため、元の所有配列の生存中だけ使用してください。
/// `-Ounchecked`では、記載された事前条件の実行時検査が省略される場合があります。
public struct BareArray2DView<Element> {

  @inlinable
  @unsafe internal init(payload: UnsafeMutablePointer<Element>, width: Int, height: Int) {
    self.capacity = height * width
    self.payload = unsafe payload
    self.width = width
    self.height = height
  }

  @usableFromInline let capacity: Int
  @usableFromInline let payload: UnsafeMutablePointer<Element>
  @usableFromInline let width: Int
  @usableFromInline let height: Int

  /// `position`番目の行を参照する非所有Viewを返します。
  ///
  /// setterは連鎖要素書き込みのwriteback専用です。同じ位置の同一storage・同一shapeのViewだけを受け入れ、
  /// 別のViewの代入は契約違反です。
  ///
  /// - Precondition: `position`は`indices`に含まれなければなりません。
  /// - Complexity: O(1)
  @inlinable
  public subscript(position: Int) -> BareArray1DView<Element> {

    @inline(__always)
    get {
      precondition(0 <= position && position < height)
      return unsafe .init(payload: payload + width * position, count: width)
    }

    @inline(__always)
    set {
      precondition(0 <= position && position < height)
      precondition(newValue.payload == payload + width * position)
      precondition(newValue.count == width)
    }
  }
}

extension BareArray2DView {

  /// 外側の軸に有効な位置である`0..<height`を返します。
  ///
  /// - Complexity: O(1)
  @inlinable
  public var indices: Range<Int> { 0..<height }
}

/// 所有配列の連続する3次元領域を参照する非所有Viewです。
///
/// 連鎖subscriptは`view[z][y][x]`の順です。Viewからの変更は所有配列へ反映されます。
/// Viewはstorageの寿命を延長しないため、元の所有配列の生存中だけ使用してください。
/// `-Ounchecked`では、記載された事前条件の実行時検査が省略される場合があります。
public struct BareArray3DView<Element> {

  @inlinable
  @unsafe internal init(
    payload: UnsafeMutablePointer<Element>, width: Int, height: Int, depth: Int
  ) {
    self.capacity = height * width
    self.payload = unsafe payload
    self.width = width
    self.height = height
    self.depth = depth
  }

  @usableFromInline let capacity: Int
  @usableFromInline let payload: UnsafeMutablePointer<Element>
  @usableFromInline let width: Int
  @usableFromInline let height: Int
  @usableFromInline let depth: Int

  /// `position`番目の面を参照する非所有Viewを返します。
  ///
  /// setterは連鎖要素書き込みのwriteback専用です。同じ位置の同一storage・同一shapeのViewだけを受け入れ、
  /// 別のViewの代入は契約違反です。
  ///
  /// - Precondition: `position`は`indices`に含まれなければなりません。
  /// - Complexity: O(1)
  @inlinable
  public subscript(position: Int) -> BareArray2DView<Element> {

    @inline(__always)
    get {
      precondition(0 <= position && position < depth)
      return unsafe .init(
        payload: payload + width * height * position, width: width, height: height)
    }

    @inline(__always)
    set {
      precondition(0 <= position && position < depth)
      precondition(newValue.payload == payload + width * height * position)
      precondition(newValue.width == width && newValue.height == height)
    }
  }
}

extension BareArray3DView {

  /// 外側の軸に有効な位置である`0..<depth`を返します。
  ///
  /// - Complexity: O(1)
  @inlinable
  public var indices: Range<Int> { 0..<depth }
}
