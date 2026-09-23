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
// queueはconstruct_node用
@frozen
@usableFromInline
struct _BucketQueue {

  @inlinable
  internal init(
    pointer: UnsafeMutablePointer<_Bucket>,
    startNode: UnsafeMutablePointer<UnsafeNode>,
    pairStride: Int
  ) {
    self.pointer = pointer
    self.startNode = startNode
    self.pairStride = pairStride
  }

  @usableFromInline let pointer: UnsafeMutablePointer<_Bucket>
  @usableFromInline let startNode: UnsafeMutablePointer<UnsafeNode>
  @usableFromInline let pairStride: Int

  @inlinable
  mutating func pop() -> UnsafeMutablePointer<UnsafeNode>? {
    guard pointer.count < pointer.capacity else { return nil }
    defer { pointer.pointee.count &+= 1 }
    return UnsafeMutableRawPointer(startNode)
      .advanced(by: pairStride &* pointer.count)
      .assumingMemoryBound(to: UnsafeNode.self)
  }

  @inlinable
  func next(pairLayout: _MemoryLayout) -> _BucketQueue? {
    guard let next = pointer.next else { return nil }
    return next._queue(isPrimary: false, pairLayout: pairLayout)
  }
}

extension UnsafeMutablePointer where Pointee == _Bucket {

  @inlinable
  func _queue(isPrimary: Bool, pairLayout: _MemoryLayout) -> _BucketQueue {
    .init(
      pointer: self,
      startNode: start(
        storage: storage(isPrimary: isPrimary), payloadOrPairAlignment: pairLayout.alignment),
      pairStride: pairLayout.stride)
  }

  @inlinable
  func queue(pairLayout: _MemoryLayout) -> _BucketQueue? {
    return _queue(isPrimary: true, pairLayout: pairLayout)
  }
}

extension MemoryLayout where T: ~Copyable {

  @inlinable
  static var _memoryLayout: _MemoryLayout { .init(stride: stride, alignment: alignment) }

  @inlinable
  static var _pairLayout: _MemoryLayout { .init(UnsafeNode.self, T.self) }
}
