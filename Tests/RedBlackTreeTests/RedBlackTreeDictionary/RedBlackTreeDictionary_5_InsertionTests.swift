import RedBlackTreeCollections
import XCTest

final class RedBlackTreeDictionaryInsertionTests: RedBlackTreeTestCase {

  func test_keySubscript_insertsUpdatesAndRemovesValues() {
    var dictionary = RedBlackTreeDictionary<Int, String>()

    dictionary[2] = "two"
    dictionary[2] = "updated"
    XCTAssertEqual(dictionary[2], "updated")

    dictionary[2] = nil
    XCTAssertNil(dictionary[2])
    XCTAssertTrue(dictionary.isEmpty)
  }

  func test_defaultSubscript_doesNotInsertUntilMutated() {
    var dictionary = RedBlackTreeDictionary<Int, [String]>()

    XCTAssertEqual(dictionary[1, default: []], [])
    XCTAssertNil(dictionary[1])

    dictionary[1, default: []].append("one")
    dictionary[1, default: []].append("another")
    XCTAssertEqual(dictionary[1], ["one", "another"])
  }

  func test_updateValue_returnsTheReplacedValue() {
    var dictionary: RedBlackTreeDictionary<Int, String> = [1: "old"]

    XCTAssertEqual(dictionary.updateValue("new", forKey: 1), "old")
    XCTAssertNil(dictionary.updateValue("two", forKey: 2))

    XCTAssertEqual(dictionary[1], "new")
    XCTAssertEqual(dictionary[2], "two")
  }

  func test_merge_combinesDuplicateKeysAndInsertsNewKeys() {
    var dictionary: RedBlackTreeDictionary<String, Int> = ["a": 1, "b": 2]

    dictionary.merge([("b", 10), ("c", 3)]) { old, new in old + new }

    XCTAssertEqual(dictionary["a"], 1)
    XCTAssertEqual(dictionary["b"], 12)
    XCTAssertEqual(dictionary["c"], 3)
  }

  func test_merging_returnsChangedCopyAndPreservesOriginal() {
    let original: RedBlackTreeDictionary<String, Int> = ["a": 1, "b": 2]

    let result = original.merging([("b", 10), ("c", 3)]) { _, new in new }

    XCTAssertEqual(original["b"], 2)
    XCTAssertNil(original["c"])
    XCTAssertEqual(result["b"], 10)
    XCTAssertEqual(result["c"], 3)
  }
}
