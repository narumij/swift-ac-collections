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

import Foundation

extension UnsafeTreeV2 {

  /// 木の生成を行う
  ///
  /// サイズが0の場合に共有バッファを用いたインスタンスを返す。
  /// ensureUniqueが利用できない場面では他の生成メソッドを利用すること。
  @inlinable
  @inline(__always)
  internal static func create(
    minimumCapacity nodeCapacity: Int = 0
  ) -> UnsafeTreeV2 {
    nodeCapacity == 0
      ? _createWithEmptySingleton()
      : _createWithNewBuffer(minimumCapacity: nodeCapacity, nullptr: UnsafeNode.nullptr)
  }

  /// シングルトンバッファを用いて高速に生成する
  ///
  /// 直接呼ぶ必要はほとんど無い
  @inlinable
  @inline(__always)
  internal static func _createWithEmptySingleton() -> UnsafeTreeV2 {
    assert(_emptyTreeStorage.header.freshPoolCapacity == 0)
    return UnsafeTreeV2(
      _buffer:
        BufferPointer(
          unsafeBufferObject: _emptyTreeStorage))
  }

  /// 通常の生成
  ///
  /// ensureUniqueが利用できない場面に限って直接呼ぶようにすること
  @inlinable
  @inline(__always)
  internal static func _createWithNewBuffer(
    minimumCapacity nodeCapacity: Int,
    nullptr: _NodePtr
  ) -> UnsafeTreeV2 {
    _create(
      unsafeBufferObject:
        UnsafeTreeV2Buffer
        .create(
          _PayloadValue.self,
          minimumCapacity: nodeCapacity,
          nullptr: nullptr))
  }

  @inlinable
  @inline(__always)
  internal static func _create(unsafeBufferObject buffer: AnyObject)
    -> UnsafeTreeV2
  {
    return UnsafeTreeV2(
      _buffer:
        BufferPointer(
          unsafeBufferObject: buffer))
  }
}

// MARK: -

extension UnsafeTreeV2 where Base._Key == Base._PayloadValue {

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
      if __parent == tree.end || __key(tree.__value_(__parent)) != __key(__k) {
        // ならしO(1)
        (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __k)
      }
    }
    assert(tree.__tree_invariant(tree.__root))
    return tree
  }
}

extension UnsafeTreeV2 where Base: KeyValueComparer {

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
      if __parent == tree.end || __key(tree.__value_(__parent)) != __key(__v) {
        // ならしO(1)
        (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __v)
      } else {
        fatalError(.duplicateValue(for: Base.__key(__v)))
      }
    }
    assert(tree.__tree_invariant(tree.__root))
    return tree
  }

  /// ソート済みの配列から木を生成する
  ///
  /// ソート済み前提では、常に末尾への追加となり探索が不要になる
  ///
  /// - Complexity: O(*n*)
  @inlinable
  internal static func create_unique<Element>(
    sorted elements: __owned [Element],
    uniquingKeysWith combine: (Base._MappedValue, Base._MappedValue) throws -> Base._MappedValue,
    transform: (Element) -> Base._PayloadValue
  ) rethrows -> UnsafeTreeV2
  where Base._Key: Comparable {

    let count = elements.count
    let tree: Tree = .create(minimumCapacity: count)
    // 初期化直後はO(1)
    var (__parent, __child) = tree.___max_ref()
    for __k in elements {
      let __v = transform(__k)
      if __parent == tree.end || Base.__key(tree.__value_(__parent)) != Base.__key(__v) {
        // ならしO(1)
        (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __v)
      } else {
        try tree.___with_mapped_value(__parent) { __mappedValue in
          __mappedValue = try combine(__mappedValue, Base.___mapped_value(__v))
        }
      }
    }
    assert(tree.__tree_invariant(tree.__root))
    return tree
  }
}

extension UnsafeTreeV2 where Base: KeyValueComparer & ___UnsafeKeyValueSequenceV2 {

  /// ソート済みの配列から木を生成する
  ///
  /// ソート済み前提では、常に末尾への追加となり探索が不要になる
  ///
  /// - Complexity: O(*n*)
  @inlinable
  internal static func create_unique<Element>(
    sorted elements: __owned [Element],
    by keyForValue: (Element) throws -> Base._Key
  ) rethrows -> UnsafeTreeV2
  where Base._Key: Comparable, Base._MappedValue == [Element] {

    let count = elements.count
    let tree: Tree = .create(minimumCapacity: count)
    // 初期化直後はO(1)
    var (__parent, __child) = tree.___max_ref()
    // ソートの計算量がO(*n* log *n*)
    for __v in elements {
      let __k = try keyForValue(__v)
      if __parent == tree.end || Base.__key(tree.__value_(__parent)) != __k {
        // ならしO(1)
        (__parent, __child) = tree.___emplace_hint_right(
          __parent, __child, Base.__payload_((__k, [__v])))
      } else {
        tree.___with_mapped_value(__parent) {
          $0.append(__v)
        }
      }
    }
    assert(tree.__tree_invariant(tree.__root))
    return tree
  }

