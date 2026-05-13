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
  _BaseNode_PtrCompProtocol_new
{}

public protocol _BaseNode_PtrCompProtocol_new:
  _BaseNode_PtrCompInterface
    & _BaseNode_PtrRangeCompInterface
    & _Base_TraitHelperInterface
where _TraitHelper: _UnsafeNodePtrType {}

extension _BaseNode_PtrCompProtocol_new {

  @inlinable
  public static func ___ptr_comp(_ l: _NodePtr, _ r: _NodePtr) -> Bool {
    _TraitHelper.___ptr_comp(l, r)
  }

  @inlinable
  public static func ___ptr_range_comp(_ __f: _NodePtr, _ __p: _NodePtr, _ __l: _NodePtr) -> Bool {
    _TraitHelper.___ptr_range_comp(__f, __p, __l)
  }
}

public protocol _BaseNode_PtrCompProtocol_old:
  _BaseNode_PtrCompInterface
    & _BaseComparableNode_PtrUniqueCompProtocol
    & _Base_IsMultiTraitInterface
{}

extension _BaseNode_PtrCompProtocol_old {

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

public protocol _BaseNode_PtrRangeCompInterface: _NodePtrType {
  static func ___ptr_range_comp(_ __f: _NodePtr, _ __p: _NodePtr, _ __l: _NodePtr) -> Bool
}

public protocol _BaseNode_PtrRangeCompProtocol:
  _BaseNode_PtrRangeCompInterface
    & _BaseNode_PtrCompInterface
    & _BaseNode_PtrUniqueCompInterface
    & _Base_IsMultiTraitInterface
{}

extension _BaseNode_PtrRangeCompProtocol {

  /// ptrのrange判定
  @inlinable
  @inline(__always)
  public static func ___ptr_range_comp(_ __f: _NodePtr, _ __p: _NodePtr, _ __l: _NodePtr) -> Bool {

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
///
/// 資料的に残されている
/// 実際には特殊化されたものをつかっている
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

/// Index用のメソッド中継
///
/// Comparable特殊化のもの
public protocol _BaseComparableNode_PtrUniqueCompProtocol:
  _BaseNode_PtrUniqueCompInterface
    & _BaseKey_LessThanInterface
    & _BaseNode_KeyInterface
where _Key: Comparable {}

extension _BaseComparableNode_PtrUniqueCompProtocol {

  @inlinable @inline(__always)
  public static func ___ptr_comp_unique(_ l: _NodePtr, _ r: _NodePtr) -> Bool {
    assert(!l.___is_null, "Node shouldn't be null")
    assert(!l.___is_end, "Node shouldn't be end")
    assert(!r.___is_null, "Node shouldn't be null")
    assert(!r.___is_end, "Node shouldn't be end")
    return __get_value(l) < __get_value(r)
  }
}

public struct __UniqueTrait<Base>: TraitHelper, _UnsafeNodePtrType
where Base: _UnsafeNodePtrType & _BaseNode_KeyInterface, Base._Key: Comparable {

  @inlinable
  public static func ___ptr_comp_unique(_ l: _NodePtr, _ r: _NodePtr) -> Bool {
    return Base.__get_value(l) < Base.__get_value(r)
  }

  @inlinable
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

    return ___ptr_comp_unique(l, r)
  }

  /// ptrのrange判定
  @inlinable
  public static func ___ptr_range_comp(_ __f: _NodePtr, _ __p: _NodePtr, _ __l: _NodePtr) -> Bool {

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

    // __f <= __p && __p <= __l
    return !___ptr_comp_unique(__p, __f) && !___ptr_comp_unique(__l, __p)
  }
}

public struct __MultiTrait<Base>: TraitHelper, _UnsafeNodePtrType
where Base: _UnsafeNodePtrType & _BaseNode_KeyInterface, Base._Key: Comparable {

  @inlinable
  public static func ___ptr_comp_unique(_ l: _NodePtr, _ r: _NodePtr) -> Bool {
    return Base.__get_value(l) < Base.__get_value(r)
  }

  @inlinable
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

    #if true

      // ポインタ化によりこちらのほうが速くなった
      return ___ptr_comp_unique(l, r) || (!___ptr_comp_unique(r, l) && ___ptr_comp_multi(l, r))

    #else

      return ___ptr_comp_unique(l, r) || (!___ptr_comp_unique(r, l) && ___ptr_comp_bitmap(l, r))

    #endif
  }

  /// ptrのrange判定
  @inlinable
  public static func ___ptr_range_comp(_ __f: _NodePtr, _ __p: _NodePtr, _ __l: _NodePtr) -> Bool {

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

    let (f, p, l) = (
      __f.___ptr_bitmap_128(),
      __p.___ptr_bitmap_128(),
      __l.___ptr_bitmap_128()
    )

    // __f <= __p && __p <= __l
    return f <= p && p <= l
  }
}
