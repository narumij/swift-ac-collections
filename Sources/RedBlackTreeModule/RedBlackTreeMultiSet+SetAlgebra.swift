

extension RedBlackTreeMultiSet {
  
  @inlinable
  @inline(__always)
  public func union(_ other: __owned RedBlackTreeMultiSet<Element>)
    -> RedBlackTreeMultiSet<Element>
  {
    var result = self
    result.formUnion(other)
    return result
  }

  /// - Complexity: O(*n* + *m*)
  @inlinable
  //  @inline(__always)
  public mutating func formUnion(_ other: __owned RedBlackTreeMultiSet<Element>) {
    _storage = .init(tree: __tree_.___meld_multi(other.__tree_))
  }
}

extension RedBlackTreeMultiSet {
  
  @inlinable
  @inline(__always)
  public func symmetricDifference(_ other: __owned RedBlackTreeMultiSet<Element>)
    -> RedBlackTreeMultiSet<Element>
  {
    var result = self
    result.formSymmetricDifference(other)
    return result
  }

  /// - Complexity: O(*n* + *m*)
  @inlinable
  //  @inline(__always)
  public mutating func formSymmetricDifference(_ other: __owned RedBlackTreeMultiSet<Element>) {
    _storage = .init(tree: __tree_.___symmetric_difference(other.__tree_))
  }
}

extension RedBlackTreeMultiSet {
  
  @inlinable
  @inline(__always)
  public func intersection(_ other: RedBlackTreeMultiSet<Element>)
    -> RedBlackTreeMultiSet<Element>
  {
    var result = self
    result.formIntersection(other)
    return result
  }

  /// - Complexity: O(*n* + *m*)
  @inlinable
  //  @inline(__always)
  public mutating func formIntersection(_ other: RedBlackTreeMultiSet<Element>) {
    _storage = .init(tree: __tree_.___intersection(other.__tree_))
  }
}

extension RedBlackTreeMultiSet {
  
  @inlinable
  @inline(__always)
  public func difference(_ other: __owned RedBlackTreeMultiSet<Element>)
    -> RedBlackTreeMultiSet<Element>
  {
    var result = self
    result.formDifference(other)
    return result
  }

  /// - Complexity: O(*n* + *m*)
  @inlinable
  //  @inline(__always)
  public mutating func formDifference(_ other: __owned RedBlackTreeMultiSet<Element>) {
    _storage = .init(tree: __tree_.___difference(other.__tree_))
  }
}
