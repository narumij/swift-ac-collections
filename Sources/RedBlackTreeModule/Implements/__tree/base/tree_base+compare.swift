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
  _BaseNode_PtrCompInterface
    & _BaseNode_PtrRangeCompInterface
    & _Base_TraitHelperInterface {}

extension _BaseNode_NodeCompareProtocol {

  @inlinable
  public static func ___ptr_comp(_ l: _NodePtr, _ r: _NodePtr) -> Bool {
    _TraitHelper.___ptr_comp(l, r)
  }

  @inlinable
  public static func ___ptr_range_comp(_ __f: _NodePtr, _ __p: _NodePtr, _ __l: _NodePtr) -> Bool {
    _TraitHelper.___ptr_range_comp(__f, __p, __l)
  }
}

