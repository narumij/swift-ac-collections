import RedBlackTreeCollections

// 以下を参考にした便利メソッド群
// https://github.com/tatyam-prime/SortedSet
//
// 標準コンテナに寄せた結果、メソッドとして浮き始めてきたので、盆栽対象とすることにした

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    @inlinable
    public mutating func removeSubrange(_ range: Range<Element>) {
      _ = erase(lowerBound(range.lowerBound)..<lowerBound(range.upperBound))
    }

    @inlinable
    public mutating func removeSubrange(_ range: ClosedRange<Element>) {
      _ = erase(lowerBound(range.lowerBound)..<upperBound(range.upperBound))
    }
  }
#endif
