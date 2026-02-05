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

  public struct _Obverse2:
    _UnsafeNodePtrType,
    UnsafeIteratorProtocol,
    ObverseIterator,
    IteratorProtocol,
    Sequence,
    Equatable
  {
    @inlinable
    @inline(__always)
    public init(_start: _SealedPtr, _end: _SealedPtr) {
      self._sealed_start = _start
      self._sealed_end = _end
      self._sealed_current = _start
    }

    public var _sealed_start, _sealed_end, _sealed_current: _SealedPtr

    public mutating func next() -> _NodePtr? {
      
      let _purified_current = _sealed_current.purified
      
      // 範囲終端が壊れてたらオコ！
      guard let _end = try? _sealed_end.purified.get() else {
        fatalError(.invalidIndex)
      }

      // current が壊れてたらオコ！
      guard let _p = try? _purified_current.get() else {
        fatalError(.invalidIndex)
      }
      
      // 終端に到達
      guard _p != _end else { return nil }
      
      _sealed_current = _purified_current.flatMap { ___tree_next_iter($0.pointer) }.seal
      
      return _p.pointer
    }
    
    public typealias Reversed = _Reverse2

    public func reversed() -> UnsafeIterator._Reverse2 {
      .init(_start: _sealed_start, _end: _sealed_end)
    }
  }
}

#if swift(>=5.5)
  extension UnsafeIterator._Obverse2: @unchecked Sendable {}
#endif
