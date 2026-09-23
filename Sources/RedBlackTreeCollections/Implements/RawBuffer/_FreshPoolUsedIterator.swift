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
/// 使用歴ありのノードを列挙するイテレータ
@frozen
@usableFromInline
struct _FreshPoolUsedIterator<_PayloadValue>: IteratorProtocol, Sequence, _UnsafeNodePtrType {

  @usableFromInline
  typealias BucketPointer = UnsafeMutablePointer<_Bucket>

  @inlinable
  internal init(bucket: BucketPointer?, pairLayout: _MemoryLayout) {
    self.pairLayout = pairLayout
    self.helper = bucket.flatMap {
      $0._counts(
        storage: $0.primaryStorage(),
        pairLayout: pairLayout)
    }
  }

  @usableFromInline
  var helper: _BucketTraverser?
  
  @usableFromInline
  let pairLayout: _MemoryLayout

  @inlinable
  mutating func next() -> _NodePtr? {
    if let p = helper?.pop() {
      return p
    }
    helper = helper?.nextCounts(payload: pairLayout)
    return helper?.pop()
  }
}
