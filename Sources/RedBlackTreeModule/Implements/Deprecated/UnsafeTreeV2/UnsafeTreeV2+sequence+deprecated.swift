//
//  UnsafeTreeV2+sequence+deprecated.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/10.
//

// TODO: デッドコードになってないかチェックすること
#if COMPATIBLE_ATCODER_2025
  extension UnsafeTreeV2 {

    @inlinable
    @inline(__always)
    internal func
      ___for_each_(__p: _SealedPtr, __l: _SealedPtr, body: (_NodePtr) throws -> Void)
      rethrows
    {
      for __c in sequence(__p, __l) {
        try body(__c)
      }
    }

    @inlinable
    @inline(__always)
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
    @inline(__always)
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
#endif

// TODO: デッドコードになってないかチェックすること
#if COMPATIBLE_ATCODER_2025
extension UnsafeTreeV2 {

    @inlinable
    @inline(__always)
    internal func
      sequence(_ __first: _SealedPtr, _ __last: _SealedPtr) -> UnsafeIterator._RemoveAwarePointers
    {
      .init(_start: __first, _end: __last)
    }
}
#endif
