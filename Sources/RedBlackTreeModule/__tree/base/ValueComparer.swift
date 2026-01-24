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

// TODO: 名称変更

/// `__key(_:)`を定義するとプロトコルで他のBase系メソッドを生成するプロトコル
public protocol ValueComparer:
  _BaseType
    & _BaseRawValue_KeyInterface
    & _BaseKey_LessThanProtocol
    & _BaseNode_PtrUniqueCompProtocol
    & _BaseNode_PtrCompProtocol
    & _BaseNode_KeyProtocol
where _Key: Comparable {}

// MARK: -

/// 要素とキーが一致する場合のひな形
public protocol ScalarValueComparer:
  ValueComparer
    & _ScalarBaseType
    & _ScalarBaseRawValue_KeyProtocol
{}

extension ScalarValueComparer {}

/// 要素がキーバリューの場合のひな形
public protocol KeyValueComparer:
  ValueComparer
    & _KeyValueBaseType
    & _BaseRawValue_KeyInterface
    & _BaseRawValue_MappedValueInterface
    & WithMappedValueInterface
{}

// LRUキャッシュがPairではないので、統一できなかった
// デコレーターパターン化できれば統一できそうだが、それはまたいずれ

extension KeyValueComparer where _RawValue == RedBlackTreePair<_Key, _MappedValue> {

  @inlinable
  @inline(__always)
  public static func __key(_ __v: _RawValue) -> _Key { __v.key }

  @inlinable
  @inline(__always)
  public static func ___mapped_value(_ __v: _RawValue) -> _MappedValue { __v.value }

  @inlinable
  @inline(__always)
  public static func ___with_mapped_value<ResultType>(
    _ __v: inout _RawValue,
    _ __body: (inout _MappedValue) throws -> ResultType
  ) rethrows -> ResultType {
    try __body(&__v.value)
  }
}
