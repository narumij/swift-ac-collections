//
//  ___UnsafeNaiveIterator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/15.
//

extension UnsafeIterator {

  public struct Obverse:
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
      return ___tree_range.next(after: &__current)
    }

    @usableFromInline
    let ___tree_range: UnsafeTreeRange

    @usableFromInline
    var __current: _NodePtr
    
    public typealias Reversed = Reverse
    
    public func reversed() -> UnsafeIterator.Reverse {
      .init(___tree_range: ___tree_range)
    }
  }
}

extension UnsafeIterator.Obverse {

  @inlinable
  @inline(__always)
  public init(start: _NodePtr, end: _NodePtr
  ) {
    self.init(__first: start, __last: end)
  }
}

#if swift(>=5.5)
  extension UnsafeIterator.Obverse: @unchecked Sendable {}
#endif
