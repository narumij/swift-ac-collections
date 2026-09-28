import RedBlackTreeCollections
import XCTest

final class RedBlackTreeDictionaryRemovalTests: RedBlackTreeTestCase {

  func test_removeValueForKey_returnsRemovedValue() {
    var dictionary: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c"]

    XCTAssertNil(dictionary.removeValue(forKey: 0))
    XCTAssertEqual(dictionary.removeValue(forKey: 2), "b")
    XCTAssertEqual(dictionary.map(\.key), [1, 3])
  }

  func test_removeAt_removesSelectedEntry() {
    var dictionary: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c"]
    let index = dictionary.firstIndex(of: 2)!

    let removed = dictionary.remove(at: index)

    XCTAssertEqual(removed.key, 2)
    XCTAssertEqual(removed.value, "b")
    XCTAssertEqual(dictionary.map(\.key), [1, 3])
  }

  #if !COMPATIBLE_ATCODER_2025
    func test_erase_returnsTheFollowingIndex() {
      var dictionary: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c"]
      let removed = dictionary.firstIndex(of: 2)!

      let next = dictionary.erase(removed)

      XCTAssertEqual(dictionary[next].key, 3)
      XCTAssertEqual(dictionary.map(\.key), [1, 3])
    }

    func test_eraseWhere_removesEveryMatchingEntry() {
      var dictionary: RedBlackTreeDictionary<Int, String> = [
        1: "keep",
        2: "remove",
        3: "keep",
        4: "remove",
      ]

      dictionary.erase { $0.key.isMultiple(of: 2) }

      XCTAssertEqual(dictionary.map(\.key), [1, 3])
    }
  #endif

  func test_popFirst_returnsNilOrRemovesLowestKey() {
    var empty = RedBlackTreeDictionary<Int, String>()
    var dictionary: RedBlackTreeDictionary<Int, String> = [3: "c", 1: "a", 2: "b"]

    XCTAssertNil(empty.popFirst())
    XCTAssertEqual(dictionary.popFirst()?.key, 1)
    XCTAssertEqual(dictionary.map(\.key), [2, 3])
  }

  func test_removeFirstAndRemoveLast_followKeyOrder() {
    var dictionary: RedBlackTreeDictionary<Int, String> = [3: "c", 1: "a", 2: "b"]

    XCTAssertEqual(dictionary.removeFirst().key, 1)
    XCTAssertEqual(dictionary.removeLast().key, 3)
    XCTAssertEqual(dictionary.first?.key, 2)
    XCTAssertEqual(dictionary.last?.key, 2)
  }

  func test_removeAll_clearsEntriesAndHonorsCapacityChoice() {
    var keepingCapacity = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<10).map { ($0, $0) })
    let originalCapacity = keepingCapacity.capacity

    keepingCapacity.removeAll(keepingCapacity: true)
    XCTAssertTrue(keepingCapacity.isEmpty)
    XCTAssertEqual(keepingCapacity.capacity, originalCapacity)

    var releasingCapacity = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<10).map { ($0, $0) })
    releasingCapacity.removeAll()
    XCTAssertTrue(releasingCapacity.isEmpty)
  }
}
