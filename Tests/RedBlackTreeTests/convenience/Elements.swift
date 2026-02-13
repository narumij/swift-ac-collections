import RedBlackTreeModule

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {
    subscript(bounds: Range<Element>) -> RedBlackTreeKeyOnlyRangeView<Base> {
      elements(in: bounds)
    }
    subscript(bounds: ClosedRange<Element>) -> RedBlackTreeKeyOnlyRangeView<Base> {
      elements(in: bounds)
    }
  }
  extension RedBlackTreeSet {
    func elements(in range: Range<Element>) -> RedBlackTreeKeyOnlyRangeView<Base> {
      self[lowerBound(range.lowerBound)..<lowerBound(range.upperBound)]
    }

    func elements(in range: ClosedRange<Element>) -> RedBlackTreeKeyOnlyRangeView<Base> {
      self[lowerBound(range.lowerBound)..<upperBound(range.upperBound)]
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {
    subscript(bounds: Range<Element>) -> SubSequence {
      elements(in: bounds)
    }
    subscript(bounds: ClosedRange<Element>) -> SubSequence {
      elements(in: bounds)
    }
  }
  extension RedBlackTreeMultiSet {
    func elements(in range: Range<Element>) -> SubSequence {
      self[lowerBound(range.lowerBound)..<lowerBound(range.upperBound)]
    }
    func elements(in range: ClosedRange<Element>) -> SubSequence {
      self[lowerBound(range.lowerBound)..<upperBound(range.upperBound)]
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {
    subscript(bounds: Range<Key>) -> SubSequence {
      elements(in: bounds)
    }
    subscript(bounds: ClosedRange<Key>) -> SubSequence {
      elements(in: bounds)
    }
  }
  extension RedBlackTreeMultiMap {
    func elements(in range: Range<Key>) -> SubSequence {
      self[lowerBound(range.lowerBound)..<lowerBound(range.upperBound)]
    }
    func elements(in range: ClosedRange<Key>) -> SubSequence {
      self[lowerBound(range.lowerBound)..<upperBound(range.upperBound)]
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary {
    subscript(bounds: Range<Key>) -> SubSequence {
      elements(in: bounds)
    }
    subscript(bounds: ClosedRange<Key>) -> SubSequence {
      elements(in: bounds)
    }
  }
  extension RedBlackTreeDictionary {
    func elements(in range: Range<Key>) -> SubSequence {
      self[lowerBound(range.lowerBound)..<lowerBound(range.upperBound)]
    }
    func elements(in range: ClosedRange<Key>) -> SubSequence {
      self[lowerBound(range.lowerBound)..<upperBound(range.upperBound)]
    }
  }
#endif
