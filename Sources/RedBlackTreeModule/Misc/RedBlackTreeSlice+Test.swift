extension RedBlackTreeSliceV2 {

  package func ___node_positions() -> ___UnsafeRemoveAwareWrapper<___UnsafeNaiveIterator> {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension RedBlackTreeSliceV2.KeyValue {

    package func ___node_positions() -> ___UnsafeRemoveAwareWrapper<___UnsafeNaiveIterator> {
      .init(tree: __tree_, start: _start, end: _end)
    }
}
