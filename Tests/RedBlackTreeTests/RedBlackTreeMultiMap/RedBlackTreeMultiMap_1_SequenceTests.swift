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

  #if !COMPATIBLE_ATCODER_2025
    func test_sortedAndReversed_followElementOrder() {
      let multiMap: RedBlackTreeMultiMap = [(2, 20), (1, 10), (1, 11), (3, 30)]

      XCTAssertEqual(multiMap.sorted().map(\.key), [1, 1, 2, 3])
      XCTAssertEqual(multiMap.sorted().map(\.value), [10, 11, 20, 30])
      XCTAssertEqual(multiMap.reversed().map(\.key), [3, 2, 1, 1])
      XCTAssertEqual(multiMap.reversed().map(\.value), [30, 20, 11, 10])
    }
  #endif
}
