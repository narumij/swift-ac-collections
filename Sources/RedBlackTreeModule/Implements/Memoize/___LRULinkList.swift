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

import Foundation

public struct _LinkingPair<Key, Value>: _UnsafeNodePtrType {

  @inlinable
  @inline(__always)
  public init(_ key: Key, _ prev: _NodePtr, _ next: _NodePtr, _ value: Value) {
    self.key = key
    self.prev = prev
    self.next = next
    self.value = value
  }

  public var key: Key
  public var prev: _NodePtr
  public var next: _NodePtr
  public var value: Value
}

public protocol LinkPairValueTrait: KeyValueTrait & _Base_IsMultiTraitInterface & _UnsafeNodePtrType
where _PayloadValue == _LinkingPair<_Key, _MappedValue> {}

extension LinkPairValueTrait {
  @inlinable
  public static var isMulti: Bool { true }
}

extension LinkPairValueTrait {

  @inlinable @inline(__always)
  public static func __key(_ element: _PayloadValue) -> _Key { element.key }

  @inlinable
  @inline(__always)
  public static func __get_value(_ p: UnsafeMutablePointer<UnsafeNode>) -> _Key {
    p.__value_(as: _PayloadValue.self).pointee.key
  }

  @inlinable
  @inline(__always)
  public static func ___mapped_value(_ element: _PayloadValue) -> _MappedValue {
    element.value
  }

  @inlinable
  @inline(__always)
  public static func ___with_mapped_value<T>(
    _ element: inout _PayloadValue, _ f: (inout _MappedValue) throws -> T
  ) rethrows -> T {
    try f(&element.value)
  }
}

public enum ___LRULinkListBase<_Key: Comparable, _MappedValue>: LinkPairValueTrait
    & IntThreeWayComparator
{}

@usableFromInline
protocol ___LRULinkList: _KeyType & _MappedValueType & _UnsafeNodePtrType
where _Key: Comparable {
  associatedtype Value
  var __tree_: Tree { get set }
  var _rankHighest: _NodePtr { get set }
  var _rankLowest: _NodePtr { get set }
  var nullptr: _NodePtr { get }
}

extension ___LRULinkList {
  public typealias Base = ___LRULinkListBase<_Key, _MappedValue>
}

extension ___LRULinkList {

  public typealias Tree = UnsafeTreeV2<Base>

  @inlinable
  @inline(__always)
  mutating func ___prepend(_ __p: _NodePtr) {
    if _rankHighest == nullptr {
      __tree_[_unsafe_raw: __p].next = nullptr
      __tree_[_unsafe_raw: __p].prev = nullptr
      _rankLowest = __p
      _rankHighest = __p
    } else {
      __tree_[_unsafe_raw: _rankHighest].prev = __p
      __tree_[_unsafe_raw: __p].next = _rankHighest
      __tree_[_unsafe_raw: __p].prev = nullptr
      _rankHighest = __p
    }
  }

  @inlinable
  @inline(__always)
  mutating func ___pop(_ __p: _NodePtr) -> _NodePtr {

    assert(
      __p == _rankHighest ||
      __tree_[_unsafe_raw: __p].next != nullptr ||
      __tree_[_unsafe_raw: __p].prev != nullptr,
      "did not contain \(__p) ptr.")

    defer {
      let prev = __tree_[_unsafe_raw: __p].prev
      let next = __tree_[_unsafe_raw: __p].next
      if prev != nullptr {
        __tree_[_unsafe_raw: prev].next = next
      } else {
        _rankHighest = next
      }
      if next != nullptr {
        __tree_[_unsafe_raw: next].prev = prev
      } else {
        _rankLowest = prev
      }
    }

    return __p
  }

  @inlinable
  @inline(__always)
  mutating func ___popRankLowest() -> _NodePtr {

    defer {
      if _rankLowest != nullptr {
        _rankLowest = __tree_[_unsafe_raw: _rankLowest].prev
      }
      if _rankLowest != nullptr {
        __tree_[_unsafe_raw: _rankLowest].next = nullptr
      } else {
        _rankHighest = nullptr
      }
    }

    return _rankLowest
  }
}
