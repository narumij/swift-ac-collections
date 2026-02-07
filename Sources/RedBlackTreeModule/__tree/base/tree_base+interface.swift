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

#if true
  // 非常に重要なポイントなので元ソース尊重よりもわかりやすさを優先しつつ、
  // エクスキューズ的に#ifで元の名前をリスペクトする感じ？
  public protocol _BaseNode_KeyInterface: _NodePtrType, _KeyType {
    /// ノードから比較用の値を取り出す。
    /// SetやMultisetではElementに該当する
    /// DictionaryやMultiMapではKeyに該当する
    static func __get_value(_: _NodePtr) -> _Key
  }
#else
  // 型の名前にねじれがあるので注意
  @usableFromInline
  protocol _BaseNode_KeyInterface: _NodePtrType & _KeyType & __node_value_type {
    /// ノードから比較用の値を取り出す。
    /// SetやMultisetではElementに該当する
    /// DictionaryやMultiMapではKeyに該当する
    static func __get_value(_: _NodePtr) -> __node_value_type
  }
#endif

// 配列インデックス方式ではこれを経由する必要があるが、ポインタ方式では縛りがない
public protocol _BaseNode_PayloadValueInterface: _NodePtrType & _PayloadValueType {
  static func __value_(_ p: _NodePtr) -> _PayloadValue
}

public protocol _BasePayload_KeyInterface: _KeyType & _PayloadValueType {
  /// 要素から比較キー値がとれること
  static func __key(_: _PayloadValue) -> _Key
}

public protocol _BasePayload_MappedValueInterface: _PayloadValueType & _MappedValueType {
  static func ___mapped_value(_: _PayloadValue) -> _MappedValue
}

public protocol _BaseKey_LessThanInterface: _KeyType {
  /// 比較関数が実装されていること
  static func value_comp(_: _Key, _: _Key) -> Bool
}

public protocol _BaseKey_EquivInterface: _KeyType {
  /// 等価比較関数は割とオプション扱い
  static func value_equiv(_ lhs: _Key, _ rhs: _Key) -> Bool
}

// MARK: -

public protocol WithMappedValueInterface: _PayloadValueType & _MappedValueType {
  static func ___with_mapped_value<T>(
    _ element: inout _PayloadValue, _ f: (inout _MappedValue) throws -> T
  ) rethrows -> T
}

// MARK: -

public protocol _Base_IsMultiTraitInterface {
  static var isMulti: Bool { get }
}

public protocol _BaseNode_PtrUniqueCompInterface: _UnsafeNodePtrType {
  static func ___ptr_comp_unique(_ l: _NodePtr, _ r: _NodePtr) -> Bool
}

public protocol _BaseNode_PtrCompInterface: _UnsafeNodePtrType {
  static func ___ptr_comp(_ l: _NodePtr, _ r: _NodePtr) -> Bool
}
