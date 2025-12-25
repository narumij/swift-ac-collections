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
    let lo = lowerBound(range.lowerBound)
    let hi = lowerBound(range.upperBound)
    return self[lo..<hi]
  }

  func elements(in range: ClosedRange<Element>) -> SubSequence {
    let lo = lowerBound(range.lowerBound)
    let hi = upperBound(range.upperBound)
    return self[lo..<hi]
  }
}
#endif

#if !COMPATIBLE_ATCODER_2025
extension RedBlackTreeMultiSet {

  subscript(bounds: Range<Element>) -> SubSequence {
    sequence(from: bounds.lowerBound, to: bounds.upperBound)
  }

  subscript(bounds: ClosedRange<Element>) -> SubSequence {
    sequence(from: bounds.lowerBound, through: bounds.upperBound)
  }
}

extension RedBlackTreeMultiSet {
  /// 値レンジ `[lower, upper)` に含まれる要素のスライス
  /// - Complexity: O(log *n*)
  func elements(in range: Range<Element>) -> SubSequence {
    sequence(from: range.lowerBound, to: range.upperBound)
  }

  /// 値レンジ `[lower, upper]` に含まれる要素のスライス
  /// - Complexity: O(log *n*)
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
  /// 値レンジ `[lower, upper)` に含まれる要素のスライス
  /// - Complexity: O(log *n*)
  func elements(in range: Range<Key>) -> SubSequence {
    let lo = lowerBound(range.lowerBound)
    let hi = lowerBound(range.upperBound)
    return self[lo..<hi]
  }

  /// 値レンジ `[lower, upper]` に含まれる要素のスライス
  /// - Complexity: O(log *n*)
  func elements(in range: ClosedRange<Key>) -> SubSequence {
    let lo = lowerBound(range.lowerBound)
    let hi = upperBound(range.upperBound)
    return self[lo..<hi]
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
  /// 値レンジ `[lower, upper)` に含まれる要素のスライス
  /// - Complexity: O(log *n*)
  func elements(in range: Range<Key>) -> SubSequence {
    let lo = lowerBound(range.lowerBound)
    let hi = lowerBound(range.upperBound)
    return self[lo..<hi]
  }

  /// 値レンジ `[lower, upper]` に含まれる要素のスライス
  /// - Complexity: O(log *n*)
  func elements(in range: ClosedRange<Key>) -> SubSequence {
    let lo = lowerBound(range.lowerBound)
    let hi = upperBound(range.upperBound)
    return self[lo..<hi]
  }
}
#endif

