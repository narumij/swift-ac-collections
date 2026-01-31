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

public enum UnsafeTreeRangeExpression2: Equatable {
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

extension UnsafeTreeRangeExpression2 {

  func _start<Base>(_ __tree_: UnsafeTreeV2<Base>) -> SafePtr {
    .success(__tree_.__begin_node_)
  }

  func _end<Base>(_ __tree_: UnsafeTreeV2<Base>) -> SafePtr {
    .success(__tree_.__end_node)
  }

  @usableFromInline
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>) -> (SafePtr, SafePtr)
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

public func ..< (lhs: SafePtr, rhs: SafePtr) -> UnsafeTreeRangeExpression2 {
  .range(from: lhs, to: rhs)
}

public func ... (lhs: SafePtr, rhs: SafePtr) -> UnsafeTreeRangeExpression2 {
  .closedRange(from: lhs, through: rhs)
}

public prefix func ..< (rhs: SafePtr) -> UnsafeTreeRangeExpression2 {
  .partialRangeTo(rhs)
}

public prefix func ... (rhs: SafePtr) -> UnsafeTreeRangeExpression2 {
  .partialRangeThrough(rhs)
}

public postfix func ... (lhs: SafePtr) -> UnsafeTreeRangeExpression2 {
  .partialRangeFrom(lhs)
}
