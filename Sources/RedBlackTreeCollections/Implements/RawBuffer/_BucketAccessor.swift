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

// accessor、traverser、queueと似た3種は、場面毎に特化したチューニングができるよう分かれている
// accessorはCoW境界を越えた場合のポインタ解決用っぽい
@frozen
@usableFromInline
package struct _BucketAccessor: _UnsafeNodePtrType {

  @inlinable
  package init(
    pointer: UnsafeMutablePointer<_Bucket>,
    startNode: UnsafeMutablePointer<UnsafeNode>,
    pairStride: Int
  ) {
    self.pointer = pointer
    self.startNode = startNode
    self.pairStride = pairStride
  }

  @usableFromInline let pointer: UnsafeMutablePointer<_Bucket>
  @usableFromInline let startNode: _NodePtr
  @usableFromInline let pairStride: Int

  @inlinable
  var capacity: Int {
    _read { yield pointer.pointee.capacity }
  }

  @inlinable
  package subscript(index: Int) -> _NodePtr {
    _read {
      yield
      UnsafeMutableRawPointer(startNode)
        .advanced(by: pairStride &* index)
        .assumingMemoryBound(to: UnsafeNode.self)
    }
  }

  @inlinable
  func next(payload: _MemoryLayout) -> _BucketAccessor? {
    assert(pointer.next != nil)  // 利用側でカウント管理している様子
    return pointer.next!._accessor(isPrimary: false, pairLayout: payload)
  }
}

extension UnsafeMutablePointer where Pointee == _Bucket {

  @inlinable
  func _accessor(isPrimary: Bool, pairLayout: _MemoryLayout) -> _BucketAccessor {
    .init(
      pointer: self,
      startNode: start(
        storage: storage(isPrimary: isPrimary), payloadOrPairAlignment: pairLayout.alignment),
      pairStride: pairLayout.stride)
  }

  @inlinable
  func accessor(pairLayout: _MemoryLayout) -> _BucketAccessor? {
    _accessor(isPrimary: true, pairLayout: pairLayout)
  }
}
