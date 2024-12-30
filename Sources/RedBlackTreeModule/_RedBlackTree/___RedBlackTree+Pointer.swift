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
  public struct TreePointer: Comparable {

    public typealias Pointer = Self

    @usableFromInline
    unowned let tree: Tree

    @usableFromInline
    var pointer: _NodePtr

    @inlinable
    public var rawValue: Int { pointer }

    // MARK: -

    @inlinable
    @inline(__always)
    internal init(__tree: Tree, pointer: _NodePtr) {
      guard pointer != .nullptr else {
        preconditionFailure("_NodePtr is nullptr")
      }
      self.tree = __tree
      self.pointer = pointer
    }

    @inlinable
    @inline(__always)
    static func end(_ tree: Tree) -> Pointer {
      .init(__tree: tree, pointer: .end)
    }
    
    // MARK: -

    @inlinable
    public var isNull: Bool {
      pointer == .nullptr
    }

    @inlinable
    public var isEnd: Bool {
      pointer == .end
    }

    // どうしてもSwiftらしい書き方が難しいときの必殺技用
    @inlinable
    public var ___pointee: Element {
      tree[pointer]
    }

    // どうしてもSwiftらしい書き方が難しいときの必殺技用
    @inlinable
    public mutating func ___next() {
      pointer = tree.__tree_next_iter(pointer)
    }

    // どうしてもSwiftらしい書き方が難しいときの必殺技用
    @inlinable
    public mutating func ___prev() {
      pointer = tree.__tree_prev_iter(pointer)
    }
    
    public static func == (lhs: Pointer, rhs: Pointer) -> Bool {
      // Rangeで正しく動けばいいので、これ以外の比較は行わない
      lhs.pointer == rhs.pointer
    }

    // 本来の目的のための、大事な比較演算子
    public static func < (lhs: Pointer, rhs: Pointer) -> Bool {

      if lhs.pointer == rhs.pointer {
        return false
      }

      guard rank(lhs) == rank(rhs) else {
        return rank(lhs) < rank(rhs)
      }

      let tree = lhs.tree
      
      return tree.value_comp(tree[key: lhs.pointer], tree[key: rhs.pointer])
    }
    
    // nullとendとそれ以外をざっくりまとめた比較値
    @inlinable
    internal static func rank(_ rhs: Pointer) -> Int {
      //      rhs.pointer != .end ? rhs.pointer : Int.max
      switch rhs.pointer {
      case .nullptr: return 3
      case .end: return 2
      default: return 1
      }
    }
  }
}
