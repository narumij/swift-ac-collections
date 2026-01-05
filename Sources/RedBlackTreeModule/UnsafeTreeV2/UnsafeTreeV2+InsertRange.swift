// Copyright 2024-2026 narumij
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2025 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal static func ___insert_range_unique<Other>(
    tree __tree_: UnsafeTreeV2,
    other __source: UnsafeTreeV2<Other>,
    _ __first: _NodePtr,
    _ __last: _NodePtr
  ) -> UnsafeTreeV2
  where
    UnsafeTree<Other>._Key == _Key,
    UnsafeTree<Other>._Value == _Value
  {
    if __first == __last {
      return __tree_
    }

    var __tree_ = __tree_

    var __first = __first

    if __tree_.__root == __tree_.nullptr, __first != __last {
      // Make sure we always have a root node
      Tree.ensureCapacity(tree: &__tree_)
      __tree_.__insert_node_at(
        __tree_.end, __tree_.__left_ref(__tree_.end),
        __tree_.__construct_node(__source.__value_(__first)))
      __first = __source.__tree_next_iter(__first)
    }

    var __max_node = __tree_.__tree_max(__tree_.__root)

    while __first != __last {
      Tree.ensureCapacity(tree: &__tree_)
      let __nd = __tree_.__construct_node(__source.__value_(__first))
      __first = __source.__tree_next_iter(__first)

      if __tree_.value_comp(__tree_.__get_value(__max_node), __tree_.__get_value(__nd)) {  // __node > __max_node
        __tree_.__insert_node_at(__max_node, __tree_.__right_ref(__max_node), __nd)
        __max_node = __nd
      } else {
        let (__parent, __child) = __tree_.__find_equal(__tree_.__get_value(__nd))
        if __tree_.__ptr_(__child) == __tree_.nullptr {
          __tree_.__insert_node_at(__parent, __child, __nd)
        } else {
          __tree_.destroy(__nd)
        }
      }
    }

    return __tree_
  }
}

extension UnsafeTreeV2 where Base: KeyValueComparer {

