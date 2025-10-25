// Copyright 2024 narumij
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
// Copyright © 2003-2024 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

import Foundation

extension ___Tree where VC._Key == VC._Value {

  /// ソート済みの配列から木を生成する
  ///
  /// ソート済み前提では、常に末尾への追加となり探索が不要になる
  ///
  /// - Complexity: O(*n*)
  @inlinable
  static func create_unique(sorted elements: __owned [VC._Value]) -> ___Tree
  where VC._Key: Comparable {

    let count = elements.count
    let tree: Tree = .create(minimumCapacity: count)
    // 初期化直後はO(1)
    var (__parent, __child) = tree.___max_ref()
    for __k in elements {
      if __parent == .end || __key(tree[__parent]) != __key(__k) {
        // ならしO(1)
        (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __k)
      }
    }
    assert(tree.__tree_invariant(tree.__root()))
    return tree
  }
}

extension ___Tree where VC: KeyValueComparer {

  /// ソート済みの配列から木を生成する
  ///
  /// ソート済み前提では、常に末尾への追加となり探索が不要になる
  ///
  /// - Complexity: O(*n*)
  @inlinable
  static func create_unique<Element>(
    sorted elements: __owned [Element],
    transform: (Element) -> VC._Value
  ) -> ___Tree
  where VC._Key: Comparable {

    let count = elements.count
    let tree: Tree = .create(minimumCapacity: count)
    // 初期化直後はO(1)
    var (__parent, __child) = tree.___max_ref()
    for __k in elements {
      let __v = transform(__k)
      if __parent == .end || __key(tree[__parent]) != __key(__v) {
        // ならしO(1)
        (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __v)
      } else {
        fatalError(.duplicateValue(for: VC.__key(__v)))
      }
    }
    assert(tree.__tree_invariant(tree.__root()))
    return tree
  }

  /// ソート済みの配列から木を生成する
  ///
  /// ソート済み前提では、常に末尾への追加となり探索が不要になる
  ///
  /// - Complexity: O(*n*)
  @inlinable
  static func create_unique<Element>(
    sorted elements: __owned [Element],
    uniquingKeysWith combine: (VC._MappedValue, VC._MappedValue) throws -> VC._MappedValue,
    transform: (Element) -> VC._Value
  ) rethrows -> ___Tree
  where VC._Key: Comparable {

    let count = elements.count
    let tree: Tree = .create(minimumCapacity: count)
    // 初期化直後はO(1)
    var (__parent, __child) = tree.___max_ref()
    for __k in elements {
      let __v = transform(__k)
      if __parent == .end || VC.__key(tree[__parent]) != VC.__key(__v) {
        // ならしO(1)
        (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __v)
      } else {
        try tree.___with_mapped_value(__parent) { __mappedValue in
          __mappedValue = try combine(__mappedValue, VC.___mapped_value(__v))
        }
      }
    }
    assert(tree.__tree_invariant(tree.__root()))
    return tree
  }

  /// ソート済みの配列から木を生成する
  ///
  /// ソート済み前提では、常に末尾への追加となり探索が不要になる
  ///
  /// - Complexity: O(*n*)
  @inlinable
  static func create_unique<Element>(
    sorted elements: __owned [Element],
    by keyForValue: (Element) throws -> VC._Key,
    transform: (VC._Key, Element) -> VC._Value
  ) rethrows -> ___Tree
  where VC._Key: Comparable, VC._MappedValue == [Element] {

    let count = elements.count
    let tree: Tree = .create(minimumCapacity: count)
    // 初期化直後はO(1)
    var (__parent, __child) = tree.___max_ref()
    // ソートの計算量がO(*n* log *n*)
    for __v in elements {
      let __k = try keyForValue(__v)
      if __parent == .end || VC.__key(tree[__parent]) != __k {
        // ならしO(1)
        (__parent, __child) = tree.___emplace_hint_right(__parent, __child, transform(__k, __v))
      } else {
        tree.___with_mapped_value(__parent) {
          $0.append(__v)
        }
      }
    }
    assert(tree.__tree_invariant(tree.__root()))
    return tree
  }

