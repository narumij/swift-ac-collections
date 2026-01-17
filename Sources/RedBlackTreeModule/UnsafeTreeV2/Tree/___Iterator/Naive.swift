//
//  ___UnsafeNaiveIterator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/15.
//

extension UnsafeIterator {
  
  public struct Obverse:
    UnsafeTreePointer,
    UnsafeIteratorProtocol,
    IteratorProtocol,
    Sequence,
    Equatable
  {
    @usableFromInline
    internal init(__first: _NodePtr, __last: _NodePtr) {
      self.__first = __first
      self.__current = __first
      self.__last = __last
    }
    
    public mutating func next() -> _NodePtr? {
      guard __current != __last else { return nil }
      let __r = __current
      __current = __tree_next_iter(__current)
      return __r
    }
    
    @usableFromInline
    let __first: _NodePtr
    @usableFromInline
    var __current: _NodePtr
    @usableFromInline
    let __last: _NodePtr
  }
  
  public struct Reverse:
    UnsafeTreePointer,
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

@usableFromInline
package typealias ___UnsafePointersUnsafeV2 = UnsafeIterator.Obverse

extension UnsafeIterator.Obverse {
  
  @inlinable
  @inline(__always)
  public init<Base: ___TreeBase>(tree: UnsafeTreeV2<Base>, start: _NodePtr, end: _NodePtr) {
    self.init(__first: start, __last: end)
  }

  @inlinable
  @inline(__always)
  public init<Base: ___TreeBase>(
    __tree_: UnsafeImmutableTree<Base>, start: _NodePtr, end: _NodePtr
  ) {
    self.init(__first: start, __last: end)
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
  public init<Base: ___TreeBase>(
    __tree_: UnsafeImmutableTree<Base>, start: _NodePtr, end: _NodePtr
  ) {
    self.init(__first: start, __last: end)
  }
}

#if swift(>=5.5)
extension UnsafeIterator.Obverse: @unchecked Sendable {}
#endif

#if swift(>=5.5)
extension UnsafeIterator.Reverse: @unchecked Sendable {}
#endif
