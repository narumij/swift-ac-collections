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
// queueはconstruct_node用
@frozen
@usableFromInline
struct _BucketQueue {

  @inlinable
  internal init(
    pointer: UnsafeMutablePointer<_Bucket>,
    start: UnsafeMutablePointer<UnsafeNode>,
    stride: Int
  ) {
    self.pointer = pointer
    self.start = start
    self.stride = stride
  }

  @usableFromInline let pointer: UnsafeMutablePointer<_Bucket>
  @usableFromInline let start: UnsafeMutablePointer<UnsafeNode>
  @usableFromInline let stride: Int

  @inlinable
  @inline(__always)
  subscript(index: Int) -> UnsafeMutablePointer<UnsafeNode> {
    UnsafeMutableRawPointer(start)
      .advanced(by: stride * index)
      .assumingMemoryBound(to: UnsafeNode.self)
  }

  @inlinable
  mutating func pop() -> UnsafeMutablePointer<UnsafeNode>? {
    guard pointer.count < pointer.capacity else { return nil }
    defer { pointer.pointee.count += 1 }
    return self[pointer.count]
  }

  @inlinable
  func next(payload: _MemoryLayout) -> _BucketQueue? {
    guard let next = pointer.next else { return nil }
    return next._queue(isHead: false, payloadLayout: payload)
  }
}

extension UnsafeMutablePointer where Pointee == _Bucket {

  @inlinable
  @inline(__always)
  func _queue(isHead: Bool, payloadLayout: _MemoryLayout) -> _BucketQueue {
    .init(
      pointer: self,
      start: start(storage: storage(isHead: isHead), valueAlignment: payloadLayout.alignment),
      stride: MemoryLayout<UnsafeNode>.stride + payloadLayout.stride)
  }

  @inlinable
  func queue(payloadLayout: _MemoryLayout) -> _BucketQueue? {
    return _queue(isHead: true, payloadLayout: payloadLayout)
  }
}

extension MemoryLayout where T: ~Copyable {

  @inlinable
  static var _memoryLayout: _MemoryLayout { .init(stride: stride, alignment: alignment) }
}
