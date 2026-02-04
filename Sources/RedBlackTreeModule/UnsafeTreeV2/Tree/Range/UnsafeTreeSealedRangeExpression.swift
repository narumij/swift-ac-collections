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

public enum UnsafeTreeSealedRangeExpression: Equatable {

  public typealias Bound = _SealedPtr
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

extension UnsafeTreeSealedRangeExpression {

  func _start<Base>(_ __tree_: UnsafeTreeV2<Base>) -> _SealedPtr {
    __tree_.__begin_node_.sealed
  }

  func _end<Base>(_ __tree_: UnsafeTreeV2<Base>) -> _SealedPtr {
    __tree_.__end_node.sealed
  }

  // TODO: FIXME
  // たぶん解決が不足している
  @usableFromInline
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>)
    -> (_from: _SealedPtr, _to: _SealedPtr)
  where
    Base: ___TreeBase
  {
    switch self {
    case .range(let lhs, let rhs):
      return (lhs, rhs)
    case .closedRange(let lhs, let rhs):
      return (lhs, rhs.flatMap { ___tree_next_iter($0.pointer) }.seal)
    case .partialRangeTo(let rhs):
      return (_start(__tree_), rhs)
    case .partialRangeThrough(let rhs):
      return (_start(__tree_), rhs.flatMap { ___tree_next_iter($0.pointer) }.seal)
    case .partialRangeFrom(let lhs):
      return (lhs, _end(__tree_))
    case .unboundedRange:
      return (_start(__tree_), _end(__tree_))
    }
  }
}

extension UnsafeTreeSealedRangeExpression {

  func _start(_ tied: _TiedRawBuffer) -> _SealedPtr {
    tied.begin_ptr.map { success($0.pointee) } ?? .failure(.null)
  }

  func _end(_ tied: _TiedRawBuffer) -> _SealedPtr {
    tied.end_ptr.map { success($0) } ?? .failure(.null)
  }

  // TODO: FIXME
  // たぶん解決が不足している
  @usableFromInline
  func relative(to tied: _TiedRawBuffer) -> (_SealedPtr, _SealedPtr) {
    guard tied.isValueAccessAllowed else {
      return (.failure(.notAllowed), .failure(.notAllowed))
    }
    switch self {
    case .range(let lhs, let rhs):
      return (lhs, rhs)
    case .closedRange(let lhs, let rhs):
      return (lhs, rhs.flatMap { ___tree_next_iter($0.pointer) }.seal)
    case .partialRangeTo(let rhs):
      return (_start(tied), rhs)
    case .partialRangeThrough(let rhs):
      return (_start(tied), rhs.flatMap { ___tree_next_iter($0.pointer) }.seal)
    case .partialRangeFrom(let lhs):
      return (lhs, _end(tied))
    case .unboundedRange:
      return (_start(tied), _end(tied))
    }
  }
}
// MARK: -

public func ..< (lhs: _SealedPtr, rhs: _SealedPtr) -> UnsafeTreeSealedRangeExpression {
  .range(from: lhs, to: rhs)
}

public func ... (lhs: _SealedPtr, rhs: _SealedPtr) -> UnsafeTreeSealedRangeExpression {
  .closedRange(from: lhs, through: rhs)
}

public prefix func ..< (rhs: _SealedPtr) -> UnsafeTreeSealedRangeExpression {
  .partialRangeTo(rhs)
}

public prefix func ... (rhs: _SealedPtr) -> UnsafeTreeSealedRangeExpression {
  .partialRangeThrough(rhs)
}

public postfix func ... (lhs: _SealedPtr) -> UnsafeTreeSealedRangeExpression {
  .partialRangeFrom(lhs)
}

// MARK: -

public func ..< (lhs: UnsafeMutablePointer<UnsafeNode>, rhs: UnsafeMutablePointer<UnsafeNode>)
  -> UnsafeTreeSealedRangeExpression
{
  .range(from: lhs.sealed, to: rhs.sealed)
}

public func ... (lhs: UnsafeMutablePointer<UnsafeNode>, rhs: UnsafeMutablePointer<UnsafeNode>)
  -> UnsafeTreeSealedRangeExpression
{
  .closedRange(from: lhs.sealed, through: rhs.sealed)
}

public prefix func ..< (rhs: UnsafeMutablePointer<UnsafeNode>)
  -> UnsafeTreeSealedRangeExpression
{
  .partialRangeTo(rhs.sealed)
}

public prefix func ... (rhs: UnsafeMutablePointer<UnsafeNode>)
  -> UnsafeTreeSealedRangeExpression
{
  .partialRangeThrough(rhs.sealed)
}

public postfix func ... (lhs: UnsafeMutablePointer<UnsafeNode>)
  -> UnsafeTreeSealedRangeExpression
{
  .partialRangeFrom(lhs.sealed)
}

// MARK: -

@inlinable @inline(__always)
func unwrapLowerUpperOrFatal(_ bounds: (_SealedPtr, _SealedPtr))
  -> (UnsafeMutablePointer<UnsafeNode>, UnsafeMutablePointer<UnsafeNode>)
{
  switch bounds {
  case (.success(let l), .success(let u)):
    return (l.pointer, u.pointer)

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
func unwrapLowerUpper(_ bounds: (_SealedPtr, _SealedPtr))
  -> (UnsafeMutablePointer<UnsafeNode>, UnsafeMutablePointer<UnsafeNode>)?
{
  switch bounds {
  case (.success(let l), .success(let u)):
    return (l.pointer, u.pointer)
  default:
    return nil
  }
}
