//
//  RedBlackTreeSet+Initialize.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/04.
//

// MARK: - Creating a Set

extension RedBlackTreeSet {
  
  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public init() {
    self.init(__tree_: .create())
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

    /// - Complexity: O(*n* log *n*)
    ///   When inserting elements sequentially from an already sorted sequence,
    ///   no search is required, and rebalancing is amortized O(1),
    ///   so the overall construction cost becomes O(*n*).
    @inlinable
    public init<Source>(_ sequence: __owned Source)
    where Element == Source.Element, Source: Sequence {
      self.init(
        __tree_:
          .___insert_range_unique(
            tree: .create(),
            sequence))
    }

    /// - Complexity: O(*n* log *n*)
    ///   When inserting elements sequentially from an already sorted sequence,
    ///   no search is required, and rebalancing is amortized O(1),
    ///   so the overall construction cost becomes O(*n*).
    @inlinable
    public init<Source>(_ collection: __owned Source)
    where Element == Source.Element, Source: Collection {
      self.init(
        __tree_:
          .___insert_range_unique(
            tree: .create(minimumCapacity: collection.count),
            collection))
    }
  }
#endif

extension RedBlackTreeSet {

  /// - Important: This implementation assumes ascending order and omits certain checks.
  ///   Using it with descending order results in undefined behavior.
  /// - Complexity: Amortized O(*n*).
  @inlinable
  public init<R>(_ range: __owned R)
  where R: RangeExpression, R: Collection, R.Element == Element {
    precondition(range is Range<Element> || range is ClosedRange<Element>)
    self.init(__tree_: .create(range: range))
  }
}
