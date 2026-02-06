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

// TODO: sealed化

// TODO: 仕様及び設計について再検討すること
// プロトコル適合問題だけに対処して止まっている気がする
// そもそも使いやすくすること自体が不可能かもしれない

// TODO: 再度チューニングすること
// 荒く書いた段階なのでいろいろ手抜きがある

public
  struct UnsafeIndexV2Collection<Base: ___TreeBase & ___TreeIndex>:
    UnsafeTreeBinding, UnsafeIndexProtocol_tie
{
  public typealias Element = Index
  public typealias SubSequence = Self
  public typealias Iterator = UnsafeIterator.IndexObverse<Base>
  public typealias Reversed = UnsafeIterator.IndexReverse<Base>

  @usableFromInline
  internal init(start: _SealedPtr, end: _SealedPtr, tie: _TiedRawBuffer) {
    self._sealed_start = start
    self._sealed_end = end
    self.tied = tie
  }

  public typealias Index = UnsafeIndexV2<Base>

  @usableFromInline
  internal var _sealed_start, _sealed_end: _SealedPtr

  @usableFromInline
  internal var tied: _TiedRawBuffer
}

extension UnsafeIndexV2Collection {

  @usableFromInline
  var _start: _NodePtr { _sealed_start.pointer! }

  @usableFromInline
  var _end: _NodePtr { _sealed_end.pointer! }
}

#if COMPATIBLE_ATCODER_2025
  extension UnsafeIndexV2Collection: Sequence, Collection, BidirectionalCollection {}
#else
  extension UnsafeIndexV2Collection: Sequence {}
#endif

extension UnsafeIndexV2Collection {

  public var startIndex: Index { ___index(_start.sealed) }
  public var endIndex: Index { ___index(_end.sealed) }

  public func makeIterator() -> Iterator {
    .init(start: _sealed_start, end: _sealed_end, tie: tied)
  }

  public func reversed() -> Reversed {
    .init(start: _sealed_start, end: _sealed_end, tie: tied)
  }

  public func index(after i: Index) -> Index {
    i.advanced(by: 1)
  }

  public func index(before i: Index) -> Index {
    i.advanced(by: -1)
  }

  public subscript(position: Index) -> Index {
    position
  }

  #if COMPATIBLE_ATCODER_2025
    public subscript(bounds: Range<Index>) -> UnsafeIndexV2Collection {
      .init(
        start: bounds.lowerBound.sealed,
        end: bounds.upperBound.sealed,
        tie: bounds.lowerBound.tied)
    }
  #endif

  #if !COMPATIBLE_ATCODER_2025
    public subscript(bounds: UnsafeIndexV2RangeExpression<Base>) -> UnsafeIndexV2Collection {
      let (lower, upper) = bounds.relative(to: tied)
      return .init(start: lower, end: upper, tie: tied)
    }
  #endif
}

#if swift(>=5.5)
  extension UnsafeIndexV2Collection: @unchecked Sendable {}
#endif

// MARK: - Is Identical To

extension UnsafeIndexV2Collection {

  @inlinable
  @inline(__always)
  public func isTriviallyIdentical(to other: Self) -> Bool {
    tied === other.tied && _start == other._start && _end == other._end
  }
}
