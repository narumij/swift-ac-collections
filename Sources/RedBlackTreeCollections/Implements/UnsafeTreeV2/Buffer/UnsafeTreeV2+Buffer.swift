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

#if USE_HEAD_BUCKET_PAIRING && !COMPATIBLE_ATCODER_2025
  @usableFromInline package typealias UnsafeTreeV2BufferElement = UInt8
#else
  @usableFromInline package typealias UnsafeTreeV2BufferElement = Void
#endif

@usableFromInline
package final class UnsafeTreeV2Buffer:
  ManagedBuffer<UnsafeTreeV2BufferHeader, UnsafeTreeV2BufferElement>
{
  // MARK: - 解放処理
  deinit {

    withUnsafeMutablePointers { header, _ in

      if !header.pointee.isLazyDetachUniquelyOwned() {
        header.pointee._lazyDetach?.isDetached = true
      }

      #if USE_HEAD_BUCKET_PAIRING && !COMPATIBLE_ATCODER_2025
      header.pointee.___deallocFreshPoolKeepingHead()
      #else
      if !header.pointee.isRawBufferUniquelyOwned {
        // 内部バッファがぼっちじゃないので、続行
        header.pointee._tied!.isValueAccessAllowed = false
      } else {
        // 内部バッファがぼっちになるので、解散
        header.pointee.___deallocFreshPool()
      }
      #endif

      #if ENABLE_EXPERIMENTAL_TSAN_SAFE
        if let p = header.pointee.lazyDetachPointer {
          p.deinitialize(count: 1)
          p.deallocate()
        }
      #endif
    }
  }
}

// MARK: - 生成

extension UnsafeTreeV2Buffer {

  //  @specialized(where _PayloadValue == Int) // 6.3以降になった際につける
  @nonobjc
  @inlinable
  internal static func create<_PayloadValue>(
    _ t: _PayloadValue.Type,
    minimumCapacity nodeCapacity: Int,
    nullptr: UnsafeMutablePointer<UnsafeNode>
  ) -> UnsafeTreeV2Buffer {
    return create(
      allocator: .init(valueType: _PayloadValue.self) {
        $0.assumingMemoryBound(to: _PayloadValue.self)
          .deinitialize(count: 1)
      },
      minimumCapacity: nodeCapacity,
      nullptr: nullptr)
  }

  @nonobjc
  @inlinable
  internal static func create(
    allocator: _BucketAllocator,
    minimumCapacity nodeCapacity: Int,
    nullptr: UnsafeMutablePointer<UnsafeNode>
  ) -> UnsafeTreeV2Buffer {

    #if ENABLE_OFFSET_OVERFLOW_GUARD
      allocator.pairLayout._preconditionOffsetDoesNotOverflow(forCount: nodeCapacity)
    #endif

    #if USE_HEAD_BUCKET_PAIRING && !COMPATIBLE_ATCODER_2025
    let storage = UnsafeTreeV2Buffer.create(
      minimumCapacity: allocator._pairedHeadAllocationSize(capacity: nodeCapacity)
    ) { managedBuffer in
      let headStorage = managedBuffer.withUnsafeMutablePointerToElements {
        UnsafeMutableRawPointer($0)
      }
      return .init(
        allocator: allocator, nullptr: nullptr, capacity: nodeCapacity,
        headStorage: headStorage)
    }
    #else
    // 要素数は常に0
    let storage = UnsafeTreeV2Buffer.create(minimumCapacity: 0) { managedBuffer in
      return .init(allocator: allocator, nullptr: nullptr, capacity: nodeCapacity)
    }
    #endif
    assert(nodeCapacity <= storage.header.freshPoolCapacity, "必要最低容量を満たしていること")
    return unsafeDowncast(storage, to: UnsafeTreeV2Buffer.self)
  }
}

extension UnsafeTreeV2Buffer {

  @nonobjc
  @inlinable
  internal static func empty() -> UnsafeTreeV2Buffer {
    // 要素数は常に0
    let storage = UnsafeTreeV2Buffer.create(minimumCapacity: 0) { managedBuffer in
      var header = UnsafeTreeV2BufferHeader(allocator: .create(), nullptr: .nullptr, capacity: 0)

      #if !USE_HEAD_BUCKET_PAIRING && COMPATIBLE_ATCODER_2025
      _ = header.tiedRawBuffer
      #endif

      header._lazyDetach = _emptyLazyDetach

      return header
    }
    assert(storage.header.freshPoolCapacity == 0)
    return unsafeDowncast(storage, to: UnsafeTreeV2Buffer.self)
  }
}

extension UnsafeTreeV2Buffer: CustomStringConvertible {
  public var description: String {
    unsafe withUnsafeMutablePointerToHeader {
      "UnsafeTreeV2Buffer \(unsafe $0.pointee)"
    }
  }
}

/// The type-punned empty singleton storage instance.
@exclusivity(unchecked)
@usableFromInline
nonisolated(unsafe) package let _emptyTreeStorage = UnsafeTreeV2Buffer.empty()
