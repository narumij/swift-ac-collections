#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet: Collection, BidirectionalCollection {}
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {
    @available(*, deprecated)
    public subscript(_unsafe bounds: Range<Index>) -> SubSequence {
      .init(
        tree: __tree_,
        start: __tree_._remap_to_safe_(bounds.lowerBound),
        end: __tree_._remap_to_safe_(bounds.upperBound))
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
        start: __tree_.lower_bound(range.lowerBound).sealed,
        end: __tree_.lower_bound(range.upperBound).sealed)
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
        start: __tree_.lower_bound(range.lowerBound).sealed,
        end: __tree_.upper_bound(range.upperBound).sealed)
    }
  }

  extension RedBlackTreeSet {

    /// - Important: 削除したメンバーを指すインデックスが無効になります。
    /// - Complexity: O(log *n* + *k*)
    @inlinable
    @inline(__always)
    public mutating func remove(contentsOf elementRange: Range<Element>) {
      __tree_._strongEnsureUnique()
      let lower = __tree_.lower_bound(elementRange.lowerBound)
      let upper = __tree_.lower_bound(elementRange.upperBound)
      ___remove(from: lower, to: upper)
    }

    /// - Important: 削除したメンバーを指すインデックスが無効になります。
    /// - Complexity: O(log *n* + *k*)
    @inlinable
    @inline(__always)
    public mutating func remove(contentsOf elementRange: ClosedRange<Element>) {
      __tree_._strongEnsureUnique()
      let lower = __tree_.lower_bound(elementRange.lowerBound)
      let upper = __tree_.upper_bound(elementRange.upperBound)
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
      return .init(
        tree: __tree_,
        start: __tree_._remap_to_safe_(bounds.lowerBound),
        end: __tree_._remap_to_safe_(bounds.upperBound))
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
      from: __tree_._remap_to_safe_(bounds.lowerBound).pointer!,
      to: __tree_._remap_to_safe_(bounds.upperBound).pointer!)
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {
    /// RangeExpressionがsubscriptやremoveで利用可能か判別します
    ///
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func isValid<R: RangeExpression>(_ bounds: R) -> Bool
    where R.Bound == Index {
      _isValid(bounds)
    }
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
    /// - Complexity: O(1)
    // @available(*, deprecated, renamed: "popMin")
    @inlinable
    //  @inline(__always)
    public mutating func popFirst() -> Element? {
      __tree_.ensureUnique()
      return ___remove_first()?.payload
    }
  }

  extension RedBlackTreeSet {
    /// - Important: 削除したメンバーを指すインデックスが無効になります。
    /// - Complexity: O(log *n*), where *n* is the number of elements.
    // @available(*, deprecated)
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

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

    /// - Important:
    ///  要素及びノードが削除された場合、インデックスは無効になります。
    /// 無効なインデックスを使用するとランタイムエラーや不正な参照が発生する可能性があるため注意してください。
    public
      typealias Index = Tree.Index
  }

  extension RedBlackTreeSet {

    /// - Complexity: O(log *n*), where *n* is the number of elements.
    @inlinable
    public func firstIndex(of member: Element) -> Index? {
      ___first_index(of: member)
    }

    /// - Complexity: O(*n*), where *n* is the number of elements.
    @inlinable
    public func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Index? {
      try ___first_index(where: predicate)
    }
  }

  extension RedBlackTreeSet {

    /// - Important: 削除後は、インデックスが無効になります。
    /// - Complexity: O(1)
    @inlinable
    @discardableResult
    public mutating func remove(at index: Index) -> Element {
      __tree_.ensureUnique()
      guard case .success(let __p) = __tree_._remap_to_safe_(index).unchecked_pointer else {
        fatalError(.invalidIndex)
      }
      return _unchecked_remove(at: __p).payload
    }
  }

  // MARK: Finding Elements

  extension RedBlackTreeSet {

    /// `lowerBound(_:)` は、指定した要素 `member` 以上の値が格納されている
    /// 最初の位置（`Index`）を返します。
    ///
    /// たとえば、ソートされた `[1, 3, 5, 7, 9]` があるとき、
    /// - `lowerBound(0)` は最初の要素 `1` の位置を返します。（つまり `startIndex`）
    /// - `lowerBound(3)` は要素 `3` の位置を返します。
    /// - `lowerBound(4)` は要素 `5` の位置を返します。（`4` 以上で最初に出現する値が `5`）
    /// - `lowerBound(10)` は `endIndex` を返します。
    ///
    /// - Parameter member: 二分探索で検索したい要素
    /// - Returns: 指定した要素 `member` 以上の値が格納されている先頭の `Index`
    /// - Complexity: O(log *n*), where *n* is the number of elements.
    @inlinable
    public func lowerBound(_ member: Element) -> Index {
      ___index_lower_bound(member)
    }

    /// `upperBound(_:)` は、指定した要素 `member` より大きい値が格納されている
    /// 最初の位置（`Index`）を返します。
    ///
    /// たとえば、ソートされた `[1, 3, 5, 5, 7, 9]` があるとき、
    /// - `upperBound(3)` は要素 `5` の位置を返します。
    ///   （`3` より大きい値が最初に現れる場所）
    /// - `upperBound(5)` は要素 `7` の位置を返します。
    ///   （`5` と等しい要素は含まないため、`5` の直後）
    /// - `upperBound(9)` は `endIndex` を返します。
    ///
    /// - Parameter member: 二分探索で検索したい要素
    /// - Returns: 指定した要素 `member` より大きい値が格納されている先頭の `Index`
    /// - Complexity: O(log *n*), where *n* is the number of elements.
    @inlinable
    public func upperBound(_ member: Element) -> Index {
      ___index_upper_bound(member)
    }
  }

  extension RedBlackTreeSet {

    /// - Complexity: O(log *n*), where *n* is the number of elements.
    @inlinable
    public func equalRange(_ element: Element) -> (lower: Index, upper: Index) {
      ___index_equal_range(element)
    }
  }

  extension RedBlackTreeSet {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var startIndex: Index { _startIndex }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var endIndex: Index { _endIndex }

    /// - Complexity: O(*d* + log *n*)
    @inlinable
    //  @inline(__always)
    public func distance(from start: Index, to end: Index) -> Int {
      _distance(from: start, to: end)
    }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func index(after i: Index) -> Index {
      _index(after: i)
    }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func formIndex(after i: inout Index) {
      _formIndex(after: &i)
    }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func index(before i: Index) -> Index {
      _index(before: i)
    }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func formIndex(before i: inout Index) {
      _formIndex(before: &i)
    }

    /// - Complexity: O(*d*)
    @inlinable
    //  @inline(__always)
    public func index(_ i: Index, offsetBy distance: Int) -> Index {
      _index(i, offsetBy: distance)
    }

    /// - Complexity: O(*d*)
    @inlinable
    //  @inline(__always)
    public func formIndex(_ i: inout Index, offsetBy distance: Int) {
      _formIndex(&i, offsetBy: distance)
    }

    /// - Complexity: O(*d*)
    @inlinable
    //  @inline(__always)
    public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
      _index(i, offsetBy: distance, limitedBy: limit)
    }

    /// - Complexity: O(*d*)
    @inlinable
    //  @inline(__always)
    public func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Index)
      -> Bool
    {
      _formIndex(&i, offsetBy: distance, limitedBy: limit)
    }

    /// - Complexity: O(1)
    @inlinable
    public subscript(position: Index) -> Element {
      @inline(__always) _read { yield self[_checked: position] }
    }

    /// Indexがsubscriptやremoveで利用可能か判別します
    ///
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func isValid(index: Index) -> Bool {
      _isValid(index: index)
    }
  }

  extension RedBlackTreeSet {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var indices: Indices {
      _indices
    }
  }

  extension RedBlackTreeSet {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func reversed() -> Tree._PayloadValues.Reversed {
      _reversed()
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
// MARK: - SubSequence

extension RedBlackTreeSet {

  public typealias SubSequence = RedBlackTreeSliceV2<Base>.KeyOnly
}

// MARK: - Index Range

extension RedBlackTreeSet {

  public typealias Indices = Tree.Indices
}
#endif
