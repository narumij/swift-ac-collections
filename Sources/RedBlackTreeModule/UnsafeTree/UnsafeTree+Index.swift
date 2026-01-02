// Copyright 2024-2026 narumij
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
// Copyright © 2003-2025 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

extension UnsafeTree where Base: ___TreeIndex {

  public typealias Index = UnsafeIndex<Base>
  public typealias Pointee = Base.Pointee

  @nonobjc
  @inlinable
  @inline(__always)
  internal func makeIndex(rawValue: _NodePtr) -> Index {
    .init(tree: self, rawValue: rawValue)
  }
}

extension UnsafeTree where Base: ___TreeIndex {

  public typealias Indices = UnsafeIndices<Base>
}

extension UnsafeTree where Base: ___TreeIndex {

  public typealias _Values = RedBlackTreeIteratorUnsafe<Base>.Values
}

extension UnsafeTree where Base: KeyValueComparer & ___TreeIndex {

  public typealias _KeyValues = RedBlackTreeIteratorUnsafe<Base>.KeyValues
}

extension UnsafeTree {

  // この実装がないと、迷子になる?
  @nonobjc
  @inlinable
  @inline(__always)
  internal func
    ___distance(from start: _NodePtr, to end: _NodePtr) -> Int
  {
    guard
      !___is_offset_null(start),
      !___is_offset_null(end)
    else {
      fatalError(.invalidIndex)
    }
    return ___signed_distance(start, end)
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___index(after i: _NodePtr) -> _NodePtr {
    ___ensureValid(after: i)
    return __tree_next(i)
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___formIndex(after i: inout _NodePtr) {
    i = ___index(after: i)
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___index(before i: _NodePtr) -> _NodePtr {
    ___ensureValid(before: i)
    return __tree_prev_iter(i)
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___formIndex(before i: inout _NodePtr) {
    i = ___index(before: i)
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___index(_ i: _NodePtr, offsetBy distance: Int) -> _NodePtr {
    ___ensureValid(offset: i)
    var distance = distance
    var i = i
    while distance != 0 {
      if 0 < distance {
        guard i != __end_node else {
          fatalError(.outOfBounds)
        }
        i = ___index(after: i)
        distance -= 1
      } else {
        guard i != __begin_node_ else {
          fatalError(.outOfBounds)
        }
        i = ___index(before: i)
        distance += 1
      }
    }
    return i
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___formIndex(_ i: inout _NodePtr, offsetBy distance: Int) {
    i = ___index(i, offsetBy: distance)
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func
    ___index(_ i: _NodePtr, offsetBy distance: Int, limitedBy limit: _NodePtr)
    -> _NodePtr?
  {
    ___ensureValid(offset: i)
    var distance = distance
    var i = i
    while distance != 0 {
      if i == limit {
        return nil
      }
      if 0 < distance {
        guard i != __end_node else {
          fatalError(.outOfBounds)
        }
        i = ___index(after: i)
        distance -= 1
      } else {
        guard i != __begin_node_ else {
          fatalError(.outOfBounds)
        }
        i = ___index(before: i)
        distance += 1
      }
    }
    return i
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func
    ___formIndex(
      _ i: inout _NodePtr, offsetBy distance: Int, limitedBy limit: _NodePtr
    )
    -> Bool
  {
    if let ii = ___index(i, offsetBy: distance, limitedBy: limit) {
      i = ii
      return true
    }
    return false
  }
}

extension UnsafeTree {

  @nonobjc
  @inlinable
  @inline(__always)
  internal func
    ___tree_adv_iter(_ i: _NodePtr, by distance: Int) -> _NodePtr
  {
    ___ensureValid(offset: i)
    var distance = distance
    var result: _NodePtr = i
    while distance != 0 {
      if 0 < distance {
        if result == __end_node { return result }
        result = __tree_next_iter(result)
        distance -= 1
      } else {
        if result == __begin_node_ {
          // 後ろと区別したくてnullptrにしてたが、一周回るとendなのでendにしてみる
          result = end
          return result
        }
        result = __tree_prev_iter(result)
        distance += 1
      }
    }
    return result
  }
}
