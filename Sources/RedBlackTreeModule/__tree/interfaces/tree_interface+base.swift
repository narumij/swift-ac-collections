//
//  tree+inteface.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/18.
//

import Foundation

// 配列インデックス方針と生メモリポインタ方針とが共存を経験してるため、
// ふるまいの基底として抽出が必要になった
// それがtree_interface群

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

// 型の名前にねじれがあるので注意
@usableFromInline
protocol _TreeNode_KeyInterface: _NodePtrType & _KeyType & __node_value_type {
  /// ノードから比較用の値を取り出す。
  /// SetやMultisetではElementに該当する
  /// DictionaryやMultiMapではKeyに該当する
  @inlinable func __get_value(_: _NodePtr) -> __node_value_type
}

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
protocol _TreeRawValue_MappedValueInteface: _KeyValueRawType {
  
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
protocol _TreeKey_LazyThreeWayCompInterface: _KeyType & _ThreeWayResultType {
  @inlinable
  func __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key)
    -> __compare_result
}

@usableFromInline
protocol _TreeKey_ThreeWayCompInterface: _KeyType & _ThreeWayResultType {
  func __comp(_ __lhs: _Key, _ __rhs: _Key) -> __compare_result
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

