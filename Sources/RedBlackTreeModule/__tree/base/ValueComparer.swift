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
  _BaseKey_LessThanInterface
    & _BasePayloadValue_KeyInterface
    & _BaseNode_KeyInterface
{}

public protocol ComparableKeyTrait:
  ValueComparer
    & _BaseComparableKey_LessThanProtocol
    & _BaseEquatableKey_EquivProtocol
where
  _Key: Comparable
{}

// MARK: -

/// 要素とキーが一致する場合のひな形
public protocol ScalarValueTrait:
  ComparableKeyTrait
    & _ScalarBaseType
    & _BasePayloadValue_KeyInterface
    & _ScalarBase_ElementProtocol
{}

/// 要素がキーバリューの場合のひな形
public protocol KeyValueTrait:
  ComparableKeyTrait
    & _KeyValueBaseType
    & _BasePayloadValue_KeyInterface
    & _BasePayloadValue_MappedValueInterface
    & _BasePayloadValue_WithMappedValueInterface
{}

/// 要素がキーバリューでペイロードがペアの場合のひな形
public protocol PairValueTrait:
  KeyValueTrait
    & _PairBasePayloadValue_KeyProtocol
    & _PairBasePayloadValue_MappedValueProtocol
    & _PairBasePayloadValue_WithMappedValueProtocol
    & _PairBase_ElementProtocol
{}
