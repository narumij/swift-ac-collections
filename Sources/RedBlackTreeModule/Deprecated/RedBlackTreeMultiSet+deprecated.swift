//
//  RedBlackTreeMultiSet+deprecated.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/12/26.
//

#if COMPATIBLE_ATCODER_2025

extension RedBlackTreeMultiSet {
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

extension RedBlackTreeMultiSet {
  @inlinable
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
#endif
