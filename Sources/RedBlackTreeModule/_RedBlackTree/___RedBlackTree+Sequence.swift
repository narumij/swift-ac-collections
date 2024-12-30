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

extension ___RedBlackTree.___Tree: Sequence {
  
  @frozen
  public struct Iterator: IteratorProtocol {
    
    @inlinable
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      self.tree = tree
      self.current = start
      self.end = end
    }
    
    @usableFromInline
    let tree: Tree
    
    @usableFromInline
    var current, end: _NodePtr
    
    @inlinable
    @inline(__always)
    public mutating func next() -> Element?
    {
      guard current != end else { return nil }
      defer { current = tree.__tree_next(current) }
      return tree[current]
    }
  }
  
  @inlinable
  public __consuming func makeIterator() -> Iterator {
    .init(tree: self, start: __begin_node, end: __end_node())
  }
}

extension ___RedBlackTree.___Tree { // SubSequence不一致でBidirectionalCollectionには適合できない
  
  public var startIndex: _NodePtr {
    __begin_node
  }
  
  public var endIndex: _NodePtr {
    __end_node()
  }
  
  public typealias Index = _NodePtr
  
  // この実装がないと、迷子になる
  @inlinable
  public func distance(from start: Index, to end: Index) -> Int {
    ___signed_distance(start, end)
  }
  
  @inlinable
  @inline(__always)
  public func index(after i: Index) -> Index {
    guard i != __end_node(), ___is_valid(i) else {
      fatalError(.invalidIndex)
    }
    return __tree_next(i)
  }
  
  @inlinable
  @inline(__always)
  public func formIndex(after i: inout Index) {
    i = __tree_next(i)
  }
  
  @inlinable
  @inline(__always)
  public func index(before i: Index) -> Index {
    guard i != __begin_node, i == __end_node() || ___is_valid(i) else {
      fatalError(.invalidIndex)
    }
    return __tree_prev_iter(i)
  }
  
  @inlinable
  @inline(__always)
  public func formIndex(before i: inout Index) {
    i = __tree_prev_iter(i)
  }
  
  @inlinable
  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    guard i == ___end() || ___is_valid(i) else {
      fatalError(.invalidIndex)
    }
    var distance = distance
    var i = i
    while distance != 0 {
      if 0 < distance {
        guard i != __end_node() else {
          fatalError(.outOfBounds)
        }
        i = index(after: i)
        distance -= 1
      }
      else {
        guard i != __begin_node else {
          fatalError(.outOfBounds)
        }
        i = index(before: i)
        distance += 1
      }
    }
    return i
  }
  
  @inlinable
  @inline(__always)
  internal func formIndex(_ i: inout Index, offsetBy distance: Int) {
    i = index(i, offsetBy: distance)
  }
  
  @inlinable
  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
    guard i == ___end() || ___is_valid(i) else {
      fatalError(.invalidIndex)
    }
    var distance = distance
    var i = i
    while distance != 0 {
      if i == limit {
        return nil
      }
      if 0 < distance {
        guard i != __end_node() else {
          fatalError(.outOfBounds)
        }
        i = index(after: i)
        distance -= 1
      }
      else {
        guard i != __begin_node else {
          fatalError(.outOfBounds)
        }
        i = index(before: i)
        distance += 1
      }
    }
    return i
  }
  
  @inlinable
  @inline(__always)
  internal func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Index) -> Bool {
    if let ii = index(i, offsetBy: distance, limitedBy: limit) {
      i = ii
      return true
    }
    return false
  }
}
