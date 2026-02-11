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
  internal var rawRange: UnsafeTreeSealedRangeExpression

  @usableFromInline
  internal var tied: _TiedRawBuffer

  // MARK: -

  @inlinable
  @inline(__always)
  internal init(rawValue: UnsafeTreeSealedRangeExpression, tie: _TiedRawBuffer) {
    self.rawRange = rawValue
    self.tied = tie
  }
}

// 削除の悩みがつきまとうので、Sequence適合せず、ループはできないようにする

extension UnsafeIndexV3RangeExpression {

  @usableFromInline
  func relative<Base: ___TreeBase>(to __tree_: UnsafeTreeV2<Base>) -> (_SealedPtr, _SealedPtr) {
    rawRange.relative(to: __tree_)
  }

  @usableFromInline
  func relative(to tied: _TiedRawBuffer) -> (_SealedPtr, _SealedPtr) {
    rawRange.relative(to: tied)
  }
}

extension UnsafeIndexV3RangeExpression {

  @inlinable
  @inline(__always)
  public func isTriviallyIdentical(to other: Self) -> Bool {
    tied === other.tied && rawRange == other.rawRange
  }
}

// MARK: - Range Expression

@inlinable
@inline(__always)
public func ..< (lhs: UnsafeIndexV3, rhs: UnsafeIndexV3)
  -> UnsafeIndexV3RangeExpression
{
  guard lhs.tied === rhs.tied else { fatalError(.treeMissmatch) }
  return .init(rawValue: .range(from: lhs.sealed, to: rhs.sealed), tie: lhs.tied)
}

@inlinable
@inline(__always)
public func ... (lhs: UnsafeIndexV3, rhs: UnsafeIndexV3)
  -> UnsafeIndexV3RangeExpression
{
  guard lhs.tied === rhs.tied else { fatalError(.treeMissmatch) }
  return .init(rawValue: .closedRange(from: lhs.sealed, through: rhs.sealed), tie: lhs.tied)
}

@inlinable
@inline(__always)
public prefix func ..< (rhs: UnsafeIndexV3) -> UnsafeIndexV3RangeExpression {
  return .init(rawValue: .partialRangeTo(rhs.sealed), tie: rhs.tied)
}

@inlinable
@inline(__always)
public prefix func ... (rhs: UnsafeIndexV3) -> UnsafeIndexV3RangeExpression {
  return .init(rawValue: .partialRangeThrough(rhs.sealed), tie: rhs.tied)
}

@inlinable
@inline(__always)
public postfix func ... (lhs: UnsafeIndexV3) -> UnsafeIndexV3RangeExpression {
  return .init(rawValue: .partialRangeFrom(lhs.sealed), tie: lhs.tied)
}
