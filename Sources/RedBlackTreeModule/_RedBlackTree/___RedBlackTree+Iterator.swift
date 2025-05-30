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

  /// 赤黒木のノードへのイテレータ
  @frozen
  public struct ___Iterator {

    public typealias Element = Tree.Element

    @usableFromInline
    typealias _Tree = Tree

    @usableFromInline
    let _tree: Tree

    @usableFromInline
    var _rawValue: Int
    
    @inlinable
    var rawValue: _NodePtr {
      @inline(__always)
      _read {
        guard !isGarbaged else {
          preconditionFailure(.garbagedIndex)
        }
        yield _rawValue
      }
      _modify { yield &_rawValue }
    }
    
    public var ___unchecked_rawValue: _NodePtr { _rawValue }

    // MARK: -

    @inlinable
    @inline(__always)
    internal init(__tree: Tree, rawValue: _NodePtr) {
      guard rawValue != .nullptr else {
        preconditionFailure("_NodePtr is nullptr")
      }
      self._tree = __tree
      self._rawValue = rawValue
    }

    /*
     invalidなポインタでの削除は、だんまりがいいように思う
     */

    // 性能上の問題でCoWに関与できない設計としている
    // CoWに関与できないので、Treeに対する破壊的変更は行わないこと
  }
}

extension ___RedBlackTree.___Tree.___Iterator: Comparable {

  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    // _tree比較は、CoWが発生した際に誤判定となり、邪魔となるので、省いている

    guard !lhs.isGarbaged, !rhs.isGarbaged else {
      preconditionFailure(.garbagedIndex)
    }

    return lhs._rawValue == rhs._rawValue
  }

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    // _tree比較は、CoWが発生した際に誤判定となり、邪魔となるので、省いている

    guard !lhs.isGarbaged, !rhs.isGarbaged else {
      preconditionFailure(.garbagedIndex)
    }

    return lhs._tree.___ptr_comp(lhs._rawValue, rhs._rawValue)
  }
}

extension ___RedBlackTree.___Tree.___Iterator {

  @inlinable
  @inline(__always)
  public func distance(to other: Self) -> Int {
    guard !isGarbaged, !other.isGarbaged else {
      preconditionFailure(.garbagedIndex)
    }
    return _tree.___signed_distance(_rawValue, other._rawValue)
  }

  @inlinable
  @inline(__always)
  public func advanced(by n: Int) -> Self {
    guard !isGarbaged else {
      preconditionFailure(.garbagedIndex)
    }
    var distance = n
    var result: Self = self
    while distance != 0 {
      if 0 < distance {
        if result.isEnd { return result }
        result.___next()
        distance -= 1
      } else {
        if result.isStart {
          result._rawValue = .nullptr
          return result
        }
        result.___prev()
        distance += 1
      }
    }
    return result
  }
}

extension ___RedBlackTree.___Tree.___Iterator {

  @inlinable
  @inline(__always)
  public var next: Self? {
    guard !isEnd, !isGarbaged else {
      return nil
    }
    var next = self
    next.___next()
    return next
  }

  @inlinable
  @inline(__always)
  public var previous: Self? {
    guard !isStart, !isGarbaged else {
      return nil
    }
    var prev = self
    prev.___prev()
    return prev
  }

  @inlinable @inline(__always)
  mutating func ___next() {
    assert(_rawValue != .end)
    _rawValue = _tree.__tree_next_iter(_rawValue)
  }

  @inlinable @inline(__always)
  mutating func ___prev() {
    _rawValue = _tree.__tree_prev_iter(_rawValue)
  }
}

extension ___RedBlackTree.___Tree.___Iterator {

  // CoWが発生すると結果が乖離する
  @inlinable
  @inline(__always)
  var ___isValid: Bool {
    if _rawValue == .end { return true }
    return _tree.___is_valid(_rawValue)
  }

  @inlinable
  @inline(__always)
  var isGarbaged: Bool {
    _tree.___is_garbaged(_rawValue)
  }

  @inlinable
  @inline(__always)
  public var isStart: Bool {
    _rawValue == _tree.__begin_node
  }

  @inlinable
  @inline(__always)
  public var isEnd: Bool {
    _rawValue == .end
  }

  // 利用価値はないが、おまけ。
  @inlinable
  @inline(__always)
  public var isRoot: Bool {
    _rawValue == _tree.__root()
  }
}

extension ___RedBlackTree.___Tree.___Iterator {

  @inlinable
  @inline(__always)
  public var pointee: Element? {
    guard _tree.__parent_(_rawValue) != .nullptr, _tree.___contains(_rawValue) else {
      return nil
    }
    return ___pointee
  }
}

extension ___RedBlackTree.___Tree.___Iterator {

  @inlinable @inline(__always)
  var ___key: VC._Key {
    _tree.__key(___pointee)
  }

  @inlinable @inline(__always)
  var ___pointee: Element {
    _tree[_rawValue]
  }
}

extension ___RedBlackTree.___Tree.___Iterator: RedBlackTreeIndex, RedBlackTreeMutableRawValue {}

#if DEBUG
  extension ___RedBlackTree.___Tree.___Iterator {
    fileprivate init(_unsafe_tree: ___RedBlackTree.___Tree<VC>, rawValue: _NodePtr) {
      self._tree = _unsafe_tree
      self._rawValue = rawValue
    }
  }

  extension ___RedBlackTree.___Tree.___Iterator {
    static func unsafe(tree: ___RedBlackTree.___Tree<VC>, rawValue: _NodePtr) -> Self {
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
public func ..< <VC>(
  lhs: ___RedBlackTree.___Tree<VC>.Index,
  rhs: ___RedBlackTree.___Tree<VC>.Index
) -> ___RedBlackTree.___Tree<VC>.Indices {
  lhs._tree.makeIndices(start: lhs._rawValue, end: rhs._rawValue)
}

@inlinable
public func + <VC>(
  lhs: ___RedBlackTree.___Tree<VC>.Index,
  rhs: Int
) -> ___RedBlackTree.___Tree<VC>.Index {
  lhs.advanced(by: rhs)
}

@inlinable
public func - <VC>(
  lhs: ___RedBlackTree.___Tree<VC>.Index,
  rhs: Int
) -> ___RedBlackTree.___Tree<VC>.Index {
  lhs.advanced(by: -rhs)
}

@inlinable
public func - <VC>(
  lhs: ___RedBlackTree.___Tree<VC>.Index,
  rhs: ___RedBlackTree.___Tree<VC>.Index
) -> Int {
  rhs.distance(to: lhs)
}
