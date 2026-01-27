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

// TODO: 仕様及び設計について再検討すること
// プロトコル適合問題だけに対処して止まっている気がする
// そもそも使いやすくすること自体が不可能かもしれない

// TODO: 再度チューニングすること
// 荒く書いた段階なのでいろいろ手抜きがある

public
  struct UnsafeIndexV2Collection<Base: ___TreeBase & ___TreeIndex>:
    UnsafeTreeProtocol, UnsafeIndexingProtocol
{
  public typealias Element = Index
  public typealias SubSequence = Self
  public typealias Iterator = UnsafeIterator.IndexObverse<Base>
  public typealias Reversed = UnsafeIterator.IndexReverse<Base>

  @usableFromInline
  internal init(start: _NodePtr, end: _NodePtr, tie: _TiedRawBuffer) {
    self._start = start
    self._end = end
    self.tied = tie
  }

  // TODO: Intに変更する検討
  // 計算量が問題
  // そもそもとして、Collection適合を廃止する方向になっている
  public typealias Index = UnsafeIndexV2<Base>

  @usableFromInline
  internal var _start, _end: _NodePtr

  @usableFromInline
  internal var tied: _TiedRawBuffer
}

#if COMPATIBLE_ATCODER_2025
  extension UnsafeIndexV2Collection: Sequence, Collection, BidirectionalCollection {}
#else
  extension UnsafeIndexV2Collection: Sequence {}
#endif

extension UnsafeIndexV2Collection {

  public var startIndex: Index { ___index(_start) }
  public var endIndex: Index { ___index(_end) }

  public func makeIterator() -> Iterator {
    .init(start: _start, end: _end, tie: tied)
  }

  public func reversed() -> Reversed {
    .init(start: _start, end: _end, tie: tied)
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
        start: bounds.lowerBound.rawValue,
        end: bounds.upperBound.rawValue,
        tie: bounds.lowerBound.tied)
    }
  #endif

  #if !COMPATIBLE_ATCODER_2025
    public subscript(bounds: UnsafeIndexV2RangeExpression<Base>) -> UnsafeIndexV2Collection {
      let (lower, upper) = tied.rawRange(bounds.rawRange)!
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
