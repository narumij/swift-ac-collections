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

public enum UnsafeTreeSafeRangeExpression: Equatable {
  public typealias Bound = SafePtr
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

extension UnsafeTreeSafeRangeExpression {

  func _start<Base>(_ __tree_: UnsafeTreeV2<Base>) -> SafePtr {
    .success(__tree_.__begin_node_)
  }

  func _end<Base>(_ __tree_: UnsafeTreeV2<Base>) -> SafePtr {
    .success(__tree_.__end_node)
  }

  @usableFromInline
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>) -> (_from: SafePtr, _to: SafePtr)
  where Base: ___TreeBase {
    switch self {
    case .range(let lhs, let rhs):
      return (lhs, rhs)
    case .closedRange(let lhs, let rhs):
      return (lhs, rhs.flatMap { ___tree_next_iter($0) })
    case .partialRangeTo(let rhs):
      return (_start(__tree_), rhs)
    case .partialRangeThrough(let rhs):
      return (_start(__tree_), rhs.flatMap { ___tree_next_iter($0) })
    case .partialRangeFrom(let lhs):
      return (lhs, _end(__tree_))
    case .unboundedRange:
      return (_start(__tree_), _end(__tree_))
    }
  }
}

// MARK: -

public func ..< (lhs: SafePtr, rhs: SafePtr) -> UnsafeTreeSafeRangeExpression {
  .range(from: lhs, to: rhs)
}

public func ... (lhs: SafePtr, rhs: SafePtr) -> UnsafeTreeSafeRangeExpression {
  .closedRange(from: lhs, through: rhs)
}

public prefix func ..< (rhs: SafePtr) -> UnsafeTreeSafeRangeExpression {
  .partialRangeTo(rhs)
}

public prefix func ... (rhs: SafePtr) -> UnsafeTreeSafeRangeExpression {
  .partialRangeThrough(rhs)
}

public postfix func ... (lhs: SafePtr) -> UnsafeTreeSafeRangeExpression {
  .partialRangeFrom(lhs)
}

// MARK: -

public func ..< (lhs: UnsafeMutablePointer<UnsafeNode>, rhs: UnsafeMutablePointer<UnsafeNode>)
  -> UnsafeTreeSafeRangeExpression
{
  .range(from: lhs.safe, to: rhs.safe)
}

public func ... (lhs: UnsafeMutablePointer<UnsafeNode>, rhs: UnsafeMutablePointer<UnsafeNode>)
  -> UnsafeTreeSafeRangeExpression
{
  .closedRange(from: lhs.safe, through: rhs.safe)
}

public prefix func ..< (rhs: UnsafeMutablePointer<UnsafeNode>)
  -> UnsafeTreeSafeRangeExpression
{
  .partialRangeTo(rhs.safe)
}

public prefix func ... (rhs: UnsafeMutablePointer<UnsafeNode>)
  -> UnsafeTreeSafeRangeExpression
{
  .partialRangeThrough(rhs.safe)
}

public postfix func ... (lhs: UnsafeMutablePointer<UnsafeNode>)
  -> UnsafeTreeSafeRangeExpression
{
  .partialRangeFrom(lhs.safe)
}

// MARK: -

@inlinable @inline(__always)
func unwrapLowerUpperOrFatal(_ bounds: (SafePtr, SafePtr))
  -> (UnsafeMutablePointer<UnsafeNode>, UnsafeMutablePointer<UnsafeNode>)
{
  switch bounds {
  case (.success(let l), .success(let u)):
    return (l, u)

  case (.failure(let e), .success):
    fatalError("lower failed: \(e)")

  case (.success, .failure(let e)):
    fatalError("upper failed: \(e)")

  case (.failure(let le), .failure(let ue)):
    fatalError("both failed: lower=\(le), upper=\(ue)")
  }
}

// MARK: -

@inlinable @inline(__always)
func unwrapLowerUpper(_ bounds: (SafePtr, SafePtr))
  -> (UnsafeMutablePointer<UnsafeNode>, UnsafeMutablePointer<UnsafeNode>)?
{
  switch bounds {
  case (.success(let l), .success(let u)):
    return (l, u)
  default:
    return nil
  }
}
