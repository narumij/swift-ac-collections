//
//  ___Tree_Insert.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/10/19.
//

extension ___Tree {
  
  @inlinable
  @inline(__always)
  static func ___insert_unique<Source>(tree __tree_: ___Tree,_ __source: Source) -> ___Tree
  where
    Source: MergeSourceProtocol,
    Source._Key == _Key,
    Source._Value == _Value
  {
    var __tree_ = __tree_

    var __i = __source.__begin_node
    
    if __tree_.__root() == .nullptr, __i != .end {
      // Make sure we always have a root node
      Tree.ensureCapacity(tree: &__tree_)
      __tree_.__insert_node_at(
        .end, __tree_.__left_ref(.end), __tree_.__construct_node(__source.__value_(__i)))
      __i = __source.__tree_next_iter(__i)
    }
    
    var __max_node = __tree_.__tree_max(__tree_.__root())
    
    while __i != .end {
      Tree.ensureCapacity(tree: &__tree_)
      let __nd = __tree_.__construct_node(__source.__value_(__i))
      __i = __source.__tree_next_iter(__i)
      
      if __tree_.value_comp(__tree_.__get_value(__max_node), __tree_.__get_value(__nd)) {  // __node > __max_node
        __tree_.__insert_node_at(__max_node, __tree_.__right_ref(__max_node), __nd)
        __max_node = __nd
      } else {
        let (__parent, __child) = __tree_.__find_equal(__tree_.__get_value(__nd))
        if __tree_.__ptr_(__child) == .nullptr {
          __tree_.__insert_node_at(__parent, __child, __nd)
        } else {
          __tree_.destroy(__nd)
        }
      }
    }
    
    return __tree_
  }
}

extension ___Tree where VC: KeyValueComparer {
  
  @inlinable
  @inline(__always)
  static func ___insert_unique<Source>(
    tree __tree_: ___Tree,
    _ __source: Source,
    uniquingKeysWith combine: (VC._MappedValue, VC._MappedValue) throws -> VC._MappedValue
  ) rethrows -> ___Tree
  where
    Source: MergeSourceProtocol,
    Source._Key == _Key,
    Source._Value == _Value
  {
    var __tree_ = __tree_

    var __i = __source.__begin_node

    if __tree_.__root() == .nullptr, __i != .end {  // Make sure we always have a root node
      Tree.ensureCapacity(tree: &__tree_)
      __tree_.__insert_node_at(
        .end, __tree_.__left_ref(.end), __tree_.__construct_node(__source.__value_(__i)))
      __i = __source.__tree_next_iter(__i)
    }

    var __max_node = __tree_.__tree_max(__tree_.__root())

    while __i != .end {
      Tree.ensureCapacity(tree: &__tree_)
      let __nd = __tree_.__construct_node(__source.__value_(__i))
      __i = __source.__tree_next_iter(__i)

      if __tree_.value_comp(__tree_.__get_value(__max_node), __tree_.__get_value(__nd)) {  // __node > __max_node
        __tree_.__insert_node_at(__max_node, __tree_.__right_ref(__max_node), __nd)
        __max_node = __nd
      } else {
        let (__parent, __child) = __tree_.__find_equal(__tree_.__get_value(__nd))
        if __tree_.__ptr_(__child) == .nullptr {
          __tree_.__insert_node_at(__parent, __child, __nd)
        } else {
          __tree_.___mapped_value(
            __tree_.__ptr_(__child),
            try combine(
              __tree_.___mapped_value(__tree_.__ptr_(__child)),
              VC.___mapped_value(__tree_.__value_(__nd))))
          __tree_.destroy(__nd)
        }
      }
    }
    
    return __tree_
  }
}

extension ___Tree {
  
  @inlinable
  @inline(__always)
  static func ___insert_multi<Source>(tree __tree_: ___Tree,_ __source: Source) -> ___Tree
  where
    Source: MergeSourceProtocol,
    Source._Key == _Key,
    Source._Value == _Value
  {
    var __tree_ = __tree_
    
    Tree.ensureCapacity(tree: &__tree_, minimumCapacity: __source.size)

    var __i = __source.__begin_node

    if __tree_.__root() == .nullptr, __i != .end {
      // Make sure we always have a root node
      __tree_.__insert_node_at(
        .end, __tree_.__left_ref(.end), __tree_.__construct_node(__source.__value_(__i)))
      __i = __source.__tree_next_iter(__i)
    }

    var __max_node = __tree_.__tree_max(__tree_.__root())

    while __i != .end {
      let __nd = __tree_.__construct_node(__source.__value_(__i))
      __i = __source.__tree_next_iter(__i)

      // Always check the max node first. This optimizes for sorted ranges inserted at the end.
      if !__tree_.value_comp(__tree_.__get_value(__nd), __tree_.__get_value(__max_node)) {  // __node >= __max_val
        __tree_.__insert_node_at(__max_node, __tree_.__right_ref(__max_node), __nd)
        __max_node = __nd
      } else {
        var __parent: _NodePtr = .zero
        let __child = __tree_.__find_leaf_high(&__parent, __tree_.__get_value(__nd))
        __tree_.__insert_node_at(__parent, __child, __nd)
      }
    }
    
    return __tree_
  }
}

