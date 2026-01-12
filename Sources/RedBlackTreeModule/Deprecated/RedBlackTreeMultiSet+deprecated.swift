#if COMPATIBLE_ATCODER_2025

  extension RedBlackTreeMultiSet {
    @available(*, deprecated)
    public subscript(_unsafe bounds: Range<Index>) -> SubSequence {
      .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue(__tree_),
        end: bounds.upperBound.rawValue(__tree_))
    }
  }

  extension RedBlackTreeMultiSet {
    @available(*, deprecated)
    public subscript(_unsafe position: Index) -> Element {
      @inline(__always) _read { yield self[_unchecked: position] }
    }
  }

  // Rangeの使い方としておかしいので、便利だが将来的に削除することにした
  extension RedBlackTreeMultiSet {

    /// 範囲 `[lower, upper)` に含まれる要素を返します。
    ///
    /// index範囲ではないことに留意
    ///
    /// **Deprecated – 以下の代替コードをご利用ください。**
    ///
    /// ```swift
    /// extension RedBlackTreeMultiSet {
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
    /// extension RedBlackTreeMultiSet {
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

  extension RedBlackTreeMultiSet {
    /// 値レンジ `[lower, upper)` に含まれる要素のスライス
    /// - Complexity: O(log *n*)
    ///
    /// **Deprecated – 以下の代替コードをご利用ください。**
    ///
    /// ```swift
    /// extension RedBlackTreeMultiSet {
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
    /// extension RedBlackTreeMultiSet {
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

  extension RedBlackTreeMultiSet {

    /// - Complexity: O(log *n* + *k*)
    @inlinable
    public mutating func remove(contentsOf elementRange: Range<Element>) {
      __tree_._strongEnsureUnique()
      let lower = ___lower_bound(elementRange.lowerBound)
      let upper = ___lower_bound(elementRange.upperBound)
      ___remove(from: lower, to: upper)
    }

    /// - Complexity: O(log *n* : *k*)
    @inlinable
    public mutating func remove(contentsOf elementRange: ClosedRange<Element>) {
      __tree_._strongEnsureUnique()
      let lower = ___lower_bound(elementRange.lowerBound)
      let upper = ___upper_bound(elementRange.upperBound)
      ___remove(from: lower, to: upper)
    }
  }

  // 予備的に用意したものと推定。これを使わないと通らない問題に出会わない場合、削除とする
  extension RedBlackTreeMultiSet {
    /// - Important: 削除したメンバーを指すインデックスが無効になります。
    /// - Complexity: O(log *n* : *k*)
    @inlinable
    @discardableResult
    public mutating func removeAll(_unsafe member: Element) -> Element? {
      __tree_._ensureUnique()
      return __tree_.___erase_multi(member) != 0 ? member : nil
    }
  }
#endif