  @inlinable
  @inline(__always)
  internal static func ___insert_range_unique<Other>(
    tree __tree_: UnsafeTreeV2,
    other __source: UnsafeTreeV2<Other>,
    _ __first: _NodePtr,
    _ __last: _NodePtr,
    uniquingKeysWith combine: (Base._MappedValue, Base._MappedValue) throws -> Base._MappedValue
  ) rethrows -> UnsafeTreeV2
  where
    UnsafeTree<Other>._Key == _Key,
    UnsafeTree<Other>._Value == _Value
  {
    if __first == __last {
      return __tree_
    }

    var __tree_ = __tree_

    var __i = __first

    if __tree_.__root == __tree_.nullptr, __i != __last {  // Make sure we always have a root node
      Tree.ensureCapacity(tree: &__tree_)
      __tree_.__insert_node_at(
        __tree_.end, __tree_.__left_ref(__tree_.end),
        __tree_.__construct_node(__source.__value_(__i)))
      __i = __source.__tree_next_iter(__i)
    }

    var __max_node = __tree_.__tree_max(__tree_.__root)

    while __i != __last {
      Tree.ensureCapacity(tree: &__tree_)
      let __nd = __tree_.__construct_node(__source.__value_(__i))
      __i = __source.__tree_next_iter(__i)

      if __tree_.value_comp(__tree_.__get_value(__max_node), __tree_.__get_value(__nd)) {  // __node > __max_node
        __tree_.__insert_node_at(__max_node, __tree_.__right_ref(__max_node), __nd)
        __max_node = __nd
      } else {
        let (__parent, __child) = __tree_.__find_equal(__tree_.__get_value(__nd))
        if __tree_.__ptr_(__child) == __tree_.nullptr {
          __tree_.__insert_node_at(__parent, __child, __nd)
        } else {
          try __tree_.___with_mapped_value(__tree_.__ptr_(__child)) { __mappedValue in
            __mappedValue = try combine(__mappedValue, Base.___mapped_value(__tree_.__value_(__nd)))
          }
          __tree_.destroy(__nd)
        }
      }
    }

    return __tree_
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal static func ___insert_range_multi<Other>(
    tree __tree_: UnsafeTreeV2,
    other __source: UnsafeTreeV2<Other>,
    _ __first: _NodePtr,
    _ __last: _NodePtr
  ) -> UnsafeTreeV2
  where
    UnsafeTree<Other>._Key == _Key,
    UnsafeTree<Other>._Value == _Value
  {
    if __first == __last {
      return __tree_
    }

    var __tree_ = __tree_

    Tree.ensureCapacity(tree: &__tree_, minimumCapacity: __tree_.__size_ + __source.__size_)

    var __first = __first

    if __tree_.__root == __tree_.nullptr, __first != __last {
      // Make sure we always have a root node
      __tree_.__insert_node_at(
        __tree_.end, __tree_.__left_ref(__tree_.end), __tree_.__construct_node(__source.__value_(__first)))
      __first = __source.__tree_next_iter(__first)
    }

    var __max_node = __tree_.__tree_max(__tree_.__root)

    while __first != __last {
      let __nd = __tree_.__construct_node(__source.__value_(__first))
      __first = __source.__tree_next_iter(__first)

      // Always check the max node first. This optimizes for sorted ranges inserted at the end.
      if !__tree_.value_comp(__tree_.__get_value(__nd), __tree_.__get_value(__max_node)) {  // __node >= __max_val
        __tree_.__insert_node_at(__max_node, __tree_.__right_ref(__max_node), __nd)
        __max_node = __nd
      } else {
        var __parent: _NodePtr = __tree_.nullptr
        let __child = __tree_.__find_leaf_high(&__parent, __tree_.__get_value(__nd))
        __tree_.__insert_node_at(__parent, __child, __nd)
      }
    }

    return __tree_
  }
}

extension UnsafeTreeV2 {

  @inlinable
  internal static func ___insert_range_unique<S>(tree __tree_: UnsafeTreeV2, _ __source: __owned S)
    -> UnsafeTreeV2
  where Base._Value == S.Element, S: Sequence {
    return ___insert_range_unique(tree: __tree_, __source) { $0 }
  }

  @inlinable
  internal static func ___insert_range_unique<S>(
    tree __tree_: UnsafeTreeV2,
    _ __source: __owned S,
    transform: (S.Element) -> Base._Value
  ) -> UnsafeTreeV2
  where S: Sequence {
    var __tree_ = __tree_

    var it = __source.makeIterator()

    if __tree_.__root == __tree_.nullptr, let __element = it.next() {  // Make sure we always have a root node
      Tree.ensureCapacity(tree: &__tree_)
      __tree_.__insert_node_at(
        __tree_.end, __tree_.__left_ref(__tree_.end), __tree_.__construct_node(transform(__element)))
    }

    if __tree_.__root == __tree_.nullptr { return __tree_ }

    var __max_node = __tree_.__tree_max(__tree_.__root)

    while let __element = it.next() {
      Tree.ensureCapacity(tree: &__tree_)
      let __nd = __tree_.__construct_node(transform(__element))
      if __tree_.value_comp(__tree_.__get_value(__max_node), __tree_.__get_value(__nd)) {  // __node > __max_node
        __tree_.__insert_node_at(__max_node, __tree_.__right_ref(__max_node), __nd)
        __max_node = __nd
      } else {
        let (__parent, __child) = __tree_.__find_equal(__tree_.__get_value(__nd))
        if __tree_.__ptr_(__child) == __tree_.nullptr {
          __tree_.__insert_node_at(__parent, __child, __nd)
        } else {
          __tree_.destroy(__nd)
        }
      }
    }

    return __tree_
  }
}

extension UnsafeTreeV2 where Base: KeyValueComparer {

