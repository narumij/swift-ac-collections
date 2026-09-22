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

// # Memory Layout
//
// ## Primary Bucket
// |Bucket|ptr|Node||Node|Value|Node|Value|...
//                  ^--start
// ^-- head
//
// ## Secondary and other Buckets
// |Bucket||Node|Value|Node|Value|...
//         ^--start
// ^-- next
//
// ## special node on Primary Bucket
// |Bucket|ptr|Node||Node|Value|Node|Value|...
//              ^-- end node (end->left == root)
//
// |Bucket|ptr|Node||Node|Value|Node|Value|...
//          ^-- begin (begin == __tree_min(end->left))
//
// ## memory layout gap
// |Bucket||Node|Value|Node|Value|...
//        ^^-- bucket has alignment gap
//
//
// ## Initial Capacity 0
// |Bucket|ptr|Node|
//
// ## Reserve Capacity to 1
// |Bucket|ptr|Node|
// |Bucket||Node|Value|
//
// ## Reserve Capacity to 2
// |Bucket|ptr|Node|
// |Bucket||Node|Value|
// |Bucket||Node|Value|
//
// ## then Copy on Write occurs
// |Bucket|ptr|Node||Node|Value|Node|Value|.......
//                                    ^-- inlined
//
// Inspired by the TrailingArray technique from Swift Collections.
//

// NOTE: 性能過敏なので修正する場合は必ず計測しながら行うこと
// (人間による人間向けのメモ）

@frozen
@usableFromInline
package struct _BucketAllocator {

  @usableFromInline
  static func create() -> Self {
    .init(valueType: Void.self, deinitialize: { _ in })
  }

  //  @specialized(where _PayloadValue == Int) // 6.3以降になった際につける
  @inlinable
  public init<_PayloadValue: ~Copyable>(
    valueType: _PayloadValue.Type,
    deinitialize: @escaping (UnsafeMutableRawPointer) -> Void
  ) {
    self.payload = MemoryLayout<_PayloadValue>._memoryLayout
    self._pair = MemoryLayout<_PayloadValue>._pairLayout
    self.deinitialize = deinitialize
  }

  public typealias _BucketPointer = UnsafeMutablePointer<_Bucket>
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

  /// `_Payload` のstrideとalignement
  @usableFromInline
  let payload: _MemoryLayout

  /// `Node|Value` のペア形式でのstrideとalignment
  @usableFromInline
  package let _pair: _MemoryLayout

  /// 型を消去した `_Payload` のdeinitializer
  ///
  /// Genericsで型を特定した解放処理では、実行時に型情報へのアクセスが毎度かかり高コストなので、これを削減するためにこのようにしてある
  ///
  /// 普段からその方についてよく知ってるケースでは軽減されるのだが、解放処理専門といった時々しか型に触れないインスタンスで高コストになりがち
  ///
  @usableFromInline
  let deinitialize: (UnsafeMutableRawPointer) -> Void
}

extension _BucketAllocator {

  @usableFromInline  // レジスタ圧を下げることにした
  package func createHeadBucket(capacity: Int, nullptr: _NodePtr) -> _BucketPointer {

    let (bytes, alignment) = (_headAllocationSize(capacity: capacity), _pair.alignment)

    let header_storage = UnsafeMutableRawPointer._allocate(
      byteCount: bytes,
      alignment: alignment)

    let header = UnsafeMutableRawPointer(header_storage)
      .assumingMemoryBound(to: _Bucket.self)

    let endNode = header.end_ptr
    let beginPtr = header.begin_ptr

    endNode.initialize(to: .create(tag: .end, nullptr: nullptr, ___has_payload_content: false))
    beginPtr.initialize(to: endNode)
    header.initialize(to: .init(capacity: capacity))
    #if DEBUG
      nodeInitializedCount += 1
    #endif

    #if DEBUG
      do {
        var it = header._capacities(storage: header.primaryStorage(), payload: _pair)
        while let p = it.pop() {
          p.pointee.___tracking_tag = .debug
        }
      }
    #endif

    return header
  }

  @usableFromInline  // レジスタ圧を下げることにした
  package func createBucket(bucketCapacity: Int) -> _BucketPointer {

    assert(bucketCapacity != 0, "先頭以外のバケットは容量0ではないこと")

    let (bytes, alignment) = (_allocationSizeNonzero(capacity: bucketCapacity), _pair.alignment)

    let header_storage = UnsafeMutableRawPointer._allocate(
      byteCount: bytes,
      alignment: alignment)

    let header = UnsafeMutableRawPointer(header_storage)
      .assumingMemoryBound(to: _Bucket.self)

    header.initialize(to: .init(capacity: bucketCapacity))

    #if DEBUG
      do {
        var it = header._capacities(storage: header.secondaryStorage(), payload: _pair)
        while let p = it.pop() {
          p.pointee.___tracking_tag = .debug
        }
      }
    #endif

    return header
  }
}

