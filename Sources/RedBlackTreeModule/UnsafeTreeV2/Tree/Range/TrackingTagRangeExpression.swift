//
//  TrackingTagRangeExpression.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/29.
//

// これはfor文では使えない
public enum TrackingTagRangeExpression: Equatable {
  public typealias Bound = TaggedSeal
  /// `a..<b` のこと
  case range(from: TaggedSeal, to: TaggedSeal)
  /// `a...b` のこと
  case closedRange(from: TaggedSeal, through: TaggedSeal)
  /// `..<b` のこと
  case partialRangeTo(TaggedSeal)
  /// `...b` のこと
  case partialRangeThrough(TaggedSeal)
  /// `a...` のこと
  case partialRangeFrom(TaggedSeal)
  /// `...` のこと
  case unboundedRange
}

public func ..< (lhs: TaggedSeal, rhs: TaggedSeal)
  -> TrackingTagRangeExpression
{
  .range(from: lhs, to: rhs)
}

public func ... (lhs: TaggedSeal, rhs: TaggedSeal)
  -> TrackingTagRangeExpression
{
  .closedRange(from: lhs, through: rhs)
}

public prefix func ..< (rhs: TaggedSeal)
  -> TrackingTagRangeExpression
{
  .partialRangeTo(rhs)
}

public prefix func ... (rhs: TaggedSeal)
  -> TrackingTagRangeExpression
{
  .partialRangeThrough(rhs)
}

public postfix func ... (lhs: TaggedSeal)
  -> TrackingTagRangeExpression
{
  .partialRangeFrom(lhs)
}

extension TrackingTagRangeExpression {

  @inlinable @inline(__always)
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>)
    -> UnsafeTreeSealedRangeExpression
  where
    Base: ___TreeBase
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

    case .unboundedRange:
      return .unboundedRange
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
