// Copyright 2024 narumij
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

@usableFromInline
protocol ___RedBlackTreeUnique: ___RedBlackTreeIndexing & ValueComparer & CompareUniqueTrait
where
  Tree == ___Tree<Self>,
  Index == Tree.Index
{
  associatedtype Tree
  associatedtype Index
  var __tree_: Tree { get }
}

extension ___RedBlackTreeUnique {

  ///（重複なし）
  @inlinable
  @inline(__always)
  public func ___equal_range(_ k: Tree._Key) -> (lower: _NodePtr, upper: _NodePtr) {
    __tree_.__equal_range_unique(k)
  }

  @inlinable
  @inline(__always)
  func ___raw_index_equal_range(_ k: Tree._Key) -> (lower: RawIndex, upper: RawIndex) {
    let (lo, hi) = __tree_.__equal_range_unique(k)
    return (___raw_index(lo), ___raw_index(hi))
  }

  @inlinable
  @inline(__always)
  func ___index_equal_range(_ k: Tree._Key) -> (lower: Index, upper: Index) {
    let (lo, hi) = __tree_.__equal_range_unique(k)
    return (___index(lo), ___index(hi))
  }
}

@usableFromInline
protocol ___RedBlackTreeMulti: ___RedBlackTreeIndexing & ValueComparer & CompareMultiTrait
where
  Tree == ___Tree<Self>,
  Index == Tree.Index
{
  associatedtype Tree
  associatedtype Index
  var __tree_: Tree { get }
}

extension ___RedBlackTreeMulti {

  /// （重複あり）
  @inlinable
  @inline(__always)
  public func ___equal_range(_ k: Tree._Key) -> (lower: _NodePtr, upper: _NodePtr) {
    __tree_.__equal_range_multi(k)
  }

  @inlinable
  @inline(__always)
  func ___raw_index_equal_range(_ k: Tree._Key) -> (lower: RawIndex, upper: RawIndex) {
    let (lo, hi) = __tree_.__equal_range_multi(k)
    return (___raw_index(lo), ___raw_index(hi))
  }

  @inlinable
  @inline(__always)
  func ___index_equal_range(_ k: Tree._Key) -> (lower: Index, upper: Index) {
    let (lo, hi) = __tree_.__equal_range_multi(k)
    return (___index(lo), ___index(hi))
  }
}
