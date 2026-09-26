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
// accessor、traverser、queueと似た3種は、場面毎に特化したチューニングができるよう分かれている
// traverserはusedIterator及びcopyとdeinitialize用
@frozen
@usableFromInline
struct _BucketTraverser: _UnsafeNodePtrType {

  @inlinable
  internal init(
    header: UnsafeMutablePointer<_Bucket>,
    startNode: UnsafeMutablePointer<UnsafeNode>,
    pairStride: Int,
    count: Int
  ) {
    self.header = header
    self.startNode = startNode
    self.pairStride = pairStride
    self.count = count
  }

  @usableFromInline var count: Int
  @usableFromInline var it: Int = 0
  @usableFromInline let header: UnsafeMutablePointer<_Bucket>
  @usableFromInline let startNode: _NodePtr
  @usableFromInline let pairStride: Int

  @inlinable
  mutating func pop() -> _NodePtr? {
    guard it < count else { return nil }
    defer { it &+= 1 }

    return UnsafeMutableRawPointer(startNode)
      .advanced(by: pairStride &* it)
      .assumingMemoryBound(to: UnsafeNode.self)
  }

  @inlinable
  func nextCounts(nodeLayout: _MemoryLayout, pairLayout: _MemoryLayout) -> _BucketTraverser? {
    guard let next = header.next else { return nil }
    return next._counts(
      storage: next.secondaryStorage(), nodeLayout: nodeLayout, pairLayout: pairLayout)
  }
}

extension UnsafeMutablePointer where Pointee == _Bucket {

  @inlinable
  func _counts(
    storage: UnsafeMutableRawPointer, nodeLayout: _MemoryLayout, pairLayout: _MemoryLayout
  ) -> _BucketTraverser {
    .init(
      header: self,
      startNode: start(
        storage: storage, nodeLayout: nodeLayout, payloadOrPairAlignment: pairLayout.alignment),
      pairStride: pairLayout.stride,
      count: pointee.count)
  }

  #if DEBUG
    @inlinable
    func _capacities(storage: UnsafeMutableRawPointer, pairLayout: _MemoryLayout)
      -> _BucketTraverser
    {
      .init(
        header: self,
        startNode: start(storage: storage, payloadOrPairAlignment: pairLayout.alignment),
        pairStride: pairLayout.stride,
        count: pointee.capacity)
    }
  #endif
}
