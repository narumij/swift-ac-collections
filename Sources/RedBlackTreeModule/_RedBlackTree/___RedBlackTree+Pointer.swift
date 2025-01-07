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

  /// Range<Bound>の左右のサイズ違いでクラッシュすることを避けるためのもの
  @frozen
  public struct TreePointer: Comparable {

    @usableFromInline
    let _tree: Tree

    @usableFromInline
    var rawValue: Int

    // MARK: -

    @inlinable
    @inline(__always)
    internal init(__storage: Tree.Storage, pointer: _NodePtr) {
      guard pointer != .nullptr else {
        preconditionFailure("_NodePtr is nullptr")
      }
      self._tree = __storage.tree
      self.rawValue = pointer
    }

    @inlinable
    @inline(__always)
    internal init(__tree: Tree, pointer: _NodePtr) {
      guard pointer != .nullptr else {
        preconditionFailure("_NodePtr is nullptr")
      }
      self._tree = __tree
      self.rawValue = pointer
    }

    @inlinable
    @inline(__always)
    static func end(_ storage: Tree.Storage) -> Self {
      .init(__tree: storage.tree, pointer: .end)
    }

    // MARK: -

    @inlinable
    public var isEnd: Bool {
      rawValue == .end
    }

    @inlinable
    public var isValid: Bool {
      if rawValue == .end { return true }
      if !(0..<_tree._header.initializedCount ~= rawValue) { return false }
      return _tree.___is_valid(rawValue)
    }

    // どうしてもSwiftらしい書き方が難しいときの必殺技用
    @inlinable
    public var ___pointee: Element {
      _tree[rawValue]
    }

    // どうしてもSwiftらしい書き方が難しいときの必殺技用
    @inlinable
    public mutating func ___next() {
      rawValue = _tree.__tree_next_iter(rawValue)
    }

    // どうしてもSwiftらしい書き方が難しいときの必殺技用
    @inlinable
    public mutating func ___prev() {
      rawValue = _tree.__tree_prev_iter(rawValue)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
      // Rangeで正しく動けばいいので、これ以外の比較は行わない
      lhs.rawValue == rhs.rawValue
    }

    // 本来の目的のための、大事な比較演算子
    public static func < (lhs: Self, rhs: Self) -> Bool {
      guard
        lhs.rawValue != rhs.rawValue,
        rhs.rawValue != .end,
        lhs.rawValue != .end
      else {
        return lhs.rawValue != .end && rhs.rawValue == .end
      }
      let tree = lhs._tree
      return Tree.VC.value_comp(tree[key: lhs.rawValue], tree[key: rhs.rawValue])
    }
  }
}


