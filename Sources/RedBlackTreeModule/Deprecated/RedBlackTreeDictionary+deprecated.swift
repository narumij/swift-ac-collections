#if COMPATIBLE_ATCODER_2025

  extension RedBlackTreeDictionary {
    @available(*, deprecated)
    public subscript(_unsafe bounds: Range<Index>) -> SubSequence {
      .init(
        tree: __tree_,
        start: __tree_._remap_to_ptr(bounds.lowerBound),
        end: __tree_._remap_to_ptr(bounds.upperBound))
    }
  }

  extension RedBlackTreeDictionary {
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
      _values()
    }
  }

  // Rangeの使い方としておかしいので、便利だが将来的に削除することにした
  extension RedBlackTreeDictionary {

    // setやmultisetと比べて、驚き最小違反とはいいにくいので、deprecatedには一旦しない
    /// 範囲 `[lower, upper)` に含まれる要素を返します。
    /// - Complexity: O(log *n*)
    ///
    /// **Deprecated – 以下の代替コードをご利用ください。**
    ///
    /// ```swift
    /// extension RedBlackTreeDictionary {
    ///   public func sequence(from start: Key, to end: Key) -> SubSequence {
    ///     self[lowerBound(start)..<lowerBound(end)]
    ///   }
    /// }
    /// ```
    @available(*, deprecated)
    public subscript(bounds: Range<Key>) -> SubSequence {
      elements(in: bounds)
    }

    // setやmultisetと比べて、驚き最小違反とはいいにくいので、deprecatedには一旦しない
    /// 範囲 `[lower, upper]` に含まれる要素を返します。
    /// - Complexity: O(log *n*)
    ///
    /// **Deprecated – 以下の代替コードをご利用ください。**
    ///
    /// ```swift
    /// extension RedBlackTreeDictionary {
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

  extension RedBlackTreeDictionary {
    /// キーレンジ `[lower, upper)` に含まれる要素のスライス
    /// - Complexity: O(log *n*)
    ///
    /// **Deprecated – 以下の代替コードをご利用ください。**
    ///
    /// ```swift
    /// extension RedBlackTreeDictionary {
    ///   public func sequence(from start: Key, to end: Key) -> SubSequence {
    ///     self[lowerBound(start)..<lowerBound(end)]
    ///   }
    /// }
    /// ```
    @available(*, deprecated)
    public func elements(in range: Range<Key>) -> SubSequence {
      .init(
        tree: __tree_,
        start: __tree_.lower_bound(range.lowerBound),
        end: __tree_.lower_bound(range.upperBound))
    }

    /// キーレンジ `[lower, upper]` に含まれる要素のスライス
    /// - Complexity: O(log *n*)
    ///
    /// **Deprecated – 以下の代替コードをご利用ください。**
    ///
    /// ```swift
    /// extension RedBlackTreeDictionary {
    ///   public func sequence(from start: Key, through end: Key) -> SubSequence {
    ///     self[lowerBound(start)..<upperBound(end)]
    ///   }
    /// }
    /// ```
    @available(*, deprecated)
    public func elements(in range: ClosedRange<Key>) -> SubSequence {
      .init(
        tree: __tree_,
        start: __tree_.lower_bound(range.lowerBound),
        end: __tree_.upper_bound(range.upperBound))
    }
  }

  extension RedBlackTreeDictionary {

    /// - Important: 削除したメンバーを指すインデックスが無効になります。
    /// - Complexity: O(log *n* + *k*)
    @inlinable
    @inline(__always)
    public mutating func remove(contentsOf keyRange: Range<Key>) {
      __tree_._strongEnsureUnique()
      let lower = __tree_.lower_bound(keyRange.lowerBound)
      let upper = __tree_.lower_bound(keyRange.upperBound)
      ___remove(from: lower, to: upper)
    }

    /// - Important: 削除したメンバーを指すインデックスが無効になります。
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
  // 便利止まりだし、標準にならうと不自然なので、将来的に削除する
  extension RedBlackTreeDictionary where Value: Equatable {

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
  extension RedBlackTreeDictionary where Value: Comparable {

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
