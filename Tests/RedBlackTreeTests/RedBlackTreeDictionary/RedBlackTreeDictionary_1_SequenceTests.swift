import XCTest
import RedBlackTreeModule

final class RedBlackTreeDictionarySequenceTests: XCTestCase {

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
