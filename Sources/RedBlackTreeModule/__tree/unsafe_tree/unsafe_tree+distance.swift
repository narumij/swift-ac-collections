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

// 関数での実装もある。nullptrアクセスコストの問題はないので、気が向いたらこちらを削除していく

@usableFromInline
protocol DistanceProtocol_ptr: _UnsafeNodePtrType & _TreeNode_PtrCompInterface {}

extension DistanceProtocol_ptr {

  @usableFromInline
  typealias difference_type = Int

  @usableFromInline
  typealias _InputIter = _NodePtr

#if false
  @inlinable
  @inline(__always)
  internal func
    __distance(_ __first: _InputIter, _ __last: _InputIter) -> difference_type
  {
    var __first = __first
    var __r = 0
    while __first != __last {
      __first = __tree_next(__first)
      __r += 1
    }
    return __r
  }

  @inlinable
  @inline(__always)
  internal func
    ___dual_distance(_ __first: _InputIter, _ __last: _InputIter) -> difference_type
  {
    var __next = __first
    var __prev = __first
    var __r = 0
    while __next != __last, __prev != __last {
      __next = __next.___is_null ? __next : __tree_next(__next)
      __prev = __prev.___is_null ? __prev : __tree_prev_iter(__prev)
      __r += 1
    }
    return __next == __last ? __r : -__r
  }

  @inlinable
  @inline(__always)
  internal func
    ___comp_distance(_ __first: _InputIter, _ __last: _InputIter) -> difference_type
  {
    guard __first != __last else { return 0 }
    var (__first, __last) = (__first, __last)
    var sign = 1
    if ___ptr_comp(__last, __first) {
      swap(&__first, &__last)
      sign = -1
    }
    return sign * __distance(__first, __last)
  }

  @inlinable
  @inline(__always)
  internal func
    ___signed_distance(_ __first: _InputIter, _ __last: _InputIter) -> difference_type
  {
    #if true
      return ___comp_distance(__first, __last)
    #else
      return ___dual_distance(__first, __last)
    #endif
  }
#endif
}

#if false
extension RedBlackTreeSet {

  public func ___comp_distance(start: Index, end: Index) -> Int {
    __tree_.___comp_distance(__tree_.rawValue(start), __tree_.rawValue(end))
  }

  public func ___dual_distance(start: Index, end: Index) -> Int {
    __tree_.___dual_distance(__tree_.rawValue(start), __tree_.rawValue(end))
  }
  
  public func ___comp_mult(start: Index, end: Index) -> Bool {
    ___ptr_comp_multi_org(__tree_.rawValue(start), __tree_.rawValue(end))
  }
  
  public func ___comp_mult2(start: Index, end: Index) -> Bool {
    ___ptr_comp_multi(__tree_.rawValue(start), __tree_.rawValue(end))
  }

  public func ___comp_bitmap(start: Index, end: Index) -> Bool {
    ___ptr_comp_bitmap(__tree_.rawValue(start), __tree_.rawValue(end))
  }
}
#endif
