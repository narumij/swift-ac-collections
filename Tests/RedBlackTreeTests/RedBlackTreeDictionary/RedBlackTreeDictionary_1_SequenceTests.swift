import XCTest
import RedBlackTreeCollections

final class RedBlackTreeDictionarySequenceTests: RedBlackTreeTestCase {

  let elements = [("apple", 1), ("cherry", 3), ("banana", 2)]

  func testSequenceConformance() {
    let dict = RedBlackTreeDictionary<String, Int>(uniqueKeysWithValues: elements)

    var collectedPairs = [(String, Int)]()

    for element in dict {
      collectedPairs.append((element.key, element.value))
    }

    let expected = [("apple", 1), ("banana", 2), ("cherry", 3)]

    // キーと値が含まれていることを確認
    XCTAssertEqual(collectedPairs.map { $0.0 }, expected.map { $0.0 })
    XCTAssertEqual(collectedPairs.map { $0.1 }, expected.map { $0.1 })
  }

  func testSequenceConformance2() {
    let dict = RedBlackTreeDictionary<String, Int>(uniqueKeysWithValues: elements)

    var collectedPairs = [(String, Int)]()

    dict.forEach { element in
      collectedPairs.append((element.key, element.value))
    }

    let expected = [("apple", 1), ("banana", 2), ("cherry", 3)]

    // キーと値が含まれていることを確認
    XCTAssertEqual(collectedPairs.map { $0.0 }, expected.map { $0.0 })
    XCTAssertEqual(collectedPairs.map { $0.1 }, expected.map { $0.1 })
  }

  func testEmptyDictionary() {
    let dict = RedBlackTreeDictionary<String, Int>()
    var count = 0
    for _ in dict {
      count += 1
    }
    XCTAssertEqual(count, 0)
  }
}

#if !COMPATIBLE_ATCODER_2025
  /// 全走査と範囲走査がキー比較を行わないこと。走査が要素ごとの探索(O(N log N))に
  /// 落ちていないことを、利用者の`Comparable`から観測できる形で固定する。
  final class RedBlackTreeDictionaryTraversalComparisonCountTests: RedBlackTreeTestCase {

    private struct CountingKey: Comparable {
      nonisolated(unsafe) static var count = 0
      let value: Int
      static func < (lhs: Self, rhs: Self) -> Bool {
        count += 1
        return lhs.value < rhs.value
      }
    }

    func testFullAndRangeTraversalDoNotCompareKeys() {
      let c = RedBlackTreeDictionary(
        uniqueKeysWithValues: (0..<64).map { (CountingKey(value: $0), $0) })
      let lower = c.index(c.startIndex, offsetBy: 8)
      let upper = c.index(c.startIndex, offsetBy: 56)
      CountingKey.count = 0

      var visited = 0
      for _ in c { visited += 1 }
      XCTAssertEqual(visited, 64)
      XCTAssertEqual(CountingKey.count, 0, "全走査はキー比較を行わないはず")

      var i = c.startIndex
      while i != c.endIndex { c.formIndex(after: &i) }
      while i != c.startIndex { c.formIndex(before: &i) }
      XCTAssertEqual(CountingKey.count, 0, "Indexによる前後の走査はキー比較を行わないはず")

      let view = c[lower..<upper]
      let afterViewCreation = CountingKey.count
      XCTAssertLessThanOrEqual(afterViewCreation, 1, "範囲の作成は定数回の比較に収まるはず")

      visited = 0
      for _ in view { visited += 1 }
      XCTAssertEqual(visited, 48)
      XCTAssertEqual(CountingKey.count, afterViewCreation, "範囲走査はキー比較を行わないはず")
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  import RedBlackTreeCollections
  import XCTest

  final class RedBlackTreeDictionaryReversedTests: RedBlackTreeTestCase {

    /// `reversed()`はキーの降順に並べた配列を返し、元の辞書を変えないこと。
    func testReversedReturnsDescendingKeyOrder() {
      let d: RedBlackTreeDictionary = [3: "c", 1: "a", 2: "b"]
      let r = d.reversed()
      XCTAssertEqual(r.map(\.key), [3, 2, 1])
      XCTAssertEqual(r.map(\.value), ["c", "b", "a"])
      XCTAssertEqual(d.map(\.key), [1, 2, 3])
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  import RedBlackTreeCollections
  import XCTest

  final class RedBlackTreeDictionarySortedTests: RedBlackTreeTestCase {

    /// `sorted()`はキー順の組の配列を返すこと。
    func testSortedReturnsPairsInKeyOrder() {
      let d: RedBlackTreeDictionary = [3: "c", 1: "a", 2: "b"]
      XCTAssertEqual(d.sorted().map(\.key), [1, 2, 3])
      XCTAssertEqual(d.sorted().map(\.value), ["a", "b", "c"])
    }
  }
#endif
