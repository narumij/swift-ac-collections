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

#if COMPATIBLE_ATCODER_2025
  public typealias CompareTrait = _Base_IsMultiTraitInterface
#endif

public typealias ___TreeBase = ValueComparer & _Base_IsMultiTraitInterface
public typealias ___TreeIndex = _BasePaylodValue_ElementInterface

// コレクション実装の基点
public protocol ___Root {
  /// 木の基本情報
  associatedtype Base
  /// 木
  associatedtype Tree
}

/// LRUキャッシュは異なるが、それ以外はBaseをホストしている
public protocol __BaseHosting: ___Root
where Base == Self {}

/// ベースのキー型を受け継ぐ
public protocol _KeyBride: ___Root & _KeyType
where _Key == Base._Key, Base: _KeyType {}

/// ベースの積載型を受け継ぐ
public protocol _PayloadValueBride: ___Root & _PayloadValueType
where _PayloadValue == Base._PayloadValue, Base: _PayloadValueType {}

/// ベースのバリュー型を受け継ぐ
public protocol _MappedValueBride: ___Root & _MappedValueType
where _MappedValue == Base._MappedValue, Base: _MappedValueType {}

/// ベースの要素型を受け継ぐ
public protocol _ElementBride: ___Root & _ElementType
where Element == Base.Element, Base: _ElementType {}

/// 木にどれを使うのかしっている
public protocol UnsafeTreeBinding: ___Root & _UnsafeNodePtrType
where Tree == UnsafeTreeV2<Base>, Base: ___TreeBase {}

/// 共通生木メンバー
@usableFromInline
protocol UnsafeTreeHost: UnsafeTreeBinding {
  var __tree_: Tree { get }
}

/// 変更可能共通生木メンバー
@usableFromInline
protocol UnsafeMutableTreeHost: UnsafeTreeHost & _PayloadValueBride {
  var __tree_: Tree { get set }
}

extension UnsafeMutableTreeHost {

  // たぶんめんどくさくなってサボってここにある

  @inlinable
  @inline(__always)
  @discardableResult
  package mutating func _unchecked_remove(at ptr: _NodePtr) -> (
    __r: _NodePtr, payload: _PayloadValue
  ) {
    let ___e = __tree_[ptr]
    let __r = __tree_.erase(ptr)
    return (__r, ___e)
  }
}

/// 区間指定メンバー
@usableFromInline
protocol UnsafeTreeRangeBaseInterface: UnsafeTreeHost {
  var _start: _NodePtr { get }
  var _end: _NodePtr { get }
}

@usableFromInline
protocol UnsafeTreeSealedRangeBaseInterface: UnsafeTreeHost {
  var _sealed_start: _SealedPtr { get }
  var _sealed_end: _SealedPtr { get }
}

/// 変更可能区間指定メンバー
@usableFromInline
protocol UnsafeMutableTreeRangeBaseInterface: UnsafeMutableTreeHost {
  var _start: _NodePtr { get }
  var _end: _NodePtr { get }
}

/// 変更可能区間指定メンバー
@usableFromInline
protocol UnsafeMutableTreeSealedRangeBaseInterface: UnsafeMutableTreeHost {
  var _sealed_start: _SealedPtr { get }
  var _sealed_end: _SealedPtr { get }
}

@usableFromInline
protocol ___UnsafeIndexRangeBaseV2:
  UnsafeTreeRangeBaseInterface
    & UnsafeIndexProviderProtocol
{}

public typealias RedBlackTreeIndex = UnsafeIndexV2
public typealias RedBlackTreeIndices = UnsafeIndexV2Collection
public typealias RedBlackTreeIterator = RedBlackTreeIteratorV2
public typealias RedBlackTreeSlice = RedBlackTreeSliceV2

@usableFromInline
typealias _SetBridge = _PayloadValueBride & _KeyBride & _ElementBride

@usableFromInline
typealias _MapBridge = _PayloadValueBride & _KeyBride & _MappedValueBride & _ElementBride

@usableFromInline
protocol _RedBlackTreeKeyOnlyBase:
  UnsafeMutableTreeRangeProtocol
    & UnsafeIndexProtocol_tree
    & UnsafeIndicesProtoocl
    & UnsafeTreeRangeBaseInterface
    & _SetBridge
    & _CompareV2
    & _SequenceV2
    & ___UnsafeIndexV2
    & ___UnsafeKeyOnlySequenceV2
{}

@usableFromInline
protocol _RedBlackTreeKeyValuesBase:
  UnsafeMutableTreeRangeProtocol
    & UnsafeIndexProtocol_tree
    & UnsafeIndicesProtoocl
    & _MapBridge
    & _CompareV2
    & _SequenceV2
    & ___UnsafeIndexV2
    & ___UnsafeKeyValueSequenceV2
{}

@usableFromInline
protocol _RedBlackTreeKeyOnlyBase__:
  UnsafeMutableTreeRangeProtocol
    & UnsafeTreeRangeBaseInterface
    & _SetBridge
    & _CompareV2
    & _SequenceV2
    & ___UnsafeKeyOnlySequenceV2__
{}

@usableFromInline
protocol _ScalarBasePayload_KeyProtocol_ptr:
  _ScalarBaseType
    & _ScalarBase_ElementProtocol
    & _ScalarBasePayloadValue_KeyProtocol
{}

extension _ScalarBasePayload_KeyProtocol_ptr {

  @inlinable @inline(__always)
  public static func __get_value(_ p: UnsafeMutablePointer<UnsafeNode>) -> _Key {
    p.__key_ptr(of: Self.self).pointee
  }
}

@usableFromInline
protocol _PairBasePayload_KeyProtocol_ptr: _PairBaseType & _PairBase_ElementProtocol {}

extension _PairBasePayload_KeyProtocol_ptr {

  @inlinable @inline(__always)
  public static func __get_value(_ p: UnsafeMutablePointer<UnsafeNode>) -> _Key {
    p.__key_ptr(of: Self.self).pointee
  }
}
