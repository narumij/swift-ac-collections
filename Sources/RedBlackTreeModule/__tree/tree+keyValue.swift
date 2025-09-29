//
//  tree+keyValue.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/09/29.
//

/// 要素がキーバリューの場合のひな形
public protocol KeyValueComparer: ValueComparer {
  associatedtype _Value
}

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
}

extension KeyValueComparer where Element == _KeyValueTuple {

  @inlinable
  @inline(__always)
  public static func ___key_equiv(_ lhs: Element, _ rhs: Element) -> Bool {
    value_equiv(__key(lhs), __key(rhs))
  }

  @inlinable
  @inline(__always)
  static func ___key_comp(_ lhs: Element, _ rhs: Element) -> Bool {
    value_comp(__key(lhs), __key(rhs))
  }
}

extension KeyValueComparer where Element == _KeyValueTuple, _Key: Equatable {

  @inlinable
  @inline(__always)
  public static func ___key_equiv(_ lhs: Element, _ rhs: Element) -> Bool {
    __key(lhs) == __key(rhs)
  }
}

extension KeyValueComparer where Element == _KeyValueTuple, _Key: Comparable {

  @inlinable
  @inline(__always)
  static func ___key_comp(_ lhs: Element, _ rhs: Element) -> Bool {
    __key(lhs) < __key(rhs)
  }
}

extension KeyValueComparer
where
  Element == _KeyValueTuple_<_Key, _Value>,
  _Value: Comparable
{

  public static func ___element_comp(_ lhs: Element, _ rhs: Element) -> Bool {
    ___key_comp(lhs, rhs) || (!___key_comp(lhs, rhs) && lhs.value < rhs.value)
  }
}

extension KeyValueComparer
where
  Element == _KeyValueTuple_<_Key, _Value>,
  _Value: Equatable
{

  public static func ___element_equiv(_ lhs: Element, _ rhs: Element) -> Bool {
    ___key_equiv(lhs, rhs) && lhs.value == rhs.value
  }
}

extension ValueComparerProtocol
where
  VC: KeyValueComparer,
  VC.Element == _KeyValueTuple_<VC._Key, VC._Value>
{
  @inlinable
  @inline(__always)
  static func ___key_comp(_ lhs: VC.Element, _ rhs: VC.Element) -> Bool {
    VC.___key_comp(lhs, rhs)
  }
  
  @inlinable
  @inline(__always)
  static func ___key_equiv(_ lhs: VC.Element, _ rhs: VC.Element) -> Bool {
    VC.___key_equiv(lhs, rhs)
  }
}

extension ValueComparerProtocol
where
  VC: KeyValueComparer,
  VC.Element == _KeyValueTuple_<VC._Key, VC._Value>,
  VC._Value: Comparable
{
  @inlinable
  @inline(__always)
  static func ___element_comp(_ lhs: VC.Element, _ rhs: VC.Element) -> Bool {
    VC.___element_comp(lhs, rhs)
  }
}

extension ValueComparerProtocol
where
  VC: KeyValueComparer,
  VC.Element == _KeyValueTuple_<VC._Key, VC._Value>,
  VC._Value: Equatable
{
  @inlinable
  @inline(__always)
  static func ___element_equiv(_ lhs: VC.Element, _ rhs: VC.Element) -> Bool {
    VC.___element_equiv(lhs, rhs)
  }
}
