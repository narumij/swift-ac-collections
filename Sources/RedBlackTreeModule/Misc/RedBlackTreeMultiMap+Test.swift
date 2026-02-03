extension RedBlackTreeMultiMap {

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

extension RedBlackTreeMultiMap {

  @inlinable
  @inline(__always)
  package func ___is_garbaged(_ index: Index) -> Bool {
    switch __tree_._remap_to_safe_(index) {
    case .failure:
      return true
    default:
      return false
    }
  }
}

#if AC_COLLECTIONS_INTERNAL_CHECKS
  extension RedBlackTreeMultiMap {

    package var _copyCount: UInt {
      get { __tree_.copyCount }
      set { __tree_.copyCount = newValue }
    }
  }
#endif

extension RedBlackTreeMultiMap {

  package func ___node_positions() -> UnsafeIterator._RemoveAwarePointers {
    .init(_start: _start, _end: _end)
  }
}
