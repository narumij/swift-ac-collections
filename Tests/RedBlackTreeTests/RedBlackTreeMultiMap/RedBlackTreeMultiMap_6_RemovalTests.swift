import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiMapRemovalTests: RedBlackTreeTestCase {

  func test_popFirstAndPopLast_removeOneExtremeEntry() {
    var map: RedBlackTreeMultiMap = [(1, "a"), (1, "b"), (2, "c"), (3, "d")]

    XCTAssertEqual(map.popFirst()?.value, "a")
    #if !COMPATIBLE_ATCODER_2025
      XCTAssertEqual(map.popLast()?.value, "d")
      XCTAssertEqual(map.map(\.value), ["b", "c"])
    #endif

    var empty = RedBlackTreeMultiMap<Int, String>()
    XCTAssertNil(empty.popFirst())
    #if !COMPATIBLE_ATCODER_2025
      XCTAssertNil(empty.popLast())
    #endif
  }

  func test_removeFirstAndRemoveLast_followKeyOrder() {
    var map: RedBlackTreeMultiMap = [(1, "a"), (1, "b"), (2, "c"), (3, "d")]

    XCTAssertEqual(map.removeFirst().value, "a")
    XCTAssertEqual(map.removeLast().value, "d")
    XCTAssertEqual(map.map(\.value), ["b", "c"])
  }

  #if !COMPATIBLE_ATCODER_2025
    func test_removeAt_removesOnlyTheSelectedDuplicate() {
      var map: RedBlackTreeMultiMap = [(1, "a"), (1, "b"), (1, "c"), (2, "d")]
      let middle = map.index(after: map.startIndex)

      let removed = map.remove(at: middle)

      XCTAssertEqual(removed.key, 1)
      XCTAssertEqual(removed.value, "b")
      XCTAssertEqual(map.map(\.value), ["a", "c", "d"])
    }

    func test_eraseUnique_removesOneEntryForKey() {
      var map: RedBlackTreeMultiMap = [(1, "a"), (1, "b"), (2, "c")]

      XCTAssertTrue(map.eraseUnique(1))
      XCTAssertEqual(map.count(forKey: 1), 1)
      XCTAssertFalse(map.eraseUnique(3))
    }

    func test_eraseMulti_removesEveryEntryForKey() {
      var map: RedBlackTreeMultiMap = [(1, "a"), (1, "b"), (2, "c")]

      XCTAssertEqual(map.eraseMulti(1), 2)
      XCTAssertEqual(map.map(\.key), [2])
      XCTAssertEqual(map.eraseMulti(1), 0)
    }

    func test_eraseWhere_removesEveryMatchingEntry() {
      var map: RedBlackTreeMultiMap = [(1, "a"), (1, "b"), (2, "c"), (3, "d")]

      map.erase { $0.key.isMultiple(of: 2) || $0.value == "b" }

      XCTAssertEqual(map.map(\.value), ["a", "d"])
    }
  #endif

  func test_removeAll_clearsEntriesAndHonorsCapacityChoice() {
    var keepingCapacity = RedBlackTreeMultiMap(keysWithValues: (0..<10).map { ($0, $0) })
    let originalCapacity = keepingCapacity.capacity

    keepingCapacity.removeAll(keepingCapacity: true)
    XCTAssertTrue(keepingCapacity.isEmpty)
    XCTAssertEqual(keepingCapacity.capacity, originalCapacity)

    var releasingCapacity = RedBlackTreeMultiMap(keysWithValues: (0..<10).map { ($0, $0) })
    releasingCapacity.removeAll()
    XCTAssertTrue(releasingCapacity.isEmpty)
  }
}
