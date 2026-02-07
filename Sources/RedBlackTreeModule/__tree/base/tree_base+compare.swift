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

public protocol _BaseNode_PtrCompProtocol_b:
  _BaseNode_PtrUniqueCompProtocol
    & _BaseNode_PtrCompProtocol
{}

public protocol _BaseNode_PtrCompProtocol:
  _UnsafeNodePtrType
    & _BaseNode_PtrUniqueCompInterface
    & _BaseNode_PtrCompInterface
    & _Base_IsMultiTraitInterface
    & _BaseNode_SignedDistanceInterface
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

/// Index用のメソッド中継
public protocol _BaseNode_PtrUniqueCompProtocol:
  _BaseNode_PtrUniqueCompInterface
    & _BaseKey_LessThanInterface
    & _BaseNode_KeyInterface
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
