#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet: Collection, BidirectionalCollection {}
#endif

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

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public subscript(bounds: Range<Index>) -> SubSequence {
      __tree_.___ensureValid(
        begin: __tree_.rawValue(bounds.lowerBound),
        end: __tree_.rawValue(bounds.upperBound))

      return .init(
        tree: __tree_,
        start: __tree_.rawValue(bounds.lowerBound),
        end: __tree_.rawValue(bounds.upperBound))
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {
    /// Removes the specified subrange of elements from the collection.
    ///
    /// - Important: 削除後は、subrangeのインデックスが無効になります。
    /// - Parameter bounds: The subrange of the collection to remove. The bounds of the
    ///     range must be valid indices of the collection.
    /// - Returns: The key-value pair that correspond to `index`.
    /// - Complexity: O(`m ) where  `m` is the size of `bounds`
    @inlinable
    public mutating func removeSubrange<R: RangeExpression>(
      _ bounds: R
    ) where R.Bound == Index {

      let bounds = bounds.relative(to: self)
      __tree_.ensureUnique()
      ___remove(
        from: __tree_.rawValue(bounds.lowerBound),
        to: __tree_.rawValue(bounds.upperBound))
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  /// RangeExpressionがsubscriptやremoveで利用可能か判別します
  ///
  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func isValid<R: RangeExpression>(_ bounds: R) -> Bool
  where R.Bound == Index {
    _isValid(bounds)
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {
    /// 特殊なforEach
    @inlinable
    @inline(__always)
    public func forEach(_ body: (Index, Element) throws -> Void) rethrows {
      try _forEach(body)
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {
    /// - Important: 削除したメンバーを指すインデックスが無効になります。
    /// - Complexity: O(log *n*), where *n* is the number of elements.
    @available(*, deprecated)
    @inlinable
    @discardableResult
    public mutating func removeLast() -> Element {
      __tree_.ensureUnique()
      guard let element = ___remove_last() else {
        preconditionFailure(.emptyLast)
      }
      return element.payload
    }
  }
#endif
