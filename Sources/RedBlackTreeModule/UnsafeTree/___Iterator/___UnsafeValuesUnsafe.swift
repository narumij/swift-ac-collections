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

@frozen
@usableFromInline
struct ___UnsafeValuesUnsafe<Base>: Sequence, IteratorProtocol
where Base: ___TreeBase {

  @usableFromInline
  internal typealias Tree = UnsafeTree<Base>

  public typealias _NodePtr = UnsafeTree<Base>._NodePtr

  @usableFromInline
  internal let __tree_: Tree

  @usableFromInline
  internal var __first, __last: _NodePtr

  @inlinable
  @inline(__always)
  internal init(tree: Tree, __first: _NodePtr, __last: _NodePtr) {
    self.__tree_ = tree
    self.__first = __first
    self.__last = __last
  }

  @inlinable
  @inline(__always)
  internal mutating func next() -> Tree._Value? {
    guard __first != __last else { return nil }
    defer { __first = __tree_.__tree_next_iter(__first) }
    return UnsafePair<Tree._Value>.__value_ptr(__first)!.pointee
  }
}
