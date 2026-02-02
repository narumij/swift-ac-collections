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
    @inline(__always)
    public init(_start: _NodePtr, _end: _NodePtr) {
      self._safe_start = _start.safe
      self._safe_end = _end.safe
      self._safe_current = _end.safe
    }

    @usableFromInline
    var _safe_start, _safe_end, _safe_current: SafePtr

    public mutating func next() -> _NodePtr? {
      
      let _checked_current = _safe_current.checked
      
      // 範囲 start が壊れてたらオコ！
      guard let start = try? _safe_start.checked.get() else {
        fatalError(.invalidIndex)
      }

      // current が壊れてたらオコ！
      guard let cur = try? _checked_current.get() else {
        fatalError(.invalidIndex)
      }

      // start に到達（exclusive）なら終了
      guard cur != start else { return nil }
      
      _safe_current = _checked_current.flatMap { ___tree_prev_iter($0.pointer) }
      
      // prev の結果が壊れてたらオコ！（end→start の途中で壊れた）
      guard let p = try? _safe_current.get() else {
        fatalError(.invalidIndex)
      }
      
      return p.pointer
    }

    public var _start: _NodePtr {
      try! _safe_start.get().pointer
    }

    public var _end: _NodePtr {
      try! _safe_end.get().pointer
    }
  }
}

#if swift(>=5.5)
  extension UnsafeIterator._Reverse2: @unchecked Sendable {}
#endif
