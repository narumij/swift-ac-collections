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

public protocol _BaseNode_NodeCompareProtocol:
  _BaseNode_PtrUniqueCompInterface
    & _BaseNode_PtrCompProtocol
    & _BaseNode_SignedDistanceProtocol
{}

public protocol _BaseNode_PtrCompProtocol:
  _BaseNode_PtrCompInterface
    & _BaseNode_PtrUniqueCompInterface
    & _Base_IsMultiTraitInterface
{}

extension _BaseNode_PtrCompProtocol {

  @inlinable @inline(__always)
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

      #if true

        // ポインタ化によりこちらのほうが速くなった
        return ___ptr_comp_unique(l, r) || (!___ptr_comp_unique(r, l) && ___ptr_comp_multi(l, r))

      #else

        return ___ptr_comp_unique(l, r) || (!___ptr_comp_unique(r, l) && ___ptr_comp_bitmap(l, r))

      #endif
    }
    return ___ptr_comp_unique(l, r)
  }
}

public protocol _BaseNode_PtrRangeCompProtocol:
  _BaseNode_PtrCompInterface
    & _BaseNode_PtrUniqueCompInterface
    & _Base_IsMultiTraitInterface
{}

extension _BaseNode_PtrRangeCompProtocol {

  /// ptrのrange判定
  @inlinable
  @inline(__always)
  static func ___ptr_range_comp(_ __f: _NodePtr, _ __p: _NodePtr, _ __l: _NodePtr) -> Bool {

    assert(!__f.___is_null)
    assert(!__p.___is_null)
    assert(!__l.___is_null)
    assert(!__f.___is_garbaged)
    assert(!__p.___is_garbaged)
    assert(!__l.___is_garbaged)

    guard !__f.___is_end else {
      // end <= end <= endは有効
      return __p.___is_end && __l.___is_end
    }

    guard !__l.___is_end else {

      // __f <= __p
      return !___ptr_comp(__p, __f)
    }

    if isMulti {
      let (f, p, l) = (
        __f.___ptr_bitmap_128(),
        __p.___ptr_bitmap_128(),
        __l.___ptr_bitmap_128()
      )

      // __f <= __p && __p <= __l
      return f <= p && p <= l
    }

    // __f <= __p && __p <= __l
    return !___ptr_comp_unique(__p, __f) && !___ptr_comp_unique(__l, __p)
  }
}

/// Index用のメソッド中継
public protocol _BaseNode_PtrUniqueCompProtocol:
  _BaseNode_PtrUniqueCompInterface
    & _BaseKey_LessThanInterface
    & _BaseNode_KeyInterface
{}

extension _BaseNode_PtrUniqueCompProtocol {

  @inlinable @inline(__always)
  public static func ___ptr_comp_unique(_ l: _NodePtr, _ r: _NodePtr) -> Bool {
    assert(!l.___is_null, "Node shouldn't be null")
    assert(!l.___is_end, "Node shouldn't be end")
    assert(!r.___is_null, "Node shouldn't be null")
    assert(!r.___is_end, "Node shouldn't be end")
    return value_comp(__get_value(l), __get_value(r))
  }
}

public protocol _BaseComparableNode_PtrUniqueCompProtocol:
  _BaseNode_PtrUniqueCompInterface
    & _BaseKey_LessThanInterface
    & _BaseNode_KeyInterface
where _Key: Comparable
{}

extension _BaseComparableNode_PtrUniqueCompProtocol {

  @inlinable @inline(__always)
  public static func ___ptr_comp_unique(_ l: _NodePtr, _ r: _NodePtr) -> Bool {
    return __get_value(l) < __get_value(r)
  }
}
