extension RedBlackTreeSlice {

  package func ___node_positions() -> ___SafePointers<Base> {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension RedBlackTreeSlice.KeyValue {

  package func ___node_positions() -> ___SafePointers<Base> {
    .init(tree: __tree_, start: _start, end: _end)
  }
}
