//
//  RedBlackTreeSet+Benchmark.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/23.
//

#if BENCHMARK
  extension RedBlackTreeSet {

    @inlinable
    public func __value_find(_ member: Element) -> Element? {
      let p = __tree_.update { $0.find(member) }.safe
//      return p != _end ? p.__value_(as: Element.self).pointee : nil
      guard let p = p.pointer, !p.___is_end else { return nil }
      return p.__value_(as: Element.self).pointee
    }
    
    @inlinable
    public func __raw_safe_find(_ member: Element) -> _SafePtr {
      __tree_.update { $0.find(member) }.safe
    }
    
    /// - Complexity: O( log `count` )
    @inlinable
    public func __raw_find(_ member: Element) -> _NodePtr {
//      __tree_.find(member)
      __tree_.update { $0.find(member) }
    }

    @inlinable
    public var __raw_end: _NodePtr {
      __tree_.__end_node
    }
  }
#endif
