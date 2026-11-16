import RedBlackTreeCollections

// 以下を参考にした便利メソッド群
// https://github.com/tatyam-prime/SortedSet
//
// 標準コンテナに寄せた結果、メソッドとして浮き始めてきたので、盆栽対象とすることにした

extension RedBlackTreeSet {

  @inlinable
  public mutating func erase(at position: Index) -> Index {
    defer { remove(at: position) }
    return index(after: position)
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

    @inlinable
    public mutating func removeSubrange(_ range: Range<Element>) {
      erase(lowerBound(range.lowerBound)..<lowerBound(range.upperBound))
    }

    @inlinable
    public mutating func removeSubrange(_ range: ClosedRange<Element>) {
      erase(lowerBound(range.lowerBound)..<upperBound(range.upperBound))
    }
  }
#endif
