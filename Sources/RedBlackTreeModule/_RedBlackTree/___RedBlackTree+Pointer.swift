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
  public struct Pointer: Comparable {
    
    public typealias Element = Tree.Element
    
    @usableFromInline
    typealias _Tree = Tree

    @usableFromInline
    let _tree: Tree

    @usableFromInline
    var rawValue: Int

    // MARK: -
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
      // TODO: CoW時に予期せぬ挙動をしないかどうか確認
      lhs._tree === rhs._tree && lhs.rawValue == rhs.rawValue
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
      // TODO: CoW時に予期せぬ挙動をしないかどうか確認
      lhs._tree === rhs._tree && lhs._tree.___ptr_comp(lhs.rawValue, rhs.rawValue)
    }

    // MARK: -

    @inlinable
    @inline(__always)
    internal init(__tree: Tree, pointer: _NodePtr) {
      guard pointer != .nullptr else {
        preconditionFailure("_NodePtr is nullptr")
      }
      self._tree = __tree
      self.rawValue = pointer
    }

    // MARK: -

    @inlinable
    public var isValid: Bool {
      if rawValue == .end { return true }
      if !(0..<_tree.header.initializedCount ~= rawValue) { return false }
      return _tree.___is_valid(rawValue)
    }
    
    /*
     invalidなポインタでの削除は、だんまりがいいように思う
     */
  }
}

extension ___RedBlackTree.___Tree.Pointer {
  
  @inlinable
  @inline(__always)
  static func end(_ tree: _Tree) -> Self {
    .init(__tree: tree, pointer: .end)
  }

  @inlinable
  public var isEnd: Bool {
    rawValue == .end
  }
}

extension ___RedBlackTree.___Tree.Pointer {

  @inlinable
  public var ___pointee: Element {
    _tree[rawValue]
  }

  @inlinable
  public func _next() -> Self? {
    guard isValid else {
      fatalError(.invalidIndex)
    }
    return .init(__tree: _tree, pointer: _tree.__tree_next_iter(rawValue))
  }

  @inlinable
  public func _prev() -> Self? {
    guard isValid else {
      fatalError(.invalidIndex)
    }
    return .init(__tree: _tree, pointer: _tree.__tree_next_iter(rawValue))
  }

  @inlinable
  mutating func ___next() {
    rawValue = _tree.__tree_next_iter(rawValue)
  }

  @inlinable
  mutating func ___prev() {
    rawValue = _tree.__tree_prev_iter(rawValue)
  }
}

#if DEBUG
fileprivate extension ___RedBlackTree.___Tree.Pointer {
  init(_tree: ___RedBlackTree.___Tree<VC>, rawValue: _NodePtr) {
    self._tree = _tree
    self.rawValue = rawValue
  }
}

extension ___RedBlackTree.___Tree.Pointer {
  static func unsafe(tree: ___RedBlackTree.___Tree<VC>, rawValue: _NodePtr) -> Self {
    rawValue == .end ? .end(tree) : .init(_tree: tree, rawValue: rawValue)
  }
}
#endif

