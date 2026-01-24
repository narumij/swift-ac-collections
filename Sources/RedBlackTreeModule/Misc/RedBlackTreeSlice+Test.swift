extension RedBlackTreeSliceV2.KeyOnly {

  package func ___node_positions() -> UnsafeIterator._RemoveAwarePointers {
    .init(_start: _start, _end: _end)
  }
}

extension RedBlackTreeSliceV2.KeyValue {

  package func ___node_positions() -> UnsafeIterator._RemoveAwarePointers {
      .init(_start: _start, _end: _end)
    }
}
