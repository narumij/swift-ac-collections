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

/// SetやMultiset用に特殊化されたハンドル
///
/// `_Key`の取得に関して特殊化済みとなっている。
///
/// その他に比較演算の強制キャストによる特殊化も盛り込まれている。
///
@frozen
@usableFromInline
struct UnsafeTreeV2ScalarHandle<_Key: Comparable>: _UnsafeNodePtrType {
  @inlinable
  internal init(
    header: UnsafeMutablePointer<UnsafeTreeV2BufferHeader>,
    isMulti: Bool
  ) {
    self.header = header
    self.isMulti = false
  }
  @usableFromInline typealias _Key = _Key
  @usableFromInline typealias _Value = _Key
//  @usableFromInline typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  @usableFromInline typealias _Pointer = _NodePtr
//  @usableFromInline typealias _NodeRef = UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>
  @usableFromInline let header: UnsafeMutablePointer<UnsafeTreeV2BufferHeader>
  @usableFromInline var isMulti: Bool
}

extension UnsafeTreeV2 where _Key == _Value, _Key: Comparable {

  @usableFromInline
  typealias Handle = UnsafeTreeV2ScalarHandle<UnsafeTreeV2<Base>._Value>

  @inlinable
  @inline(__always)
  internal func read<R>(_ body: (Handle) throws -> R) rethrows -> R {
    try _buffer.withUnsafeMutablePointers { header, elements in
      let handle = Handle(
        header: header, isMulti: isMulti)
      return try body(handle)
    }
  }

  @inlinable
  @inline(__always)
  internal func _i_update<R>(_ body: (UnsafeTreeV2ScalarHandle<Int>) throws -> R) rethrows -> R {
    try _buffer.withUnsafeMutablePointers { header, elements in
      let handle = UnsafeTreeV2ScalarHandle<Int>(
        header: header, isMulti: isMulti)
      return try body(handle)
    }
  }

  @inlinable
  @inline(__always)
  internal func update<R>(_ body: (Handle) throws -> R) rethrows -> R {
    try _buffer.withUnsafeMutablePointers { header, elements in
      let handle = Handle(
        header: header, isMulti: isMulti)
      return try body(handle)
    }
  }
}

extension UnsafeTreeV2ScalarHandle {

  @inlinable
  @inline(__always)
  func __key(_ __v: _Value) -> _Key { __v }

  @inlinable
  func value_comp(_ __l: _Key, _ __r: _Key) -> Bool {
    __l < __r
  }

  @inlinable
  func value_equiv(_ __l: _Key, _ __r: _Key) -> Bool {
    __l == __r
  }

  @inlinable
  func __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key) -> __int_compare_result {
    __default_three_way_comparator(__lhs, __rhs)
  }

  @inlinable
  func __comp(_ __lhs: _Key, _ __rhs: _Key) -> __int_compare_result {
    __default_three_way_comparator(__lhs, __rhs)
  }
  
  @inlinable
  func ___ptr_comp(_ l: _NodePtr, _ r: _NodePtr) -> Bool {
    l.__value_(as: _Key.self) < r.__value_(as: _Key.self)
  }
}

// MARK: - TreeNodeValueProtocol

extension UnsafeTreeV2ScalarHandle {

  @inlinable
  func __get_value(_ p: _NodePtr) -> _Key {
    p.__value_().pointee
  }
}

extension UnsafeTreeV2ScalarHandle {

  @inlinable
  @inline(__always)
  public func __construct_node(_ k: _Value) -> _NodePtr {
    let p = header.pointee.__construct_raw_node()
    // あえてのdefer
    defer { p.__value_().initialize(to: k) }
    return p
  }
}

extension UnsafeTreeV2ScalarHandle {
  
  @inlinable
  var nullptr: UnsafeMutablePointer<UnsafeNode> {
    header.pointee.nullptr
  }

  @inlinable
  var __begin_node_: UnsafeMutablePointer<UnsafeNode> {
    get {
      header.pointee.begin_ptr
    }
    nonmutating set {
      header.pointee.begin_ptr = newValue
    }
  }

  @inlinable
  var __root: UnsafeMutablePointer<UnsafeNode> {
    header.pointee.root_ptr.pointee
  }

  @inlinable
  func __root_ptr() -> UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>> {
    header.pointee.root_ptr
  }

  @inlinable
  var end: UnsafeMutablePointer<UnsafeNode> {
    header.pointee.end_ptr
  }

  @inlinable
  var __end_node: UnsafeMutablePointer<UnsafeNode> {
    header.pointee.end_ptr
  }


  @inlinable
  func destroy(_ p: UnsafeMutablePointer<UnsafeNode>) {
    header.pointee.___pushRecycle(p)
  }
  
  
  @inlinable
  var __size_: Int {
    get { header.pointee.count }
    nonmutating set { /* NOP */ }
  }
}

extension UnsafeTreeV2ScalarHandle: BoundBothProtocol, BoundAlgorithmProtocol_ptr {}
extension UnsafeTreeV2ScalarHandle: FindInteface, FindProtocol_ptr {}
extension UnsafeTreeV2ScalarHandle: RemoveInteface, RemoveProtocol_ptr {}
extension UnsafeTreeV2ScalarHandle: EraseProtocol {}
extension UnsafeTreeV2ScalarHandle: EraseUniqueProtocol {}
extension UnsafeTreeV2ScalarHandle: FindEqualInterface, FindEqualProtocol_ptr {}
extension UnsafeTreeV2ScalarHandle: InsertNodeAtInterface, InsertNodeAtProtocol_ptr {}
extension UnsafeTreeV2ScalarHandle: InsertUniqueInterface, InsertUniqueProtocol_ptr {}
//extension UnsafeTreeV2ScalarHandle: ___EraseUniqueProtocol {}
extension UnsafeTreeV2ScalarHandle: PointerCompareInterface, IsMultiTraitInterface, CompareBothProtocol_ptr, CompareMultiProtocol_ptr, NodeBitmapProtocol_ptr {}
extension UnsafeTreeV2ScalarHandle: DistanceProtocol_ptr, CountProtocol_ptr {}

