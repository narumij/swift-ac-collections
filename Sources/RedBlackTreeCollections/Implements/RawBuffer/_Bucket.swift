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
  func storage(isHead: Bool) -> UnsafeMutableRawPointer {
    isHead ? primaryStorage() : secondaryStorage()
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
  /// `Node|Value` と隣接させるために必要なアライメント調整後のアドレスとなる
  ///
  /// __Primary Bucket__
  ///
  /// ```
  /// |Bucket|ptr|Node| |Node|Value|Node|Value|...
  ///                   ^--start
  /// ```
  ///
  /// __Secondary and other Buckets__
  /// ```
  /// |Bucket| |Node|Value|Node|Value|...
  ///          ^--start
  /// ```
  /// - WARNING: 確保数0の場合利用してはならない
  ///
  @inlinable
  package func start(storage: UnsafeMutableRawPointer, valueAlignment: Int) -> UnsafeMutablePointer<
    UnsafeNode
  > {
    let headerAlignment = MemoryLayout<UnsafeNode>.alignment
    if valueAlignment <= headerAlignment {
      return
        storage
        .assumingMemoryBound(to: UnsafeNode.self)
    }
    return
      storage
      .advanced(by: MemoryLayout<UnsafeNode>.stride)
      .alignedUp(toMultipleOf: valueAlignment)
      .advanced(by: -MemoryLayout<UnsafeNode>.stride)
      .assumingMemoryBound(to: UnsafeNode.self)
  }
}
