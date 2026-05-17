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

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary {

    /// - Important:
    ///   When an element or its corresponding node is removed, any related index becomes invalid.
    ///   Using an invalid index may result in a runtime error or undefined behavior.
    public typealias Index = UnsafeIndexV3
  }

  extension RedBlackTreeDictionary {

    @inlinable
    func ___index(_ p: _SealedPtr) -> _TieWrappedPtr {
      p.band(__tree_.tied)
    }

    @inlinable
    func ___index_or_nil(_ p: _SealedPtr) -> _TieWrappedPtr? {
      p.exists ? p.band(__tree_.tied) : nil
    }
    
    @inlinable
    func ___index(_ p: _SealedPtr) -> _LazyDetachPointer {
      p.band(__tree_.lazyDetach)
    }

    @inlinable
    func ___index_or_nil(_ p: _SealedPtr) -> _LazyDetachPointer? {
      p.exists ? p.band(__tree_.lazyDetach) : nil
    }
  }

  extension RedBlackTreeDictionary {
    /// - Complexity: O( log `count` )
    @inlinable
    public func firstIndex(of key: Key) -> Index? {
      ___index_or_nil(__tree_.find(key).sealed)
    }
  }

  extension RedBlackTreeDictionary {

    /// - Complexity: O(1)
    @inlinable
    public var startIndex: Index { ___index(_sealed_start) }

    /// - Complexity: O(1)
    @inlinable
    public var endIndex: Index { ___index(_sealed_end) }
  }

  extension RedBlackTreeDictionary {

    /// - Complexity: O(log *n* + *k*)
    @inlinable
    public func distance(from start: Index, to end: Index)
      -> Int
    {
      guard let d = __tree_.distance(from: start, to: end)
      else { fatalError(.invalidIndex) }
      return d
    }
  }

  extension RedBlackTreeDictionary {

    /// Returns the index of the first element whose key is not less than the given key.
    ///
    /// `lowerBound(_:)` returns the first position (`Index`) whose element has a key
    /// greater than or equal to the specified `key`.
    ///
    /// For example, given a key-sorted sequence `[1: "a", 3: "c", 5: "e", 7: "g", 9: "i"]`:
    /// - `lowerBound(0)` returns the position of the first element `(1, "a")` (i.e. `startIndex`).
    /// - `lowerBound(3)` returns the position of the element with key `3`, `(3, "c")`.
    /// - `lowerBound(4)` returns the position of `(5, "e")` (the first key ≥ `4`).
    /// - `lowerBound(10)` returns `endIndex`.
    ///
    /// - Parameter key: The key to search for using binary search.
    /// - Returns: The first `Index` whose element’s key is greater than or equal to `key`.
    /// - Complexity: O(log *n*), where *n* is the number of elements.
    @inlinable
    public func lowerBound(_ key: Key) -> Index {
      ___index(__tree_.lower_bound(key).sealed)
    }

    /// Returns the index of the first element whose key is greater than the given key.
    ///
    /// `upperBound(_:)` returns the first position (`Index`) whose element has a key
    /// strictly greater than the specified `key`.
    ///
    /// For example, given a key-sorted sequence `[1: "a", 3: "c", 5: "e", 7: "g", 9: "i"]`:
    /// - `upperBound(3)` returns the position of the element with key `5`, `(5, "e")`
    ///   (the first key greater than `3`).
    /// - `upperBound(5)` returns the position of the element with key `7`, `(7, "g")`.
    /// - `upperBound(9)` returns `endIndex`.
    ///
    /// - Parameter key: The key to search for using binary search.
    /// - Returns: The first `Index` whose element’s key is strictly greater than `key`.
    /// - Complexity: O(log *n*), where *n* is the number of elements.
    @inlinable
    public func upperBound(_ key: Key) -> Index {
      ___index(__tree_.upper_bound(key).sealed)
    }
  }

  extension RedBlackTreeDictionary {

    /// - Complexity: O( log `count` )
    @inlinable
    public func find(_ key: Key) -> Index {
      ___index(__tree_.find(key).sealed)
    }
  }

  extension RedBlackTreeDictionary {

    /// - Complexity: O(log *n*), where *n* is the number of elements.
    @inlinable
    public func equalRange(_ key: Key) -> UnsafeIndexV3Range {
      let (lower, upper) = __tree_.__equal_range_unique(key)
      return .init(.init(lowerBound: ___index(lower.sealed), upperBound: ___index(upper.sealed)))
    }
  }

  extension RedBlackTreeDictionary {

    /// - Complexity: O(1)
    @inlinable
    public func index(before i: Index) -> Index {
      __tree_.prev_iter(i)
    }

    /// - Complexity: O(1)
    @inlinable
    public func index(after i: Index) -> Index {
      __tree_.next_iter(i)
    }

    /// - Complexity: O(`distance`)
    @inlinable
    public func index(_ i: Index, offsetBy distance: Int) -> Index {
      __tree_.adv_iter(i, offsetBy: distance)
    }

    /// - Complexity: O(`distance`)
    @inlinable
    public func index(
      _ i: Index, offsetBy distance: Int, limitedBy limit: Index
    ) -> Index? {
      __tree_.index_or_nil(i, offsetBy: distance, limitedBy: limit)
    }
  }

  extension RedBlackTreeDictionary {

    /// - Complexity: O(1)
    @inlinable
    public func formIndex(before i: inout Index) {
      i = __tree_.prev_iter(i)
    }

    /// - Complexity: O(1)
    @inlinable
    public func formIndex(after i: inout Index) {
      i = __tree_.next_iter(i)
    }

    /// - Complexity: O(*d*)
    @inlinable
    public func formIndex(_ i: inout Index, offsetBy distance: Int) {
      i = __tree_.adv_iter(i, offsetBy: distance)
    }

    /// - Complexity: O(*d*)
    @inlinable
    public func formIndex(
      _ i: inout Index, offsetBy distance: Int, limitedBy limit: Index
    ) -> Bool {

      __tree_.form_index(&i, offsetBy: distance, limitedBy: limit)
    }
  }
#endif

// MARK: -

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary {

    /// Returns whether the index can be used with subscript or remove operations.
    ///
    /// - Complexity: O(1)
    @inlinable
    public func isValid(_ index: Index) -> Bool {
      __tree_.__purified_(index).exists
    }
  }
#endif
