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

  public struct _Reverse2:
    _UnsafeNodePtrType,
    UnsafeIteratorProtocol,
    ReverseIterator,
    IteratorProtocol,
    Sequence,
    Equatable
  {
    @inlinable
    public init(_start: _SealedPtr, _end: _SealedPtr) {
      self._sealed_start = _start
      self._sealed_end = _end
      self._sealed_current = _end
    }

    public var _sealed_start, _sealed_end, _sealed_current: _SealedPtr

    @inlinable
    public mutating func next() -> _NodePtr? {

      let _purified_current = _sealed_current.purified

      guard let start = try? _sealed_start.purified.get() else {
        // 範囲 start が壊れている
        fatalError(.invalidIndex)
      }

      guard let cur = try? _purified_current.get() else {
        // current が壊れている
        fatalError(.invalidIndex)
      }

      // start に到達（exclusive）なら終了
      guard cur != start else { return nil }

      _sealed_current = _purified_current.flatMap { ___tree_prev_iter($0.pointer).uncheckedSeal }

      guard let p = try? _sealed_current.get() else {
        // prev の結果が壊れている（end→start の途中で壊れた）
        fatalError(.invalidIndex)
      }

      return p.pointer
    }
  }
}

extension UnsafeIterator._Reverse2: @unchecked Sendable {}
