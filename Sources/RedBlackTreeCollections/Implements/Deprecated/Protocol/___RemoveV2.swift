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

#if COMPATIBLE_ATCODER_2025
  @usableFromInline
  protocol ___RemoveV2: UnsafeMutableTreeRangeBaseInterfaceV2, _PayloadValueBride
  where Base: _BaseNode_PtrCompInterface {}

  extension ___RemoveV2 {

    @inlinable
    func isValidNodeRange(lower: _NodePtr, upper: _NodePtr) -> Bool {
      lower == upper || Base.___ptr_comp(lower, upper)
    }

    @discardableResult
    @inlinable
    package mutating func ___remove(from: _NodePtr, to: _NodePtr) -> _NodePtr {
      guard from != _end else { return __tree_.end }
      guard isValidNodeRange(lower: from, upper: to) else {
        fatalError(.invalidIndex)
      }
      return __tree_.erase(from, to)
    }

    @discardableResult
    @inlinable
    package mutating func ___unchecked_remove(from: _NodePtr, to: _NodePtr) -> _NodePtr {
      guard from != _end else { return __tree_.end }
      return __tree_.___erase_range(from, to)
    }
  }
#endif
