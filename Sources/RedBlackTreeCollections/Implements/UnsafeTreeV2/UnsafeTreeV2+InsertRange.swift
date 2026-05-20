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
  internal mutating func ___insert_range_unique<Other>(
    other __source: UnsafeTreeV2<Other>,
    _ __first: _NodePtr,
    _ __last: _NodePtr
  )
  where
    UnsafeTreeV2<Other>._Key == _Key,
    UnsafeTreeV2<Other>._PayloadValue == _PayloadValue
  {
    if __first == __last {
      return
    }

    var __first = __first

    if __root == nullptr, __first != __last {
      // Make sure we always have a root node
      ensureCapacity()
      __insert_node_at(
        end, end.__left_ref,
        __construct_node(__source.__value_(__first)))
      __first = __source.__tree_next_iter(__first)
    }

    var __max_node = __tree_max(__root)

    while __first != __last {
      unsafeEnsureCapacity()
      let __nd = __construct_node(__source.__value_(__first))
      __first = __source.__tree_next_iter(__first)

      if value_comp(__get_value(__max_node), __get_value(__nd)) {  // __node > __max_node
        __insert_node_at(__max_node, __max_node.__right_ref, __nd)
        __max_node = __nd
      } else {
        let (__parent, __child) = __find_equal(__get_value(__nd))
        if __child.pointee == nullptr {
          __insert_node_at(__parent, __child, __nd)
        } else {
          destroy(__nd)
        }
      }
    }
  }
}

extension UnsafeTreeV2 where Base: PairValueTrait {

  @inlinable
  internal mutating func ___insert_range_unique<Other>(
    other __source: UnsafeTreeV2<Other>,
    _ __first: _NodePtr,
    _ __last: _NodePtr,
    uniquingKeysWith combine: (Base._MappedValue, Base._MappedValue) throws -> Base._MappedValue
  ) rethrows
  where
    UnsafeTreeV2<Other>._Key == _Key,
    UnsafeTreeV2<Other>._PayloadValue == _PayloadValue
  {
    if __first == __last {
      return
    }

    var __i = __first

    if __root == nullptr, __i != __last {  // Make sure we always have a root node
      ensureCapacity()
      __insert_node_at(
        end, end.__left_ref,
        __construct_node(__source.__value_(__i)))
      __i = __source.__tree_next_iter(__i)
    }

    var __max_node = __tree_max(__root)

    while __i != __last {
      unsafeEnsureCapacity()
      let __nd = __construct_node(__source.__value_(__i))
      __i = __source.__tree_next_iter(__i)

      if value_comp(__get_value(__max_node), __get_value(__nd)) {  // __node > __max_node
        __insert_node_at(__max_node, __max_node.__right_ref, __nd)
        __max_node = __nd
      } else {
        let (__parent, __child) = __find_equal(__get_value(__nd))
        if __child.pointee == nullptr {
          __insert_node_at(__parent, __child, __nd)
        } else {
          Base.__mapped_value_ptr(__child).pointee = try combine(
            Base.__mapped_value_(__child),
            Base.__mapped_value_(__nd))
          destroy(__nd)
        }
      }
    }
  }
}

extension UnsafeTreeV2 {

  @inlinable
  internal mutating func ___insert_range_multi<Other>(
    other __source: UnsafeTreeV2<Other>,
    _ __first: _NodePtr,
    _ __last: _NodePtr
  )
  where
    UnsafeTreeV2<Other>._Key == _Key,
    UnsafeTreeV2<Other>._PayloadValue == _PayloadValue
  {
    if __first == __last {
      return
    }

    ensureCapacity(to: __size_ + __source.__size_)

    var __first = __first

    if __root == nullptr, __first != __last {
      // Make sure we always have a root node
      __insert_node_at(
        end, end.__left_ref,
        __construct_node(__source.__value_(__first)))
      __first = __source.__tree_next_iter(__first)
    }

    var __max_node = __tree_max(__root)

    while __first != __last {
      let __nd = __construct_node(__source.__value_(__first))
      __first = __source.__tree_next_iter(__first)

      // Always check the max node first. This optimizes for sorted ranges inserted at the end.
      if !value_comp(__get_value(__nd), __get_value(__max_node)) {  // __node >= __max_val
        __insert_node_at(__max_node, __max_node.__right_ref, __nd)
        __max_node = __nd
      } else {
        var __parent: _NodePtr = nullptr
        let __child = __find_leaf_high(&__parent, __get_value(__nd))
        __insert_node_at(__parent, __child, __nd)
      }
    }
  }
}

