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
  extension RedBlackTreeMultiSet {

    /// - Important:
    ///   When an element or its corresponding node is removed, any related index becomes invalid.
    ///   Using an invalid index may result in a runtime error or undefined behavior.
    public typealias Index = UnsafeIndexV3
  }

  extension RedBlackTreeMultiSet {

    /// Returns whether the index can be used with subscript or remove operations.
    ///
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func isValid(_ index: Index) -> Bool {
      __tree_.__purified_(index).exists
    }
  }

  extension RedBlackTreeMultiSet {
    /// - Complexity: O( log `count` )
    @inlinable
    public func firstIndex(of member: Element) -> Index? {
      ___index_or_nil(__tree_.find(member).sealed)
    }
  }

  extension RedBlackTreeMultiSet {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var startIndex: Index { ___index(_sealed_start) }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var endIndex: Index { ___index(_sealed_end) }
  }

  extension RedBlackTreeMultiSet {

    /// - Complexity: O(log *n* + *k*)
    @inlinable
    @inline(__always)
    public func distance(from start: Index, to end: Index)
      -> Int
    {
      guard let d = __tree_.distance(from: start, to: end)
      else { fatalError(.invalidIndex) }
      return d
    }
  }

  extension RedBlackTreeMultiSet {

    /// Returns the index of the first element that is not less than the given value.
    ///
    /// `lowerBound(_:)` returns the first position (`Index`) where the value is
    /// greater than or equal to the specified element `member`.
    ///
    /// For example, given a sorted sequence `[1, 3, 5, 7, 9]`:
    /// - `lowerBound(0)` returns the position of the first element `1` (i.e. `startIndex`).
    /// - `lowerBound(3)` returns the position of element `3`.
    /// - `lowerBound(4)` returns the position of element `5` (the first value ≥ `4`).
    /// - `lowerBound(10)` returns `endIndex`.
    ///
    /// - Parameter member: The element to search for using binary search.
    /// - Returns: The first `Index` whose value is greater than or equal to `member`.
    /// - Complexity: O(log *n*), where *n* is the number of elements.
    @inlinable
    public func lowerBound(_ member: Element) -> Index {
      ___index(__tree_.lower_bound(member).sealed)
    }

    /// Returns the index of the first element that is greater than the given value.
    ///
    /// `upperBound(_:)` returns the first position (`Index`) where the value is
    /// strictly greater than the specified element `member`.
    ///
    /// For example, given a sorted sequence `[1, 3, 5, 5, 7, 9]`:
    /// - `upperBound(3)` returns the position of element `5`
    ///   (the first value greater than `3`).
    /// - `upperBound(5)` returns the position of element `7`
    ///   (elements equal to `5` are excluded, so it points just after them).
    /// - `upperBound(9)` returns `endIndex`.
    ///
    /// - Parameter member: The element to search for using binary search.
    /// - Returns: The first `Index` whose value is strictly greater than `member`.
    /// - Complexity: O(log *n*), where *n* is the number of elements.
    @inlinable
    public func upperBound(_ member: Element) -> Index {
      ___index(__tree_.upper_bound(member).sealed)
    }
  }

  extension RedBlackTreeMultiSet {

    /// - Complexity: O( log `count` )
    @inlinable
    public func find(_ member: Element) -> Index {
      ___index(__tree_.find(member).sealed)
    }
  }

  extension RedBlackTreeMultiSet {

    /// - Complexity: O(log *n*), where *n* is the number of elements.
    @inlinable
    public func equalRange(_ element: Element) -> UnsafeIndexV3Range {
      let (lower, upper) = __tree_.__equal_range_multi(element)
      return .init(.init(lowerBound: ___index(lower.sealed), upperBound: ___index(upper.sealed)))
    }
  }

  extension RedBlackTreeMultiSet {

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

  extension RedBlackTreeMultiSet {

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

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

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
#endif
