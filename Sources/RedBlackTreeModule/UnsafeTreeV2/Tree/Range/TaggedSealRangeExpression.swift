//
//  TrackingTagRangeExpression.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/29.
//

// これはfor文では使えない
public enum TaggedSealRangeExpression: Equatable {
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
  -> TaggedSealRangeExpression
{
  .range(from: lhs, to: rhs)
}

public func ... (lhs: TaggedSeal, rhs: TaggedSeal)
  -> TaggedSealRangeExpression
{
  .closedRange(from: lhs, through: rhs)
}

public prefix func ..< (rhs: TaggedSeal)
  -> TaggedSealRangeExpression
{
  .partialRangeTo(rhs)
}

public prefix func ... (rhs: TaggedSeal)
  -> TaggedSealRangeExpression
{
  .partialRangeThrough(rhs)
}

public postfix func ... (lhs: TaggedSeal)
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
      return .partialRangeTo(__tree_.__purified_(to))

    case .partialRangeThrough(let through):
      return .partialRangeThrough(__tree_.__purified_(through))

    case .partialRangeFrom(let from):
      return .partialRangeFrom(__tree_.__purified_(from))

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
