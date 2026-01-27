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

extension RedBlackTreeBound {

  @inlinable @inline(__always)
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>) -> UnsafeMutablePointer<UnsafeNode>
  where Base: ___TreeBase, Base._Key == _Key {
    switch self {
    case .start: __tree_.__begin_node_
    case .end: __tree_.__end_node
    case .lower(let l): __tree_.lower_bound(l)
    case .upper(let r): __tree_.upper_bound(r)
    }
  }
}

extension RedBlackTreeBoundsExpression {

  @inlinable @inline(__always)
  func _relative<Base>(to __tree_: UnsafeTreeV2<Base>) -> UnsafeTreeRangeExpression
  where Base: ___TreeBase, Base._Key == _Key {
    switch self {
    case .range(let lhs, let rhs):
      return .range(from: lhs.relative(to: __tree_), to: rhs.relative(to: __tree_))
    case .closedRange(let lhs, let rhs):
      return .closedRange(from: lhs.relative(to: __tree_), through: rhs.relative(to: __tree_))
    case .partialRangeTo(let rhs):
      return .partialRangeTo(rhs.relative(to: __tree_))
    case .partialRangeThrough(let rhs):
      return .partialRangeThrough(rhs.relative(to: __tree_))
    case .partialRangeFrom(let lhs):
      return .partialRangeFrom(lhs.relative(to: __tree_))
    }
  }

  @inlinable @inline(__always)
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>) -> (
    UnsafeMutablePointer<UnsafeNode>, UnsafeMutablePointer<UnsafeNode>
  )
  where Base: ___TreeBase, Base._Key == _Key {
    _relative(to: __tree_).relative(to: __tree_)
  }
}
