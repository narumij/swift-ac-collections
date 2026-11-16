//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project.
//
// Copyright (c) 2024-2026 narumij.
// Licensed under the Apache License v2.0.
//
// SPDX-License-Identifier: Apache-2.0
//
// This implementation includes code derived from LLVM libc++'s red-black tree
// implementation, originally distributed under the Apache License v2.0 with
// LLVM Exceptions.
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by
// narumij.
//
//===----------------------------------------------------------------------===//

// 同一木のノードの比較であることが不変条件
// ノードさえ生きてれば比較自体は可能だが未定義動作
@usableFromInline
package enum _NodeKey<Base: ~Copyable & _BaseNode_KeyInterface>
where Base._NodePtr == UnsafeMutablePointer<UnsafeNode>, Base._Key: Comparable {

  case key(Base._Key)
  case end

  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

  @inlinable
  package init(_ p: _NodePtr) {
    self = p.___is_end ? .end : .key(Base.__get_value(p))
  }
}

extension _NodeKey: Comparable {}

extension _NodeKey {
  
  @inlinable
  package static func lessThan(
    lhs: (node: UnsafeMutablePointer<UnsafeNode>, bitmap: _NodePathBitmap?),
    rhs: (node: UnsafeMutablePointer<UnsafeNode>, bitmap: _NodePathBitmap?)
  )
    -> (
      result: Bool,
      lhsBitmap: _NodePathBitmap?,
      rhsBitmap: _NodePathBitmap?
    )
  where Base._NodePtr == UnsafeMutablePointer<UnsafeNode>, Base._Key: Comparable {
    if lhs.node == rhs.node {
      return (false, lhs.bitmap, rhs.bitmap)
    }
    
    let lk = _NodeKey(lhs.node)
    let rk = _NodeKey(rhs.node)
    
    if lk < rk {
      return (true, lhs.bitmap, rhs.bitmap)
    }
    
    if lk > rk {
      return (false, lhs.bitmap, rhs.bitmap)
    }
    
    return _NodePathBitmap.lessThan(lhs: lhs, rhs: rhs)
  }

  @inlinable
  package static func isInHalfOpenRange(
    first: (node: UnsafeMutablePointer<UnsafeNode>, bitmap: _NodePathBitmap?),
    position: (node: UnsafeMutablePointer<UnsafeNode>, bitmap: _NodePathBitmap?),
    last: (node: UnsafeMutablePointer<UnsafeNode>, bitmap: _NodePathBitmap?)
  )
    -> (
      result: Bool,
      firstBitmap: _NodePathBitmap?,
      positionBitmap: _NodePathBitmap?,
      lastBitmap: _NodePathBitmap?
    )
  where Base._NodePtr == UnsafeMutablePointer<UnsafeNode>, Base._Key: Comparable {
    let belowFirst = lessThan(lhs: position, rhs: first)
    guard !belowFirst.result else {
      return (
        false,
        belowFirst.rhsBitmap,
        belowFirst.lhsBitmap,
        last.bitmap
      )
    }

    let belowLast = lessThan(
      lhs: (position.node, belowFirst.lhsBitmap),
      rhs: last
    )
    return (
      belowLast.result,
      belowFirst.rhsBitmap,
      belowLast.lhsBitmap,
      belowLast.rhsBitmap
    )
  }

  @inlinable
  package static func containsRange(
    outerFirst: (node: UnsafeMutablePointer<UnsafeNode>, bitmap: _NodePathBitmap?),
    outerLast: (node: UnsafeMutablePointer<UnsafeNode>, bitmap: _NodePathBitmap?),
    innerFirst: (node: UnsafeMutablePointer<UnsafeNode>, bitmap: _NodePathBitmap?),
    innerLast: (node: UnsafeMutablePointer<UnsafeNode>, bitmap: _NodePathBitmap?)
  )
    -> (
      result: Bool,
      outerFirstBitmap: _NodePathBitmap?,
      outerLastBitmap: _NodePathBitmap?,
      innerFirstBitmap: _NodePathBitmap?,
      innerLastBitmap: _NodePathBitmap?
    )
  where Base._NodePtr == UnsafeMutablePointer<UnsafeNode>, Base._Key: Comparable {
    let innerStartsBeforeOuter = lessThan(lhs: innerFirst, rhs: outerFirst)
    guard !innerStartsBeforeOuter.result else {
      return (
        false,
        innerStartsBeforeOuter.rhsBitmap,
        outerLast.bitmap,
        innerStartsBeforeOuter.lhsBitmap,
        innerLast.bitmap
      )
    }

    let innerIsReversed = lessThan(
      lhs: innerLast,
      rhs: (innerFirst.node, innerStartsBeforeOuter.lhsBitmap)
    )
    guard !innerIsReversed.result else {
      return (
        false,
        innerStartsBeforeOuter.rhsBitmap,
        outerLast.bitmap,
        innerIsReversed.rhsBitmap,
        innerIsReversed.lhsBitmap
      )
    }

    let innerEndsAfterOuter = lessThan(
      lhs: outerLast,
      rhs: (innerLast.node, innerIsReversed.lhsBitmap)
    )
    return (
      !innerEndsAfterOuter.result,
      innerStartsBeforeOuter.rhsBitmap,
      innerEndsAfterOuter.lhsBitmap,
      innerIsReversed.rhsBitmap,
      innerEndsAfterOuter.rhsBitmap
    )
  }
}
