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
public protocol _KeyBride:
  ___Root
    & _KeyType
where
  Base: _KeyType,
  _Key == Base._Key
{}

/// ベースの積載型を受け継ぐ
public protocol _PayloadValueBride:
  ___Root
    & _PayloadValueType
where
  Base: _PayloadValueType,
  _PayloadValue == Base._PayloadValue
{}

/// ベースのバリュー型を受け継ぐ
public protocol _MappedValueBride:
  ___Root
    & _MappedValueType
where
  Base: _MappedValueType,
  _MappedValue == Base._MappedValue
{}

/// ベースの要素型を受け継ぐ
public protocol _ElementBride:
  ___Root
    & _ElementType
where
  Base: _ElementType,
  Element == Base.Element
{}

@usableFromInline
package protocol UnsafeTreeProtocol:
  ___Root
    & _UnsafeNodePtrType
where
  Base: ___TreeBase,
  Tree == UnsafeTreeV2<Base>
{}

@usableFromInline
protocol ___UnsafeTreeBaseV2: UnsafeTreeProtocol {
  var __tree_: Tree { get }
}

@usableFromInline
protocol ___UnsafeMutableTreeBaseV2: ___UnsafeTreeBaseV2 {
  var __tree_: Tree { get set }
}

@usableFromInline
protocol ___UnsafeRangeBaseV2:
  ___UnsafeTreeBaseV2
    & _UnsafeNodePtrType
    & _PayloadValueBride
{
  var _start: _NodePtr { get }
  var _end: _NodePtr { get }
}

@usableFromInline
protocol ___UnsafeIndexBaseV2:
  ___UnsafeTreeBaseV2
    & _UnsafeNodePtrType
where
  Base: ___TreeIndex,
  Index == UnsafeTreeV2<Base>.Index
{
  associatedtype Index
}

extension ___UnsafeIndexBaseV2 {

  @inlinable
  @inline(__always)
  internal func ___index(_ p: _NodePtr) -> Index {
    __tree_.makeIndex(rawValue: p)
  }

  @inlinable
  @inline(__always)
  internal func ___index_or_nil(_ p: _NodePtr) -> Index? {
    p == __tree_.nullptr ? nil : ___index(p)
  }

  @inlinable
  @inline(__always)
  internal func ___index_or_nil(_ p: _NodePtr?) -> Index? {
    p.map { ___index($0) }
  }
}

@usableFromInline
protocol ___UnsafeIndicesBaseV2: ___UnsafeTreeBaseV2
where
  Base: ___TreeIndex,
  Indices == UnsafeTreeV2<Base>.Indices
{
  associatedtype Indices
}

@usableFromInline
protocol ___UnsafeIndexRangeBaseV2:
  ___UnsafeRangeBaseV2
    & ___UnsafeIndexBaseV2
    & ___UnsafeIndicesBaseV2
{}

public typealias RedBlackTreeIndex = UnsafeIndexV2
public typealias RedBlackTreeIndices = UnsafeIndexV2Collection
public typealias RedBlackTreeIterator = RedBlackTreeIteratorV2
public typealias RedBlackTreeSlice = RedBlackTreeSliceV2

@usableFromInline
protocol _RedBlackTreeKeyOnlyBase:
  ___UnsafeStorageProtocolV2
    & ___UnsafeCommonV2
    & ___UnsafeIndexV2
    & ___UnsafeBaseSequenceV2
    & ___UnsafeKeyOnlySequenceV2
{}

@usableFromInline
protocol _RedBlackTreeKeyValuesBase:
  ___UnsafeStorageProtocolV2
    & ___UnsafeCommonV2
    & ___UnsafeIndexV2
    & ___UnsafeBaseSequenceV2
    & ___UnsafeKeyValueSequenceV2
{}
