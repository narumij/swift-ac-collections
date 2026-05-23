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

public enum _RawRangeExpression<Bound> {
  /// `a..<b` のこと
  case range(from: Bound, to: Bound)
  /// `a...b` のこと
  case closedRange(from: Bound, through: Bound)
  /// `..<b` のこと
  case partialRangeTo(Bound)
  /// `...b` のこと
  case partialRangeThrough(Bound)
  /// `a...` のこと
  case partialRangeFrom(Bound)
  /// `...` のこと
  case unboundedRange
}

extension _RawRangeExpression: Equatable where Bound: Equatable {}

extension _RawRangeExpression where Bound == _SealedPtr {

  @inlinable
  internal var safe: _RawRangeExpression<_SafePtr> {
    switch self {
    case .range(let from, let to):
      .range(from: from.map(\.pointer), to: to.map(\.pointer))
    case .closedRange(let from, let through):
      .closedRange(from: from.map(\.pointer), through: through.map(\.pointer))
    case .partialRangeTo(let bound):
      .partialRangeTo(bound.map(\.pointer))
    case .partialRangeThrough(let bound):
      .partialRangeThrough(bound.map(\.pointer))
    case .partialRangeFrom(let bound):
      .partialRangeFrom(bound.map(\.pointer))
    case .unboundedRange:
      .unboundedRange
    }
  }
}

// TODO: 方針ぶれがひどいので、整理すること

extension _RawRangeExpression where Bound == _SafePtr {

  @inlinable
  func _start<Base>(_ __tree_: UnsafeTreeV2<Base>) -> _SafePtr {
    __tree_.__begin_node_.safe
  }

  @inlinable
  func _end<Base>(_ __tree_: UnsafeTreeV2<Base>) -> _SafePtr {
    __tree_.__end_node.safe
  }
}

extension _RawRangeExpression where Bound == _SafePtr {

  @usableFromInline
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>)
    -> _RawRange<_SafePtr>
  where
    Base: ___TreeBase
  {
    switch self {
    case .range(let lhs, let rhs):
      return .init(
        lowerBound: lhs,
        upperBound: rhs)
    case .closedRange(let lhs, let rhs):
      return .init(
        lowerBound: lhs,
        upperBound: rhs.flatMap { ___tree_next_iter($0) })
    case .partialRangeTo(let rhs):
      return .init(
        lowerBound: _start(__tree_),
        upperBound: rhs)
    case .partialRangeThrough(let rhs):
      return .init(
        lowerBound: _start(__tree_),
        upperBound: rhs.flatMap { ___tree_next_iter($0) })
    case .partialRangeFrom(let lhs):
      return .init(
        lowerBound: lhs,
        upperBound: _end(__tree_))
    case .unboundedRange:
      return .init(
        lowerBound: _start(__tree_),
        upperBound: _end(__tree_))
    }
  }
}

extension _RawRangeExpression where Bound == _SealedPtr {

  @usableFromInline
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>)
    -> _RawRange<_SealedPtr>
  where
    Base: ___TreeBase
  {
    return safe.relative(to: __tree_).sealed
  }
}