  @inlinable
  @inline(__always)
  internal static func ___insert_range_unique<S>(
    tree __tree_: UnsafeTreeV2,
    _ __source: S,
    uniquingKeysWith combine: (Base._MappedValue, Base._MappedValue) throws -> Base._MappedValue,
    transform __t_: (S.Element) -> Base._Value
  )
    rethrows -> UnsafeTreeV2
  where
    S: Sequence
  {
    var __tree_ = __tree_

    var it = __source.makeIterator()

    if __tree_.__root == __tree_.nullptr, let __element = it.next().map(__t_) {  // Make sure we always have a root node
      Tree.ensureCapacity(tree: &__tree_)
      __tree_.__insert_node_at(
        __tree_.end, __tree_.__left_ref(__tree_.end), __tree_.__construct_node(__element))
    }

    if __tree_.__root == __tree_.nullptr { return __tree_ }

    var __max_node = __tree_.__tree_max(__tree_.__root)

    while let __element = it.next().map(__t_) {
      Tree.ensureCapacity(tree: &__tree_)
      let __nd = __tree_.__construct_node(__element)
      if __tree_.value_comp(__tree_.__get_value(__max_node), __tree_.__get_value(__nd)) {  // __node > __max_node
        __tree_.__insert_node_at(__max_node, __tree_.__right_ref(__max_node), __nd)
        __max_node = __nd
      } else {
        let (__parent, __child) = __tree_.__find_equal(__tree_.__get_value(__nd))
        if __tree_.__ptr_(__child) == __tree_.nullptr {
          __tree_.__insert_node_at(__parent, __child, __nd)
        } else {
          try __tree_.___with_mapped_value(__tree_.__ptr_(__child)) { __mappedValue in
            __mappedValue = try combine(__mappedValue, Base.___mapped_value(__tree_.__value_(__nd)))
          }
          __tree_.destroy(__nd)
        }
      }
    }

    return __tree_
  }
}

extension UnsafeTreeV2 {

  @inlinable
  internal static func
    ___insert_range_multi<S>(tree __tree_: UnsafeTreeV2, _ __source: __owned S) -> UnsafeTreeV2
  where Base._Value == S.Element, S: Sequence {
    ___insert_range_multi(tree: __tree_, __source) { $0 }
  }

  @inlinable
  internal static func
    ___insert_range_multi<S>(
      tree __tree_: UnsafeTreeV2,
      _ __source: __owned S,
      transform: (S.Element) -> Base._Value
    )
    -> UnsafeTreeV2
  where S: Sequence {
    var __tree_ = __tree_

    var it = __source.makeIterator()

    if __tree_.__root == __tree_.nullptr, let __element = it.next() {  // Make sure we always have a root node
      Tree.ensureCapacity(tree: &__tree_)
      __tree_.__insert_node_at(
        __tree_.end, __tree_.__left_ref(__tree_.end), __tree_.__construct_node(transform(__element)))
    }

    if __tree_.__root == __tree_.nullptr { return __tree_ }

    var __max_node = __tree_.__tree_max(__tree_.__root)

    while let __element = it.next() {
      Tree.ensureCapacity(tree: &__tree_)
      let __nd = __tree_.__construct_node(transform(__element))
      // Always check the max node first. This optimizes for sorted ranges inserted at the end.
      if !__tree_.value_comp(__tree_.__get_value(__nd), __tree_.__get_value(__max_node)) {  // __node >= __max_val
        __tree_.__insert_node_at(__max_node, __tree_.__right_ref(__max_node), __nd)
        __max_node = __nd
      } else {
        var __parent: _NodePtr = __tree_.nullptr
        let __child = __tree_.__find_leaf_high(&__parent, __tree_.__get_value(__nd))
        __tree_.__insert_node_at(__parent, __child, __nd)
      }
    }

    return __tree_
  }
}
