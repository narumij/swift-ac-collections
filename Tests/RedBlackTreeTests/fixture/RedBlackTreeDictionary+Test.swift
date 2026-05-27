#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

#if DEBUG
extension RedBlackTreeDictionary {

  /// releaseビルドでは無効化されています(?)
  @inlinable
  package func ___tree_invariant() -> Bool {
    #if SIZECHECK
      // 並行してサイズもチェックする。その分遅い
      __tree_.count == __tree_.___signed_distance(__tree_.__begin_node_, __tree_.end)
        && __tree_.__tree_invariant(__tree_.__root)
    #else
      __tree_.__tree_invariant(__tree_.__root)
    #endif
  }
}
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary {

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

#if AC_COLLECTIONS_INTERNAL_CHECKS
  extension RedBlackTreeDictionary {

    package var _copyCount: UInt {
      get { __tree_.copyCount }
      set { __tree_.copyCount = newValue }
    }
  }
#endif

#if DEBUG
  extension RedBlackTreeDictionary {

    package func ___node_positions() -> UnsafeIterator._RemoveAwarePointers {
      .init(_start: _sealed_start, _end: _sealed_end)
    }
  }
#endif

#if DEBUG && !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary {

    /// - Complexity: O(1)
    @inlinable
    public subscript(_result position: Index) -> Result<Element, SealError> {
      __tree_.__purified_(position)
        .map { $0.pointer.__value_().pointee }
    }
  }
#endif
