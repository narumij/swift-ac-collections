// Copyright 2024-2026 narumij
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

import Foundation

// 型の解決を制約の一致任せにしているといろいろしんどいので、
// 型に関して辿ると一意にここら辺に定まるようにする

// MARK: - Primitives

/// ノードを指す基本型の定義
public protocol _NodePtrType {
  /// ノードを指す型
  associatedtype _NodePtr: Equatable
  /// ノードを指すメンバへの参照型
  associatedtype _NodeRef
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
  protocol _ThreeWayResultType
{
  /// 三方比較結果型
  associatedtype __compare_result: ThreeWayCompareResult
}

// MARK: - Conditions

/// ノードは必ず比較型と保持型を持つ
public protocol _TreeValueType: _KeyType & _ValueType {}

/// SetやMultiSetは比較型と保持型が同じ
public protocol _ScalarValueType: _KeyType & _ValueType
where _Key == _Value {}

/// DictionaryやMultiMapは比較型と保持型は異なり、制約なし、マップ値型がある
public protocol _KeyValueType: _KeyType & _ValueType & _MappedValueType {}

/// DictionaryやMultiMapは内部のキーバリュー値にRedBlackTreePairを用いている
public protocol _KeyValuePairType: _KeyValueType {}

extension _KeyValuePairType {
  public typealias Pair = RedBlackTreePair<_Key, _MappedValue>
}

// MARK: - Aliases

/// ノードポインタの別名の定義
///
/// 移植用
public protocol _PointerType: _NodePtrType
where _NodePtr == _Pointer {
  associatedtype _Pointer
}

/// ノードポインタの別名の定義
public protocol _pointer_type: _PointerType
where pointer == _Pointer {
  associatedtype pointer
}

/// ノードポインタの別名の定義
///
/// C++では左だけがあるノードをキャストして利用する都合や、余り事情は分からないが別名がいろいろある
@usableFromInline
package protocol _parent_pointer_type: _PointerType
where __parent_pointer == _Pointer {
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
