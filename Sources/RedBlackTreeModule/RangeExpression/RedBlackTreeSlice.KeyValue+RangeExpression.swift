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

#if !COMPATIBLE_ATCODER_2025
extension RedBlackTreeSliceV2.KeyValue {

    public typealias _RangeExpression = UnsafeIndexV2RangeExpression<Base>

    @inlinable
    public func isValid(_ bounds: UnboundedRange) -> Bool {
      return _start.isValid && _end.isValid
    }

    @inlinable
    public func isValid(_ bounds: _RangeExpression) -> Bool {
      let (l, u) = bounds.rawRange._relative(to: __tree_)
      return l.isValid && u.isValid
    }

    @inlinable
    public subscript(bounds: UnboundedRange) -> SubSequence {
      ___subscript(.unboundedRange)
    }

    @inlinable
    public subscript(bounds: _RangeExpression) -> SubSequence {
      ___subscript(bounds.rawRange)
    }
  }
#endif
