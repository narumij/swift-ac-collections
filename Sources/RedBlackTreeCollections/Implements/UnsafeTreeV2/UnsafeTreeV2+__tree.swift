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

// MARK: - TreeNodeValueProtocol

extension UnsafeTreeV2: _TreeNode_KeyProtocol {}

// MARK: - BeginNodeProtocol

extension UnsafeTreeV2 {

  @inlinable
  package var __begin_node_: _NodePtr {

    @inline(__always)
    @_transparent
    unsafeAddress {
      UnsafePointer(withMutableHeader { $0.begin_ptr })
    }

    @inline(__always)
    @_transparent
    nonmutating unsafeMutableAddress {
      withMutableHeader { $0.begin_ptr }
    }
  }
}

// MARK: - EndNodeProtocol

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  package var __end_node: _NodePtr {
    //    origin.pointee.end_ptr
    withMutableHeader { $0.end_ptr }
  }
}

// MARK: - RootProtocol

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  var __root: _NodePtr {
    @inline(__always) _read {
      yield withMutableHeader { $0.root_ptr }.pointee
    }
  }

  // MARK: - RootPtrProtocol

  @inlinable
  package func __root_ptr() -> _NodeRef {
    withMutableHeader { $0.root_ptr }
  }
}

// MARK: - SizeProtocol

extension UnsafeTreeV2 {

  @inlinable
  package var __size_: Int {
    @inline(__always) get {
      withMutableHeader { $0.count }
    }
    nonmutating set {
      /* NOP */
    }
  }
}

// MARK: - AllocatorProtocol

extension UnsafeTreeV2 {

  @inlinable
  public func __construct_node(_ k: _PayloadValue) -> _NodePtr {
    withMutableHeader {
      $0.__construct_node(k)
    }
  }

  @inlinable
  internal func destroy(_ p: _NodePtr) {
    withMutableHeader {
      $0.___pushRecycle(p)
    }
  }
}

extension UnsafeTreeV2 {

  @inlinable
  package func __value_(_ p: _NodePtr) -> _PayloadValue {
    p.__value_().pointee
  }
}

extension UnsafeTreeV2: _PayloadValueBridge_Key & _ValueCompBridge {}

extension UnsafeTreeV2: _PtrCompBridge where Base: _BaseNode_PtrCompInterface {}

extension UnsafeTreeV2: _PtrRangeCompBridge where Base: _BaseNode_PtrRangeCompInterface {}

extension UnsafeTreeV2: _SignedDistanceBridge where Base: _BaseNode_SignedDistanceInterface {}

extension UnsafeTreeV2: BoundBothInterface {

  @inlinable
//  @inline(__always)
  public var isMulti: Bool {
    Base.isMulti
  }
}

extension UnsafeTreeV2: IntThreeWayComparator {}
extension UnsafeTreeV2: FindProtocol_ptr {}
extension UnsafeTreeV2: FindEqualInterface, FindEqualProtocol_ptr {

  @inlinable
  package func __comp(_ __lhs: Base._Key, _ __rhs: Base._Key) -> __compare_result {
    __lazy_synth_three_way_comparator(__lhs, __rhs)
  }
}
extension UnsafeTreeV2: FindLeafProtocol_ptr {}
extension UnsafeTreeV2: InsertNodeAtInterface, InsertNodeAtProtocol_ptr {}
extension UnsafeTreeV2: InsertUniqueInterface, InsertUniqueProtocol_ptr {}
extension UnsafeTreeV2: InsertMultiProtocol {}
extension UnsafeTreeV2: BoundBothProtocol, BoundAlgorithmProtocol_ptr {}
extension UnsafeTreeV2: EqualProtocol_ptr {}
extension UnsafeTreeV2: RemoveInteface, RemoveProtocol_ptr {}
extension UnsafeTreeV2: EraseProtocol {}
extension UnsafeTreeV2: EraseUniqueProtocol {}
extension UnsafeTreeV2: EraseMultiProtocol {}
extension UnsafeTreeV2: CountProtocol_ptr {}
extension UnsafeTreeV2: InsertLastProtocol_ptr {}
extension UnsafeTreeV2: TreeAlgorithmBaseProtocol_ptr {}
extension UnsafeTreeV2: TreeAlgorithmProtocol_ptr {}

extension UnsafeTreeV2 {

  @inlinable
  internal func ___min() -> _PayloadValue? {
    __root == nullptr ? nil : Base.__payload_(__tree_min(__root))
  }

  @inlinable
  internal func ___max() -> _PayloadValue? {
    __root == nullptr ? nil : Base.__payload_(__tree_max(__root))
  }
}
