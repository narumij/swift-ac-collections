//
//  unsafe_node+pointer+distance.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/06/01.
//

#if DEBUG
  @testable import RedBlackTreeCollections

  // 遅い
  @inlinable
  internal func
    ___dual_distance(
      _ __first: UnsafeMutablePointer<UnsafeNode>,
      _ __last: UnsafeMutablePointer<UnsafeNode>
    )
    -> Int
  {
    var __next = __first
    var __prev = __first
    var __r = 0
    while __next != __last, __prev != __last {
      __next = __next.___is_null ? __next : __tree_next(__next)
      __prev = __prev.___is_null ? __prev : __tree_prev_iter(__prev)
      __r += 1
    }
    return __next == __last ? __r : -__r
  }
#endif