extension UnsafeTreeV2 {

  @inlinable
  internal static func ___insert_range_unique<S>(tree __tree_: UnsafeTreeV2, _ __source: __owned S)
    -> UnsafeTreeV2
  where Base._PayloadValue == S.Element, S: Sequence {
    var __tree_ = __tree_
    __tree_.___insert_range_unique(__source)
    return __tree_
  }

  @inlinable
  internal mutating func ___insert_range_unique<S>(_ __source: __owned S)
  where Base._PayloadValue == S.Element, S: Sequence {

    var it = __source.makeIterator()

    if __root == nullptr, let __element = it.next() {  // Make sure we always have a root node
      ensureCapacity()
      __insert_node_at(
        end, end.__left_ref, __construct_node(__element)
      )
    }

    if __root == nullptr { return }

    var __max_node = __tree_max(__root)

    while let __element = it.next() {
      unsafeEnsureCapacity()
      let __nd = __construct_node(__element)
      if value_comp(__get_value(__max_node), __get_value(__nd)) {  // __node > __max_node
        __insert_node_at(__max_node, __max_node.__right_ref, __nd)
        __max_node = __nd
      } else {
        let (__parent, __child) = __find_equal(__get_value(__nd))
        if __child.pointee == nullptr {
          __insert_node_at(__parent, __child, __nd)
        } else {
          destroy(__nd)
        }
      }
    }
  }

  @inlinable
  internal static func ___insert_range_unique<S>(
    tree __tree_: UnsafeTreeV2,
    _ __source: __owned S,
    transform: (S.Element) -> Base._PayloadValue
  ) -> UnsafeTreeV2
  where S: Sequence {
    var __tree_ = __tree_

    var it = __source.makeIterator()

    if __tree_.__root == __tree_.nullptr, let __element = it.next() {  // Make sure we always have a root node
      __tree_.ensureCapacity()
      __tree_.__insert_node_at(
        __tree_.end, __tree_.end.__left_ref, __tree_.__construct_node(transform(__element))
      )
    }

    if __tree_.__root == __tree_.nullptr { return __tree_ }

    var __max_node = __tree_.__tree_max(__tree_.__root)

    while let __element = it.next() {
      __tree_.unsafeEnsureCapacity()
      let __nd = __tree_.__construct_node(transform(__element))
      if __tree_.value_comp(__tree_.__get_value(__max_node), __tree_.__get_value(__nd)) {  // __node > __max_node
        __tree_.__insert_node_at(__max_node, __max_node.__right_ref, __nd)
        __max_node = __nd
      } else {
        let (__parent, __child) = __tree_.__find_equal(__tree_.__get_value(__nd))
        if __child.pointee == __tree_.nullptr {
          __tree_.__insert_node_at(__parent, __child, __nd)
        } else {
          fatalError("Duplicate values for key: '\(__tree_.__get_value(__nd))'")
        }
      }
    }

    return __tree_
  }
}

extension UnsafeTreeV2 where Base: PairValueTrait {

  @inlinable
  internal static func ___insert_range_unique<S>(
    tree __tree_: UnsafeTreeV2,
    _ __source: S,
    uniquingKeysWith combine: (Base._MappedValue, Base._MappedValue) throws -> Base._MappedValue,
    transform __t_: (S.Element) -> Base._PayloadValue
  )
    rethrows -> UnsafeTreeV2
  where
    S: Sequence
  {
    var __tree_ = __tree_
    try __tree_.___insert_range_unique(__source, uniquingKeysWith: combine, transform: __t_)
    return __tree_
  }

  @inlinable
  internal mutating func ___insert_range_unique<S>(
    _ __source: S,
    uniquingKeysWith combine: (Base._MappedValue, Base._MappedValue) throws -> Base._MappedValue,
    transform __t_: (S.Element) -> Base._PayloadValue
  )
    rethrows
  where
    S: Sequence
  {
    var it = __source.makeIterator()

    if __root == nullptr, let __element = it.next().map(__t_) {  // Make sure we always have a root node
      ensureCapacity()
      __insert_node_at(
        end, end.__left_ref,
        __construct_node(__element))
    }

    if __root == nullptr { return }

    var __max_node = __tree_max(__root)

    while let __element = it.next().map(__t_) {
      unsafeEnsureCapacity()
      let __nd = __construct_node(__element)
      if value_comp(__get_value(__max_node), __get_value(__nd)) {  // __node > __max_node
        __insert_node_at(__max_node, __max_node.__right_ref, __nd)
        __max_node = __nd
      } else {
        let (__parent, __child) = __find_equal(__get_value(__nd))
        if __child.pointee == nullptr {
          __insert_node_at(__parent, __child, __nd)
        } else {
          Base.__mapped_value_ptr(__child).pointee = try combine(
            Base.__mapped_value_(__child),
            Base.__mapped_value_(__nd))
          destroy(__nd)
        }
      }
    }
  }

