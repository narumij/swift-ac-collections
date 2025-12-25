//
//  RedBlackTreeDictionary+deprecated.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/12/26.
//

#if COMPATIBLE_ATCODER_2025

  extension RedBlackTreeDictionary {
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public subscript(_unsafe bounds: Range<Index>) -> SubSequence {
      .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue,
        end: bounds.upperBound.rawValue)
    }
  }

  extension RedBlackTreeDictionary {
    @inlinable
//    public subscript(_unsafe position: Index) -> Element {
  public subscript(_unsafe position: Index) -> (key: Key, value: Value) {
//      @inline(__always) get { ___element(self[_unchecked: position]) }
    @inline(__always) get { self[_unchecked: position] }
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
        start: ___lower_bound(range.lowerBound),
        end: ___lower_bound(range.upperBound))
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
        start: ___lower_bound(range.lowerBound),
        end: ___upper_bound(range.upperBound))
    }
  }
#endif
