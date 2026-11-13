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

extension UnsafeTreeV2 {

  @inlinable
  mutating func ___copy_range(
    _ f: UnsafeMutablePointer<UnsafeNode>,
    _ l: UnsafeMutablePointer<UnsafeNode>,
    to __parent: UnsafeMutablePointer<UnsafeNode>,
    _ __child: UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>
  ) {
    var f = f
    var (__parent, __child) = (__parent, __child)
    while f != l {
      unsafeEnsureCapacity()
      (__parent, __child) = ___emplace_hint_right(__parent, __child, Base.__payload_(f))
      f = __tree_next_iter(f)
    }
  }

  @inlinable
  func ___meld_unique(_ other: UnsafeTreeV2) -> UnsafeTreeV2 {

    var __result_: UnsafeTreeV2 = ._createWithNewBuffer(minimumCapacity: 2, nullptr: nullptr)

    var (__parent, __child) = __result_.___max_ref()
    var (__first1, __last1) = (__begin_node_, __end_node)
    var (__first2, __last2) = (other.__begin_node_, other.__end_node)

    while __first1 != __last1 {
      if __first2 == __last2 {
        __result_.___copy_range(__first1, __last1, to: __parent, __child)
        return __result_
      }

      if value_comp(other.__get_value(__first2), __get_value(__first1)) {

        __result_.unsafeEnsureCapacity()
        (__parent, __child) = __result_.___emplace_hint_right(
          __parent, __child, Base.__payload_(__first2))
        __first2 = other.__tree_next_iter(__first2)
      } else {
        if !value_comp(__get_value(__first1), other.__get_value(__first2)) {
          __first2 = other.__tree_next_iter(__first2)
        }

        __result_.unsafeEnsureCapacity()
        (__parent, __child) = __result_.___emplace_hint_right(
          __parent, __child, Base.__payload_(__first1))
        __first1 = __tree_next_iter(__first1)
      }
    }

    __result_.___copy_range(__first2, __last2, to: __parent, __child)
    return __result_
  }

