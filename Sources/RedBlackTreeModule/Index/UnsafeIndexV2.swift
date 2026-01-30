//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project
//
// Copyright (c) 2024 - 2026 narumij.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.
//
//===----------------------------------------------------------------------===//

import Foundation

// このポインタを保持している構造体は性能面でやはり必要
// 必要ではあるがIndexと言い張るのはキメラ的すぎてよろしくない
// なにか別の名前と概念を割り当てる。
// 本体コレクションのインデックス操作APIは廃止の方向

// 補助的にTrackingTagは提供する

/// 赤黒木のノードへのインデックス
///
/// C++の双方向イテレータに近い内容となっている
@frozen
public struct UnsafeIndexV2<Base>: UnsafeTreeProtocol, UnsafeIndexingProtocol
where Base: ___TreeBase & ___TreeIndex {

  public typealias Tree = UnsafeTreeV2<Base>
  public typealias Pointee = Tree.Pointee

  @usableFromInline
  typealias _PayloadValue = Tree._PayloadValue

  @usableFromInline
  internal var _trackingTag: _RawTrackingTag {
    rawValue.pointee.___tracking_tag
  }
  
  @usableFromInline
  internal var trackingTag: RedBlackTreeTrackingTag {
    .create(rawValue.pointee.___tracking_tag)
  }

  @usableFromInline
  internal var rawValue: _NodePtr {
    didSet {
      guard rawValue != .nullptr,
        !rawValue.___is_garbaged
      else {
        fatalError(.invalidIndex)
      }
    }
  }

  @usableFromInline
  internal var tied: _TiedRawBuffer

  // MARK: -

  @inlinable
  @inline(__always)
  internal init(rawValue: _NodePtr, tie: _TiedRawBuffer) {
    assert(rawValue != .nullptr)
    assert(!rawValue.___is_garbaged)
    self.rawValue = rawValue
    self.tied = tie
  }

  /*
   invalidなポインタでの削除は、だんまりがいいように思う
   */

  // 性能上の問題でCoWに関与できない設計としている
  // CoWに関与できないので、Treeに対する破壊的変更は行わないこと
}

extension UnsafeIndexV2 {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public static func === (lhs: Self, rhs: Self) -> Bool {
    lhs.rawValue == rhs.rawValue
  }
}

extension UnsafeIndexV2: Equatable {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    // _tree比較は、CoWが発生した際に誤判定となり、邪魔となるので、省いている

    // TODO: CoW抑制方針になったので、treeMissmatchが妥当かどうか再検討する

    //    lhs.rawValue == rhs.rawValue
    lhs._trackingTag == rhs._trackingTag
  }
}

#if COMPATIBLE_ATCODER_2025
  // 本当は削除したいが、Collection適応でRange適応が必須なため、仕方なく残している
  extension UnsafeIndexV2: Comparable {

    /// - Complexity: RedBlackTreeSet, RedBlackTreeMap, RedBlackTreeDictionaryの場合O(1)
    ///   RedBlackTreeMultiSet, RedBlackTreeMultMapの場合 O(log *n*)
    ///
    ///   内部動作がユニークな場合、値の比較で解決できますが、
    ///   内部動作がマルチの場合、ノード位置での比較となるので重くなります。
    @inlinable
    @inline(__always)
    public static func < (lhs: Self, rhs: Self) -> Bool {
      // _tree比較は、CoWが発生した際に誤判定となり、邪魔となるので、省いている

      // TODO: CoW抑制方針になったので、treeMissmatchが妥当かどうか再検討する

      guard
        !lhs.rawValue.___is_garbaged,
        !rhs.rawValue.___is_garbaged
      else {
        preconditionFailure(.garbagedIndex)
      }

      switch (lhs.trackingTag, rhs.trackingTag) {
      case (.nullptr, _), (_, .nullptr):
        fatalError(.invalidIndex)
      case (.end, _):
        return false
      case (_, .end):
        return true
      default:
        break
      }

      // rhsよせでもいいかもしれない(2026/1/13)

      return Base.___ptr_comp(lhs.rawValue, rhs.rawValue)
    }
  }
