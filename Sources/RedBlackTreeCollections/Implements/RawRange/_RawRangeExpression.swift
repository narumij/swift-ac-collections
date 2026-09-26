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
    case (.range(let lhsFrom, let lhsTo), .range(let rhsFrom, let rhsTo)):
      lhsFrom == rhsFrom && lhsTo == rhsTo
    case (.closedRange(let lhsFrom, let lhsThrough), .closedRange(let rhsFrom, let rhsThrough)):
      lhsFrom == rhsFrom && lhsThrough == rhsThrough
    case (.partialRangeTo(let lhs), .partialRangeTo(let rhs)):
      lhs == rhs
    case (.partialRangeThrough(let lhs), .partialRangeThrough(let rhs)):
      lhs == rhs
    case (.partialRangeFrom(let lhs), .partialRangeFrom(let rhs)):
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
  func relative<Base>(to tree: UnsafeTreeV2<Base>)
    -> _RawRange<_SafePtr>
  where Base: ___TreeBase {
    relative(
      start: _start(tree),
      end: _end(tree),
      bound: { $0 },
      through: {
        $0.flatMap { ___tree_next_iter($0) }
      })
  }
}

// つまり_SafeRangeExpressionに対する拡張
extension Result where Success == _NodeRangeExpression, Failure == SealError {

  @usableFromInline
  func relative<Base>(to tree: UnsafeTreeV2<Base>) -> _SafeRange
  where Base: ___TreeBase {
    flatMap {
      sequence($0.relative(to: tree))
    }
  }
}

extension _RawRangeExpression
where Bound == UnsafeMutablePointer<UnsafeNode> {

  @usableFromInline
  func relative<Base>(to tree: UnsafeTreeV2<Base>)
    -> _RawRange<_SafePtr>
  where Base: ___TreeBase {
    relative(
      start: _start(tree),
      end: _end(tree),
      bound: \.unchecked,
      through: ___tree_next_iter)
  }
}

extension _RawRangeExpression {

  @usableFromInline
  func relative<T>(
    start: T,
    end: T,
    bound: (Bound) -> T,
    through: (Bound) -> T
  ) -> _RawRange<T> {
    switch self {
    case .range(let lhs, let rhs):
      .init(
        lowerBound: bound(lhs),
        upperBound: bound(rhs))

    case .closedRange(let lhs, let rhs):
      .init(
        lowerBound: bound(lhs),
        upperBound: through(rhs))

    case .partialRangeTo(let rhs):
      .init(
        lowerBound: start,
        upperBound: bound(rhs))

    case .partialRangeThrough(let rhs):
      .init(
        lowerBound: start,
        upperBound: through(rhs))

    case .partialRangeFrom(let lhs):
      .init(
        lowerBound: bound(lhs),
        upperBound: end)

    case .unboundedRange:
      .init(
        lowerBound: start,
        upperBound: end)
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

public typealias _SafeRangeExpression = Result<_NodeRangeExpression, SealError>
