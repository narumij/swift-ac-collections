#if COMPATIBLE_ATCODER_2025

  extension RedBlackTreeMultiMap {
    @available(*, deprecated)
    public subscript(_unsafe bounds: Range<Index>) -> SubSequence {
      .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue,
        end: bounds.upperBound.rawValue)
    }
  }

  extension RedBlackTreeMultiMap {
    @available(*, deprecated)
    public subscript(_unsafe position: Index) -> (key: Key, value: Value) {
      @inline(__always) get { self[_unchecked: position] }
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
      .init(tree: __tree_, start: __tree_.__begin_node_, end: __tree_.__end_node())
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
        start: ___lower_bound(range.lowerBound),
        end: ___lower_bound(range.upperBound))
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
        start: ___lower_bound(range.lowerBound),
        end: ___upper_bound(range.upperBound))
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
