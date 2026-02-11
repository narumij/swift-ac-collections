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

@frozen
public struct UnsafeIndexV3RangeExpression: _UnsafeNodePtrType {

  @usableFromInline
  internal var rawRange: _TieWrappedRangeExpression

  @inlinable
  @inline(__always)
  internal init(rawValue: _TieWrappedRangeExpression) {
    self.rawRange = rawValue
  }
}

// 削除の悩みがつきまとうので、Sequence適合せず、ループはできないようにする

extension UnsafeIndexV3RangeExpression {

  @usableFromInline
  func relative<Base: ___TreeBase>(to __tree_: UnsafeTreeV2<Base>) -> (_SealedPtr, _SealedPtr) {
    rawRange.sealed.relative(to: __tree_)
  }
}

// MARK: - Range Expression

@inlinable
@inline(__always)
public func ..< (lhs: UnsafeIndexV3, rhs: UnsafeIndexV3)
  -> UnsafeIndexV3RangeExpression
{
  guard lhs.tied === rhs.tied else { fatalError(.treeMissmatch) }
  return .init(rawValue: .range(from: lhs, to: rhs))
}

@inlinable
@inline(__always)
public func ... (lhs: UnsafeIndexV3, rhs: UnsafeIndexV3)
  -> UnsafeIndexV3RangeExpression
{
  guard lhs.tied === rhs.tied else { fatalError(.treeMissmatch) }
  return .init(rawValue: .closedRange(from: lhs, through: rhs))
}

@inlinable
@inline(__always)
public prefix func ..< (rhs: UnsafeIndexV3) -> UnsafeIndexV3RangeExpression {
  return .init(rawValue: .partialRangeTo(rhs))
}

@inlinable
@inline(__always)
public prefix func ... (rhs: UnsafeIndexV3) -> UnsafeIndexV3RangeExpression {
  return .init(rawValue: .partialRangeThrough(rhs))
}

@inlinable
@inline(__always)
public postfix func ... (lhs: UnsafeIndexV3) -> UnsafeIndexV3RangeExpression {
  return .init(rawValue: .partialRangeFrom(lhs))
}

// MARK: -

extension UnsafeIndexV3RangeExpression {

  public enum _TieWrappedRangeExpression: Equatable {

    public typealias Bound = _TieWrappedPtr
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
}

extension UnsafeIndexV3RangeExpression._TieWrappedRangeExpression {
  var sealed: UnsafeTreeSealedRangeExpression {
    switch self {
    case .range(let from, let to):
      .range(from: from.sealed, to: to.sealed)
    case .closedRange(let from, let through):
      .closedRange(from: from.sealed, through: through.sealed)
    case .partialRangeTo(let bound):
      .partialRangeTo(bound.sealed)
    case .partialRangeThrough(let bound):
      .partialRangeThrough(bound.sealed)
    case .partialRangeFrom(let bound):
      .partialRangeFrom(bound.sealed)
    case .unboundedRange:
      .unboundedRange
    }
  }
}
