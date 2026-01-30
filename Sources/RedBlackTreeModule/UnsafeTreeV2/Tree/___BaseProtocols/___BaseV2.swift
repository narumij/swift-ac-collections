// Copyright 2024-2026 narumij
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2025 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

public typealias ___TreeBase = ValueComparer & _Tree_IsMultiTraitProtocol

// コレクション実装の基点
public protocol ___Root {
  associatedtype Base
  associatedtype Tree
}

@usableFromInline
protocol ___UnsafeTreeBaseV2: ___Root, _UnsafeNodePtrType
where
  Base: ___TreeBase,
  Tree == UnsafeTreeV2<Base>,
  _Key == Base._Key,
  _PayloadValue == Base._PayloadValue
{
  associatedtype _Key
  associatedtype _PayloadValue
  
  associatedtype Element

  var __tree_: Tree { get }
}

@usableFromInline
protocol ___UnsafeMutableTreeBaseV2: ___UnsafeTreeBaseV2 {
  var __tree_: Tree { get set }
}

@usableFromInline
protocol ___UnsafeRangeBaseV2: ___UnsafeTreeBaseV2 {
  var _start: _NodePtr { get }
  var _end: _NodePtr { get }
}

@usableFromInline
protocol ___UnsafeIndexBaseV2: ___UnsafeTreeBaseV2
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
