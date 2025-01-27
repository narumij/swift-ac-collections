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
      // _tree比較は、CoWが発生した際に誤判定となり、邪魔となるので、省いている
      lhs.rawValue == rhs.rawValue
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
      // _tree比較は、CoWが発生した際に誤判定となり、邪魔となるので、省いている
      lhs._tree.___ptr_comp(lhs.rawValue, rhs.rawValue)
    }

    // MARK: -

    @inlinable
    @inline(__always)
    internal init(__tree: Tree, rawValue: _NodePtr) {
      guard rawValue != .nullptr else {
        preconditionFailure("_NodePtr is nullptr")
      }
      self._tree = __tree
      self.rawValue = rawValue
    }

    /*
     invalidなポインタでの削除は、だんまりがいいように思う
     */
  }
}

extension ___RedBlackTree.___Tree.Pointer {
  
  @inlinable
  @inline(__always)
  public var isValid: Bool {
    if rawValue == .end { return true }
    if !(0..<_tree.header.initializedCount ~= rawValue) { return false }
    return _tree.___is_valid(rawValue)
  }
  
  @inlinable
  @inline(__always)
  public var isStartIndex: Bool {
    rawValue == _tree.__begin_node
  }
  
  @inlinable
  @inline(__always)
  public var isEndIndex: Bool {
    rawValue == .end
  }
  
  // 利用上価値はないが、おまけで。
  @inlinable
  @inline(__always)
  public var isRootIndex: Bool {
    rawValue == _tree.__root()
  }
}

extension ___RedBlackTree.___Tree.Pointer {
  
  // 名前について検討中
  @inlinable
  @inline(__always)
  public var pointee: Element? {
    guard !___is_null_or_end(rawValue), isValid else {
      return nil
    }
    return ___pointee
  }
  
  // 名前はXMLNodeを参考にした
  @inlinable
  @inline(__always)
  public var next: Self? {
    guard !___is_null_or_end(rawValue), isValid else {
      return nil
    }
    var next = self
    next.___next()
    return next
  }
  
  // 名前はXMLNodeを参考にした
  @inlinable
  @inline(__always)
  public var previous: Self? {
    guard rawValue != .nullptr, rawValue != _tree.begin(), isValid else {
      return nil
    }
    var prev = self
    prev.___prev()
    return prev
  }
  
  // 名前はIntの同名を参考にした
  @inlinable
  @inline(__always)
  public func advanced(by distance: Int) -> Self? {
    var distance = distance
    var result: Self? = self
    while distance != 0 {
      if 0 < distance {
        result = result?.next
        distance -= 1
      } else {
        result = result?.previous
        distance += 1
      }
    }
    return result
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
fileprivate extension ___RedBlackTree.___Tree.Pointer {
  init(_unsafe_tree: ___RedBlackTree.___Tree<VC>, rawValue: _NodePtr) {
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

