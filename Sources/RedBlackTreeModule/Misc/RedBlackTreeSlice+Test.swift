extension RedBlackTreeSliceV2 {

  package func ___node_positions() -> UnsafeIterator.RemoveAwarePointers {
    .init(start: _start, end: _end)
  }
}

extension RedBlackTreeSliceV2.KeyValue {

  package func ___node_positions() -> UnsafeIterator.RemoveAwarePointers {
      .init(start: _start, end: _end)
    }
}
