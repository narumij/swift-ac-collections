//
//  ___RedBlackTreeMerge.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/06/03.
//

@usableFromInline
protocol ___RedBlackTreeMerge: ValueComparer & CompareTrait & ThreeWayComparator
where
  Tree == ___Tree<Self>,
  _Value == Tree._Value
{
  associatedtype Tree
  associatedtype _Value
  var __tree_: Tree { get }
  mutating func _ensureCapacity()
  mutating func _ensureCapacity(amount: Int)
}

// MARK: - Tree merge
// マージ元がtreeを持つケース

extension ___RedBlackTreeMerge {

  // MARK: Unique

  @inlinable
  @inline(__always)
  mutating func ___tree_merge_unique<Source>(_ __source: Source)
  where
    Source: MergeSourceProtocol,
    Source._Key == _Key,
    Source._Value == _Value
  {
    var __i = __source.__begin_node
    while __i != __source.__end_node() {
      var __src_ptr: _NodePtr = __i
      let (__parent, __child) = __tree_.__find_equal(__source.__get_value(__src_ptr))
      __i = __source.__tree_next_iter(__i)
      if __tree_.__ptr_(__child) != .nullptr {
        continue
      }
      _ensureCapacity()
      __src_ptr = __tree_.__construct_node(__source.__value_(__src_ptr))
      __tree_.__insert_node_at(__parent, __child, __src_ptr)
    }
  }

  // MARK: Unique with Uniquing

