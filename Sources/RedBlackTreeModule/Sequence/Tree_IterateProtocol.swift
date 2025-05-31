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

public protocol Tree_IterateProtocol {
  associatedtype Element
  var __begin_node: _NodePtr { get }
  func __tree_next_iter(_ __x: _NodePtr) -> _NodePtr
  func __tree_prev_iter(_ __x: _NodePtr) -> _NodePtr
  subscript(_ pointer: _NodePtr) -> Element { get }
}

public protocol Tree_IndexProtocol {
  associatedtype Index
  func makeIndex(rawValue: _NodePtr) -> Index
}

public protocol Tree_RawIndexProtocol {
  func makeRawIndex(rawValue: _NodePtr) -> RawIndex
}

public protocol Tree_IndicesProtocol {
  associatedtype Indices
  func makeIndices(start: _NodePtr, end: _NodePtr) -> Indices
}

#if false
public protocol ___RawIndicesProtocol: RedBlackTreeSequenceBase {
//  func makeRawIndices<Base: RedBlackTreeSequenceBase>(start: _NodePtr, end: _NodePtr) -> RawIndexSequence<Base>
  func makeRawIndices<Base: RedBlackTreeSequenceBase>() -> RawIndexSequence<Base>
  func makeRawIndices<Base: RedBlackTreeSequenceBase>(start: _NodePtr, end: _NodePtr) -> RawIndexSequence<Base>
}

extension ___RedBlackTree.___Tree {

  public typealias RawIndices = RawIndexSequence<___RedBlackTree.___Tree<VC>>
  
  @inlinable @inline(__always)
  public func makeRawIndices<Base: RedBlackTreeSequenceBase>() -> RawIndexSequence<Base> where Base.Tree == ___RedBlackTree.___Tree<VC> {
    .init(tree: self, start: __begin_node, end: __end_node())
  }

  @inlinable @inline(__always)
  public func makeRawIndices<Base: RedBlackTreeSequenceBase>(start: _NodePtr, end: _NodePtr) -> RawIndexSequence<Base> where Base.Tree == ___RedBlackTree.___Tree<VC> {
    .init(tree: self, start: start, end: end)
  }
}
#endif
