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
    public typealias Bound = RedBlackTreeBoundExpression<Element>
    public typealias BoundRange = RedBlackTreeBoundRangeExpression<Element>
  }

  extension RedBlackTreeSet {

    /// 該当する要素を取得可能かどうかの判定結果を返す
    @inlinable
    public func isValid(_ bound: Bound) -> Bool {
      let sealed = bound.relative(to: __tree_)
      return sealed.isValid && !sealed.___is_end!
    }
  }

  extension RedBlackTreeSet {

    // 実は辞書の派生型という位置づけが自然な気もする

    /// 要素の位置に該当する要素を取得する
    ///
    /// 要素位置を評価した結果が末尾の次や失敗の場合、nilを返す
    ///
    @inlinable
    public subscript(bound: Bound) -> Element? {
      let p = bound.relative(to: __tree_)
      guard let p = try? p.get().pointer, !p.___is_end else { return nil }
      return __tree_[_unsafe_raw: p]
    }
  }

  extension RedBlackTreeSet {

    @inlinable
    public mutating func erase(_ bound: Bound) -> Element? {
      __tree_.ensureUnique()
      let p = bound.relative(to: __tree_)
      guard let p = try? p.get().pointer, !p.___is_end else { return nil }
      return _unchecked_remove(at: p).payload
    }
  }

  extension RedBlackTreeSet {

    // MARK: -

    @inlinable
    public func count(_ bounds: BoundRange) -> Int? {

      guard let d = distance(bounds), d >= 0 else {
        return nil
      }
      return d
    }

    @inlinable
    public func distance(_ bounds: BoundRange) -> Int? {

      let (lower, upper) = bounds.relative(to: __tree_)
      return __tree_.___distance(from: lower, to: upper)
    }
  }

  extension RedBlackTreeSet {

    @inlinable
    public mutating func erase(_ bounds: BoundRange) {

      __tree_.ensureUnique()
      let (lower, upper) = bounds.relative(to: __tree_)
      guard __tree_.isValidSealedRange(lower: lower, upper: upper) else {
        fatalError(.invalidIndex)
      }
      __tree_.___erase(lower.pointer!, upper.pointer!)
    }

    @inlinable
    public mutating func erase(
      _ bounds: BoundRange, where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows {

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
    public subscript(bounds: BoundRange) -> View {

      @inline(__always) get {
        let (lower, upper) = __tree_.sanitizeSealedRange(bounds.relative(to: __tree_))
        return .init(__tree_: __tree_, _start: lower, _end: upper)
      }
      @inline(__always) _modify {
        let (lower, upper) = __tree_.sanitizeSealedRange(bounds.relative(to: __tree_))
        var view = RedBlackTreeKeyOnlyRangeView(__tree_: __tree_, _start: lower, _end: upper)
        self = RedBlackTreeSet()  // yield中のCoWキャンセル。考えた人賢い
        defer { self = RedBlackTreeSet(__tree_: view.__tree_) }
        yield &view
      }
    }
  }
#endif

#if DEBUG
  extension RedBlackTreeSet {

    package func _withSealed<R>(
      _ b: RedBlackTreeBoundExpression<Element>,
      _ body: (_SealedPtr) throws -> R
    ) rethrows -> R {
      let b = b.relative(to: __tree_)
      return try body(b)
    }

    package func _withSealed<R>(
      _ a: RedBlackTreeBoundExpression<Element>,
      _ b: RedBlackTreeBoundExpression<Element>,
      _ body: (_SealedPtr, _SealedPtr) throws -> R
    ) rethrows -> R {
      let a = a.relative(to: __tree_)
      let b = b.relative(to: __tree_)
      return try body(a, b)
    }
  }

  extension RedBlackTreeSet {

    package func _isEqual(
      _ l: RedBlackTreeBoundExpression<Element>,
      _ r: RedBlackTreeBoundExpression<Element>
    ) -> Bool {
      let l = l.relative(to: __tree_)
      let r = r.relative(to: __tree_)
      return l == r
    }

    package func _error(_ bound: RedBlackTreeBoundExpression<Element>) -> SealError? {
      bound.relative(to: __tree_).error
    }
  }
#endif
