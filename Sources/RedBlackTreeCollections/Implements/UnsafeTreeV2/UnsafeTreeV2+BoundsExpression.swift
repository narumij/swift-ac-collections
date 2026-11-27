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

extension RedBlackTreeBoundExpression {

  @inlinable
  func evaluate<Base>(_ __tree_: UnsafeTreeV2<Base>)
    -> _SafePtr
  where
    Base: ___TreeBase,
    Base._Key == Key
  {
    _internal.evaluate(__tree_)
  }
}

extension RedBlackTreeBoundRangeExpression {

  @inlinable
  func __evaluate<Base>(_ __tree_: UnsafeTreeV2<Base>)
    -> _RawRangeExpression<_SafePtr>
  where
    Base: ___TreeBase,
    Base._Key == Key
  {
    switch self {

    case .range(let from, let to):
      return .range(
        from: from.evaluate(__tree_),
        to: to.evaluate(__tree_))

    case .closedRange(let from, let through):
      return .closedRange(
        from: from.evaluate(__tree_),
        through: through.evaluate(__tree_))

    case .partialRangeTo(let to):
      return .partialRangeTo(to.evaluate(__tree_))

    case .partialRangeThrough(let through):
      return .partialRangeThrough(through.evaluate(__tree_))

    case .partialRangeFrom(let from):
      return .partialRangeFrom(from.evaluate(__tree_))

    case .equalRange(let __v):
      let (lower, upper) =
        __tree_.isMulti
        ? __tree_.__equal_range_multi(__v)
        : __tree_.__equal_range_unique(__v)

      return .range(
        from: lower.unchecked,
        to: upper.unchecked)
    }
  }
}

extension RedBlackTreeBoundRangeExpression {
  
  @inlinable
  func evaluate<Base>(_ tree: UnsafeTreeV2<Base>) -> _SafeRangeExpression
  where
  Base: ___TreeBase,
  Base._Key == Key
  {
    sequence(__evaluate(tree))
  }
}
