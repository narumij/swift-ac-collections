// Copyright 2024-2025 narumij
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
// Copyright © 2003-2024 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

// コレクション実装の基点
public protocol ___Root {
  associatedtype Base
  associatedtype Tree
}

@usableFromInline
protocol ___IndexBase: ___Root
where
  Base: ___TreeBase & ___TreeIndex,
  Tree == ___Tree<Base>,
  Index == Tree.Index
{
  associatedtype Index
  var __tree_: Tree { get }
}

@usableFromInline
protocol ___Base: ___IndexBase
where
  Base: ___TreeBase & ___TreeIndex,
  Tree == ___Tree<Base>,
  Index == Tree.Index,
  Indices == Tree.Indices,
  _Key == Tree._Key,
  _Value == Tree._Value
{
  associatedtype Index
  associatedtype Indices
  associatedtype _Key
  associatedtype _Value
  associatedtype Element
  var __tree_: Tree { get }
  var _start: _NodePtr { get }
  var _end: _NodePtr { get }
}

@usableFromInline
protocol ___RedBlackTreeKeyOnlyBase:
  ___StorageProtocol & ___CopyOnWrite & ___Common & ___Index & ___BaseSequence
    & ___KeyOnlySequence
{}

@usableFromInline
protocol ___RedBlackTreeKeyValuesBase:
  ___StorageProtocol & ___CopyOnWrite & ___Common & ___Index & ___BaseSequence
    & ___KeyValueSequence
{}

// MARK: -

extension ___IndexBase {

  @inlinable
  @inline(__always)
  internal func ___index(_ p: _NodePtr) -> Index {
    __tree_.makeIndex(rawValue: p)
  }

  @inlinable
  @inline(__always)
  internal func ___index_or_nil(_ p: _NodePtr) -> Index? {
    p == .nullptr ? nil : ___index(p)
  }

  @inlinable
  @inline(__always)
  internal func ___index_or_nil(_ p: _NodePtr?) -> Index? {
    p.map { ___index($0) }
  }
}
