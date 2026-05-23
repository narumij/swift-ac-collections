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
  func isValidSealedRange(lower: _SealedPtr, upper: _SealedPtr) -> Bool {

    let result = lower.flatMap { l in
      upper.map { r in
        l == r || Base.___ptr_comp(l.pointer, r.pointer)
      }
    }

    return (try? result.get()) == true
  }

  @inlinable
  func isValidSealedRange(_ range: _RawRange<_SealedPtr>) -> Bool {
    isValidSealedRange(lower: range.lowerBound, upper: range.upperBound)
  }

  @inlinable
  func sanitizeSealedRange(_ range: _RawRange<_SealedPtr>)
    -> _RawRange<_SealedPtr>
  {
    isValidSealedRange(range) ? range : ___sealed_empty_range
  }
  
  @inlinable
  func isValidSealedRange(lower: _SafePtr, upper: _SafePtr) -> Bool {

    let result = lower.flatMap { l in
      upper.map { r in
        l == r || Base.___ptr_comp(l, r)
      }
    }

    return (try? result.get()) == true
  }

  @inlinable
  func isValidSealedRange(_ range: _RawRange<_SafePtr>) -> Bool {
    isValidSealedRange(lower: range.lowerBound, upper: range.upperBound)
  }

  @inlinable
  func sanitizeSealedRange(_ range: _RawRange<_SafePtr>)
    -> _RawRange<_SafePtr>
  {
    isValidSealedRange(range) ? range : ___safe_empty_range
  }
}

extension UnsafeTreeV2 {

  @inlinable
  var ___sealed_empty_range: _RawRange<_SealedPtr> {
    let e = __end_node.sealed
    return .init(lowerBound: e, upperBound: e)
  }
  
  @inlinable
  var ___safe_empty_range: _RawRange<_SafePtr> {
    let e = __end_node.safe
    return .init(lowerBound: e, upperBound: e)
  }
}
