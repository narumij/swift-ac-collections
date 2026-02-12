import RedBlackTreeModule

// 以下を参考にした便利メソッド群
// https://github.com/tatyam-prime/SortedSet
//
// 標準コンテナに寄せた結果、メソッドとして浮き始めてきたので、盆栽対象とすることにした
#if COMPATIBLE_ATCODER_2025
extension RedBlackTreeMultiSet {

  @inlinable public func lessThan(_ p: Element) -> Element? {
    return lowerBound(p).previous?.pointee
  }

  @inlinable public func lessThanOrEqual(_ p: Element) -> Element? {
    let lo = lowerBound(p)
    return (lo.pointee.map { p < $0 } ?? true) ? lo.previous?.pointee : lo.pointee
  }

  @inlinable public func greaterThan(_ p: Element) -> Element? {
    return upperBound(p).pointee
  }

  @inlinable public func greaterThanOrEqual(_ p: Element) -> Element? {
    let lo = lowerBound(p)
    return (lo.pointee.map { p == $0 } ?? false) ? lo.pointee : upperBound(p).pointee
  }
}
#endif

#if COMPATIBLE_ATCODER_2025
extension RedBlackTreeMultiSet {

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
extension RedBlackTreeMultiSet {

  @inlinable
  public mutating func removeSubrange(_ range: Range<Element>) {
    erase(lowerBound(range.lowerBound) ..< lowerBound(range.upperBound))
  }
  
  @inlinable
  public mutating func removeSubrange(_ range: ClosedRange<Element>) {
    erase(lowerBound(range.lowerBound) ..< upperBound(range.upperBound))
  }
}
#endif
