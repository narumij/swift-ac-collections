// Copyright (c) 2026 narumij.
// Licensed under the Apache License v2.0.
// SPDX-License-Identifier: Apache-2.0

// Adapts the removal naming used in the root containers' SortedCollectionsAPI
// files to mutable views. These are not Apple's read-only SubSequence APIs.
// Operations affect only the view's bounds. Through a container's _modify
// accessor they update that container; a standalone view uses copy-on-write.
#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeKeyOnlyRangeView {

    /// Removes the first `k` elements represented by this view.
    /// - Precondition: `k` is between zero and the view's count, inclusive.
    @inlinable
    public mutating func removeFirst(_ k: Int) {
      precondition(k >= 0, "Invalid removal count")
      for _ in 0..<k { removeFirst() }
    }

    /// Removes the last `k` elements represented by this view.
    /// - Precondition: `k` is between zero and the view's count, inclusive.
    @inlinable
    public mutating func removeLast(_ k: Int) {
      precondition(k >= 0, "Invalid removal count")
      for _ in 0..<k { removeLast() }
    }

    /// Removes every element represented by this view, leaving outside elements intact.
    @inlinable
    public mutating func removeAll() {
      erase()
    }

    /// Removes represented elements satisfying the predicate.
    /// Earlier removals remain applied if the predicate throws, as with `erase(where:)`.
    @inlinable
    public mutating func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
      try erase(where: shouldBeRemoved)
    }
  }

  extension RedBlackTreeKeyValueRangeView {

    /// Removes the first `k` elements represented by this view.
    /// - Precondition: `k` is between zero and the view's count, inclusive.
    @inlinable
    public mutating func removeFirst(_ k: Int) {
      precondition(k >= 0, "Invalid removal count")
      for _ in 0..<k { removeFirst() }
    }

    /// Removes the last `k` elements represented by this view.
    /// - Precondition: `k` is between zero and the view's count, inclusive.
    @inlinable
    public mutating func removeLast(_ k: Int) {
      precondition(k >= 0, "Invalid removal count")
      for _ in 0..<k { removeLast() }
    }

    /// Removes every element represented by this view, leaving outside elements intact.
    @inlinable
    public mutating func removeAll() {
      erase()
    }

    /// Removes represented elements satisfying the predicate.
    /// Earlier removals remain applied if the predicate throws, as with `erase(where:)`.
    @inlinable
    public mutating func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
      try erase(where: shouldBeRemoved)
    }
  }

  extension RedBlackTreeMappedValuesView {

    /// Removes the first `k` elements represented by this view.
    /// - Precondition: `k` is between zero and the view's count, inclusive.
    @inlinable
    public mutating func removeFirst(_ k: Int) {
      precondition(k >= 0, "Invalid removal count")
      for _ in 0..<k { removeFirst() }
    }

    /// Removes the last `k` elements represented by this view.
    /// - Precondition: `k` is between zero and the view's count, inclusive.
    @inlinable
    public mutating func removeLast(_ k: Int) {
      precondition(k >= 0, "Invalid removal count")
      for _ in 0..<k { removeLast() }
    }

    /// Removes every element represented by this view, leaving outside elements intact.
    @inlinable
    public mutating func removeAll() {
      erase()
    }

    /// Removes represented elements satisfying the predicate.
    /// Earlier removals remain applied if the predicate throws, as with `erase(where:)`.
    @inlinable
    public mutating func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
      try erase(where: shouldBeRemoved)
    }
  }

#endif