  /// ソート済みの配列から木を生成する
  ///
  /// ソート済み前提では、常に末尾への追加となり探索が不要になる
  ///
  /// - Complexity: O(*n*)
  @inlinable
  static func create_multi<Element>(
    sorted elements: __owned [Element],
    by keyForValue: (Element) throws -> VC._Key,
    transform: (VC._Key, Element) -> VC._Value
  ) rethrows -> ___Tree
  where VC._Key: Comparable, VC._MappedValue == Element {

    let count = elements.count
    let tree: Tree = .create(minimumCapacity: count)
    // 初期化直後はO(1)
    var (__parent, __child) = tree.___max_ref()
    for __v in elements {
      let __k = try keyForValue(__v)
      // ならしO(1)
      (__parent, __child) = tree.___emplace_hint_right(__parent, __child, transform(__k, __v))
    }
    assert(tree.__tree_invariant(tree.__root()))
    return tree
  }
}

extension ___Tree {

  /// ソート済みの配列から木を生成する
  ///
  /// ソート済み前提では、常に末尾への追加となり探索が不要になる
  ///
  /// - Complexity: O(*n*)
  @inlinable
  @inline(__always)
  static func create_multi(sorted elements: __owned [VC._Value]) -> ___Tree
  where VC._Key: Comparable {

    create_multi(sorted: elements) { $0 }
  }

  /// ソート済みの配列から木を生成する
  ///
  /// ソート済み前提では、常に末尾への追加となり探索が不要になる
  ///
  /// - Complexity: O(*n*)
  @inlinable
  static func create_multi<Element>(
    sorted elements: __owned [Element],
    transform: (Element) -> VC._Value
  ) -> ___Tree
  where VC._Key: Comparable {

    let count = elements.count
    let tree: Tree = .create(minimumCapacity: count)
    // 初期化直後はO(1)
    var (__parent, __child) = tree.___max_ref()
    for __k in elements {
      let __v = transform(__k)
      // ならしO(1)
      (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __v)
    }
    assert(tree.__tree_invariant(tree.__root()))
    return tree
  }
}

extension ___Tree {

  /// Rangeから木を生成する
  ///
  /// Rangeは重複も無いため、さらに簡略化したコードで足りる
  ///
  /// - Complexity: O(*n*)
  @inlinable
  static func create<R>(range: __owned R) -> ___Tree
  where R: RangeExpression, R: Collection, R.Element == VC._Value {

    let tree: Tree = .create(minimumCapacity: range.count)
    // 初期化直後はO(1)
    var (__parent, __child) = tree.___max_ref()
    for __k in range {
      // ならしO(1)
      (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __k)
    }
    assert(tree.__tree_invariant(tree.__root()))
    return tree
  }
}

extension ___Tree {

  @inlinable
  static func create_unique<S>(naive sequence: __owned S) -> ___Tree
  where VC._Value == S.Element, S: Sequence {

    .___insert_range_unique(tree: .create(minimumCapacity: 0), sequence)
  }

  @inlinable
  static func create_multi<S>(naive sequence: __owned S) -> ___Tree
  where VC._Value == S.Element, S: Sequence {

    .___insert_range_multi(tree: .create(minimumCapacity: 0), sequence)
  }
}

// MARK: -

#if false
  extension ___Tree {

    // 使っていない

    @inlinable
    static func __create_unique<S>(sequence: __owned S) -> ___Tree
    where VC._Value == S.Element, S: Sequence {

      let count = (sequence as? (any Collection))?.count
      var tree: Tree = .create(minimumCapacity: count ?? 0)
      for __v in sequence {
        if count == nil {
          Tree.ensureCapacity(tree: &tree)
        }
        // 検索の計算量がO(log *n*)
        let (__parent, __child) = tree.__find_equal(VC.__key(__v))
        if tree.__ptr_(__child) == .nullptr {
          let __h = tree.__construct_node(__v)
          // ならしO(1)
          tree.__insert_node_at(__parent, __child, __h)
        }
      }

      return tree
    }

    @inlinable
    static func __create_multi<S>(sequence: __owned S) -> ___Tree
    where VC._Value == S.Element, S: Sequence {

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
          // ならしO(1)
          tree.__insert_node_at(__parent, __child, __h)
        }
      }

      return tree
    }
  }
#endif
