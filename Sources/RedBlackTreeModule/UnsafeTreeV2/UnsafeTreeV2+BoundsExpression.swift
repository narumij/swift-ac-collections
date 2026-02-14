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

import Foundation

extension RedBlackTreeBoundExpression {

  @inlinable @inline(__always)
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>)
    -> _SealedPtr
  where
    Base: ___TreeBase,
    Base._Key == _Key
  {

    switch self {

    case .start:
      return __tree_.__begin_node_.sealed

    case .last:
      return RedBlackTreeBoundExpression
        .end
        .before
        .relative(to: __tree_)

    case .end:
      return __tree_.__end_node.sealed

    case .lower(let __v):
      return __tree_.lower_bound(__v).sealed

    case .upper(let __v):
      return __tree_.upper_bound(__v).sealed

    case .find(let __v):
      return __tree_.find(__v).sealed

    case .advanced(let __self, offset: let offset, let limit):
      let __p = __self.relative(to: __tree_)
      let limit = limit?.relative(to: __tree_)
      switch limit {
      case .none:
        return __p.flatMap {
          ___tree_adv_iter($0.pointer, offset)
        }
        .sealed
      case .some(let __l):
        let __r = __p.flatMap {
          ___tree_adv_iter($0.pointer, offset, __l.temporaryUnseal)
        }
        .sealed
        return switch __r {
        case .failure(.limit): __l
        default: __r
        }
      }

    case .before(let __self):
      return
        RedBlackTreeBoundExpression
        .advanced(__self, offset: -1)
        .relative(to: __tree_)

    case .after(let __self):
      return
        RedBlackTreeBoundExpression
        .advanced(__self, offset: 1)
        .relative(to: __tree_)
      
    case .lessThan(let __v):
      return ___tree_prev_iter(__tree_.lower_bound(__v)).sealed
      
    case .greaterThen(let __v):
      return __tree_.upper_bound(__v).sealed
      
    case .lessThanOrEqual(let __v):
      let __f = __tree_.find(__v).sealed
      return __f.exists ? __f : ___tree_prev_iter(__tree_.lower_bound(__v)).sealed
      
    case .greaterThenOrEqual(let __v):
      let __f = __tree_.find(__v).sealed
      return __f.exists ? __f : __tree_.upper_bound(__v).sealed

    #if DEBUG
      case .debug(let e):
        return .failure(e)
    #endif
    }
  }
}

extension RedBlackTreeBoundRangeExpression {

  @inlinable @inline(__always)
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>)
    -> UnsafeTreeSealedRangeExpression
  where
    Base: ___TreeBase,
    Base._Key == _Key
  {
    switch self {

    case .range(let from, let to):
      return .range(
        from: from.relative(to: __tree_),
        to: to.relative(to: __tree_))

    case .closedRange(let from, let through):
      return .closedRange(
        from: from.relative(to: __tree_),
        through: through.relative(to: __tree_))

    case .partialRangeTo(let to):
      return .partialRangeTo(to.relative(to: __tree_))

    case .partialRangeThrough(let through):
      return .partialRangeThrough(through.relative(to: __tree_))

    case .partialRangeFrom(let from):
      return .partialRangeFrom(from.relative(to: __tree_))

    case .equalRange(let __v):
      let (lower, upper) =
        __tree_.isMulti
        ? __tree_.__equal_range_multi(__v)
        : __tree_.__equal_range_unique(__v)

      return .range(
        from: lower.sealed,
        to: upper.sealed)
    }
  }

  @usableFromInline
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>)
    -> (
      _SealedPtr,
      _SealedPtr
    )
  where
    Base: ___TreeBase,
    Base._Key == _Key
  {
    relative(to: __tree_).relative(to: __tree_)
  }
}
