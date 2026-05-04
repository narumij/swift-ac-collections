//
//  RedBlackTreeDictionary+Index.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/05.
//

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary {

    /// - Important:
    ///   When an element or its corresponding node is removed, any related index becomes invalid.
    ///   Using an invalid index may result in a runtime error or undefined behavior.
    public typealias Index = UnsafeIndexV3
  }

  extension RedBlackTreeDictionary {

    @inlinable
    func ___index(_ p: _SealedPtr) -> UnsafeIndexV3 {
      p.band(__tree_.tied)
    }

    @inlinable
    func ___index_or_nil(_ p: _SealedPtr) -> UnsafeIndexV3? {
      p.exists ? p.band(__tree_.tied) : nil
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
    @inline(__always)
    public var startIndex: Index { ___index(_sealed_start) }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var endIndex: Index { ___index(_sealed_end) }
  }

  extension RedBlackTreeDictionary {

    /// - Complexity: O(log *n* + *k*)
    @inlinable
    @inline(__always)
    public func distance(from start: Index, to end: Index)
      -> Int
    {
      guard
        let d = __tree_.___distance(
          from: __tree_.__purified_(start),
          to: __tree_.__purified_(end))
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
      __tree_.__purified_(i)
        .flatMap { ___tree_prev_iter($0.pointer) }
        .flatMap { $0.sealed.band(__tree_.tied) }
    }

    /// - Complexity: O(1)
    @inlinable
    public func index(after i: Index) -> Index {
      __tree_.__purified_(i)
        .flatMap { ___tree_next_iter($0.pointer) }
        .flatMap { $0.sealed.band(__tree_.tied) }
    }

    /// - Complexity: O(`distance`)
    @inlinable
    public func index(_ i: Index, offsetBy distance: Int)
      -> Index
    {
      __tree_.__purified_(i)
        .flatMap { ___tree_adv_iter($0.pointer, distance) }
        .flatMap { $0.sealed.band(__tree_.tied) }
    }

    /// - Complexity: O(`distance`)
    @inlinable
    public func index(
      _ i: Index, offsetBy distance: Int, limitedBy limit: Index
    )
      -> Index?
    {
      var i = i
      let result = formIndex(&i, offsetBy: distance, limitedBy: limit)
      return result ? i : nil
    }
  }

  extension RedBlackTreeDictionary {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func formIndex(before i: inout Index) {
      i = index(before: i)
    }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func formIndex(after i: inout Index) {
      i = index(after: i)
    }

    /// - Complexity: O(*d*)
    @inlinable
    //  @inline(__always)
    public func formIndex(_ i: inout Index, offsetBy distance: Int) {
      i = index(i, offsetBy: distance)
    }

    /// - Complexity: O(*d*)
    @inlinable
    @inline(__always)
    public func formIndex(
      _ i: inout Index,
      offsetBy distance: Int,
      limitedBy limit: Index
    )
      -> Bool
    {
      guard let ___i = __tree_.__purified_(i).pointer
      else { return false }

      let __l = __tree_.__purified_(limit).map(\.pointer)

      return ___form_index(___i, offsetBy: distance, limitedBy: __l) {
        i = $0.flatMap { $0.sealed.band(__tree_.tied) }
      }
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
    @inline(__always)
    public func isValid(_ index: Index) -> Bool {
      __tree_.__purified_(index).exists
    }
  }

  extension RedBlackTreeDictionary {

    /// - Complexity: O(1)
    @inlinable
    public subscript(position: Index) -> Element {
      @inline(__always) get {
        Base.__element_(__tree_[_unsafe: __tree_.__purified_(position)])
      }
    }
  }
#endif
