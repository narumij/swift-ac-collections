//
//  UnsafeTreeRangeExpression.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/20.
//

public enum UnsafeTreeRangeExpression: Equatable {
  public typealias Bound = UnsafeMutablePointer<UnsafeNode>
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
}

extension UnsafeTreeRangeExpression {

#if false
  @usableFromInline
  func _slow_pair()
    -> (UnsafeMutablePointer<UnsafeNode>, UnsafeMutablePointer<UnsafeNode>)
  {
    switch self {
    case .range(let lhs, let rhs):
      (lhs, rhs)
    case .closedRange(let lhs, let rhs):
      (lhs, __tree_next(rhs))
    case .partialRangeTo(let rhs):
      (rhs.__slow_begin(), rhs)
    case .partialRangeThrough(let rhs):
      (rhs.__slow_begin(), __tree_next(rhs))
    case .partialRangeFrom(let lhs):
      (lhs, lhs.__slow_end())
    }
  }
#endif

  @usableFromInline
  func rawRange(_begin: UnsafeMutablePointer<UnsafeNode>, _end: UnsafeMutablePointer<UnsafeNode>)
    -> (UnsafeMutablePointer<UnsafeNode>, UnsafeMutablePointer<UnsafeNode>)
  {
    switch self {
    case .range(let lhs, let rhs):
      (lhs, rhs)
    case .closedRange(let lhs, let rhs):
      (lhs, __tree_next(rhs))
    case .partialRangeTo(let rhs):
      (_begin, rhs)
    case .partialRangeThrough(let rhs):
      (_begin, __tree_next(rhs))
    case .partialRangeFrom(let lhs):
      (lhs, _end)
    }
  }

  @usableFromInline
  func range(_begin: UnsafeMutablePointer<UnsafeNode>, _end: UnsafeMutablePointer<UnsafeNode>)
    -> UnsafeTreeRange
  {
    switch self {
    case .range(let lhs, let rhs):
      .init(___from: lhs, ___to: rhs)
    case .closedRange(let lhs, let rhs):
      .init(___from: lhs, ___to: __tree_next(rhs))
    case .partialRangeTo(let rhs):
      .init(___from: _begin, ___to: rhs)
    case .partialRangeThrough(let rhs):
      .init(___from: _begin, ___to: __tree_next(rhs))
    case .partialRangeFrom(let lhs):
      .init(___from: lhs, ___to: _end)
    }
  }
}

public func ..< (lhs: UnsafeMutablePointer<UnsafeNode>, rhs: UnsafeMutablePointer<UnsafeNode>)
  -> UnsafeTreeRangeExpression
{
  .range(from: lhs, to: rhs)
}

public func ... (lhs: UnsafeMutablePointer<UnsafeNode>, rhs: UnsafeMutablePointer<UnsafeNode>)
  -> UnsafeTreeRangeExpression
{
  .closedRange(from: lhs, through: rhs)
}

public prefix func ..< (rhs: UnsafeMutablePointer<UnsafeNode>)
  -> UnsafeTreeRangeExpression
{
  .partialRangeTo(rhs)
}

public prefix func ... (rhs: UnsafeMutablePointer<UnsafeNode>)
  -> UnsafeTreeRangeExpression
{
  .partialRangeThrough(rhs)
}

public postfix func ... (lhs: UnsafeMutablePointer<UnsafeNode>)
  -> UnsafeTreeRangeExpression
{
  .partialRangeFrom(lhs)
}
