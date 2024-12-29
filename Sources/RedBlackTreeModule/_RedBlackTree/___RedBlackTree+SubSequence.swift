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
    public init(tree: Tree, start: Index, end: Index) {
      self.base = tree
      self.startIndex = start
      self.endIndex = end
    }

    @usableFromInline
    unowned let base: Tree

    public
      var startIndex: Index
    
    public
      var endIndex: Index

    @inlinable
    public func makeIterator() -> Iterator {
      base.makeIterator(start: startIndex, end: endIndex)
    }
    
    @inlinable
    @inline(__always)
    var count: Int {
      base.distance(from: startIndex, to: endIndex)
    }
    
    // この実装がないと、迷子になる
    @inlinable
    @inline(__always)
    public func distance(from start: Index, to end: Index) -> Int {
      base.distance(from: start, to: end)
    }
    
    @inlinable
    @inline(__always)
    public func index(after i: Index) -> Index {
      base.index(after: i)
    }
    
    @inlinable
    @inline(__always)
    public func formIndex(after i: inout Index) {
      base.formIndex(after: &i)
    }
    
    @inlinable
    @inline(__always)
    public func index(before i: Index) -> Index {
      base.index(before: i)
    }
    
    @inlinable
    @inline(__always)
    public func formIndex(before i: inout Index) {
      base.formIndex(before: &i)
    }
    
    @inlinable
    @inline(__always)
    public func index(_ i: Index, offsetBy distance: Int) -> Index {
      base.index(i, offsetBy: distance)
    }
    
    @inlinable
    @inline(__always)
    internal func formIndex(_ i: inout Index, offsetBy distance: Int) {
      base.formIndex(&i, offsetBy: distance)
    }
    
    @inlinable
    @inline(__always)
    public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
      base.index(i, offsetBy: distance, limitedBy: limit)
    }
    
    @inlinable
    @inline(__always)
    internal func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Self.Index) -> Bool {
      if let ii = index(i, offsetBy: distance, limitedBy: limit) {
        i = ii
        return true
      }
      return false
    }
    
    @inlinable
    @inline(__always)
    public subscript(position: Index) -> Element {
      base[position]
    }
    
    @inlinable
    public subscript(bounds: Range<TreePointer>) -> SubSequence {
      .init(tree: base, start: bounds.lowerBound.pointer, end: bounds.upperBound.pointer)
    }
  }
  
  func subsequence(from: _NodePtr, to: _NodePtr) -> SubSequence {
    .init(tree: self, start: from, end: to)
  }
}
