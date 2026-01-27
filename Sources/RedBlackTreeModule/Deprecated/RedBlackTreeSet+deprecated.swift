#if COMPATIBLE_ATCODER_2025

  extension RedBlackTreeSet {
    @available(*, deprecated)
    public subscript(_unsafe bounds: Range<Index>) -> SubSequence {
      .init(
        tree: __tree_,
        start: __tree_.rawValue(bounds.lowerBound),
        end: __tree_.rawValue(bounds.upperBound))
    }
  }

  // Rangeの使い方としておかしいので、便利だが将来的に削除することにした
  extension RedBlackTreeSet {

    /// 範囲 `[lower, upper)` に含まれる要素を返します。
    ///
    /// index範囲ではないことに留意
    ///
    /// **Deprecated – 以下の代替コードをご利用ください。**
    ///
    /// ```swift
    /// extension RedBlackTreeSet {
    ///   public func sequence(from start: Element, to end: Element) -> SubSequence {
    ///     self[lowerBound(start)..<lowerBound(end)]
    ///   }
    /// }
    /// ```
    @available(*, deprecated)
    public subscript(bounds: Range<Element>) -> SubSequence {
      elements(in: bounds)
    }

    /// 範囲 `[lower, upper]` に含まれる要素を返します。
    ///
    /// index範囲ではないことに留意
    ///
    /// **Deprecated – 以下の代替コードをご利用ください。**
    ///
    /// ```swift
    /// extension RedBlackTreeSet {
    ///   public func sequence(from start: Element, through end: Element) -> SubSequence {
    ///     self[lowerBound(start)..<upperBound(end)]
    ///   }
    /// }
    /// ```
    @available(*, deprecated)
    public subscript(bounds: ClosedRange<Element>) -> SubSequence {
      elements(in: bounds)
    }
  }

  extension RedBlackTreeSet {
    /// 値レンジ `[lower, upper)` に含まれる要素のスライス
    /// - Complexity: O(log *n*)
    ///
    /// **Deprecated – 以下の代替コードをご利用ください。**
    ///
    /// ```swift
    /// extension RedBlackTreeSet {
    ///   public func sequence(from start: Element, to end: Element) -> SubSequence {
    ///     self[lowerBound(start)..<lowerBound(end)]
    ///   }
    /// }
    /// ```
    @available(*, deprecated)
    public func elements(in range: Range<Element>) -> SubSequence {
      .init(
        tree: __tree_,
        start: ___lower_bound(range.lowerBound),
        end: ___lower_bound(range.upperBound))
    }

    /// 値レンジ `[lower, upper]` に含まれる要素のスライス
    /// - Complexity: O(log *n*)
    ///
    /// **Deprecated – 以下の代替コードをご利用ください。**
    ///
    /// ```swift
    /// extension RedBlackTreeSet {
    ///   public func sequence(from start: Element, through end: Element) -> SubSequence {
    ///     self[lowerBound(start)..<upperBound(end)]
    ///   }
    /// }
    /// ```
    @available(*, deprecated)
    public func elements(in range: ClosedRange<Element>) -> SubSequence {
      .init(
        tree: __tree_,
        start: ___lower_bound(range.lowerBound),
        end: ___upper_bound(range.upperBound))
    }
  }

  extension RedBlackTreeSet {

    /// - Important: 削除したメンバーを指すインデックスが無効になります。
    /// - Complexity: O(log *n* + *k*)
    @inlinable
    @inline(__always)
    public mutating func remove(contentsOf elementRange: Range<Element>) {
      __tree_._strongEnsureUnique()
      let lower = ___lower_bound(elementRange.lowerBound)
      let upper = ___lower_bound(elementRange.upperBound)
      ___remove(from: lower, to: upper)
    }

    /// - Important: 削除したメンバーを指すインデックスが無効になります。
    /// - Complexity: O(log *n* + *k*)
    @inlinable
    @inline(__always)
    public mutating func remove(contentsOf elementRange: ClosedRange<Element>) {
      __tree_._strongEnsureUnique()
      let lower = ___lower_bound(elementRange.lowerBound)
      let upper = ___upper_bound(elementRange.upperBound)
      ___remove(from: lower, to: upper)
    }
  }
#endif
