//
//  RedBlackTreeSet+Index.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/04.
//

extension RedBlackTreeSet {

  /// - Complexity: O(1)
  @inlinable
  public subscript(position: Index) -> Element {
    @inline(__always) get {
      __tree_[_unsafe: __tree_.__purified_(position)]
    }
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {
    /// - Important:
    ///   When an element or its corresponding node is removed, any related index becomes invalid.
    ///   Using an invalid index may result in a runtime error or undefined behavior.
    public typealias Index = UnsafeIndexV3
  }

  extension RedBlackTreeSet {

    @inlinable
    func ___index(_ p: _SealedPtr) -> UnsafeIndexV3 {
      p.band(__tree_.tied)
    }

    @inlinable
    func ___index_or_nil(_ p: _SealedPtr) -> UnsafeIndexV3? {
      p.exists ? p.band(__tree_.tied) : nil
    }
  }

  extension RedBlackTreeSet {
    /// - Complexity: O( log `count` )
    @inlinable
    public func firstIndex(of member: Element) -> Index? {
      ___index_or_nil(__tree_.find(member).sealed)
    }
  }

  extension RedBlackTreeSet {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var startIndex: Index { ___index(_sealed_start) }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var endIndex: Index { ___index(_sealed_end) }
  }

  extension RedBlackTreeSet {

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
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

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

  extension RedBlackTreeSet {

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
  extension RedBlackTreeSet {

    /// Returns whether the given index is valid for use with subscript or remove operations.
    ///
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func isValid(_ index: Index) -> Bool {
      __tree_.__purified_(index).exists
    }
  }
#endif
