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

extension RedBlackTreeBound {

  @inlinable @inline(__always)
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>)
    -> UnsafeMutablePointer<UnsafeNode>
  where
    Base: ___TreeBase,
    Base._Key == _Key
  {

    switch self {

    case .start:
      return __tree_.__begin_node_

    case .end:
      return __tree_.__end_node

    case .lower(let __v):
      return __tree_.lower_bound(__v)

    case .upper(let __v):
      return __tree_.upper_bound(__v)

    case .find(let __v):
      return __tree_.find(__v)

    case .advanced(let __self, by: let offset, limit: let __limit):
      let __p = __self.relative(to: __tree_)
      guard !__p.___is_null else {
        fatalError(.invalidIndex)
      }
      if let __limit {
        let __l = __limit.relative(to: __tree_)
        return ___tree_adv_iter(__p, offset, __l)
      }
      // 初期状態でnullが来る可能性はほぼないが、念のためにfatal
      return ___tree_adv_iter(__p, offset)

    case .prev(let __self):
      return
        RedBlackTreeBound
        .advanced(__self, by: -1)
        .relative(to: __tree_)

    case .next(let __self):
      return
        RedBlackTreeBound
        .advanced(__self, by: 1)
        .relative(to: __tree_)

    }
  }
}

extension RedBlackTreeBoundsExpression {

  @inlinable @inline(__always)
  func _relative<Base>(to __tree_: UnsafeTreeV2<Base>) -> UnsafeTreeRangeExpression
  where
    Base: ___TreeBase,
    Base._Key == _Key
  {
    switch self {

    case .range(let lhs, let rhs):
      return .range(
        from: lhs.relative(to: __tree_),
        to: rhs.relative(to: __tree_))

    case .closedRange(let lhs, let rhs):
      return .closedRange(
        from: lhs.relative(to: __tree_),
        through: rhs.relative(to: __tree_))

    case .partialRangeTo(let rhs):
      return .partialRangeTo(rhs.relative(to: __tree_))

    case .partialRangeThrough(let rhs):
      return .partialRangeThrough(rhs.relative(to: __tree_))

    case .partialRangeFrom(let lhs):
      return .partialRangeFrom(lhs.relative(to: __tree_))

    case .equalRange(let __v):
      let (lower, upper) =
        __tree_.isMulti ? __tree_.__equal_range_multi(__v) : __tree_.__equal_range_unique(__v)
      return .range(from: lower, to: upper)
    }
  }

  @inlinable @inline(__always)
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>)
    -> (
      UnsafeMutablePointer<UnsafeNode>,
      UnsafeMutablePointer<UnsafeNode>
    )
  where
    Base: ___TreeBase,
    Base._Key == _Key
  {
    _relative(to: __tree_)
      .relative(to: __tree_)
  }
}
