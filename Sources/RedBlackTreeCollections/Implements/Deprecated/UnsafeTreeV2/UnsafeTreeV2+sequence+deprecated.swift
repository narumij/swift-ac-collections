//
//  UnsafeTreeV2+sequence+deprecated.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/10.
//

#if COMPATIBLE_ATCODER_2025
  extension UnsafeTreeV2 {

    @inlinable
    internal func
      ___for_each_(__p: _SealedPtr, __l: _SealedPtr, body: (_NodePtr) throws -> Void)
      rethrows
    {
      for __c in sequence(__p, __l) {
        try body(__c)
      }
    }

    @inlinable
    internal func ___rev_for_each_(
      __p: _SealedPtr, __l: _SealedPtr, body: (_NodePtr) throws -> Void
    )
      rethrows
    {
      for __c in sequence(__p, __l).reversed() {
        try body(__c)
      }
    }
  }

  extension UnsafeTreeV2 {

    @inlinable
    internal func ___for_each(
      __p: _SealedPtr, __l: _SealedPtr, body: (_NodePtr, inout Bool) throws -> Void
    )
      rethrows
    {
      for __c in sequence(__p, __l) {
        var cont = true
        try body(__c, &cont)
        if !cont {
          break
        }
      }
    }
  }

  extension UnsafeTreeV2 {

    @inlinable
    internal func
      sequence(_ __first: _SealedPtr, _ __last: _SealedPtr) -> UnsafeIterator._RemoveAwarePointers
    {
      .init(_start: __first, _end: __last)
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension UnsafeTreeV2 {

    @usableFromInline
    internal func
      unsafeSequence(_ __first: _NodePtr, _ __last: _NodePtr)
      -> UnsafeIterator._Obverse1
    {
      .init(_start: __first, _end: __last)
    }

    @usableFromInline
    internal func
      unsafeValues(_ __first: _NodePtr, _ __last: _NodePtr)
      -> UnsafeIterator._Payload<Base, UnsafeIterator._Obverse1>
    {
      .init(source: .init(_start: __first, _end: __last))
    }
  }
#endif
