//
//  UnsafeTreeV2+deprecated.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/17.
//

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

extension UnsafeTreeV2 where Base: ___TreeIndex {

  public typealias Pointee = Base.Element
  public typealias Indices = UnsafeIndexV2Collection<Base>
}

extension UnsafeTreeV2 where Base: ___TreeIndex {

  public typealias _PayloadValues = RedBlackTreeIteratorV2.Values<Base>
}

extension UnsafeTreeV2 where Base: PairValueTrait & ___TreeIndex {

  public typealias _KeyValues = RedBlackTreeIteratorV2.KeyValues<Base>
}
