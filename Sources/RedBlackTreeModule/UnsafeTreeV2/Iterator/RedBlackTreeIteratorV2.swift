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

import Foundation

@frozen
public enum RedBlackTreeIteratorV2<Base> where Base: ___TreeBase & ___TreeIndex {

  public typealias Base = Base

  @frozen
  public struct Values: Sequence, IteratorProtocol, _UnsafeNodePtrType,
    UnsafeImmutableIndexingProtocol
  {

    public typealias Tree = UnsafeTreeV2<Base>
    public typealias _Value = RedBlackTreeIteratorV2.Base._Value

    @usableFromInline
    internal let __tree_: UnsafeImmutableTree<Base>

    @usableFromInline
    var source: UnsafeIterator.RemoveAwarePointers

    @usableFromInline
    var tied: _TiedRawBuffer

    @usableFromInline
    internal var _end: _NodePtr

    @inlinable
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      self.__tree_ = .init(__tree_: tree)
      self.tied = tree.tied
      source = .init(iterator: .init(__first: start, __last: end))
      _end = tree.__end_node
    }

    @inlinable
    @inline(__always)
    public mutating func next() -> _Value? {
      source.next().map { $0.__value_().pointee }
    }
  }
}

extension RedBlackTreeIteratorV2.Values: Equatable where _Value: Equatable {

  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.isTriviallyIdentical(to: rhs) || lhs.elementsEqual(rhs)
  }
}

extension RedBlackTreeIteratorV2.Values: Comparable where _Value: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    !lhs.isTriviallyIdentical(to: rhs) && lhs.lexicographicallyPrecedes(rhs)
  }
}

#if swift(>=5.5)
  extension RedBlackTreeIteratorV2.Values: @unchecked Sendable
  where _Value: Sendable {}
#endif

// MARK: - Is Identical To

extension RedBlackTreeIteratorV2.Values {
  @inlinable
  @inline(__always)
  public func isTriviallyIdentical(to other: Self) -> Bool {
    __tree_.__end_node == other.__tree_.__end_node && source == other.source
  }
}
