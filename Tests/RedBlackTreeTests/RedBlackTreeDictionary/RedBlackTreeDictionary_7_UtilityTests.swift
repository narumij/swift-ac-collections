import RedBlackTreeCollections
import XCTest

final class RedBlackTreeDictionaryUtilityTests: RedBlackTreeTestCase {

  func test_keysAndValues_followKeyOrder() {
    let dictionary: RedBlackTreeDictionary = [3: "c", 1: "a", 2: "b"]

      XCTAssertEqual(Array(dictionary.keys), [1, 2, 3])
      XCTAssertEqual(Array(dictionary.values), ["a", "b", "c"])
  }

  func test_mapValues_transformsValuesAndPreservesKeys() {
    let dictionary: RedBlackTreeDictionary = [1: 10, 2: 20]

    let result = dictionary.mapValues { "value=\($0)" }

    XCTAssertEqual(result[1], "value=10")
    XCTAssertEqual(result[2], "value=20")
    XCTAssertEqual(result.map(\.key), [1, 2])
  }

  func test_compactMapValues_omitsNilResults() {
    let dictionary: RedBlackTreeDictionary = [1: 10, 2: 20, 3: 30]

    let result = dictionary.compactMapValues { $0 >= 20 ? String($0) : nil }

    XCTAssertNil(result[1])
    XCTAssertEqual(result[2], "20")
    XCTAssertEqual(result[3], "30")
  }

  func test_filter_returnsDictionaryContainingMatchingEntries() {
    let dictionary: RedBlackTreeDictionary = [1: "a", 2: "b", 3: "c", 4: "d"]

    let result = dictionary.filter { $0.key.isMultiple(of: 2) }

    XCTAssertEqual(result.map(\.key), [2, 4])
    XCTAssertEqual(result[2], "b")
    XCTAssertEqual(result[4], "d")
  }

  func test_copyOnWrite_mutatingCopyPreservesOriginal() {
    let original: RedBlackTreeDictionary = [1: "a", 2: "b"]
    var copy = original

    copy[2] = "changed"
    copy[3] = "c"

    XCTAssertEqual(original[2], "b")
    XCTAssertNil(original[3])
    XCTAssertEqual(copy[2], "changed")
    XCTAssertEqual(copy[3], "c")
  }
}
