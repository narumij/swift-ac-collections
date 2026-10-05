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

// 配列インデックス方針と生メモリポインタ方針とが共存を経験してたため、
// ふるまいの基底として抽出が必要だった
// それがtree_interface群
// 整理やチェックに都合がいいのでインライン化せずにこのままにする

// nullへのインスタンスアクセス
//
// nullptrへはグローバルアクセスもあるが、性能観点でインスタンスアクセスを利用している
@usableFromInline
package protocol NullPtrInterface: ~Copyable, _PointerType {
  @inlinable var nullptr: _Pointer { get }
}

// endへのインスタンスアクセス
//
// end->leftが木の根
@usableFromInline
package protocol _end_interface: ~Copyable, _NodePtrType {
  @inlinable var end: _NodePtr { get }
}

@usableFromInline
protocol BeginNodeInterface: ~Copyable, _NodePtrType {
  // 木の左端のノードを返す
  @inlinable var __begin_node_: _NodePtr { get nonmutating set }
}

@usableFromInline
protocol EndNodeInterface: ~Copyable, _NodePtrType {
  // 終端ノード（木の右端の次の仮想ノード）を返す
  @inlinable var __end_node: _NodePtr { get }
}

@usableFromInline
protocol EndInterface: ~Copyable, _end_interface {}

@usableFromInline
protocol RootInterface: ~Copyable, _NodePtrType {
  // 木の根ノードを返す
  @inlinable var __root: _NodePtr { get }
}

@usableFromInline
protocol RootPtrInterface: ~Copyable, _NodePtrType {
  // 木の根ノードへの参照を返す
  @inlinable func __root_ptr() -> _NodeRef
}

// MARK: -

#if true
  // 非常に重要なポイントなので元ソース尊重よりもわかりやすさを優先しつつ、
  // エクスキューズ的に#ifで元の名前をリスペクトする感じ？
  @usableFromInline
  protocol _TreeNode_KeyInterface: ~Copyable, _NodePtrType & _KeyType {
    // ノードから比較用の値を取り出す。
    // SetやMultisetではElementに該当する
    // DictionaryやMultiMapではKeyに該当する
    @inlinable func __get_value(_: _NodePtr) -> _Key
  }
#else
  // 型の名前にねじれがあるので注意
  @usableFromInline
  protocol _TreeNode_KeyInterface: ~Copyable, _NodePtrType & _KeyType & __node_value_type {
    // ノードから比較用の値を取り出す。
    // SetやMultisetではElementに該当する
    // DictionaryやMultiMapではKeyに該当する
    @inlinable func __get_value(_: _NodePtr) -> __node_value_type
  }
#endif

// 型の名前にねじれがあるので注意
@usableFromInline
protocol _TreeNode_PayloadValueInterface: ~Copyable, NullPtrInterface & _PayloadValueType & __value_type {
  // ノードの値要素を取得する
  @inlinable func __value_(_ p: _NodePtr) -> __value_type
}

@usableFromInline
protocol _TreePayloadValue_KeyInterface: ~Copyable, _KeyType, _PayloadValueType {
  // 要素から比較用のキー値を取り出す。
  @inlinable func __key(_ e: _PayloadValue) -> _Key
}

@usableFromInline
protocol _TreeRawValue_MappedValueInteface: ~Copyable, _KeyValueBaseType {

  @inlinable func ___mapped_value(_ element: _PayloadValue) -> _MappedValue
}

// 型の名前にねじれがあるので注意
@usableFromInline
protocol _TreeKey_CompInterface: ~Copyable, __node_value_type {
  // キー同士を比較する。通常`<`と同じ
  @inlinable func value_comp(_: __node_value_type, _: __node_value_type) -> Bool
}

// MARK: -

@usableFromInline
protocol SizeInterface: ~Copyable {
  // 木のノードの数を返す
  //
  // 終端ノードは含まないはず
  @inlinable var __size_: Int { get nonmutating set }
}

// MARK: -

// 型の名前にねじれがあるので注意
@usableFromInline
protocol ValueInterface: ~Copyable,
  TreeNodeAccessInterface
    & _TreeNode_KeyInterface
    & _TreeKey_CompInterface
    & _end_interface
{}

@usableFromInline package protocol _Tree_IsMultiTraitInterface:  ~Copyable {
  @inlinable var isMulti: Bool { get }
}
