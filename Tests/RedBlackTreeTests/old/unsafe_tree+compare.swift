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

// MARK: -
#if DEBUG
  @testable import RedBlackTreeModule

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
#endif
