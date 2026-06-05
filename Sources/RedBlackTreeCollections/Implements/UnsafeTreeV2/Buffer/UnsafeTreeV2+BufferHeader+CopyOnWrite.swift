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

@inlinable
func growth(from count: Int, to minimum: Int) -> Int {
  // TODO: ジャッジ搭載のタイミングで再度チューニングすること

  #if true
    if count == 0 {
      return Swift.max(minimum, 2)
    }

    if count < 9 {
      // 0,  2,  8, 16, 24,  36,  54
      // 0, +2, +6, +8, +8, +12, +18
      // アロケーション発生タイミングを分散することで要素あたりのコストを下げたい
      // つまり、+1が混じらないようにしている

      // scale factor 4.0 when small amount
      return Swift.max(minimum, count &<< 2)
    }
  #endif

  // scale factor 1.5
  return Swift.max(minimum, count &+ (count &>> 1))

  // scale factor 2.0
  //  return Swift.max(minimum, count &+ count)
}

// ぶれがひどい
// https://atcoder.jp/contests/abc411/submissions/72757331
// return Swift.max(minimum, count &+ max(1, count))

// Bench0は以下がよい
// return Swift.max(minimum, count &+ max(1, count &>> 3))

// 黄金比の4項近似
// return Swift.max(minimum, count &+ (count &>> 1) &+ (count &>> 4) &+ (count &>> 5) &+ (count &>> 8))

// MARK: -

extension UnsafeTreeV2BufferHeader {

  @inlinable
  internal mutating func grow(_ newCapacity: Int) {
    assert(freshPoolCapacity < newCapacity, "増加要求であること")
    pushFreshBucket(additionalCapacity: newCapacity &- freshPoolCapacity)
  }

  @inlinable
  internal func _requestCapacity() -> (require: Int, request: Int) {
    let require = count &+ 1
    return (require, growth(from: count, to: require))
  }

  @inlinable
  internal func _requestCapacity(limit: Int) -> (require: Int, request: Int) {
    let require = count &+ 1
    return (min(limit, require), min(limit, growth(from: count, to: require)))
  }
}

extension UnsafeTreeV2BufferHeader {

  // reserveCapacity用

  @usableFromInline  // 呼び出し元の命令キャッシュ圧低下を狙っている
  internal mutating func _ensureCapacitySlow(to minimumCapacity: Int) {
    guard freshPoolCapacity < minimumCapacity else {
      return
    }
    grow(minimumCapacity)
    //    grow(growth(from: freshPoolCapacity, to: minimumCapacity))
  }

  @usableFromInline  // 呼び出し元の命令キャッシュ圧低下を狙っている
  internal mutating func _ensureCapacitySlow() {
    let cap = _requestCapacity()
    guard freshPoolCapacity < cap.require else {
      return
    }
    grow(cap.request)
  }

  // LRU用

  @usableFromInline  // 呼び出し元の命令キャッシュ圧低下を狙っている
  internal mutating func _ensureCapacitySlow(limit: Int) {
    let cap = _requestCapacity(limit: limit)
    guard freshPoolCapacity < cap.require else {
      return
    }
    grow(cap.request)
  }
}

extension UnsafeTreeV2BufferHeader {

  // reserveCapacity用

  @usableFromInline  // 呼び出し元の命令キャッシュ圧低下を狙っている
  internal func _ensureUniqueSlow<Base>(to minimumCapacity: Int) -> UnsafeTreeV2<Base> {
    copy(minimumCapacity: minimumCapacity)
  }

  @usableFromInline  // 呼び出し元の命令キャッシュ圧低下を狙っている
  internal func _ensureUniqueSlow<Base>() -> UnsafeTreeV2<Base> {
    copy(minimumCapacity: _requestCapacity().request)
  }
}
