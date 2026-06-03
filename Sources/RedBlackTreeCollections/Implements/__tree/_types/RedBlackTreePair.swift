//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project.
//
// Copyright (c) 2024-2026 narumij.
// Licensed under the Apache License v2.0.
//
// SPDX-License-Identifier: Apache-2.0
//
// This implementation includes code derived from LLVM libc++'s red-black tree
// implementation, originally distributed under the Apache License v2.0 with
// LLVM Exceptions.
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by
// narumij.
//
//===----------------------------------------------------------------------===//

/// DictionaryやMultiMapの内部保持に用いるデータ型
///
/// Swift6.2でタプルの速度低下がみられたので、構造体を採用している
///
@frozen
public struct RedBlackTreePair<Key, Value> {

  @inlinable
  package init(tuple: (key: Key, value: Value)) {
    self.tuple = tuple
  }

  // elementにリネームしたい衝動がある
  public var tuple: (key: Key, value: Value)
}

extension RedBlackTreePair {}

extension RedBlackTreePair: Sendable where Key: Sendable, Value: Sendable {}

extension RedBlackTreePair: Hashable where Key: Hashable, Value: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(tuple.key)
    hasher.combine(tuple.value)
  }
}

extension RedBlackTreePair: Equatable where Key: Equatable, Value: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.tuple == rhs.tuple
  }
}

extension RedBlackTreePair: Comparable where Key: Comparable, Value: Comparable {
  @inlinable
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.tuple < rhs.tuple
  }
}

extension RedBlackTreePair: Encodable where Key: Encodable, Value: Encodable {

  @inlinable
  public func encode(to encoder: Encoder) throws {
    var container = encoder.unkeyedContainer()
    try container.encode(tuple.key)
    try container.encode(tuple.value)
  }
}

extension RedBlackTreePair: Decodable where Key: Decodable, Value: Decodable {
  @inlinable
  public init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    self.init(
      tuple: (
        key: try container.decode(Key.self),
        value: try container.decode(Value.self)
      ))
  }
}
