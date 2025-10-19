//
//  ___Tree_Create.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/10/19.
//

extension ___Tree {
  
  @inlinable
  static func __create_unique<S>(sequence: __owned S) -> ___Tree
  where VC._Value == S.Element, S: Sequence
  {
    let count = (sequence as? (any Collection))?.count
    var tree: Tree = .create(minimumCapacity: count ?? 0)
    for __v in sequence {
      if count == nil {
        Tree.ensureCapacity(tree: &tree)
      }
      // 検索の計算量がO(log *n*)
      let (__parent,__child) = tree.__find_equal(VC.__key(__v))
      if tree.__ptr_(__child) == .nullptr {
        let __h = tree.__construct_node(__v)
        // バランシングの最悪計算量が結局わからず、ならしO(1)とみている
        tree.__insert_node_at(__parent, __child, __h)
      }
    }

    return tree
  }
  
  @inlinable
  static func __create_multi<S>(sequence: __owned S) -> ___Tree
  where VC._Value == S.Element, S: Sequence
  {
    let count = (sequence as? (any Collection))?.count
    var tree: Tree = .create(minimumCapacity: count ?? 0)
    for __v in sequence {
      if count == nil {
        Tree.ensureCapacity(tree: &tree)
      }
      var __parent = _NodePtr.nullptr
      // 検索の計算量がO(log *n*)
      let __child = tree.__find_leaf_high(&__parent, VC.__key(__v))
      if tree.__ptr_(__child) == .nullptr {
        let __h = tree.__construct_node(__v)
        // バランシングの最悪計算量が結局わからず、ならしO(1)とみている
        tree.__insert_node_at(__parent, __child, __h)
      }
    }

    return tree
  }

  
  @inlinable
  static func create(unique: Bool, sorted elements: __owned [VC._Value]) -> ___Tree
  where VC._Key: Comparable
  {
    let count = elements.count
    let tree: Tree = .create(minimumCapacity: count)
    // 初期化直後はO(1)
    var (__parent, __child) = tree.___max_ref()
    // ソートの計算量がO(*n* log *n*)
    for __k in elements {
      if !unique || __parent == .end || __key(tree[__parent]) != __key(__k) {
        // バランシングの最悪計算量が結局わからず、ならしO(1)とみている
        (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __k)
      }
    }
    assert(tree.__tree_invariant(tree.__root()))
    return tree
  }
  
  @inlinable
  static func create<R>(range: __owned R) -> ___Tree
  where R: RangeExpression, R: Collection, R.Element == VC._Value {
    let tree: Tree = .create(minimumCapacity: range.count)
    // 初期化直後はO(1)
    var (__parent, __child) = tree.___max_ref()
    for __k in range {
      // バランシングの最悪計算量が結局わからず、ならしO(1)とみている
      (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __k)
    }
    assert(tree.__tree_invariant(tree.__root()))
    return tree
  }
  
  @inlinable
  static func create_unique<S>(naive sequence: __owned S) -> ___Tree
  where VC._Value == S.Element, S: Sequence
  {
    return .___insert_unique(tree: .create(minimumCapacity: 0), sequence)
  }
  
  @inlinable
  static func create_multi<S>(naive sequence: __owned S) -> ___Tree
  where VC._Value == S.Element, S: Sequence
  {
    return .___insert_multi(tree: .create(minimumCapacity: 0), sequence)
  }
}

