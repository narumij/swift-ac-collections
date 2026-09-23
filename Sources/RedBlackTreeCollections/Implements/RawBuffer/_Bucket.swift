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

// NOTE: 性能過敏なので修正する場合は必ず計測しながら行うこと
@frozen
@usableFromInline
package struct _Bucket {

  @usableFromInline
  package typealias _Next = UnsafeMutablePointer<_Bucket>

  @inlinable
  package init(capacity c: Int) {
    capacity = c
  }

  /// 次のバケットへのポインタ
  @usableFromInline
  package var next: _Next? = nil
  /// 確保数
  @usableFromInline
  package let capacity: Int
  /// 使用数
  @usableFromInline
  package var count: Int = 0
}

extension UnsafeMutablePointer where Pointee == _Bucket {

  /// 次のバケットへのポインタ
  @inlinable
  var next: UnsafeMutablePointer? { pointee.next }

  /// 確保数
  @inlinable
  var capacity: Int { pointee.capacity }

  /// 使用数
  @inlinable
  var count: Int { pointee.count }

  /// beginノードポインタの開始アドレスを返す
  ///
  /// 先頭バケットにしか配置されていない
  ///
  /// __Primary Bucket__
  ///
  /// ```
  /// |Bucket|ptr|Node||Node|Value|Node|Value|...
  ///        ^--begin_ptr
  /// ```
  @inlinable
  var begin_ptr: UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>> {
    UnsafeMutableRawPointer(advanced(by: 1))
      .assumingMemoryBound(to: UnsafeMutablePointer<UnsafeNode>.self)
  }

  /// endノードの開始アドレスを返す
  ///
  /// 先頭バケットにしか配置されていない
  ///
  /// __Primary Bucket__
  ///
  /// ```
  /// |Bucket|ptr|Node||Node|Value|Node|Value|...
  ///            ^--end_ptr
  /// ```
  @inlinable
  var end_ptr: UnsafeMutablePointer<UnsafeNode> {
    UnsafeMutableRawPointer(begin_ptr.advanced(by: 1))
      .assumingMemoryBound(to: UnsafeNode.self)
  }

  /// アライメント調整ギャップも含めた開始アドレスを返す
  ///
  /// __Primary Bucket__
  ///
  /// ```
  /// |Bucket|ptr|Node| |Node|Value|Node|Value|...
  ///                 ^--storage
  /// ```
  ///
  /// __Secondary and other Buckets__
  /// ```
  /// |Bucket| |Node|Value|Node|Value|...
  ///        ^--storage
  /// ```
  ///
  /// 確保数0の場合、確保領域の末尾の次のアドレスとなる
  @inlinable
  func storage(isPrimary: Bool) -> UnsafeMutableRawPointer {
    isPrimary ? primaryStorage() : secondaryStorage()
  }

  @inlinable
  package func primaryStorage() -> UnsafeMutableRawPointer {
    UnsafeMutableRawPointer(end_ptr.advanced(by: 1))
  }

  @inlinable
  package func secondaryStorage() -> UnsafeMutableRawPointer {
    UnsafeMutableRawPointer(advanced(by: 1))
  }

  /// ノードの開始アドレスを返す
  ///
  /// `Node|Payload` と隣接させるために必要なアライメント調整後のアドレスとなる
  ///
  /// __Primary Bucket__
  ///
  /// ```
  /// |Bucket|begin ptr|end Node| |Node|Payload|Node|Payload|...
  ///                           ^- storage
  ///                             ^-------start
  ///                             ^-------node(0)
  ///                             ^-------(node alignment)
  ///                                  ^-payload
  ///                                  ^-(payload alignment)
  /// ```
  ///
  /// __Secondary and other Buckets__
  /// ```
  /// |Bucket| |Node|Payload|Node|Payload|...
  ///        ^- storage
  ///          ^-------start
  ///          ^-------node(0)
  ///          ^-------(node alignment)
  ///               ^-payload(0)
  ///               ^-(payload alignment)
  /// ```
  ///
  /// - Parameters:
  ///   - storage: Bucket固有のメタデータ直後にある、alignment調整前のslot領域先頭アドレス。
  ///   - payloadAlignment: Payload型に要求されるalignment。max(node, payload)で構わない。
  ///
  /// - Returns: `node(0)`、すなわち最初の通常ノードの開始アドレス。
  ///
  /// - WARNING: 確保数0の場合利用してはならない
  ///
  @inlinable
  package func start(storage: UnsafeMutableRawPointer, payloadOrPairAlignment payloadAlignment: Int) -> UnsafeMutablePointer<
    UnsafeNode
  > {
    let nodeAlignment = MemoryLayout<UnsafeNode>.alignment
    if payloadAlignment <= nodeAlignment {
      return
        storage
        .assumingMemoryBound(to: UnsafeNode.self)
    }
    return
      storage
      .advanced(by: MemoryLayout<UnsafeNode>.stride)
      .alignedUp(toMultipleOf: payloadAlignment)
      .advanced(by: -MemoryLayout<UnsafeNode>.stride)
      .assumingMemoryBound(to: UnsafeNode.self)
  }
  
  @inlinable
  package func start(storage: UnsafeMutableRawPointer, nodeLayout: _MemoryLayout, payloadOrPairAlignment payloadAlignment: Int) -> UnsafeMutablePointer<
    UnsafeNode
  > {
    let nodeAlignment = nodeLayout.alignment
    if payloadAlignment <= nodeAlignment {
      return
        storage
        .assumingMemoryBound(to: UnsafeNode.self)
    }
    return
      storage
      .advanced(by: nodeLayout.stride)
      .alignedUp(toMultipleOf: payloadAlignment)
      .advanced(by: -nodeLayout.stride)
      .assumingMemoryBound(to: UnsafeNode.self)
  }
}
