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
      return (lhs.safe, rhs.safe)
    case .closedRange(let lhs, let rhs):
      return (lhs.safe, rhs.safe.flatMap { ___tree_next_iter($0) })
    case .partialRangeTo(let rhs):
      return (_start(__tree_), rhs.safe)
    case .partialRangeThrough(let rhs):
      return (_start(__tree_), rhs.safe.flatMap { ___tree_next_iter($0) })
    case .partialRangeFrom(let lhs):
      return (lhs.safe, _end(__tree_))
    case .unboundedRange:
      return (_start(__tree_), _end(__tree_))
    }
  }
}

extension UnsafeTreeRangeExpression {

  func _start(_ tied: _TiedRawBuffer) -> SafePtr {
    tied.begin_ptr.map { .success($0.pointee) } ?? .failure(.null)
  }

  func _end(_ tied: _TiedRawBuffer) -> SafePtr {
    tied.end_ptr.map { .success($0) } ?? .failure(.null)
  }

  @usableFromInline
  func relative(to tied: _TiedRawBuffer) -> (SafePtr, SafePtr) {
    guard tied.isValueAccessAllowed else {
      return (.failure(.notAllowed), .failure(.notAllowed))
    }
    switch self {
    case .range(let lhs, let rhs):
      return (lhs.safe, rhs.safe)
    case .closedRange(let lhs, let rhs):
      return (lhs.safe, rhs.safe.flatMap { ___tree_next_iter($0) })
    case .partialRangeTo(let rhs):
      return (_start(tied), rhs.safe)
    case .partialRangeThrough(let rhs):
      return (_start(tied), rhs.safe.flatMap { ___tree_next_iter($0) })
    case .partialRangeFrom(let lhs):
      return (lhs.safe, _end(tied))
    case .unboundedRange:
      return (_start(tied), _end(tied))
    }
  }
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
}
