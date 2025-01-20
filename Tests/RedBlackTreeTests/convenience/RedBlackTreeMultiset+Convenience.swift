import RedBlackTreeModule

// 以下を参考にした便利メソッド群
// https://github.com/tatyam-prime/SortedSet
//
// 標準コンテナに寄せた結果、メソッドとして浮き始めてきたので、盆栽対象とすることにした
extension RedBlackTreeMultiset {

  @inlinable public func lessThan(_ p: Element) -> Element? {
    var lo = lowerBound(p)
    guard lo != startIndex else { return nil }
    lo = index(before: lo)
    return self[lo]
  }

  @inlinable public func lessThanOrEqual(_ p: Element) -> Element? {
    var lo = lowerBound(p)
    if lo == endIndex || p < self[lo] {
      if lo == startIndex { return nil }
      lo = index(before: lo)
    }
    return self[lo]
  }

  @inlinable public func greaterThan(_ p: Element) -> Element? {
    let hi = upperBound(p)
    guard hi != endIndex else { return nil }
    return self[hi]
  }

  @inlinable public func greaterThanOrEqual(_ p: Element) -> Element? {
    let lo = lowerBound(p)
    guard lo != endIndex else { return nil }
    if self[lo] == p { return p }
    let hi = upperBound(p)
    guard hi != endIndex else { return nil }
    return self[hi]
  }
}

extension RedBlackTreeMultiset {

  @inlinable
  public mutating func removeSubrange(_ range: Range<Element>) {
    removeSubrange(lowerBound(range.lowerBound) ..< lowerBound(range.upperBound))
  }
  
  @inlinable
  public mutating func removeSubrange(_ range: ClosedRange<Element>) {
    removeSubrange(lowerBound(range.lowerBound) ..< upperBound(range.upperBound))
  }
}
