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
    @usableFromInline
    internal init(___tree_range: UnsafeTreeRange) {
      self.___tree_range = ___tree_range
      self.__current = ___tree_range.___from
    }

    @usableFromInline
    internal init(__first: _NodePtr, __last: _NodePtr) {
      self.init(
        ___tree_range:
          UnsafeTreeRange(___from: __first, ___to: __last))
    }

    public var _start: UnsafeMutablePointer<UnsafeNode> {
      ___tree_range.___from
    }

    public var _end: UnsafeMutablePointer<UnsafeNode> {
      ___tree_range.___to
    }

    public mutating func next() -> _NodePtr? {
      return ___tree_range.boundsCheckedNext(after: &__current)
    }

    @usableFromInline
    let ___tree_range: UnsafeTreeRange

    @usableFromInline
    var __current: _NodePtr

    public typealias Reversed = _Reverse

    public func reversed() -> UnsafeIterator._Reverse {
      .init(___tree_range: ___tree_range)
    }
  }
}

extension UnsafeIterator._Obverse {

  public init(_start: _SealedPtr, _end: _SealedPtr) {
    self.init(__first: _start.pointer!, __last: _end.pointer!)
  }
}

#if swift(>=5.5)
  extension UnsafeIterator._Obverse: @unchecked Sendable {}
#endif
