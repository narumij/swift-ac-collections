import XCTest
import RedBlackTreeCollections

final class RedBlackTreeMultiMapSequenceTests: RedBlackTreeTestCase {

  let elements: [(String, Int)] = [
    ("cherry", 4),
    ("apple", 1),
    ("banana", 2),
    ("apple", 3),
  ]
  
  func testSequenceConformance() {
    let multiMap = RedBlackTreeMultiMap<String, Int>(keysWithValues: elements)

    var collectedPairs = [(String, Int)]()

    for element in multiMap {
      collectedPairs.append((element.key, element.value))
    }

    // 含まれるキーと値の組を確認（重複あり）
    let expectedPairs: [(String, Int)] = [
      ("apple", 1),
      ("apple", 3),
      ("banana", 2),
      ("cherry", 4),
    ]

    XCTAssertEqual(collectedPairs.map { $0.0 }, expectedPairs.map { $0.0 })
    XCTAssertEqual(collectedPairs.map { $0.1 }, expectedPairs.map { $0.1 })
  }
  
  func testSequenceConformance2() {
    let multiMap = RedBlackTreeMultiMap<String, Int>(keysWithValues: elements)

    var collectedPairs = [(String, Int)]()

    multiMap.forEach { element in
      collectedPairs.append((element.key, element.value))
    }

    // 含まれるキーと値の組を確認（重複あり）
    let expectedPairs: [(String, Int)] = [
      ("apple", 1),
      ("apple", 3),
      ("banana", 2),
      ("cherry", 4),
    ]

    XCTAssertEqual(collectedPairs.map { $0.0 }, expectedPairs.map { $0.0 })
    XCTAssertEqual(collectedPairs.map { $0.1 }, expectedPairs.map { $0.1 })
  }

  func testEmptyMultiMap() {
    let multiMap = RedBlackTreeMultiMap<String, Int>()
    var count = 0
    for _ in multiMap {
      count += 1
    }
    XCTAssertEqual(count, 0)
  }

  func test_sequencePredicates_observeEntriesInKeyOrder() {
    let multiMap: RedBlackTreeMultiMap = [(1, 11), (2, 22), (3, 33)]

    XCTAssertEqual(multiMap.first(where: { $0.value == 22 })?.key, 2)
    XCTAssertNil(multiMap.first(where: { $0.value == 44 }))
    XCTAssertTrue(multiMap.contains(where: { $0.key == 3 }))
    XCTAssertFalse(multiMap.contains(where: { $0.key == 4 }))
    XCTAssertTrue(multiMap.allSatisfy { $0.value == $0.key * 11 })
  }

    func test_sortedAndReversed_followElementOrder() {
      let multiMap: RedBlackTreeMultiMap = [(2, 20), (1, 10), (1, 11), (3, 30)]

      XCTAssertEqual(multiMap.sorted().map(\.key), [1, 1, 2, 3])
      XCTAssertEqual(multiMap.sorted().map(\.value), [10, 11, 20, 30])
      XCTAssertEqual(multiMap.reversed().map(\.key), [3, 2, 1, 1])
      XCTAssertEqual(multiMap.reversed().map(\.value), [30, 20, 11, 10])
    }
}

  /// 全走査と範囲走査がキー比較を行わないこと。走査が要素ごとの探索(O(N log N))に
  /// 落ちていないことを、利用者の`Comparable`から観測できる形で固定する。
  final class RedBlackTreeMultiMapTraversalComparisonCountTests: RedBlackTreeTestCase {

    private struct CountingKey: Comparable {
      nonisolated(unsafe) static var count = 0
      let value: Int
      static func < (lhs: Self, rhs: Self) -> Bool {
        count += 1
        return lhs.value < rhs.value
      }
    }

    func testFullAndRangeTraversalDoNotCompareKeys() {
      let c = RedBlackTreeMultiMap(
        keysWithValues: (0..<64).map { (CountingKey(value: $0), $0) })
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
