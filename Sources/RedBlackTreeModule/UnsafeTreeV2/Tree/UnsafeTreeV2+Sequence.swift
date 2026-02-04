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

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal func
    ___for_each_(__p: _NodePtr, __l: _NodePtr, body: (_NodePtr) throws -> Void)
    rethrows
  {
    for __c in sequence(__p, __l) {
      try body(__c)
    }
  }

  @inlinable
  @inline(__always)
  internal func ___rev_for_each_(
    __p: _NodePtr, __l: _NodePtr, body: (_NodePtr) throws -> Void
  )
    rethrows
  {
    for __c in sequence(__p, __l).reversed() {
      try body(__c)
    }
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal func ___for_each(
    __p: _NodePtr, __l: _NodePtr, body: (_NodePtr, inout Bool) throws -> Void
  )
    rethrows
  {
    for __c in sequence(__p, __l) {
      var cont = true
      try body(__c, &cont)
      if !cont {
        break
      }
    }
  }
}

extension UnsafeTreeV2 {

  @inlinable
  internal func elementsEqual<OtherSequence>(
    _ __first: _NodePtr, _ __last: _NodePtr, _ other: OtherSequence,
    by areEquivalent: (_PayloadValue, OtherSequence.Element) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence {
    try unsafeValues(__first, __last).elementsEqual(other, by: areEquivalent)
  }
}

extension UnsafeTreeV2 {

  @inlinable
  internal func lexicographicallyPrecedes<OtherSequence>(
    _ __first: _NodePtr, _ __last: _NodePtr, _ other: OtherSequence,
    by areInIncreasingOrder: (_PayloadValue, _PayloadValue) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence, _PayloadValue == OtherSequence.Element {
    try unsafeValues(__first, __last).lexicographicallyPrecedes(other, by: areInIncreasingOrder)
  }
}

extension UnsafeTreeV2 {

  @inlinable
  internal func
    ___copy_all_to_array() -> [_PayloadValue]
  {
    return .init(unsafeUninitializedCapacity: count) { buffer, initializedCount in
      initializedCount = count
      var buffer = buffer.baseAddress!
      var __first = __begin_node_
      let __last = __end_node
      while __first != __last {
        buffer.initialize(to: self[__first])
        buffer = buffer + 1
        __first = __tree_next_iter(__first)
      }
    }
  }

  @inlinable
  internal func
    ___rev_copy_all_to_array() -> [_PayloadValue]
  {
    return .init(unsafeUninitializedCapacity: count) { buffer, initializedCount in
      initializedCount = count
      var buffer = buffer.baseAddress!
      let __first = __begin_node_
      var __last = __end_node
      while __first != __last {
        __last = __tree_prev_iter(__last)
        buffer.initialize(to: self[__last])
        buffer = buffer + 1
      }
    }
  }

  @inlinable
  internal func
    ___copy_all_to_array<T>(transform: (_PayloadValue) -> T)
    -> [T]
  {
    return .init(unsafeUninitializedCapacity: count) { buffer, initializedCount in
      initializedCount = count
      var buffer = buffer.baseAddress!
      var __first = __begin_node_
      let __last = __end_node
      while __first != __last {
        buffer.initialize(to: transform(self[__first]))
        buffer = buffer + 1
        __first = __tree_next_iter(__first)
      }
    }
  }

  @inlinable
  internal func
    ___copy_to_array(_ __first: _NodePtr, _ __last: _NodePtr) -> [_PayloadValue]
  {
    var result: [_PayloadValue] = []
    var __first = __first
    while __first != __last {
      result.append(self[__first])
      __first = __tree_next_iter(__first)
    }
    return result
  }

  @inlinable
  internal func
    ___rev_copy_to_array(_ __first: _NodePtr, _ __last: _NodePtr) -> [_PayloadValue]
  {
    var result: [_PayloadValue] = []
    var __last = __last
    while __first != __last {
      __last = __tree_prev_iter(__last)
      result.append(self[__last])
    }
    return result
  }

  @inlinable
  internal func
    ___copy_to_array<T>(
      _ __first: _NodePtr, _ __last: _NodePtr, transform: (_PayloadValue) -> T
    ) -> [T]
  {
    var result: [T] = []
    var __first = __first
    while __first != __last {
      result.append(transform(self[__first]))
      __first = __tree_next_iter(__first)
    }
    return result
  }

  @inlinable
  internal func
    ___rev_copy_to_array<T>(
      _ __first: _NodePtr, _ __last: _NodePtr, transform: (_PayloadValue) -> T
    ) -> [T]
  {
    var result: [T] = []
    var __last = __last
    while __first != __last {
      __last = __tree_prev_iter(__last)
      result.append(transform(self[__last]))
    }
    return result
  }
}

extension UnsafeTreeV2: Equatable where _PayloadValue: Equatable {

  @inlinable
  @inline(__always)
  public static func == (lhs: UnsafeTreeV2<Base>, rhs: UnsafeTreeV2<Base>) -> Bool {

    if lhs.count != rhs.count {
      return false
    }

    if lhs.count == 0 || lhs.isTriviallyIdentical(to: rhs) {
      return true
    }

    return lhs.elementsEqual(
      lhs.__begin_node_,
      lhs.__end_node,
      rhs.unsafeValues(rhs.__begin_node_, rhs.__end_node),
      by: ==)
  }
}

extension UnsafeTreeV2: Comparable where _PayloadValue: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: UnsafeTreeV2<Base>, rhs: UnsafeTreeV2<Base>) -> Bool {
    !lhs.isTriviallyIdentical(to: rhs)
      && lhs.lexicographicallyPrecedes(
        lhs.__begin_node_,
        lhs.__end_node,
        rhs.unsafeValues(rhs.__begin_node_, rhs.__end_node),
        by: <)
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal func ___filter(
    _ __first: _NodePtr,
    _ __last: _NodePtr,
    _ isIncluded: (_PayloadValue) throws -> Bool
  )
    rethrows -> UnsafeTreeV2
  {
    var tree: Tree = ._createWithNewBuffer(minimumCapacity: 0, nullptr: nullptr)
    var (__parent, __child) = tree.___max_ref()
    for __p in unsafeSequence(__first, __last)
    where try isIncluded(__value_(__p)) {
      Tree.ensureCapacity(tree: &tree)
      (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __value_(__p))
      assert(tree.__tree_invariant(tree.__root))
    }
    return tree
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal func
    sequence(_ __first: _NodePtr, _ __last: _NodePtr) -> UnsafeIterator._RemoveAwarePointers
  {
    .init(_start: __first.sealed, _end: __last.sealed)
  }

  @inlinable
  @inline(__always)
  internal func
    unsafeSequence(_ __first: _NodePtr, _ __last: _NodePtr)
    -> UnsafeIterator._Obverse
  {
    .init(__first: __first, __last: __last)
  }

  @inlinable
  @inline(__always)
  internal func
    unsafeValues(_ __first: _NodePtr, _ __last: _NodePtr)
    -> UnsafeIterator._Payload<Base, UnsafeIterator._Obverse>
  {
    .init(Base.self, _start: __first, _end: __last)
  }
}
