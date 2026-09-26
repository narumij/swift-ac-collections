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

extension UnsafeTreeV2 where Base: _BaseNode_PtrCompInterface {

  @inlinable
  func isValid(range: _NodeRange) -> Bool {
    range.lowerBound == range.upperBound
      || Base.___ptr_comp(range.lowerBound, range.upperBound)
  }
  
  @inlinable
  func isValid(range: _SafeRange) -> Bool {
    return (try? range.map(isValid(range:)).get()) == true
  }


  @inlinable
  func isValid(safeRange range: _RawRange<_SafePtr>) -> Bool {
    return isValid(range: traverse(range) { $0.map { $0 } })
  }

  @inlinable
  func sanitize(safeRange range: _RawRange<_SafePtr>) -> _RawRange<_SafePtr> {
    isValid(safeRange: range) ? range : ___safe_empty_range
  }
}

extension UnsafeTreeV2 {

  @inlinable
  var ___safe_empty_range: _RawRange<_SafePtr> {
    let e = __end_node.unchecked
    return .init(lowerBound: e, upperBound: e)
  }
}
