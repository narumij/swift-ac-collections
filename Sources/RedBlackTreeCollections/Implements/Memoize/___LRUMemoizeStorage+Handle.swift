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

/// LRU用に特殊化されたハンドル
///
/// `_Key`の取得に関して特殊化済みとなっている。
///
@frozen
@usableFromInline
struct ___LRUHandle<_Key, _MappedValue> where _Key: Comparable {
  @inlinable
  internal init(
    header: UnsafeMutablePointer<UnsafeTreeV2BufferHeader>
  ) {
    self.header = header
    self.nullptr = header.pointee.nullptr
    self.root_ref = header.pointee.root_ptr
  }
  @usableFromInline typealias _Key = _Key
  @usableFromInline typealias _PayloadValue = _LinkingPair<_Key, _MappedValue>
  @usableFromInline typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  @usableFromInline typealias _Pointer = _NodePtr
  @usableFromInline typealias _NodeRef = UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>
  @usableFromInline let header: UnsafeMutablePointer<UnsafeTreeV2BufferHeader>
  @usableFromInline let nullptr: _NodePtr
  @usableFromInline let root_ref: _NodeRef
}

extension ___LRUHandle {

  @inlinable
  func value_comp(_ __l: _Key, _ __r: _Key) -> Bool {
    __l < __r
  }
}

// MARK: - TreeNodeValueProtocol

extension ___LRUHandle {

  @inlinable
  func __get_value(_ p: _NodePtr) -> _Key {
    p.__value_(as: _PayloadValue.self).pointee.key
  }
}

extension ___LRUHandle {

  @inlinable
  public func __construct_node(_ k: _PayloadValue) -> _NodePtr {
    let p = header.pointee.__construct_raw_node()
    // あえてのdefer
    defer {
      p.__value_().initialize(to: k)
      #if DEBUG
        payloadInitializedCount += 1
      #endif
    }
    return p
  }
}

extension ___LRUHandle {

  @inlinable
  var __begin_node_: _NodePtr {
    @inline(__always)
    @_transparent
    unsafeAddress {
      UnsafePointer(header.pointee.begin_ptr)
    }
    @inline(__always)
    @_transparent
    nonmutating unsafeMutableAddress {
      header.pointee.begin_ptr
    }
  }

  @inlinable
  @inline(__always)
  var __root: _NodePtr {
    @inline(__always)
    @_transparent
    unsafeAddress {
      UnsafePointer(root_ref)
    }
  }

  @inlinable
  func __root_ptr() -> _NodeRef {
    root_ref
  }

  @inlinable
  var end: _NodePtr {
    header.pointee.end_ptr
  }

  @inlinable
  var __end_node: _NodePtr {
    header.pointee.end_ptr
  }

  @inlinable
  func destroy(_ p: _NodePtr) {
    header.pointee.___pushRecycle(p)
  }

  @inlinable
  var __size_: Int {
    get { header.pointee.count }
    nonmutating set { /* NOP */  }
  }
}

extension ___LRUHandle: FindInteface, FindProtocol_find_equal_ptr {}
// これに関して古いfind_equalがどうも速いので、そちらを使う
// (これに関してとは、KeyValueアクセスのケース)
extension ___LRUHandle: FindEqualInterface, FindEqualProtocol_ptr_old {}
extension ___LRUHandle: InsertNodeAtInterface, InsertNodeAtProtocol_ptr {}
extension ___LRUHandle: RemoveInteface, RemoveProtocol_ptr {}
extension ___LRUHandle: EraseProtocol {}

extension ___LRUHandle: TreeAlgorithmBaseProtocol_ptr {}
extension ___LRUHandle: TreeAlgorithmProtocol_ptr {}

extension ___LRUHandle {

  @inlinable
  var count: Int { header.pointee.count }

  @inlinable
  var capacity: Int { header.pointee.freshPoolCapacity }
}

extension UnsafeTreeV2 where Base: KeyValueTrait, Base._PayloadValue == _LinkingPair<_Key,Base._MappedValue> {

  @usableFromInline
  typealias _LRUHandle = ___LRUHandle<_Key, Base._MappedValue>

  @inlinable
  internal func update<R>(_ body: (_LRUHandle) throws -> R) rethrows -> R {
    try _buffer.withUnsafeMutablePointers { header, _ in
      let handle = _LRUHandle(header: header)
      return try body(handle)
    }
  }
}
