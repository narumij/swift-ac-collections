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

extension UnsafeTreeV2 {

  @inlinable
  internal static func create() -> UnsafeTreeV2 {
    _createWithEmptySingleton()
  }

  /// 木の生成を行う
  ///
  /// サイズが0の場合に共有バッファを用いたインスタンスを返す。
  /// ensureUniqueが利用できない場面では他の生成メソッドを利用すること。
  @inlinable
  internal static func create(
    minimumCapacity nodeCapacity: Int
  ) -> UnsafeTreeV2 {
    nodeCapacity == 0
      ? _createWithEmptySingleton()
      : _createWithNewBuffer(minimumCapacity: nodeCapacity, nullptr: UnsafeNode.nullptr)
  }

  /// シングルトンバッファを用いて高速に生成する
  ///
  /// 直接呼ぶ必要はほとんど無い
  @inlinable
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

// MARK: -

extension UnsafeTreeV2 where _PayloadValue: Decodable {

  @inlinable
  internal static func create(from decoder: Decoder) throws -> UnsafeTreeV2 {

    var container = try decoder.unkeyedContainer()
    let tree: Tree = ._createWithNewBuffer(
      minimumCapacity: container.count ?? 0, nullptr: UnsafeNode.nullptr)

    var (__parent, __child) = tree.___max_ref()
    while !container.isAtEnd {
      let __k = try container.decode(_PayloadValue.self)
      (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __k)
    }

    assert(tree.__tree_invariant(tree.__root))
    return tree
  }
}
