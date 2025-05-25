import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class RedBlackTreeDictionarySequenceTests: XCTestCase {

  let elements = [("apple", 1), ("banana", 2), ("cherry", 3)]

  func testSequenceConformance() {
    let dict = RedBlackTreeDictionary<String, Int>(uniqueKeysWithValues: elements)

    var collectedKeys = [String]()
    var collectedValues = [Int]()

    for element in dict {
      collectedKeys.append(element.key)
      collectedValues.append(element.value)
    }

    // キーと値が含まれていることを確認
    XCTAssertEqual(Set(collectedKeys), Set(["apple", "banana", "cherry"]))
    XCTAssertEqual(Set(collectedValues), Set([1, 2, 3]))

    // 並び順が保証されている場合（例: ソート済みの辞書ならテストできる）
    let sortedKeys = dict.map { $0.key }
    XCTAssertEqual(sortedKeys, ["apple", "banana", "cherry"].sorted())
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
