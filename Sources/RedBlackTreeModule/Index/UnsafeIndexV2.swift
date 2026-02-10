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

// sealed化した結果、本当の不安が払拭されてしまい、このままでもべつにいっかという気持ちがわいている

/// 赤黒木用重量インデックス
///
/// C++の双方向イテレータに近い内容となっている
///
/// - note: for文の範囲指定に使える
///
@frozen
public struct UnsafeIndexV2<Base>: UnsafeTreeBinding, UnsafeIndexProtocol_tie
where Base: ___TreeBase & ___TreeIndex {

  public typealias Tree = UnsafeTreeV2<Base>
  public typealias Pointee = Tree.Pointee

  @usableFromInline
  typealias _PayloadValue = Tree._PayloadValue

  @usableFromInline
  package var value: _TrackingTag? {
    sealed.tag.value
  }

  @usableFromInline
  package var tag: _SealedTag {
    sealed.tag
  }

  @usableFromInline
  internal var rawValue: _NodePtr { sealed.pointer! }

  @usableFromInline
  internal var tied: _TiedRawBuffer

  @usableFromInline
  internal var sealed: _SealedPtr

  // MARK: -

  @inlinable @inline(__always)
  internal init(sealed: _SealedPtr, tie: _TiedRawBuffer) {
    self.tied = tie
    self.sealed = sealed
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
    lhs.sealed == rhs.sealed
  }
}

extension UnsafeIndexV2: Equatable {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    // _tree比較は、CoWが発生した際に誤判定となり、邪魔となるので、省いている

    // TODO: CoW抑制方針になったので、treeMissmatchが妥当かどうか再検討する

    lhs.tag == rhs.tag
  }
}

extension UnsafeIndexV2: Comparable {

  /// - Complexity: RedBlackTreeSet, RedBlackTreeMap, RedBlackTreeDictionaryの場合O(1)
  ///   RedBlackTreeMultiSet, RedBlackTreeMultMapの場合 O(log *n*)
  ///
  ///   内部動作がユニークな場合、値の比較で解決できますが、
  ///   内部動作がマルチの場合、ノード位置での比較となるので重くなります。
  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    guard let r = rhs.sealed.pointer,
      let l = rhs.__purified_(lhs).pointer
    else {
      preconditionFailure(.garbagedIndex)
    }
    return Base.___ptr_comp(l, r)
  }
}

// Stridableできるが、Range<Index>に標準実装が生えることと、
// その実装が要素アクセスのたびに範囲チェックを行うことを嫌って、Stridableをやめている
extension UnsafeIndexV2 {

  /// - Complexity: RedBlackTreeSet, RedBlackTreeMap, RedBlackTreeDictionaryの場合O(*d*)
  ///   RedBlackTreeMultiSet, RedBlackTreeMultMapの場合 O(log *n* + *d*)
  @inlinable
  //  @inline(__always)
  public func distance(to other: Self) -> Int {
    guard
      let from = sealed.pointer,
      let to = __purified_(other).pointer
    else {
      preconditionFailure(.garbagedIndex)
    }
    return Base.___signed_distance(from, to)
  }

  /// - Complexity: O(*d*)
  @inlinable
  //  @inline(__always)
  public func advanced(by n: Int) -> Self {
    let adv = sealed.purified.flatMap { ___tree_adv_iter($0.pointer, n) }
    var result = self
    result.sealed = adv.sealed
    return result
  }
}

extension UnsafeIndexV2 {

  /// 次のイテレータを返す
  ///
  /// 操作が不正な場合に結果がnilとなる
  @inlinable
  @inline(__always)
  public var next: Self? {
    let next = sealed.purified.flatMap { ___tree_next_iter($0.pointer) }.sealed
    guard next.isValid, tied.isValueAccessAllowed else { return nil }
    var result = self
    result.sealed = next
    return result
  }

  /// 前のイテレータを返す
  ///
  /// 操作が不正な場合に結果がnilとなる
  @inlinable
  @inline(__always)
  public var previous: Self? {
    let prev = sealed.purified.flatMap { ___tree_prev_iter($0.pointer) }.sealed
    guard prev.isValid, tied.isValueAccessAllowed else { return nil }
    var result = self
    result.sealed = prev
    return result
  }
}

extension UnsafeIndexV2 {

  @inlinable
  @inline(__always)
  public var isEnd: Bool {
    sealed.___is_end ?? false
  }
}

extension UnsafeIndexV2 {

  /// 現在位置の値を返す
  ///
  /// 無効な場合nilとなる
  @inlinable
  public var pointee: Pointee? {
    guard
      sealed.isValid,
      sealed.___is_end == false,
      tied.isValueAccessAllowed
    else {
      return nil
    }
    return Base.__element_(sealed.__value_()!.pointee)
  }
}

#if DEBUG
  extension UnsafeIndexV2 {
    fileprivate init(
      _unsafe_tree: UnsafeTreeV2<Base>, rawValue: _NodePtr, trackingTag: _TrackingTag
    ) {
      self.tied = _unsafe_tree.tied
      self.sealed = rawValue.sealed
    }
  }

  extension UnsafeIndexV2 {

    internal static func unsafe(tree: UnsafeTreeV2<Base>, rawValue: _NodePtr) -> Self {
      .init(_unsafe_tree: tree, rawValue: rawValue, trackingTag: rawValue.pointee.___tracking_tag)
    }

    internal static func unsafe(tree: UnsafeTreeV2<Base>, rawTag: _TrackingTag) -> Self {
      if rawTag == .nullptr {
        return .init(_unsafe_tree: tree, rawValue: tree.nullptr, trackingTag: .nullptr)
      }
      if rawTag == .end {
        return .init(_unsafe_tree: tree, rawValue: tree.end, trackingTag: .end)
      }
      return .init(
        _unsafe_tree: tree,
        rawValue: tree._buffer.header[rawTag],
        trackingTag: tree._buffer.header[rawTag].pointee.___tracking_tag)
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

// MARK: Index Resolver

extension UnsafeIndexV2 {

  @inlinable
  @inline(__always)
  internal func __purified_(_ index: UnsafeIndexV2) -> _SealedPtr {
    tied === index.tied
      ? index.sealed.purified
      : tied.__retrieve_(index.sealed.purified.tag).purified
  }
}

extension UnsafeIndexV2 {
  @inlinable
  public var isValid: Bool {
    sealed.purified.isValid
  }
}

extension UnsafeIndexV2: CustomStringConvertible {
  public var description: String {
    switch sealed {
    case .success(let t):
      "UnsafeIndexV2<\(t)>"
    case .failure(let e):
      "UnsafeIndexV2<\(e)>"
    }
  }
}

extension UnsafeIndexV2: CustomDebugStringConvertible {
  public var debugDescription: String { description }
}
