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
  internal static func create() -> UnsafeTreeV2 {
    _createWithEmptySingleton()
  }

  // 木の生成を行う
  //
  // サイズが0の場合に共有バッファを用いたインスタンスを返す。
  // ensureUniqueが利用できない場面では他の生成メソッドを利用すること。
  @inlinable
  internal static func create(
    minimumCapacity nodeCapacity: Int
  ) -> UnsafeTreeV2 {
    nodeCapacity == 0
      ? _createWithEmptySingleton()
      : _createWithNewBuffer(minimumCapacity: nodeCapacity, nullptr: UnsafeNode.nullptr)
  }

  // シングルトンバッファを用いて高速に生成する
  //
  // 直接呼ぶ必要はほとんど無い
  @inlinable
  internal static func _createWithEmptySingleton() -> UnsafeTreeV2 {
    assert(_emptyTreeStorage.header.freshPoolCapacity == 0)
    return UnsafeTreeV2(
      _buffer:
        BufferPointer(
          unsafeBufferObject: _emptyTreeStorage))
  }

  // 通常の生成
  //
  // ensureUniqueが利用できない場面に限って直接呼ぶようにすること
  @inlinable
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

extension UnsafeTreeV2 {

  // Rangeから木を生成する
  //
  // Rangeは重複も無いため、さらに簡略化したコードで足りる
  //
  // - Complexity: O(*n*)
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

// MARK: -

extension UnsafeTreeV2 where _PayloadValue: Decodable {

  // `___emplace_hint_right`は比較を一切行わず常に最右へ追加するだけなので、
  // 非ソート・重複を含む外部JSONを与えると赤黒木の順序・一意性が壊れていた
  // (2026-10-03発見)。`___insert_range_unique`/`___insert_range_multi`と同じ、
  // 単調増加なら高速・そうでなくても`__find_equal`等で正しい位置へ挿入する
  // 経路へ切り替える。
  @inlinable
  internal static func _decodedElements(from decoder: Decoder) throws -> [_PayloadValue] {
    var container = try decoder.unkeyedContainer()
    var elements: [_PayloadValue] = []
    if let count = container.count {
      elements.reserveCapacity(count)
    }
    while !container.isAtEnd {
      elements.append(try container.decode(_PayloadValue.self))
    }
    return elements
  }

  /// unique型(Set/Dictionary)向け。重複は最初に出現した方を残して破棄する。
  @inlinable
  internal static func create(from decoder: Decoder) throws -> UnsafeTreeV2 {
    var tree: Tree = .create()
    tree.___insert_range_unique(try _decodedElements(from: decoder))
    assert(tree.__tree_invariant(tree.__root))
    return tree
  }

  /// multi型(MultiSet/MultiMap)向け。同値キー・重複要素もすべて保持する。
  @inlinable
  internal static func createMulti(from decoder: Decoder) throws -> UnsafeTreeV2 {
    var tree: Tree = .create()
    tree.___insert_range_multi(try _decodedElements(from: decoder)) { $0 }
    assert(tree.__tree_invariant(tree.__root))
    return tree
  }
}
