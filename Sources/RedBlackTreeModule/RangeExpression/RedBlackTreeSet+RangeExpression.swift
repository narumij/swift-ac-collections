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

#if !COMPATIBLE_ATCODER_2025

  extension RedBlackTreeSet {

    public typealias View = RedBlackTreeKeyOnlyRangeView<Base>
    public typealias IndexRange = UnsafeIndexV3Range
    public typealias IndexRangeExpression = UnsafeIndexV3RangeExpression

    @inlinable
    public func isValid(_ bounds: UnboundedRange) -> Bool {
      true
    }

    @inlinable
    public func isValid(_ bounds: IndexRange) -> Bool {
      let range = __tree_.__purified_(bounds.range)
      return __tree_.isValidSealedRange(lower: range.lowerBound, upper: range.upperBound)
        && range.lowerBound.isValid
        && range.upperBound.isValid
    }

    @inlinable
    public func isValid(_ bounds: IndexRangeExpression) -> Bool {
      let range = __tree_.__purified_(bounds.relative(to: __tree_))
      return __tree_.isValidSealedRange(lower: range.lowerBound, upper: range.upperBound)
        && range.lowerBound.isValid
        && range.upperBound.isValid
    }
    
    @inlinable
    public subscript(bounds: UnboundedRange) -> View {
      @inline(__always) get {
        self[unchecked: ___sealed_range]
      }
      @inline(__always) _modify {
        yield &self[unchecked: ___sealed_range]
      }
    }

    @inlinable
    public subscript(bounds: IndexRange) -> View {
      @inline(__always) get {
        let range = __tree_.__purified_(bounds.range)
        guard __tree_.isValidSealedRange(range) else {
          fatalError(.invalidIndex)
        }
        return self[unchecked: range]
      }
      @inline(__always) _modify {
        let range = __tree_.__purified_(bounds.range)
        guard __tree_.isValidSealedRange(range) else {
          fatalError(.invalidIndex)
        }
        yield &self[unchecked: range]
      }
    }

    @inlinable
    public subscript(bounds: IndexRangeExpression) -> View {
      @inline(__always) get {
        let range = __tree_.__purified_(bounds.relative(to: __tree_))
        guard __tree_.isValidSealedRange(range) else {
          fatalError(.invalidIndex)
        }
        return self[unchecked: range]
      }
      @inline(__always) _modify {
        let range = __tree_.__purified_(bounds.relative(to: __tree_))
        guard __tree_.isValidSealedRange(range) else {
          fatalError(.invalidIndex)
        }
        yield &self[unchecked: range]
      }
    }

    @inlinable
    public mutating func erase(_ bounds: UnboundedRange) {
      __tree_.ensureUnique()
      _ = ___remove(from: _start, to: _end)
    }

    @inlinable
    public mutating func erase(_ bounds: IndexRange) {
      __tree_.ensureUnique()
      let range = __tree_.__purified_(bounds.range)
      guard __tree_.isValidSealedRange(range) else {
        fatalError(.invalidIndex)
      }
      _ = ___remove(from: range.lowerBound.pointer!, to: range.upperBound.pointer!)
    }

    @inlinable
    public mutating func erase(_ bounds: IndexRangeExpression) {
      __tree_.ensureUnique()
      let range = __tree_.__purified_(bounds.relative(to: __tree_))
      guard __tree_.isValidSealedRange(range) else {
        fatalError(.invalidIndex)
      }
      _ = ___remove(from: range.lowerBound.pointer!, to: range.upperBound.pointer!)
    }

    @inlinable
    public mutating func erase(
      _ bounds: IndexRange, where shouldBeRemoved: (Element) throws -> Bool
    )
      rethrows
    {
      __tree_.ensureUnique()
      let range = __tree_.__purified_(bounds.range)
      guard __tree_.isValidSealedRange(range) else {
        fatalError(.invalidIndex)
      }
      try __tree_.___erase_if(range.lowerBound, range.upperBound, shouldBeRemoved)
    }

    @inlinable
    public mutating func erase(
      _ bounds: IndexRangeExpression, where shouldBeRemoved: (Element) throws -> Bool
    )
      rethrows
    {

      __tree_.ensureUnique()
      let range = __tree_.__purified_(bounds.relative(to: __tree_))
      guard __tree_.isValidSealedRange(range) else {
        fatalError(.invalidIndex)
      }
      try __tree_.___erase_if(range.lowerBound, range.upperBound, shouldBeRemoved)
    }
  }

  extension RedBlackTreeSet {

    @inlinable
    subscript(unchecked range: _RawRange<_SealedPtr>) -> View {
      
      @inline(__always) get {
        RedBlackTreeKeyOnlyRangeView(
          __tree_: __tree_,
          _start: range.lowerBound,
          _end: range.upperBound)
      }
      
      @inline(__always) _modify {
        var view = RedBlackTreeKeyOnlyRangeView(
          __tree_: __tree_,
          _start: range.lowerBound,
          _end: range.upperBound)
        self = RedBlackTreeSet()  // yield中のCoWキャンセル。考えた人賢い
        defer { self = RedBlackTreeSet(__tree_: view.__tree_) }
        yield &view
      }
    }
  }

#endif
