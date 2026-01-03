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

extension UnsafeTree {

  @inlinable
  @inline(__always)
  internal func ___copy_range(_ f: inout _NodePtr, _ l: _NodePtr, to r: inout Tree) {
    var (__parent, __child) = r.___max_ref()
    while f != l {
      Tree.ensureCapacity(tree: &r)
      (__parent, __child) = r.___emplace_hint_right(__parent, __child, self[f])
      f = __tree_next_iter(f)
    }
  }

  @inlinable
  @inline(__always)
  internal func ___meld_unique(_ other: UnsafeTree) -> UnsafeTree {

    var __result_: UnsafeTree = .create(minimumCapacity: 0)

    var (__parent, __child) = __result_.___max_ref()
    var (__first1, __last1) = (__begin_node_, __end_node)
    var (__first2, __last2) = (other.__begin_node_, other.__end_node)

    while __first1 != __last1 {
      if __first2 == __last2 {
        ___copy_range(&__first1, __last1, to: &__result_)
        return __result_
      }

      if value_comp(
        other.__get_value(__first2),
        self.__get_value(__first1))
      {

        Tree.ensureCapacity(tree: &__result_)
        (__parent, __child) = __result_.___emplace_hint_right(__parent, __child, other[__first2])
        __first2 = other.__tree_next_iter(__first2)
      } else {
        if !value_comp(
          self.__get_value(__first1),
          other.__get_value(__first2))
        {
          __first2 = other.__tree_next_iter(__first2)
        }

        Tree.ensureCapacity(tree: &__result_)
        (__parent, __child) = __result_.___emplace_hint_right(__parent, __child, self[__first1])
        __first1 = __tree_next_iter(__first1)
      }
    }

    other.___copy_range(&__first2, __last2, to: &__result_)
    return __result_
  }

  @inlinable
  @inline(__always)
  internal func ___meld_multi(_ other: UnsafeTree) -> UnsafeTree {

    var __result_: UnsafeTree = .create(minimumCapacity: 0)

    var (__parent, __child) = __result_.___max_ref()
    var (__first1, __last1) = (__begin_node_, __end_node)
    var (__first2, __last2) = (other.__begin_node_, other.__end_node)

    while __first1 != __last1 {

      if __first2 == __last2 {
        ___copy_range(&__first1, __last1, to: &__result_)
        return __result_
      }

      if value_comp(
        self.__get_value(__first1),
        other.__get_value(__first2))
      {

        Tree.ensureCapacity(tree: &__result_)
        (__parent, __child) = __result_.___emplace_hint_right(__parent, __child, self[__first1])
        __first1 = __tree_next_iter(__first1)
      } else if value_comp(
        other.__get_value(__first2),
        self.__get_value(__first1))
      {

        Tree.ensureCapacity(tree: &__result_)
        (__parent, __child) = __result_.___emplace_hint_right(__parent, __child, other[__first2])
        __first2 = other.__tree_next_iter(__first2)
      } else {
        Tree.ensureCapacity(tree: &__result_)
        (__parent, __child) = __result_.___emplace_hint_right(__parent, __child, self[__first1])
        __first1 = __tree_next_iter(__first1)

        Tree.ensureCapacity(tree: &__result_)
        (__parent, __child) = __result_.___emplace_hint_right(__parent, __child, other[__first2])
        __first2 = other.__tree_next_iter(__first2)
      }
    }

    other.___copy_range(&__first2, __last2, to: &__result_)
    return __result_
  }

  @inlinable
  @inline(__always)
  internal func ___intersection(_ other: UnsafeTree) -> UnsafeTree {
    // lower_boundを使う方法があるが、一旦楽に実装できそうな方からにしている
    var __result_: UnsafeTree = .create(minimumCapacity: 0)
    var (__parent, __child) = __result_.___max_ref()
    var (__first1, __last1) = (__begin_node_, __end_node)
    var (__first2, __last2) = (other.__begin_node_, other.__end_node)
    while __first1 != __last1, __first2 != __last2 {
      if value_comp(self.__get_value(__first1), other.__get_value(__first2)) {
        __first1 = __tree_next_iter(__first1)
      } else {
        if !value_comp(other.__get_value(__first2), self.__get_value(__first1)) {
          Tree.ensureCapacity(tree: &__result_)
          (__parent, __child) = __result_.___emplace_hint_right(__parent, __child, self[__first1])
          __first1 = __tree_next_iter(__first1)
        }
        __first2 = other.__tree_next_iter(__first2)
      }
    }
    return __result_
  }

  /// - Complexity: O(*n* + *m*)
  @inlinable
  @inline(__always)
  internal func ___symmetric_difference(_ other: UnsafeTree) -> UnsafeTree {
    var __result_: UnsafeTree = .create(minimumCapacity: 0)
    var (__parent, __child) = __result_.___max_ref()
    var (__first1, __last1) = (__begin_node_, __end_node)
    var (__first2, __last2) = (other.__begin_node_, other.__end_node)
    while __first1 != __last1 {
      if __first2 == __last2 {
        ___copy_range(&__first1, __last1, to: &__result_)
        return __result_
      }
      if value_comp(self.__get_value(__first1), other.__get_value(__first2)) {
        Tree.ensureCapacity(tree: &__result_)
        (__parent, __child) = __result_.___emplace_hint_right(__parent, __child, self[__first1])
        __first1 = __tree_next_iter(__first1)
      } else {
        if value_comp(other.__get_value(__first2), self.__get_value(__first1)) {
          Tree.ensureCapacity(tree: &__result_)
          (__parent, __child) = __result_.___emplace_hint_right(__parent, __child, other[__first2])
        } else {
          __first1 = __tree_next_iter(__first1)
        }
        __first2 = other.__tree_next_iter(__first2)
      }
    }
    other.___copy_range(&__first2, __last2, to: &__result_)
    return __result_
  }

  /// - Complexity: O(*n* + *m*)
  @inlinable
  @inline(__always)
  internal func ___difference(_ other: UnsafeTree) -> UnsafeTree {
    var __result_: UnsafeTree = .create(minimumCapacity: 0)
    var (__parent, __child) = __result_.___max_ref()
    var (__first1, __last1) = (__begin_node_, __end_node)
    var (__first2, __last2) = (other.__begin_node_, other.__end_node)
    while __first1 != __last1, __first2 != __last2 {
      if value_comp(self.__get_value(__first1), other.__get_value(__first2)) {
        Tree.ensureCapacity(tree: &__result_)
        (__parent, __child) = __result_.___emplace_hint_right(__parent, __child, self[__first1])
        __first1 = __tree_next_iter(__first1)
      } else if value_comp(other.__get_value(__first2), self.__get_value(__first1)) {
        __first2 = other.__tree_next_iter(__first2)
      } else {
        __first1 = __tree_next_iter(__first1)
        __first2 = other.__tree_next_iter(__first2)
      }
    }
    return __result_
  }
}
