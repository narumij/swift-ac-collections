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
/// `Element`が`Sendable`なら、配列も`Sendable`です。
/// `-Ounchecked`では、記載された事前条件の実行時検査が省略される場合があります。
public struct OptionalArray1D<Element>: ~Copyable {

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

  /// 指定位置の要素を取得または更新します。
  ///
  /// 未設定の位置からは`nil`を返します。非`nil`の値を代入するとその位置へ要素を構築し、
  /// 設定済みの位置へ代入すると以前の要素を破棄して置き換えます。`nil`を代入すると
  /// 既存要素をちょうど一度破棄します。
  ///
  /// - Parameter position: 取得または更新するslotの位置。
  /// - Precondition: `position`が`indices`に含まれること。
  /// - Complexity: O(1)
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

  /// 有効なslot位置である`0..<capacity`を返します。
  ///
  /// - Complexity: O(1)
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
/// 各slotは未設定状態、または一つの`Element`を所有する設定済み状態のどちらかです。
/// 連鎖subscriptは`array[y][x]`の順で、`width`が最内軸、`height`が最外軸です。
/// `Element`が`Sendable`なら、配列も`Sendable`です。
/// `-Ounchecked`では、記載された事前条件の実行時検査が省略される場合があります。
@frozen
public struct OptionalArray2D<Element>: ~Copyable {

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

  /// `position`番目の行を参照する非所有Viewを返します。
  ///
  /// 返されたViewからの変更はこの配列へ反映されます。Viewはこの配列の生存中だけ使用してください。
  /// setterは連鎖要素書き込みのwriteback専用です。同じ位置から返された同一storage・同一shapeの
  /// Viewだけを受け入れ、別のViewの代入は契約違反です。
  ///
  /// - Parameter position: 参照する行の位置。
  /// - Precondition: `position`は`indices`に含まれなければなりません。
  /// - Complexity: O(1)
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
      precondition(0 <= position && position < height)
      let offset = width * position
      precondition(newValue.hasPayload == hasPayload + offset)
      precondition(newValue.payload == payload + offset)
      precondition(newValue.count == width)
    }
  }
}

extension OptionalArray2D {

  /// 外側の軸に有効な位置である`0..<height`を返します。
  ///
  /// - Complexity: O(1)
  public var indices: Range<Int> { 0..<height }
}

extension OptionalArray2D: @unchecked Sendable where Element: Sendable { }

/// メモ化用配列
///
/// 配列ベースのメモ化に用いる配列です。
/// 未初期化値の番兵を用意することなく利用できます。
/// 各slotは未設定状態、または一つの`Element`を所有する設定済み状態のどちらかです。
/// 連鎖subscriptは`array[z][y][x]`の順で、`width`が最内軸、`depth`が最外軸です。
/// `Element`が`Sendable`なら、配列も`Sendable`です。
/// `-Ounchecked`では、記載された事前条件の実行時検査が省略される場合があります。
@frozen
public struct OptionalArray3D<Element>: ~Copyable {

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

  /// `position`番目の2次元面を参照する非所有Viewを返します。
  ///
  /// 返されたViewからの変更はこの配列へ反映されます。Viewはこの配列の生存中だけ使用してください。
  /// setterは連鎖要素書き込みのwriteback専用です。同じ位置の同一storage・同一shapeのViewだけを
  /// 受け入れ、別のViewの代入は契約違反です。
  ///
  /// - Parameter position: 参照する面の位置。
  /// - Precondition: `position`は`indices`に含まれなければなりません。
  /// - Complexity: O(1)
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
      precondition(0 <= position && position < depth)
      let offset = width * height * position
      precondition(newValue.hasPayload == hasPayload + offset)
      precondition(newValue.payload == payload + offset)
      precondition(newValue.width == width && newValue.height == height)
    }
  }
}

extension OptionalArray3D {

  /// 外側の軸に有効な位置である`0..<depth`を返します。
  ///
  /// - Complexity: O(1)
  public var indices: Range<Int> { 0..<depth }
}

extension OptionalArray3D: @unchecked Sendable where Element: Sendable { }

/// メモ化用配列
///
/// 配列ベースのメモ化に用いる配列です。
/// 未初期化値の番兵を用意することなく利用できます。
/// 各slotは未設定状態、または一つの`Element`を所有する設定済み状態のどちらかです。
/// 連鎖subscriptは`array[w][z][y][x]`の順で、`size0`が最内軸、
/// `size3`が最外軸です。
/// `Element`が`Sendable`なら、配列も`Sendable`です。
/// `-Ounchecked`では、記載された事前条件の実行時検査が省略される場合があります。
@frozen
public struct OptionalArray4D<Element>: ~Copyable {

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

