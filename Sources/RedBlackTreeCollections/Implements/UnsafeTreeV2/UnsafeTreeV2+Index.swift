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

extension UnsafeTreeV2 {

  public typealias _PayloadValues = RedBlackTreeIteratorV2.Values<Base>
}

extension UnsafeTreeV2 where Base: PairValueTrait {

  public typealias _KeyValues = RedBlackTreeIteratorV2.KeyValues<Base>
}

extension UnsafeTreeV2 where Base: _UnsafeNodePtrType & _BaseNode_SignedDistanceInterface {

  @inlinable
  internal func
    distance(from start: UnsafeIndexV3, to end: UnsafeIndexV3) -> Int?
  {
    return try? lifetA2(
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
  func prev_iter(_ i: _TieWrappedPtr) -> _TieWrappedPtr {
    __purified_(i)
      .flatMap { ___tree_prev_iter($0.pointer) }
      .flatMap { $0.sealed.band(tied) }
  }

  @inlinable
  func next_iter(_ i: _TieWrappedPtr) -> _TieWrappedPtr {
    __purified_(i)
      .flatMap { ___tree_next_iter($0.pointer) }
      .flatMap { $0.sealed.band(tied) }
  }

  @inlinable
  func adv_iter(_ i: _TieWrappedPtr, offsetBy distance: Int) -> _TieWrappedPtr {
    __purified_(i)
      .flatMap { ___tree_adv_iter($0.pointer, distance) }
      .flatMap { $0.sealed.band(tied) }
  }

  @inlinable
  func adv_iter(_ i: _TieWrappedPtr, offsetBy distance: Int, limitedBy limit: _TieWrappedPtr)
    -> _TieWrappedPtr
  {
    let __l = __purified_(limit).map(\.pointer)
    return __purified_(i)
      .flatMap { ___tree_adv_iter($0.pointer, distance, __l) }
      .flatMap { $0.sealed.band(tied) }
  }

  @inlinable
  func index_or_nil(_ i: _TieWrappedPtr, offsetBy distance: Int, limitedBy limit: _TieWrappedPtr)
    -> _TieWrappedPtr?
  {
    let advanced = adv_iter(i, offsetBy: distance, limitedBy: limit)
    switch advanced {
    case .success:
      return advanced
    case .failure:
      return nil
    }
  }

  @inlinable
  func form_index(
    _ i: inout _TieWrappedPtr, offsetBy distance: Int, limitedBy limit: _TieWrappedPtr
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
      return false
    }
  }
}

extension UnsafeTreeV2 {

  @inlinable
  func prev_iter(_ i: _LazyDetachPointer) -> _LazyDetachPointer {
    __purified_(i)
      .flatMap { ___tree_prev_iter($0.pointer) }
      .flatMap { $0.sealed.band(lazyDetach) }
  }

  @inlinable
  func next_iter(_ i: _LazyDetachPointer) -> _LazyDetachPointer {
    __purified_(i)
      .flatMap { ___tree_next_iter($0.pointer) }
      .flatMap { $0.sealed.band(lazyDetach) }
  }

  @inlinable
  func adv_iter(_ i: _LazyDetachPointer, offsetBy distance: Int) -> _LazyDetachPointer {
    __purified_(i)
      .flatMap { ___tree_adv_iter($0.pointer, distance) }
      .flatMap { $0.sealed.band(lazyDetach) }
  }

  @inlinable
  func adv_iter(_ i: _LazyDetachPointer, offsetBy distance: Int, limitedBy limit: _LazyDetachPointer)
    -> _LazyDetachPointer
  {
    let __l = __purified_(limit).map(\.pointer)
    return __purified_(i)
      .flatMap { ___tree_adv_iter($0.pointer, distance, __l) }
      .flatMap { $0.sealed.band(lazyDetach) }
  }

  @inlinable
  func index_or_nil(_ i: _LazyDetachPointer, offsetBy distance: Int, limitedBy limit: _LazyDetachPointer)
    -> _LazyDetachPointer?
  {
    let advanced = adv_iter(i, offsetBy: distance, limitedBy: limit)
    switch advanced {
    case .success:
      return advanced
    case .failure:
      return nil
    }
  }

  @inlinable
  func form_index(
    _ i: inout _LazyDetachPointer, offsetBy distance: Int, limitedBy limit: _LazyDetachPointer
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
      return false
    }
  }
}


#if false
extension UnsafeTreeV2 {

  // Span対応準備のための実験コード
  func nextBuffer(_ index: inout _TieWrappedPtr) -> UnsafeMutableBufferPointer<_PayloadValue>? {
    defer { index = next_iter(index) }
    return try? __purified_(index).map { Base.__payload_buffer($0.pointer) }.get()
  }
}

extension RedBlackTreeSet {

  // Spanは初期化が解放されてないようなので、OutputSpanで実験
  // いまいちうまくいかない。そもそも~Copyableな本体じゃ無いとだめかも？
  // それ以外にも、辞書の場合どうなるんだろう？という疑問がある
  @_lifetime(borrow self)
  func nextSpan(after index: inout Index, maximumCount: Int) -> OutputSpan<Element> {
    .init(buffer: __tree_.nextBuffer(&index)!, initializedCount: 1)
  }
}
#endif
