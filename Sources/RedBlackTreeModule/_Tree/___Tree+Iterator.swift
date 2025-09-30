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

extension ___Tree {

  /// 赤黒木のノードへのイテレータ
  @frozen
  public struct ___Iterator {

    public typealias _Value = Tree._Value

    @usableFromInline
    let __tree_: ___Tree

    @usableFromInline
    var rawValue: Int

    // MARK: -

    @inlinable
    @inline(__always)
    internal init(tree: ___Tree, rawValue: _NodePtr) {
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
}

extension ___Tree.___Iterator: Comparable {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    // _tree比較は、CoWが発生した際に誤判定となり、邪魔となるので、省いている
    lhs.rawValue == rhs.rawValue
  }

  /// - Complexity: RedBlackTreeSet, RedBlackTreeDictionaryの場合O(1)
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
          !__tree_.___is_garbaged(rhs.rawValue) else {
      preconditionFailure(.garbagedIndex)
    }

    return lhs.__tree_.___ptr_comp(lhs.rawValue, rhs.rawValue)
  }
}

// Stridableできるが、Range<Index>に標準実装が生えることと、
// その実装が要素アクセスのたびに範囲チェックを行うことを嫌って、Stridableをやめている
extension ___Tree.___Iterator {

  @inlinable
  //  @inline(__always)
  public func distance(to other: Self) -> Int {
    guard !__tree_.___is_garbaged(rawValue),
          !__tree_.___is_garbaged(other.rawValue) else {
      preconditionFailure(.garbagedIndex)
    }
    return __tree_.___signed_distance(rawValue, other.rawValue)
  }

  @inlinable
  //  @inline(__always)
  public func advanced(by n: Int) -> Self {
    return .init(tree: __tree_, rawValue: __tree_.___tree_adv_iter(rawValue, by: n))
  }
}

extension ___Tree.___Iterator {

  @inlinable
  @inline(__always)
  public var next: Self? {
    guard !__tree_.___is_next_null(rawValue) else {
      return nil
    }
    var next = self
    next.___next()
    return next
  }

  @inlinable
  @inline(__always)
  public var previous: Self? {
    guard !__tree_.___is_prev_null(rawValue) else {
      return nil
    }
    var prev = self
    prev.___prev()
    return prev
  }

  @inlinable
  @inline(__always)
  mutating func ___next() {
    assert(!__tree_.___is_garbaged(rawValue))
    assert(!__tree_.___is_end(rawValue))
    rawValue = __tree_.__tree_next_iter(rawValue)
  }

  @inlinable
  @inline(__always)
  mutating func ___prev() {
    assert(!__tree_.___is_garbaged(rawValue))
    assert(!__tree_.___is_begin(rawValue))
    rawValue = __tree_.__tree_prev_iter(rawValue)
  }
}

extension ___Tree.___Iterator {

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

extension ___Tree.___Iterator {

  @inlinable
  public var pointee: _Value? {
    @inline(__always) _read {
      yield __tree_.___is_subscript_null(rawValue) ? nil : ___pointee
    }
  }
}

extension ___Tree.___Iterator {

  @inlinable
  @inline(__always)
  var ___key: VC._Key {
    __tree_.__key(___pointee)
  }

  @inlinable
  var ___pointee: _Value {
    @inline(__always) _read {
      yield __tree_[rawValue]
    }
  }
}

#if DEBUG
  extension ___Tree.___Iterator {
    fileprivate init(_unsafe_tree: ___Tree<VC>, rawValue: _NodePtr) {
      self.__tree_ = _unsafe_tree
      self.rawValue = rawValue
    }
  }

  extension ___Tree.___Iterator {
    static func unsafe(tree: ___Tree<VC>, rawValue: _NodePtr) -> Self {
      .init(_unsafe_tree: tree, rawValue: rawValue)
    }
  }
#endif

#if false
  @inlinable
  func _description(_ p: _NodePtr) -> String {
    switch p {
    case .nullptr: ".nullptr"
    case .end: ".end"
    case .under: ".under"
    case .over: ".over"
    default: "\(p)"
    }
  }
#endif

@inlinable
@inline(__always)
public func ..< <VC>(
  lhs: ___Tree<VC>.Index,
  rhs: ___Tree<VC>.Index
) -> ___Tree<VC>.Indices {
  lhs.__tree_.makeIndices(start: lhs.rawValue, end: rhs.rawValue)
}

@inlinable
@inline(__always)
public func + <VC>(
  lhs: ___Tree<VC>.Index,
  rhs: Int
) -> ___Tree<VC>.Index {
  lhs.advanced(by: rhs)
}

@inlinable
@inline(__always)
public func - <VC>(
  lhs: ___Tree<VC>.Index,
  rhs: Int
) -> ___Tree<VC>.Index {
  lhs.advanced(by: -rhs)
}

@inlinable
@inline(__always)
public func - <VC>(
  lhs: ___Tree<VC>.Index,
  rhs: ___Tree<VC>.Index
) -> Int {
  rhs.distance(to: lhs)
}

#if swift(>=5.5)
  extension ___Tree.___Iterator: @unchecked Sendable
  where _Value: Sendable {}
#endif
