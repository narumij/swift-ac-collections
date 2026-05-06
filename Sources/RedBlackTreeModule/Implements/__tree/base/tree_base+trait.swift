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

/// 平衡木のキーの最低限の性質に関する定義
///
///  llvmのソース由来の名前となっている
///
public protocol ValueComparer:
  _BaseKey_LessThanInterface
    & _BasePayloadValue_KeyInterface
    & _BaseNode_KeyInterface
{}

// MARK: -

/// キーのComparable制限と比較の標準実装
///
/// 比較実装を実際に使うかは、各実行形態側で決まり、ここで決めるわけではない
///
public protocol ComparableKeyTrait:
  ValueComparer
    & _BaseComparableKey_LessThanProtocol
    & _BaseEquatableKey_EquivProtocol
    & _BaseComparableNode_PtrUniqueCompProtocol
    & _BaseNode_PtrCompProtocol
    & _BaseNode_PtrRangeCompProtocol
where
  _Key: Comparable
{}

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
{}

/// 要素がキーバリューでペイロードがペアの場合のひな形
public protocol PairValueTrait:
  KeyValueTrait
    & _PairBasePayloadValue_KeyProtocol
    & _PairBasePayloadValue_MappedValueProtocol
    & _PairBase_ElementProtocol
{}
