import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class RedBlackTreeMultiMapSequenceTests: XCTestCase {

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

  func testEmptyMultiMap() {
    let multiMap = RedBlackTreeMultiMap<String, Int>()
    var count = 0
    for _ in multiMap {
      count += 1
    }
    XCTAssertEqual(count, 0)
  }
}
