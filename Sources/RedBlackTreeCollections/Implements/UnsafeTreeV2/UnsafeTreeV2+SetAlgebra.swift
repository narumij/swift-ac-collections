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

  mutating func ___copy_range(
    _ f: UnsafeMutablePointer<UnsafeNode>,
    _ l: UnsafeMutablePointer<UnsafeNode>,
    to __parent: UnsafeMutablePointer<UnsafeNode>,
    _ __child: UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>
  ) {
    var f = f
    var (__parent, __child) = (__parent, __child)
    while f != l {
      ensureCapacity()
      (__parent, __child) = ___emplace_hint_right(__parent, __child, Base.__payload_(f))
      f = __tree_next_iter(f)
    }
  }

  @usableFromInline
  func ___meld_unique(_ other: UnsafeTreeV2) -> UnsafeTreeV2 {

    var __result_: UnsafeTreeV2 = ._createWithNewBuffer(minimumCapacity: 0, nullptr: nullptr)

    var (__parent, __child) = __result_.___max_ref()
    var (__first1, __last1) = (__begin_node_, __end_node)
    var (__first2, __last2) = (other.__begin_node_, other.__end_node)

    while __first1 != __last1 {
      if __first2 == __last2 {
        __result_.___copy_range(__first1, __last1, to: __parent, __child)
        return __result_
      }

      if value_comp(other.__get_value(__first2), __get_value(__first1)) {

        __result_.ensureCapacity()
        (__parent, __child) = __result_.___emplace_hint_right(
          __parent, __child, other[_unsafe_raw: __first2])
        __first2 = other.__tree_next_iter(__first2)
      } else {
        if !value_comp(__get_value(__first1), other.__get_value(__first2)) {
          __first2 = other.__tree_next_iter(__first2)
        }

        __result_.ensureCapacity()
        (__parent, __child) = __result_.___emplace_hint_right(
          __parent, __child, self[_unsafe_raw: __first1])
        __first1 = __tree_next_iter(__first1)
      }
    }

    __result_.___copy_range(__first2, __last2, to: __parent, __child)
    return __result_
  }

  @usableFromInline
  func ___meld_multi(_ other: UnsafeTreeV2) -> UnsafeTreeV2 {

    var __result_: UnsafeTreeV2 = ._createWithNewBuffer(minimumCapacity: 0, nullptr: nullptr)

    var (__parent, __child) = __result_.___max_ref()
    var (__first1, __last1) = (__begin_node_, __end_node)
    var (__first2, __last2) = (other.__begin_node_, other.__end_node)

    while __first1 != __last1 {

      if __first2 == __last2 {
        __result_.___copy_range(__first1, __last1, to: __parent, __child)
        return __result_
      }

      if value_comp(
        self.__get_value(__first1),
        other.__get_value(__first2))
      {

        __result_.ensureCapacity()
        (__parent, __child) = __result_.___emplace_hint_right(
          __parent, __child, self[_unsafe_raw: __first1])
        __first1 = __tree_next_iter(__first1)
      } else if value_comp(
        other.__get_value(__first2),
        self.__get_value(__first1))
      {

        __result_.ensureCapacity()
        (__parent, __child) = __result_.___emplace_hint_right(
          __parent, __child, other[_unsafe_raw: __first2])
        __first2 = other.__tree_next_iter(__first2)
      } else {
        __result_.ensureCapacity()
        (__parent, __child) = __result_.___emplace_hint_right(
          __parent, __child, self[_unsafe_raw: __first1])
        __first1 = __tree_next_iter(__first1)

        __result_.ensureCapacity()
        (__parent, __child) = __result_.___emplace_hint_right(
          __parent, __child, other[_unsafe_raw: __first2])
        __first2 = other.__tree_next_iter(__first2)
      }
    }

    __result_.___copy_range(__first2, __last2, to: __parent, __child)
    return __result_
  }

  @usableFromInline
  func ___intersection(_ other: UnsafeTreeV2) -> UnsafeTreeV2 {
    // lower_boundを使う方法があるが、一旦楽に実装できそうな方からにしている
    var __result_: UnsafeTreeV2 = ._createWithNewBuffer(minimumCapacity: 0, nullptr: nullptr)
    var (__parent, __child) = __result_.___max_ref()
    var (__first1, __last1) = (__begin_node_, __end_node)
    var (__first2, __last2) = (other.__begin_node_, other.__end_node)
    while __first1 != __last1, __first2 != __last2 {
      if value_comp(__get_value(__first1), other.__get_value(__first2)) {
        __first1 = __tree_next_iter(__first1)
      } else {
        if !value_comp(other.__get_value(__first2), __get_value(__first1)) {
          __result_.ensureCapacity()
          (__parent, __child) = __result_.___emplace_hint_right(
            __parent, __child, self[_unsafe_raw: __first1])
          __first1 = __tree_next_iter(__first1)
        }
        __first2 = other.__tree_next_iter(__first2)
      }
    }
    return __result_
  }

  /// - Complexity: O(*n* + *m*)
  @usableFromInline
  func ___symmetric_difference(_ other: UnsafeTreeV2) -> UnsafeTreeV2 {
    var __result_: UnsafeTreeV2 = ._createWithNewBuffer(minimumCapacity: 0, nullptr: nullptr)
    var (__parent, __child) = __result_.___max_ref()
    var (__first1, __last1) = (__begin_node_, __end_node)
    var (__first2, __last2) = (other.__begin_node_, other.__end_node)
    while __first1 != __last1 {
      if __first2 == __last2 {
        __result_.___copy_range(__first1, __last1, to: __parent, __child)
        return __result_
      }
      if value_comp(__get_value(__first1), other.__get_value(__first2)) {
        __result_.ensureCapacity()
        (__parent, __child) = __result_.___emplace_hint_right(
          __parent, __child, self[_unsafe_raw: __first1])
        __first1 = __tree_next_iter(__first1)
      } else {
        if value_comp(other.__get_value(__first2), __get_value(__first1)) {
          __result_.ensureCapacity()
          (__parent, __child) = __result_.___emplace_hint_right(
            __parent, __child, other[_unsafe_raw: __first2])
        } else {
          __first1 = __tree_next_iter(__first1)
        }
        __first2 = other.__tree_next_iter(__first2)
      }
    }
    __result_.___copy_range(__first2, __last2, to: __parent, __child)
    return __result_
  }

  /// - Complexity: O(*n* + *m*)
  @usableFromInline
  func ___difference(_ other: UnsafeTreeV2) -> UnsafeTreeV2 {
    var __result_: UnsafeTreeV2 = ._createWithNewBuffer(minimumCapacity: 0, nullptr: nullptr)
    var (__parent, __child) = __result_.___max_ref()
    var (__first1, __last1) = (__begin_node_, __end_node)
    var (__first2, __last2) = (other.__begin_node_, other.__end_node)
    while __first1 != __last1, __first2 != __last2 {
      if value_comp(__get_value(__first1), other.__get_value(__first2)) {
        __result_.ensureCapacity()
        (__parent, __child) = __result_.___emplace_hint_right(
          __parent, __child, self[_unsafe_raw: __first1])
        __first1 = __tree_next_iter(__first1)
      } else if value_comp(other.__get_value(__first2), __get_value(__first1)) {
        __first2 = other.__tree_next_iter(__first2)
      } else {
        __first1 = __tree_next_iter(__first1)
        __first2 = other.__tree_next_iter(__first2)
      }
    }
    __result_.___copy_range(__first1, __last1, to: __parent, __child)
    return __result_
  }
}
