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

public protocol _BaseNode_PtrCompProtocol:
  _UnsafeNodePtrType
    & _BaseNode_PtrUniqueCompInterface
    & _BaseNode_PtrCompInterface
    & _Base_IsMultiTraitInterface
{}

extension _BaseNode_PtrCompProtocol {

  @inlinable
  @inline(__always)
  public static func ___ptr_comp(_ l: _NodePtr, _ r: _NodePtr) -> Bool {
    assert(l.___is_end || !l.__parent_.___is_null)
    assert(r.___is_end || !r.__parent_.___is_null)

    guard
      l != r,
      !r.___is_end,
      !l.___is_end
    else {
      return !l.___is_end && r.___is_end
    }

    if isMulti {

      // TODO: ポインタ版になったので再度はかりなおすこと

      #if true
        //      name                         time             std         iterations
        //      --------------------------------------------------------------------
        //      index compare 1000        19416.000 ns ±  10.13 %       69751
        //      index compare 1000000 109517708.000 ns ±   2.03 %          13

        return ___ptr_comp_unique(l, r) || (!___ptr_comp_unique(r, l) && ___ptr_comp_multi(l, r))

      #else
        //      name                         time             std         iterations
        //      --------------------------------------------------------------------
        //      index compare 1000        11917.000 ns ±   8.25 %     114822
        //      index compare 1000000  54229021.000 ns ±   3.62 %         24

        return ___ptr_comp_unique(l, r) || (!___ptr_comp_unique(r, l) && ___ptr_comp_bitmap(l, r))

      #endif
    }
    return ___ptr_comp_unique(l, r)
  }
}

/// Index用のメソッド中継
public protocol _BaseNode_PtrUniqueCompProtocol:
  _BaseNode_PtrUniqueCompInterface
    & _BaseKey_LessThanInterface
    & _BaseNode_KeyProtocol
{}

extension _BaseNode_PtrUniqueCompProtocol {

  public static func ___ptr_comp_unique(_ l: _NodePtr, _ r: _NodePtr) -> Bool {
    assert(!l.___is_null, "Node shouldn't be null")
    assert(!l.___is_end, "Node shouldn't be end")
    assert(!r.___is_null, "Node shouldn't be null")
    assert(!r.___is_end, "Node shouldn't be end")
    return value_comp(__get_value(l), __get_value(r))
  }
}

extension _BaseNode_PtrCompProtocol {

  @usableFromInline
  typealias difference_type = Int

  @usableFromInline
  typealias _InputIter = _NodePtr

  @inlinable
  @inline(__always)
  static func
    ___signed_distance(_ __first: _InputIter, _ __last: _InputIter) -> difference_type
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
}
