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
public struct UnsafeIndexV2RangeExpression<Base>: UnsafeTreeBinding,
  UnsafeIndexingProtocol
where Base: ___TreeBase & ___TreeIndex {

  public typealias Tree = UnsafeTreeV2<Base>
  public typealias Pointee = Tree.Pointee

  @usableFromInline
  typealias _PayloadValue = Tree._PayloadValue

  @usableFromInline
  internal var rawRange: UnsafeTreeRangeExpression

  @usableFromInline
  internal var tied: _TiedRawBuffer

  // MARK: -

  @inlinable
  @inline(__always)
  internal init(rawValue: UnsafeTreeRangeExpression, tie: _TiedRawBuffer) {
    self.rawRange = rawValue
    self.tied = tie
  }
}

extension UnsafeIndexV2RangeExpression: Sequence {

  public typealias Iterator = UnsafeIterator.IndexObverse<Base>

  public func makeIterator() -> Iterator {
    let (lower, upper) = tied.rawRange(rawRange)!
    return .init(start: lower, end: upper, tie: tied)
  }
}

extension UnsafeIndexV2RangeExpression {

  @usableFromInline
  func relative(to __tree_: Tree) -> (_NodePtr, _NodePtr) {
    rawRange._relative(to: __tree_)
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
  return .init(rawValue: lhs.rawValue..<rhs.rawValue, tie: lhs.tied)
}

#if !COMPATIBLE_ATCODER_2025
  @inlinable
  @inline(__always)
  public func ... <Base>(lhs: UnsafeIndexV2<Base>, rhs: UnsafeIndexV2<Base>)
    -> UnsafeIndexV2RangeExpression<Base>
  {
    guard lhs.tied === rhs.tied else { fatalError(.treeMissmatch) }
    return .init(rawValue: lhs.rawValue...rhs.rawValue, tie: lhs.tied)
  }

  @inlinable
  @inline(__always)
  public prefix func ..< <Base>(rhs: UnsafeIndexV2<Base>) -> UnsafeIndexV2RangeExpression<Base> {
    return .init(rawValue: ..<rhs.rawValue, tie: rhs.tied)
  }

  @inlinable
  @inline(__always)
  public prefix func ... <Base>(rhs: UnsafeIndexV2<Base>) -> UnsafeIndexV2RangeExpression<Base> {
    return .init(rawValue: ...rhs.rawValue, tie: rhs.tied)
  }

  @inlinable
  @inline(__always)
  public postfix func ... <Base>(lhs: UnsafeIndexV2<Base>) -> UnsafeIndexV2RangeExpression<Base> {
    return .init(rawValue: lhs.rawValue..., tie: lhs.tied)
  }
#endif

// MARK: -
