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
    public typealias IndexRange = UnsafeIndexV3RangeExpression

    @inlinable
    public func isValid(_ bounds: UnboundedRange) -> Bool {
      true
    }

    @inlinable
    public func isValid(_ bounds: IndexRange) -> Bool {
      let (l, u) = bounds.relative(to: __tree_)
      return l.isValid && u.isValid
    }

    @inlinable
    public subscript(bounds: UnboundedRange) -> View {
      @inline(__always) get {
        self[unchecked: _sealed_start, _sealed_end]
      }
      @inline(__always) _modify {
        yield &self[unchecked: _sealed_start, _sealed_end]
      }
    }

    @inlinable
    public subscript(bounds: IndexRange) -> View {
      @inline(__always) get {
        let (lower, upper) = bounds.relative(to: __tree_)
        guard __tree_.isValidSealedRange(lower: lower, upper: upper) else {
          fatalError(.invalidIndex)
        }
        return self[unchecked: lower, upper]
      }
      @inline(__always) _modify {
        let (lower, upper) = bounds.relative(to: __tree_)
        guard __tree_.isValidSealedRange(lower: lower, upper: upper) else {
          fatalError(.invalidIndex)
        }
        yield &self[unchecked: lower, upper]
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
      let (lower, upper) = bounds.relative(to: __tree_)
      _ = ___remove(from: lower.pointer!, to: upper.pointer!)
    }

    @inlinable
    public mutating func erase(
      _ bounds: IndexRange, where shouldBeRemoved: (Element) throws -> Bool
    )
      rethrows
    {

      __tree_.ensureUnique()
      let (lower, upper) = bounds.relative(to: __tree_)
      guard __tree_.isValidSealedRange(lower: lower, upper: upper) else {
        fatalError(.invalidIndex)
      }
      try __tree_.___erase_if(lower, upper, shouldBeRemoved: shouldBeRemoved)
    }
  }

  extension RedBlackTreeSet {

    @inlinable
    subscript(unchecked _start: _SealedPtr, _end: _SealedPtr) -> View {
      @inline(__always) get {
        .init(__tree_: __tree_, _start: _start, _end: _end)
      }
      @inline(__always) _modify {
        var view = RedBlackTreeKeyOnlyRangeView(__tree_: __tree_, _start: _start, _end: _end)
        self = RedBlackTreeSet()  // yield中のCoWキャンセル。考えた人賢い
        defer { self = RedBlackTreeSet(__tree_: view.__tree_) }
        yield &view
      }
    }
  }

#endif
