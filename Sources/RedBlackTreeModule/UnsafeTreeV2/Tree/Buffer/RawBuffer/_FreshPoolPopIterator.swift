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

/// 使用済みから初期化済みまでを列挙するイテレータ
@frozen
@usableFromInline
struct _FreshPoolPopIterator<_Value>: IteratorProtocol, Sequence, _UnsafeNodePtrType {

  @usableFromInline
  typealias BucketPointer = UnsafeMutablePointer<_Bucket>

  @inlinable
  @inline(__always)
  internal init(bucket: BucketPointer?) {
    self.helper = bucket.flatMap {
      $0._counts(
        isHead: true,
        memoryLayout:
          MemoryLayout<_Value>._memoryLayout)
    }
  }

  @usableFromInline
  var helper: _BucketTraverser?

  @inlinable
  @inline(__always)
  mutating func next() -> _NodePtr? {
    if let p = helper?.pop() {
      return p
    }
    helper = helper?.nextCounts(memoryLayout: MemoryLayout<_Value>._memoryLayout)
    return helper?.pop()
  }
}
