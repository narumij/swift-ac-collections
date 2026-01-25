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

// https://atcoder.jp/contests/abc411/submissions/72757331
// ぶれがひどい

@inlinable
func growth(from count: Int, to minimum: Int) -> Int {
  // TODO: ジャッジ搭載のタイミングで再度チューニングすること
  if count < 3 {
    return Swift.max(minimum, count << 1)
  }
  return Swift.max(minimum, count + max(1, count))
}

extension UnsafeTreeV2BufferHeader {

  @inlinable
  @inline(__always)
  internal func _growthCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {
    linearly ? minimumCapacity : growth(from: count, to: minimumCapacity)
  }
}

// MARK: -

extension UnsafeTreeV2BufferHeader {

  @inlinable
  @inline(__always)
  internal mutating func grow(_ newCapacity: Int) {
    assert(freshPoolCapacity < newCapacity)
    pushFreshBucket(capacity: newCapacity - freshPoolCapacity)
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
  internal mutating func _ensureUnique() {
    let isUnique = isUnique()
    guard !isUnique else { return }
    withMutableHeader { header in
      self = header.copy()
    }
  }

  @inlinable
  @inline(__always)
  internal mutating func _strongEnsureUnique() {
    #if !USE_SIMPLE_COPY_ON_WRITE
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
      return _ensureUnique()
    #endif
  }
}

extension UnsafeTreeV2 {

  @inlinable @inline(__always)
  internal mutating func _ensureUniqueAndCapacity(
    to minimumCapacity: Int? = nil, linearly: Bool = false
  ) {
    let isUnique = isUnique()

    withMutableHeader { header in
      let minimumCapacity = minimumCapacity ?? (header.count + 1)
      let shouldExpand = header.freshPoolCapacity < minimumCapacity
      guard shouldExpand || !isUnique else { return }
      let growthCapacity = header._growthCapacity(
        to: minimumCapacity,
        linearly: linearly)
      if !isUnique {
        self = header.copy(minimumCapacity: growthCapacity)
        return
      }
      assert(isReadOnly == false)
      header.grow(growthCapacity)
    }
  }
}

extension UnsafeTreeV2 {

  @inlinable @inline(__always)
  internal mutating func _ensureCapacity(to minimumCapacity: Int? = nil, linearly: Bool = false) {

    withMutableHeader { header in
      let minimumCapacity = minimumCapacity ?? (header.count + 1)
      let shouldExpand = header.freshPoolCapacity < minimumCapacity
      guard shouldExpand else { return }
      let growthCapacity = header._growthCapacity(
        to: minimumCapacity,
        linearly: linearly)
      if isReadOnly {
        self = header.copy(minimumCapacity: growthCapacity)
        return
      }
      assert(isReadOnly == false)
      header.grow(growthCapacity)
    }
  }
}

extension UnsafeTreeV2 {

  @inlinable @inline(__always)
  internal mutating func _ensureCapacity(
    to minimumCapacity: Int? = nil, limit: Int, linearly: Bool = false
  ) {

    withMutableHeader { header in
      let minimumCapacity = min(limit, minimumCapacity ?? (header.count + 1))
      let shouldExpand = header.freshPoolCapacity < minimumCapacity
      guard shouldExpand else { return }
      let growthCapacity = header._growthCapacity(
        to: minimumCapacity,
        linearly: linearly)
      let limitedCapacity = min(limit, growthCapacity)
      assert(growthCapacity > 0)
      if isReadOnly {
        self = header.copy(minimumCapacity: limitedCapacity)
        return
      }
      assert(isReadOnly == false)
      header.grow(limitedCapacity)
    }
  }
}

// MARK: -

extension UnsafeTreeV2 {

  @inlinable @inline(__always)
  internal mutating func _ensureUnique(
    transform: (UnsafeTreeV2) throws -> UnsafeTreeV2
  )
    rethrows
  {
    _ensureUnique()
    self = try transform(self)
  }
}

// MARK: -

extension UnsafeTreeV2 {

  // 以前の名残でクラスメソッド経由となっている。取り除くリファクタリングをして構わない

  @inlinable
  @inline(__always)
  internal static func ensureCapacity(tree: inout UnsafeTreeV2, linearly: Bool = false) {
    tree._ensureCapacity(linearly: linearly)
  }

  @inlinable
  @inline(__always)
  internal static func ensureCapacity(
    tree: inout UnsafeTreeV2, minimumCapacity: Int, linearly: Bool = false
  ) {
    tree._ensureCapacity(to: minimumCapacity, linearly: linearly)
  }
}
