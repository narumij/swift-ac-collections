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
  internal var range: _RawRangeExpression<_TieWrappedPtr>

  @inlinable
  @inline(__always)
  internal init(_ range: _RawRangeExpression<_TieWrappedPtr>) {
    self.range = range
  }
}

// 削除の悩みがつきまとうので、Sequence適合せず、ループはできないようにする

extension UnsafeIndexV3RangeExpression {

  @usableFromInline
  func _relative<Base: ___TreeBase>(to __tree_: UnsafeTreeV2<Base>) -> _RawRange<_TieWrappedPtr> {
    // CoW対応があるので、同一木制限はできない
    return range.relative(to: __tree_)
  }

//  @usableFromInline
//  func relative<Base: ___TreeBase>(to __tree_: UnsafeTreeV2<Base>) -> (_SealedPtr, _SealedPtr) {
//    // CoW対応があるので、同一木制限はできない
//    let r = __tree_.__purified_(range.relative(to: __tree_))
//    return (r.lowerBound, r.upperBound)
//  }
}

// MARK: - Range Expression

@inlinable
@inline(__always)
public func ..< (lhs: UnsafeIndexV3, rhs: UnsafeIndexV3)
  -> UnsafeIndexV3RangeExpression
{
  guard lhs.tied === rhs.tied else { fatalError(.treeMissmatch) }
  return .init(.range(from: lhs, to: rhs))
}

@inlinable
@inline(__always)
public func ... (lhs: UnsafeIndexV3, rhs: UnsafeIndexV3)
  -> UnsafeIndexV3RangeExpression
{
  guard lhs.tied === rhs.tied else { fatalError(.treeMissmatch) }
  return .init(.closedRange(from: lhs, through: rhs))
}

@inlinable
@inline(__always)
public prefix func ..< (rhs: UnsafeIndexV3) -> UnsafeIndexV3RangeExpression {
  return .init(.partialRangeTo(rhs))
}

@inlinable
@inline(__always)
public prefix func ... (rhs: UnsafeIndexV3) -> UnsafeIndexV3RangeExpression {
  return .init(.partialRangeThrough(rhs))
}

@inlinable
@inline(__always)
public postfix func ... (lhs: UnsafeIndexV3) -> UnsafeIndexV3RangeExpression {
  return .init(.partialRangeFrom(lhs))
}

// MARK: -

