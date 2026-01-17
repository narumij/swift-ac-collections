// Copyright 2024-2026 narumij
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2025 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

// MARK: - TreeEndNodeProtocol

extension UnsafeTreeV2: TreeEndNodeProtocol {

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

extension UnsafeTreeV2: TreeNodeProtocol {

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

extension UnsafeTreeV2: TreeNodeRefProtocol {

  @inlinable
  @inline(__always)
  package func __left_ref(_ p: _NodePtr) -> _NodeRef {
    return withUnsafeMutablePointer(to: &p.pointee.__left_) { $0 }
  }

  @inlinable
  @inline(__always)
  package func __right_ref(_ p: _NodePtr) -> _NodeRef {
    return withUnsafeMutablePointer(to: &p.pointee.__right_) { $0 }
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

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  package func __get_value(_ p: _NodePtr) -> _Key {
    Base.__key(p.__value_().pointee)
  }
}

// MARK: - BeginNodeProtocol

extension UnsafeTreeV2 {

  @inlinable
  package var __begin_node_: _NodePtr {

    @inline(__always) get {
      //      _buffer.withUnsafeMutablePointerToElements { $0.pointee.begin_ptr }
//      origin.pointee.begin_ptr
      withMutableHeader { $0.begin_ptr }
    }

    @inline(__always)
    nonmutating set {
//      origin.pointee.begin_ptr = newValue
      //      _buffer.withUnsafeMutablePointerToElements { $0.pointee.begin_ptr = newValue }
      withMutableHeader { $0.begin_ptr = newValue }

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
      withHeader { $0.count }
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
  public func __construct_node(_ k: _Value) -> _NodePtr {
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
  package func __value_(_ p: _NodePtr) -> _Value {
    p.__value_().pointee
  }

  @inlinable
  @inline(__always)
  package func ___element(_ p: _NodePtr, _ __v: _Value) {
    p.__value_().pointee = __v
  }
}

extension UnsafeTreeV2: ValueComparator {}
extension UnsafeTreeV2: BoundProtocol {

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

extension UnsafeTreeV2: FindProtocol {}
extension UnsafeTreeV2: FindEqualProtocol, FindEqualProtocol_ptr {}
extension UnsafeTreeV2: FindLeafProtocol {}
extension UnsafeTreeV2: InsertNodeAtProtocol {}
extension UnsafeTreeV2: InsertUniqueProtocol, InsertNodeAtProtocol_ptr {}
extension UnsafeTreeV2: InsertMultiProtocol {}
extension UnsafeTreeV2: EqualProtocol {}
extension UnsafeTreeV2: RemoveProtocol, RemoveProtocol_org {}
extension UnsafeTreeV2: EraseProtocol {}
extension UnsafeTreeV2: EraseUniqueProtocol {}
extension UnsafeTreeV2: EraseMultiProtocol {}
extension UnsafeTreeV2: CompareBothProtocol {}
extension UnsafeTreeV2: CountProtocol {}
extension UnsafeTreeV2: InsertLastProtocol {}
extension UnsafeTreeV2: CompareProtocol {}
