//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project.
//
// Copyright (c) 2024-2026 narumij.
// Licensed under the Apache License v2.0.
//
// SPDX-License-Identifier: Apache-2.0
//
// This implementation includes code derived from LLVM libc++'s red-black tree
// implementation, originally distributed under the Apache License v2.0 with
// LLVM Exceptions.
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by
// narumij.
//
//===----------------------------------------------------------------------===//

extension UnsafeTreeV2 {

  @inlinable
  func evaluate(_ _internal: RedBlackTreeBoundExpressionV2<_Key>.Internal)
    -> _SafePtr
  {
    _internal.withUnsafeBufferPointer { buffer in

      let _internal = buffer.baseAddress!

      var ptr = _SafePtr.failure(.null)

      for i in 0..<buffer.count {
        switch _internal[i] {

        case .index(let i):
          switch __purified_(i) {
          case .success(let s):
            ptr = s.pointer.unchecked
          case .failure:
            ptr = .failure(.null)
          }

        case .start:
          ptr = __begin_node_.unchecked

        case .last:
          ptr = ___tree_prev_iter(__end_node)

        case .end:
          ptr = __end_node.unchecked

        case .lowerBound(let __v):
          ptr = lower_bound(__v).unchecked

        case .upperBound(let __v):
          ptr = upper_bound(__v).unchecked

        case .find(let __v):
          ptr = find(__v).unchecked

        case .advanced(let offset, let limit):
          switch limit {
          case .none:
            ptr = ptr.flatMap {
              ___tree_adv_iter($0, offset)
            }
          case .some(let __l):
            let l = evaluate(__l)
            let __r = ptr.flatMap {
              ___tree_adv_iter($0, offset, l)
            }
            ptr =
              switch __r {
              case .failure(.limit): l
              default: __r
              }
          }

        case .before:
          ptr = ptr.flatMap { ___tree_adv_iter($0, -1) }

        case .after:
          ptr = ptr.flatMap { ___tree_adv_iter($0, 1) }

        case .lessThan(let __v):
          ptr = ___tree_prev_iter(lower_bound(__v))

        case .greaterThan(let __v):
          ptr = upper_bound(__v).unchecked

        case .lessThanOrEqual(let __v):
          let __f = find(__v).unchecked
          ptr = __f.___has_payload_content ? __f : ___tree_prev_iter(lower_bound(__v))

        case .greaterThanOrEqual(let __v):
          let __f = find(__v).unchecked
          ptr = __f.___has_payload_content ? __f : upper_bound(__v).unchecked

        #if DEBUG
          case .debug(let e):
            return .failure(e)
        #endif
        }
      }
      return ptr
    }
  }
}

extension RedBlackTreeBoundExpressionV2 {

  @inlinable
  func evaluate<Base>(_ __tree_: UnsafeTreeV2<Base>)
    -> _SafePtr
  where
    Base: ___TreeBase,
    Base._Key == _Key
  {
    return __tree_.evaluate(_internal)
  }
}

extension RedBlackTreeBoundRangeExpression {

  @inlinable
  func evaluate<Base>(_ __tree_: UnsafeTreeV2<Base>)
    -> _RawRangeExpression<_SafePtr>
  where
    Base: ___TreeBase,
    Base._Key == _Key
  {
    switch self {

    case .range(let from, let to):
      return .range(
        from: from.evaluate(__tree_),
        to: to.evaluate(__tree_))

    case .closedRange(let from, let through):
      return .closedRange(
        from: from.evaluate(__tree_),
        through: through.evaluate(__tree_))

    case .partialRangeTo(let to):
      return .partialRangeTo(to.evaluate(__tree_))

    case .partialRangeThrough(let through):
      return .partialRangeThrough(through.evaluate(__tree_))

    case .partialRangeFrom(let from):
      return .partialRangeFrom(from.evaluate(__tree_))

    case .equalRange(let __v):
      let (lower, upper) =
        __tree_.isMulti
        ? __tree_.__equal_range_multi(__v)
        : __tree_.__equal_range_unique(__v)

      return .range(
        from: lower.unchecked,
        to: upper.unchecked)
    }
  }
}
