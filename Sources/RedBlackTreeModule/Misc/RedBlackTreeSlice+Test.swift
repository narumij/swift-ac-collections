extension RedBlackTreeSliceV2 {

  package func ___node_positions() -> UnsafeIterator.RemoveAware<UnsafeIterator.Obverse> {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension RedBlackTreeSliceV2.KeyValue {

  package func ___node_positions() -> UnsafeIterator.RemoveAware<UnsafeIterator.Obverse> {
      .init(tree: __tree_, start: _start, end: _end)
    }
}
