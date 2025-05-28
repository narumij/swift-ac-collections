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

extension ___RedBlackTree.___Tree {

  /// 赤黒木のノードへのポインタ
  ///
  /// 各データ構造で代表的なインデックスとして用いられる
  ///
  /// 各種プロトコルや範囲検査に対応するため、単独で様々な事ができる
  ///
  /// 他に軽量なポインタもあります。
  @frozen
  public struct Pointer {

    public typealias Element = Tree.Element

    @usableFromInline
    typealias _Tree = Tree

    @usableFromInline
    let _tree: Tree

//    @usableFromInline
    public
    var rawValue: Int

    @usableFromInline
    class Remnant {
      @usableFromInline
      var rawValue: Int?
      @usableFromInline
      var prev: Int?
      @usableFromInline
      var next: Int?
      @inlinable @inline(__always)
      init() {}
    }

    /// 幽霊化した際の記憶の残滓
    @usableFromInline
    var remnant: Remnant = .init()

    // MARK: -

    @inlinable
    @inline(__always)
    public init(__tree: Tree, rawValue: _NodePtr) {
      guard rawValue != .nullptr else {
        preconditionFailure("_NodePtr is nullptr")
      }
      self._tree = __tree
      self.rawValue = rawValue
    }

    /*
     invalidなポインタでの削除は、だんまりがいいように思う
     */
    
    // 性能上の問題でCoWに関与できない設計としている
    // CoWに関与できないので、Treeに対する破壊的変更は行わないこと
  }
}

// underやoverは幽霊化の補助としての利用に限定している
// このため、RangeやStridableに関連しないところでは、underやoverは使わないし対応しない

extension ___RedBlackTree.___Tree.Pointer: Comparable {
  
