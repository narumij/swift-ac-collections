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

#if !COMPATIBLE_ATCODER_2025 && ENABLE_EXPERIMENTAL_LRU

@usableFromInline
package struct _LinkList<_Key: Comparable, _MappedValue>: _UnsafeNodePtrType
 {
   @usableFromInline enum Base: LinkPairValueTrait & IntThreeWayComparator {}

  @usableFromInline var _rankHighest: _NodePtr = .nullptr
  @usableFromInline var _rankLowest: _NodePtr = .nullptr
  @usableFromInline let maxCount: Int

  @inlinable
  package init(maxCount: Int) {
    self.maxCount = maxCount
  }
}

extension _LinkList {
  
  @inlinable
  package mutating func prepend(_ __p: _NodePtr)  {
    if _rankHighest == .nullptr {
      Base.__payload_ptr(__p).pointee.next = .nullptr
      Base.__payload_ptr(__p).pointee.prev = .nullptr
      _rankLowest = __p
      _rankHighest = __p
    } else {
      Base.__payload_ptr(_rankHighest).pointee.prev = __p
      Base.__payload_ptr(__p).pointee.next = _rankHighest
      Base.__payload_ptr(__p).pointee.prev = .nullptr
      _rankHighest = __p
    }
  }

  @inlinable
  package mutating func pop(_ __p: _NodePtr) -> _NodePtr {

    assert(
      __p == _rankHighest || Base.__payload_ptr(__p).pointee.next != .nullptr
      || Base.__payload_ptr(__p).pointee.prev != .nullptr,
      "did not contain \(__p) ptr.")

    defer {
      let prev = Base.__payload_ptr(__p).pointee.prev
      let next = Base.__payload_ptr(__p).pointee.next
      if prev != .nullptr {
        Base.__payload_ptr(prev).pointee.next = next
      } else {
        _rankHighest = next
      }
      if next != .nullptr {
        Base.__payload_ptr(next).pointee.prev = prev
      } else {
        _rankLowest = prev
      }
    }

    return __p
  }

  @inlinable
  package mutating func popRankLowest() -> _NodePtr {

    defer {
      if _rankLowest != .nullptr {
        _rankLowest = Base.__payload_ptr(_rankLowest).pointee.prev
      }
      if _rankLowest != .nullptr {
        Base.__payload_ptr(_rankLowest).pointee.next = .nullptr
      } else {
        _rankHighest = .nullptr
      }
    }

    return _rankLowest
  }
  
  @usableFromInline
  mutating func reset() {
    self = .init(maxCount: maxCount)
  }
}

#endif
