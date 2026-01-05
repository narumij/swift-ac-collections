extension RedBlackTreeSliceV2 {

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

extension RedBlackTreeSliceV2.KeyValue {

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
