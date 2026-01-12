// Copyright 2024-2026 narumij
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2025 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

import Foundation

/// 赤黒木のノードへのインデックス
///
/// C++の双方向イテレータに近い内容となっている
@frozen
public struct UnsafeIndexV2<Base> where Base: ___TreeBase & ___TreeIndex {

  public typealias Tree = UnsafeTreeV2<Base>
  public typealias Pointee = Tree.Pointee
  public typealias _NodePtr = Tree._NodePtr

  @usableFromInline
  typealias _Value = Tree._Value

  @usableFromInline
  internal let __tree_: Tree

  @usableFromInline
  internal var ___node_id_: Int

  @usableFromInline
  internal var rawValue: _NodePtr

  // MARK: -

  @inlinable
  @inline(__always)
  internal init(tree: Tree, rawValue: _NodePtr) {
    assert(rawValue != tree.nullptr)
    self.__tree_ = tree
    self.rawValue = rawValue
    self.___node_id_ = rawValue.pointee.___node_id_
  }

  /*
   invalidなポインタでの削除は、だんまりがいいように思う
   */

  // 性能上の問題でCoWに関与できない設計としている
  // CoWに関与できないので、Treeに対する破壊的変更は行わないこと
}

extension UnsafeTreeV2 where Base: ___TreeIndex {

  @inlinable
  func equiv(_ l: UnsafeIndexV2<Base>, _ r: UnsafeIndexV2<Base>) -> Bool {
//    let lhs = ___node_ptr(l)
//    let rhs = ___node_ptr(r)
//    guard !___is_garbaged(lhs),
//      !___is_garbaged(rhs)
//    else {
//      preconditionFailure(.garbagedIndex)
//    }
//    return ___ptr_comp(lhs, rhs)
    return l.___node_id_ == r.___node_id_
  }
  
  @inlinable
  func lessThan(_ l: UnsafeIndexV2<Base>, _ r: UnsafeIndexV2<Base>) -> Bool {
    let lhs = ___node_ptr(l)
    let rhs = ___node_ptr(r)
    guard !___is_garbaged(lhs),
      !___is_garbaged(rhs)
    else {
      preconditionFailure(.garbagedIndex)
    }
    return ___ptr_comp(lhs, rhs)
  }
}

extension UnsafeIndexV2: Comparable {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    // _tree比較は、CoWが発生した際に誤判定となり、邪魔となるので、省いている
    //    lhs.rawValue == rhs.rawValue
    lhs.___node_id_ == rhs.___node_id_
  }

  /// - Complexity: RedBlackTreeSet, RedBlackTreeMap, RedBlackTreeDictionaryの場合O(1)
  ///   RedBlackTreeMultiSet, RedBlackTreeMultMapの場合 O(log *n*)
  ///
  ///   内部動作がユニークな場合、値の比較で解決できますが、
  ///   内部動作がマルチの場合、ノード位置での比較となるので重くなります。
  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    // _tree比較は、CoWが発生した際に誤判定となり、邪魔となるので、省いている
    return lhs.__tree_.lessThan(lhs, rhs)
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
    guard !__tree_.___is_garbaged(rawValue),
      !__tree_.___is_garbaged(other.rawValue)
    else {
      preconditionFailure(.garbagedIndex)
    }
    return __tree_.___signed_distance(rawValue, other.rawValue)
  }

  /// - Complexity: O(1)
  @inlinable
  //  @inline(__always)
  public func advanced(by n: Int) -> Self {
    return .init(tree: __tree_, rawValue: __tree_.___tree_adv_iter(rawValue, by: n))
  }
}

extension UnsafeIndexV2 {

  /// 次のイテレータを返す
  ///
  /// 操作が不正な場合に結果がnilとなる
  @inlinable
  @inline(__always)
  public var next: Self? {
    guard !__tree_.___is_next_null(rawValue) else {
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
    guard !__tree_.___is_prev_null(rawValue) else {
      return nil
    }
    var prev = self
    prev.___unchecked_prev()
    return prev
  }

  @inlinable
  @inline(__always)
  internal mutating func ___unchecked_next() {
    assert(!__tree_.___is_garbaged(rawValue))
    assert(!__tree_.___is_end(rawValue))
    rawValue = __tree_.__tree_next_iter(rawValue)
  }

  @inlinable
  @inline(__always)
  internal mutating func ___unchecked_prev() {
    assert(!__tree_.___is_garbaged(rawValue))
    assert(!__tree_.___is_begin(rawValue))
    rawValue = __tree_.__tree_prev_iter(rawValue)
  }
}

extension UnsafeIndexV2 {

