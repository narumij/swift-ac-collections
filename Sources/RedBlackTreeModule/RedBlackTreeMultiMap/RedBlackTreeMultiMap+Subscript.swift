//
//  RedBlackTreeMultiMap+Subscript.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/05.
//

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {

    /// - Complexity: O(log *n*)
    @inlinable
    @inline(__always)
    public subscript(key: Key) -> View {
      @inline(__always) get {
        let (lower, upper) = ___equal_range(key)
        return self[unchecked: .init(lowerBound: lower.sealed, upperBound: upper.sealed)]
      }
      @inline(__always) _modify {
        let (lower, upper) = ___equal_range(key)
        yield &self[unchecked: .init(lowerBound: lower.sealed, upperBound: upper.sealed)]
      }
    }
  }
#endif
