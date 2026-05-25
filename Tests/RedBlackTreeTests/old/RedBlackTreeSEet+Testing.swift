//
//  RedBlackTreeSEet+Testing.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/25.
//

import RedBlackTreeModule

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

    @inlinable
    internal func bound(before i: Bound) -> Bound {
      //      .before(i)
      i.before
    }

    @inlinable
    internal func bound(after i: Bound) -> Bound {
      //      .after(i)
      i.after
    }
  }
#endif
