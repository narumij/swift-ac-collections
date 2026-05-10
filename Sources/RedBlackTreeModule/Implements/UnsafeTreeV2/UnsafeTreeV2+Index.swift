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

#if !COMPATIBLE_ATCODER_2025
  extension UnsafeTreeV2 where Base: ___TreeIndex {

    public typealias Index = UnsafeIndexV3
  }
#endif

extension UnsafeTreeV2 where Base: _UnsafeNodePtrType & _BaseNode_SignedDistanceInterface {

  @inlinable
  @inline(__always)
  internal func
    ___distance(from start: _TieWrappedPtr, to end: _TieWrappedPtr) -> Int?
  {
    return try? lifetA2(
      __purified_(start).map(\.pointer),
      __purified_(end).map(\.pointer),
      Base.___signed_distance
    )
    .get()
  }

  @inlinable
  @inline(__always)
  internal func
    ___distance(
      from start: RedBlackTreeBoundExpression<_Key>, to end: RedBlackTreeBoundExpression<_Key>
    ) -> Int?
  {
    return try? lifetA2(
      start.evaluate(self).map(\.pointer),
      end.evaluate(self).map(\.pointer),
      Base.___signed_distance
    )
    .get()
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  func prev_iter(_ i: UnsafeIndexV3) -> UnsafeIndexV3 {
    __purified_(i)
      .flatMap { ___tree_prev_iter($0.pointer) }
      .flatMap { $0.sealed.band(tied) }
  }

  @inlinable
  @inline(__always)
  func next_iter(_ i: UnsafeIndexV3) -> UnsafeIndexV3 {
    __purified_(i)
      .flatMap { ___tree_next_iter($0.pointer) }
      .flatMap { $0.sealed.band(tied) }
  }

  @inlinable
  @inline(__always)
  func adv_iter(_ i: UnsafeIndexV3, offsetBy distance: Int) -> UnsafeIndexV3 {
    __purified_(i)
      .flatMap { ___tree_adv_iter($0.pointer, distance) }
      .flatMap { $0.sealed.band(tied) }
  }
}

extension UnsafeTreeV2 {

  public typealias _PayloadValues = RedBlackTreeIteratorV2.Values<Base>
}

extension UnsafeTreeV2 where Base: PairValueTrait {

  public typealias _KeyValues = RedBlackTreeIteratorV2.KeyValues<Base>
}
