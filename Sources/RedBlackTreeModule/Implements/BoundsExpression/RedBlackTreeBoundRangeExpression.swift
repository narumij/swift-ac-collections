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

// MARK: - RedBlackTreeSet

/// A range expression for ordered red-black trees.
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
public enum RedBlackTreeBoundRangeExpression<_Key> {
  /// An endpoint expression of the range.
  public typealias Bound = RedBlackTreeBoundExpression<_Key>
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
  case equalRange(_Key)
}

@inlinable @inline(__always)
public func ..< <_Key>(
  lhs: RedBlackTreeBoundExpression<_Key>, rhs: RedBlackTreeBoundExpression<_Key>
)
  -> RedBlackTreeBoundRangeExpression<_Key>
{
  .range(from: lhs, to: rhs)
}

@inlinable @inline(__always)
public func ... <_Key>(
  lhs: RedBlackTreeBoundExpression<_Key>, rhs: RedBlackTreeBoundExpression<_Key>
)
  -> RedBlackTreeBoundRangeExpression<_Key>
{
  .closedRange(from: lhs, through: rhs)
}

@inlinable @inline(__always)
public prefix func ..< <_Key>(rhs: RedBlackTreeBoundExpression<_Key>)
  -> RedBlackTreeBoundRangeExpression<_Key>
{
  .partialRangeTo(rhs)
}

@inlinable @inline(__always)
public prefix func ... <_Key>(rhs: RedBlackTreeBoundExpression<_Key>)
  -> RedBlackTreeBoundRangeExpression<_Key>
{
  .partialRangeThrough(rhs)
}

@inlinable @inline(__always)
public postfix func ... <_Key>(lhs: RedBlackTreeBoundExpression<_Key>)
  -> RedBlackTreeBoundRangeExpression<_Key>
{
  .partialRangeFrom(lhs)
}

@inlinable @inline(__always)
public func equalRange<_Key>(_ __v: _Key)
  -> RedBlackTreeBoundRangeExpression<_Key>
{
  .equalRange(__v)
}
