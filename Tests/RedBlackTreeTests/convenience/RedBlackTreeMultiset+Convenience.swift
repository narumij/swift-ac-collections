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
  /// 範囲削除を行う場合に使用する
  ///
  /// remove(at:)後のIndexは不正となり、利用できなくなる
  /// このメソッドを使うことでその不便を解消し、C++のような範囲削除が可能となる
  ///
  /// ```swift
  /// var treeMultiset: RedBlackTreeMultiset<Int> = [1, 2, 2, 2, 3, 4]
  /// var it = treeMultiset.lowerBound(2)
  /// let end = treeMultiset.upperBound(2)
  /// while it != end {
  ///   it = treeMultiset.erase(at: it)
  /// }
  /// print(treeMultiset) // 出力: [1,3,4]
  /// ```
  @inlinable
  public mutating func erase(at position: Index) -> Index {
    defer { remove(at: position) }
    return index(after: position)
  }
}

extension RedBlackTreeMultiset {
  
  @inlinable
  func forEach(in range: Range<Element>, _ body: (Index, Element) throws -> Void) rethrows {
    var it = lowerBound(range.lowerBound)
    let end = upperBound(range.upperBound)
    while it != end {
      let o = it
      it = index(after: it)
      try body(o, self[o])
    }
  }

  @inlinable
  public mutating func remove(in range: Range<Element>) {
    let lower = lowerBound(range.lowerBound)
    let upper = upperBound(range.upperBound)
    var it = lower
    while it != upper {
      it = erase(at: it)
    }
  }

  @inlinable
  public mutating func remove(in range: Range<Element>, perform body: ((Element) throws -> Void) = { _ in }) rethrows {
    let lower = lowerBound(range.lowerBound)
    let upper = upperBound(range.upperBound)
    var it = lower
    while it != upper {
      try body(self[it])
      it = erase(at: it)
    }
  }
}

extension RedBlackTreeMultiset {
  var elements: [Element] {
    map { $0 }
  }
}

