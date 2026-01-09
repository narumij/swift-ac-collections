// Copyright 2024-2026 narumij
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2025 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

@usableFromInline
typealias ReferenceCounter = ManagedBuffer<Void, Void>

extension ManagedBuffer where Header == Void, Element == Void {

  @inlinable
  @inline(__always)
  static func create() -> ManagedBuffer {
    ManagedBuffer<Void, Void>.create(minimumCapacity: 0) { _ in }
  }
}

@usableFromInline
protocol ___UnsafeCopyOnWriteV2 {
  associatedtype Base: ___TreeBase
  #if !USE_SIMPLE_COPY_ON_WRITE || COMPATIBLE_ATCODER_2025
    /// 2段階CoWを実現するためのプロパティ
    ///
    /// 競技プログラミングでの利用ではできる限りCopyを避けたかった。
    /// これを実現するためにコンテナ本体のユニーク参照と木のユニーク参照とを分けることにした。
    ///
    /// multimap等では中身の破壊が起きやすいので木のユニーク参照判定をしている。
    ///
    /// 性能が向上し、コピーを避ける必要があるかまだ判断がつかないので維持している。
    ///
    /// 一般的なCoW動作の方が一般向けと今のところ考えており、このモジュールを一般利用可能にするにあたっては、
    /// これを利用しない判断をする可能性が高い。
    var referenceCounter: ReferenceCounter { get set }
  #endif
  var __tree_: UnsafeTreeV2<Base> { get set }
}

extension ___UnsafeCopyOnWriteV2 {

  @inlinable
  @inline(__always)
  internal mutating func _isKnownUniquelyReferenced_LV1() -> Bool {
    #if !DISABLE_COPY_ON_WRITE
      #if !USE_SIMPLE_COPY_ON_WRITE || COMPATIBLE_ATCODER_2025
        !__tree_.isReadOnly && isKnownUniquelyReferenced(&referenceCounter)
      #else
        __tree_._buffer.isUniqueReference()
      #endif
    #else
      true
    #endif
  }

  @inlinable
  @inline(__always)
  internal mutating func _isKnownUniquelyReferenced_LV2() -> Bool {
    #if !DISABLE_COPY_ON_WRITE
      if !_isKnownUniquelyReferenced_LV1() {
        return false
      }
      if !__tree_._buffer.isUniqueReference() {
        return false
      }
    #endif
    return true
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureUnique() {
    if !_isKnownUniquelyReferenced_LV1() {
      __tree_ = __tree_.copy()
    }
  }

  @inlinable
  @inline(__always)
  internal mutating func _strongEnsureUnique() {
    if !_isKnownUniquelyReferenced_LV2() {
      __tree_ = __tree_.copy()
    }
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureUnique(
    transform: (UnsafeTreeV2<Base>) throws -> UnsafeTreeV2<Base>
  )
    rethrows
  {
    _ensureUnique()
    __tree_ = try transform(__tree_)
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureUniqueAndCapacity() {
    _ensureUniqueAndCapacity(to: __tree_.count + 1)
    assert(__tree_.capacity > 0)
    assert(__tree_.capacity > __tree_.count)
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureUniqueAndCapacity(to minimumCapacity: Int) {
    let shouldExpand = __tree_.capacity < minimumCapacity
    if !_isKnownUniquelyReferenced_LV1() {
      __tree_ = __tree_.copy(growthCapacityTo: minimumCapacity, linearly: false)
    } else if shouldExpand {
      __tree_.growthCapacity(to: minimumCapacity, linearly: false)
    }
    assert(__tree_.initializedCount <= __tree_.capacity)
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureUniqueAndCapacity(limit: Int, linearly: Bool = false) {
    _ensureUniqueAndCapacity(to: __tree_.count + 1, limit: limit, linearly: linearly)
    assert(__tree_.capacity > 0)
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureUniqueAndCapacity(
    to minimumCapacity: Int, limit: Int, linearly: Bool
  ) {
    let shouldExpand = __tree_.capacity < minimumCapacity
    if !_isKnownUniquelyReferenced_LV1() {
      __tree_ = __tree_.copy(
        growthCapacityTo: minimumCapacity,
        limit: limit,
        linearly: false)
    } else if shouldExpand {
      __tree_.growthCapacity(to: minimumCapacity, limit: limit, linearly: false)
    }
    assert(__tree_.capacity >= minimumCapacity)
    assert(__tree_.initializedCount <= __tree_.capacity)
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureCapacity() {
    _ensureCapacity(amount: 1)
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureCapacity(amount: Int) {
    let minimumCapacity = __tree_.count + amount
    if __tree_.capacity < minimumCapacity {
      __tree_.growthCapacity(to: minimumCapacity, linearly: false)
    }
    assert(__tree_.capacity >= minimumCapacity)
    assert(__tree_.initializedCount <= __tree_.capacity)
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureCapacity(limit: Int, linearly: Bool = false) {
    _ensureCapacity(to: __tree_.count + 1, limit: limit, linearly: linearly)
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureCapacity(to minimumCapacity: Int, limit: Int, linearly: Bool) {
//    assert(__tree_.capacity <= minimumCapacity)
    if __tree_.capacity < min(limit, minimumCapacity) {
      __tree_.growthCapacity(to: min(limit, minimumCapacity), limit: limit, linearly: false)
    }
//    assert(__tree_.capacity >= minimumCapacity)
#if USE_FRESH_POOL_V1
    assert(__tree_.initializedCount <= __tree_.capacity)
#else
    assert(__tree_.initializedCount <= __tree_._buffer.header.freshPool.capacity)
#endif
  }
}
