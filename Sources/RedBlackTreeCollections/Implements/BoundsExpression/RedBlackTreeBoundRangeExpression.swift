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

// MARK: - RedBlackTreeSet

/// A range expression for sorted red-black trees.
///
/// This type represents half-open, closed, partial, and equal ranges
/// using `RedBlackTreeBoundExpression` as endpoints.
///
/// - Note:
///   - Endpoints are specified by `BoundExpression`, not raw keys.
///   - Ranges are evaluated in the tree's sort order.
///   - Invalid ranges (e.g., lower > upper) may trap at runtime.
///
/// - SeeAlso: `RedBlackTreeBoundExpression`
@frozen
public enum RedBlackTreeBoundRangeExpression<Key> {
  /// An endpoint expression of the range.
  public typealias Bound = RedBlackTreeBoundExpression<Key>
  /// A half-open range `[from, to)`.
  ///
  /// - Parameters:
  ///   - from: Lower bound (inclusive)
  ///   - to: Upper bound (exclusive)
  ///
  /// - Note:
  ///   If `from >= to`, the range may be empty or invalid.
  case range(from: Bound, to: Bound)
  /// A closed range `[from, through]`.
  ///
  /// - Parameters:
  ///   - from: Lower bound (inclusive)
  ///   - through: Upper bound (inclusive)
  ///
  /// - Note:
  ///   If `from > through`, the range is invalid.
  case closedRange(from: Bound, through: Bound)
  /// A range of elements strictly less than `bound` (`..< bound`).
  ///
  /// - Parameter bound: Upper bound (exclusive)
  case partialRangeTo(Bound)
  /// A range of elements less than or equal to `bound` (`... bound`).
  ///
  /// - Parameter bound: Upper bound (inclusive)
  case partialRangeThrough(Bound)
  /// A range of elements greater than or equal to `bound` (`bound ..`).
  ///
  /// - Parameter bound: Lower bound (inclusive)
  case partialRangeFrom(Bound)
  /// A range containing all elements equal to the given key.
  ///
  /// - Parameter key: The target key
  ///
  /// - Note:
  ///   - For sets, the result contains at most one element.
  ///   - For multisets or multimaps, it spans all equal-key elements.
  case equalRange(Key)
}

// Sequence適合は不可能

@inlinable
public func ..< <Key>(
  lhs: RedBlackTreeBoundExpression<Key>, rhs: RedBlackTreeBoundExpression<Key>
)
  -> RedBlackTreeBoundRangeExpression<Key>
{
  .range(from: lhs, to: rhs)
}

@inlinable
public func ... <Key>(
  lhs: RedBlackTreeBoundExpression<Key>, rhs: RedBlackTreeBoundExpression<Key>
)
  -> RedBlackTreeBoundRangeExpression<Key>
{
  .closedRange(from: lhs, through: rhs)
}

@inlinable
public prefix func ..< <Key>(rhs: RedBlackTreeBoundExpression<Key>)
  -> RedBlackTreeBoundRangeExpression<Key>
{
  .partialRangeTo(rhs)
}

@inlinable
public prefix func ... <Key>(rhs: RedBlackTreeBoundExpression<Key>)
  -> RedBlackTreeBoundRangeExpression<Key>
{
  .partialRangeThrough(rhs)
}

@inlinable
public postfix func ... <Key>(lhs: RedBlackTreeBoundExpression<Key>)
  -> RedBlackTreeBoundRangeExpression<Key>
{
  .partialRangeFrom(lhs)
}

@inlinable
public func equalRange<Key>(_ key: Key)
  -> RedBlackTreeBoundRangeExpression<Key>
{
  .equalRange(key)
}
