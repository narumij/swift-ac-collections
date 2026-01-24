//
//  ValueComparer.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/24.
//

/*
 日本語で整理

 _NodePtrから_Keyを取り出す知識を、3箇所がもてる
 - Base
 - Tree
 - Handle

 利用側ではこれを選べるようにしたい

 _NodePtrから_Keyを取り出すとき、手法が二つある
 - 値
 - ポインタ

 利用側でこれえらを選べるようにしたい

 木が知識を持ってるケースは今のところないので、
 最終的に4パターンから利用側が選べるような設計に整理したい

 決める主体として、二つがある
 - Base
 - 自身

 UnsafeTreeV2はクラスが決めるようにしたい
 ハンドルは自分が決めるようにしたい

 _TreeNode_KeyInterfaceに集約できてるかどうか、まず整理する
 その後_TreeNode_KeyInterfaceの利用の仕方について整理する
 */

// MARK: common

// TODO: プロトコルインジェクションを整理すること
// __treenの基本要素ではないので、別カテゴリがいい



/// `__key(_:)`を定義するとプロトコルで他のBase系メソッドを生成するプロトコル
public protocol ValueComparer:
  _TreeValueType
    & _BaseKey_LessThanProtocol
    & _BaseKey_EquivProtocol
    & _BaseNode_PtrUniqueCompProtocol
    & _BaseNode_PtrCompProtocol
    & _BaseNode_KeyProtocol
    & _BaseRawValue_KeyInterface
{}


/// ツリー使用条件をインジェクションされる側の実装プロトコル
@usableFromInline
protocol ValueComparator:
  _TreeValueType
    & _TreeRawValue_KeyInterface
    & _TreeKey_CompInterface
where
  _Key == Base._Key,
  _RawValue == Base._RawValue
{
  associatedtype Base: ValueComparer
  @inlinable static func __key(_ e: _RawValue) -> _Key
  @inlinable static func value_comp(_ a: _Key, _ b: _Key) -> Bool
  @inlinable static func value_equiv(_ lhs: _Key, _ rhs: _Key) -> Bool
}

extension ValueComparator {

  @inlinable
  @inline(__always)
  public static func __key(_ e: _RawValue) -> _Key {
    Base.__key(e)
  }

  @inlinable
  @inline(__always)
  public static func value_comp(_ a: _Key, _ b: _Key) -> Bool {
    Base.value_comp(a, b)
  }

  @inlinable
  @inline(__always)
  public static func value_equiv(_ lhs: _Key, _ rhs: _Key) -> Bool {
    Base.value_equiv(lhs, rhs)
  }

  @inlinable
  @inline(__always)
  public func __key(_ e: _RawValue) -> _Key {
    Base.__key(e)
  }

  @inlinable
  @inline(__always)
  public func value_comp(_ a: _Key, _ b: _Key) -> Bool {
    Base.value_comp(a, b)
  }
}

extension ValueComparator {

  @inlinable
  @inline(__always)
  internal static func with_value_equiv<T>(_ f: ((_Key, _Key) -> Bool) -> T) -> T {
    f(value_equiv)
  }

  @inlinable
  @inline(__always)
  internal static func with_value_comp<T>(_ f: ((_Key, _Key) -> Bool) -> T) -> T {
    f(value_comp)
  }
}

extension ValueComparator where Base: ThreeWayComparator {

  @inlinable
  @inline(__always)
  internal func
    __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key)
    -> Base.__compare_result
  {
    Base.__lazy_synth_three_way_comparator(__lhs, __rhs)
  }
}

// MARK: -

/// 要素とキーが一致する場合のひな形
public protocol ScalarValueComparer:
  _ScalarRawType
    & _BaseScalarRawValue_KeyProtocol

    & HasDefaultThreeWayComparator
    & ValueComparer
{}

extension ScalarValueComparer {}

// TODO: プロトコルインジェクションを整理すること
// __treenの基本要素ではないので、別カテゴリがいい

/// 要素がキーバリューの場合のひな形
public protocol KeyValueComparer:
  _KeyValueRawType
    & _BaseRawValue_KeyInterface
    & _BaseRawValue_MappedValueInterface
    & WithMappedValueInterface

    & HasDefaultThreeWayComparator
    & ValueComparer
{}

extension KeyValueComparer where _RawValue == RedBlackTreePair<_Key, _MappedValue> {

  @inlinable
  @inline(__always)
  public static func __key(_ element: _RawValue) -> _Key { element.key }

  @inlinable
  @inline(__always)
  public static func ___mapped_value(_ element: _RawValue) -> _MappedValue { element.value }

  @inlinable
  @inline(__always)
  public static func ___with_mapped_value<T>(
    _ element: inout _RawValue, _ f: (inout _MappedValue) throws -> T
  ) rethrows -> T {
    try f(&element.value)
  }
}
