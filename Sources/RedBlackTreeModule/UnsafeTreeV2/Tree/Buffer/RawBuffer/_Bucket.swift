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

  public typealias _Next = UnsafeMutablePointer<_Bucket>

  public init(capacity: Int) {
    self.capacity = capacity
  }

  /// 次のバケットへのポインタ
  public var next: _Next? = nil
  /// 確保数
  public let capacity: Int
  /// 使用数
  public var count: Int = 0
}

extension UnsafeMutablePointer where Pointee == _Bucket {
  
  /// 次のバケットへのポインタ
  @inlinable
  @inline(__always)
  var next: UnsafeMutablePointer? { pointee.next }
  
  /// 確保数
  @inlinable
  @inline(__always)
  var capacity: Int { pointee.capacity }
  
  /// 使用数
  @inlinable
  @inline(__always)
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
  @inline(__always)
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
  @inline(__always)
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
    if isHead {
      UnsafeMutableRawPointer(end_ptr.advanced(by: 1))
    } else {
      UnsafeMutableRawPointer(advanced(by: 1))
    }
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
  @inline(__always)
  package func start(isHead: Bool, valueAlignment: Int) -> UnsafeMutablePointer<UnsafeNode> {
    let headerAlignment = MemoryLayout<UnsafeNode>.alignment
    if valueAlignment <= headerAlignment {
      return storage(isHead: isHead)
        .assumingMemoryBound(to: UnsafeNode.self)
    }
    return storage(isHead: isHead)
      .advanced(by: MemoryLayout<UnsafeNode>.stride)
      .alignedUp(toMultipleOf: valueAlignment)
      .advanced(by: -MemoryLayout<UnsafeNode>.stride)
      .assumingMemoryBound(to: UnsafeNode.self)
  }
}
