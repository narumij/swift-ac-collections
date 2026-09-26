//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project.
//
// Copyright (c) 2024-2026 narumij.
// Licensed under the Apache License v2.0.
//
// SPDX-License-Identifier: Apache-2.0
//
// This implementation includes code derived from LLVM libc++'s red-black tree
// implementation, originally distributed under the Apache License v2.0 with
// LLVM Exceptions.
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by
// narumij.
//
//===----------------------------------------------------------------------===//

#if !COMPATIBLE_ATCODER_2025
  extension UnsafeTreeV2 where Base: ___TreeIndex {

    public typealias Index = UnsafeIndexV3
  }
#endif

extension UnsafeTreeV2 {

  public typealias _PayloadValues = RedBlackTreeIteratorV2.Values<Base>
}

extension UnsafeTreeV2 where Base: PairValueTrait {

  public typealias _KeyValues = RedBlackTreeIteratorV2.KeyValues<Base>
}

extension UnsafeTreeV2 {

  @inlinable
  func index(_ p: _NodePtr) -> _LazyTieWrappedPtr {
    return withMutableHeader { $0.index(p) }
  }

  @inlinable
  func index_or_nil(_ p: _NodePtr) -> _LazyTieWrappedPtr? {
    return withMutableHeader { $0.index_or_nil(p) }
  }
}

extension UnsafeTreeV2 {

  @inlinable
  func index(_ p: _NodePtr) -> _LazyTiedPtr {
    return withMutableHeader { $0.index(p) }
  }

  @inlinable
  func index_or_nil(_ p: _NodePtr) -> _LazyTiedPtr? {
    return withMutableHeader { $0.index_or_nil(p) }
  }
}

extension UnsafeTreeV2 where Base: _UnsafeNodePtrType & _BaseNode_SignedDistanceInterface {

  @inlinable
  internal func
    distance(from start: UnsafeIndexV3, to end: UnsafeIndexV3) -> Int?
  {
    return try? liftA2(
      __purified_(start).map(\.pointer),
      __purified_(end).map(\.pointer),
      Base.___signed_distance
    )
    .get()
  }

  @inlinable
  internal func
    distance(
      from start: RedBlackTreeBoundExpression<_Key>, to end: RedBlackTreeBoundExpression<_Key>
    ) -> Int?
  {
    return try? liftA2(
      start.evaluate(self),
      end.evaluate(self),
      Base.___signed_distance
    )
    .get()
  }
}

extension UnsafeTreeV2 {

  @inlinable
  func prev_iter(_ i: _LazyTieWrappedPtr) -> _LazyTieWrappedPtr {
    __purified_(i)
      .flatMap { ___tree_prev_iter($0.pointer) }
      .flatMap { index($0) }
      .mapError { _ in fatalError() }
  }

  @inlinable
  func next_iter(_ i: _LazyTieWrappedPtr) -> _LazyTieWrappedPtr {
    __purified_(i)
      .flatMap { ___tree_next_iter($0.pointer) }
      .flatMap { index($0) }
      .mapError { _ in fatalError() }
  }

  @inlinable
  func adv_iter(_ i: _LazyTieWrappedPtr, offsetBy distance: Int) -> _LazyTieWrappedPtr {
    __purified_(i)
      .flatMap { ___tree_adv_iter($0.pointer, distance) }
      .flatMap { index($0) }
      .mapError { _ in fatalError() }
  }

  @inlinable
  func adv_iter(
    _ i: _LazyTieWrappedPtr, offsetBy distance: Int, limitedBy limit: _LazyTieWrappedPtr
  )
    -> _LazyTieWrappedPtr
  {
    let __l = __purified_(limit).map(\.pointer)
    return __purified_(i)
      .flatMap { ___tree_adv_iter($0.pointer, distance, __l) }
      .flatMap { index($0) }
  }

  @inlinable
  func index_or_nil(
    _ i: _LazyTieWrappedPtr, offsetBy distance: Int, limitedBy limit: _LazyTieWrappedPtr
  )
    -> _LazyTieWrappedPtr?
  {
    let advanced = adv_iter(i, offsetBy: distance, limitedBy: limit)
    switch advanced {
    case .success:
      return advanced
    case .failure(.limit):
      return nil
    case .failure:
      fatalError()
    }
  }

  @inlinable
  func form_index(
    _ i: inout _LazyTieWrappedPtr, offsetBy distance: Int, limitedBy limit: _LazyTieWrappedPtr
  )
    -> Bool
  {
    let advanced = adv_iter(i, offsetBy: distance, limitedBy: limit)
    switch adv_iter(i, offsetBy: distance, limitedBy: limit) {
    case .success:
      i = advanced
      return true
    case .failure(.limit):
      i = limit
      return false
    default:
      fatalError()
    }
  }
}

extension UnsafeTreeV2 {

  @inlinable
  func prev_iter(_ i: _LazyTiedPtr) -> _LazyTiedPtr {
    try! __purified_(i)
      .flatMap { ___tree_prev_iter($0.pointer) }
      .flatMap { index($0) }
      .get()
  }

  @inlinable
  func next_iter(_ i: _LazyTiedPtr) -> _LazyTiedPtr {
    try! __purified_(i)
      .flatMap { ___tree_next_iter($0.pointer) }
      .flatMap { index($0) }
      .get()
  }

  @inlinable
  func adv_iter(_ i: _LazyTiedPtr, offsetBy distance: Int) -> _LazyTiedPtr {
    try! __purified_(i)
      .flatMap { ___tree_adv_iter($0.pointer, distance) }
      .flatMap { index($0) }
      .get()
  }

  @inlinable
  func adv_iter(
    _ i: _LazyTiedPtr, offsetBy distance: Int, limitedBy limit: _LazyTiedPtr
  )
    -> _LazyTieWrappedPtr
  {
    let __l = __purified_(limit).map(\.pointer)
    return __purified_(i)
      .flatMap { ___tree_adv_iter($0.pointer, distance, __l) }
      .flatMap { index($0) }
  }

  @inlinable
  func index_or_nil(
    _ i: _LazyTiedPtr, offsetBy distance: Int, limitedBy limit: _LazyTiedPtr
  )
    -> _LazyTiedPtr?
  {
    let advanced = adv_iter(i, offsetBy: distance, limitedBy: limit)
    switch advanced {
    case .success:
      return try? advanced.get()
    case .failure(.limit):
      return nil
    case .failure:
      fatalError()
    }
  }

  @inlinable
  func form_index(
    _ i: inout _LazyTiedPtr, offsetBy distance: Int, limitedBy limit: _LazyTiedPtr
  )
    -> Bool
  {
    let advanced = adv_iter(i, offsetBy: distance, limitedBy: limit)
    switch adv_iter(i, offsetBy: distance, limitedBy: limit) {
    case .success:
      if let a = try? advanced.get() {
        i = a
      }
      return true
    case .failure(.limit):
      i = limit
      return false
    case .failure:
      fatalError()
    }
  }
}
