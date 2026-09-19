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

public struct _LinkingPair<Key, Value>: _UnsafeNodePtrType {

  @inlinable
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

public protocol LinkPairValueTrait: KeyValueTrait & _Base_IsMultiInterface & _UnsafeNodePtrType
where _PayloadValue == _LinkingPair<_Key, _MappedValue> {}

extension LinkPairValueTrait {
  @inlinable
  public static var isMulti: Bool { true }
}

extension LinkPairValueTrait {

  @inlinable
  public static func __key(_ element: _PayloadValue) -> _Key { element.key }

  @inlinable
  public static func __get_value(_ p: UnsafeMutablePointer<UnsafeNode>) -> _Key {
    p.__value_(as: _PayloadValue.self).pointee.key
  }

  @inlinable
  public static func ___mapped_value(_ element: _PayloadValue) -> _MappedValue {
    element.value
  }

  @inlinable
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
  mutating func ___prepend(_ __p: _NodePtr) {
    if _rankHighest == nullptr {
      Base.__payload_ptr(__p).pointee.next = nullptr
      Base.__payload_ptr(__p).pointee.prev = nullptr
      _rankLowest = __p
      _rankHighest = __p
    } else {
      Base.__payload_ptr(_rankHighest).pointee.prev = __p
      Base.__payload_ptr(__p).pointee.next = _rankHighest
      Base.__payload_ptr(__p).pointee.prev = nullptr
      _rankHighest = __p
    }
  }

  @inlinable
  mutating func ___pop(_ __p: _NodePtr) -> _NodePtr {

    assert(
      __p == _rankHighest ||
      Base.__payload_ptr(__p).pointee.next != nullptr ||
      Base.__payload_ptr(__p).pointee.prev != nullptr,
      "did not contain \(__p) ptr.")

    defer {
      let prev = Base.__payload_(__p).prev
      let next = Base.__payload_(__p).next
      if prev != nullptr {
        Base.__payload_ptr(prev).pointee.next = next
      } else {
        _rankHighest = next
      }
      if next != nullptr {
        Base.__payload_ptr(next).pointee.prev = prev
      } else {
        _rankLowest = prev
      }
    }

    return __p
  }

  @inlinable
  mutating func ___popRankLowest() -> _NodePtr {

    defer {
      if _rankLowest != nullptr {
        _rankLowest = Base.__payload_(_rankLowest).prev
      }
      if _rankLowest != nullptr {
        Base.__payload_ptr(_rankLowest).pointee.next = nullptr
      } else {
        _rankHighest = nullptr
      }
    }

    return _rankLowest
  }
}
