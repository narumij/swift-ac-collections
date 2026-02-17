#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {
    public
      typealias KeyValue = (key: Key, value: Value)
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap: _RedBlackTreeKeyValuesBase {}
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {

    /// - Complexity: O(*n* log *n* + *n*)
    @inlinable
    public init<S>(multiKeysWithValues keysAndValues: __owned S)
    where S: Sequence, S.Element == (Key, Value) {
      self.init(
        __tree_:
          .create_multi(sorted: keysAndValues.sorted { $0.0 < $1.0 }) {
            Self.__payload_($0)
          })
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  // MARK: - Init naive

  extension RedBlackTreeMultiMap {

    /// - Complexity: O(*n* log *n*)
    ///
    /// 省メモリでの初期化
    @inlinable
    public init<Source>(naive sequence: __owned Source)
    where Element == Source.Element, Source: Sequence {
      self.init(__tree_: .create_multi(naive: sequence, transform: Self.__payload_))
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {

    /// - Complexity: O(log *n*)
    @inlinable
    public func values(forKey key: Key) -> Values {
      let (lo, hi) = __tree_.__equal_range_multi(key)
      return .init(start: lo.sealed, end: hi.sealed, tie: __tree_.tied)
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {

    /// - Complexity: O(*n* log(*m + n*))
    @inlinable
    @inline(__always)
    public static func + (lhs: Self, rhs: Self) -> Self {
      lhs.inserting(contentsOf: rhs)
    }

    /// - Complexity: O(*n* log(*m + n*))
    @inlinable
    @inline(__always)
    public static func += (lhs: inout Self, rhs: Self) {
      lhs.insert(contentsOf: rhs)
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {

    /// - Complexity: O(*n*), where *n* is the number of elements.
    @inlinable
    public func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
      for __c in __tree_.sequence(_sealed_start, _sealed_end) {
        let __e = Base.__element_(__tree_[_unsafe_raw: __c])
        if try predicate(__e) {
          return __e
        }
      }
      return nil
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {

    /// - Important: 削除したメンバーを指すインデックスが無効になります。
    /// - Complexity: O(log *n*)
    @inlinable
    @discardableResult
    public mutating func removeFirst(forKey key: Key) -> Bool {
      __tree_._strongEnsureUnique()
      return __tree_.___erase_unique(key)
    }

    /// - Important: 削除したメンバーを指すインデックスが無効になります。
    /// - Complexity: O(log *n*)
    @inlinable
    @discardableResult
    public mutating func removeFirst(_unsafeForKey key: Key) -> Bool {
      __tree_.ensureUnique()
      return __tree_.___erase_unique(key)
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap: Collection, BidirectionalCollection {}
#endif

// MARK: - Range Accessing Keys and Values

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {

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
#endif

#if COMPATIBLE_ATCODER_2025

  // MARK: Finding Elements

  extension RedBlackTreeMultiMap {

    /// - Complexity: O(log *n*)
    @inlinable
    public func lowerBound(_ p: Key) -> Index {
      ___index_lower_bound(p)
    }

    /// - Complexity: O(log *n*)
    @inlinable
    public func upperBound(_ p: Key) -> Index {
      ___index_upper_bound(p)
    }
  }

  extension RedBlackTreeMultiMap {

    /// - Complexity: O(log *n*)
    @inlinable
    public func equalRange(_ key: Key) -> (lower: Index, upper: Index) {
      ___index_equal_range(key)
    }
  }

  extension RedBlackTreeMultiMap {

    /// - Complexity: O(log *n*)
    @inlinable
    public func firstIndex(of key: Key) -> Index? {
      ___first_index(of: key)
    }

    /// - Complexity: O(*n*)
    @inlinable
    public func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Index? {
      try ___first_index(where: predicate)
    }
  }

  extension RedBlackTreeMultiMap {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func reversed() -> Tree._KeyValues.Reversed {
      _reversed()
    }
  }

  extension RedBlackTreeMultiMap {
    /// - Important:
    ///  要素及びノードが削除された場合、インデックスは無効になります。
    /// 無効なインデックスを使用するとランタイムエラーや不正な参照が発生する可能性があるため注意してください。
    public typealias Index = Tree.Index
  }

  extension RedBlackTreeMultiMap {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var startIndex: Index { _startIndex }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var endIndex: Index { _endIndex }
  }

  extension RedBlackTreeMultiMap {

    /// - Complexity: O(*d* + log *n*)
    @inlinable
    //  @inline(__always)
    public func distance(from start: Index, to end: Index) -> Int {
      _distance(from: start, to: end)
    }
  }

  extension RedBlackTreeMultiMap {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func index(after i: Index) -> Index {
      _index(after: i)
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

  extension RedBlackTreeMultiMap {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func formIndex(after i: inout Index) {
      _formIndex(after: &i)
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

  extension RedBlackTreeMultiMap {

    /*
     コメントアウトの多さはテストコードのコンパイラクラッシュに由来する。
     */

    /// - Complexity: O(1)
    @inlinable
    //  public subscript(position: Index) -> Element {
    public subscript(position: Index) -> (key: Key, value: Value) {
      //    @inline(__always) get { ___element(self[_checked: position]) }
      @inline(__always) get { self[_checked: position] }
    }

    /// Indexがsubscriptやremoveで利用可能か判別します
    ///
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func isValid(index: Index) -> Bool {
      _isValid(index: index)
    }

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
  }

  extension RedBlackTreeMultiMap {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var indices: Indices {
      _indices
    }
  }

  extension RedBlackTreeMultiMap {

    public typealias SubSequence = RedBlackTreeSliceV2<Self>.KeyValue
  }

  // MARK: - Index Range

  extension RedBlackTreeMultiMap {

    public typealias Indices = Tree.Indices
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {

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

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {

    @inlinable
    @inline(__always)
    public func forEach(_ body: (Element) throws -> Void) rethrows {
      try _forEach(body)
    }

    /// 特殊なforEach
    @inlinable
    @inline(__always)
    public func forEach(_ body: (Index, Element) throws -> Void) rethrows {
      try _forEach(body)
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025

  extension RedBlackTreeMultiMap {
    @available(*, deprecated)
    public subscript(_unsafe bounds: Range<Index>) -> SubSequence {
      .init(
        tree: __tree_,
        start: __tree_.__purified_(bounds.lowerBound),
        end: __tree_.__purified_(bounds.upperBound))
    }
  }

  extension RedBlackTreeMultiMap {
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func keys() -> Keys {
      _keys()
    }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func values() -> Values {
      .init(start: _sealed_start, end: _sealed_end, tie: __tree_.tied)
    }
  }

  // Rangeの使い方としておかしいので、便利だが将来的に削除することにした
  extension RedBlackTreeMultiMap {

    /// 範囲 `[lower, upper)` に含まれる要素を返します。
    ///
    /// index範囲ではないことに留意
    ///
    /// **Deprecated – 以下の代替コードをご利用ください。**
    ///
    /// ```swift
    /// extension RedBlackTreeMultiMap {
    ///   public func sequence(from start: Key, to end: Key) -> SubSequence {
    ///     self[lowerBound(start)..<lowerBound(end)]
    ///   }
    /// }
    /// ```
    @available(*, deprecated)
    public subscript(bounds: Range<Key>) -> SubSequence {
      elements(in: bounds)
    }

    /// 範囲 `[lower, upper]` に含まれる要素を返します。
    ///
    /// index範囲ではないことに留意
    ///
    /// **Deprecated – 以下の代替コードをご利用ください。**
    ///
    /// ```swift
    /// extension RedBlackTreeMultiMap {
    ///   public func sequence(from start: Key, through end: Key) -> SubSequence {
    ///     self[lowerBound(start)..<upperBound(end)]
    ///   }
    /// }
    /// ```
    @available(*, deprecated)
    public subscript(bounds: ClosedRange<Key>) -> SubSequence {
      elements(in: bounds)
    }
  }

  extension RedBlackTreeMultiMap {
    /// キーレンジ `[lower, upper)` に含まれる要素のスライス
    /// - Complexity: O(log *n*)
    ///
    /// **Deprecated – 以下の代替コードをご利用ください。**
    ///
    /// ```swift
    /// extension RedBlackTreeMultiMap {
    ///   public func sequence(from start: Key, to end: Key) -> SubSequence {
    ///     self[lowerBound(start)..<lowerBound(end)]
    ///   }
    /// }
    /// ```
    @available(*, deprecated)
    public func elements(in range: Range<Key>) -> SubSequence {
      .init(
        tree: __tree_,
        start: __tree_.lower_bound(range.lowerBound).sealed,
        end: __tree_.lower_bound(range.upperBound).sealed)
    }

    /// キーレンジ `[lower, upper]` に含まれる要素のスライス
    /// - Complexity: O(log *n*)
    ///
    /// **Deprecated – 以下の代替コードをご利用ください。**
    ///
    /// ```swift
    /// extension RedBlackTreeMultiMap {
    ///   public func sequence(from start: Key, through end: Key) -> SubSequence {
    ///     self[lowerBound(start)..<upperBound(end)]
    ///   }
    /// }
    /// ```
    @available(*, deprecated)
    public func elements(in range: ClosedRange<Key>) -> SubSequence {
      .init(
        tree: __tree_,
        start: __tree_.lower_bound(range.lowerBound).sealed,
        end: __tree_.upper_bound(range.upperBound).sealed)
    }
  }

  extension RedBlackTreeMultiMap {

    /// - Complexity: O(log *n* + *k*)
    @inlinable
    @inline(__always)
    public mutating func remove(contentsOf keyRange: Range<Key>) {
      __tree_._strongEnsureUnique()
      let lower = __tree_.lower_bound(keyRange.lowerBound)
      let upper = __tree_.lower_bound(keyRange.upperBound)
      ___remove(from: lower, to: upper)
    }

    /// - Complexity: O(log *n* + *k*)
    @inlinable
    @inline(__always)
    public mutating func remove(contentsOf keyRange: ClosedRange<Key>) {
      __tree_._strongEnsureUnique()
      let lower = __tree_.lower_bound(keyRange.lowerBound)
      let upper = __tree_.upper_bound(keyRange.upperBound)
      ___remove(from: lower, to: upper)
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {

    // TODO: イテレータ利用の注意をドキュメントすること
    /// - Important: 削除したメンバーを指すインデックスが無効になります。
    /// - Complexity: O(log *n* + *k*)
    @inlinable
    @discardableResult
    public mutating func removeAll(forKey key: Key) -> Int {
      __tree_._strongEnsureUnique()
      return __tree_.___erase_multi(key)
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {

    /// - Complexity: O(log *n*)
    @inlinable
    @inline(__always)
    public subscript(key: Key) -> SubSequence {
      let (lo, hi): (_NodePtr, _NodePtr) = self.___equal_range(key)
      return .init(tree: __tree_, start: lo.sealed, end: hi.sealed)
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  // 便利止まりだし、標準にならうと不自然なので、将来的に削除する
  extension RedBlackTreeMultiMap where Value: Equatable {

    /// - Complexity: O(*m*), where *m* is the lesser of the length of the
    ///   sequence and the length of `other`.
    @inlinable
    @inline(__always)
    public func elementsEqual<OtherSequence>(_ other: OtherSequence) -> Bool
    where OtherSequence: Sequence, Element == OtherSequence.Element {
      elementsEqual(other, by: ==)
    }
  }

  // 便利止まりだし、標準にならうと不自然なので、将来的に削除する
  extension RedBlackTreeMultiMap where Value: Comparable {

    /// - Complexity: O(*m*), where *m* is the lesser of the length of the
    ///   sequence and the length of `other`.
    @inlinable
    @inline(__always)
    public func lexicographicallyPrecedes<OtherSequence>(_ other: OtherSequence) -> Bool
    where OtherSequence: Sequence, Element == OtherSequence.Element {
      lexicographicallyPrecedes(other, by: <)
    }
  }
#endif
