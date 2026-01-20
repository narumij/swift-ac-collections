//
//  UnsafeTreeRangeExpression.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/20.
//

public enum UnsafeTreeRangeExpression {
  public typealias Bound = UnsafeMutablePointer<UnsafeNode>
  case range(lhs: Bound, rhs: Bound)
  case closedRange(lhs: Bound, rhs: Bound)
  case leftUnbound(rhs: Bound)
  case leftUnboundRightClose(rhs: Bound)
  case rithUnbound(lhs: Bound)
}

extension UnsafeTreeRangeExpression {
  
  @usableFromInline
  func pair(_begin: UnsafeMutablePointer<UnsafeNode>, _end: UnsafeMutablePointer<UnsafeNode>)
    -> (UnsafeMutablePointer<UnsafeNode>, UnsafeMutablePointer<UnsafeNode>)
  {
    switch self {
    case .range(let lhs, let rhs):
      (lhs, rhs)
    case .closedRange(let lhs, let rhs):
      (lhs, __tree_next(rhs))
    case .leftUnbound(let rhs):
      (_begin, rhs)
    case .leftUnboundRightClose(let rhs):
      (_begin, __tree_next(rhs))
    case .rithUnbound(let lhs):
      (lhs, _end)
    }
  }

  @usableFromInline
  func range(_begin: UnsafeMutablePointer<UnsafeNode>, _end: UnsafeMutablePointer<UnsafeNode>)
    -> UnsafeTreeRange
  {
    switch self {
    case .range(let lhs, let rhs):
      .init(__first: lhs, __last: rhs)
    case .closedRange(let lhs, let rhs):
      .init(__first: lhs, __last: __tree_next(rhs))
    case .leftUnbound(let rhs):
      .init(__first: _begin, __last: rhs)
    case .leftUnboundRightClose(let rhs):
      .init(__first: _begin, __last: __tree_next(rhs))
    case .rithUnbound(let lhs):
      .init(__first: lhs, __last: _end)
    }
  }
}

public func ..< (lhs: UnsafeMutablePointer<UnsafeNode>, rhs: UnsafeMutablePointer<UnsafeNode>)
  -> UnsafeTreeRangeExpression
{
  .range(lhs: lhs, rhs: rhs)
}

public func ... (lhs: UnsafeMutablePointer<UnsafeNode>, rhs: UnsafeMutablePointer<UnsafeNode>)
  -> UnsafeTreeRangeExpression
{
  .closedRange(lhs: lhs, rhs: rhs)
}

public prefix func ..< (rhs: UnsafeMutablePointer<UnsafeNode>)
  -> UnsafeTreeRangeExpression
{
  .leftUnbound(rhs: rhs)
}

public prefix func ... (rhs: UnsafeMutablePointer<UnsafeNode>)
  -> UnsafeTreeRangeExpression
{
  .leftUnboundRightClose(rhs: rhs)
}

public postfix func ... (lhs: UnsafeMutablePointer<UnsafeNode>)
  -> UnsafeTreeRangeExpression
{
  .rithUnbound(lhs: lhs)
}
