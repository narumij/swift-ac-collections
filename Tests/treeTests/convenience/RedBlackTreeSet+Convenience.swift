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
