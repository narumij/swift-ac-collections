#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

  extension RedBlackTreeDictionary {

    /// Compatibility helper for tests that still exercise Bound lookup behavior.
    @inlinable
    internal func isValid(_ bound: Bound) -> Bool {
      self[bound] != nil
    }

    /// Compatibility helper for tests that exercise Bound range lookup behavior.
    @inlinable
    internal func isValid(_ bounds: BoundRangeExpression) -> Bool {
      !self[bounds].isEmpty
    }

    /// Compatibility helpers for tests that still use the former Range spelling.
    @inlinable
    internal func isValid(_ bounds: UnboundedRange) -> Bool {
      containsSubrange(bounds)
    }

    @inlinable
    internal func isValid(_ bounds: IndexRange) -> Bool {
      containsSubrange(bounds)
    }

    @inlinable
    internal func isValid(_ bounds: IndexRangeExpression) -> Bool {
      containsSubrange(bounds)
    }
  }

extension RedBlackTreeDictionary {

  /// releaseビルドでは無効化されています(?)
  @inlinable
  package func ___tree_invariant() -> Bool {
    #if DEBUG
      #if SIZECHECK
        // 並行してサイズもチェックする。その分遅い
        __tree_.count == __tree_.___signed_distance(__tree_.__begin_node_, __tree_.end)
          && __tree_.__tree_invariant(__tree_.__root)
      #else
        __tree_.__tree_invariant(__tree_.__root)
      #endif
    #else
      true
    #endif
  }

  @inlinable
  package func ___tree_invariant_for_fuzz() -> Bool {
    __tree_.__tree_invariant(__tree_.__root)
  }
}

#if AC_COLLECTIONS_INTERNAL_CHECKS
  extension RedBlackTreeDictionary {

    package var _copyCount: UInt {
      get { __tree_.copyCount }
      set { __tree_.copyCount = newValue }
    }
  }
#endif

  extension RedBlackTreeDictionary {

    /// Alias retained for tests shared with the AtCoder 2025 compatibility build.
    @inlinable
    internal func isValid(_ index: Index) -> Bool {
      isElement(at: index)
    }
  }

#if DEBUG
  extension RedBlackTreeDictionary {

    /// - Complexity: O(1)
    @inlinable
    public subscript(_result position: Index) -> Result<Element, SealError> {
      __tree_.__purified_(position)
        .map { $0.pointer.__value_().pointee }
    }
  }
#endif
