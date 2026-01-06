import XCTest
import RedBlackTreeModule

final class MultiMapAdvancedTest: RedBlackTreeTestCase {

  func testEmptyAndCapacity() {
    var map = RedBlackTreeMultiMap<String, Int>()
    XCTAssertTrue(map.isEmpty)
    XCTAssertEqual(map.capacity, 0)
    map.reserveCapacity(10)
    XCTAssertGreaterThanOrEqual(map.capacity, 10)
  }

  func testInsertAndDuplicates() {
    var map = RedBlackTreeMultiMap<String, Int>()
    map.insert(key: "x", value: 1)
    map.insert(key: "x", value: 2)
    map.insert(key: "y", value: 3)
    XCTAssertEqual(map.count(forKey: "x"), 2)
    XCTAssertEqual(map.values(forKey: "x").sorted(), [1, 2])
  }

  func testRemoveSubrange() {
    var map: RedBlackTreeMultiMap = [("a", 1), ("b", 2), ("c", 3), ("d", 4)]
    let lower = map.lowerBound("b")
    let upper = map.upperBound("c")
    map.removeSubrange(lower..<upper)
    XCTAssertFalse(map.contains(key: "b"))
    XCTAssertFalse(map.contains(key: "c"))
    XCTAssertTrue(map.contains(key: "a"))
    XCTAssertTrue(map.contains(key: "d"))
  }

  //    func testRemoveAtRawIndex() {
  //        var map: RedBlackTreeMultiMap = [("x", 10), ("y", 20)]
  //        let index = map.firstIndex(of: "x")!
  //        let raw = index.rawValue
  //        let removed = map.remove(at: raw)
  //        XCTAssertEqual(removed.key, "x")
  //    }

  func testValuesForKey() {
    let map: RedBlackTreeMultiMap = [("a", 1), ("a", 2), ("b", 3)]
    let valuesA = map.values(forKey: "a")
    XCTAssertEqual(valuesA.sorted(), [1, 2])
    XCTAssertEqual(map.values(forKey: "z") + [], [])
  }

  func testRemoveValuesForKey() {
    var map: RedBlackTreeMultiMap = [("x", 1), ("x", 2), ("y", 3)]
    XCTAssertEqual(map.removeAll(forKey: "x"), 2)
    XCTAssertFalse(map.contains(key: "x"))
    XCTAssertEqual(map.removeAll(forKey: "z"), 0)
  }

  func testMinAndMax() {
    let map: RedBlackTreeMultiMap = [("b", 2), ("a", 1), ("c", 3)]
    XCTAssertEqual(map.min()?.key, "a")
    XCTAssertEqual(map.max()?.key, "c")
  }

  func testExpressibleByDictionaryLiteralAndArrayLiteral() {
    let map1: RedBlackTreeMultiMap = [("p", 1), ("q", 2)]
    XCTAssertEqual(map1.count, 2)
    let map2 = RedBlackTreeMultiMap(dictionaryLiteral: ("x", 10), ("x", 20), ("y", 30))
    XCTAssertEqual(map2.count(forKey: "x"), 2)
  }

  func testSequenceAndIterator() {
    let map: RedBlackTreeMultiMap = [("a", 1), ("b", 2), ("a", 3)]
    var seenKeys = Set<String>()
    for (key, value) in map.map(tuple) {
      seenKeys.insert(key)
      XCTAssertTrue(value == 1 || value == 2 || value == 3)
    }
    XCTAssertTrue(seenKeys.contains("a"))
    XCTAssertTrue(seenKeys.contains("b"))
  }

  func testFirstAndLast() {
    let map: RedBlackTreeMultiMap = [("a", 1), ("b", 2)]
    XCTAssertEqual(map.first?.key, "a")
    XCTAssertEqual(map.last?.key, "b")
  }

  func testContains() {
    let map: RedBlackTreeMultiMap = [("x", 10)]
    XCTAssertTrue(map.contains(key: "x"))
    XCTAssertFalse(map.contains(key: "y"))
  }

  func testValueAt() {
    let map: RedBlackTreeMultiMap = [("x", 10), ("x", 20)]
    let idx = map.lowerBound("x")
    XCTAssertNotNil(map[idx].value)
  }

#if COMPATIBLE_ATCODER_2025
  func testRemoveContentsOfRange() {
    var map: RedBlackTreeMultiMap = [("a", 1), ("b", 2), ("c", 3), ("d", 4)]
    map.remove(contentsOf: "b"..."c")
    XCTAssertFalse(map.contains(key: "b"))
    XCTAssertFalse(map.contains(key: "c"))
  }
#endif
}
