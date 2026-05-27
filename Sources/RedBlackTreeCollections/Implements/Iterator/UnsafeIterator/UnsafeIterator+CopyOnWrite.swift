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

extension UnsafeIterator {

  public struct CopyOnWrite<Source: IteratorProtocol>:
    _UnsafeNodePtrType,
    IteratorProtocol,
    Sequence
  where
    Source: UnsafeAssosiatedIterator,
    Source.Base: ___TreeBase
  {
    public typealias Base = Source.Base

    @usableFromInline
    var tree: UnsafeTreeV2<Source.Base>

    @inlinable
    init(
      start: _SealedPtr,
      end: _SealedPtr,
      tree: UnsafeTreeV2<Source.Base>
    ) {
      self.init(
        _source: .init(
          Source.Base.self,
          _start: start,
          _end: end),
        tree: tree)
    }

    @usableFromInline
    var source: Source

    @inlinable
    internal init(_source: Source, tree: UnsafeTreeV2<Source.Base>) {
      self.source = _source
      self.tree = tree
    }

    @inlinable
    public mutating func next() -> Source.Element? {
      source.next()
    }
  }
}

extension UnsafeIterator.CopyOnWrite: Equatable where Source: Equatable {

  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.source == rhs.source
  }
}

extension UnsafeIterator.CopyOnWrite: Comparable where Source: Equatable, Element: Comparable {

  @inlinable
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.lexicographicallyPrecedes(rhs)
  }
}

extension UnsafeIterator.CopyOnWrite: @unchecked Sendable where Source: Sendable {}

#if false
extension UnsafeIterator.COW
where
  Source.Base: PairValueTrait,
  Base: ___TreeIndex,
  Self: ReverseIterator
{
  #if !COMPATIBLE_ATCODER_2025
    /// - Complexity: O(1)
    @inlinable
    public var keys: UnsafeIterator.KeyReverse<Base> {
      .init(start: source._sealed_start, end: source._sealed_end, tree: tree)
    }

    /// - Complexity: O(1)
    @inlinable
    public var values: UnsafeIterator.MappedValueReverse<Base> {
      .init(start: source._sealed_start, end: source._sealed_end, tree: tree)
    }
  #endif
}
#endif

extension UnsafeIterator.CopyOnWrite: ObverseIterator
where
  Source: ObverseIterator,
  Source.ReversedIterator: UnsafeAssosiatedIterator & Sequence,
  Source.ReversedIterator.Base == Source.Base
{
  @inlinable
  public func reversed() -> UnsafeIterator.CopyOnWrite<Source.ReversedIterator> {
    .init(_source: source.reversed(), tree: tree)
  }
}

extension UnsafeIterator.CopyOnWrite: ReverseIterator
where Source: ReverseIterator {}
