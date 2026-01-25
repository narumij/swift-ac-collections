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

// 配列インデックス方針と生メモリポインタ方針とが共存を経験してるため、
// ふるまいの基底として抽出が必要になった
// それがtree_interface群

/*
 protocolの分類
 
 型について語ってるだけのものはsuffixにTypeを使う
 型を利用してメソッドについて語ってるだけのものはSuffixにInterfaceを使う
 実装が混じってるものや未分類はsuffixにProtocolを使う
 移行の追加suffixは、配列ベースがstdかorg、ポインタベースはptr
 たまに気分でsuffixナシをつかう
 
 つまるところ、パスカルケースのプロトコル命名では、うそやまぎらわしいは許さないこと
 
 TypeやInterfaceは、キャメルケースにし、一意に定まるようにする
 元のソースを尊重した別名系のものはスネークケースにする
 
 */

// TODO: 非常に重要なプロトコルなので、スネークケースでは無く、キャメルケースにする
/// nullへのインスタンスアクセス
///
/// nullptrへはグローバルアクセスもあるが、性能観点でインスタンスアクセスを利用している
@usableFromInline
package protocol _nullptr_interface: _PointerType {
  @inlinable var nullptr: _Pointer { get }
}

/// endへのインスタンスアクセス
///
/// end->leftが木の根
@usableFromInline
package protocol _end_interface: _NodePtrType {
  @inlinable var end: _NodePtr { get }
}

@usableFromInline
protocol BeginNodeInterface: _NodePtrType {
  /// 木の左端のノードを返す
  @inlinable var __begin_node_: _NodePtr { get nonmutating set }
}

@usableFromInline
protocol EndNodeInterface: _NodePtrType {
  /// 終端ノード（木の右端の次の仮想ノード）を返す
  @inlinable var __end_node: _NodePtr { get }
}

@usableFromInline
protocol EndInterface: _end_interface {}

@usableFromInline
protocol RootInterface: _NodePtrType {
  /// 木の根ノードを返す
  @inlinable var __root: _NodePtr { get }
}

@usableFromInline
protocol RootPtrInterface: _NodePtrType {
  /// 木の根ノードへの参照を返す
  @inlinable func __root_ptr() -> _NodeRef
}

// MARK: -

#if true
// 非常に重要なポイントなので元ソース尊重よりもわかりやすさを優先しつつ、
// エクスキューズ的に#ifで元の名前をリスペクトする感じ？
@usableFromInline
protocol _TreeNode_KeyInterface: _NodePtrType & _KeyType {
  /// ノードから比較用の値を取り出す。
  /// SetやMultisetではElementに該当する
  /// DictionaryやMultiMapではKeyに該当する
  @inlinable func __get_value(_: _NodePtr) -> _Key
}
#else
// 型の名前にねじれがあるので注意
@usableFromInline
protocol _TreeNode_KeyInterface: _NodePtrType & _KeyType & __node_value_type {
  /// ノードから比較用の値を取り出す。
  /// SetやMultisetではElementに該当する
  /// DictionaryやMultiMapではKeyに該当する
  @inlinable func __get_value(_: _NodePtr) -> __node_value_type
}
#endif

// 型の名前にねじれがあるので注意
@usableFromInline
protocol _TreeNode_RawValueInterface: _nullptr_interface & _RawValueType & __value_type {
  /// ノードの値要素を取得する
  @inlinable func __value_(_ p: _NodePtr) -> __value_type
}

@usableFromInline
protocol _TreeRawValue_KeyInterface: _KeyType, _RawValueType {
  /// 要素から比較用のキー値を取り出す。
  @inlinable func __key(_ e: _RawValue) -> _Key
}

@usableFromInline
protocol _TreeRawValue_MappedValueInteface: _KeyValueBaseType {
  
  @inlinable func ___mapped_value(_ element: _RawValue) -> _MappedValue
}

// 型の名前にねじれがあるので注意
@usableFromInline
protocol _TreeKey_CompInterface: __node_value_type {
  /// キー同士を比較する。通常`<`と同じ
  @inlinable func value_comp(_: __node_value_type, _: __node_value_type) -> Bool
}

// MARK: -

@usableFromInline
protocol SizeInterface {
  /// 木のノードの数を返す
  ///
  /// 終端ノードは含まないはず
  @inlinable var __size_: Int { get nonmutating set }
}

// MARK: -

// 型の名前にねじれがあるので注意
@usableFromInline
protocol ValueInterface:
  TreeNodeAccessInterface
    & _TreeNode_KeyInterface
    & _TreeKey_CompInterface
    & _end_interface
{}
