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

#if true
extension RedBlackTreeIteratorV2.Values {
  
    public typealias Reversed = UnsafeIterator.ValueReverse<Base>
}
#else
extension RedBlackTreeIteratorV2.Values {

  @frozen
  public struct Reversed: Sequence, IteratorProtocol, UnsafeTreePointer,
    UnsafeImmutableIndexingProtocol
  {

    public typealias Tree = UnsafeTreeV2<Base>
    @usableFromInline typealias ImmutableTree = UnsafeImmutableTree<Base>
    public typealias _Value = RedBlackTreeIteratorV2.Base._Value

    @usableFromInline
    internal let __tree_: ImmutableTree

    @usableFromInline
    var source: UnsafeIterator.RemoveAwareReversePointers

    @usableFromInline
    var poolLifespan: PoolLifespan

    @inlinable
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      self.__tree_ = .init(__tree_: tree)
      source = .init(iterator: .init(__first: start, __last: end))
      self.poolLifespan = tree.poolLifespan
    }

    @inlinable
    internal init(
      __tree_: ImmutableTree,
      start: _NodePtr,
      end: _NodePtr,
      poolLifespan: PoolLifespan
    ) {
      source = .init(iterator: .init(__first: start, __last: end))
      self.__tree_ = __tree_
      self.poolLifespan = poolLifespan
    }

    @inlinable
    @inline(__always)
    public mutating func next() -> _Value? {
      source.next().map { $0.__value_().pointee }
    }
  }
}

extension RedBlackTreeIteratorV2.Values.Reversed {

  @inlinable
  @inline(__always)
  public func forEach(_ body: (Tree.Index, _Value) throws -> Void) rethrows {
    try source.makeIterator().forEach {
      try body(___index($0), __tree_.__value_($0))
    }
  }
}

extension RedBlackTreeIteratorV2.Values.Reversed {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var indices: Tree.Indices.Reversed {
    .init(
      __tree_: __tree_, start: source.source.__first, end: source.source.__last,
      poolLifespan: poolLifespan)
  }
}

extension RedBlackTreeIteratorV2.Values.Reversed {

  @available(*, deprecated, message: "危険になった為 (I think danger this is.)")
  @inlinable
  @inline(__always)
  package func ___node_positions() -> UnsafeIterator.RemoveAware<UnsafeIterator.Reverse> {
    // 多分lifetime延長しないとクラッシュする
    // と思ったけどしなかった。念のためlifetimeとdeprecated
    defer { _fixLifetime(self) }
    return source  //.init(__tree_: __tree_, start: _start, end: _end)
  }
}

extension RedBlackTreeIteratorV2.Values.Reversed: Equatable where Element: Equatable {

  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.isTriviallyIdentical(to: rhs) || lhs.elementsEqual(rhs)
  }
}

extension RedBlackTreeIteratorV2.Values.Reversed: Comparable where Element: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    !lhs.isTriviallyIdentical(to: rhs) && lhs.lexicographicallyPrecedes(rhs)
  }
}

#if swift(>=5.5)
  extension RedBlackTreeIteratorV2.Values.Reversed: @unchecked Sendable
  where _Value: Sendable {}
#endif

// MARK: - Is Identical To

extension RedBlackTreeIteratorV2.Values.Reversed {
  @inlinable
  @inline(__always)
  public func isTriviallyIdentical(to other: Self) -> Bool {
    __tree_.__end_node == other.__tree_.__end_node && source == other.source
  }
}
#endif
