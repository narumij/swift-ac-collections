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

extension UnsafeTreeV2 {

  @inlinable @inline(__always)
  func relative(from b: RedBlackTreeBound<_Key>) -> _NodePtr {
    switch b {
    case .start: __begin_node_
    case .end: __end_node
    case .lower(let l): lower_bound(l)
    case .upper(let r): upper_bound(r)
    }
  }
}

extension UnsafeTreeV2 {

  @inlinable @inline(__always)
  func relative<K>(to boundsExpression: RedBlackTreeBoundsExpression<K>)
    -> UnsafeTreeRangeExpression
  where K == _Key {
    switch boundsExpression {
    case .range(let lhs, let rhs):
      return .range(from: relative(from: lhs), to: relative(from: rhs))
    case .closedRange(let lhs, let rhs):
      return .closedRange(from: relative(from: lhs), through: relative(from: rhs))
    case .partialRangeTo(let rhs):
      return .partialRangeTo(relative(from: rhs))
    case .partialRangeThrough(let rhs):
      return .partialRangeThrough(relative(from: rhs))
    case .partialRangeFrom(let lhs):
      return .partialRangeFrom(relative(from: lhs))
    }
  }
}
