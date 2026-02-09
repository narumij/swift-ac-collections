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
  extension RedBlackTreeMultiSet {

    // Swiftの段階的開示という哲学にしたがうと、ポインターよりこちらの方がましな気がする
    @inlinable
    public subscript(bound: RedBlackTreeBoundExpression<Element>) -> Element? {
      let p = bound.relative(to: __tree_)
      guard let p = try? p.get().pointer, !p.___is_end else { return nil }
      return __tree_[_unsafe_raw: p]
    }

    // Swiftの段階的開示という哲学にしたがうと、ポインターよりこちらの方がましな気がする
    public mutating func remove(_ bound: RedBlackTreeBoundExpression<Element>) -> Element? {
      __tree_.ensureUnique()
      let p = bound.relative(to: __tree_)
      guard let p = try? p.get().pointer, !p.___is_end else { return nil }
      return _unchecked_remove(at: p).payload
    }

    public func sealedTag(_ bound: RedBlackTreeBoundExpression<Element>)
      -> _SealedTag?
    {
      let p = bound.relative(to: __tree_)
      guard let p = try? p.get().pointer, !p.___is_end else { return nil }
      return .taggedSeal(p)
    }

    // MARK: -

    public func count(
      _ bounds: RedBlackTreeBoundRangeExpression<Element>
    )
      -> Int?
    {
      guard let d = distance(bounds), d >= 0 else {
        return nil
      }
      return d
    }

    public func distance(
      _ bounds: RedBlackTreeBoundRangeExpression<Element>
    )
      -> Int?
    {
      let (lower, upper) = bounds.relative(to: __tree_)
      return __tree_.___distance(from: lower, to: upper)
    }

    public subscript(bounds: RedBlackTreeBoundRangeExpression<Element>)
      -> RedBlackTreeKeyOnlyRangeView<Self>
    {
      @inline(__always) get {
        let (lower, upper) = __tree_.sanitizeSealedRange(bounds.relative(to: __tree_))
        return .init(__tree_: __tree_, _start: lower, _end: upper)
      }
      @inline(__always) _modify {
        let (lower, upper) = __tree_.sanitizeSealedRange(bounds.relative(to: __tree_))
        var view = RedBlackTreeKeyOnlyRangeView(__tree_: __tree_, _start: lower, _end: upper)
        self = RedBlackTreeMultiSet()  // yield中のCoWキャンセル。考えた人賢い
        defer { self = RedBlackTreeMultiSet(__tree_: view.__tree_) }
        yield &view
      }
    }

    public mutating func removeAll(in bounds: RedBlackTreeBoundRangeExpression<Element>) {
      __tree_.ensureUnique()
      let (lower, upper) = bounds.relative(to: __tree_)
      guard __tree_.isValidSealedRange(lower: lower, upper: upper) else {
        fatalError(.invalidIndex)
      }
      __tree_.___checking_erase(lower.pointer!, upper.pointer!)
    }

    public mutating func removeAll(
      in bounds: RedBlackTreeBoundRangeExpression<Element>,
      where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows {
      __tree_.ensureUnique()
      let (lower, upper) = bounds.relative(to: __tree_)
      guard __tree_.isValidSealedRange(lower: lower, upper: upper) else {
        fatalError(.invalidIndex)
      }
      try __tree_.___checking_erase_if(
        lower.pointer!, upper.pointer!, shouldBeRemoved: shouldBeRemoved)
    }
  }
#endif
