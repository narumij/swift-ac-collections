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
// ## Resever Capacity to 1
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
@frozen
@usableFromInline
package struct _BucketAllocator {

  static func create() -> Self {
    .init(valueType: Void.self, deinitialize: { _ in })
  }

  @inlinable
  @inline(__always)
  public init<_PayloadValue>(
    valueType: _PayloadValue.Type,
    deinitialize: @escaping (UnsafeMutableRawPointer) -> Void
  ) {
    self.payload = MemoryLayout<_PayloadValue>._memoryLayout
    self._pair = .init(UnsafeNode.self, _PayloadValue.self)
    self.deinitialize = deinitialize
    self.startOffset = max(0, payload.alignment - MemoryLayout<UnsafeNode>.alignment)
  }

  public typealias _BucketPointer = UnsafeMutablePointer<_Bucket>
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

  /// `_Payload` のstrideとalignement
  @usableFromInline
  let payload: _MemoryLayout
  
  /// `Node|Value` のペア形式でのstrideとalignment
  @usableFromInline
  package let _pair: _MemoryLayout

  
  /// ```
  /// |Bucket| |Node|Value|Node|Value|...
  ///        ^ ^
  ///       この部分のサイズ
  /// ```
  @usableFromInline
  package let startOffset: Int
  
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

  @inlinable
  @inline(__always)
  public func createHeadBucket(capacity: Int, nullptr: _NodePtr) -> (
    _BucketPointer, capacity: Int
  ) {

    let (bytes, alignment) = (_allocationSize(capacity: capacity), _pair.alignment)

    let header_storage = UnsafeMutableRawPointer._allocate(
      byteCount: bytes
        + MemoryLayout<UnsafeNode>.stride
        + MemoryLayout<UnsafeMutablePointer<UnsafeNode>>.stride,
      alignment: alignment)

    let header = UnsafeMutableRawPointer(header_storage)
      .assumingMemoryBound(to: _Bucket.self)

    let endNode = header.end_ptr
    let beginPtr = header.begin_ptr

    endNode.initialize(to: .create(tag: .end, nullptr: nullptr))
    beginPtr.initialize(to: endNode)
    header.initialize(to: .init(capacity: capacity))

    #if DEBUG
      do {
        var it = header._capacities(isHead: true, payload: payload)
        while let p = it.pop() {
          p.pointee.___tracking_tag = .debug
        }
      }
    #endif

    return (header, capacity)
  }

  @inlinable
  @inline(__always)
  public func createBucket(capacity: Int) -> (_BucketPointer, capacity: Int) {

    assert(capacity != 0, "先頭以外のバケットは容量0ではないこと")

    let (bytes, alignment) = (_allocationSize(capacity: capacity), _pair.alignment)

    let header_storage = UnsafeMutableRawPointer._allocate(
      byteCount: bytes,
      alignment: alignment)

    let header = UnsafeMutableRawPointer(header_storage)
      .assumingMemoryBound(to: _Bucket.self)

    header.initialize(to: .init(capacity: capacity))

    #if DEBUG
      do {
        var it = header._capacities(isHead: false, payload: payload)
        while let p = it.pop() {
          p.pointee.___tracking_tag = .debug
        }
      }
    #endif

    return (header, capacity)
  }
}

extension _BucketAllocator {

  @usableFromInline
  package func _allocationSize(capacity: Int) -> Int {
    let s2 = MemoryLayout<_Bucket>.stride
    let s01 = _pair.stride
    let size = s2 + s01 * capacity + (capacity == 0 ? 0 : startOffset)
    return size
  }
}

extension _BucketAllocator {
  
  @inlinable
  public func deinitialize(bucket b: _BucketPointer?) {
    var reserverHead = b
    var isHead = true
    while let h = reserverHead {
      reserverHead = h.pointee.next
      _deinitializeNodeAndValues(isHead: isHead, h)
      h.pointee.count = 0
      isHead = false
    }
  }
}

extension _BucketAllocator {

  @inlinable
  public func deallocate(bucket b: _BucketPointer?) {
    var reserverHead = b
    while let h = reserverHead {
      reserverHead = h.pointee.next
      if h == b {
        _deallocHeadBucket(h)
      } else {
        _deallocBucket(h)
      }
    }
  }
}

extension _BucketAllocator {

  @inlinable
  func _deallocHeadBucket(_ b: _BucketPointer) {
    _deinitializeNodeAndValues(isHead: true, b)
    _deinitializeEndNode(b)
    _deinitializeBeginNode(b)
    b.deinitialize(count: 1)
    UnsafeMutableRawPointer(b)._deallocate()
  }

  @inlinable
  func _deallocBucket(_ b: _BucketPointer) {
    _deinitializeNodeAndValues(isHead: false, b)
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
  }

  @inlinable
  func _deinitializeNodeAndValues(isHead: Bool, _ b: _BucketPointer) {
    var it = b._counts(isHead: isHead, payload: payload)
    while let p = it.pop() {
      if p.pointee.___has_payload_content {
        deinitialize(p.advanced(by: 1))
      } else {
        p.deinitialize(count: 1)
      }
    }
    #if DEBUG
      do {
        var it = b._capacities(isHead: isHead, payload: payload)
        while let p = it.pop() {
          p.pointee.___tracking_tag = .debug
        }
      }
    #endif
  }
}
