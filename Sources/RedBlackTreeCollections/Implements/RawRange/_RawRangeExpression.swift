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

  @inlinable
  public static func != (lhs: Self, rhs: Self) -> Bool {
    !(lhs == rhs)
  }
}

// 各Range表現はここで半開区間の`_RawRange<_SafePtr>`へ正規化する。
// closed rangeの上端だけ次のノードへ進め、exclusive upper boundへ変換する。

extension _RawRangeExpression {

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

extension _RawRangeExpression where Bound == UnsafeMutablePointer<UnsafeNode> {

  @usableFromInline
  func relative<Base>(to tree: UnsafeTreeV2<Base>) -> _SafeRange
  where Base: ___TreeBase {
    sequence(relative(to: tree))
  }

  @usableFromInline
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>)
    -> _RawRange<_SafePtr>
  where
    Base: ___TreeBase
  {
    switch self {
    case .range(let lhs, let rhs):
      return .init(
        lowerBound: lhs.unchecked,
        upperBound: rhs.unchecked)
    case .closedRange(let lhs, let rhs):
      return .init(
        lowerBound: lhs.unchecked,
        upperBound: ___tree_next_iter(rhs))
    case .partialRangeTo(let rhs):
      return .init(
        lowerBound: _start(__tree_),
        upperBound: rhs.unchecked)
    case .partialRangeThrough(let rhs):
      return .init(
        lowerBound: _start(__tree_),
        upperBound: ___tree_next_iter(rhs))
    case .partialRangeFrom(let lhs):
      return .init(
        lowerBound: lhs.unchecked,
        upperBound: _end(__tree_))
    case .unboundedRange:
      return .init(
        lowerBound: _start(__tree_),
        upperBound: _end(__tree_))
    }
  }
}

extension _RawRangeExpression {

  @inlinable
  func map<T>(_ f: (Bound) -> T) -> _RawRangeExpression<T> {
    switch self {
    case .range(let from, let to):
      .range(from: f(from), to: f(to))
    case .closedRange(let from, let through):
      .closedRange(from: f(from), through: f(through))
    case .partialRangeTo(let bound):
      .partialRangeTo(f(bound))
    case .partialRangeThrough(let bound):
      .partialRangeThrough(f(bound))
    case .partialRangeFrom(let bound):
      .partialRangeFrom(f(bound))
    case .unboundedRange:
      .unboundedRange
    }
  }
}

@inlinable
func sequence<T, E>(
  _ range: _RawRangeExpression<Result<T, E>>
) -> Result<_RawRangeExpression<T>, E> {
  switch range {
  case .range(let from, let to):
    liftA2(from, to) {
      .range(from: $0, to: $1)
    }

  case .closedRange(let from, let through):
    liftA2(from, through) {
      .closedRange(from: $0, through: $1)
    }

  case .partialRangeTo(let bound):
    bound.map {
      .partialRangeTo($0)
    }

  case .partialRangeThrough(let bound):
    bound.map {
      .partialRangeThrough($0)
    }

  case .partialRangeFrom(let bound):
    bound.map {
      .partialRangeFrom($0)
    }

  case .unboundedRange:
    .success(.unboundedRange)
  }
}

@inlinable
func traverse<T, S, E>(
  _ range: _RawRangeExpression<T>,
  _ f: (T) -> Result<S, E>
) -> Result<_RawRangeExpression<S>, E> {
  sequence(range.map(f))
}


public typealias _NodeRangeExpression = _RawRangeExpression<UnsafeMutablePointer<UnsafeNode>>
// _SafeNodeRangeがいいという説がある
public typealias _SafeRangeExpression = Result<_NodeRangeExpression, SealError>
