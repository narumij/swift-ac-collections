#if COMPATIBLE_ATCODER_2025

  extension RedBlackTreeSlice.KeyOnly {

    @available(*, deprecated)
    public subscript(_unsafe bounds: Range<Index>) -> SubSequence {
      .init(
        tree: __tree_,
        start: __tree_.rawValue(bounds.lowerBound),
        end: __tree_.rawValue(bounds.upperBound))
    }
  }

  extension RedBlackTreeSliceV2.KeyValue {

    @available(*, deprecated)
    public subscript(_unsafe bounds: Range<Index>) -> SubSequence {
      .init(
        tree: __tree_,
        start: __tree_.rawValue(bounds.lowerBound),
        end: __tree_.rawValue(bounds.upperBound))
    }
  }

  extension RedBlackTreeSliceV2.KeyValue {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func keys() -> Keys {
      _keys()
    }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func values() -> Values {
      _values()
    }
  }
#endif
