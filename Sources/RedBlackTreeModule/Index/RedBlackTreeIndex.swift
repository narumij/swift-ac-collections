// Copyright 2024 narumij
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
// Copyright © 2003-2024 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

import Foundation

/// 赤黒木のノードへのインデックス
///
/// C++の双方向イテレータに近い内容となっている
@frozen
public struct RedBlackTreeIndex<Base> where Base: ___TreeBase {
  
  public typealias Tree = ___Tree<Base>
  public typealias _Value = Tree._Value

  @usableFromInline
  let __tree_: Tree

  @usableFromInline
  var rawValue: Int

  // MARK: -

  @inlinable
  @inline(__always)
  internal init(tree: Tree, rawValue: _NodePtr) {
    assert(rawValue != .nullptr)
    self.__tree_ = tree
    self.rawValue = rawValue
  }

  /*
   invalidなポインタでの削除は、だんまりがいいように思う
   */

  // 性能上の問題でCoWに関与できない設計としている
  // CoWに関与できないので、Treeに対する破壊的変更は行わないこと
}

extension RedBlackTreeIndex: Comparable {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    // _tree比較は、CoWが発生した際に誤判定となり、邪魔となるので、省いている
    lhs.rawValue == rhs.rawValue
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

    let __tree_ = lhs.__tree_

    guard !__tree_.___is_garbaged(lhs.rawValue),
      !__tree_.___is_garbaged(rhs.rawValue)
    else {
      preconditionFailure(.garbagedIndex)
    }

    return lhs.__tree_.___ptr_comp(lhs.rawValue, rhs.rawValue)
  }
}

// Stridableできるが、Range<Index>に標準実装が生えることと、
// その実装が要素アクセスのたびに範囲チェックを行うことを嫌って、Stridableをやめている
extension RedBlackTreeIndex {

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

extension RedBlackTreeIndex {
  
  // TODO: ここら辺を使いこなそうとすると、型を書く必要が生じて使いにくい。APIを再度検討すること

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
  mutating func ___unchecked_next() {
    assert(!__tree_.___is_garbaged(rawValue))
    assert(!__tree_.___is_end(rawValue))
    rawValue = __tree_.__tree_next_iter(rawValue)
  }

  @inlinable
  @inline(__always)
  mutating func ___unchecked_prev() {
    assert(!__tree_.___is_garbaged(rawValue))
    assert(!__tree_.___is_begin(rawValue))
    rawValue = __tree_.__tree_prev_iter(rawValue)
  }
}

extension RedBlackTreeIndex {

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

extension RedBlackTreeIndex {

  /// 現在位置の値を返す
  ///
  /// 無効な場合nilとなる
  @inlinable
  public var pointee: _Value? {
    @inline(__always) _read {
      yield __tree_.___is_subscript_null(rawValue) ? nil : ___pointee
    }
  }
}

extension RedBlackTreeIndex {

  @inlinable
  @inline(__always)
  var ___key: Base._Key {
    Base.__key(___pointee)
  }

  @inlinable
  var ___pointee: _Value {
    @inline(__always) _read {
      yield __tree_[rawValue]
    }
  }
}

#if DEBUG
  extension RedBlackTreeIndex {
    fileprivate init(_unsafe_tree: ___Tree<Base>, rawValue: _NodePtr) {
      self.__tree_ = _unsafe_tree
      self.rawValue = rawValue
    }
  }

  extension RedBlackTreeIndex {
    static func unsafe(tree: ___Tree<Base>, rawValue: _NodePtr) -> Self {
      .init(_unsafe_tree: tree, rawValue: rawValue)
    }
  }
#endif

#if swift(>=5.5)
// TODO: 競プロ用としてはSendableでいいが、一般用としてはSendableが適切かどうか検証が必要
  extension RedBlackTreeIndex: @unchecked Sendable
  where _Value: Sendable {}
#endif

extension RedBlackTreeIndex {
  @inlinable
  @inline(__always)
  var ___indices: RedBlackTreeIndices<Base> {
    __tree_.makeIndices(start: __tree_.__begin_node_, end: __tree_.__end_node())
  }
}

// MARK: - Range Expression

@inlinable
@inline(__always)
public func ..< <Base>(lhs: RedBlackTreeIndex<Base>, rhs: RedBlackTreeIndex<Base>) -> ___Tree<Base>.Indices {
  let indices = lhs.___indices
  let bounds = (lhs..<rhs).relative(to: indices)
  return indices[bounds.lowerBound..<bounds.upperBound]
}

@inlinable
@inline(__always)
public func ... <Base>(lhs: RedBlackTreeIndex<Base>, rhs: RedBlackTreeIndex<Base>) -> ___Tree<Base>.Indices {
  let indices = lhs.___indices
  let bounds = (lhs...rhs).relative(to: indices)
  return indices[bounds.lowerBound..<bounds.upperBound]
}

@inlinable
@inline(__always)
public prefix func ..< <Base>(rhs: RedBlackTreeIndex<Base>) -> ___Tree<Base>.Indices {
  let indices = rhs.___indices
  let bounds = (..<rhs).relative(to: indices)
  return indices[bounds.lowerBound..<bounds.upperBound]
}

@inlinable
@inline(__always)
public prefix func ... <Base>(rhs: RedBlackTreeIndex<Base>) -> ___Tree<Base>.Indices {
  let indices = rhs.___indices
  let bounds = (...rhs).relative(to: indices)
  return indices[bounds.lowerBound..<bounds.upperBound]
}

@inlinable
@inline(__always)
public postfix func ... <Base>(lhs: RedBlackTreeIndex<Base>) -> ___Tree<Base>.Indices {
  let indices = lhs.___indices
  let bounds = (lhs...).relative(to: indices)
  return indices[bounds.lowerBound..<bounds.upperBound]
}

// MARK: - Convenience

@inlinable
@inline(__always)
public func + <Base>(lhs: RedBlackTreeIndex<Base>, rhs: Int) -> RedBlackTreeIndex<Base> {
  lhs.advanced(by: rhs)
}

@inlinable
@inline(__always)
public func - <Base>(lhs: RedBlackTreeIndex<Base>, rhs: Int) -> RedBlackTreeIndex<Base> {
  lhs.advanced(by: -rhs)
}

@inlinable
@inline(__always)
public func - <Base>(lhs: RedBlackTreeIndex<Base>, rhs: RedBlackTreeIndex<Base>) -> Int {
  rhs.distance(to: lhs)
}

extension RedBlackTreeIndex {
  
  /// Indexをたどり続ける場合に型を書く負担を軽減するためのものです。
  ///
  /// 例えば以下のように書きたい場合に用います。
  /// ```swift
  /// let st = RedBlackTreeSet<Int>(0..<10)
  /// var it = st.startIndex.some()
  /// while it != st.endIndex {
  ///   it = it?.next
  /// }
  /// ```
  ///
  /// - 代替コード: AtCoder2025には未搭載なので、利用する場合、提出コードに以下を追加する必要があります。
  /// ```swift
  /// extension ___Tree.___Iterator {
  ///   func some() -> Self? { .some(self) }
  /// }
  /// ```
  @available(
    *, deprecated,
    message: "AtCoder2025には未搭載です。もし必要な場合は、代替コードを利用してください。"
  )
  func some() -> Self? { .some(self) }
}

/*
代替コード
```swift
extension ___Tree.___Iterator {
  func some() -> Self? { .some(self) }
}
```
 */
