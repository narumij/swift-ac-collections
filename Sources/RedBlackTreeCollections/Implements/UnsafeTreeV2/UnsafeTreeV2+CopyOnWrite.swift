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

import Foundation

@inlinable
func growth(from count: Int, to minimum: Int) -> Int {
  // TODO: ジャッジ搭載のタイミングで再度チューニングすること

  if count == 0 {
    return Swift.max(minimum, 2)
  }

  if count < 3 {
    // scale factor 4.0 when small amount
    return Swift.max(minimum, count &<< 2)
  }

  // scale factor 1.5
  return Swift.max(minimum, count &+ (count &>> 1))
}

// ぶれがひどい
// https://atcoder.jp/contests/abc411/submissions/72757331
//return Swift.max(minimum, count + max(1, count))

// Bench0は以下がよい
// return Swift.max(minimum, count + max(1, count >> 3))

// 黄金比の4項近似
//return Swift.max(minimum, count + (count >> 1) + (count >> 4) + (count >> 5) + (count >> 8))

extension UnsafeTreeV2BufferHeader {

  @inlinable
  @inline(__always)
  internal func _growthCapacity(to minimumCapacity: Int) -> Int {
    growth(from: count, to: minimumCapacity)
  }
}

// MARK: -

extension UnsafeTreeV2BufferHeader {

  @inlinable
  internal mutating func grow(_ newCapacity: Int) {
    assert(freshPoolCapacity < newCapacity, "増加要求であること")
    pushFreshBucket(additionalCapacity: newCapacity - freshPoolCapacity)
  }

  @inlinable
  internal func _requestCapacity() -> (require: Int, request: Int) {
    let require = count &+ 1
    return (require, growth(from: count, to: require))
  }
}

extension UnsafeTreeV2BufferHeader {

  @usableFromInline  // 呼び出し元の命令キャッシュ圧低下を狙っている
  internal mutating func _ensureCapacity(to minimumCapacity: Int) {
    guard freshPoolCapacity < minimumCapacity else {
      return
    }
    grow(minimumCapacity)
    //    grow(growth(from: freshPoolCapacity, to: minimumCapacity))
  }

  @usableFromInline  // 呼び出し元の命令キャッシュ圧低下を狙っている
  internal mutating func _ensureCapacity() {
    let cap = _requestCapacity()
    guard freshPoolCapacity < cap.require else {
      return
    }
    grow(cap.request)
  }
}

extension UnsafeTreeV2BufferHeader {

  @usableFromInline  // 呼び出し元の命令キャッシュ圧低下を狙っている
  internal func _ensureUnique<Base>(to minimumCapacity: Int) -> UnsafeTreeV2<Base> {
    copy(minimumCapacity: minimumCapacity)
  }

  @usableFromInline  // 呼び出し元の命令キャッシュ圧低下を狙っている
  internal func _ensureUnique<Base>() -> UnsafeTreeV2<Base> {
    copy(minimumCapacity: _requestCapacity().request)
  }
}

// MARK: -

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal mutating func isUnique() -> Bool {
    _buffer.isUniqueReference()
  }

  @inlinable
  @inline(__always)
  internal mutating func ensureUnique() {
    let isUnique = isUnique()
    guard !isUnique else { return }
    withMutableHeader { header in
      self = header.copy()
    }
  }

  @inlinable
  @inline(__always)
  internal mutating func _strongEnsureUnique() {
    #if COMPATIBLE_ATCODER_2025
      let isTreeUnique = isUnique()
      let isPoolUnique =
        _buffer.header._tied == nil
        ? true : isKnownUniquelyReferenced(&_buffer.header._tied!)

      if isTreeUnique, isPoolUnique {
        /* NOP */
      } else {
        self = self.copy()
      }
    #else
      return ensureUnique()
    #endif
  }
}

extension UnsafeTreeV2 {

  @inlinable @inline(__always)
  internal mutating func ensureUniqueAndCapacity(to minimumCapacity: Int) {

    if !isUnique() {
      self = withMutableHeader { $0._ensureUnique(to: minimumCapacity) }
    } else {
      withMutableHeader { $0._ensureCapacity(to: minimumCapacity) }
    }
  }

  @inlinable @inline(__always)
  internal mutating func ensureUniqueAndCapacity() {

    if !isUnique() {
      self = withMutableHeader { $0._ensureUnique() }
    } else {
      withMutableHeader { $0._ensureCapacity() }
    }
  }
}

extension UnsafeTreeV2 {

  @inlinable @inline(__always)
  internal mutating func ensureCapacity(to minimumCapacity: Int) {

    if isReadOnly {
      self = withMutableHeader { $0._ensureUnique(to: minimumCapacity) }
    } else {
      assert(isReadOnly == false, "変更禁止シングルトンではないこと")
      withMutableHeader { $0._ensureCapacity(to: minimumCapacity) }
    }
  }

  @inlinable @inline(__always)
  internal mutating func ensureCapacity() {

    if isReadOnly {
      self = withMutableHeader { $0._ensureUnique() }
    } else {
      assert(isReadOnly == false, "変更禁止シングルトンではないこと")
      withMutableHeader { $0._ensureCapacity() }
    }
  }

  @inlinable @inline(__always)
  internal mutating func unsafeEnsureCapacity() {
    assert(isReadOnly == false, "変更禁止シングルトンではないこと")
    withMutableHeader { $0._ensureCapacity() }
  }
}

extension UnsafeTreeV2 {

  // LRUキャッシュ用

  @inlinable @inline(__always)
  internal mutating func ensureCapacity(
    to minimumCapacity: Int? = nil, limit: Int
  ) {

    withMutableHeader { header in
      let minimumCapacity = min(limit, minimumCapacity ?? (header.count &+ 1))
      let shouldExpand = header.freshPoolCapacity < minimumCapacity
      guard shouldExpand else { return }
      let newCapacity = header._growthCapacity(to: minimumCapacity)
      let limitedCapacity = min(limit, newCapacity)
      assert(newCapacity > 0, "以降の処理は容量変更の場合のみ呼ばれること")
      if isReadOnly {
        self = header.copy(minimumCapacity: limitedCapacity)
        return
      }
      assert(isReadOnly == false, "変更禁止シングルトンではないこと")
      header.grow(limitedCapacity)
    }
  }
}
