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

  public struct _Obverse:
    _UnsafeNodePtrType,
    UnsafeIteratorProtocol,
    ObverseIterator,
    IteratorProtocol,
    Sequence,
    Equatable
  {
    public init(_start: _SealedPtr, _end: _SealedPtr) {
      self._start = _start.pointer!
      self._end = _end.pointer!
      self._current = _start.pointer!
    }
    
    public init(_start: _NodePtr, _end: _NodePtr) {
      self._start = _start
      self._end = _end
      self._current = _start
    }

    public let _start: _NodePtr
    public let _end: _NodePtr
    public var _current: _NodePtr

    public var _sealed_start: _SealedPtr {
      fatalError()
    }

    public var _sealed_end: _SealedPtr {
      fatalError()
    }

    public mutating func next() -> _NodePtr? {
      guard _current != _end else { return nil }
      // 最悪でもendで止まる
      guard !_current.___is_end else {
        fatalError(.outOfBounds)
      }
      let __r = _current
      _current = __tree_next_iter(_current)
      return __r
    }

    public typealias Reversed = _Reverse

    public func reversed() -> UnsafeIterator._Reverse {
      fatalError()
    }
  }
}

#if swift(>=5.5)
  extension UnsafeIterator._Obverse: @unchecked Sendable {}
#endif
