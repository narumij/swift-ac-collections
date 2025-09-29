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
  associatedtype _Value
  static func ___value(of element: Element) -> _Value
}

extension KeyValueComparer {

  @inlinable
  @inline(__always)
  static func ___key_equiv(_ lhs: Element, _ rhs: Element) -> Bool {
    value_equiv(__key(lhs), __key(rhs))
  }

  @inlinable
  @inline(__always)
  static func ___key_comp(_ lhs: Element, _ rhs: Element) -> Bool {
    value_comp(__key(lhs), __key(rhs))
  }
}

// MARK: -

extension KeyValueComparer where _Value: Comparable {
  @inlinable
  @inline(__always)
  static func ___element_comp(_ lhs: Element, _ rhs: Element) -> Bool {
    ___key_comp(lhs, rhs)
      || (!___key_comp(lhs, rhs) && ___value(of: lhs) < ___value(of: rhs))
  }
}

extension KeyValueComparer where _Value: Equatable {
  @inlinable
  @inline(__always)
  static func ___element_equiv(_ lhs: Element, _ rhs: Element) -> Bool {
    ___key_equiv(lhs, rhs) && ___value(of: lhs) == ___value(of: rhs)
  }
}

// MARK: -

extension ValueComparerProtocol where VC: KeyValueComparer {
  @inlinable
  @inline(__always)
  public static func ___value(of element: VC.Element) -> VC._Value { VC.___value(of: element) }
}

extension ValueComparerProtocol where VC: KeyValueComparer, VC._Value: Comparable {
  @inlinable
  @inline(__always)
  static func ___element_comp(_ lhs: VC.Element, _ rhs: VC.Element) -> Bool {
    VC.___element_comp(lhs, rhs)
  }
}

extension ValueComparerProtocol where VC: KeyValueComparer, VC._Value: Equatable {
  @inlinable
  @inline(__always)
  static func ___element_equiv(_ lhs: VC.Element, _ rhs: VC.Element) -> Bool {
    VC.___element_equiv(lhs, rhs)
  }
}

// MARK: -

// TODO: 最近タプルの最適化が甘いので、構造体に変更する.
// 以外とやっかいで諦めかけている

public typealias _KeyValueTuple_<_Key, _Value> = (key: _Key, value: _Value)

extension KeyValueComparer {
  public typealias _KeyValueTuple = _KeyValueTuple_<_Key, _Value>
}

extension KeyValueComparer where Element == _KeyValueTuple {

  @inlinable
  @inline(__always)
  public static func __key(_ element: Element) -> _Key { element.key }

  @inlinable
  @inline(__always)
  public static func ___value(of element: Element) -> _Value { element.value }
}

// MARK: -

public struct _KeyValueElement<Key, Value> {
  @inlinable
  @inline(__always)
  public init(key: Key, value: Value) {
    self.key = key
    self.value = value
  }
  @inlinable
  @inline(__always)
  public init(_ key: Key,_ value: Value) {
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

extension KeyValueComparer where Element == _KeyValueElement<_Key,_Value> {

  @inlinable
  @inline(__always)
  public static func __key(_ element: Element) -> _Key { element.key }

  @inlinable
  @inline(__always)
  public static func ___value(of element: Element) -> _Value { element.value }
}

#if true
@inlinable
public func keyValue<K,V>(_ key: K,_ value: V) -> _KeyValueTuple_<K,V> {
  (key, value)
}
@inlinable
func keyValue<K,V>(_ tuple: (K, V)) -> _KeyValueTuple_<K,V> {
  tuple
}
@inlinable
func keyValue<K,V>(_ key: K,_ value: V) -> _KeyValueElement<K,V> {
  .init(key, value)
}
@inlinable
func keyValue<K,V>(_ tuple: _KeyValueTuple_<K,V>) -> _KeyValueElement<K,V> {
  .init(tuple)
}
@inlinable
func keyValue<K,V>(_ kv: _KeyValueElement<K,V>) -> (K,V) {
  (kv.key, kv.value)
}
#else
@inlinable
func keyValue<K,V>(_ key: K,_ value: V) -> _KeyValueElement<K,V> {
  .init(key, value)
}
@inlinable
func keyValue<K,V>(_ tuple: (K, V)) -> _KeyValueElement<K,V> {
  .init(tuple)
}
@inlinable
func _keyValue<K,V>(_ kv: _KeyValueElement<K,V>) -> (K,V) {
  (kv.key, kv.value)
}
#endif
