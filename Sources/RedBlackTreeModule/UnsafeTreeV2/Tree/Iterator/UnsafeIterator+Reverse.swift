//
//  UnsafeIterator+Reverse.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/17.
//

extension UnsafeIterator {

  public struct _Reverse:
    _UnsafeNodePtrType,
    UnsafeIteratorProtocol,
    ReverseIterator,
    IteratorProtocol,
    Sequence,
    Equatable
  {
    @usableFromInline
    internal init(___tree_range: UnsafeTreeRange) {
      self.___tree_range = ___tree_range
      self.__current = ___tree_range.___to
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
      return ___tree_range.boundsCheckedNext(before: &__current)
    }

    @usableFromInline
    let ___tree_range: UnsafeTreeRange

    @usableFromInline
    var __current: _NodePtr
  }
}

extension UnsafeIterator._Reverse {

  @inlinable
  @inline(__always)
  public init(
    _start: _NodePtr, _end: _NodePtr
  ) {
    self.init(__first: _start, __last: _end)
  }
}

#if swift(>=5.5)
  extension UnsafeIterator._Reverse: @unchecked Sendable {}
#endif
