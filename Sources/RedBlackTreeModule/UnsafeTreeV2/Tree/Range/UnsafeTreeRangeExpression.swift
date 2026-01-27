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
  /// `...` のこと
  case unboundedRange
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
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>)
    -> (UnsafeMutablePointer<UnsafeNode>, UnsafeMutablePointer<UnsafeNode>)
  where Base: ___TreeBase {
    let (_begin, _end) = (__tree_.__begin_node_, __tree_.__end_node)
    switch self {
    case .range(let lhs, let rhs):
      return (lhs, rhs)
    case .closedRange(let lhs, let rhs):
      guard !rhs.___is_end else { fatalError(.outOfBounds) }
      return (lhs, __tree_next(rhs))
    case .partialRangeTo(let rhs):
      return (_begin, rhs)
    case .partialRangeThrough(let rhs):
      guard !rhs.___is_end else { fatalError(.outOfBounds) }
      return (_begin, __tree_next(rhs))
    case .partialRangeFrom(let lhs):
      return (lhs, _end)
    case .unboundedRange:
      return (_begin, _end)
    }
  }

  @usableFromInline
  func rawRange(_begin: UnsafeMutablePointer<UnsafeNode>, _end: UnsafeMutablePointer<UnsafeNode>)
    -> (UnsafeMutablePointer<UnsafeNode>, UnsafeMutablePointer<UnsafeNode>)
  {
    switch self {
    case .range(let lhs, let rhs):
      return (lhs, rhs)
    case .closedRange(let lhs, let rhs):
      guard !rhs.___is_end else { fatalError(.outOfBounds) }
      return (lhs, __tree_next(rhs))
    case .partialRangeTo(let rhs):
      return (_begin, rhs)
    case .partialRangeThrough(let rhs):
      guard !rhs.___is_end else { fatalError(.outOfBounds) }
      return (_begin, __tree_next(rhs))
    case .partialRangeFrom(let lhs):
      return (lhs, _end)
    case .unboundedRange:
      return (_begin, _end)
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
    case .unboundedRange:
      .init(___from: _begin, ___to: _end)
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
