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

/// DictionaryやMultimap用に特殊化されたハンドル
///
/// `_Key`の取得に関して特殊化済みとなっている。
///
/// その他に比較演算の強制キャストによる特殊化も盛り込まれている。
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
//    self.origin = origin
    self.isMulti = false
  }
  @usableFromInline typealias _Key = _Key
  @usableFromInline typealias _RawValue = RedBlackTreePair<_Key, _MappedValue>
  @usableFromInline typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  @usableFromInline typealias _Pointer = _NodePtr
  @usableFromInline typealias _NodeRef = UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>
  @usableFromInline let header: UnsafeMutablePointer<UnsafeTreeV2BufferHeader>
//  @usableFromInline let origin: UnsafeMutableRawPointer
  @usableFromInline var isMulti: Bool
}

extension UnsafeTreeV2
where
  Base: KeyValueComparer,
  _Key: Comparable,
  _RawValue == RedBlackTreePair<_Key, Base._MappedValue>
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
  func __key(_ __v: _RawValue) -> _Key { __v.key }

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
    p.__value_(as: _RawValue.self).pointee.key
  }
}

extension UnsafeTreeV2KeyValueHandle: UnsafeTreeAccessHandleBase {}

extension UnsafeTreeV2KeyValueHandle: BoundBothProtocol, BoundAlgorithmProtocol {}
extension UnsafeTreeV2KeyValueHandle: FindInteface, FindProtocol_ptr {}
extension UnsafeTreeV2KeyValueHandle: FindEqualInterface, FindEqualProtocol_std {}
extension UnsafeTreeV2KeyValueHandle: InsertNodeAtInterface, InsertNodeAtProtocol_std {}
extension UnsafeTreeV2KeyValueHandle: InsertUniqueInterface, InsertUniqueProtocol_std {}
extension UnsafeTreeV2KeyValueHandle: RemoveInteface, RemoveProtocol_std {}
extension UnsafeTreeV2KeyValueHandle: EraseProtocol {}
extension UnsafeTreeV2KeyValueHandle: EraseUniqueProtocol {}
extension UnsafeTreeV2KeyValueHandle: TreeAlgorithmBaseProtocol_std {}
extension UnsafeTreeV2KeyValueHandle: TreeAlgorithmProtocol_std {}

extension UnsafeTreeV2KeyValueHandle {
  public typealias __compare_result = __int_compare_result
}
