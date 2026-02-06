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

public protocol UnsafeIndexBinding: UnsafeTreeBinding
where Index == UnsafeTreeV2<Base>.Index, Base: ___TreeIndex {
  associatedtype Index
}

public protocol UnsafeIndicesBinding: UnsafeTreeBinding
where Indices == UnsafeTreeV2<Base>.Indices, Base: ___TreeIndex {
  associatedtype Indices
}

/// 共通生木メンバー
@usableFromInline
protocol UnsafeTreeHost: UnsafeTreeBinding {
  var __tree_: Tree { get }
}

/// 変更可能共通生木メンバー
@usableFromInline
protocol UnsafeMutableTreeHost: UnsafeTreeHost, _PayloadValueBride {
  var __tree_: Tree { get set }
}

extension UnsafeMutableTreeHost {

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
protocol ___UnsafeIndexBaseV2: UnsafeIndexBinding, UnsafeTreeHost {}

extension ___UnsafeIndexBaseV2 {

  @inlinable
  @inline(__always)
  internal func ___index(_ p: _SealedPtr) -> Index {
    __tree_.makeIndex(sealed: p)
  }

  @inlinable
  @inline(__always)
  internal func ___index_or_nil(_ p: _SealedPtr) -> Index? {
    !p.isValid ? nil : ___index(p)
  }

  @inlinable
  @inline(__always)
  internal func ___index_or_nil(_ p: _SealedPtr?) -> Index? {
    p.flatMap { ___index_or_nil($0) }
  }
}

@usableFromInline
protocol UnsafeIndicesProtoocl: UnsafeTreeSealedRangeBaseInterface & UnsafeIndicesBinding {}

extension UnsafeIndicesProtoocl {

  @inlinable
  @inline(__always)
  internal var _indices: Indices {
    .init(start: _sealed_start, end: _sealed_end, tie: __tree_.tied)
  }
}

@usableFromInline
protocol ___UnsafeIndexRangeBaseV2:
  UnsafeTreeRangeProtocol
    & ___UnsafeIndexBaseV2
    & UnsafeIndicesBinding
{}

public typealias RedBlackTreeIndex = UnsafeIndexV2
public typealias RedBlackTreeIndices = UnsafeIndexV2Collection
public typealias RedBlackTreeIterator = RedBlackTreeIteratorV2
public typealias RedBlackTreeSlice = RedBlackTreeSliceV2

@usableFromInline
protocol _RedBlackTreeKeyOnlyBase:
  UnsafeMutableTreeRangeProtocol
    & UnsafeTreeRangeProtocol & _PayloadValueBride & _KeyBride
    & ___UnsafeIndexV2
    & ___UnsafeBaseSequenceV2
    & ___UnsafeKeyOnlySequenceV2
    & UnsafeIndicesProtoocl
{}

@usableFromInline
protocol _RedBlackTreeKeyValuesBase:
  UnsafeMutableTreeRangeProtocol
    & ___UnsafeCommonV2
    & ___UnsafeIndexV2
    & ___UnsafeBaseSequenceV2
    & ___UnsafeKeyValueSequenceV2
    & UnsafeIndicesProtoocl
{}

@usableFromInline
protocol _RedBlackTreeKeyOnlyBase__:
  UnsafeMutableTreeRangeProtocol
    & UnsafeTreeRangeProtocol & _PayloadValueBride & _KeyBride
    & ___UnsafeBaseSequenceV2__
    & ___UnsafeKeyOnlySequenceV2__
    & UnsafeIndicesProtoocl
{}
