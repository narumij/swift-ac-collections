extension RedBlackTreeDictionary {

  /// releaseビルドでは無効化されています(?)
  @inlinable
  @inline(__always)
  package func ___tree_invariant() -> Bool {
    #if !WITHOUT_SIZECHECK
      // 並行してサイズもチェックする。その分遅い
      __tree_.count == __tree_.___signed_distance(__tree_.__begin_node_, __tree_.end)
        && __tree_.__tree_invariant(__tree_.__root)
    #else
      __tree_.__tree_invariant(__tree_.__root)
    #endif
  }
}

extension RedBlackTreeDictionary {
  
  @inlinable
  @inline(__always)
  package func ___is_garbaged(_ index: Index) -> Bool {
    switch __tree_.__sealed_(index).purified {
    case .failure:
      return true
    default:
      return false
    }
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

  package func ___node_positions() -> UnsafeIterator._RemoveAwarePointers {
    .init(_start: _sealed_start, _end: _sealed_end)
  }
}

