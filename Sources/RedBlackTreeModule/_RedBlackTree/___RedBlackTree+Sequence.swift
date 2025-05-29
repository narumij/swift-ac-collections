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

  @inlinable
  public __consuming func makeIterator() -> ElementIterator<Tree> {
    .init(tree: self, start: __begin_node, end: __end_node())
  }
}

extension ___RedBlackTree.___Tree {

  // この実装がないと、迷子になる?
  @inlinable
  internal func ___distance(from start: _NodePtr, to end: _NodePtr) -> Int {
    guard start == __end_node() || ___is_valid(start),
      end == __end_node() || ___is_valid(end)
    else {
      fatalError(.invalidIndex)
    }
    return ___signed_distance(start, end)
  }

  @inlinable
  @inline(__always)
  internal func ___index(after i: _NodePtr) -> _NodePtr {
    guard i != __end_node(), ___is_valid(i) else {
      fatalError(.invalidIndex)
    }
    return __tree_next(i)
  }

  @inlinable
  @inline(__always)
  internal func ___formIndex(after i: inout _NodePtr) {
    guard i != __end_node(), ___is_valid(i) else { fatalError(.invalidIndex) }
    i = __tree_next(i)
  }

  @inlinable
  @inline(__always)
  internal func ___index(before i: _NodePtr) -> _NodePtr {
    guard i != __begin_node, i == __end_node() || ___is_valid(i) else {
      fatalError(.invalidIndex)
    }
    return __tree_prev_iter(i)
  }

  @inlinable
  @inline(__always)
  internal func ___formIndex(before i: inout _NodePtr) {
    guard i == __end_node() || ___is_valid(i) else { fatalError(.invalidIndex) }
    i = __tree_prev_iter(i)
  }

  @inlinable
  @inline(__always)
  internal func ___index(_ i: _NodePtr, offsetBy distance: Int) -> _NodePtr {
    guard i == ___end() || ___is_valid(i) else { fatalError(.invalidIndex) }
    var distance = distance
    var i = i
    while distance != 0 {
      if 0 < distance {
        guard i != __end_node() else {
          fatalError(.outOfBounds)
        }
        i = ___index(after: i)
        distance -= 1
      } else {
        guard i != __begin_node else {
          fatalError(.outOfBounds)
        }
        i = ___index(before: i)
        distance += 1
      }
    }
    return i
  }

  @inlinable
  @inline(__always)
  internal func ___formIndex(_ i: inout _NodePtr, offsetBy distance: Int) {
    guard i == __end_node() || ___is_valid(i) else { fatalError(.invalidIndex) }
    i = ___index(i, offsetBy: distance)
  }

  @inlinable
  @inline(__always)
  internal func ___index(_ i: _NodePtr, offsetBy distance: Int, limitedBy limit: _NodePtr) -> _NodePtr? {
    guard i == ___end() || ___is_valid(i) else { fatalError(.invalidIndex) }
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
        i = ___index(after: i)
        distance -= 1
      } else {
        guard i != __begin_node else {
          fatalError(.outOfBounds)
        }
        i = ___index(before: i)
        distance += 1
      }
    }
    return i
  }

  @inlinable
  @inline(__always)
  internal func ___formIndex(_ i: inout _NodePtr, offsetBy distance: Int, limitedBy limit: _NodePtr) -> Bool
  {
    guard i == __end_node() || ___is_valid(i) else { fatalError(.invalidIndex) }
    if let ii = ___index(i, offsetBy: distance, limitedBy: limit) {
      i = ii
      return true
    }
    return false
  }
}
