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

import Foundation

extension RedBlackTreeBoundExpression {

  @inlinable @inline(__always)
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>)
    -> Result<UnsafeMutablePointer<UnsafeNode>, BoundRelativeError>
  where
    Base: ___TreeBase,
    Base._Key == _Key
  {

    switch self {

    case .start:
      return .success(__tree_.__begin_node_)

    case .end:
      return .success(__tree_.__end_node)

    case .lower(let __v):
      return .success(__tree_.lower_bound(__v))

    case .upper(let __v):
      return .success(__tree_.upper_bound(__v))

    case .find(let __v):
      return .success(__tree_.find(__v))

    case .advanced(let __self, by: let offset):
      let __p = __self.relative(to: __tree_)
      return __p.flatMap { __p in
        ___tree_adv_iter(__p, offset)
      }

    case .before(let __self):
      return
        RedBlackTreeBoundExpression
        .advanced(__self, by: -1)
        .relative(to: __tree_)

    case .after(let __self):
      return
        RedBlackTreeBoundExpression
        .advanced(__self, by: 1)
        .relative(to: __tree_)

    }
  }
}

extension RedBlackTreeBoundRangeExpression {

  @inlinable @inline(__always)
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>)
    -> UnsafeTreeRangeExpression2
  where
    Base: ___TreeBase,
    Base._Key == _Key
  {
    switch self {

    case .range(let from, let to):
      return .range(
        from: from.relative(to: __tree_),
        to: to.relative(to: __tree_))

    case .closedRange(let from, let through):
      return .closedRange(
        from: from.relative(to: __tree_),
        through: through.relative(to: __tree_))

    case .partialRangeTo(let to):
      return .partialRangeTo(to.relative(to: __tree_))

    case .partialRangeThrough(let through):
      return .partialRangeThrough(through.relative(to: __tree_))

    case .partialRangeFrom(let from):
      return .partialRangeFrom(from.relative(to: __tree_))

    case .equalRange(let __v):
      let (lower, upper) =
        __tree_.isMulti
        ? __tree_.__equal_range_multi(__v)
        : __tree_.__equal_range_unique(__v)

      return .range(
        from: .success(lower),
        to: .success(upper))
    }
  }

  @usableFromInline
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>)
    -> (
      Result<UnsafeMutablePointer<UnsafeNode>, BoundRelativeError>,
      Result<UnsafeMutablePointer<UnsafeNode>, BoundRelativeError>
    )
  where
    Base: ___TreeBase,
    Base._Key == _Key
  {
    relative(to: __tree_)
      .relative(to: __tree_)
  }
}

extension RedBlackTreeBoundExpression {

  @inlinable @inline(__always)
  func _relative<Base>(to __tree_: UnsafeTreeV2<Base>)
    -> UnsafeMutablePointer<UnsafeNode>
  where
    Base: ___TreeBase,
    Base._Key == _Key
  {
    try! relative(to: __tree_).get()
  }
}

extension RedBlackTreeBoundRangeExpression {

  @inlinable @inline(__always)
  func ___relative<Base>(to __tree_: UnsafeTreeV2<Base>) -> UnsafeTreeRangeExpression
  where
    Base: ___TreeBase,
    Base._Key == _Key
  {
    switch self {

    case .range(let lhs, let rhs):
      return .range(
        from: lhs._relative(to: __tree_),
        to: rhs._relative(to: __tree_))

    case .closedRange(let lhs, let rhs):
      return .closedRange(
        from: lhs._relative(to: __tree_),
        through: rhs._relative(to: __tree_))

    case .partialRangeTo(let rhs):
      return .partialRangeTo(rhs._relative(to: __tree_))

    case .partialRangeThrough(let rhs):
      return .partialRangeThrough(rhs._relative(to: __tree_))

    case .partialRangeFrom(let lhs):
      return .partialRangeFrom(lhs._relative(to: __tree_))

    case .equalRange(let __v):
      let (lower, upper) =
        __tree_.isMulti ? __tree_.__equal_range_multi(__v) : __tree_.__equal_range_unique(__v)
      return .range(from: lower, to: upper)
    }
  }

  @inlinable @inline(__always)
  func _relative<Base>(to __tree_: UnsafeTreeV2<Base>)
    -> (
      UnsafeMutablePointer<UnsafeNode>,
      UnsafeMutablePointer<UnsafeNode>
    )
  where
    Base: ___TreeBase,
    Base._Key == _Key
  {
    ___relative(to: __tree_)
      ._relative(to: __tree_)
  }
}
