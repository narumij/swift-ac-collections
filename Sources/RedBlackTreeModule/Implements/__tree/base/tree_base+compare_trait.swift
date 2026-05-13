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

//@available(*, deprecated)
//public protocol CompareUniqueTrait: _Base_IsMultiTraitInterface {}
//
//extension CompareUniqueTrait {
//  @inlinable @inline(__always)
//  public static var isMulti: Bool { false }
//}
//
//@available(*, deprecated)
//public protocol CompareMultiTrait: _Base_IsMultiTraitInterface {}
//
//extension CompareMultiTrait {
//  @inlinable @inline(__always)
//  public static var isMulti: Bool { true }
//}

// 分岐を減らしたい気持ちはあるが、ホットパスというわけでもないので、無理にはやらない

public protocol TraitHelper: _UnsafeNodePtrType {
  static func ___ptr_comp(_ l: _NodePtr, _ r: _NodePtr) -> Bool
  static func ___ptr_range_comp(_ __f: _NodePtr, _ __p: _NodePtr, _ __l: _NodePtr) -> Bool
}

public protocol CompareUniqueTraitHelper: _Base_TraitHelperInterface
where _TraitHelper == __UniqueTrait<Self> {}
extension CompareUniqueTraitHelper {
  
  @inlinable @inline(__always)
  public static var isMulti: Bool { false }
}

public protocol CompareMultiTraitHelper: _Base_TraitHelperInterface
where _TraitHelper == __MultiTrait<Self> {}
extension CompareMultiTraitHelper {
  
  @inlinable @inline(__always)
  public static var isMulti: Bool { true }
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

#if false
    let (f, p, l) = (
      __f.___ptr_bitmap_128(),
      __p.___ptr_bitmap_128(),
      __l.___ptr_bitmap_128()
    )
#else
    let (f, p, l) = (
      __f.___ptr_bitmap_64(),
      __p.___ptr_bitmap_64(),
      __l.___ptr_bitmap_64()
    )
#endif

    // __f <= __p && __p <= __l
    return f <= p && p <= l
  }
}
