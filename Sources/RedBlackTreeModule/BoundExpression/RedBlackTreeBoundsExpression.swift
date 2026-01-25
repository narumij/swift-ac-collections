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

@frozen
public enum RedBlackTreeBoundsExpression<_Key> {
  public typealias Bound = RedBlackTreeBound<_Key>
  case range(from: Bound, to: Bound)
  case closedRange(from: Bound, through: Bound)
  case partialRangeTo(Bound)
  case partialRangeThrough(Bound)
  case partialRangeFrom(Bound)
}

@inlinable @inline(__always)
public func ..< <_Key>(lhs: RedBlackTreeBound<_Key>, rhs: RedBlackTreeBound<_Key>)
  -> RedBlackTreeBoundsExpression<_Key>
{
  .range(from: lhs, to: rhs)
}

@inlinable @inline(__always)
public func ... <_Key>(lhs: RedBlackTreeBound<_Key>, rhs: RedBlackTreeBound<_Key>)
  -> RedBlackTreeBoundsExpression<_Key>
{
  .closedRange(from: lhs, through: rhs)
}

@inlinable @inline(__always)
public prefix func ..< <_Key>(rhs: RedBlackTreeBound<_Key>)
  -> RedBlackTreeBoundsExpression<_Key>
{
  .partialRangeTo(rhs)
}

@inlinable @inline(__always)
public prefix func ... <_Key>(rhs: RedBlackTreeBound<_Key>)
  -> RedBlackTreeBoundsExpression<_Key>
{
  .partialRangeThrough(rhs)
}

@inlinable @inline(__always)
public postfix func ... <_Key>(lhs: RedBlackTreeBound<_Key>) -> RedBlackTreeBoundsExpression<_Key> {
  .partialRangeFrom(lhs)
}
