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

// TODO: Sealedに移行

/// 赤黒木のノードへのインデックス
///
/// C++の双方向イテレータに近い内容となっている
@frozen
public struct UnsafeIndexV2<Base>: UnsafeTreeBinding, UnsafeIndexingProtocol
where Base: ___TreeBase & ___TreeIndex {

  public typealias Tree = UnsafeTreeV2<Base>
  public typealias Pointee = Tree.Pointee

  @usableFromInline
  typealias _PayloadValue = Tree._PayloadValue

  @usableFromInline
  internal var _rawTag: _RawTrackingTag {
    (try? sealed.map(\.tag).map(\._rawTag).get()) ?? .nullptr
  }

  @usableFromInline
  internal var trackingTag: TaggedSeal {
    try? sealed.map(\.tag).get()
  }

  @usableFromInline
  internal var rawValue: _NodePtr { sealed.pointer! }

  @usableFromInline
  internal var tied: _TiedRawBuffer

  @usableFromInline
  internal var sealed: _SealedPtr

  // MARK: -

  @inlinable
  @inline(__always)
  internal init(rawValue: _NodePtr, tie: _TiedRawBuffer) {
    assert(rawValue != .nullptr)
    assert(!rawValue.___is_garbaged)
    self.tied = tie
    self.sealed = rawValue.sealed
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

    lhs.trackingTag == rhs.trackingTag
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
      guard let r = rhs.sealed.pointer,
        let l = rhs.resolve(lhs.trackingTag).pointer
      else {
        preconditionFailure(.garbagedIndex)
      }
      return Base.___ptr_comp(l, r)
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
    let other = _remap_to_safe_(other)
    guard
      let from = sealed.pointer,
      let to = other.pointer
    else {
      preconditionFailure(.garbagedIndex)
    }
    return Base.___signed_distance(from, to)
  }

  /// - Complexity: O(*d*)
  @inlinable
  //  @inline(__always)
  public func advanced(by n: Int) -> Self {
    let adv = sealed.purified.flatMap { ___tree_adv_iter($0.pointer, n) }.seal
    var result = self
    result.sealed = adv
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
    let next = sealed.purified.flatMap { ___tree_next_iter($0.pointer) }.seal
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
    let prev = sealed.purified.flatMap { ___tree_prev_iter($0.pointer) }.seal
    guard prev.isValid, tied.isValueAccessAllowed else { return nil }
    var result = self
    result.sealed = prev
    return result
  }
}

extension UnsafeIndexV2 {

  @inlinable
  @inline(__always)
  public var isStart: Bool {
    tied.begin_ptr.flatMap { sealed.__is_equals($0.pointee) } ?? false
  }

  @inlinable
  @inline(__always)
  public var isEnd: Bool {
    sealed.___is_end ?? false
  }

  // 利用価値はないが、おまけ。
  @inlinable
  @inline(__always)
  public var isRoot: Bool {
    sealed.___is_root ?? false
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
      _unsafe_tree: UnsafeTreeV2<Base>, rawValue: _NodePtr, trackingTag: _RawTrackingTag
    ) {
      self.tied = _unsafe_tree.tied
      self.sealed = rawValue.sealed
    }
  }

  extension UnsafeIndexV2 {

    internal static func unsafe(tree: UnsafeTreeV2<Base>, rawValue: _NodePtr) -> Self {
      .init(_unsafe_tree: tree, rawValue: rawValue, trackingTag: rawValue.pointee.___tracking_tag)
    }

    internal static func unsafe(tree: UnsafeTreeV2<Base>, rawTag: _RawTrackingTag) -> Self {
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
  package func resolve(raw: _RawTrackingTag, seal: UnsafeNode.Seal) -> _SealedPtr {
    switch raw {
    case .nullptr:
      return .failure(.null)
    case .end:
      return tied.end_ptr.map { $0.sealed } ?? .failure(.null)
    default:
      guard raw < tied.capacity else {
        return .failure(.unknown)
      }
      return tied[raw].map { .success(.uncheckedSeal($0, seal)) } ?? .failure(.null)
    }
  }

  @inlinable
  @inline(__always)
  package func resolve(_ tag: TaggedSeal) -> _SealedPtr {
    tag.map { resolve(raw: $0.rawValue.raw, seal: $0.rawValue.seal) } ?? .failure(.null)
  }

  @inlinable
  @inline(__always)
  internal func _remap_to_safe_(_ index: UnsafeIndexV2) -> _SealedPtr {
    tied === index.tied ? index.sealed : resolve(index.trackingTag)
  }
}
