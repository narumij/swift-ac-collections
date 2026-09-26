#if COMPATIBLE_ATCODER_2025
  extension _SequenceV2 {

    @inlinable
    package var _sealed_start: _SealedPtr {
      __tree_.__begin_node_.uncheckedSeal
    }

    @inlinable
    package var _sealed_end: _SealedPtr {
      __tree_.__end_node.uncheckedSeal
    }

    @inlinable
    var ___sealed_range: _RawRange<_SealedPtr> {
      .init(lowerBound: _sealed_start, upperBound: _sealed_end)
    }
  }
#endif
