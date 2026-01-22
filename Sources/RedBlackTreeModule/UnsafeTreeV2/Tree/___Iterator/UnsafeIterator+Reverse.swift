//
//  UnsafeIterator+Reverse.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/17.
//

extension UnsafeIterator {

  public struct Reverse:
    _UnsafeNodePtrType,
    UnsafeIteratorProtocol,
    IteratorProtocol,
    Sequence,
    Equatable
  {
    @usableFromInline
    internal init(__first: _NodePtr, __last: _NodePtr) {
      self.__first = __first
      self.__current = __last
      self.__last = __last
    }
    
    public var _start: UnsafeMutablePointer<UnsafeNode> {
      __first
    }

    public var _end: UnsafeMutablePointer<UnsafeNode> {
      __last
    }

    public mutating func next() -> _NodePtr? {
      guard __current != __first else { return nil }
      __current = __tree_prev_iter(__current)
      return __current
    }

    @usableFromInline
    let __first: _NodePtr
    @usableFromInline
    var __current: _NodePtr
    @usableFromInline
    let __last: _NodePtr
  }
}

extension UnsafeIterator.Reverse {

  @inlinable
  @inline(__always)
  public init<Base: ___TreeBase>(tree: UnsafeTreeV2<Base>, start: _NodePtr, end: _NodePtr) {
    self.init(__first: start, __last: end)
  }

  @inlinable
  @inline(__always)
  public init(start: _NodePtr, end: _NodePtr
  ) {
    self.init(__first: start, __last: end)
  }
}

#if swift(>=5.5)
  extension UnsafeIterator.Reverse: @unchecked Sendable {}
#endif
