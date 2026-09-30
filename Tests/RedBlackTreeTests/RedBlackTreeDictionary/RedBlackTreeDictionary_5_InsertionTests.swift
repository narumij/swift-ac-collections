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

  func test_keySubscript_assigningNilToMissingKeyIsANoOp() {
    var dictionary: RedBlackTreeDictionary<Int, String> = [1: "one"]

    dictionary[999] = nil

    XCTAssertNil(dictionary[999])
    XCTAssertEqual(dictionary.count, 1)
    XCTAssertEqual(dictionary[1], "one")
  }

  func test_defaultSubscript_doesNotInsertUntilMutated() {
    var dictionary = RedBlackTreeDictionary<Int, [String]>()

    XCTAssertEqual(dictionary[1, default: []], [])
    XCTAssertNil(dictionary[1])

    dictionary[1, default: []].append("one")
    dictionary[1, default: []].append("another")
    XCTAssertEqual(dictionary[1], ["one", "another"])
  }

  func test_insert_returnsInsertedFlagAndExistingMemberOnDuplicate() {
    var dictionary = RedBlackTreeDictionary<Int, Int>()

    let first = dictionary.insert((3, 10))
    XCTAssertTrue(first.inserted)
    XCTAssertEqual(first.memberAfterInsert.key, 3)
    XCTAssertEqual(first.memberAfterInsert.value, 10)
    XCTAssertEqual(dictionary[3], 10)

    let duplicate = dictionary.insert((3, 20))
    XCTAssertFalse(duplicate.inserted)
    XCTAssertEqual(duplicate.memberAfterInsert.value, 10)
    XCTAssertEqual(dictionary[3], 10)
  }

  func test_insertKeyValue_returnsInsertedFlagAndExistingMemberOnDuplicate() {
    var dictionary = RedBlackTreeDictionary<Int, Int>()

    let first = dictionary.insert(key: 3, value: 10)
    XCTAssertTrue(first.inserted)
    XCTAssertEqual(first.memberAfterInsert.value, 10)

    let duplicate = dictionary.insert(key: 3, value: 20)
    XCTAssertFalse(duplicate.inserted)
    XCTAssertEqual(duplicate.memberAfterInsert.value, 10)
    XCTAssertEqual(dictionary[3], 10)
  }

  #if !COMPATIBLE_ATCODER_2025
    func test_insertWithHint_insertsRegardlessOfHintAccuracyAndRejectsDuplicateKey() {
      var dictionary: RedBlackTreeDictionary<Int, String> = [1: "one", 3: "three"]

      let goodHint = dictionary.firstIndex(of: 3)!
      let insertedWithGoodHint = dictionary.insert((2, "two"), hint: goodHint)
      XCTAssertTrue(insertedWithGoodHint.inserted)
      XCTAssertEqual(dictionary[insertedWithGoodHint.indexAfterInsert].key, 2)

      let insertedWithBadHint = dictionary.insert((4, "four"), hint: dictionary.startIndex)
      XCTAssertTrue(insertedWithBadHint.inserted)
      XCTAssertEqual(dictionary[insertedWithBadHint.indexAfterInsert].key, 4)

      let duplicate = dictionary.insert((2, "replacement"), hint: dictionary.endIndex)
      XCTAssertFalse(duplicate.inserted)
      XCTAssertEqual(dictionary[2], "two")
      XCTAssertEqual(dictionary.map(\.key), [1, 2, 3, 4])
    }

    /// ヒント付きupdateが新規キーではnilを返し、既存キーでは旧エントリを返して値を置き換えること
    func test_updateWithHint_returnsNilForNewKeyAndOldEntryForExistingKey() {
      var dictionary: RedBlackTreeDictionary<Int, String> = [1: "one", 3: "three"]

      let insertedWithGoodHint = dictionary.update((2, "two"), hint: dictionary.firstIndex(of: 3)!)
      XCTAssertNil(insertedWithGoodHint)
      XCTAssertEqual(dictionary.map(\.key), [1, 2, 3])

      let insertedWithBadHint = dictionary.update((4, "four"), hint: dictionary.startIndex)
      XCTAssertNil(insertedWithBadHint)
      XCTAssertEqual(dictionary.map(\.key), [1, 2, 3, 4])

      let replaced = dictionary.update((2, "replacement"), hint: dictionary.endIndex)
      XCTAssertEqual(replaced?.key, 2)
      XCTAssertEqual(replaced?.value, "two")
      XCTAssertEqual(dictionary[2], "replacement")
      XCTAssertEqual(dictionary.map(\.key), [1, 2, 3, 4])
    }
  #endif

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

  func test_merge_fromAnotherDictionary_combinesDuplicateKeysAndInsertsNewKeys() {
    var dictionary: RedBlackTreeDictionary<String, Int> = ["a": 1, "b": 2]
    let other: RedBlackTreeDictionary<String, Int> = ["b": 10, "c": 3]

    dictionary.merge(other) { old, new in old + new }

    XCTAssertEqual(dictionary["a"], 1)
    XCTAssertEqual(dictionary["b"], 12)
    XCTAssertEqual(dictionary["c"], 3)
    XCTAssertEqual(other["b"], 10)
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
