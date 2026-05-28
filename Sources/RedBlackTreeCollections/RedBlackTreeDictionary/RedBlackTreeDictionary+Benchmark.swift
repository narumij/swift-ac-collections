//
//  RedBlackTreeDictionary+Benchmark.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/29.
//

#if BENCHMARK
  extension RedBlackTreeDictionary {

    @inlinable
    public var __indices: UnsafeIterator._Indices<Base> {
      .init(start: _start, end: _end, tree: __tree_)
    }
  }
#endif