extension ___Tree {
  
  @inlinable
  static func ___insert_unique<S>(tree __tree_: ___Tree,_ __source: __owned S) -> ___Tree
  where VC._Value == S.Element, S: Sequence
  {
    var __tree_ = __tree_
    
    var it = __source.makeIterator()
    
    if __tree_.__root() == .nullptr,
       let __element = it.next()
    {  // Make sure we always have a root node
      Tree.ensureCapacity(tree: &__tree_)
      __tree_.__insert_node_at(
        .end, __tree_.__left_ref(.end), __tree_.__construct_node(__element))
    }
    
    var __max_node = __tree_.__tree_max(__tree_.__root())
    
    while let __element = it.next() {
      Tree.ensureCapacity(tree: &__tree_)
      let __nd = __tree_.__construct_node(__element)
      if __tree_.value_comp(__tree_.__get_value(__max_node), __tree_.__get_value(__nd)) {  // __node > __max_node
        __tree_.__insert_node_at(__max_node, __tree_.__right_ref(__max_node), __nd)
        __max_node = __nd
      } else {
        let (__parent, __child) = __tree_.__find_equal(__tree_.__get_value(__nd))
        if __tree_.__ptr_(__child) == .nullptr {
          __tree_.__insert_node_at(__parent, __child, __nd)
        } else {
          __tree_.destroy(__nd)
        }
      }
    }
    
    return __tree_
  }
}

extension ___Tree where VC: KeyValueComparer {
  
  @inlinable
  @inline(__always)
  static func ___insert<S>(tree __tree_: ___Tree,
    _ __source: S,
    uniquingKeysWith combine: (VC._MappedValue, VC._MappedValue) throws -> VC._MappedValue,
    transform __t_: (S.Element) -> VC._Value
  ) rethrows -> ___Tree
  where
    S: Sequence
  {
    var __tree_ = __tree_

    var it = __source.makeIterator()

    if __tree_.__root() == .nullptr,
      let __element = it.next().map(__t_)
    {  // Make sure we always have a root node
      Tree.ensureCapacity(tree: &__tree_)
      __tree_.__insert_node_at(
        .end, __tree_.__left_ref(.end), __tree_.__construct_node(__element))
    }

    var __max_node = __tree_.__tree_max(__tree_.__root())

    while let __element = it.next().map(__t_) {
      Tree.ensureCapacity(tree: &__tree_)
      let __nd = __tree_.__construct_node(__element)
      if __tree_.value_comp(__tree_.__get_value(__max_node), __tree_.__get_value(__nd)) {  // __node > __max_node
        __tree_.__insert_node_at(__max_node, __tree_.__right_ref(__max_node), __nd)
        __max_node = __nd
      } else {
        let (__parent, __child) = __tree_.__find_equal(__tree_.__get_value(__nd))
        if __tree_.__ptr_(__child) == .nullptr {
          __tree_.__insert_node_at(__parent, __child, __nd)
        } else {
          __tree_.___mapped_value(
            __tree_.__ptr_(__child),
            try combine(
              __tree_.___mapped_value(__tree_.__ptr_(__child)),
              VC.___mapped_value(__tree_.__value_(__nd))))
          __tree_.destroy(__nd)
        }
      }
    }
    
    return __tree_
  }
}

extension ___Tree {
  
  @inlinable
  static func ___insert_multi<S>(tree __tree_: ___Tree,_ __source: __owned S) -> ___Tree
  where VC._Value == S.Element, S: Sequence
  {
    var __tree_ = __tree_

    var it = __source.makeIterator()

    if __tree_.__root() == .nullptr,
      let __element = it.next()
    {  // Make sure we always have a root node
      Tree.ensureCapacity(tree: &__tree_)
      __tree_.__insert_node_at(.end, __tree_.__left_ref(.end), __tree_.__construct_node(__element))
    }

    var __max_node = __tree_.__tree_max(__tree_.__root())

    while let __element = it.next() {
      Tree.ensureCapacity(tree: &__tree_)
      let __nd = __tree_.__construct_node(__element)
      // Always check the max node first. This optimizes for sorted ranges inserted at the end.
      if !__tree_.value_comp(__tree_.__get_value(__nd), __tree_.__get_value(__max_node)) {  // __node >= __max_val
        __tree_.__insert_node_at(__max_node, __tree_.__right_ref(__max_node), __nd)
        __max_node = __nd
      } else {
        var __parent: _NodePtr = .zero
        let __child = __tree_.__find_leaf_high(&__parent, __tree_.__get_value(__nd))
        __tree_.__insert_node_at(__parent, __child, __nd)
      }
    }
    
    return __tree_
  }
}
