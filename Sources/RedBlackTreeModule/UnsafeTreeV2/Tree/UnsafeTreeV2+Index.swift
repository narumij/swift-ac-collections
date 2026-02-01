//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project
//
// Copyright (c) 2024 - 2026 narumij.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.
//
//===----------------------------------------------------------------------===//

extension UnsafeTreeV2 where Base: ___TreeIndex {

  public typealias Index = UnsafeIndexV2<Base>
  public typealias Pointee = Base.Element

  @inlinable
  @inline(__always)
  internal func makeIndex(rawValue: _NodePtr) -> Index {
    .init(rawValue: rawValue, tie: tied)
  }
}

extension UnsafeTreeV2 where Base: ___TreeIndex {

  public typealias Indices = UnsafeIndexV2Collection<Base>
}

extension UnsafeTreeV2 where Base: ___TreeIndex {

  public typealias _PayloadValues = RedBlackTreeIteratorV2.Values<Base>
}

extension UnsafeTreeV2 where Base: KeyValueComparer & ___TreeIndex {

  public typealias _KeyValues = RedBlackTreeIteratorV2.KeyValues<Base>
}

extension UnsafeTreeV2 {

  // この実装がないと、迷子になる?
  @inlinable
  @inline(__always)
  internal func
    ___distance(from start: _NodePtr, to end: _NodePtr) -> Int
  {
    guard
      start.isValid,
      end.isValid
    else {
      fatalError(.invalidIndex)
    }
    return ___signed_distance(start, end)
  }

  @inlinable
  @inline(__always)
  internal func ___index(after i: _NodePtr) -> _NodePtr {
    return __tree_next(i.next_checked)
  }

  @inlinable
  @inline(__always)
  internal func ___formIndex(after i: inout _NodePtr) {
    i = ___index(after: i)
  }

  @inlinable
  @inline(__always)
  internal func ___index(before i: _NodePtr) -> _NodePtr {
    return __tree_prev_iter(i.checked)
  }

  @inlinable
  @inline(__always)
  internal func ___formIndex(before i: inout _NodePtr) {
    i = ___index(before: i)
  }

  @inlinable
  @inline(__always)
  internal func ___index(_ i: _NodePtr, offsetBy distance: Int) -> _NodePtr {
    var distance = distance
    var i = i.checked
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

  @inlinable
  @inline(__always)
  internal func ___formIndex(_ i: inout _NodePtr, offsetBy distance: Int) {
    i = ___index(i, offsetBy: distance)
  }

  @inlinable
  @inline(__always)
  internal func
    ___index(_ i: _NodePtr, offsetBy distance: Int, limitedBy limit: _NodePtr)
    -> _NodePtr?
  {
    var distance = distance
    var i = i.checked
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

//extension UnsafeTreeV2 {
//
//  @inlinable
//  @inline(__always)
//  internal func
//    ___tree_adv_iter(_ i: _NodePtr, by distance: Int) -> _NodePtr
//  {
//    var distance = distance
//    var result: _NodePtr = i.checked
//    while distance != 0 {
//      if 0 < distance {
//        if result == __end_node { return result }
//        result = __tree_next_iter(result)
//        distance -= 1
//      } else {
//        if result == __begin_node_ {
//          // 後ろと区別したくてnullptrにしてたが、一周回るとendなのでendにしてみる
//          result = end
//          return result
//        }
//        result = __tree_prev_iter(result)
//        distance += 1
//      }
//    }
//    return result
//  }
//}
