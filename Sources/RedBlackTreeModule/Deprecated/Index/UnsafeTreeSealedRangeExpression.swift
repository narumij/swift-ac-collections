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

/// 内部Range
///
/// ポインタ付き
///
public typealias UnsafeTreeSealedRangeExpression = _RawRangeExpression<_SealedPtr>

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
