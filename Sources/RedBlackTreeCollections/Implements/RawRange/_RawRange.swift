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

public struct _RawRange<Bound> {

  @usableFromInline
  internal var lowerBound: Bound

  @usableFromInline
  internal var upperBound: Bound

  @inlinable
  internal init(lowerBound: Bound, upperBound: Bound) {
    self.lowerBound = lowerBound
    self.upperBound = upperBound
  }
}

extension _RawRange where Bound == _SafePtr {

  @inlinable
  func map2<T>(_ f: (Bound._NodePtr, Bound._NodePtr) -> T) -> Result<T, SealError> {
    liftA2(lowerBound, upperBound, f)
  }
}

extension _RawRange where Bound == UnsafeMutablePointer<UnsafeNode> {

  @inlinable
  var unchecked: _RawRange<_SafePtr> {
    .init(
      lowerBound: lowerBound.unchecked,
      upperBound: upperBound.unchecked)
  }
}
