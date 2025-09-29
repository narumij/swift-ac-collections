//
//  tree+scalar.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/09/29.
//

/// 要素とキーが一致する場合のひな形
public protocol ScalarValueComparer: ValueComparer where _Key == Element {
  static func ___element_comp(_ lhs: Element, _ rhs: Element) -> Bool
  static func ___element_equiv(_ lhs: Element, _ rhs: Element) -> Bool
}

extension ScalarValueComparer {

  @inlinable
  @inline(__always)
  public static func __key(_ e: Element) -> _Key { e }

  @inlinable
  @inline(__always)
  public static func ___element_comp(_ lhs: Element, _ rhs: Element) -> Bool {
    value_comp(__key(lhs), __key(rhs))
  }

  @inlinable
  @inline(__always)
  public static func ___element_equiv(_ lhs: Element, _ rhs: Element) -> Bool {
    value_equiv(__key(lhs), __key(rhs))
  }
}

extension ScalarValueComparer where Element: Equatable {

  @inlinable
  @inline(__always)
  public static func ___element_equiv(_ lhs: Element, _ rhs: Element) -> Bool {
    lhs == rhs
  }
}

extension ScalarValueComparer where Element: Comparable {

  @inlinable
  @inline(__always)
  public static func ___element_comp(_ lhs: Element, _ rhs: Element) -> Bool {
    lhs < rhs
  }
}

extension ValueComparerProtocol where VC: ScalarValueComparer {

  @inlinable
  @inline(__always)
  static func ___element_comp(_ lhs: VC.Element, _ rhs: VC.Element) -> Bool {
    VC.___element_comp(lhs, rhs)
  }

  @inlinable
  @inline(__always)
  static func ___element_equiv(_ lhs: VC.Element, _ rhs: VC.Element) -> Bool {
    VC.___element_equiv(lhs, rhs)
  }
}
