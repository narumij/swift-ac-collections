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
  protocol UnsafeTreeSealedRangeProtocol: UnsafeTreeSealedRangeBaseInterfaceV2, _PayloadValueBride {
  }

  extension UnsafeTreeSealedRangeProtocol {

    @inlinable
    internal func ___first(where predicate: (_PayloadValue) throws -> Bool) rethrows
      -> _PayloadValue?
    {
      var result: _PayloadValue?
      try __tree_.___for_each(__p: _sealed_start, __l: _sealed_end) { __p, cont in
        if try predicate(__tree_[_unsafe_raw: __p]) {
          result = __tree_[_unsafe_raw: __p]
          cont = false
        }
      }
      return result
    }
  }

  extension UnsafeTreeSealedRangeProtocol {

    @inlinable
    internal func ___first_(where predicate: (_PayloadValue) throws -> Bool) rethrows
      -> _SealedPtr?
    {
      var __r = UnsafeNode.nullptr
      try __tree_.___for_each(__p: _sealed_start, __l: _sealed_end) { __p, cont in
        if try predicate(__tree_[_unsafe_raw: __p]) {
          __r = __p
          cont = false
        }
      }
      return __r.sealed
    }
  }

  extension UnsafeTreeSealedRangeProtocol {

    @inlinable
    internal func _isIdentical(to other: Self) -> Bool {
      __tree_.isIdentical(to: other.__tree_)
        && _sealed_start == other._sealed_start
        && _sealed_end == other._sealed_end
    }
  }
#endif