  /// ソート済みの配列から木を生成する
  ///
  /// ソート済み前提では、常に末尾への追加となり探索が不要になる
  ///
  /// - Complexity: O(*n*)
  @inlinable
  internal static func create_multi<Element>(
    sorted elements: __owned [Element],
    by keyForValue: (Element) throws -> Base._Key
  ) rethrows -> UnsafeTreeV2
  where Base._Key: Comparable, Base._MappedValue == Element {

    let count = elements.count
    let tree: Tree = .create(minimumCapacity: count)
    // 初期化直後はO(1)
    var (__parent, __child) = tree.___max_ref()
    for __v in elements {
      let __k = try keyForValue(__v)
      // ならしO(1)
      (__parent, __child) = tree.___emplace_hint_right(
        __parent, __child, Base.__payload_((__k, __v)))
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
  @inline(__always)
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

  /// Rangeから木を生成する
  ///
  /// Rangeは重複も無いため、さらに簡略化したコードで足りる
  ///
  /// - Complexity: O(*n*)
  @inlinable
  internal static func create<R>(range: __owned R) -> UnsafeTreeV2
  where R: RangeExpression, R: Collection, R.Element == Base._PayloadValue {

    let tree: Tree = .create(minimumCapacity: range.count)
    // 初期化直後はO(1)
    var (__parent, __child) = tree.___max_ref()
    for __k in range {
      // ならしO(1)
      (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __k)
    }
    assert(tree.__tree_invariant(tree.__root))
    return tree
  }
}

extension UnsafeTreeV2 {

  @inlinable
  internal static func create_unique<S>(naive sequence: __owned S) -> UnsafeTreeV2
  where Base._PayloadValue == S.Element, S: Sequence {

    .___insert_range_unique(tree: .create(), sequence)
  }

  @inlinable
  internal static func create_unique<S>(
    naive sequence: __owned S, transform: (S.Element) -> Base._PayloadValue
  ) -> UnsafeTreeV2
  where S: Sequence {

    .___insert_range_unique(tree: .create(), sequence, transform: transform)
  }

  @inlinable
  internal static func create_multi<S>(naive sequence: __owned S) -> UnsafeTreeV2
  where Base._PayloadValue == S.Element, S: Sequence {

    .___insert_range_multi(tree: .create(), sequence)
  }

  @inlinable
  internal static func create_multi<S>(
    naive sequence: __owned S, transform: (S.Element) -> Base._PayloadValue
  )
    -> UnsafeTreeV2
  where S: Sequence {

    .___insert_range_multi(tree: .create(), sequence, transform: transform)
  }
}

// MARK: -

#if false
  extension UnsafeTreeV2 {

    // 使っていない

    @inlinable
    internal static func __create_unique<S>(sequence: __owned S) -> UnsafeTreeV2
    where Base._PayloadValue == S.Element, S: Sequence {

      let count = (sequence as? (any Collection))?.count
      var tree: Tree = .create(minimumCapacity: count ?? 0)
      for __v in sequence {
        if count == nil {
          Tree.ensureCapacity(tree: &tree)
        }
        // 検索の計算量がO(log *n*)
        let (__parent, __child) = tree.__find_equal(Base.__key(__v))
        if tree.__ptr_(__child) == tree.nullptr {
          let __h = tree.__construct_node(__v)
          // ならしO(1)
          tree.__insert_node_at(__parent, __child, __h)
        }
      }

      return tree
    }

    @inlinable
    internal static func __create_multi<S>(sequence: __owned S) -> UnsafeTreeV2
    where Base._PayloadValue == S.Element, S: Sequence {

      let count = (sequence as? (any Collection))?.count
      var tree: Tree = .create(minimumCapacity: count ?? 0)
      for __v in sequence {
        if count == nil {
          Tree.ensureCapacity(tree: &tree)
        }
        var __parent = tree.nullptr
        // 検索の計算量がO(log *n*)
        let __child = tree.__find_leaf_high(&__parent, Base.__key(__v))
        if tree.__ptr_(__child) == tree.nullptr {
          let __h = tree.__construct_node(__v)
          // ならしO(1)
          tree.__insert_node_at(__parent, __child, __h)
        }
      }

      return tree
    }
  }
#endif

// MARK: -

extension UnsafeTreeV2 where _PayloadValue: Decodable {

  @inlinable
  internal static func create(from decoder: Decoder) throws -> UnsafeTreeV2 {

    var container = try decoder.unkeyedContainer()
    var tree: Tree = ._createWithNewBuffer(minimumCapacity: 0, nullptr: UnsafeNode.nullptr)
    if let count = container.count {
      Tree.ensureCapacity(tree: &tree, minimumCapacity: count)
    }

    var (__parent, __child) = tree.___max_ref()
    while !container.isAtEnd {
      let __k = try container.decode(_PayloadValue.self)
      (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __k)
    }

    assert(tree.__tree_invariant(tree.__root))
    return tree
  }
}