  @inlinable
  internal static func ___insert_range_unique<S>(
    tree __tree_: UnsafeTreeV2,
    grouping values: __owned S,
    by keyForValue: (S.Element) throws -> _Key
  )
    rethrows -> UnsafeTreeV2
  where
    S: Sequence, Base._MappedValue == [S.Element]
  {
    var __tree_ = __tree_
    try __tree_.___insert_range_unique(grouping: values, by: keyForValue)
    return __tree_
  }

  @inlinable
  internal mutating func ___insert_range_unique<S>(
    grouping values: __owned S,
    by keyForValue: (S.Element) throws -> _Key
  )
    rethrows
  where
    S: Sequence, Base._MappedValue == [S.Element]
  {
    var it = values.makeIterator()

    func __payload(_ e: S.Element) throws -> _PayloadValue {
      Base.__payload_((try keyForValue(e), [e]))
    }

    if __root == nullptr, let __element = it.next() {  // Make sure we always have a root node
      ensureCapacity()
      __insert_node_at(
        end, end.__left_ref,
        __construct_node(try __payload(__element)))
    }

    if __root == nullptr { return }

    var __max_node = __tree_max(__root)

    while let __element = it.next() {
      unsafeEnsureCapacity()
      let __nd = __construct_node(try __payload(__element))
      if value_comp(__get_value(__max_node), __get_value(__nd)) {  // __node > __max_node
        __insert_node_at(__max_node, __max_node.__right_ref, __nd)
        __max_node = __nd
      } else {
        let (__parent, __child) = __find_equal(__get_value(__nd))
        if __child.pointee == nullptr {
          __insert_node_at(__parent, __child, __nd)
        } else {
          Base.__mapped_value_ptr(__child).pointee.append(__element)
          destroy(__nd)
        }
      }
    }
  }
}

extension UnsafeTreeV2 {

  @inlinable
  internal static func
    ___insert_range_multi<S>(tree __tree_: UnsafeTreeV2, _ __source: __owned S) -> UnsafeTreeV2
  where Base._PayloadValue == S.Element, S: Sequence {
    var __tree_ = __tree_
    try __tree_.___insert_range_multi(__source) { $0 }
    return __tree_
  }

  @inlinable
  internal static func
    ___insert_range_multi<S>(
      tree __tree_: UnsafeTreeV2,
      _ __source: __owned S,
      transform: (S.Element) throws -> Base._PayloadValue
    ) rethrows
    -> UnsafeTreeV2
  where S: Sequence {
    var __tree_ = __tree_
    try __tree_.___insert_range_multi(__source, transform: transform)
    return __tree_
  }

  @inlinable
  internal mutating func
    ___insert_range_multi<S>(_ __source: __owned S)
  where Base._PayloadValue == S.Element, S: Sequence {
    try ___insert_range_multi(__source) { $0 }
  }

  @inlinable
  internal mutating func
    ___insert_range_multi<S>(
      _ __source: __owned S,
      transform: (S.Element) throws -> Base._PayloadValue
    ) rethrows
  where S: Sequence {

    var it = __source.makeIterator()

    if __root == nullptr, let __element = it.next() {  // Make sure we always have a root node
      ensureCapacity()
      __insert_node_at(
        end, end.__left_ref, __construct_node(try transform(__element))
      )
    }

    if __root == nullptr { return }

    var __max_node = __tree_max(__root)

    while let __element = it.next() {
      unsafeEnsureCapacity()
      let __nd = __construct_node(try transform(__element))
      // Always check the max node first. This optimizes for sorted ranges inserted at the end.
      if !value_comp(__get_value(__nd), __get_value(__max_node)) {  // __node >= __max_val
        __insert_node_at(__max_node, __max_node.__right_ref, __nd)
        __max_node = __nd
      } else {
        var __parent: _NodePtr = nullptr
        let __child = __find_leaf_high(&__parent, __get_value(__nd))
        __insert_node_at(__parent, __child, __nd)
      }
    }
  }
}
