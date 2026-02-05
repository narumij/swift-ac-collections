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

import Foundation

@usableFromInline
package final class UnsafeTreeV2Buffer:
  ManagedBuffer<UnsafeTreeV2BufferHeader, Void>
{
  // MARK: - 解放処理
  @inlinable
  deinit {
    withUnsafeMutablePointers { header, _ in
      if header.pointee.isRawBufferUniquelyOwned {
        header.pointee.___deallocFreshPool()
      } else {
        header.pointee._tied?.isValueAccessAllowed = false
      }
    }
  }
}

// MARK: - 生成

extension UnsafeTreeV2Buffer {

  // __always必須
  @nonobjc
  @inlinable
  @inline(__always)
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
      minimumCapacity: nodeCapacity, nullptr: nullptr)
  }
  
  @nonobjc
  @inlinable
  @inline(__always)
  internal static func create(
    allocator: _BucketAllocator,
    minimumCapacity nodeCapacity: Int,
    nullptr: UnsafeMutablePointer<UnsafeNode>
  ) -> UnsafeTreeV2Buffer {
    // 要素数は常に0
    let storage = UnsafeTreeV2Buffer.create(minimumCapacity: 0) { managedBuffer in
      return .init(allocator: allocator, nullptr: nullptr, capacity: nodeCapacity)
    }
    assert(nodeCapacity <= storage.header.freshPoolCapacity)
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
@usableFromInline
nonisolated(unsafe) package let _emptyTreeStorage = UnsafeTreeV2Buffer.create(
  allocator: .create(), minimumCapacity: 0, nullptr: .nullptr)
