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

// accessor、traverser、queueと似た3種は、場面毎に特化したチューニングができるよう分かれている
// accessorはCoW境界を越えた場合のポインタ解決用っぽい
@frozen
@usableFromInline
package struct _BucketAccessor: _UnsafeNodePtrType {

  @usableFromInline
  package init(
    pointer: UnsafeMutablePointer<_Bucket>,
    start: UnsafeMutablePointer<UnsafeNode>,
    stride: Int
  ) {
    self.pointer = pointer
    self.start = start
    self.stride = stride
  }

  let pointer: UnsafeMutablePointer<_Bucket>
  let start: _NodePtr
  let stride: Int

  @usableFromInline
  var capacity: Int {
    _read { yield pointer.pointee.capacity }
  }

  @usableFromInline
  package subscript(index: Int) -> _NodePtr {
    _read {
      yield
      UnsafeMutableRawPointer(start)
        .advanced(by: stride * index)
        .assumingMemoryBound(to: UnsafeNode.self)
    }
  }

  @usableFromInline
  func next(payload: _MemoryLayout) -> _BucketAccessor? {
    guard let next = pointer.next else { return nil }
    return next._accessor(isHead: false, payload: payload)
  }
}

extension UnsafeMutablePointer where Pointee == _Bucket {

  @inlinable
  @inline(__always)
  func _accessor(isHead: Bool, payload: _MemoryLayout) -> _BucketAccessor {
    .init(
      pointer: self, start: start(isHead: isHead, valueAlignment: payload.alignment),
      stride: MemoryLayout<UnsafeNode>.stride + payload.stride)
  }

  @inlinable
  func accessor(payload: _MemoryLayout) -> _BucketAccessor? {
    _accessor(isHead: true, payload: payload)
  }
}