extension _BucketAllocator {

  @inlinable
  @inline(__always)
  package func _allocationSize(capacity: Int) -> Int {
    guard capacity != 0 else { return MemoryLayout<_Bucket>.stride }
    return _allocationSizeNonzero(capacity: capacity)
  }

  @inlinable
  @inline(__always)
  package func _headAllocationSize(capacity: Int) -> Int {
    let prefix = MemoryLayout<_Bucket>.stride
      &+ MemoryLayout<UnsafeMutablePointer<UnsafeNode>>.stride
      &+ MemoryLayout<UnsafeNode>.stride
    guard capacity != 0 else { return prefix }
    return _allocationSize(prefix: prefix, capacity: capacity)
  }

  @inlinable
  @inline(__always)
  package func _allocationSizeNonzero(capacity: Int) -> Int {
    assert(capacity > 0)
    return _allocationSize(prefix: MemoryLayout<_Bucket>.stride, capacity: capacity)
  }

  @inlinable
  @inline(__always)
  func _allocationSize(prefix: Int, capacity: Int) -> Int {
    let nodeStride = MemoryLayout<UnsafeNode>.stride
    let payloadAlignment = payload.alignment
    let payloadOffset = prefix &+ nodeStride
    let leadingGap = (0 &- payloadOffset) & (payloadAlignment &- 1)
    return prefix
      &+ leadingGap
      &+ _pair.stride &* (capacity &- 1)
      &+ nodeStride
      &+ payload.stride
  }
}

extension _BucketAllocator {

  @usableFromInline
  package func deinitialize(bucket b: _BucketPointer?) {
    var reserverHead = b
    if let h = reserverHead {
      _deinitializeNodeAndValues(storage: h.primaryStorage(), h)
      h.pointee.count = 0
      reserverHead = h.pointee.next
    }
    while let h = reserverHead {
      _deinitializeNodeAndValues(storage: h.secondaryStorage(), h)
      h.pointee.count = 0
      reserverHead = h.pointee.next
    }
  }
}

extension _BucketAllocator {

  @inlinable
  package func deallocate(bucket b: _BucketPointer?) {
    var reserverHead = b
    if let h = reserverHead {
      reserverHead = h.pointee.next
      _deallocHeadBucket(h)
    }
    while let h = reserverHead {
      reserverHead = h.pointee.next
      _deallocOtherBucket(h)
    }
  }
}

extension _BucketAllocator {

  @inlinable
  func _deallocHeadBucket(_ b: _BucketPointer) {
    _deinitializeNodeAndValues(storage: b.primaryStorage(), b)
    _deinitializeEndNode(b)
    _deinitializeBeginNode(b)
    b.deinitialize(count: 1)
    UnsafeMutableRawPointer(b)._deallocate()
  }

  @inlinable
  func _deallocOtherBucket(_ b: _BucketPointer) {
    _deinitializeNodeAndValues(storage: b.secondaryStorage(), b)
    b.deinitialize(count: 1)
    UnsafeMutableRawPointer(b)._deallocate()
  }

  @inlinable
  func _deinitializeBeginNode(_ b: _BucketPointer) {
    UnsafeMutableRawPointer(b.begin_ptr)
      .assumingMemoryBound(to: UnsafeMutablePointer<UnsafeNode>.self)
      .deinitialize(count: 1)
  }

  @inlinable
  func _deinitializeEndNode(_ b: _BucketPointer) {
    UnsafeMutableRawPointer(b.end_ptr)
      .assumingMemoryBound(to: UnsafeNode.self)
      .deinitialize(count: 1)
    #if DEBUG
      nodeDeinitializedCount += 1
    #endif
  }

  @inlinable
  func _deinitializeNodeAndValues(storage: UnsafeMutableRawPointer, _ b: _BucketPointer) {
    var it = b._counts(storage: storage, payload: _pair)
    while let p = it.pop() {
      if p.pointee.___has_payload_content {
        deinitialize(p.advanced(by: 1))
        #if DEBUG
          payloadDeinitializedCount += 1
        #endif
      }
      p.deinitialize(count: 1)
      #if DEBUG
        nodeDeinitializedCount += 1
      #endif
    }
    #if DEBUG
      do {
        var it = b._capacities(storage: storage, payload: _pair)
        while let p = it.pop() {
          p.pointee.___tracking_tag = .debug
        }
      }
    #endif
  }
}