  @inlinable
  func ___meld_multi(_ other: UnsafeTreeV2) -> UnsafeTreeV2 {

    var __result_: UnsafeTreeV2 = ._createWithNewBuffer(
      minimumCapacity: count + other.count, nullptr: nullptr)

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

        __result_.unsafeEnsureCapacity()
        (__parent, __child) = __result_.___emplace_hint_right(
          __parent, __child, Base.__payload_(__first1))
        __first1 = __tree_next_iter(__first1)
      } else if value_comp(
        other.__get_value(__first2),
        self.__get_value(__first1))
      {

        __result_.unsafeEnsureCapacity()
        (__parent, __child) = __result_.___emplace_hint_right(
          __parent, __child, Base.__payload_(__first2))
        __first2 = other.__tree_next_iter(__first2)
      } else {
        __result_.unsafeEnsureCapacity()
        (__parent, __child) = __result_.___emplace_hint_right(
          __parent, __child, Base.__payload_(__first1))
        __first1 = __tree_next_iter(__first1)

        __result_.unsafeEnsureCapacity()
        (__parent, __child) = __result_.___emplace_hint_right(
          __parent, __child, Base.__payload_(__first2))
        __first2 = other.__tree_next_iter(__first2)
      }
    }

    __result_.___copy_range(__first2, __last2, to: __parent, __child)
    return __result_
  }

  @inlinable
  func ___intersection(_ other: UnsafeTreeV2) -> UnsafeTreeV2 {
    // lower_boundを使う方法があるが、一旦楽に実装できそうな方からにしている
    var __result_: UnsafeTreeV2 = ._createWithNewBuffer(minimumCapacity: 2, nullptr: nullptr)
    var (__parent, __child) = __result_.___max_ref()
    var (__first1, __last1) = (__begin_node_, __end_node)
    var (__first2, __last2) = (other.__begin_node_, other.__end_node)
    while __first1 != __last1, __first2 != __last2 {
      if value_comp(__get_value(__first1), other.__get_value(__first2)) {
        __first1 = __tree_next_iter(__first1)
      } else {
        if !value_comp(other.__get_value(__first2), __get_value(__first1)) {
          __result_.unsafeEnsureCapacity()
          (__parent, __child) = __result_.___emplace_hint_right(
            __parent, __child, Base.__payload_(__first1))
          __first1 = __tree_next_iter(__first1)
        }
        __first2 = other.__tree_next_iter(__first2)
      }
    }
    return __result_
  }

  #if false
  // AIによる移植コード。せっかくなので資料的に残す。
  // 暇が出来たらチューニングして活かせるか再度検討してもいい。
  
  /// libc++のforward iterator版`__set_intersection`と同じ手順の積集合（試作）。
  ///
  /// 片側の二分探索で読み飛ばすので、比較回数は`___intersection`より少なくなりうる。
  /// 木のイテレータは1歩ずつしか進めないため、ノードをたどる回数は減らない。
  /// 残す個体と順序は`___intersection`と同じ。
  @inlinable
  func __algorithm__set_intersection(_ other: UnsafeTreeV2) -> UnsafeTreeV2 {
    var __result_: UnsafeTreeV2 = ._createWithNewBuffer(minimumCapacity: 2, nullptr: nullptr)
    var (__parent, __child) = __result_.___max_ref()
    var (__first1, __last1) = (__begin_node_, __end_node)
    var (__first2, __last2) = (other.__begin_node_, other.__end_node)
    var __prev_may_be_equal = false

    while __first2 != __last2 {
      let __first1_next = ___lower_bound_onesided(
        __first1, __last1, other.__get_value(__first2))
      let __may_be_equal1 = __first1 == __first1_next
      __first1 = __first1_next
      __set_intersection_add_output_if_equal(
        __may_be_equal1, &__first1, &__first2, other,
        &__result_, &__parent, &__child, &__prev_may_be_equal)
      if __first1 == __last1 {
        break
      }

      let __first2_next = other.___lower_bound_onesided(
        __first2, __last2, __get_value(__first1))
      let __may_be_equal2 = __first2 == __first2_next
      __first2 = __first2_next
      __set_intersection_add_output_if_equal(
        __may_be_equal2, &__first1, &__first2, other,
        &__result_, &__parent, &__child, &__prev_may_be_equal)
    }
    return __result_
  }

  /// libc++の`__set_intersection_add_output_if_equal`と同じ手順。
  ///
  /// 2回続けて「進められなかった」（同値の可能性がある）なら、`__first1`の要素を結果へ加え、
  /// 両方を1つ進める。そうでなければ、今回の判定を次回のために残す。
  /// 出力イテレータの代わりに、結果の木と挿入位置（`__result_`、`__parent`、`__child`）を受け取る
  @inlinable
  func __set_intersection_add_output_if_equal(
    _ __may_be_equal: Bool,
    _ __first1: inout UnsafeMutablePointer<UnsafeNode>,
    _ __first2: inout UnsafeMutablePointer<UnsafeNode>,
    _ other: UnsafeTreeV2,
    _ __result_: inout UnsafeTreeV2,
    _ __parent: inout UnsafeMutablePointer<UnsafeNode>,
    _ __child: inout UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>,
    _ __prev_may_be_equal: inout Bool
  ) {
    if __may_be_equal && __prev_may_be_equal {
      __result_.unsafeEnsureCapacity()
      (__parent, __child) = __result_.___emplace_hint_right(
        __parent, __child, Base.__payload_(__first1))
      __first1 = __tree_next_iter(__first1)
      __first2 = other.__tree_next_iter(__first2)
      __prev_may_be_equal = false
    } else {
      __prev_may_be_equal = __may_be_equal
    }
  }

  /// libc++の`__lower_bound_onesided`と同じ手順で、[`__first`, `__last`)から
  /// `__value`以上の最初の位置を探す。歩幅を倍にしながら先を見て、行き過ぎたら二分探索で戻る
  @inlinable
  func ___lower_bound_onesided(
    _ __first: UnsafeMutablePointer<UnsafeNode>,
    _ __last: UnsafeMutablePointer<UnsafeNode>,
    _ __value: _Key
  ) -> UnsafeMutablePointer<UnsafeNode> {
    var __first = __first
    if __first == __last || !value_comp(__get_value(__first), __value) {
      return __first
    }
    var __step = 1
    while __first != __last {
      var __it = __first
      var __dist = 0
      while __dist < __step, __it != __last {
        __it = __tree_next_iter(__it)
        __dist += 1
      }
      if __it == __last || !value_comp(__get_value(__it), __value) {
        if __dist == 1 {
          return __it
        }
        return ___lower_bound_bisecting(__first, __value, __dist)
      }
      __first = __it
      __step <<= 1
    }
    return __first
  }

  /// libc++の`__lower_bound_bisecting`と同じ手順で、`__first`から`__len`個の範囲を二分探索する
  @inlinable
  func ___lower_bound_bisecting(
    _ __first: UnsafeMutablePointer<UnsafeNode>,
    _ __value: _Key,
    _ __len: Int
  ) -> UnsafeMutablePointer<UnsafeNode> {
    var (__first, __len) = (__first, __len)
    while __len != 0 {
      let __l2 = __len / 2
      var __m = __first
      for _ in 0..<__l2 {
        __m = __tree_next_iter(__m)
      }
      if value_comp(__get_value(__m), __value) {
        __first = __tree_next_iter(__m)
        __len -= __l2 + 1
      } else {
        __len = __l2
      }
    }
    return __first
  }
  #endif

  /// - Complexity: O(*n* + *m*)
  @inlinable
  func ___symmetric_difference(_ other: UnsafeTreeV2) -> UnsafeTreeV2 {
    var __result_: UnsafeTreeV2 = ._createWithNewBuffer(minimumCapacity: 2, nullptr: nullptr)
    var (__parent, __child) = __result_.___max_ref()
    var (__first1, __last1) = (__begin_node_, __end_node)
    var (__first2, __last2) = (other.__begin_node_, other.__end_node)
    while __first1 != __last1 {
      if __first2 == __last2 {
        __result_.___copy_range(__first1, __last1, to: __parent, __child)
        return __result_
      }
      if value_comp(__get_value(__first1), other.__get_value(__first2)) {
        __result_.unsafeEnsureCapacity()
        (__parent, __child) = __result_.___emplace_hint_right(
          __parent, __child, Base.__payload_(__first1))
        __first1 = __tree_next_iter(__first1)
      } else {
        if value_comp(other.__get_value(__first2), __get_value(__first1)) {
          __result_.unsafeEnsureCapacity()
          (__parent, __child) = __result_.___emplace_hint_right(
            __parent, __child, Base.__payload_(__first2))
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
  @inlinable
  func ___difference(_ other: UnsafeTreeV2) -> UnsafeTreeV2 {
    var __result_: UnsafeTreeV2 = ._createWithNewBuffer(minimumCapacity: 2, nullptr: nullptr)
    var (__parent, __child) = __result_.___max_ref()
    var (__first1, __last1) = (__begin_node_, __end_node)
    var (__first2, __last2) = (other.__begin_node_, other.__end_node)
    while __first1 != __last1, __first2 != __last2 {
      if value_comp(__get_value(__first1), other.__get_value(__first2)) {
        __result_.unsafeEnsureCapacity()
        (__parent, __child) = __result_.___emplace_hint_right(
          __parent, __child, Base.__payload_(__first1))
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
