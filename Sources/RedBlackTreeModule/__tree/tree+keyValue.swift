// Copyright 2024 narumij
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
// Copyright © 2003-2024 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

import Foundation

/// 要素がキーバリューの場合のひな形
public protocol KeyValueComparer: ValueComparer {
  associatedtype _MappedValue
  static func ___mapped_value(of element: _Value) -> _MappedValue
}

extension KeyValueComparer {

  @inlinable
  @inline(__always)
  static func ___key_equiv(_ lhs: _Value, _ rhs: _Value) -> Bool {
    value_equiv(__key(lhs), __key(rhs))
  }

  @inlinable
  @inline(__always)
  static func ___key_comp(_ lhs: _Value, _ rhs: _Value) -> Bool {
    value_comp(__key(lhs), __key(rhs))
  }
}

// MARK: -

extension KeyValueComparer where _MappedValue: Comparable {
  @inlinable
  @inline(__always)
  static func ___element_comp(_ lhs: _Value, _ rhs: _Value) -> Bool {
    ___key_comp(lhs, rhs)
      || (!___key_comp(lhs, rhs) && ___mapped_value(of: lhs) < ___mapped_value(of: rhs))
  }
}

extension KeyValueComparer where _MappedValue: Equatable {
  @inlinable
  @inline(__always)
  static func ___element_equiv(_ lhs: _Value, _ rhs: _Value) -> Bool {
    ___key_equiv(lhs, rhs) && ___mapped_value(of: lhs) == ___mapped_value(of: rhs)
  }
}

// MARK: -

extension ValueComparerProtocol where VC: KeyValueComparer {
  @inlinable
  @inline(__always)
  public static func ___mapped_value(of element: VC._Value) -> VC._MappedValue {
    VC.___mapped_value(of: element)
  }
}

extension ValueComparerProtocol where VC: KeyValueComparer, VC._MappedValue: Comparable {
  @inlinable
  @inline(__always)
  static func ___element_comp(_ lhs: VC._Value, _ rhs: VC._Value) -> Bool {
    VC.___element_comp(lhs, rhs)
  }
}

extension ValueComparerProtocol where VC: KeyValueComparer, VC._MappedValue: Equatable {
  @inlinable
  @inline(__always)
  static func ___element_equiv(_ lhs: VC._Value, _ rhs: VC._Value) -> Bool {
    VC.___element_equiv(lhs, rhs)
  }
}

// MARK: -

// 最近タプルの最適化が甘いので、LRUのみペアを構造体に変更
// それ以外は一律速くなる感じでは無く、トレードオフになるため行わない

public typealias _KeyValueTuple_<Key, Value> = (key: Key, value: Value)

extension KeyValueComparer {
  public typealias _KeyValueTuple = _KeyValueTuple_<_Key, _MappedValue>
}

extension KeyValueComparer where _Value == _KeyValueTuple {

  @inlinable
  @inline(__always)
  public static func __key(_ element: _Value) -> _Key { element.key }

  @inlinable
  @inline(__always)
  public static func ___mapped_value(of element: _Value) -> _MappedValue { element.value }
}

// MARK: -

public struct Pair<Key, Value> {
  @inlinable
  @inline(__always)
  public init(key: Key, value: Value) {
    self.key = key
    self.value = value
  }
  @inlinable
  @inline(__always)
  public init(_ key: Key, _ value: Value) {
    self.key = key
    self.value = value
  }
  @inlinable
  @inline(__always)
  public init(_ tuple: (Key, Value)) {
    self.key = tuple.0
    self.value = tuple.1
  }
  public var key: Key
  public var value: Value
}

extension Pair: Sendable where Key: Sendable, Value: Sendable {}
extension Pair: Hashable where Key: Hashable, Value: Hashable {}
extension Pair: Equatable where Key: Equatable, Value: Equatable {}
extension Pair: Comparable where Key: Comparable, Value: Comparable {
  public static func < (lhs: Pair<Key, Value>, rhs: Pair<Key, Value>)
    -> Bool
  {
    (lhs.key, lhs.value) < (rhs.key, rhs.value)
  }
}

extension KeyValueComparer where _Value == Pair<_Key, _MappedValue> {

  @inlinable
  @inline(__always)
  public static func __key(_ element: _Value) -> _Key { element.key }

  @inlinable
  @inline(__always)
  public static func ___mapped_value(of element: _Value) -> _MappedValue { element.value }
}
