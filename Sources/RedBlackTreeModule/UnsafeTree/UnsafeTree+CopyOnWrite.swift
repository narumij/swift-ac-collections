// Copyright 2024-2025 narumij
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
// Copyright © 2003-2024 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

import Foundation

extension UnsafeTree {

  @nonobjc
  @inlinable
  @inline(__always)
  internal func bitCeil(_ n: Int) -> Int {
    n <= 1 ? 1 : 1 << (Int.bitWidth - (n - 1).leadingZeroBitCount)
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func growthFormula(count: Int) -> Int {
    #if true
      // アロケーターにとって負担が軽そうな、2のべき付近を要求することにした。
      // ヘッダー込みで確保するべきかどうかは、ManagedBufferのソースをみておらず不明。
      // はみ出して大量に無駄にするよりはましなので、ヘッダー込みでサイズ計算することにしている。
      let rawSize = bitCeil(MemoryLayout<UnsafeNode>.stride * count)
      return rawSize / MemoryLayout<UnsafeNode>.stride
    #else
      // メモリ使用量の多さが気になったので、標準Setと同じものに変更
      return Self.capacity(forScale: Self.scale(forCapacity: count))
    #endif
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        _header.initializedCount,
        minimumCapacity)
    }

    if minimumCapacity <= 4 {
      return Swift.max(
        _header.initializedCount,
        minimumCapacity
      )
    }

    if minimumCapacity <= 12 {
      return Swift.max(
        _header.initializedCount,
        freshPoolCapacity + (minimumCapacity - freshPoolCapacity) * 2
      )
    }

    // 手元の環境だと、サイズ24まではピタリのサイズを確保することができる
    // 小さなサイズの成長を抑制すると、ABC385Dでの使用メモリが抑えられやすい
    // 実行時間も抑制されやすいが、なぜなのかはまだ不明

    // ABC385Dの場合、アロケータープールなんかで使いまわしが効きやすいからなのではと予想している。

    return Swift.max(
      _header.initializedCount,
      growthFormula(count: minimumCapacity))
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func copy() -> UnsafeTree {
    copy(minimumCapacity: _header.initializedCount)
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func copy(growthCapacityTo capacity: Int, linearly: Bool) -> UnsafeTree {
    copy(
      minimumCapacity:
        growCapacity(to: capacity, linearly: linearly))
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func copy(growthCapacityTo capacity: Int, limit: Int, linearly: Bool) -> UnsafeTree {
    copy(
      minimumCapacity:
        Swift.min(
          growCapacity(to: capacity, linearly: linearly),
          limit))
  }
  
  @nonobjc
  @inlinable
  @inline(__always)
  internal func growthCapacity(to capacity: Int, linearly: Bool) {
    ensureCapacity(growCapacity(to: capacity, linearly: linearly))
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func growthCapacity(to capacity: Int, limit: Int, linearly: Bool) {
    ensureCapacity(Swift.min(growCapacity(to: capacity, linearly: linearly), limit))
  }
}

extension UnsafeTree {

  @nonobjc
  @inlinable
  @inline(__always)
  internal static func _isKnownUniquelyReferenced(tree: inout UnsafeTree) -> Bool {
    #if !DISABLE_COPY_ON_WRITE
      isKnownUniquelyReferenced(&tree)
    #else
      true
    #endif
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal static func ensureUniqueAndCapacity(tree: inout UnsafeTree) {
    ensureUniqueAndCapacity(tree: &tree, minimumCapacity: tree.count + 1)
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal static func ensureUniqueAndCapacity(tree: inout UnsafeTree, minimumCapacity: Int) {
    let shouldExpand = tree.freshPoolCapacity < minimumCapacity
    if !_isKnownUniquelyReferenced(tree: &tree) {
      tree = tree.copy(growthCapacityTo: minimumCapacity, linearly: false)
    } else if shouldExpand {
      _ = tree.growCapacity(to: minimumCapacity, linearly: false)
    }
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal static func ensureCapacity(tree: inout UnsafeTree) {
    ensureCapacity(tree: &tree, minimumCapacity: tree.count + 1)
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal static func ensureCapacity(tree: inout UnsafeTree, minimumCapacity: Int) {
    if tree.freshPoolCapacity < minimumCapacity {
//      tree = tree.copy(growthCapacityTo: minimumCapacity, linearly: false)
      tree.growthCapacity(to: minimumCapacity, linearly: false)
    }
  }
}

// from https://github.com/swiftlang/swift/blob/main/stdlib/public/core/Integers.swift
// LICENCE: https://github.com/swiftlang/swift/blob/main/LICENSE.txt
// Apache License 2.0 LLVM exception

#if UNSAFE_TREE_PROJECT
extension FixedWidthInteger {

  @inlinable
  internal func _binaryLogarithm() -> Int {
    return Self.bitWidth &- (leadingZeroBitCount &+ 1)
  }
}
#endif

// from https://github.com/swiftlang/swift/blob/main/stdlib/public/core/HashTable.swift
// LICENCE: https://github.com/swiftlang/swift/blob/main/LICENSE.txt
// Apache License 2.0 LLVM exception

extension UnsafeTree {

  /// The inverse of the maximum hash table load factor.
  @inlinable
  internal static var maxLoadFactor: Double {
    return 3 / 4
  }

  @inlinable
  internal static func capacity(forScale scale: Int8) -> Int {
    let bucketCount = (1 as Int) &<< scale
    return Int(Double(bucketCount) * maxLoadFactor)
  }

  @inlinable
  internal static func scale(forCapacity capacity: Int) -> Int8 {
    let capacity = Swift.max(capacity, 1)
    // Calculate the minimum number of entries we need to allocate to satisfy
    // the maximum load factor. `capacity + 1` below ensures that we always
    // leave at least one hole.
    let minimumEntries = Swift.max(
      Int((Double(capacity) / maxLoadFactor).rounded(.up)),
      capacity + 1)
    // The actual number of entries we need to allocate is the lowest power of
    // two greater than or equal to the minimum entry count. Calculate its
    // exponent.
    let exponent = (Swift.max(minimumEntries, 2) - 1)._binaryLogarithm() + 1
    //    _internalInvariant(exponent >= 0 && exponent < Int.bitWidth)
    // The scale is the exponent corresponding to the bucket count.
    let scale = Int8(truncatingIfNeeded: exponent)
    //    unsafe _internalInvariant(self.capacity(forScale: scale) >= capacity)
    return scale
  }
}