  @inlinable
  @inline(__always)
  public var isStart: Bool {
    __tree_.___is_begin(rawValue)
  }

  @inlinable
  @inline(__always)
  public var isEnd: Bool {
    __tree_.___is_end(rawValue)
  }

  // 利用価値はないが、おまけ。
  @inlinable
  @inline(__always)
  public var isRoot: Bool {
    __tree_.___is_root(rawValue)
  }
}

extension UnsafeIndexV2 {

  /// 現在位置の値を返す
  ///
  /// 無効な場合nilとなる
  @inlinable
  public var pointee: Pointee? {
    guard
      !__tree_.___is_subscript_null(rawValue(__tree_)),
      !__tree_.___is_garbaged(rawValue(__tree_))
    else { return nil }
    return Base.___pointee(UnsafePair<_Value>.valuePointer(rawValue(__tree_))!.pointee)
  }
}

#if DEBUG
  extension UnsafeIndexV2 {
    fileprivate init(_unsafe_tree: UnsafeTreeV2<Base>, rawValue: _NodePtr, node_id: Int) {
      self.__tree_ = _unsafe_tree
      self.rawValue = rawValue
      self.___node_id_ = node_id
    }
  }

  extension UnsafeIndexV2 {
    internal static func unsafe(tree: UnsafeTreeV2<Base>, rawValue: _NodePtr) -> Self {
      .init(_unsafe_tree: tree, rawValue: rawValue, node_id: rawValue.pointee.___node_id_)
    }
    internal static func unsafe(tree: UnsafeTreeV2<Base>, rawValue: Int) -> Self {
      if rawValue == .nullptr {
        return .init(_unsafe_tree: tree, rawValue: tree.nullptr, node_id: .nullptr)
      }
      if rawValue == .end {
        return .init(_unsafe_tree: tree, rawValue: tree.end, node_id: .end)
      }
      return .init(
        _unsafe_tree: tree, rawValue: tree._buffer.header[rawValue],
        node_id: tree._buffer.header[rawValue].pointee.___node_id_)
    }
  }
#endif

#if swift(>=5.5)
  extension UnsafeIndexV2: @unchecked Sendable
  where _Value: Sendable {}
#endif

extension UnsafeIndexV2 {
  @inlinable
  @inline(__always)
  internal var ___indices: UnsafeIndicesV2<Base> {
    .init(tree: __tree_, start: __tree_.__begin_node_, end: __tree_.__end_node)
  }
}

// MARK: - Range Expression

@inlinable
@inline(__always)
public func ..< <Base>(lhs: UnsafeIndexV2<Base>, rhs: UnsafeIndexV2<Base>)
  -> UnsafeTreeV2<Base>.Indices
{
  let indices = lhs.___indices
  let bounds = (lhs..<rhs).relative(to: indices)
  return indices[bounds.lowerBound..<bounds.upperBound]
}

#if !COMPATIBLE_ATCODER_2025
  @inlinable
  @inline(__always)
  public func ... <Base>(lhs: UnsafeIndexV2<Base>, rhs: UnsafeIndexV2<Base>)
    -> UnsafeTreeV2<Base>.Indices
  {
    let indices = lhs.___indices
    let bounds = (lhs...rhs).relative(to: indices)
    return indices[bounds.lowerBound..<bounds.upperBound]
  }

  @inlinable
  @inline(__always)
  public prefix func ..< <Base>(rhs: UnsafeIndexV2<Base>) -> UnsafeTreeV2<Base>.Indices {
    let indices = rhs.___indices
    let bounds = (..<rhs).relative(to: indices)
    return indices[bounds.lowerBound..<bounds.upperBound]
  }

  @inlinable
  @inline(__always)
  public prefix func ... <Base>(rhs: UnsafeIndexV2<Base>) -> UnsafeTreeV2<Base>.Indices {
    let indices = rhs.___indices
    let bounds = (...rhs).relative(to: indices)
    return indices[bounds.lowerBound..<bounds.upperBound]
  }

  @inlinable
  @inline(__always)
  public postfix func ... <Base>(lhs: UnsafeIndexV2<Base>) -> UnsafeTreeV2<Base>.Indices {
    let indices = lhs.___indices
    let bounds = (lhs...).relative(to: indices)
    return indices[bounds.lowerBound..<bounds.upperBound]
  }
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

extension UnsafeIndexV2 {

  @inlinable
  @inline(__always)
  package func rawValue(_ tree: Tree) -> _NodePtr {
    tree.___node_ptr(self)
  }

  @inlinable
  @inline(__always)
  package var _rawValue: Int {
    rawValue.pointee.___node_id_
  }
}
