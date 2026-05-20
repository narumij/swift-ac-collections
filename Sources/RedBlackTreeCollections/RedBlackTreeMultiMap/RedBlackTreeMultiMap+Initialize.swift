//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project
//
// Copyright (c) 2024 - 2026 narumij.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.
//
//===----------------------------------------------------------------------===//

// MARK: - Creating a MultiMap

extension RedBlackTreeMultiMap {

  /// Creates a new, empty multi map.
  ///
  /// - Complexity: O(1)
  @inlinable
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
      var tree = Tree.create()
      try tree.___insert_range_multi(keysAndValues) {
        Base.__payload_($0)
      }
      self.init(__tree_: tree)
    }

    /// - Complexity: O(*n* log *n*)
    ///   When inserting elements sequentially from an already sorted sequence,
    ///   no search is required, and rebalancing is amortized O(1),
    ///   so the overall construction cost becomes O(*n*).
    @inlinable
    public init<S>(multiKeysWithValues keysAndValues: __owned S)
    where S: Collection, S.Element == (Key, Value) {
      var tree = Tree.create(minimumCapacity: keysAndValues.count)
      try tree.___insert_range_multi(keysAndValues) {
        Base.__payload_($0)
      }
      self.init(__tree_: tree)
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
    var tree = Tree.create()
    try tree.___insert_range_multi(values) {
      Base.__payload_((try keyForValue($0), $0))
    }
    self.init(__tree_: tree)
  }
}
