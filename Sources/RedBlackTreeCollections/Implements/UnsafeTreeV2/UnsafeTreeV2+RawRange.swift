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



extension UnsafeTreeV2 where Base: _BaseNode_PtrCompInterface {

  @inlinable
  func isValidSafeRange(_ range: _RawRange<_SafePtr>) -> Bool {

    let result = range.map2 { l, r in
      l == r || Base.___ptr_comp(l, r)
    }

    return (try? result.get()) == true
  }

  @inlinable
  func sanitizeSafeRange(_ range: _RawRange<_SafePtr>) -> _RawRange<_SafePtr> {
    isValidSafeRange(range) ? range : ___safe_empty_range
  }
}

extension UnsafeTreeV2 {

  @inlinable
  var ___safe_empty_range: _RawRange<_SafePtr> {
    let e = __end_node.safe
    return .init(lowerBound: e, upperBound: e)
  }
}
