//
//  ___RedBlackTreeMerge.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/06/03.
//

@usableFromInline
protocol ___RedBlackTreeMerge: ValueComparer & CompareTrait
where
  Tree == ___Tree<Self>,
  Element == Tree.Element
{
  associatedtype Tree
  associatedtype Element
  var __tree_: Tree { get }
  mutating func _ensureCapacity()
}

extension ___RedBlackTreeMerge {

  @inlinable
  @inline(__always)
  mutating func ___tree_merge_unique<Source>(_ __source: Source)
  where Source: MergeSourceProtocol, Source._Key == _Key, Source.Element == Element {
    var __i = __source.__begin_node
    while __i != __source.__end_node() {
      var __src_ptr: _NodePtr = __i
      var __parent: _NodePtr = .zero
      let __child = __tree_.__find_equal(&__parent, __source.__value_(__src_ptr))
      __i = __source.__tree_next_iter(__i)
      if __tree_.__ptr_(__child) != .nullptr {
        continue
      }
      _ensureCapacity()
      __src_ptr = __tree_.__construct_node(__source.___element(__src_ptr))
      __tree_.__insert_node_at(__parent, __child, __src_ptr)
    }
  }

  @inlinable
  @inline(__always)
  mutating func ___tree_merge_multi<Source>(_ __source: Source)
  where Source: MergeSourceProtocol, Source._Key == _Key, Source.Element == Element {
    var __i = __source.__begin_node
    while __i != __source.__end_node() {
      var __src_ptr: _NodePtr = __i
      var __parent: _NodePtr = .zero
      let __child = __tree_.__find_leaf_high(&__parent, __source.__value_(__src_ptr))
      __i = __source.__tree_next_iter(__i)
      _ensureCapacity()
      __src_ptr = __tree_.__construct_node(__source.___element(__src_ptr))
      __tree_.__insert_node_at(__parent, __child, __src_ptr)
    }
  }

  @inlinable
  @inline(__always)
  mutating func ___tree_merge_unique<Source, Key, Value>(
    _ __source: Source, uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows
  where
    Element == _KeyValueTuple_<Key, Value>,
    Source: MergeSourceProtocol,
    Source._Key == _Key,
    Source.Element == Element
  {
    var __i = __source.__begin_node
    while __i != __source.__end_node() {
      var __src_ptr: _NodePtr = __i
      var __parent: _NodePtr = .zero
      let __child = __tree_.__find_equal(&__parent, __source.__value_(__src_ptr))
      __i = __source.__tree_next_iter(__i)
      if __tree_.__ptr_(__child) != .nullptr {
        __tree_[__tree_.__ptr_(__child)].value = try combine(
          __tree_[__tree_.__ptr_(__child)].value, __source.___element(__src_ptr).value)
      } else {
        _ensureCapacity()
        __src_ptr = __tree_.__construct_node(__source.___element(__src_ptr))
        __tree_.__insert_node_at(__parent, __child, __src_ptr)
      }
    }
  }

  @inlinable
  @inline(__always)
  mutating func ___merge_unique<S>(_ __source: S)
  where S: Sequence, S.Element == Element {
    for __element in __source {
      var __parent: _NodePtr = .zero
      let __child = __tree_.__find_equal(&__parent, __tree_.__key(__element))
      if __tree_.__ptr_(__child) != .nullptr {
        continue
      }
      _ensureCapacity()
      let __src_ptr = __tree_.__construct_node(__element)
      __tree_.__insert_node_at(__parent, __child, __src_ptr)
    }
  }

  @inlinable
  @inline(__always)
  mutating func ___merge_multi<S>(_ __source: S)
  where S: Sequence, S.Element == Element {
    for __element in __source {
      var __parent: _NodePtr = .zero
      let __child = __tree_.__find_leaf_high(&__parent, __tree_.__key(__element))
      _ensureCapacity()
      let __src_ptr = __tree_.__construct_node(__element)
      __tree_.__insert_node_at(__parent, __child, __src_ptr)
    }
  }

  @inlinable
  @inline(__always)
  mutating func ___merge_multi<S, Key, Value>(_ __source: S)
  where
    Element == _KeyValueTuple_<Key, Value>,
    S: Sequence, S.Element == (Key, Value)
  {
    for __element in __source {
      var __parent: _NodePtr = .zero
      let __child = __tree_.__find_leaf_high(&__parent, __tree_.__key(__element))
      _ensureCapacity()
      let __src_ptr = __tree_.__construct_node(__element)
      __tree_.__insert_node_at(__parent, __child, __src_ptr)
    }
  }

  @inlinable
  @inline(__always)
  mutating func ___merge_unique<S, Key, Value>(
    _ __source: S, uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows
  where
    Element == _KeyValueTuple_<Key, Value>,
    S: Sequence, S.Element == (Key, Value)
  {
    for __element in __source {
      var __parent: _NodePtr = .zero
      let __child = __tree_.__find_equal(&__parent, __tree_.__key(__element))
      if __tree_.__ptr_(__child) != .nullptr {
        __tree_[__tree_.__ptr_(__child)].value = try combine(
          __tree_[__tree_.__ptr_(__child)].value, __element.1)
      } else {
        _ensureCapacity()
        let __src_ptr = __tree_.__construct_node(__element)
        __tree_.__insert_node_at(__parent, __child, __src_ptr)
      }
    }
  }
}
