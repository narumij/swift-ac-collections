//
//  RedBlackTreeSet+Benchmark.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/23.
//

#if BENCHMARK
  extension RedBlackTreeSet {

    @inlinable
    public func __raw_find(_ member: Element) -> _NodePtr {
      __tree_.find(member)
    }

    @inlinable
    public var __raw_end: _NodePtr {
      __tree_.__end_node
    }
  }
#endif
