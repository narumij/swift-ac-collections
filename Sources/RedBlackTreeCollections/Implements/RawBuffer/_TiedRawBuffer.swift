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

/// 木に紐付いている生バッファ
///
/// インデックスやイテレータを利用した際に生成され、それ以後メモリの解放責任を負う
@usableFromInline
package final class _TiedRawBuffer:
  ManagedBuffer<_TiedRawBuffer.Header, Void>, _UnsafeNodePtrType
{
  @usableFromInline
  typealias _BucketPointer = UnsafeMutablePointer<_Bucket>

  deinit {
    withUnsafeMutablePointerToHeader { header in
      header.pointee.deallocate()
    }
  }
}

extension _TiedRawBuffer {

  @nonobjc
  @inlinable
  @inline(__always)
  static func create(
    bucket: _BucketPointer?,
    deallocator: _BucketAllocator
  )
    -> _TiedRawBuffer
  {
    let storage = _TiedRawBuffer.create(minimumCapacity: 0) { managedBuffer in
      return Header(bucketHead: bucket, deallocator: deallocator)
    }
    return unsafeDowncast(storage, to: _TiedRawBuffer.self)
  }
}

extension _TiedRawBuffer {

  @frozen
  @usableFromInline
  package struct Header {

    @inlinable
    internal init(
      bucketHead: _TiedRawBuffer.Header._BucketPointer? = nil,
      deallocator: _BucketAllocator
    ) {
      self.bucketHead = bucketHead
      self.deallocator = deallocator
      self.isValueAccessAllowed = true
    }

    @usableFromInline
    typealias _BucketPointer = UnsafeMutablePointer<_Bucket>

    @usableFromInline
    typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

    @usableFromInline let bucketHead: _BucketPointer?
    @usableFromInline let deallocator: _BucketAllocator
    @usableFromInline var isValueAccessAllowed: Bool

    @inlinable
    func deallocate() {
      deallocator.deallocate(bucket: bucketHead)
    }
  }
}

extension _TiedRawBuffer {

  @nonobjc
  @inlinable
  var isValueAccessAllowed: Bool {
    get { header.isValueAccessAllowed }
    set { withUnsafeMutablePointerToHeader { $0.pointee.isValueAccessAllowed = newValue } }
  }
}

/// The type-punned empty singleton storage instance.
@usableFromInline
nonisolated(unsafe) package let _emptyRawBuffer =
  _TiedRawBuffer
  .create(bucket: nil, deallocator: .init(valueType: Void.self, deinitialize: { _ in }))
