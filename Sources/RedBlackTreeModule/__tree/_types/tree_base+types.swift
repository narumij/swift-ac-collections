//
//  types.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/18.
//

import Foundation

public protocol _NodePtrType {
  associatedtype _NodePtr: Equatable
  associatedtype _NodeRef
}

public protocol _PointerType: _NodePtrType
where _NodePtr == _Pointer {
  associatedtype _Pointer
}

public protocol _KeyType {
  /// ツリーが比較に使用する値の型
  associatedtype _Key
}

public protocol _ValueType {
  /// 要素の型
  associatedtype _Value
}

public protocol _MappedValueType {
  /// キーバリューの場合のバリュー型
  associatedtype _MappedValue
}

public protocol _TreeValueType: _KeyType & _ValueType {}

public protocol _pointer_type: _PointerType
where pointer == _Pointer
{
    associatedtype pointer
}

public protocol _parent_pointer_type: _PointerType
where __parent_pointer == _Pointer
{
    associatedtype __parent_pointer
}

@usableFromInline
protocol __node_value_type: _KeyType
where __node_value_type == _Key {
  associatedtype __node_value_type
}

@usableFromInline
protocol __value_type: _ValueType
where __value_type == _Value {
  associatedtype __value_type
}
