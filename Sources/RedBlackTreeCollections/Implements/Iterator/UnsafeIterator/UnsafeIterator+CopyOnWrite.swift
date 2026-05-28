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

  @frozen
  public struct _CopyOnWrite<Source>:
    _UnsafeNodePtrType,
    IteratorProtocol,
    Sequence
  where
    Source: UnsafeAssosiatedIterator
  {
    public typealias Base = Source.Base
    public typealias Tree = UnsafeTreeV2<Source.Base>

    @usableFromInline
    var tree: Tree

    @inlinable
    init(start: _NodePtr, end: _NodePtr, tree: Tree)
    where Source.Source == _Obverse4 {
      self.source = .init(source: .init(nullptr: tree.nullptr, _start: start, _end: end))
      self.tree = tree
    }

    @inlinable
    init(start: _NodePtr, end: _NodePtr, tree: Tree)
    where Source.Source == _Reverse4 {
      self.source = .init(source: .init(nullptr: tree.nullptr, _start: start, _end: end))
      self.tree = tree
    }

    @usableFromInline
    var source: Source

    @inlinable
    internal init(_source: Source, tree: Tree) {
      self.source = _source
      self.tree = tree
    }

    @inlinable
    public mutating func next() -> Source.Element? {
      source.next()
    }
  }
}

extension UnsafeIterator._CopyOnWrite: @unchecked Sendable where Source: Sendable {}

extension UnsafeIterator._CopyOnWrite: ObverseIterator
where
  Source: ObverseIterator,
  Source.ReversedIterator: UnsafeAssosiatedIterator & Sequence,
  Source.ReversedIterator.Base == Source.Base
{
  @inlinable
  public func reversed() -> UnsafeIterator._CopyOnWrite<Source.ReversedIterator> {
    .init(_source: source.reversed(), tree: tree)
  }
}

extension UnsafeIterator._CopyOnWrite: ReverseIterator
where Source: ReverseIterator {}
