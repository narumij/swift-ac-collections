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

// NOTE: 性能過敏なので修正する場合は必ず計測しながら行うこと
/// SetやMultiset用に特殊化されたハンドル
///
/// `_Key`の取得に関して特殊化済みとなっている。
///
@frozen
@usableFromInline
struct UnsafeTreeV2KeyOnlyHandle<_Key: Comparable>: _UnsafeNodePtrType {

  @inlinable @inline(__always)
  internal init(
    header: UnsafeMutablePointer<UnsafeTreeV2BufferHeader>,
    isMulti: Bool
  ) {
    self.header = header
    self.nullptr = header.pointee.nullptr
    self.root_ptr = header.pointee.root_ptr
    self.isMulti = isMulti
  }

  @usableFromInline typealias _Key = _Key
  @usableFromInline typealias _PayloadValue = _Key
  @usableFromInline typealias _Pointer = _NodePtr

  @usableFromInline let header: UnsafeMutablePointer<UnsafeTreeV2BufferHeader>
  @usableFromInline let nullptr: _NodePtr
  @usableFromInline let root_ptr: _NodeRef  // root_refのほうが名前として妥当かも
  @usableFromInline let isMulti: Bool
}

extension UnsafeTreeV2KeyOnlyHandle {

  @inlinable
  @inline(__always)
  func __key(_ __v: _PayloadValue) -> _Key { __v }

  @inlinable
  func value_comp(_ __l: _Key, _ __r: _Key) -> Bool {
    __l < __r
  }

  @inlinable
  func value_equiv(_ __l: _Key, _ __r: _Key) -> Bool {
    __l == __r
  }

  @inlinable
  func __comp(_ __lhs: _Key, _ __rhs: _Key) -> __int_compare_result {
    __default_three_way_comparator(__lhs, __rhs)
  }
}

// MARK: - TreeNodeValueProtocol

extension UnsafeTreeV2KeyOnlyHandle {

  @inlinable
  func __get_value(_ p: _NodePtr) -> _Key {
    p.__value_(as: _PayloadValue.self).pointee
  }
}

extension UnsafeTreeV2KeyOnlyHandle {

  @inlinable
  @inline(__always)
  public func __construct_node(_ k: _PayloadValue) -> _NodePtr {
    let p = header.pointee.__construct_raw_node()
    // あえてのdefer
    defer { p.__value_().initialize(to: k) }
    return p
  }
}

extension UnsafeTreeV2KeyOnlyHandle {

  @inlinable
  var __begin_node_: _NodePtr {
    get {
      header.pointee.begin_ptr.pointee
    }
    nonmutating set {
      header.pointee.begin_ptr.pointee = newValue
    }
  }

  @inlinable
  @inline(__always)
  var __root: _NodePtr {
    root_ptr.pointee
  }

  @inlinable
  @inline(__always)
  func __root_ptr() -> _NodeRef {
    root_ptr
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

extension UnsafeTreeV2KeyOnlyHandle {
  @usableFromInline
  typealias __compare_result = __int_compare_result
}

extension UnsafeTreeV2KeyOnlyHandle: BoundBothProtocol, BoundAlgorithmProtocol_ptr {}
extension UnsafeTreeV2KeyOnlyHandle: FindInteface, FindProtocol_ptr {}
extension UnsafeTreeV2KeyOnlyHandle: RemoveInteface, RemoveProtocol_ptr {}
extension UnsafeTreeV2KeyOnlyHandle: EraseProtocol {}
extension UnsafeTreeV2KeyOnlyHandle: EraseUniqueProtocol {}
extension UnsafeTreeV2KeyOnlyHandle: FindEqualInterface, FindEqualProtocol_ptr {}
extension UnsafeTreeV2KeyOnlyHandle: InsertNodeAtInterface, InsertNodeAtProtocol_ptr {}
extension UnsafeTreeV2KeyOnlyHandle: InsertUniqueInterface, InsertUniqueProtocol_ptr {}
extension UnsafeTreeV2KeyOnlyHandle: _TreeNode_PtrCompInterface, _Tree_IsMultiTraitInterface,
  _TreeNode_PtrCompProtocol, _TreeNode_PtrCompUniqueProtocol
{}
extension UnsafeTreeV2KeyOnlyHandle: CountProtocol_ptr {}

extension UnsafeTreeV2KeyOnlyHandle: TreeAlgorithmBaseProtocol_ptr {}
extension UnsafeTreeV2KeyOnlyHandle: TreeAlgorithmProtocol_ptr {}
