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

extension UnsafeIterator {

  public struct _Obverse3:
    _UnsafeNodePtrType,
    UnsafeIteratorProtocol,
    ObverseIterator,
    IteratorProtocol,
    Sequence,
    Equatable
  {
    @inlinable
    public init(_start: _SealedPtr, _end: _SealedPtr) {
      self._safe_start = _start.map(\.pointer)
      self._safe_end = _end.map(\.pointer)
      self._safe_current = _start.map(\.pointer)
    }

    public var _safe_start, _safe_end, _safe_current: _SafePtr

    public var _sealed_start: _SealedPtr { _safe_start.uncheckedSeal }
    public var _sealed_end: _SealedPtr { _safe_end.uncheckedSeal }

    @inlinable
    public mutating func next() -> _NodePtr? {
      guard _safe_current != _safe_end else { return nil }
      // 最悪でもendで止まる
      guard _safe_current.___has_payload_content else {
        fatalError(.outOfBounds)
      }
      let __r = _safe_current
      _safe_current = _safe_current.flatMap { ___tree_next_iter($0) }
      return __r.pointer
    }

    public typealias Reversed = _Reverse3

    @inlinable
    public func reversed() -> UnsafeIterator._Reverse3 {
      .init(_start: _safe_start.uncheckedSeal, _end: _safe_end.uncheckedSeal)
    }
  }
}

extension UnsafeIterator._Obverse3: @unchecked Sendable {}