#endif

// Stridableできるが、Range<Index>に標準実装が生えることと、
// その実装が要素アクセスのたびに範囲チェックを行うことを嫌って、Stridableをやめている
extension UnsafeIndexV2 {

  /// - Complexity: RedBlackTreeSet, RedBlackTreeMap, RedBlackTreeDictionaryの場合O(*d*)
  ///   RedBlackTreeMultiSet, RedBlackTreeMultMapの場合 O(log *n* + *d*)
  @inlinable
  //  @inline(__always)
  public func distance(to other: Self) -> Int {
    let other = ___node_ptr(other)
    guard !rawValue.___is_garbaged, !other.___is_garbaged else {
      preconditionFailure(.garbagedIndex)
    }
    return Base.___signed_distance(rawValue, other)
  }

  /// - Complexity: O(*d*)
  @inlinable
  //  @inline(__always)
  public func advanced(by n: Int) -> Self {
    //    return .init(rawValue: Base.advanced(rawValue, by: n), tie: tied)
    if rawValue.___is_offset_null {
      fatalError(.invalidIndex)
    }
    var n = n
    var __ptr_ = rawValue
    while n != 0 {
      if n < 0 {
        // 後ろと区別したくてnullptrにしてたが、一周回るとendなのでendにしてみる
        // TODO: fatalErrorにするか検討
        if __tree_prev_iter(__ptr_).___is_null {
          return .init(rawValue: tied.end_ptr!, tie: tied)
        }
        __ptr_ = __tree_prev_iter(__ptr_)
        n += 1
      } else {
        // TODO: fatalErrorにするか検討
        if __ptr_.___is_end { return .init(rawValue: __ptr_, tie: tied) }
        __ptr_ = __tree_next_iter(__ptr_)
        n -= 1
      }
      if __ptr_ == .nullptr {
        break
      }
    }
    return .init(rawValue: __ptr_, tie: tied)
  }
}

extension UnsafeIndexV2 {

  /// 次のイテレータを返す
  ///
  /// 操作が不正な場合に結果がnilとなる
  @inlinable
  @inline(__always)
  public var next: Self? {
    guard
      !rawValue.___is_next_null,
      tied.isValueAccessAllowed
    else {
      return nil
    }
    var next = self
    next.___unchecked_next()
    return next
  }

  /// 前のイテレータを返す
  ///
  /// 操作が不正な場合に結果がnilとなる
  @inlinable
  @inline(__always)
  public var previous: Self? {
    guard !rawValue.___is_null else {
      fatalError(.invalidIndex)
    }

    let prev = __tree_prev_iter(rawValue)

    guard
      !rawValue.___is_garbaged,
      !prev.___is_null,
      !prev.___is_garbaged,
      tied.isValueAccessAllowed
    else {
      return nil
    }

    var result = self
    result.rawValue = prev
    return result
  }

  @inlinable
  @inline(__always)
  internal mutating func ___unchecked_next() {
    assert(!rawValue.___is_garbaged)
    assert(!rawValue.___is_end)
    rawValue = __tree_next_iter(rawValue)
  }

  @inlinable
  @inline(__always)
  internal mutating func ___unchecked_prev() {
    assert(!rawValue.___is_garbaged)
    assert(!rawValue.___is_slow_begin)
    rawValue = __tree_prev_iter(rawValue)
  }
}

extension UnsafeIndexV2 {

  @inlinable
  @inline(__always)
  public var isStart: Bool {
    rawValue.___is_slow_begin
  }

  @inlinable
  @inline(__always)
  public var isEnd: Bool {
    rawValue.___is_end
  }

  // 利用価値はないが、おまけ。
  @inlinable
  @inline(__always)
  public var isRoot: Bool {
    rawValue.___is_root
  }
}

extension UnsafeIndexV2 {

  /// 現在位置の値を返す
  ///
  /// 無効な場合nilとなる
  @inlinable
  public var pointee: Pointee? {
    guard
      !rawValue.___is_subscript_null,
      !rawValue.___is_garbaged,
      tied.isValueAccessAllowed
    else { return nil }
    return Base.___pointee(rawValue.__value_().pointee)
  }
}

