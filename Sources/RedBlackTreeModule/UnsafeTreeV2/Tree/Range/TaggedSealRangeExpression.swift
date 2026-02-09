//
//  TrackingTagRangeExpression.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/29.
//

/// 赤黒木用軽量Range
///
/// - note: for文の範囲指定に使えない
///
public enum TaggedSealRangeExpression: Equatable {
  public typealias Bound = _SealedTag
  /// `a..<b` のこと
  case range(from: _SealedTag, to: _SealedTag)
  /// `a...b` のこと
  case closedRange(from: _SealedTag, through: _SealedTag)
  /// `..<b` のこと
  case partialRangeTo(_SealedTag)
  /// `...b` のこと
  case partialRangeThrough(_SealedTag)
  /// `a...` のこと
  case partialRangeFrom(_SealedTag)
}

public func ..< (lhs: _SealedTag, rhs: _SealedTag)
  -> TaggedSealRangeExpression
{
  .range(from: lhs, to: rhs)
}

public func ... (lhs: _SealedTag, rhs: _SealedTag)
  -> TaggedSealRangeExpression
{
  .closedRange(from: lhs, through: rhs)
}

public prefix func ..< (rhs: _SealedTag)
  -> TaggedSealRangeExpression
{
  .partialRangeTo(rhs)
}

public prefix func ... (rhs: _SealedTag)
  -> TaggedSealRangeExpression
{
  .partialRangeThrough(rhs)
}

public postfix func ... (lhs: _SealedTag)
  -> TaggedSealRangeExpression
{
  .partialRangeFrom(lhs)
}

extension TaggedSealRangeExpression {

  @inlinable @inline(__always)
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>)
    -> UnsafeTreeSealedRangeExpression
  where
    Base: ___TreeBase
  {
    switch self {

    case .range(let from, let to):
      return .range(
        from: __tree_.__purified_(from),
        to: __tree_.__purified_(to))

    case .closedRange(let from, let through):
      return .closedRange(
        from: __tree_.__purified_(from),
        through: __tree_.__purified_(through))

    case .partialRangeTo(let to):
      return .partialRangeTo(
        __tree_.__purified_(to))

    case .partialRangeThrough(let through):
      return .partialRangeThrough(
        __tree_.__purified_(through))

    case .partialRangeFrom(let from):
      return .partialRangeFrom(
        __tree_.__purified_(from))
    }
  }

  @usableFromInline
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>)
    -> (_SealedPtr, _SealedPtr)
  where
    Base: ___TreeBase
  {
    relative(to: __tree_)
      .relative(to: __tree_)
  }
}
