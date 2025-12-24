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
protocol ___RedBlackTreeSequenceBase: ___RedBlackTreeIndexing, Collection
where
  Base: ___TreeBase & ___TreeIndex,
  Tree == ___Tree<Base>,
  Index == Tree.Index,
  Indices == Tree.Indices,
  _Value == Tree._Value
{
  associatedtype Base
  associatedtype Tree
  associatedtype Index
  associatedtype Indices
  associatedtype _Value
  var __tree_: Tree { get }
  var _start: _NodePtr { get }
  var _end: _NodePtr { get }
}

// MARK: -

extension ___RedBlackTreeSequenceBase { }

extension ___RedBlackTreeSequenceBase {

//  @inlinable
//  @inline(__always)
//  func _elementsEqual<OtherSequence>(
//    _ other: OtherSequence, by areEquivalent: (_Value, OtherSequence.Element) throws -> Bool
//  ) rethrows -> Bool where OtherSequence: Sequence {
//    try __tree_.elementsEqual(_start, _end, other, by: areEquivalent)
//  }
//
//  @inlinable
//  @inline(__always)
//  func _lexicographicallyPrecedes<OtherSequence>(
//    _ other: OtherSequence, by areInIncreasingOrder: (_Value, _Value) throws -> Bool
//  ) rethrows -> Bool where OtherSequence: Sequence, _Value == OtherSequence.Element {
//    try __tree_.lexicographicallyPrecedes(_start, _end, other, by: areInIncreasingOrder)
//  }
}
