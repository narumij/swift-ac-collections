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
// accessor、traverser、queueと似た3種は、場面毎に特化したチューニングができるよう分かれている
// traverserはusedIterator及びcopyとdeinitialize用
@frozen
@usableFromInline
struct _BucketTraverser: _UnsafeNodePtrType {

  @inlinable
  internal init(
    pointer: UnsafeMutablePointer<_Bucket>,
    start: UnsafeMutablePointer<UnsafeNode>,
    stride: Int,
    count: Int
  ) {
    self.pointer = pointer
    self.start = start
    self.stride = stride
    self.count = count
  }

  @usableFromInline var count: Int
  @usableFromInline var it: Int = 0
  @usableFromInline let pointer: UnsafeMutablePointer<_Bucket>
  @usableFromInline let start: _NodePtr
  @usableFromInline let stride: Int

  @inlinable
  subscript(index: Int) -> _NodePtr {
    _read {
      yield
      UnsafeMutableRawPointer(start)
        .advanced(by: stride * index)
        .assumingMemoryBound(to: UnsafeNode.self)
    }
  }

  @inlinable
  @inline(__always)
  mutating func pop() -> _NodePtr? {
    guard it < count else { return nil }
    defer { it += 1 }
    return self[it]
  }

  @inlinable
  func nextCounts(payload: _MemoryLayout) -> _BucketTraverser? {
    guard let next = pointer.next else { return nil }
    return next._counts(storage: next.otherStorage(), payload: payload)
  }
}

extension UnsafeMutablePointer where Pointee == _Bucket {

  @inlinable
  func _counts(storage: UnsafeMutableRawPointer, payload: _MemoryLayout) -> _BucketTraverser {
    .init(
      pointer: self,
      start: start(storage: storage, valueAlignment: payload.alignment),
      stride: MemoryLayout<UnsafeNode>.stride + payload.stride,
      count: pointee.count)
  }

  @inlinable
  func _capacities(storage: UnsafeMutableRawPointer, payload: _MemoryLayout) -> _BucketTraverser {
    .init(
      pointer: self,
      start: start(storage: storage, valueAlignment: payload.alignment),
      stride: MemoryLayout<UnsafeNode>.stride + payload.stride,
      count: pointee.capacity)
  }
}
