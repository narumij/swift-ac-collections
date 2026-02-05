//
//  KeyValueComparer.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/12/23.
//

import RedBlackTreeModule

// KeyValueの内部実装はPairに移行済み
// 以下はテストでのみ使っている

extension KeyValueComparer where _PayloadValue == (key: _Key, value: _MappedValue) {

  @inlinable
  @inline(__always)
  public static func __key(_ element: _PayloadValue) -> _Key { element.key }

  @inlinable
  @inline(__always)
  public static func ___mapped_value(_ element: _PayloadValue) -> _MappedValue { element.value }

  @inlinable
  @inline(__always)
  public static func ___with_mapped_value<T>(
    _ element: inout _PayloadValue, _ f: (inout _MappedValue) throws -> T
  ) rethrows -> T {
    try f(&element.value)
  }
}
