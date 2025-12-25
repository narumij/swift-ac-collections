#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSlice {
    @available(*, deprecated)
    public subscript(_unsafe position: Index) -> Element {
      @inline(__always) _read {
        yield self[_unchecked: position]
      }
    }

    @available(*, deprecated)
    public subscript(_unsafe bounds: Range<Index>) -> SubSequence {
      .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue,
        end: bounds.upperBound.rawValue)
    }
  }

  extension RedBlackTreeSlice.KeyValue {

    @available(*, deprecated)
    public subscript(_unsafe position: Index) -> (key: _Key, value: _MappedValue) {
      @inline(__always) get { self[_unchecked: position] }
    }

    @available(*, deprecated)
    public subscript(_unsafe bounds: Range<Index>) -> SubSequence {
      .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue,
        end: bounds.upperBound.rawValue)
    }
  }

  extension RedBlackTreeSlice.KeyValue {

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
