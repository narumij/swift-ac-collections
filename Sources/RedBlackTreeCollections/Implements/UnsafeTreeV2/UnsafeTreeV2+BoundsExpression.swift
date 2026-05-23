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

extension RedBlackTreeBoundExpressionV1 {

  // _SafePtrで十分なんじゃないか？？
  @inlinable
  func evaluate<Base>(_ __tree_: UnsafeTreeV2<Base>)
    -> _SealedPtr
  where
    Base: ___TreeBase,
    Base._Key == _Key
  {

    switch self {

    case .start:
      return __tree_.__begin_node_.sealed

    case .last:
      return RedBlackTreeBoundExpressionV1
        .end
        .before
        .evaluate(__tree_)

    case .end:
      return __tree_.__end_node.sealed

    case .lowerBound(let __v):
      return __tree_.lower_bound(__v).sealed

    case .upperBound(let __v):
      return __tree_.upper_bound(__v).sealed

    case .find(let __v):
      return __tree_.find(__v).sealed

    case .advanced(let __self, let offset, let limit):
      let __p = __self.evaluate(__tree_)
      let limit = limit?.evaluate(__tree_)
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
        RedBlackTreeBoundExpressionV1
        .advanced(__self, offset: -1)
        .evaluate(__tree_)

    case .after(let __self):
      return
        RedBlackTreeBoundExpressionV1
        .advanced(__self, offset: 1)
        .evaluate(__tree_)

    case .lessThan(let __v):
      return ___tree_prev_iter(__tree_.lower_bound(__v)).sealed

    case .greaterThan(let __v):
      return __tree_.upper_bound(__v).sealed

    case .lessThanOrEqual(let __v):
      let __f = __tree_.find(__v).sealed
      return __f.exists ? __f : ___tree_prev_iter(__tree_.lower_bound(__v)).sealed

    case .greaterThanOrEqual(let __v):
      let __f = __tree_.find(__v).sealed
      return __f.exists ? __f : __tree_.upper_bound(__v).sealed

    #if DEBUG
      case .debug(let e):
        return .failure(e)
    #endif
    }
  }

  @inlinable
  func _evaluate<Base>(_ __tree_: UnsafeTreeV2<Base>)
    -> _SafePtr
  where
    Base: ___TreeBase,
    Base._Key == _Key
  {

    switch self {

    case .start:
      return __tree_.__begin_node_.safe

    case .last:
      return RedBlackTreeBoundExpressionV1
        .end
        .before
        ._evaluate(__tree_)

    case .end:
      return __tree_.__end_node.safe

    case .lowerBound(let __v):
      return __tree_.lower_bound(__v).safe

    case .upperBound(let __v):
      return __tree_.upper_bound(__v).safe

    case .find(let __v):
      return __tree_.find(__v).safe

    case .advanced(let __self, let offset, let limit):
      let __p = __self._evaluate(__tree_)
      let limit = limit?._evaluate(__tree_)
      switch limit {
      case .none:
        return __p.flatMap {
          ___tree_adv_iter($0, offset)
        }
      case .some(let __l):
        let __r = __p.flatMap {
          ___tree_adv_iter($0, offset, __l)
        }
        return switch __r {
        case .failure(.limit): __l
        default: __r
        }
      }

    case .before(let __self):
      return
        RedBlackTreeBoundExpressionV1
        .advanced(__self, offset: -1)
        ._evaluate(__tree_)

    case .after(let __self):
      return
        RedBlackTreeBoundExpressionV1
        .advanced(__self, offset: 1)
        ._evaluate(__tree_)

    case .lessThan(let __v):
      return ___tree_prev_iter(__tree_.lower_bound(__v))

    case .greaterThan(let __v):
      return __tree_.upper_bound(__v).safe

    case .lessThanOrEqual(let __v):
      let __f = __tree_.find(__v).safe
      return __f.exists ? __f : ___tree_prev_iter(__tree_.lower_bound(__v))

    case .greaterThanOrEqual(let __v):
      let __f = __tree_.find(__v).safe
      return __f.exists ? __f : __tree_.upper_bound(__v).safe

    #if DEBUG
      case .debug(let e):
        return .failure(e)
    #endif
    }
  }
}

