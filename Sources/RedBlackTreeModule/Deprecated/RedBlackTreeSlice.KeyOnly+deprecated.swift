#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSliceV2.KeyOnly: Collection & BidirectionalCollection {}
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSlice.KeyOnly {

    @available(*, deprecated)
    public subscript(_unsafe bounds: Range<Index>) -> SubSequence {
      .init(
        tree: __tree_,
        start: try! __tree_._remap_to_safe_(bounds.lowerBound).get(),
        end: try! __tree_._remap_to_safe_(bounds.upperBound).get())
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSliceV2.KeyOnly {

    @available(*, deprecated, message: "性能問題があり廃止")
    @inlinable
    @inline(__always)
    public func forEach(_ body: (Index, Element) throws -> Void) rethrows {
      try _forEach(body)
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSliceV2.KeyOnly {

    /// - Complexity: O(log *n*)
    @inlinable
    @inline(__always)
    public subscript(bounds: Range<Index>) -> SubSequence {
      // TODO: ベースでの有効性しかチェックしていない。__containsのチェックにするか要検討
      return .init(
        tree: __tree_,
        start: try! __tree_._remap_to_safe_(bounds.lowerBound).get(),
        end: try! __tree_._remap_to_safe_(bounds.upperBound).get())
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSliceV2.KeyOnly {

    /// RangeExpressionがsubscriptやremoveで利用可能か判別します
    ///
    /// - Complexity:
    ///
    ///   ベースがset, map, dictionaryの場合、O(1)
    ///
    ///   ベースがmultiset, multimapの場合 O(log *n*)
    @inlinable
    @inline(__always)
    public func isValid<R: RangeExpression>(
      _ bounds: R
    ) -> Bool where R.Bound == Index {
      let bounds = bounds.relative(to: self)
      return ___contains(bounds)
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
extension RedBlackTreeSliceV2.KeyOnly: ___UnsafeIndicesBaseV2 {}

extension RedBlackTreeSliceV2.KeyOnly {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var indices: Indices {
    _indices
  }
}
#endif