  // ポインタを利用して削除した場合に、Range<Index>の厳しい検査に耐えるための準備
  @usableFromInline
  func phantomMark() {
    remnant.rawValue = rawValue
    
    // Treeが空の場合、削除自体が発生しないので、考慮していない
    
    if ___is_under_or_over(rawValue) {
      remnant.prev = rawValue
      remnant.next = rawValue
      return
    }
    
    // ユーザーの操作でポインタ不正が発生するようであればguardにする必要があるが、
    // 今のところ思い当たらないので様子見
    assert(rawValue == .end || _tree.___is_valid(rawValue))
    
    if rawValue == .end {
      remnant.prev = _tree.__tree_prev_iter(rawValue)
      remnant.next = .over
      return
    }
    
    if rawValue == _tree.begin() {
      remnant.prev = .under
      remnant.next = _tree.__tree_next_iter(rawValue)
      return
    }
    
    remnant.prev = _tree.__tree_prev_iter(rawValue)
    remnant.next = _tree.__tree_next_iter(rawValue)
  }

  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    // _tree比較は、CoWが発生した際に誤判定となり、邪魔となるので、省いている
    return lhs.rawValue == rhs.rawValue
  }

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    // _tree比較は、CoWが発生した際に誤判定となり、邪魔となるので、省いている

    // 通常の特殊null比較が成立する場合 <
    if let underOver = lessThanContainsUnderOrOver(lhs.rawValue, rhs.rawValue) {
      return underOver
    }
    
    // 幽霊判定はRange<Index>のシーケンス動作の為のもの
    // それ以外のユースケースでバグが生じても仕様とする
    
    // そもそもSwift標準が削除済みのインデックスに対して検査をスキップしてくれたらいいが
    // それを実施するとパフォーマンスが落ちる懸念があり責任がとれないのでそういうPRはしない

    // 左が幽霊化しているケース
    if lhs.remnant.rawValue == lhs.rawValue,
      let next = lhs.remnant.next,
      let prev = lhs.remnant.prev
    {
      // 右側と双方幽霊化してるケースは未実装
      guard rhs.remnant.rawValue != rhs.rawValue else {
        fatalError(.invalidIndex)
      }

      // 左幽霊の右隣と等しい場合<
      if next == rhs.rawValue {
        return true
      }

      // 左幽霊の右隣と特殊null比較が成立する場合<
      if let result = lessThanContainsUnderOrOver(next, rhs.rawValue) {
        return result
      }

      // 左幽霊の右隣が無効化してない場合、木の比較をする
      if next == .end || rhs._tree.___is_valid(next) {
        return rhs._tree.___ptr_comp(next, rhs.rawValue)
      }

      // 左幽霊の左隣と一致せず、特殊null比較が成立する場合<
      if prev != rhs.rawValue, let _ = lessThanContainsUnderOrOver(prev, rhs.rawValue) {
        return true
      }

      // 左幽霊の左隣も無効な場合、木の比較ができないので不正操作
      guard prev == .end || rhs._tree.___is_valid(prev) else {
        // 不正なポインタを木の比較に送ると無限ループとなるので注意
        fatalError(.invalidIndex)
      }

      // 左幽霊の左隣と一致しない場合、木の比較をする
      return prev != rhs.rawValue && rhs._tree.___ptr_comp(prev, rhs.rawValue)
    }

    // 右が幽霊化しているケース
    if rhs.remnant.rawValue == rhs.rawValue,
      let prev = rhs.remnant.prev,
      let next = rhs.remnant.next
    {
      // 右幽霊の左隣と等しい場合<
      if lhs.rawValue == prev {
        return true
      }

      // 右幽霊の左隣と特殊null比較が成立する場合<
      if let result = lessThanContainsUnderOrOver(lhs.rawValue, prev) {
        return result
      }

      // 右幽霊の左隣が無効化してない場合、木の比較をする
      if prev == .end || lhs._tree.___is_valid(prev) {
        return lhs._tree.___ptr_comp(lhs.rawValue, prev)
      }

      // 右幽霊の右隣と一致せず、特殊null比較が成立する場合<
      if next != lhs.rawValue,
        let _ = lessThanContainsUnderOrOver(lhs.rawValue, next)
      {
        return true
      }

      // 右幽霊の右隣も無効な場合、木の比較ができないので不正操作
      guard next == .end || lhs._tree.___is_valid(next) else {
        // 不正なポインタを木の比較に送ると無限ループとなるので注意
        fatalError(.invalidIndex)
      }

      // 右幽霊の右隣と一致しない場合、木の比較をする
      return next != rhs.rawValue && lhs._tree.___ptr_comp(lhs.rawValue, next)
    }

    assert(lhs.___isValid)
    assert(rhs.___isValid)

    guard lhs.rawValue == .end || lhs._tree.___is_valid(lhs.rawValue),
      rhs.rawValue == .end || rhs._tree.___is_valid(rhs.rawValue)
    else {
      // 不正なポインタを木の比較に送ると無限ループとなるので注意
      fatalError(.invalidIndex)
    }

    // 通常の木の比較を行う
    return lhs._tree.___ptr_comp(lhs.rawValue, rhs.rawValue)
  }
}

extension ___RedBlackTree.___Tree.Pointer: Strideable {

  @inlinable
  @inline(__always)
  public func distance(to other: Self) -> Int {
    _tree.___signed_distance(rawValue, other.rawValue)
  }

  /// 特殊なnullptr
  /// 範囲の下限を下回っていることを表す
  @inlinable
  @inline(__always)
  var under: Self {
    .init(__tree: _tree, rawValue: .under)
  }

  /// 特殊なnullptr
  /// 範囲の上限を上回っていることを表す
  @inlinable
  @inline(__always)
  var over: Self {
    .init(__tree: _tree, rawValue: .over)
  }

  /// 範囲の下限を超えて操作されたポインタ
  @inlinable
  @inline(__always)
  public var isUnder: Bool {
    rawValue == .under
  }

  /// 範囲の上限を超えて操作されたポインタ
  @inlinable
  @inline(__always)
  public var isOver: Bool {
    rawValue == .over
  }

  /// 削除操作で無効になりつつ、がんばって（？）隣を記録し、比較操作にまだ耐えているポインタ
  @inlinable
  @inline(__always)
  public var isPhantom: Bool {
    remnant.rawValue == rawValue
  }

