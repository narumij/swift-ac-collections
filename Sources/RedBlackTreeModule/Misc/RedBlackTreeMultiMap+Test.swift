extension RedBlackTreeMultiMap {

  /// releaseビルドでは無効化されています(?)
  @inlinable
  @inline(__always)
  package func ___tree_invariant() -> Bool {
    #if !WITHOUT_SIZECHECK
      // 並行してサイズもチェックする。その分遅い
      __tree_.count == __tree_.___signed_distance(__tree_.__begin_node_, .end)
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
    __tree_.___is_garbaged(index.rawValue(__tree_))
  }
}

#if AC_COLLECTIONS_INTERNAL_CHECKS
  extension RedBlackTreeMultiMap {

    package var _copyCount: UInt {
      get { __tree_.copyCount }
      set { __tree_.copyCount = newValue }
    }
  }

  extension RedBlackTreeMultiMap {
    package mutating func _checkUnique() -> Bool {
      _isKnownUniquelyReferenced_LV2()
    }
  }
#endif

extension RedBlackTreeMultiMap {

#if USE_UNSAFE_TREE
  package func ___node_positions() -> ___SafePointersUnsafeV2<Base> {
    .init(tree: __tree_, start: _start, end: _end)
  }
#else
  package func ___node_positions() -> ___SafePointers<Base> {
    .init(tree: __tree_, start: _start, end: _end)
  }
#endif
}