  @inlinable
  @inline(__always)
  mutating func ___tree_merge_unique<Source, Key, Value>(
    _ __source: Source,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows
  where
    _Value == _KeyValueTuple_<Key, Value>,
    Source: MergeSourceProtocol,
    Source._Key == _Key,
    Source._Value == _Value
  {
    var __i = __source.__begin_node
    while __i != __source.__end_node() {
      var __src_ptr: _NodePtr = __i
      let (__parent, __child) = __tree_.__find_equal(__source.__get_value(__src_ptr))
      __i = __source.__tree_next_iter(__i)
      if __tree_.__ptr_(__child) != .nullptr {
        __tree_[__tree_.__ptr_(__child)].value = try combine(
          __tree_[__tree_.__ptr_(__child)].value, __source.__value_(__src_ptr).value)
      } else {
        _ensureCapacity()
        __src_ptr = __tree_.__construct_node(__source.__value_(__src_ptr))
        __tree_.__insert_node_at(__parent, __child, __src_ptr)
      }
    }
  }

  @inlinable
  @inline(__always)
  mutating func ___tree_merge_unique<Source, Key, Value>(
    _ __source: Source,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows
  where
    _Value == Pair<Key, Value>,
    Source: MergeSourceProtocol,
    Source._Key == _Key,
    Source._Value == _Value
  {
    var __i = __source.__begin_node
    while __i != __source.__end_node() {
      var __src_ptr: _NodePtr = __i
      let (__parent, __child) = __tree_.__find_equal(__source.__get_value(__src_ptr))
      __i = __source.__tree_next_iter(__i)
      if __tree_.__ptr_(__child) != .nullptr {
        __tree_[__tree_.__ptr_(__child)].value = try combine(
          __tree_[__tree_.__ptr_(__child)].value, __source.__value_(__src_ptr).value)
      } else {
        _ensureCapacity()
        __src_ptr = __tree_.__construct_node(__source.__value_(__src_ptr))
        __tree_.__insert_node_at(__parent, __child, __src_ptr)
      }
    }
  }
}

extension ___RedBlackTreeMerge {

  // MARK: Multi

  @inlinable
  @inline(__always)
  mutating func ___tree_merge_multi<Source>(_ __source: Source)
  where
    Source: MergeSourceProtocol,
    Source._Key == _Key,
    Source._Value == _Value
  {
    _ensureCapacity(amount: __source.size)
    var __i = __source.__begin_node
    while __i != __source.__end_node() {
      var __src_ptr: _NodePtr = __i
      var __parent: _NodePtr = .zero
      let __child = __tree_.__find_leaf_high(&__parent, __source.__get_value(__src_ptr))
      __i = __source.__tree_next_iter(__i)
      __src_ptr = __tree_.__construct_node(__source.__value_(__src_ptr))
      __tree_.__insert_node_at(__parent, __child, __src_ptr)
    }
  }
}

// MARK: - Sequence merge
// マージ元がSequenceのケース

extension ___RedBlackTreeMerge {

  // MARK: Unique

  @inlinable
  @inline(__always)
  mutating func ___merge_unique<S>(_ __source: S)
  where
    S: Sequence,
    S.Element == _Value
  {
    #if false
      for __element in __source {
        let (__parent, __child) = __tree_.__find_equal(__tree_.__key(__element))
        if __tree_.__ptr_(__child) != .nullptr {
          continue
        }
        _ensureCapacity()
        let __src_ptr = __tree_.__construct_node(__element)
        __tree_.__insert_node_at(__parent, __child, __src_ptr)
      }
    #else
      var it = __source.makeIterator()

      if __tree_.__root() == .nullptr,
        let __element = it.next()
      {  // Make sure we always have a root node
        _ensureCapacity()
        __tree_.__insert_node_at(
          .end, __tree_.__left_ref(.end), __tree_.__construct_node(__element))
      }

      var __max_node = __tree_.__tree_max(__tree_.__root())

      while let __element = it.next() {
        _ensureCapacity()
        let __nd = __tree_.__construct_node(__element)
        if __tree_.value_comp(__tree_.__get_value(__max_node), __tree_.__get_value(__nd)) { // __node > __max_node
          __tree_.__insert_node_at(__max_node, __tree_.__right_ref(__max_node), __nd)
          __max_node = __nd
        } else {
          let (__parent, __child) = __tree_.__find_equal(__tree_.__key(__element))
          if __tree_.__ptr_(__child) == .nullptr {
            __tree_.__insert_node_at(__parent, __child, __nd)
          } else {
            __tree_.destroy(__nd)
          }
        }
      }
    #endif
  }

  // MARK: Unique with Uniquing

  @inlinable
  @inline(__always)
  mutating func ___merge_unique<S, Key, Value>(
    _ __source: S,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows
  where
    _Value == _KeyValueTuple_<Key, Value>,
    S: Sequence,
    S.Element == (Key, Value)
  {
    #if false
      for __element in __source {
        let (__parent, __child) = __tree_.__find_equal(__tree_.__key(__element))
        if __tree_.__ptr_(__child) != .nullptr {
          __tree_[__tree_.__ptr_(__child)].value = try combine(
            __tree_[__tree_.__ptr_(__child)].value, __element.1)
        } else {
          _ensureCapacity()
          let __src_ptr = __tree_.__construct_node(__element)
          __tree_.__insert_node_at(__parent, __child, __src_ptr)
        }
      }
    #else
      var it = __source.makeIterator()

      if __tree_.__root() == .nullptr,
        let __element = it.next()
      {  // Make sure we always have a root node
        _ensureCapacity()
        __tree_.__insert_node_at(
          .end, __tree_.__left_ref(.end), __tree_.__construct_node(__element))
      }

      var __max_node = __tree_.__tree_max(__tree_.__root())

      while let __element = it.next() {
        _ensureCapacity()
        let __nd = __tree_.__construct_node(__element)
        if __tree_.value_comp(__tree_.__get_value(__max_node), __tree_.__get_value(__nd)) { // __node > __max_node
          __tree_.__insert_node_at(__max_node, __tree_.__right_ref(__max_node), __nd)
          __max_node = __nd
        } else {
          let (__parent, __child) = __tree_.__find_equal(__tree_.__key(__element))
          if __tree_.__ptr_(__child) == .nullptr {
            __tree_.__insert_node_at(__parent, __child, __nd)
          } else {
            __tree_[__tree_.__ptr_(__child)].value = try combine(
              __tree_[__tree_.__ptr_(__child)].value, __element.1)
            __tree_.destroy(__nd)
          }
        }
      }
    #endif
  }

  @inlinable
  @inline(__always)
  mutating func ___merge_unique<S, Key, Value>(
    _ __source: S,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows
  where
    _Value == Pair<Key, Value>,
    S: Sequence,
    S.Element == Pair<Key, Value>
  {
    #if false
      for __element in __source {
        let (__parent, __child) = __tree_.__find_equal(__tree_.__key(__element))
        if __tree_.__ptr_(__child) != .nullptr {
          __tree_[__tree_.__ptr_(__child)].value = try combine(
            __tree_[__tree_.__ptr_(__child)].value, __element.value)
        } else {
          _ensureCapacity()
          let __src_ptr = __tree_.__construct_node(__element)
          __tree_.__insert_node_at(__parent, __child, __src_ptr)
        }
      }
    #else
      var it = __source.makeIterator()

      if __tree_.__root() == .nullptr,
        let __element = it.next()
      {  // Make sure we always have a root node
        _ensureCapacity()
        __tree_.__insert_node_at(
          .end, __tree_.__left_ref(.end), __tree_.__construct_node(__element))
      }

      var __max_node = __tree_.__tree_max(__tree_.__root())

      while let __element = it.next() {
        _ensureCapacity()
        let __nd = __tree_.__construct_node(__element)
        if __tree_.value_comp(__tree_.__get_value(__max_node), __tree_.__get_value(__nd)) { // __node > __max_node
          __tree_.__insert_node_at(__max_node, __tree_.__right_ref(__max_node), __nd)
          __max_node = __nd
        } else {
          let (__parent, __child) = __tree_.__find_equal(__tree_.__key(__element))
          if __tree_.__ptr_(__child) == .nullptr {
            __tree_.__insert_node_at(__parent, __child, __nd)
          } else {
            __tree_[__tree_.__ptr_(__child)].value = try combine(
              __tree_[__tree_.__ptr_(__child)].value, __element.value)
            __tree_.destroy(__nd)
          }
        }
      }
    #endif
  }
}

extension ___RedBlackTreeMerge {

  // MARK: Multi

  @inlinable
  @inline(__always)
  mutating func ___merge_multi<S>(_ __source: S)
  where
    S: Sequence,
    S.Element == _Value
  {
    var it = __source.makeIterator()

    if __tree_.__root() == .nullptr,
      let __element = it.next()
    {  // Make sure we always have a root node
      _ensureCapacity()
      __tree_.__insert_node_at(.end, __tree_.__left_ref(.end), __tree_.__construct_node(__element))
    }

    var __max_node = __tree_.__tree_max(__tree_.__root())

    while let __element = it.next() {
      _ensureCapacity()
      let __nd = __tree_.__construct_node(__element)
      // Always check the max node first. This optimizes for sorted ranges inserted at the end.
      if !__tree_.value_comp(__tree_.__get_value(__nd), __tree_.__get_value(__max_node)) {  // __node >= __max_val
        __tree_.__insert_node_at(__max_node, __tree_.__right_ref(__max_node), __nd)
        __max_node = __nd
      } else {
        var __parent: _NodePtr = .zero
        let __child = __tree_.__find_leaf_high(&__parent, __tree_.__key(__element))
        __tree_.__insert_node_at(__parent, __child, __nd)
      }
    }
  }
}
