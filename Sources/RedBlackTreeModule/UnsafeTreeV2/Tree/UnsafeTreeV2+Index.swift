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

extension UnsafeTreeV2 where Base: ___TreeIndex {

  public typealias Index = UnsafeIndexV2<Base>
  public typealias Pointee = Base.Element

  @inlinable
  @inline(__always)
  internal func makeIndex(sealed: _SealedPtr) -> Index {
    .init(sealed: sealed, tie: tied)
  }
}

extension UnsafeTreeV2 where Base: ___TreeIndex {

  public typealias Indices = UnsafeIndexV2Collection<Base>
}

extension UnsafeTreeV2 where Base: ___TreeIndex {

  public typealias _PayloadValues = RedBlackTreeIteratorV2.Values<Base>
}

extension UnsafeTreeV2 where Base: KeyValueComparer & ___TreeIndex {

  public typealias _KeyValues = RedBlackTreeIteratorV2.KeyValues<Base>
}

extension UnsafeTreeV2 {

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

  @inlinable
  @inline(__always)
  internal func ___index(after i: _SealedPtr) -> _SealedPtr {
    i.flatMap { ___tree_next_iter($0.pointer) }.seal
  }

  @inlinable
  @inline(__always)
  internal func ___index(before i: _SealedPtr) -> _SealedPtr {
    i.flatMap { ___tree_prev_iter($0.pointer) }.seal
  }

  @inlinable
  @inline(__always)
  internal func ___index(_ i: _SealedPtr, offsetBy distance: Int) -> _SealedPtr {
    i.flatMap { ___tree_adv_iter($0.pointer, distance) }.seal
  }

  @inlinable
  @inline(__always)
  internal func
    ___index(_ i: _SealedPtr, offsetBy distance: Int, limitedBy limit: _SealedPtr)
    -> _SealedPtr?
  {
    let i = i.flatMap { ___tree_adv_iter($0.pointer, distance, limit.temporaryUnseal) }.seal
    return i.isError(.limit) ? nil : i
  }
}
