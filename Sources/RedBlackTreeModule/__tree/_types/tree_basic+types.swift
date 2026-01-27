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

// 型の解決を制約の一致任せにしているといろいろしんどいので、
// 型に関して辿ると一意にここら辺に定まるようにする
// 期待するところとして、コンパイル負荷軽減と、witnessテーブル削減あたり

// 三方比較に関してはどこに配置するか迷っている（型がインターフェースを参照しているため）

// `_Value`という型名はこのコードベースでは中途半端で混乱の元なので使用しない方針とする

// MARK: - Primitives

/// ノードポインタ型の定義
public protocol _NodePtrType {
  /// ノードポインタ型
  ///
  /// _模式図_
  /// ```
  /// ...|Node|Payload|Node...
  ///    ^_NodePtr
  /// ```
  associatedtype _NodePtr: Equatable
  
  /// ノード参照ポインタ型
  ///
  /// _模式図_
  /// ```
  /// ...|             Node             |
  ///    |left|right|parent|is_black|etc|
  ///    |    |     ^_NodeRef
  ///    |    ^_NodeRef
  ///    ^_NodeRef
  /// ```
  associatedtype _NodeRef
}

/// ノードの積載値型の定義
public protocol _PayloadValueType {
  /// ノードの積載値型
  ///
  /// _模式図_
  /// ```
  /// ...|Node|Payload|Node...
  ///    |    ^--_PayloadValue
  ///    ^_NodePtr
  /// ```
  associatedtype _PayloadValue
}

/// 比較値型の定義
public protocol _KeyType {
  /// 比較値型
  ///
  /// set, multiset
  /// ```
  /// ...|Node|Payload|Node...
  ///    |    |Key    |
  ///    |     ^--_Key
  ///    ^_NodePtr
  /// ```
  ///
  /// dictionary, multimap, etc
  /// ```
  /// ...|Node|     Payload      |Node...
  ///    |    |(Key, MappedValue)|
  ///    |      ^--_Key
  ///    ^_NodePtr
  /// ```
  associatedtype _Key
}

/// キーバリュー積載時の対応値型の定義
public protocol _MappedValueType {
  /// キーバリュー積載時の対応値型
  ///
  /// _模式図_
  /// ```
  /// ...|Node|     Payload      |Node...
  ///    |    |(Key, MappedValue)|
  ///    |           ^--_MappedValue
  ///    ^_NodePtr
  /// ```
  associatedtype _MappedValue
}

// MARK: - Conditions

/// 基本型
///
/// 必ず積載型と比較型を持つ
///
/// 型名に`Base`をもつのは、クラスレベルでの制約や定義をもつことを表す。
///
/// インスタンスレベルは`Tree`となる
///
/// 制約や定義が木のインスタンスに適用されるかどうかは木の実装次第
///
public protocol _BaseType: _PayloadValueType & _KeyType {}

/// SetやMultiSetは積載型と比較型が同じ
public protocol _ScalarBaseType: _BaseType
where _PayloadValue == _Key {}

/// DictionaryやMultiMapは積載型と比較型は互いに異なり、対応値型がある
public protocol _KeyValueBaseType: _BaseType & _MappedValueType {}

/// DictionaryやMultiMapは積載型にRedBlackTreePairを用いる
public protocol _PairBaseType: _KeyValueBaseType
where _PayloadValue == RedBlackTreePair<_Key, _MappedValue> {}

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

/// 積載型の別名定義
@usableFromInline
protocol __value_type: _PayloadValueType
where __value_type == _PayloadValue {
  /// 保持型の別名
  associatedtype __value_type
}