  /// `position`番目の3次元領域を参照する非所有Viewを返します。
  ///
  /// 返されたViewからの変更はこの配列へ反映されます。Viewはこの配列の生存中だけ使用してください。
  /// setterは連鎖要素書き込みのwriteback専用です。同じ位置の同一storage・同一shapeのViewだけを
  /// 受け入れ、別のViewの代入は契約違反です。
  ///
  /// - Parameter position: `size3`軸で参照する位置。
  /// - Precondition: `position`は`indices`に含まれなければなりません。
  /// - Complexity: O(1)
  @inlinable
  public subscript(position: Int) -> OptionalArray3DView<Element> {
    @inline(__always)
    get {
      precondition(0 <= position && position < size3)
      // 内側に0の次元があれば要素は無い。途中の積はoverflowし得るので評価しない。
      let offset = size0 == 0 || size1 == 0 || size2 == 0 ? 0 : size0 * size1 * size2 * position
      return unsafe .init(
        hasPayload: hasPayload + offset,
        payload: payload + offset,
        width: size0,
        height: size1,
        depth: size2)
    }

    @inline(__always)
    set {
      precondition(0 <= position && position < size3)
      let offset =
        size0 == 0 || size1 == 0 || size2 == 0 ? 0 : size0 * size1 * size2 * position
      precondition(newValue.hasPayload == hasPayload + offset)
      precondition(newValue.payload == payload + offset)
      precondition(
        newValue.width == size0 && newValue.height == size1 && newValue.depth == size2)
    }
  }
}

extension OptionalArray4D {

  /// 外側の軸に有効な位置である`0..<size3`を返します。
  ///
  /// - Complexity: O(1)
  public var indices: Range<Int> { 0..<size3 }
}

extension OptionalArray4D: @unchecked Sendable where Element: Sendable { }

// MARK: -

/// 要素アクセスの為の一時データ構造
///
/// 親の多次元配列が所有する一部分を参照します。View自身はstorageを所有しません。
/// 親配列の生存中だけ使用でき、Viewを親配列より長く保持してはいけません。
/// Viewを通じた変更は親配列の同じ要素へ反映されます。
/// `-Ounchecked`では、記載された事前条件の実行時検査が省略される場合があります。
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
  /// 設定済みの位置へ非`nil`の値を代入すると、親配列が所有する以前の要素を破棄して
  /// 置き換えます。`nil`を代入すると既存要素を破棄し、そのslotを未設定状態へ戻します。
  ///
  /// - Parameter position: 取得または更新するslotの位置。
  /// - Precondition: `position`がこのViewの有効範囲に含まれること。
  /// - Complexity: O(1)
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
  /// このViewに有効なslot位置である`0..<count`を返します。
  ///
  /// - Complexity: O(1)
  public var indices: Range<Int> { 0..<count }
}

/// 要素アクセスの為の一時データ構造
///
/// 親配列のstorageを所有せずに参照する2次元Viewです。
/// 親配列の生存中だけ使用でき、Viewを通じた変更は親配列へ反映されます。
/// 連鎖subscriptは`view[y][x]`の順で、`width`が最内軸、`height`が最外軸です。
/// `-Ounchecked`では、記載された事前条件の実行時検査が省略される場合があります。
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

  /// `position`番目の行を参照する非所有Viewを返します。
  ///
  /// 返されたViewからの変更は同じ親配列へ反映されます。Viewは親配列の生存中だけ使用してください。
  /// setterは連鎖要素書き込みのwriteback専用です。同じ位置から返された同一storage・同一shapeの
  /// Viewだけを受け入れ、別のViewの代入は契約違反です。
  ///
  /// - Parameter position: 参照する行の位置。
  /// - Precondition: `position`は`indices`に含まれなければなりません。
  /// - Complexity: O(1)
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
      precondition(0 <= position && position < height)
      let offset = width * position
      precondition(newValue.hasPayload == hasPayload + offset)
      precondition(newValue.payload == payload + offset)
      precondition(newValue.count == width)
    }
  }
}

extension OptionalArray2DView {
  /// 外側の軸に有効な位置である`0..<height`を返します。
  ///
  /// - Complexity: O(1)
  public var indices: Range<Int> { 0..<height }
}

/// 要素アクセスの為の一時データ構造
///
/// 親配列のstorageを所有せずに参照する3次元Viewです。
/// 親配列の生存中だけ使用でき、Viewを通じた変更は親配列へ反映されます。
/// 連鎖subscriptは`view[z][y][x]`の順で、`width`が最内軸、`depth`が最外軸です。
/// `-Ounchecked`では、記載された事前条件の実行時検査が省略される場合があります。
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

  /// `position`番目の2次元面を参照する非所有Viewを返します。
  ///
  /// 返されたViewからの変更は同じ親配列へ反映されます。Viewは親配列の生存中だけ使用してください。
  /// setterは連鎖要素書き込みのwriteback専用です。同じ位置の同一storage・同一shapeのViewだけを
  /// 受け入れ、別のViewの代入は契約違反です。
  ///
  /// - Parameter position: 参照する面の位置。
  /// - Precondition: `position`は`indices`に含まれなければなりません。
  /// - Complexity: O(1)
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
      precondition(0 <= position && position < depth)
      let offset = width * height * position
      precondition(newValue.hasPayload == hasPayload + offset)
      precondition(newValue.payload == payload + offset)
      precondition(newValue.width == width && newValue.height == height)
    }
  }
}

extension OptionalArray3DView {
  /// 外側の軸に有効な位置である`0..<depth`を返します。
  ///
  /// - Complexity: O(1)
  public var indices: Range<Int> { 0..<depth }
}
