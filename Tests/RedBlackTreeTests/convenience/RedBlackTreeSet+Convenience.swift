import RedBlackTreeModule

// 以下を参考にした便利メソッド群
// https://github.com/tatyam-prime/SortedSet
//
// 標準コンテナに寄せた結果、メソッドとして浮き始めてきたので、盆栽対象とすることにした
#if COMPATIBLE_ATCODER_2025
extension RedBlackTreeSet {

  @inlinable public func lessThan(_ p: Element) -> Element? {
    return lowerBound(p).previous?.pointee
  }

  @inlinable public func lessThanOrEqual(_ p: Element) -> Element? {
    return (firstIndex(of: p) ?? (lowerBound(p).previous))?.pointee
  }

  @inlinable public func greaterThan(_ p: Element) -> Element? {
    return upperBound(p).pointee
  }

  @inlinable public func greaterThanOrEqual(_ p: Element) -> Element? {
    return (firstIndex(of: p) ?? (upperBound(p)))?.pointee
  }
}
#endif

extension RedBlackTreeSet {
  
  @inlinable
  public mutating func erase(at position: Index) -> Index {
    defer { remove(at: position) }
    return index(after: position)
  }
}

#if COMPATIBLE_ATCODER_2025
extension RedBlackTreeSet {

  @inlinable
  public mutating func removeSubrange(_ range: Range<Element>) {
    removeSubrange(lowerBound(range.lowerBound) ..< lowerBound(range.upperBound))
  }
  
  @inlinable
  public mutating func removeSubrange(_ range: ClosedRange<Element>) {
    removeSubrange(lowerBound(range.lowerBound) ..< upperBound(range.upperBound))
  }
}
#else
extension RedBlackTreeSet {

  @inlinable
  public mutating func removeSubrange(_ range: Range<Element>) {
    removeAll(in: lowerBound(range.lowerBound) ..< lowerBound(range.upperBound))
  }
  
  @inlinable
  public mutating func removeSubrange(_ range: ClosedRange<Element>) {
    removeAll(in: lowerBound(range.lowerBound) ..< upperBound(range.upperBound))
  }
}
#endif
