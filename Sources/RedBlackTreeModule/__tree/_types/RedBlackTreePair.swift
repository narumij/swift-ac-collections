//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project
//
// Copyright (c) 2024 - 2026 narumij.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.
//
//===----------------------------------------------------------------------===//

@frozen
public struct RedBlackTreePair<Key, Value> {

  @inlinable
  @inline(__always)
  internal init(key: Key, value: Value) {
    self.key = key
    self.value = value
  }

  @inlinable
  @inline(__always)
  package init(_ key: Key, _ value: Value) {
    self.key = key
    self.value = value
  }

  @inlinable
  @inline(__always)
  package init(_ tuple: (Key, Value)) {
    self.key = tuple.0
    self.value = tuple.1
  }

  public var key: Key
  public var value: Value  // mapped_valueのほうが、混乱が減るのでいい気がしてきている
  public var tuple: (Key, Value) { (key, value) }

  @inlinable
  @inline(__always)
  public var first: Key { key }

  @inlinable
  @inline(__always)
  public var second: Value { value }
}

#if swift(>=5.5)
  extension RedBlackTreePair: Sendable where Key: Sendable, Value: Sendable {}
#endif

extension RedBlackTreePair: Hashable where Key: Hashable, Value: Hashable {}
extension RedBlackTreePair: Equatable where Key: Equatable, Value: Equatable {}
extension RedBlackTreePair: Comparable where Key: Comparable, Value: Comparable {
  public static func < (lhs: RedBlackTreePair<Key, Value>, rhs: RedBlackTreePair<Key, Value>)
    -> Bool
  {
    (lhs.key, lhs.value) < (rhs.key, rhs.value)
  }
}
extension RedBlackTreePair: Encodable where Key: Encodable, Value: Encodable {}
extension RedBlackTreePair: Decodable where Key: Decodable, Value: Decodable {}
