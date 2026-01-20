//
//  types.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/18.
//

import Foundation

/// ノードを指す型の定義
public protocol _NodePtrType {
  /// ノードを指す型
  associatedtype _NodePtr: Equatable
  /// ノードを指すメンバへの参照型
  associatedtype _NodeRef
}

/// ノードポインタの別名の定義
///
/// 移植用
public protocol _PointerType: _NodePtrType
where _NodePtr == _Pointer {
  associatedtype _Pointer
}

/// 比較用の値型の定義
public protocol _KeyType {
  /// 比較用の値型
  associatedtype _Key
}

/// ノードが保持する値型の定義
public protocol _ValueType {
  /// ノードが保持する値型
  associatedtype _Value
}

/// キーに対応する値型の定義
public protocol _MappedValueType {
  /// キーに対応する値型
  associatedtype _MappedValue
}

/// ノードは必ず比較型と保持型を持つ
public protocol _TreeValueType: _KeyType & _ValueType {}

/// ノードポインタの別名の定義
public protocol _pointer_type: _PointerType
where pointer == _Pointer
{
    associatedtype pointer
}

/// ノードポインタの別名の定義
///
/// C++では左だけがあるノードをキャストして利用する都合や、余り事情は分からないが別名がいろいろある
public protocol _parent_pointer_type: _PointerType
where __parent_pointer == _Pointer
{
    associatedtype __parent_pointer
}

/// 比較型の別名定義
@usableFromInline
protocol __node_value_type: _KeyType
where __node_value_type == _Key {
  /// 比較型の別名
  associatedtype __node_value_type
}

/// 保持型の別名定義
@usableFromInline
protocol __value_type: _ValueType
where __value_type == _Value {
  /// 保持型の別名
  associatedtype __value_type
}

/// 三方比較結果
///
/// <=>演算子に対応するものらしい
public
  protocol ThreeWayCompareResult
{
  @inlinable func __less() -> Bool
  @inlinable func __greater() -> Bool
}

/// 三方比較結果型の定義
public
  protocol ThreeWayResultType
{
    /// 三方比較結果型
  associatedtype __compare_result: ThreeWayCompareResult
}
