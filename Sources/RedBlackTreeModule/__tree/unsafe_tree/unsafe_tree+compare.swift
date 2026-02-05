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

// static系の実装もある。気が向いたらこちらを削除してもよいような、だめだったような。

@usableFromInline
protocol _TreeNode_PtrCompProtocol:
  _UnsafeNodePtrType
    & _TreeNode_PtrCompInterface
    & _TreeKey_CompInterface
    & _Tree_IsMultiTraitInterface
    & NullPtrInterface
    & EndInterface
{
  func ___ptr_comp_unique(_ l: _NodePtr, _ r: _NodePtr) -> Bool
}

extension _TreeNode_PtrCompProtocol {

  @inlinable
  @inline(__always)
  internal func ___ptr_comp(_ l: _NodePtr, _ r: _NodePtr) -> Bool {
    assert(l == end || l.__parent_ != nullptr)
    assert(r == end || r.__parent_ != nullptr)

    guard
      l != r,
      r != end,
      l != end
    else {
      return l != end && r == end
    }

    if isMulti {

      // DONE: ポインタ版になったので再度はかりなおすこと
      // ___ptr_comp_multiのほうがはやく、改良版はさらに速くなった

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

extension _TreeNode_PtrCompProtocol {

  /// ptrのrange判定
  @inlinable
  @inline(__always)
  internal func ___ptr_range_comp(_ __f: _NodePtr, _ __p: _NodePtr, _ __l: _NodePtr) -> Bool {
    
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

@usableFromInline
protocol _TreeNode_PtrCompUniqueProtocol:
  _TreeNode_KeyInterface
    & EndInterface
    & NullPtrInterface
    & _TreeKey_CompInterface
{}

extension _TreeNode_PtrCompUniqueProtocol {

  @inlinable
  @inline(__always)
  internal func ___ptr_comp_unique(_ l: _NodePtr, _ r: _NodePtr) -> Bool {
    assert(l != nullptr, "Node shouldn't be null")
    assert(l != end, "Node shouldn't be end")
    assert(r != nullptr, "Node shouldn't be null")
    assert(r != end, "Node shouldn't be end")
    return value_comp(__get_value(l), __get_value(r))
  }
}

// MARK: -

@usableFromInline
protocol CompareProtocol: _TreeNode_PtrCompInterface {}

extension CompareProtocol {

  @inlinable
  @inline(__always)
  internal func
    ___ptr_less_than(_ l: _NodePtr, _ r: _NodePtr) -> Bool
  {
    ___ptr_comp(l, r)
  }

  @inlinable
  @inline(__always)
  internal func
    ___ptr_less_than_or_equal(_ l: _NodePtr, _ r: _NodePtr) -> Bool
  {
    !___ptr_comp(r, l)
  }

  @inlinable
  @inline(__always)
  internal func
    ___ptr_greator_than(_ l: _NodePtr, _ r: _NodePtr) -> Bool
  {
    ___ptr_comp(r, l)
  }

  @inlinable
  @inline(__always)
  internal func
    ___ptr_greator_than_or_equal(_ l: _NodePtr, _ r: _NodePtr) -> Bool
  {
    !___ptr_comp(l, r)
  }

  @inlinable
  @inline(__always)
  internal func
    ___ptr_range_contains(_ l: _NodePtr, _ r: _NodePtr, _ p: _NodePtr) -> Bool
  {
    ___ptr_less_than_or_equal(l, p) && ___ptr_less_than(p, r)
  }

  @inlinable
  @inline(__always)
  internal func
    ___ptr_closed_range_contains(_ l: _NodePtr, _ r: _NodePtr, _ p: _NodePtr) -> Bool
  {
    ___ptr_less_than_or_equal(l, p) && ___ptr_less_than_or_equal(p, r)
  }
}
