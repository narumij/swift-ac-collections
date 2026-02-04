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

// TODO: sealed化

@frozen
public struct UnsafeIndexV2RangeExpression<Base>: UnsafeTreeBinding,
  UnsafeIndexingProtocol
where Base: ___TreeBase & ___TreeIndex {

  public typealias Tree = UnsafeTreeV2<Base>
  public typealias Pointee = Tree.Pointee

  @usableFromInline
  typealias _PayloadValue = Tree._PayloadValue

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

extension UnsafeIndexV2RangeExpression: Sequence {

  public typealias Iterator = UnsafeIterator.IndexObverse<Base>

  public func makeIterator() -> Iterator {
    let (lower, upper) = rawRange.relative(to: tied)
    return .init(start: lower, end: upper, tie: tied)
  }
}

extension UnsafeIndexV2RangeExpression {

  @usableFromInline
  func relative(to __tree_: Tree) -> (_NodePtr, _NodePtr) {
    unwrapLowerUpperOrFatal(rawRange.relative(to: __tree_))
  }
}

extension UnsafeIndexV2RangeExpression {

  @inlinable
  @inline(__always)
  public func isTriviallyIdentical(to other: Self) -> Bool {
    tied === other.tied && rawRange == other.rawRange
  }
}

// MARK: - Range Expression

@inlinable
@inline(__always)
public func ..< <Base>(lhs: UnsafeIndexV2<Base>, rhs: UnsafeIndexV2<Base>)
  -> UnsafeIndexV2RangeExpression<Base>
{
  guard lhs.tied === rhs.tied else { fatalError(.treeMissmatch) }
  return .init(rawValue: .range(from: lhs.sealed, to: rhs.sealed), tie: lhs.tied)
}

#if !COMPATIBLE_ATCODER_2025
  @inlinable
  @inline(__always)
  public func ... <Base>(lhs: UnsafeIndexV2<Base>, rhs: UnsafeIndexV2<Base>)
    -> UnsafeIndexV2RangeExpression<Base>
  {
    guard lhs.tied === rhs.tied else { fatalError(.treeMissmatch) }
    return .init(rawValue: .closedRange(from: lhs.sealed, through: rhs.sealed), tie: lhs.tied)
  }

  @inlinable
  @inline(__always)
  public prefix func ..< <Base>(rhs: UnsafeIndexV2<Base>) -> UnsafeIndexV2RangeExpression<Base> {
    return .init(rawValue: .partialRangeTo(rhs.sealed), tie: rhs.tied)
  }

  @inlinable
  @inline(__always)
  public prefix func ... <Base>(rhs: UnsafeIndexV2<Base>) -> UnsafeIndexV2RangeExpression<Base> {
    return .init(rawValue: .partialRangeThrough(rhs.sealed), tie: rhs.tied)
  }

  @inlinable
  @inline(__always)
  public postfix func ... <Base>(lhs: UnsafeIndexV2<Base>) -> UnsafeIndexV2RangeExpression<Base> {
    return .init(rawValue: .partialRangeFrom(lhs.sealed), tie: lhs.tied)
  }
#endif

// MARK: -
