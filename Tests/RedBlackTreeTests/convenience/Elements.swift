import RedBlackTreeModule

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {
    subscript(bounds: Range<Element>) -> SubSequence {
      elements(in: bounds)
    }
    subscript(bounds: ClosedRange<Element>) -> SubSequence {
      elements(in: bounds)
    }
  }
  extension RedBlackTreeSet {
    func elements(in range: Range<Element>) -> SubSequence {
      sequence(from: range.lowerBound, to: range.upperBound)
    }

    func elements(in range: ClosedRange<Element>) -> SubSequence {
      sequence(from: range.lowerBound, through: range.upperBound)
    }
  }
#else
  extension RedBlackTreeSet {
    public func sequence(from start: Element, to end: Element) -> SubSequence {
      self[lowerBound(start)..<lowerBound(end)]
    }
  }
  extension RedBlackTreeSet {
    public func sequence(from start: Element, through end: Element) -> SubSequence {
      self[lowerBound(start)..<upperBound(end)]
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
      sequence(from: range.lowerBound, to: range.upperBound)
    }
    func elements(in range: ClosedRange<Element>) -> SubSequence {
      sequence(from: range.lowerBound, through: range.upperBound)
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
      sequence(from: range.lowerBound, to: range.upperBound)
    }
    func elements(in range: ClosedRange<Key>) -> SubSequence {
      sequence(from: range.lowerBound, through: range.upperBound)
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
      sequence(from: range.lowerBound, to: range.upperBound)
    }
    func elements(in range: ClosedRange<Key>) -> SubSequence {
      sequence(from: range.lowerBound, through: range.upperBound)
    }
  }
#endif