extension UnsafeTreeV2 {
 
  @inlinable
  func _evaluate(_ _internal: RedBlackTreeBoundExpressionV2<_Key>.Internal)
    -> _SafePtr
  {
    var ptr = _SafePtr.failure(.null)

    for i in _internal.indices {
      switch _internal[i] {
        
      case .pointer(let p):
        ptr = p
        
      case .start:
        ptr = __begin_node_.safe
        
      case .last:
        ptr = _evaluate([.end, .before])
        
      case .end:
        ptr = __end_node.safe
        
      case .lowerBound(let __v):
        ptr = lower_bound(__v).safe
        
      case .upperBound(let __v):
        ptr = upper_bound(__v).safe
        
      case .find(let __v):
        ptr = find(__v).safe
        
      case .advanced(let offset, let limit):
//        let limit = limit.map {
//          _evaluate($0)
//        }
        switch limit {
        case .none:
          ptr = ptr.flatMap {
            ___tree_adv_iter($0, offset)
          }
        case .some(let __l):
          let l = _evaluate(__l)
          let __r = ptr.flatMap {
            ___tree_adv_iter($0, offset, l)
          }
          ptr = switch __r {
          case .failure(.limit): l
          default: __r
          }
        }
        
      case .before:
        ptr = _evaluate([.pointer(ptr), .advanced(offset: -1)])
        
      case .after:
        ptr = _evaluate([.pointer(ptr), .advanced(offset: 1)])
        
      case .lessThan(let __v):
        ptr = ___tree_prev_iter(lower_bound(__v))
        
      case .greaterThan(let __v):
        ptr = upper_bound(__v).safe
        
      case .lessThanOrEqual(let __v):
        let __f = find(__v).safe
        ptr = __f.exists ? __f : ___tree_prev_iter(lower_bound(__v))
        
      case .greaterThanOrEqual(let __v):
        let __f = find(__v).safe
        ptr = __f.exists ? __f : upper_bound(__v).safe
        
#if DEBUG
      case .debug(let e):
        return .failure(e)
#endif
      }
    }
    return ptr
  }
}

extension RedBlackTreeBoundExpressionV2 {
  
  @inlinable
  func _evaluate<Base>(_ __tree_: UnsafeTreeV2<Base>)
    -> _SafePtr
  where
    Base: ___TreeBase,
    Base._Key == _Key
  {
    return __tree_._evaluate(_internal)
  }
  
  @inlinable
  func evaluate<Base>(_ __tree_: UnsafeTreeV2<Base>)
    -> _SealedPtr
  where
    Base: ___TreeBase,
    Base._Key == _Key
  {
    return __tree_._evaluate(_internal).sealed
  }
}

extension RedBlackTreeBoundRangeExpression {

  // _SafePtrで十分なんじゃないか？？
  @inlinable
  func evaluate<Base>(_ __tree_: UnsafeTreeV2<Base>)
    -> _RawRangeExpression<_SealedPtr>
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
        from: lower.sealed,
        to: upper.sealed)
    }
  }

  #if true
  @inlinable
  func _evaluate<Base>(_ __tree_: UnsafeTreeV2<Base>)
    -> _RawRangeExpression<_SafePtr>
  where
    Base: ___TreeBase,
    Base._Key == _Key
  {
    switch self {

    case .range(let from, let to):
      return .range(
        from: from._evaluate(__tree_),
        to: to._evaluate(__tree_))

    case .closedRange(let from, let through):
      return .closedRange(
        from: from._evaluate(__tree_),
        through: through._evaluate(__tree_))

    case .partialRangeTo(let to):
      return .partialRangeTo(to._evaluate(__tree_))

    case .partialRangeThrough(let through):
      return .partialRangeThrough(through._evaluate(__tree_))

    case .partialRangeFrom(let from):
      return .partialRangeFrom(from._evaluate(__tree_))

    case .equalRange(let __v):
      let (lower, upper) =
        __tree_.isMulti
        ? __tree_.__equal_range_multi(__v)
        : __tree_.__equal_range_unique(__v)

      return .range(
        from: lower.safe,
        to: upper.safe)
    }
  }
  #endif
}