  @inlinable
  @inline(__always)
  public func advanced(by n: Int) -> Self {
    if n < 0, remnant.rawValue == rawValue, let prev = remnant.prev {
      return .init(__tree: _tree, rawValue: prev).advanced(by: n + 1)
    }
    if n > 0, remnant.rawValue == rawValue, let next = remnant.next {
      return .init(__tree: _tree, rawValue: next).advanced(by: n - 1)
    }
    guard
      ___is_under_or_over(rawValue) || _tree.___is_valid_index(rawValue)
    else {
      fatalError(.invalidIndex)
    }
    var distance = n
    var result: Self = .init(__tree: _tree, rawValue: rawValue)
    while distance != 0 {
      if 0 < distance {
        result = result.next ?? over
        distance -= 1
      } else {
        result = result.previous ?? under
        distance += 1
      }
    }
    return result
  }
}

extension ___RedBlackTree.___Tree.Pointer {

  /// 参照している木に対してポインタがValidかどうか
  ///
  /// CoWが発生すると結果が乖離するため注意
  @inlinable
  @inline(__always)
  public var ___isValid: Bool {
    // TODO: 余力があるときにinternalに変更するかも
    if rawValue == .end { return true }
    return _tree.___is_valid(rawValue)
  }

  @inlinable
  @inline(__always)
  public var isStart: Bool {
    rawValue == _tree.__begin_node
  }

  @inlinable
  @inline(__always)
  public var isEnd: Bool {
    rawValue == .end
  }

  // 利用価値はないが、おまけ。
  @inlinable
  @inline(__always)
  public var isRoot: Bool {
    rawValue == _tree.__root()
  }
}

extension ___RedBlackTree.___Tree.Pointer {

  @inlinable
  @inline(__always)
  public var next: Self? {
    // 幽霊化はあくまでRange<Index>対応なので、next返却能力はあるが、未対応のままにする
    guard !___is_null_or_end(rawValue), ___isValid else {
      return nil
    }
    var next = self
    next.___next()
    return next
  }

  @inlinable
  @inline(__always)
  public var previous: Self? {
    // 幽霊化はあくまでRange<Index>対応なので、previous返却能力はあるが、未対応のままにする
    guard rawValue != .nullptr, rawValue != _tree.begin(), ___isValid else {
      return nil
    }
    var prev = self
    prev.___prev()
    return prev
  }
}

extension ___RedBlackTree.___Tree.Pointer {
  
  @inlinable
  @inline(__always)
  public var pointee: Element? {
    guard !___is_null_or_end(rawValue), ___isValid else {
      return nil
    }
    return ___pointee
  }
}

extension ___RedBlackTree.___Tree.Pointer {

  @inlinable @inline(__always)
  var ___pointee: Element {
    _tree[rawValue]
  }

  @inlinable @inline(__always)
  mutating func ___next() {
    rawValue = _tree.__tree_next_iter(rawValue)
  }

  @inlinable @inline(__always)
  mutating func ___prev() {
    rawValue = _tree.__tree_prev_iter(rawValue)
  }
}

#if DEBUG
  extension ___RedBlackTree.___Tree.Pointer {
    fileprivate init(_unsafe_tree: ___RedBlackTree.___Tree<VC>, rawValue: _NodePtr) {
      self._tree = _unsafe_tree
      self.rawValue = rawValue
    }
  }

  extension ___RedBlackTree.___Tree.Pointer {
    static func unsafe(tree: ___RedBlackTree.___Tree<VC>, rawValue: _NodePtr) -> Self {
      .init(_unsafe_tree: tree, rawValue: rawValue)
    }
  }
#endif

extension ___RedBlackTree.___Tree.Pointer: RedBlackTreeIndex { }
extension ___RedBlackTree.___Tree.Pointer: RedBlackTreeRawValue { }

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
func lessThanContainsUnderOrOver(_ lhs: _NodePtr, _ rhs: _NodePtr) -> Bool? {
  if lhs == .under {
    return rhs != .under
  }
  if lhs == .over {
    return false
  }
  if rhs == .under {
    return false
  }
  if rhs == .over {
    return lhs != .over
  }
  return nil
}

