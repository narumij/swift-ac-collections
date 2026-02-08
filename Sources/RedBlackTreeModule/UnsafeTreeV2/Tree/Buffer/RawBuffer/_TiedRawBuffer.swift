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
  public typealias _BucketPointer = UnsafeMutablePointer<_Bucket>

  @inlinable
  deinit {
    withUnsafeMutablePointerToHeader { header in
      header.pointee.deallocate()
    }
  }
}

extension _TiedRawBuffer {

  @nonobjc
  @inlinable
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
  @nonobjc
  @inlinable
  public func isTriviallyIdentical(to other: _TiedRawBuffer) -> Bool {
    self === other
  }
}

extension _TiedRawBuffer {

  @frozen
  public
    struct Header
  {

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

    @usableFromInline var bucketHead: _BucketPointer?
    @usableFromInline let deallocator: _BucketAllocator
    @usableFromInline var isValueAccessAllowed: Bool

    @inlinable
    func deallocate() {
      deallocator.deallocate(bucket: bucketHead)
    }

    @inlinable
    subscript(___tracking_tag: _RawTrackingTag) -> _NodePtr? {
      assert(___tracking_tag >= 0, "特殊ノードの取得要求をされないこと")
      var remaining = ___tracking_tag
      var p = bucketHead?.accessor(payload: deallocator.payload)
      while let h = p {
        let cap = h.capacity
        if remaining < cap {
          return h[remaining]
        }
        remaining -= cap
        p = h.next(payload: deallocator.payload)
      }
      assert(false, "ここには到達しないこと")
      return nil
    }
  }
}

extension _TiedRawBuffer {

  @nonobjc
  @inlinable
  subscript(___tracking_tag: _RawTrackingTag) -> _NodePtr? {
    header[___tracking_tag]
  }

  @nonobjc
  @inlinable
  @inline(__always)
  var begin_ptr: UnsafeMutablePointer<_NodePtr>? {
    header.bucketHead?.begin_ptr
  }

  @nonobjc
  @inlinable
  @inline(__always)
  var end_ptr: _NodePtr? {
    header.bucketHead?.end_ptr
  }

  @nonobjc
  @usableFromInline
  var isValueAccessAllowed: Bool {
    get { header.isValueAccessAllowed }
    set { withUnsafeMutablePointerToHeader { $0.pointee.isValueAccessAllowed = newValue } }
  }
}

extension _TiedRawBuffer {

  @inlinable
  @inline(__always)
  package func _retrieve(tag: TagSeal_) -> _SealedPtr {
    switch tag {
    case .end:
      return end_ptr.map { $0.sealed } ?? .failure(.null)
    case .tag(let raw, let seal):
      guard raw < capacity else {
        return .failure(.unknown)
      }
      return self[raw]
        .map { .success(.uncheckedSeal($0, seal)) }
        ?? .failure(.null)
    }
  }

  /// つながりをたぐりよせる
  ///
  /// 日本人的にはお祭りなどによくある千本引きのイメージ
  @inlinable
  @inline(__always)
  package func retrieve(_ tag: TaggedSeal) -> _SealedPtr {
    tag.flatMap { _retrieve(tag: $0) }
  }
}

// TODO: 空の場合のインデックスやレンジの動作が課題となる。

/// The type-punned empty singleton storage instance.
@usableFromInline
nonisolated(unsafe) package let _emptyDeallocator =
  _TiedRawBuffer
  .create(bucket: nil, deallocator: .init(valueType: Void.self, deinitialize: { _ in }))