#if DEBUG
  extension UnsafeIndexV2 {
    fileprivate init(
      _unsafe_tree: UnsafeTreeV2<Base>, rawValue: _NodePtr, trackingTag: _RawTrackingTag
    ) {
      self.rawValue = rawValue
      self.tied = _unsafe_tree.tied
    }
  }

  extension UnsafeIndexV2 {
    internal static func unsafe(tree: UnsafeTreeV2<Base>, rawValue: _NodePtr) -> Self {
      .init(_unsafe_tree: tree, rawValue: rawValue, trackingTag: rawValue.pointee.___tracking_tag)
    }
    internal static func unsafe(tree: UnsafeTreeV2<Base>, trackingTag: _RawTrackingTag) -> Self {
      if trackingTag == .nullptr {
        return .init(_unsafe_tree: tree, rawValue: tree.nullptr, trackingTag: .nullptr)
      }
      if trackingTag == .end {
        return .init(_unsafe_tree: tree, rawValue: tree.end, trackingTag: .end)
      }
      return .init(
        _unsafe_tree: tree, rawValue: tree._buffer.header[trackingTag],
        trackingTag: tree._buffer.header[trackingTag].pointee.___tracking_tag)
    }
  }
#endif

#if swift(>=5.5)
  extension UnsafeIndexV2: @unchecked Sendable
  where _PayloadValue: Sendable {}
#endif

// MARK: - Convenience

@inlinable
@inline(__always)
public func + <Base>(lhs: UnsafeIndexV2<Base>, rhs: Int) -> UnsafeIndexV2<Base> {
  lhs.advanced(by: rhs)
}

@inlinable
@inline(__always)
public func - <Base>(lhs: UnsafeIndexV2<Base>, rhs: Int) -> UnsafeIndexV2<Base> {
  lhs.advanced(by: -rhs)
}

@inlinable
@inline(__always)
public func - <Base>(lhs: UnsafeIndexV2<Base>, rhs: UnsafeIndexV2<Base>) -> Int {
  rhs.distance(to: lhs)
}

// MARK: - Optional

#if !COMPATIBLE_ATCODER_2025
  // TODO: 再検討
  // こういうものが必要になるのもどうかとおもうが、
  // かといってIndexの返却をIndex!にするのは標準で前例がみつかってないし、
  // Index?もどうかとおもい、悩むポイント
  extension UnsafeIndexV2 {

    /// オプショナル型を返却します。
    ///
    /// 型を書く負担を軽減するためのものです。
    ///
    /// 例えば以下のように書きたい場合に用います。
    /// ```swift
    /// let st = RedBlackTreeSet<Int>(0..<10)
    /// var it = st.startIndex.some()
    /// while it != st.endIndex {
    ///   it = it?.next
    /// }
    /// ```
    public func some() -> Self? { .some(self) }
  }
#endif

// MARK: Index Resolver

extension UnsafeIndexV2 {

  @inlinable
  @inline(__always)
  package subscript(_raw p: _RawTrackingTag) -> _NodePtr {
    switch p {
    case .nullptr:
      return .nullptr
    case .end:
      return tied.end_ptr!
    default:
      return tied[p] ?? .nullptr
    }
  }

  /// インデックスをポインタに解決する
  ///
  /// 木が同一の場合、インデックスが保持するポインタを返す。
  /// 木が異なる場合、インデックスが保持するノード番号に対応するポインタを返す。
  @inlinable
  @inline(__always)
  internal func ___node_ptr(_ index: UnsafeIndexV2) -> _NodePtr {
    #if true
      // .endが考慮されていないことがきになったが、テストが通ってしまっているので問題が見つかるまで保留
      // endはシングルトン的にしたい気持ちもある
      return tied === index.tied
        ? index.rawValue
    : self[_raw: index._trackingTag]
    #else
      self === index.__tree_ ? index.rawValue : (_header[index.___raw_index])
    #endif
  }
}
