#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

#if AC_COLLECTIONS_INTERNAL_CHECKS
  extension RedBlackTreeSet {
    package var _copyCount: UInt {
      get { __tree_.copyCount }
      set { __tree_.copyCount = newValue }
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

    @inlinable
    internal func bound(before i: Bound) -> Bound {
      //      .before(i)
      i.before
    }

    @inlinable
    internal func bound(after i: Bound) -> Bound {
      //      .after(i)
      i.after
    }
  }
#endif

extension RedBlackTreeSet {

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
}

#if DEBUG
  extension RedBlackTreeSet {

    @inlinable
    package func ___is_garbaged(_ index: Index) -> Bool {
      switch __tree_.__purified_(index).purified {
      case .failure:
        return true
      default:
        return false
      }
    }
  }
#endif

#if DEBUG && COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

    package func ___node_positions() -> UnsafeIterator._RemoveAwarePointers {
      .init(_start: _sealed_start, _end: _sealed_end)
    }
  }
#endif

#if DEBUG && !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

    /// - Complexity: O(1)
    @inlinable
    package subscript(_result position: Index) -> Result<Element, SealError> {
      // なぜpublicにしたのか思い出せない
      __tree_.__purified_(position)
        .map { $0.pointer.__value_().pointee }
    }
  }
#endif

#if DEBUG
  extension RedBlackTreeSet {

    package func _withSealed<R>(
      _ b: RedBlackTreeBoundExpression<Element>,
      _ body: (_SealedPtr) throws -> R
    ) rethrows -> R {
      let b = b.evaluate(__tree_).uncheckedSeal
      return try body(b)
    }

    package func _withSealed<R>(
      _ a: RedBlackTreeBoundExpression<Element>,
      _ b: RedBlackTreeBoundExpression<Element>,
      _ body: (_SealedPtr, _SealedPtr) throws -> R
    ) rethrows -> R {
      let a = a.evaluate(__tree_).uncheckedSeal
      let b = b.evaluate(__tree_).uncheckedSeal
      return try body(a, b)
    }
  }

  extension RedBlackTreeSet {

    package func _isEqual(
      _ l: RedBlackTreeBoundExpression<Element>,
      _ r: RedBlackTreeBoundExpression<Element>
    ) -> Bool {
      let l = l.evaluate(__tree_).uncheckedSeal
      let r = r.evaluate(__tree_).uncheckedSeal
      return l == r
    }

    package func _error(_ bound: RedBlackTreeBoundExpression<Element>) -> SealError? {
      bound.evaluate(__tree_).uncheckedSeal.error
    }
  }
#endif
