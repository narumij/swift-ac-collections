#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary {
    @inlinable
    package func ___is_garbaged(_ index: Index) -> Bool {
      if case .failure = __tree_.__purified_(index).purified { true } else { false }
    }
  }

  extension RedBlackTreeMultiMap {
    @inlinable
    package func ___is_garbaged(_ index: Index) -> Bool {
      if case .failure = __tree_.__purified_(index).purified { true } else { false }
    }

    @inlinable
    public init<S>(keysWithValues keysAndValues: __owned S)
    where S: Sequence, S.Element == (Key, Value) {
      self.init(multiKeysWithValues: keysAndValues)
    }
  }

  extension RedBlackTreeMultiSet {
    @inlinable
    package func ___is_garbaged(_ index: Index) -> Bool {
      if case .failure = __tree_.__purified_(index).purified { true } else { false }
    }
  }

  #if DEBUG
    extension RedBlackTreeDictionary {
      package func ___node_positions() -> UnsafeIterator._RemoveAwarePointers {
        .init(_start: _sealed_start, _end: _sealed_end)
      }
    }

    extension RedBlackTreeMultiMap {
      package func ___node_positions() -> UnsafeIterator._RemoveAwarePointers {
        .init(_start: _sealed_start, _end: _sealed_end)
      }
    }

    extension RedBlackTreeMultiSet {
      package func ___node_positions() -> UnsafeIterator._RemoveAwarePointers {
        .init(_start: _sealed_start, _end: _sealed_end)
      }
    }

    extension RedBlackTreeSet {
      package func ___node_positions() -> UnsafeIterator._RemoveAwarePointers {
        .init(_start: _sealed_start, _end: _sealed_end)
      }
    }
  #endif
#endif
