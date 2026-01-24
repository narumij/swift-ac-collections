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
    self.nullptr = header.pointee.nullptr
    self.root_ptr = header.pointee.root_ptr
  }
  @usableFromInline typealias _Key = _Key
  @usableFromInline typealias _RawValue = _Key
  @usableFromInline typealias _Pointer = _NodePtr
  @usableFromInline let header: UnsafeMutablePointer<UnsafeTreeV2BufferHeader>
  @usableFromInline let nullptr: _NodePtr
  @usableFromInline let root_ptr: UnsafeMutablePointer<_NodePtr>
  @usableFromInline var isMulti: Bool
}

extension UnsafeTreeV2 where _Key == _RawValue, _Key: Comparable {

  @usableFromInline
  typealias Handle = UnsafeTreeV2ScalarHandle<UnsafeTreeV2<Base>._RawValue>

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
  func __key(_ __v: _RawValue) -> _Key { __v }

  @inlinable
  func value_comp(_ __l: _Key, _ __r: _Key) -> Bool {
    __l < __r
  }

  @inlinable
  func value_equiv(_ __l: _Key, _ __r: _Key) -> Bool {
    __l == __r
  }

//  @inlinable
//  func __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key) -> __int_compare_result {
//    __default_three_way_comparator(__lhs, __rhs)
//  }

  @inlinable
  func __comp(_ __lhs: _Key, _ __rhs: _Key) -> __int_compare_result {
    __default_three_way_comparator(__lhs, __rhs)
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
  public func __construct_node(_ k: _RawValue) -> _NodePtr {
    let p = header.pointee.__construct_raw_node()
    // あえてのdefer
    defer { p.__value_().initialize(to: k) }
    return p
  }
}

extension UnsafeTreeV2ScalarHandle {
  
  @inlinable
  var __begin_node_: UnsafeMutablePointer<UnsafeNode> {
    get {
      header.pointee.begin_ptr.pointee
    }
    nonmutating set {
      header.pointee.begin_ptr.pointee = newValue
    }
  }

  @inlinable
  @inline(__always)
  var __root: UnsafeMutablePointer<UnsafeNode> {
    root_ptr.pointee
  }

  @inlinable
  @inline(__always)
  func __root_ptr() -> UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>> {
    root_ptr
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

extension UnsafeTreeV2ScalarHandle: BoundBothProtocol, BoundAlgorithmProtocol_ptr {
  @usableFromInline
  typealias __compare_result = __int_compare_result
}
extension UnsafeTreeV2ScalarHandle: FindInteface, FindProtocol_ptr {}
extension UnsafeTreeV2ScalarHandle: RemoveInteface, RemoveProtocol_ptr {}
extension UnsafeTreeV2ScalarHandle: EraseProtocol {}
extension UnsafeTreeV2ScalarHandle: EraseUniqueProtocol {}
extension UnsafeTreeV2ScalarHandle: FindEqualInterface, FindEqualProtocol_ptr {}
extension UnsafeTreeV2ScalarHandle: InsertNodeAtInterface, InsertNodeAtProtocol_ptr {}
extension UnsafeTreeV2ScalarHandle: InsertUniqueInterface, InsertUniqueProtocol_ptr {}
extension UnsafeTreeV2ScalarHandle: PointerCompareInterface, IsMultiTraitInterface, CompareBothProtocol_ptr, CompareUniqueProtocol {}
extension UnsafeTreeV2ScalarHandle: DistanceProtocol_ptr, CountProtocol_ptr {}

extension UnsafeTreeV2ScalarHandle: TreeAlgorithmBaseProtocol_ptr {}
extension UnsafeTreeV2ScalarHandle: TreeAlgorithmProtocol_ptr {}
