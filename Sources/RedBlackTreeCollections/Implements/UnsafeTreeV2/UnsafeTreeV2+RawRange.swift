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
  func validated(range: _NodeRange) -> Result<_NodeRange, SealError> {
    isValid(range: range)
      ? .success(range)
      : .failure(.other)
  }

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
  func sanitize(_ range: _NodeRange) -> _NodeRange {
    isValid(range: range) ? range : ___empty_range
  }
  
  @inlinable
  func sanitize(_ range: _SafeRange) -> _SafeRange {
    range.map(sanitize(_:)).flatMapError { _ in .success(___empty_range) }
  }
}

extension UnsafeTreeV2 {

  @inlinable
  var ___empty_range: _NodeRange {
    let e = __end_node
    return .init(lowerBound: e, upperBound: e)
  }
}
