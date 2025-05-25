import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class RedBlackTreeMultiMapSequenceTests: XCTestCase {

  let elements: [(String, Int)] = [
    ("apple", 1),
    ("apple", 3),
    ("banana", 2),
    ("cherry", 4),
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

    // 順序確認（特に木構造だと辞書順の可能性が高い）
    let sortedKeys = multiMap.map { $0.key }
    XCTAssertEqual(sortedKeys, sortedKeys.sorted())
  }

  func testEmptyMultiMap() {
    let multiMap = RedBlackTreeMultiMap<String, Int>()
    var count = 0
    for _ in multiMap {
      count += 1
    }
    XCTAssertEqual(count, 0)
  }

  func testMultipleValuesForKey() {
    var multiMap = RedBlackTreeMultiMap<String, Int>()
    multiMap.insert(key: "apple", value: 1)
    multiMap.insert(key: "apple", value: 2)
    multiMap.insert(key: "apple", value: 3)

    let appleValues = multiMap.values(forKey: "apple")
    XCTAssertEqual(Set(appleValues), Set([1, 2, 3]))

    // 全要素の数は3であることを確認
    XCTAssertEqual(multiMap.count, 3)
  }
}
