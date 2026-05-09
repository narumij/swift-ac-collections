//
//  UnsafeTreeV2+deprecated.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/17.
//

#if COMPATIBLE_ATCODER_2025
  extension UnsafeTreeV2 where Base: ___TreeIndex {

    public typealias Index = UnsafeIndexV2<Base>
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension UnsafeTreeV2 where Base: ___TreeIndex {

    public typealias Indices = UnsafeIndexV2Collection<Base>
  }
#endif

// TODO: デッドコードになってないかチェックすること
#if COMPATIBLE_ATCODER_2025
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
  }
#endif

