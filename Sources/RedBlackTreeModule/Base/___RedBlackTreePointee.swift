//
//  ___RedBlackTreePointee.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/12/23.
//

public protocol ___RedBlackTreePointee {
  associatedtype _Value
  associatedtype Pointee
  static func ___pointee(_ __value: _Value) -> Pointee
}
