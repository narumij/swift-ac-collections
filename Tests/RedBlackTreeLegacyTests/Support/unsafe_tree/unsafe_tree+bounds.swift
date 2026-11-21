//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project.
//
// Copyright (c) 2024-2026 narumij.
// Licensed under the Apache License v2.0.
//
// SPDX-License-Identifier: Apache-2.0
//
// This implementation includes code derived from LLVM libc++'s red-black tree
// implementation, originally distributed under the Apache License v2.0 with
// LLVM Exceptions.
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by
// narumij.
//
//===----------------------------------------------------------------------===//

@usableFromInline
protocol BoundBothProtocol: ~Copyable,
  BoundInteface
    & BoundBothInterface
    & _Tree_IsMultiTraitInterface
{}

#if !ENABLE_LEGACY_TREE_LOWER_UPPER_BOUND
  extension BoundBothProtocol where Self: ~Copyable {

    @inlinable
    internal func lower_bound(_ __v: _Key) -> _NodePtr {
      isMulti ? __lower_bound_multi(__v) : __lower_bound_unique(__v)
    }

    @inlinable
    internal func upper_bound(_ __v: _Key) -> _NodePtr {
      isMulti ? __upper_bound_multi(__v) : __upper_bound_unique(__v)
    }
  }
#endif

#if ENABLE_LEGACY_TREE_LOWER_UPPER_BOUND
  extension BoundBothProtocol where Self: ~Copyable {

    @inlinable
    internal func lower_bound(_ __v: _Key) -> _NodePtr {
      __lower_bound_multi(__v)
    }

    @inlinable
    internal func upper_bound(_ __v: _Key) -> _NodePtr {
      __upper_bound_multi(__v)
    }
  }
#endif

