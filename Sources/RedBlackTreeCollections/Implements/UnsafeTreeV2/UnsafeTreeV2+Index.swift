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

    public typealias Index = RedBlackTreeIndex
  }
#endif

#if COMPATIBLE_ATCODER_2025
extension UnsafeTreeV2 {

  public typealias _PayloadValues = UnsafeIterator.Values<Base>
}

extension UnsafeTreeV2 where Base: PairValueTrait {

  public typealias _KeyValues = UnsafeIterator.KeyValues<Base>
}
#else
extension UnsafeTreeV2 {

  public typealias _PayloadValues = RedBlackTreeIterator.Values<Base>
}

extension UnsafeTreeV2 where Base: PairValueTrait {

  public typealias _KeyValues = RedBlackTreeIterator.KeyValues<Base>
}
#endif

extension UnsafeTreeV2 {

  // Result連鎖(`flatMap { index($0) }`)内で成功値を包む用途として残す
  @inlinable
  func index(_ p: _NodePtr) -> _LazyTieWrappedPtr {
    return withMutableHeader { $0.index(p) }
  }

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
  func prev_iter(_ i: _LazyTiedPtr) -> _LazyTiedPtr {
    let result = __purified_(i)
      .flatMap { ___tree_prev_iter($0.pointer) }
      .flatMap { index($0) }
    switch result {
    case .success(let index):
      return index
    case .failure(let error):
      fatalError(errorMessage(error))
    }
  }

  @inlinable
  func next_iter(_ i: _LazyTiedPtr) -> _LazyTiedPtr {
    let result = __purified_(i)
      .flatMap { ___tree_next_iter($0.pointer) }
      .flatMap { index($0) }
    switch result {
    case .success(let index):
      return index
    case .failure(let error):
      fatalError(errorMessage(error))
    }
  }

  @inlinable
  func adv_iter(_ i: _LazyTiedPtr, offsetBy distance: Int) -> _LazyTiedPtr {
    let result = __purified_(i)
      .flatMap { ___tree_adv_iter($0.pointer, distance) }
      .flatMap { index($0) }
    switch result {
    case .success(let index):
      return index
    case .failure(let error):
      fatalError(errorMessage(error))
    }
  }

  @inlinable
  func adv_iter(
    _ i: _LazyTiedPtr, offsetBy distance: Int, limitedBy limit: _LazyTiedPtr
  )
    -> _LazyTieWrappedPtr
  {
    __purified_(limit).flatMap { limit in
      __purified_(i)
        .flatMap { ___tree_adv_iter($0.pointer, distance, .success(limit.pointer)) }
        .flatMap { index($0) }
    }
  }

  @inlinable
  func index_or_nil(
    _ i: _LazyTiedPtr, offsetBy distance: Int, limitedBy limit: _LazyTiedPtr
  )
    -> _LazyTiedPtr?
  {
    switch adv_iter(i, offsetBy: distance, limitedBy: limit) {
    case .success(let index):
      return index
    case .failure(.limit):
      return nil
    case .failure(let error):
      fatalError(errorMessage(error))
    }
  }

  @inlinable
  func form_index(
    _ i: inout _LazyTiedPtr, offsetBy distance: Int, limitedBy limit: _LazyTiedPtr
  )
    -> Bool
  {
    // The environment-provided nullptr lives in ManagedBufferHeader. The first
    // traversal intentionally brings that header's cache line in before the
    // decision traversal invokes the API again. Do not fold these calls
    // together without remeasuring this path.
    let advanced = adv_iter(i, offsetBy: distance, limitedBy: limit)
    switch adv_iter(i, offsetBy: distance, limitedBy: limit) {
    case .success:
      if case .success(let index) = advanced {
        i = index
      }
      return true
    case .failure(.limit):
      i = limit
      return false
    case .failure(let error):
      fatalError(errorMessage(error))
    }
  }
}
