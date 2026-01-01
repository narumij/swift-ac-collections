extension RedBlackTreeSlice {

#if USE_UNSAFE_TREE
  package func ___node_positions() -> ___SafePointers<Base> {
    fatalError()
  }
#else
  package func ___node_positions() -> ___SafePointers<Base> {
    .init(tree: __tree_, start: _start, end: _end)
  }
#endif
}

extension RedBlackTreeSlice.KeyValue {

  #if USE_UNSAFE_TREE
    package func ___node_positions() -> ___SafePointers<Base> {
      fatalError()
    }
  #else
    package func ___node_positions() -> ___SafePointers<Base> {
      .init(tree: __tree_, start: _start, end: _end)
    }
  #endif
}
