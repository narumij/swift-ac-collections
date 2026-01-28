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
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>) -> UnsafeMutablePointer<UnsafeNode>
  where Base: ___TreeBase, Base._Key == _Key {
    switch self {

    case .start:
      return __tree_.__begin_node_

    case .end:
      return __tree_.__end_node

    case .lower(let l):
      return __tree_.lower_bound(l)

    case .upper(let r):
      return __tree_.upper_bound(r)

    case .advanced(let __self, by: var offset):
      var __p = __self.relative(to: __tree_)
      // 初期状態でnullが来る可能性はほぼないが、念のためにfatal
      guard !__p.___is_null else {
        fatalError(.invalidIndex)
      }
      while offset != 0 {
        if offset < 0 {
          let _prev = __tree_prev_iter(__p)
          // nullの場合更新せずにループ終了
          guard !_prev.___is_null else { break }
          __p = _prev
          offset += 1
        } else {
          // endの場合次への操作をせずにループ終了
          guard !__p.___is_end else { break }
          __p = __tree_next_iter(__p)
          offset -= 1
        }
      }
      return __p

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
  where Base: ___TreeBase, Base._Key == _Key {
    switch self {
    case .range(let lhs, let rhs):
      .range(
        from: lhs.relative(to: __tree_),
        to: rhs.relative(to: __tree_))
    case .closedRange(let lhs, let rhs):
      .closedRange(
        from: lhs.relative(to: __tree_),
        through: rhs.relative(to: __tree_))
    case .partialRangeTo(let rhs):
      .partialRangeTo(rhs.relative(to: __tree_))
    case .partialRangeThrough(let rhs):
      .partialRangeThrough(rhs.relative(to: __tree_))
    case .partialRangeFrom(let lhs):
      .partialRangeFrom(lhs.relative(to: __tree_))
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
