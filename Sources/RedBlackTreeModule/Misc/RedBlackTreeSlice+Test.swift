extension RedBlackTreeSliceV2.KeyOnly {

  package func ___node_positions() -> UnsafeIterator._RemoveAwarePointers {
    .init(_start: _start.sealed, _end: _end.sealed)
  }
}

extension RedBlackTreeSliceV2.KeyValue {

  package func ___node_positions() -> UnsafeIterator._RemoveAwarePointers {
    .init(_start: _start.sealed, _end: _end.sealed)
    }
}
