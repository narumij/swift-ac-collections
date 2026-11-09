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

import Synchronization

#if ENABLE_EXPERIMENTAL_TSAN_SAFE

extension UnsafeMutablePointer where Pointee == UnsafeTreeV2BufferHeader {
  
  @inlinable
  func index(_ p: UnsafeMutablePointer<UnsafeNode>) -> _LazyTiedPtrV2 {
    assert(p != .nullptr)
    let cell = _LazyTie._lazyDetachCell(at: pointer(to: \.lazyDetachPointer)!)
    return .unchecked(p, end_ptr: pointee.end_ptr, lazyDetach: cell.pointee)
  }
  
  @inlinable
  func index_or_nil(_ p: UnsafeMutablePointer<UnsafeNode>) -> _LazyTiedPtrV2? {
    p.___has_payload_content ? .some(index(p)) : .none
  }
}

extension _LazyTie {
  
  // 試作: lazyDetachPointerのフィールドに対して、ヘッダ全体を開かずに
  // 「atomicに確認し、無ければロックの中で作って公開する」
  @inlinable
  static func _lazyDetachCell(
    at field: UnsafeMutablePointer<UnsafeMutablePointer<_LazyTie>?>
  ) -> UnsafeMutablePointer<_LazyTie> {
    let bits = UnsafeMutableRawPointer(field).assumingMemoryBound(to: Atomic<UInt>.self)
    if let cell = UnsafeMutablePointer<_LazyTie>(bitPattern: bits.pointee.load(ordering: .acquiring)) {
      return cell
    }
    return _createLazyDetachCell(at: field)
  }

  @usableFromInline
  @inline(never)
  static func _createLazyDetachCell(
    at field: UnsafeMutablePointer<UnsafeMutablePointer<_LazyTie>?>
  ) -> UnsafeMutablePointer<_LazyTie> {
    let bits = UnsafeMutableRawPointer(field).assumingMemoryBound(to: Atomic<UInt>.self)
    return _lazyDetachLock.withLock { _ in
      if let cell = UnsafeMutablePointer<_LazyTie>(bitPattern: bits.pointee.load(ordering: .acquiring)) {
        return cell
      }
      let cell = UnsafeMutablePointer<_LazyTie>.allocate(capacity: 1)
      cell.initialize(to: .create())
      bits.pointee.store(UInt(bitPattern: cell), ordering: .releasing)
      return cell
    }
  }
}
#endif
