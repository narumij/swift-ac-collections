//
//  ___Tree+Unite.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/06/14.
//

extension ___Tree {

  @inlinable
  @inline(__always)
  func ___copy_range(_ f: inout _NodePtr, _ l: _NodePtr, to r: inout Tree) {
    var (__parent, __child) = r.___max_ref()
    while f != l {
      Tree.ensureCapacity(tree: &r)
      (__parent, __child) = r.___emplace_hint_right(__parent, __child, self[f])
      f = __tree_next_iter(f)
    }
  }

  @inlinable
  @inline(__always)
  func ___meld_unique(_ other: ___Tree) -> ___Tree {

    var __result_: ___Tree = .create(minimumCapacity: 0)

    var (__parent, __child) = __result_.___max_ref()
    var (__first1, __last1) = (__begin_node, __end_node())
    var (__first2, __last2) = (other.__begin_node, other.__end_node())

    while __first1 != __last1 {
      if __first2 == __last2 {
        ___copy_range(&__first1, __last1, to: &__result_)
        return __result_
      }

      if ___comp(
        __key(other[__first2]),
        __key(self[__first1]))
      {

        Tree.ensureCapacity(tree: &__result_)
        (__parent, __child) = __result_.___emplace_hint_right(__parent, __child, other[__first2])
        __first2 = other.__tree_next_iter(__first2)
      } else {
        if !___comp(
          __key(self[__first1]),
          __key(other[__first2]))
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
  func ___meld_multi(_ other: ___Tree) -> ___Tree {

    var __result_: ___Tree = .create(minimumCapacity: 0)

    var (__parent, __child) = __result_.___max_ref()
    var (__first1, __last1) = (__begin_node, __end_node())
    var (__first2, __last2) = (other.__begin_node, other.__end_node())

    while __first1 != __last1 {

      if __first2 == __last2 {
        ___copy_range(&__first1, __last1, to: &__result_)
        return __result_
      }

      if ___comp(
        __key(self[__first1]),
        __key(other[__first2]))
      {

        Tree.ensureCapacity(tree: &__result_)
        (__parent, __child) = __result_.___emplace_hint_right(__parent, __child, self[__first1])
        __first1 = __tree_next_iter(__first1)
      } else if ___comp(
        __key(other[__first2]),
        __key(self[__first1]))
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
  func ___intersection(_ other: ___Tree) -> ___Tree {
    // lower_boundを使う方法があるが、一旦楽に実装できそうな方からにしている
    var __result_: ___Tree = .create(minimumCapacity: 0)
    var (__parent, __child) = __result_.___max_ref()
    var (__first1, __last1) = (__begin_node, __end_node())
    var (__first2, __last2) = (other.__begin_node, other.__end_node())
    while __first1 != __last1, __first2 != __last2 {
      if ___comp(__key(self[__first1]), __key(other[__first2])) {
        __first1 = __tree_next_iter(__first1)
      } else {
        if !___comp(__key(other[__first2]), __key(self[__first1])) {
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
  func ___symmetric_difference(_ other: ___Tree) -> ___Tree {
    var __result_: ___Tree = .create(minimumCapacity: 0)
    var (__parent, __child) = __result_.___max_ref()
    var (__first1, __last1) = (__begin_node, __end_node())
    var (__first2, __last2) = (other.__begin_node, other.__end_node())
    while __first1 != __last1 {
      if __first2 == __last2 {
        ___copy_range(&__first1, __last1, to: &__result_)
        return __result_
      }
      if ___comp(__key(self[__first1]), __key(other[__first2])) {
        Tree.ensureCapacity(tree: &__result_)
        (__parent, __child) = __result_.___emplace_hint_right(__parent, __child, self[__first1])
        __first1 = __tree_next_iter(__first1)
      } else {
        if ___comp(__key(other[__first2]), __key(self[__first1])) {
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
  func ___difference(_ other: ___Tree) -> ___Tree {
    var __result_: ___Tree = .create(minimumCapacity: 0)
    var (__parent, __child) = __result_.___max_ref()
    var (__first1, __last1) = (__begin_node, __end_node())
    var (__first2, __last2) = (other.__begin_node, other.__end_node())
    while __first1 != __last1, __first2 != __last2 {
      if ___comp(__key(self[__first1]), __key(other[__first2])) {
        Tree.ensureCapacity(tree: &__result_)
        (__parent, __child) = __result_.___emplace_hint_right(__parent, __child, self[__first1])
        __first1 = __tree_next_iter(__first1)
      } else if ___comp(__key(other[__first2]), __key(self[__first1])) {
        __first2 = __tree_next_iter(__first2)
      } else {
        __first1 = __tree_next_iter(__first1)
        __first2 = __tree_next_iter(__first2)
      }
    }
    return __result_
  }
}
