//
//  tree_base+interface.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/24.
//

public protocol _BaseNode_RawValueInterface: _NodePtrType & _RawValueType {
  static func __value_(_ p: _NodePtr) -> _RawValue
}

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

public protocol _BaseRawValue_KeyInterface: _KeyType & _RawValueType {
  /// 要素から比較キー値がとれること
  static func __key(_: _RawValue) -> _Key
}

public protocol _BaseRawValue_MappedValueInterface: _RawValueType & _MappedValueType {
  static func ___mapped_value(_: _RawValue) -> _MappedValue
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

public protocol WithMappedValueInterface: _RawValueType & _MappedValueType {
  static func ___with_mapped_value<T>(
    _ element: inout _RawValue, _ f: (inout _MappedValue) throws -> T
  ) rethrows -> T
}

// MARK: -

public protocol _Base_MultiTraitInterface {
  static var isMulti: Bool { get }
}

public protocol _BaseNode_PtrUniqueCompInterface: _UnsafeNodePtrType {
  static func ___ptr_comp_unique(_ l: _NodePtr, _ r: _NodePtr) -> Bool
}

public protocol _BaseNode_PtrCompInterface: _UnsafeNodePtrType {
  static func ___ptr_comp(_ l: _NodePtr, _ r: _NodePtr) -> Bool
}
