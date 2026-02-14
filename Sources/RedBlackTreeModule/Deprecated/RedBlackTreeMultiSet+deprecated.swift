#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet: _RedBlackTreeKeyOnlyBase {}
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    /// - Complexity: O(*n* log *n* + *n*)
    @inlinable
    public init<Source>(_ sequence: __owned Source)
    where Element == Source.Element, Source: Sequence {
      self.init(__tree_: .create_multi(sorted: sequence.sorted()))
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  // MARK: - Init naive

  extension RedBlackTreeMultiSet {

    /// - Complexity: O(*n* log *n*)
    ///
    /// 省メモリでの初期化
    @inlinable
    public init<Source>(naive sequence: __owned Source)
    where Element == Source.Element, Source: Sequence {
      self.init(__tree_: .create_multi(naive: sequence))
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    /// - Complexity: O(*n*)
    @inlinable
    public func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
      for __c in __tree_.sequence(_sealed_start, _sealed_end) {
        let __e = __tree_[_unsafe_raw: __c]
        if try predicate(__e) {
          return __e
        }
      }
      return nil
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet: Collection, BidirectionalCollection {}
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    /// - Complexity: O(log *n*)
    @inlinable
    public func equalRange(_ element: Element) -> (lower: Index, upper: Index) {
      ___index_equal_range(element)
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func reversed() -> Tree._PayloadValues.Reversed {
      _reversed()
    }
  }

  extension RedBlackTreeMultiSet {

    /// - Important:
    ///  要素及びノードが削除された場合、インデックスは無効になります。
    /// 無効なインデックスを使用するとランタイムエラーや不正な参照が発生する可能性があるため注意してください。
    public
      typealias Index = Tree.Index
  }

  extension RedBlackTreeMultiSet {

    /// - Complexity: O(*d* + log *n*)
    @inlinable
    //  @inline(__always)
    public func distance(from start: Index, to end: Index) -> Int {
      _distance(from: start, to: end)
    }
  }

  extension RedBlackTreeMultiSet {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var startIndex: Index { _startIndex }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var endIndex: Index { _endIndex }
  }

  extension RedBlackTreeMultiSet {

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

    /// - Complexity: O(*d*)
    @inlinable
    //  @inline(__always)
    public func index(_ i: Index, offsetBy distance: Int) -> Index {
      _index(i, offsetBy: distance)
    }

    /// - Complexity: O(*d*)
    @inlinable
    //  @inline(__always)
    public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
      _index(i, offsetBy: distance, limitedBy: limit)
    }
  }

  extension RedBlackTreeMultiSet {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func formIndex(before i: inout Index) {
      _formIndex(before: &i)
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
    public func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Index)
      -> Bool
    {
      _formIndex(&i, offsetBy: distance, limitedBy: limit)
    }
  }

  extension RedBlackTreeMultiSet {

    /// - Complexity: O(log *n*)
    @inlinable
    public func lowerBound(_ member: Element) -> Index {
      ___index_lower_bound(member)
    }

    /// - Complexity: O(log *n*)
    @inlinable
    public func upperBound(_ member: Element) -> Index {
      ___index_upper_bound(member)
    }
  }

  extension RedBlackTreeMultiSet {

    /// - Complexity: O(log *n*)
    @inlinable
    public func firstIndex(of member: Element) -> Index? {
      ___first_index(of: member)
    }

    /// - Complexity: O(*n*)
    @inlinable
    public func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Index? {
      for __c in __tree_.sequence(_sealed_start, _sealed_end) {
        if try predicate(__tree_[_unsafe_raw: __c]) {
          return ___index(__c.sealed)
        }
      }
      return nil
    }
  }

  extension RedBlackTreeMultiSet {

    /// - Complexity: O(1)
    @inlinable
    public subscript(position: Index) -> Element {
      @inline(__always) _read {
        yield __tree_[_unsafe: __tree_.__purified_(position)]
      }
    }
  }

  extension RedBlackTreeMultiSet {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public subscript(bounds: Range<Index>) -> SubSequence {
      return .init(
        tree: __tree_,
        start: __tree_.__purified_(bounds.lowerBound),
        end: __tree_.__purified_(bounds.upperBound))
    }
  }

  extension RedBlackTreeMultiSet {

    /// - Important: 削除後は、インデックスが無効になります。
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    @discardableResult
    public mutating func remove(at index: Index) -> Element {
      __tree_.ensureUnique()
      guard case .success(let __p) = __tree_.__purified_(index) else {
        fatalError(.invalidIndex)
      }
      return _unchecked_remove(at: __p.pointer).payload
    }
  }

  extension RedBlackTreeMultiSet {

    /// Indexがsubscriptやremoveで利用可能か判別します
    ///
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func isValid(index: Index) -> Bool {
      _isValid(index: index)
    }
  }

  extension RedBlackTreeMultiSet {
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

  extension RedBlackTreeMultiSet {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var indices: Indices {
      _indices
    }
  }

  // MARK: - SubSequence: Sequence

  extension RedBlackTreeMultiSet {

    public typealias SubSequence = RedBlackTreeSliceV2<Self>.KeyOnly
  }

  // MARK: - Index Range

  extension RedBlackTreeMultiSet {

    public typealias Indices = Tree.Indices
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    @inlinable
    @inline(__always)
    public func forEach(_ body: (_PayloadValue) throws -> Void) rethrows {
      try _forEach(body)
    }
  }

  extension RedBlackTreeMultiSet {
    /// 特殊なforEach
    @inlinable
    @inline(__always)
    public func forEach(_ body: (Index, _PayloadValue) throws -> Void) rethrows {
      try _forEach(body)
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025

  extension RedBlackTreeMultiSet {
    @available(*, deprecated)
    public subscript(_unsafe bounds: Range<Index>) -> SubSequence {
      .init(
        tree: __tree_,
        start: __tree_.__purified_(bounds.lowerBound),
        end: __tree_.__purified_(bounds.upperBound))
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
        start: __tree_.lower_bound(range.lowerBound).sealed,
        end: __tree_.lower_bound(range.upperBound).sealed)
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
        start: __tree_.lower_bound(range.lowerBound).sealed,
        end: __tree_.upper_bound(range.upperBound).sealed)
    }
  }

  extension RedBlackTreeMultiSet {

    /// - Complexity: O(log *n* + *k*)
    @inlinable
    public mutating func remove(contentsOf elementRange: Range<Element>) {
      __tree_._strongEnsureUnique()
      let lower = __tree_.lower_bound(elementRange.lowerBound)
      let upper = __tree_.lower_bound(elementRange.upperBound)
      ___remove(from: lower, to: upper)
    }

    /// - Complexity: O(log *n* : *k*)
    @inlinable
    public mutating func remove(contentsOf elementRange: ClosedRange<Element>) {
      __tree_._strongEnsureUnique()
      let lower = __tree_.lower_bound(elementRange.lowerBound)
      let upper = __tree_.upper_bound(elementRange.upperBound)
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
      __tree_.ensureUnique()
      return __tree_.___erase_multi(member) != 0 ? member : nil
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {
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
        from: __tree_.__purified_(bounds.lowerBound).pointer!,
        to: __tree_.__purified_(bounds.upperBound).pointer!)
    }
  }
#endif
