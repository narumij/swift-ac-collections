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

// TODO: やや古いのでスカラー版にあわせること

/// DictionaryやMultimap用に特殊化されたハンドル
///
/// `_Key`の取得に関して特殊化済みとなっている。
///
@frozen
@usableFromInline
struct UnsafeTreeV2KeyValueHandle<_Key, _MappedValue> where _Key: Comparable {
  @inlinable
  internal init(
    header: UnsafeMutablePointer<UnsafeTreeV2BufferHeader>,
    origin: UnsafeMutableRawPointer
  ) {
    self.header = header
    self.isMulti = false
  }
  @usableFromInline typealias _Key = _Key
  @usableFromInline typealias _Payload = RedBlackTreePair<_Key, _MappedValue>
  @usableFromInline typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  @usableFromInline typealias _Pointer = _NodePtr
  @usableFromInline typealias _NodeRef = UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>
  @usableFromInline let header: UnsafeMutablePointer<UnsafeTreeV2BufferHeader>
  @usableFromInline var isMulti: Bool
}

extension UnsafeTreeV2
where
  Base: KeyValueComparer,
  _Key: Comparable,
  _Payload == RedBlackTreePair<_Key, Base._MappedValue>
{

  @usableFromInline
  typealias KeyValueHandle = UnsafeTreeV2KeyValueHandle<_Key, Base._MappedValue>

  @inlinable
  @inline(__always)
  internal func read<R>(_ body: (KeyValueHandle) throws -> R) rethrows -> R {
    try _buffer.withUnsafeMutablePointers { header, elements in
      let handle = KeyValueHandle(header: header, origin: elements)
      return try body(handle)
    }
  }

  @inlinable
  @inline(__always)
  internal func update<R>(_ body: (KeyValueHandle) throws -> R) rethrows -> R {
    try _buffer.withUnsafeMutablePointers { header, elements in
      let handle = KeyValueHandle(header: header, origin: elements)
      return try body(handle)
    }
  }
}

extension UnsafeTreeV2KeyValueHandle {

  @inlinable
  @inline(__always)
  func __key(_ __v: _Payload) -> _Key { __v.key }

  @inlinable
  func value_comp(_ __l: _Key, _ __r: _Key) -> Bool {
    __l < __r
  }

  @inlinable
  func value_equiv(_ __l: _Key, _ __r: _Key) -> Bool {
    __l == __r
  }

  @inlinable
  @inline(__always)
  func __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key) -> __int_compare_result {
    __default_three_way_comparator(__lhs, __rhs)
  }

  @inlinable
  func __comp(_ __lhs: _Key, _ __rhs: _Key) -> __int_compare_result {
    __default_three_way_comparator(__lhs, __rhs)
  }
}

// MARK: - TreeNodeValueProtocol

extension UnsafeTreeV2KeyValueHandle {

  @inlinable
  @inline(__always)
  func __get_value(_ p: _NodePtr) -> _Key {
    p.__value_(as: _Payload.self).pointee.key
  }
}

extension UnsafeTreeV2KeyValueHandle: UnsafeTreeAccessHandleBase {}

extension UnsafeTreeV2KeyValueHandle: BoundBothProtocol, BoundAlgorithmProtocol_ptr {}
extension UnsafeTreeV2KeyValueHandle: FindInteface, FindProtocol_ptr {}
extension UnsafeTreeV2KeyValueHandle: FindEqualInterface, FindEqualProtocol_ptr {}
extension UnsafeTreeV2KeyValueHandle: InsertNodeAtInterface, InsertNodeAtProtocol_ptr {}
extension UnsafeTreeV2KeyValueHandle: InsertUniqueInterface, InsertUniqueProtocol_ptr {}
extension UnsafeTreeV2KeyValueHandle: RemoveInteface, RemoveProtocol_ptr {}
extension UnsafeTreeV2KeyValueHandle: EraseProtocol {}
extension UnsafeTreeV2KeyValueHandle: EraseUniqueProtocol {}
extension UnsafeTreeV2KeyValueHandle: TreeAlgorithmBaseProtocol_ptr {}
extension UnsafeTreeV2KeyValueHandle: TreeAlgorithmProtocol_ptr {}

extension UnsafeTreeV2KeyValueHandle {
  public typealias __compare_result = __int_compare_result
}
