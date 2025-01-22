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

  @frozen
  public struct SubSequence: Sequence {

    public typealias Element = Tree.Element
    public typealias Index = _NodePtr

    @inlinable
    init(___tree: Tree, start: Index, end: Index) {
      self._tree = ___tree
      self.startIndex = start
      self.endIndex = end
    }

    @usableFromInline
    let _tree: Tree

    public
      var startIndex: Index

    public
      var endIndex: Index

    @inlinable
    public __consuming func makeIterator() -> Iterator {
      Iterator(tree: _tree, start: startIndex, end: endIndex)
    }

    @inlinable
    @inline(__always)
    internal var count: Int {
      _tree.distance(from: startIndex, to: endIndex)
    }

    // 断念
    //    @inlinable
    //    public func lowerBound(_ member: Element) -> Index {
    //      base.__lower_bound(base.__key(member), base.__root(), endIndex)
    //    }
    //
    //    @inlinable
    //    public func upperBound(_ member: Element) -> Index {
    //      base.__upper_bound(base.__key(member), base.__root(), endIndex)
    //    }

    @inlinable
    @inline(__always)
    internal func forEach(_ body: (Element) throws -> Void) rethrows {
      var __p = startIndex
      while __p != endIndex {
        let __c = __p
        __p = _tree.__tree_next(__p)
        try body(_tree[__c])
      }
    }

    // この実装がないと、迷子になる
    @inlinable
    @inline(__always)
    internal func distance(from start: Index, to end: Index) -> Int {
      _tree.distance(from: start, to: end)
    }

    @inlinable
    @inline(__always)
    internal func index(after i: Index) -> Index {
      _tree.index(after: i)
    }

    @inlinable
    @inline(__always)
    internal func formIndex(after i: inout Index) {
      _tree.formIndex(after: &i)
    }

    @inlinable
    @inline(__always)
    internal func index(before i: Index) -> Index {
      _tree.index(before: i)
    }

    @inlinable
    @inline(__always)
    internal func formIndex(before i: inout Index) {
      _tree.formIndex(before: &i)
    }

    @inlinable
    @inline(__always)
    internal func index(_ i: Index, offsetBy distance: Int) -> Index {
      _tree.index(i, offsetBy: distance)
    }

    @inlinable
    @inline(__always)
    internal func formIndex(_ i: inout Index, offsetBy distance: Int) {
      _tree.formIndex(&i, offsetBy: distance)
    }

    @inlinable
    @inline(__always)
    internal func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
      _tree.index(i, offsetBy: distance, limitedBy: limit)
    }

    @inlinable
    @inline(__always)
    internal func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Self.Index)
      -> Bool
    {
      if let ii = index(i, offsetBy: distance, limitedBy: limit) {
        i = ii
        return true
      }
      return false
    }

    @inlinable
    @inline(__always)
    internal subscript(position: Index) -> Element {
      assert(_tree.___ptr_less_than_or_equal(startIndex, position))
      assert(_tree.___ptr_less_than(position, endIndex))
      guard _tree.___ptr_less_than_or_equal(startIndex, position),
            _tree.___ptr_less_than(position, endIndex) else {
        fatalError(.outOfRange)
      }
      return _tree[position]
    }

    @inlinable
    @inline(__always)
    internal subscript(bounds: Range<Pointer>) -> SubSequence {
      guard _tree.___ptr_less_than_or_equal(startIndex, bounds.lowerBound.rawValue),
            _tree.___ptr_less_than_or_equal(bounds.upperBound.rawValue, endIndex) else {
        fatalError(.outOfRange)
      }
      return .init(
        ___tree: _tree,
        start: bounds.lowerBound.rawValue,
        end: bounds.upperBound.rawValue)
    }
  }
}

extension ___RedBlackTree.___Tree.SubSequence {

  @inlinable
  @inline(__always)
  internal func ___is_valid_index(index i: _NodePtr) -> Bool {
    guard i != .nullptr, _tree.___is_valid(i) else {
      return false
    }
    return _tree.___ptr_closed_range_contains(startIndex, endIndex, i)
  }
}

extension ___RedBlackTree.___Tree {

  @inlinable
  internal func subsequence(from: _NodePtr, to: _NodePtr) -> SubSequence {
    .init(
      ___tree: self,
      start: from,
      end: to)
  }
}
