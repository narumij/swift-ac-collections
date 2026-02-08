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

// MARK: - TreeEndNodeProtocol

extension UnsafeTreeV2: _pointer_type {

  @inlinable
  @inline(__always)
  package func __left_(_ p: _NodePtr) -> _NodePtr {
    return p.pointee.__left_
  }

  @inlinable
  @inline(__always)
  package func __left_unsafe(_ p: _NodePtr) -> _NodePtr {
    return p.pointee.__left_
  }

  @inlinable
  @inline(__always)
  package func __left_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    lhs.pointee.__left_ = rhs
  }
}

// MARK: - TreeNodeProtocol

extension UnsafeTreeV2: TreeNodeAccessInterface {

  @inlinable
  @inline(__always)
  package func __right_(_ p: _NodePtr) -> _NodePtr {
    return p.pointee.__right_
  }

  @inlinable
  @inline(__always)
  package func __right_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    lhs.pointee.__right_ = rhs
  }

  @inlinable
  @inline(__always)
  package func __is_black_(_ p: _NodePtr) -> Bool {
    return p.pointee.__is_black_
  }

  @inlinable
  @inline(__always)
  package func __is_black_(_ lhs: _NodePtr, _ rhs: Bool) {
    lhs.pointee.__is_black_ = rhs
  }

  @inlinable
  @inline(__always)
  package func __parent_(_ p: _NodePtr) -> _NodePtr {
    return p.pointee.__parent_
  }

  @inlinable
  @inline(__always)
  package func __parent_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    lhs.pointee.__parent_ = rhs
  }

  @inlinable
  @inline(__always)
  package func __parent_unsafe(_ p: _NodePtr) -> _NodePtr {
    return p.pointee.__parent_
  }
}

// MARK: -

extension UnsafeTreeV2: TreeNodeRefAccessInterface {

  @inlinable
  @inline(__always)
  package func __left_ref(_ p: _NodePtr) -> _NodeRef {
    return _ref(to: &p.pointee.__left_)
  }

  @inlinable
  @inline(__always)
  package func __right_ref(_ p: _NodePtr) -> _NodeRef {
    return _ref(to: &p.pointee.__right_)
  }

  @inlinable
  @inline(__always)
  package func __ptr_(_ rhs: _NodeRef) -> _NodePtr {
    rhs.pointee
  }

  @inlinable
  @inline(__always)
  package func __ptr_(_ lhs: _NodeRef, _ rhs: _NodePtr) {
    lhs.pointee = rhs
  }
}

// MARK: - TreeNodeValueProtocol

extension UnsafeTreeV2: _TreeNode_KeyProtocol {}

// MARK: - BeginNodeProtocol

extension UnsafeTreeV2 {

  @inlinable
  package var __begin_node_: _NodePtr {

    @inline(__always) get {
      //      _buffer.withUnsafeMutablePointerToElements { $0.pointee.begin_ptr }
//      origin.pointee.begin_ptr
      withMutableHeader { $0.begin_ptr.pointee }
    }

    @inline(__always)
    nonmutating set {
//      origin.pointee.begin_ptr = newValue
      //      _buffer.withUnsafeMutablePointerToElements { $0.pointee.begin_ptr = newValue }
      withMutableHeader { $0.begin_ptr.pointee = newValue }

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

  #if !DEBUG
    @nonobjc
    @inlinable
    @inline(__always)
    package var __root: _NodePtr {
      get { withMutableHeader { $0.__root } }
    }
  #else
    @inlinable
    @inline(__always)
    package var __root: _NodePtr {
      get { withMutableHeader { $0.__root } }
      set { withMutableHeader { $0.__root = newValue } }
    }
  #endif

  // MARK: - RootPtrProtocol

  @inlinable
  @inline(__always)
  package func __root_ptr() -> _NodeRef {
//    origin.pointee.__root_ptr()
    withMutableHeader { $0.__root_ptr() }  }
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
  @inline(__always)
  public func __construct_node(_ k: _PayloadValue) -> _NodePtr {
    withMutableHeader {
      $0.__construct_node(k)
    }
  }

  @inlinable
  @inline(__always)
  internal func destroy(_ p: _NodePtr) {
    withMutableHeader {
      $0.___pushRecycle(p)
    }
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  package func __value_(_ p: _NodePtr) -> _PayloadValue {
    p.__value_().pointee
  }

  @inlinable
  @inline(__always)
  package func ___element(_ p: _NodePtr, _ __v: _PayloadValue) {
    p.__value_().pointee = __v
  }
}

extension UnsafeTreeV2: _PayloadKeyBridge & _ValueCompBridge {}

extension UnsafeTreeV2: _SignedDistanceBridge where Base: _BaseNode_SignedDistanceInterface {}

extension UnsafeTreeV2: BoundBothInterface {

  @inlinable
  @inline(__always)
  package static var isMulti: Bool {
    Base.isMulti
  }

  @inlinable
  @inline(__always)
  public var isMulti: Bool {
    Base.isMulti
  }
}

extension UnsafeTreeV2: IntThreeWayComparator {}
extension UnsafeTreeV2: FindProtocol_ptr {}
extension UnsafeTreeV2: FindEqualInterface, FindEqualProtocol_ptr {
  
  @inlinable
  @inline(__always)
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
extension UnsafeTreeV2: _TreeNode_PtrCompProtocol, _TreeNode_PtrCompUniqueProtocol {}
extension UnsafeTreeV2: CountProtocol_ptr {}
extension UnsafeTreeV2: InsertLastProtocol_ptr {}
extension UnsafeTreeV2: CompareProtocol {}
extension UnsafeTreeV2: TreeAlgorithmBaseProtocol_ptr {}
extension UnsafeTreeV2: TreeAlgorithmProtocol_ptr {}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal func ___min() -> _PayloadValue? {
    __root == nullptr ? nil : self[__tree_min(__root)]
  }

  @inlinable
  @inline(__always)
  internal func ___max() -> _PayloadValue? {
    __root == nullptr ? nil : self[__tree_max(__root)]
  }
}
