import RedBlackTreeModule

// 以下を参考にした便利メソッド群
// https://github.com/tatyam-prime/SortedSet
//
// 標準コンテナに寄せた結果、メソッドとして浮き始めてきたので、盆栽対象とすることにした
extension RedBlackTreeSet {

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

extension RedBlackTreeSet {

  /// 範囲削除を行う場合に使用する
  ///
  /// remove(at:)後のIndexは不正となり、利用できなくなる
  /// このメソッドを使うことでその不便を解消し、C++のような範囲削除が可能となる
  ///
  /// ```swift
  /// var treeSet: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5, 6]
  /// var it = treeSet.lowerBound(2)
  /// let end = treeSet.upperBound(5)
  /// while it != end {
  ///   it = treeSet.erase(at: it)
  /// }
  /// print(treeSet) // 出力: [1, 6]
  /// ```
  @inlinable
  public mutating func erase(at position: Index) -> Index {
    defer { remove(at: position) }
    return index(after: position)
  }
}

extension RedBlackTreeSet {

  @inlinable
  public subscript(bounds: Range<Element>) -> ___SubSequence {
    self[lowerBound(bounds.lowerBound) ..< upperBound(bounds.upperBound)]
  }
}

extension RedBlackTreeSet {
  
  @inlinable
  public func enumerated(lowerBound from: Element, upperBound to: Element) -> EnumeratedSequence {
    ___enumerated_sequence__(from: lowerBound(from), to: upperBound(to))
  }
}

extension RedBlackTreeSet {

  @inlinable
  public mutating func removeAndForEach(
    lowerbound from: Element, upperbound to: Element,
    _ action: (Element) throws -> Void
  ) rethrows {
    try ___remove(
      from: lowerBound(from),
      to: upperBound(to),
      forEach: action)
  }
}

extension RedBlackTreeSet {

  @inlinable
  public mutating func removeAndForEach(
    _ range: Range<Element>,
    _ action: (Element) throws -> Void
  ) rethrows {
    try ___remove(
      from: lowerBound(range.lowerBound),
      to: upperBound(range.upperBound),
      forEach: action)
  }

  @inlinable
  public mutating func removeAndReduce<Result>(
    lowerbound from: Element, upperbound to: Element,
    into initialResult: Result,
    _ updateAccumulatingResult: (inout Result, Element) throws -> Void
  ) rethrows -> Result {
    try ___remove(
      from: lowerBound(from),
      to: upperBound(to),
      into: initialResult, updateAccumulatingResult)
  }

  @inlinable
  public mutating func removeAndReduce<Result>(
    lowerbound from: Element, upperbound to: Element,
    _ initialResult: Result,
    _ nextPartialResult: (Result, Element) throws -> Result
  ) rethrows -> Result {
    try ___remove(
      from: lowerBound(from),
      to: upperBound(to),
      initialResult, nextPartialResult)
  }
}
