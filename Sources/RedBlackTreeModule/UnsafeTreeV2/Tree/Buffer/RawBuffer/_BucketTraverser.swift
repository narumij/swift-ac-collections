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
// traverserはusedIterator及びcopy用
@frozen
@usableFromInline
struct _BucketTraverser: _UnsafeNodePtrType {

  @usableFromInline
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

  let pointer: UnsafeMutablePointer<_Bucket>
  let start: _NodePtr
  let stride: Int
  var count: Int
  var it: Int = 0

  subscript(index: Int) -> _NodePtr {
    _read {
      yield
      UnsafeMutableRawPointer(start)
        .advanced(by: stride * index)
        .assumingMemoryBound(to: UnsafeNode.self)
    }
  }

  @usableFromInline
  mutating func pop() -> _NodePtr? {
    guard it < count else { return nil }
    let p = self[it]
    it += 1
    return p
  }

  @usableFromInline
  func nextCounts(memoryLayout: _MemoryLayout) -> _BucketTraverser? {
    guard let next = pointer.pointee.next else { return nil }
    return next._counts(isHead: false, memoryLayout: memoryLayout)
  }
}

extension UnsafeMutablePointer where Pointee == _Bucket {

  // TODO: secondaryなメソッドの命名が雑なのを直す

  @usableFromInline
  func _counts(isHead: Bool, memoryLayout: _MemoryLayout) -> _BucketTraverser {
    .init(
      pointer: self,
      start: start(isHead: isHead, valueAlignment: memoryLayout.alignment),
      stride: MemoryLayout<UnsafeNode>.stride + memoryLayout.stride,
      count: pointee.count)
  }

  @usableFromInline
  func _capacities(isHead: Bool, memoryLayout: _MemoryLayout) -> _BucketTraverser {
    .init(
      pointer: self,
      start: start(isHead: isHead, valueAlignment: memoryLayout.alignment),
      stride: MemoryLayout<UnsafeNode>.stride + memoryLayout.stride,
      count: pointee.capacity)
  }
}
