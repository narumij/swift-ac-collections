//
//  tree_interface+node.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/21.
//

// 配列インデックスベース用

// ルートノードの親相当の機能
@usableFromInline
package protocol TreeEndNodeAccessInterface: _nullptr_interface, _pointer_type {
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
package protocol TreeNodeAccessInterface: TreeEndNodeAccessInterface, _parent_pointer_type, TreeAlgorithmBaseInterface {
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

// 同名実装はない。TreeAlgorithmBaseProtocol_stdあたりに実装が付随している
@usableFromInline
package protocol TreeNodeRefAccessInterface: _nullptr_interface {
  /// 左ノードへの参照を返す
  @inlinable func __left_ref(_: _NodePtr) -> _NodeRef
  /// 右ノードへの参照を返す
  @inlinable func __right_ref(_: _NodePtr) -> _NodeRef
  /// 参照先を返す
  @inlinable func __ptr_(_ rhs: _NodeRef) -> _NodePtr
  /// 参照先を更新する
  @inlinable func __ptr_(_ lhs: _NodeRef, _ rhs: _NodePtr)
}
