//
//  tree+inteface.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/18.
//

import Foundation

// 配列インデックス方針と生メモリポインタ方針とが共存を経験してるため、
// ふるまいの基底として抽出が必要になった

/// nullへのインスタンスアクセス
///
/// nullptrへはグローバルアクセスもあるが、性能観点でインスタンスアクセスを利用している
public protocol _nullptr_interface: _PointerType {
  var nullptr: _Pointer { get }
}

/// endへのインスタンスアクセス
public protocol _end_interface: _NodePtrType {
  var end: _NodePtr { get }
}

// ルートノードの親相当の機能
@usableFromInline
package protocol TreeEndNodeInterface: _nullptr_interface, _pointer_type {
  /// 左ノードを返す
  ///
  /// 木を遡るケースではこちらが必ず必要
  @inlinable func __left_(_: pointer) -> pointer
  /// 左ノードを返す
  ///
  /// 根から末端に向かう処理は、こちらで足りる
  @inlinable func __left_unsafe(_ p: pointer) -> pointer
  /// 左ノードを更新する
  @inlinable func __left_(_ lhs: pointer, _ rhs: pointer)
}

// 一般ノード相当の機能
@usableFromInline
package protocol TreeNodeInterface: TreeEndNodeInterface, _parent_pointer_type {
  /// 右ノードを返す
  @inlinable func __right_(_: pointer) -> pointer
  /// 右ノードを更新する
  @inlinable func __right_(_ lhs: pointer, _ rhs: pointer)
  /// 色を返す
  @inlinable func __is_black_(_: pointer) -> Bool
  /// 色を更新する
  @inlinable func __is_black_(_ lhs: pointer, _ rhs: Bool)
  /// 親ノードを返す
  @inlinable func __parent_(_: pointer) -> pointer
  /// 親ノードを更新する
  @inlinable func __parent_(_ lhs: pointer, _ rhs: pointer)
  /// 親ノードを返す
  ///
  /// This is only to align the naming with C++.
  /// C++と名前を揃えているだけのもの
  @inlinable func __parent_unsafe(_: pointer) -> __parent_pointer
}

@usableFromInline
package protocol TreeNodeRefInterface: _nullptr_interface {
  /// 左ノードへの参照を返す
  @inlinable func __left_ref(_: _NodePtr) -> _NodeRef
  /// 右ノードへの参照を返す
  @inlinable func __right_ref(_: _NodePtr) -> _NodeRef
  /// 参照先を返す
  @inlinable func __ptr_(_ rhs: _NodeRef) -> _NodePtr
  /// 参照先を更新する
  @inlinable func __ptr_(_ lhs: _NodeRef, _ rhs: _NodePtr)
}

// 型の名前にねじれがあるので注意
@usableFromInline
protocol TreeNodeValueInterface: _NodePtrType & _KeyType & __node_value_type {
  /// ノードから比較用の値を取り出す。
  /// SetやMultisetではElementに該当する
  /// DictionaryやMultiMapではKeyに該当する
  @inlinable func __get_value(_: _NodePtr) -> __node_value_type
}

// 型の名前にねじれがあるので注意
@usableFromInline
protocol TreeValueInterface: _nullptr_interface & _ValueType & __value_type {
  /// ノードの値要素を取得する
  @inlinable func __value_(_ p: _NodePtr) -> __value_type
}

@usableFromInline
protocol KeyInterface: _KeyType, _ValueType {
  /// 要素から比較用のキー値を取り出す。
  @inlinable func __key(_ e: _Value) -> _Key
}

// 型の名前にねじれがあるので注意
@usableFromInline
protocol ValueCompInterface: __node_value_type {
  /// キー同士を比較する。通常`<`と同じ
  @inlinable func value_comp(_: __node_value_type, _: __node_value_type) -> Bool
}

@usableFromInline
protocol BeginNodeInterface: _NodePtrType {
  /// 木の左端のノードを返す
  @inlinable var __begin_node_: _NodePtr { get nonmutating set }
}

@usableFromInline
protocol EndNodeInterface: _NodePtrType {
  /// 終端ノード（木の右端の次の仮想ノード）を返す
  var __end_node: _NodePtr { get }
}

@usableFromInline
protocol EndInterface: _NodePtrType {
  /// 終端ノード（木の右端の次の仮想ノード）を返す
  @inlinable var end: _NodePtr { get }
}

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

@usableFromInline
protocol SizeInterface {
  /// 木のノードの数を返す
  ///
  /// 終端ノードは含まないはず
  var __size_: Int { get nonmutating set }
}

// MARK: -

@usableFromInline
protocol AllocatorInterface: _NodePtrType, _ValueType {
  /// ノードを構築する
  func __construct_node(_ k: _Value) -> _NodePtr
}

@usableFromInline
protocol DellocatorInterface: _NodePtrType {
  /// ノードを破棄する
  func destroy(_ p: _NodePtr)
}

@usableFromInline
protocol ThreeWayComparatorInterface: _KeyType {
  associatedtype __compare_result: ThreeWayCompareResult
  @inlinable
  func __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key)
    -> __compare_result
}

// MARK: -
