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
  internal mutating func ensureCapacity(limit: Int) {

    if isReadOnly {
      self = withMutableHeader { $0._ensureUnique(limit: limit) }
    } else {
      assert(isReadOnly == false, "変更禁止シングルトンではないこと")
      withMutableHeader { $0._ensureCapacity(limit: limit) }
    }
  }
}
