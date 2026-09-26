//
//  UnsafeTreeV2+create+deprecated.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/10.
//

#if COMPATIBLE_ATCODER_2025
  extension UnsafeTreeV2 where Base: ScalarValueTrait {

    /// ソート済みの配列から木を生成する
    ///
    /// ソート済み前提では、常に末尾への追加となり探索が不要になる
    ///
    /// - Complexity: O(*n*)
    @inlinable
    internal static func
      create_unique(sorted elements: __owned [Base._PayloadValue]) -> UnsafeTreeV2
    where Base._Key: Comparable {

      let count = elements.count
      let tree: Tree = .create(minimumCapacity: count)
      // 初期化直後はO(1)
      var (__parent, __child) = tree.___max_ref()
      for __k in elements {
        if __parent == tree.end || Base.__key_(__parent) != Base.__key(__k) {
          // ならしO(1)
          (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __k)
        }
      }
      assert(tree.__tree_invariant(tree.__root))
      return tree
    }
  }

  extension UnsafeTreeV2 where Base: PairValueTrait {

    /// ソート済みの配列から木を生成する
    ///
    /// ソート済み前提では、常に末尾への追加となり探索が不要になる
    ///
    /// - Complexity: O(*n*)
    @inlinable
    internal static func create_unique<Element>(
      sorted elements: __owned [Element],
      transform: (Element) -> Base._PayloadValue
    ) -> UnsafeTreeV2
    where Base._Key: Comparable {

      let count = elements.count
      let tree: Tree = .create(minimumCapacity: count)
      // 初期化直後はO(1)
      var (__parent, __child) = tree.___max_ref()
      for __k in elements {
        let __v = transform(__k)
        if __parent == tree.end || Base.__key_(__parent) != Base.__key(__v) {
          // ならしO(1)
          (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __v)
        } else {
          fatalError(.duplicateValue(for: Base.__key(__v)))
        }
      }
      assert(tree.__tree_invariant(tree.__root))
      return tree
    }
  }

  extension UnsafeTreeV2 {

    /// ソート済みの配列から木を生成する
    ///
    /// ソート済み前提では、常に末尾への追加となり探索が不要になる
    ///
    /// - Complexity: O(*n*)
    @inlinable
    internal static func
      create_multi(sorted elements: __owned [Base._PayloadValue]) -> UnsafeTreeV2
    where Base._Key: Comparable {

      create_multi(sorted: elements) { $0 }
    }

    /// ソート済みの配列から木を生成する
    ///
    /// ソート済み前提では、常に末尾への追加となり探索が不要になる
    ///
    /// - Complexity: O(*n*)
    @inlinable
    internal static func create_multi<Element>(
      sorted elements: __owned [Element],
      transform: (Element) -> Base._PayloadValue
    ) -> UnsafeTreeV2
    where Base._Key: Comparable {

      let count = elements.count
      let tree: Tree = .create(minimumCapacity: count)
      // 初期化直後はO(1)
      var (__parent, __child) = tree.___max_ref()
      for __k in elements {
        let __v = transform(__k)
        // ならしO(1)
        (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __v)
      }
      assert(tree.__tree_invariant(tree.__root))
      return tree
    }
  }

  extension UnsafeTreeV2 {

    @inlinable
    internal static func create_unique<S>(naive sequence: __owned S) -> UnsafeTreeV2
    where Base._PayloadValue == S.Element, S: Sequence {

      var tree = Self.create()
      tree.___insert_range_unique(sequence)
      return tree
    }

    @inlinable
    internal static func create_unique<S>(
      naive sequence: __owned S, transform: (S.Element) -> Base._PayloadValue
    ) -> UnsafeTreeV2
    where S: Sequence {

      var tree = Self.create()
      tree.___insert_range_unique(sequence, transform: transform)
      return tree
    }

    @inlinable
    internal static func create_multi<S>(naive sequence: __owned S) -> UnsafeTreeV2
    where Base._PayloadValue == S.Element, S: Sequence {

      var tree = Self.create()
      tree.___insert_range_multi(sequence) { $0 }
      return tree
    }

    @inlinable
    internal static func create_multi<S>(
      naive sequence: __owned S, transform: (S.Element) -> Base._PayloadValue
    )
      -> UnsafeTreeV2
    where S: Sequence {

      var tree = Self.create()
      tree.___insert_range_multi(sequence, transform: transform)
      return tree
    }
  }
#endif
