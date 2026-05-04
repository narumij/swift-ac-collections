//
//  RedBlackTreeMultiSet+Subscript.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/05.
//

#if !COMPATIBLE_ATCODER_2025 && false
  // 追加するか検討
  extension RedBlackTreeMultiSet {

    /// - Complexity: O(log *n*)
    @inlinable
    @inline(__always)
    public subscript(element: Element) -> View {
      @inline(__always) get {
        let (lower, upper) = ___equal_range(element)
        return self[unchecked: .init(lowerBound: lower.sealed, upperBound: upper.sealed)]
      }
      @inline(__always) _modify {
        let (lower, upper) = ___equal_range(element)
        yield &self[unchecked: .init(lowerBound: lower.sealed, upperBound: upper.sealed)]
      }
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    /// Accesses the element at the specified position.
    /// 
    /// - Complexity: O(1)
    @inlinable
    public subscript(position: Index) -> Element {
      @inline(__always) get {
        __tree_[_unsafe: __tree_.__purified_(position)]
      }
    }
  }
#endif
