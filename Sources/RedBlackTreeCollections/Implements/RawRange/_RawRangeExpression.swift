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

extension _RawRangeExpression: Equatable where Bound: Equatable {
  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case let (.range(lhsFrom, lhsTo), .range(rhsFrom, rhsTo)):
      lhsFrom == rhsFrom && lhsTo == rhsTo
    case let (.closedRange(lhsFrom, lhsThrough), .closedRange(rhsFrom, rhsThrough)):
      lhsFrom == rhsFrom && lhsThrough == rhsThrough
    case let (.partialRangeTo(lhs), .partialRangeTo(rhs)):
      lhs == rhs
    case let (.partialRangeThrough(lhs), .partialRangeThrough(rhs)):
      lhs == rhs
    case let (.partialRangeFrom(lhs), .partialRangeFrom(rhs)):
      lhs == rhs
    case (.unboundedRange, .unboundedRange):
      true
    default:
      false
    }
  }
}

// TODO: 方針ぶれがひどいので、整理すること

extension _RawRangeExpression where Bound == _SafePtr {

  @inlinable
  func _start<Base>(_ __tree_: UnsafeTreeV2<Base>) -> _SafePtr {
    __tree_.__begin_node_.unchecked
  }

  @inlinable
  func _end<Base>(_ __tree_: UnsafeTreeV2<Base>) -> _SafePtr {
    __tree_.__end_node.unchecked
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
