//
//  RedBlackTreeMultiMap+Initialize.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/05.
//

// MARK: - Creating a MultiMap

extension RedBlackTreeMultiMap {

  /// Creates a new, empty multi map.
  ///
  /// - Complexity: O(1)
  @inlinable @inline(__always)
  public init() {
    self.init(__tree_: .create())
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {

    /// - Complexity: O(*n* log *n*)
    ///   When inserting elements sequentially from an already sorted sequence,
    ///   no search is required, and rebalancing is amortized O(1),
    ///   so the overall construction cost becomes O(*n*).
    @inlinable
    public init<S>(multiKeysWithValues keysAndValues: __owned S)
    where S: Sequence, S.Element == (Key, Value) {
      self.init(
        __tree_:
          .___insert_range_multi(
            tree: .create(),
            keysAndValues,
            transform: Base.__payload_(_:)))
    }

    /// - Complexity: O(*n* log *n*)
    ///   When inserting elements sequentially from an already sorted sequence,
    ///   no search is required, and rebalancing is amortized O(1),
    ///   so the overall construction cost becomes O(*n*).
    @inlinable
    public init<S>(multiKeysWithValues keysAndValues: __owned S)
    where S: Collection, S.Element == (Key, Value) {
      self.init(
        __tree_:
          .___insert_range_multi(
            tree:
              .create(minimumCapacity: keysAndValues.count),
            keysAndValues,
            transform: Base.__payload_(_:)))
    }
  }
#endif

extension RedBlackTreeMultiMap {
  // Dictionaryからぱくってきたが、割と様子見

  /// - Complexity: O(*n* log *n* + *n*)
  @inlinable
  public init<S: Sequence>(
    grouping values: __owned S,
    by keyForValue: (S.Element) throws -> Key
  ) rethrows where Value == S.Element {
    self.init(
      __tree_: try .create_multi(
        sorted: try values.sorted {
          try keyForValue($0) < keyForValue($1)
        },
        by: keyForValue
      ))
  }
}
