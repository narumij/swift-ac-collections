//
//  UnsafeTreeV2+Ptr.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/13.
//

extension UnsafeTreeV2 where Base: _UnsafeNodePtrType & _BaseNode_SignedDistanceInterface {

  // この実装がないと、迷子になる?
  @inlinable
  @inline(__always)
  internal func
    ___distance(from start: _SealedPtr, to end: _SealedPtr) -> Int?
  {
    guard
      let start = start.purified.pointer,
      let end = end.purified.pointer
    else {
      return nil
    }
    return ___signed_distance(start, end)
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal func ___index(after i: _SealedPtr) -> _SealedPtr {
    i.flatMap { ___tree_next_iter($0.pointer) }.sealed
  }

  @inlinable
  @inline(__always)
  internal func ___index(before i: _SealedPtr) -> _SealedPtr {
    i.flatMap { ___tree_prev_iter($0.pointer) }.sealed
  }

  @inlinable
  @inline(__always)
  internal func ___index(_ i: _SealedPtr, offsetBy distance: Int) -> _SealedPtr {
    i.flatMap { ___tree_adv_iter($0.pointer, distance) }.sealed
  }

  @inlinable
  @inline(__always)
  internal func
    ___index(_ i: _SealedPtr, offsetBy distance: Int, limitedBy limit: _SealedPtr)
    -> _SealedPtr
  {
    i.flatMap { ___tree_adv_iter($0.pointer, distance, limit.temporaryUnseal) }.sealed
  }
}
