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

#if COMPATIBLE_ATCODER_2025
extension UnsafeIterator {

  @frozen
  public struct _Obverse0:
    _UnsafeNodePtrType,
    IteratorProtocol,
    Sequence,
    Equatable
  {
    @inlinable
    init(_start: _NodePtr, _end: _NodePtr) {
      self._start = _start
      self._end = _end
      self._current = _start
    }

    @usableFromInline let _start: _NodePtr
    @usableFromInline let _end: _NodePtr
    @usableFromInline var _current: _NodePtr

    @inlinable
    public mutating func next() -> _NodePtr? {
      guard _current != _end else { return nil }
      defer { _current = __tree_next_iter(_current) }
      return _current
    }
  }
}

extension UnsafeIterator._Obverse0: @unchecked Sendable {}
#endif
