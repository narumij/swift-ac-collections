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

extension UnsafeTreeV2 {

  @inlinable
  func isValidRawRange(lower: _NodePtr, upper: _NodePtr) -> Bool {

    guard
      !lower.___is_null,
      !upper.___is_null,
      !lower.___is_garbaged,
      !upper.___is_garbaged
    else {
      fatalError(.invalidIndex)
    }

    if upper.___is_end {
      return true
    }

    guard
      // lower <= upper は、upper > lowerなので
      !___ptr_comp(upper, lower)
    else {
      fatalError(.outOfRange)
    }

    return true
  }
  
  @inlinable
  func isValidRawRange(range: UnsafeTreeRangeExpression) -> Bool {
    let (lower, upper) = range.relative(to: self)
    return isValidRawRange(lower: lower, upper: upper)
  }
}
