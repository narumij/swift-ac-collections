import XCTest
import RedBlackTreeModule

final class RedBlackTreeMultiMapTests: XCTestCase {

  override func setUpWithError() throws {
    RedBlackTreeModule.tearDown(treeBuffer: _emptyTreeStorage)
  }
  
  override func tearDownWithError() throws {
    RedBlackTreeModule.tearDown(treeBuffer: _emptyTreeStorage)
  }
  
  func testInsertAndContains() {
    var map = RedBlackTreeMultiMap<String, Int>()
    map.insert(key: "a", value: 1)
    map.insert(key: "b", value: 2)
    XCTAssertTrue(map.contains(key: "a"))
    XCTAssertTrue(map.contains(key: "b"))
    XCTAssertFalse(map.contains(key: "c"))
  }

  func testValuesForKey() {
    var map = RedBlackTreeMultiMap<String, Int>()
    map.insert(key: "x", value: 10)
    map.insert(key: "x", value: 20)
    map.insert(key: "y", value: 30)
    let valuesX = map.values(forKey: "x")
    XCTAssertEqual(valuesX.sorted(), [10, 20])
    let valuesY = map.values(forKey: "y")
    XCTAssertEqual(valuesY + [], [30])
    XCTAssertEqual(map.count(forKey: "x"), 2)
  }

  func testMinMax() {
    let map: RedBlackTreeMultiMap = [("b", 1), ("a", 2), ("c", 3)]
    XCTAssertEqual(map.min()?.key, "a")
    XCTAssertEqual(map.max()?.key, "c")
  }

  func testFirstAndLast() {
    let map: RedBlackTreeMultiMap = [("b", 1), ("a", 2), ("c", 3)]
    XCTAssertEqual(map.first?.key, "a")
    XCTAssertEqual(map.last?.key, "c")

    let emptyMap = RedBlackTreeMultiMap<String, Int>()
    XCTAssertNil(emptyMap.first)
    XCTAssertNil(emptyMap.last)
  }

  func testFirstWhere() {
    let map: RedBlackTreeMultiMap = [("x", 1), ("y", 2), ("z", 3)]
    let firstEven = map.first { $0.value % 2 == 0 }
    XCTAssertEqual(firstEven?.value, 2)
    let firstLarge = map.first { $0.value > 10 }
    XCTAssertNil(firstLarge)
  }

  func testFirstIndexAndIndexing() {
    let map: RedBlackTreeMultiMap = [("a", 1), ("b", 2), ("a", 3)]
    if let idx = map.firstIndex(of: "a") {
      XCTAssertEqual(map[idx].key, "a")
    } else {
      XCTFail("Expected to find key 'a'")
    }

    if let idx = map.firstIndex(where: { $0.value == 2 }) {
      XCTAssertEqual(map[idx].value, 2)
    } else {
      XCTFail("Expected to find value 2")
    }
  }

  func testRemoveValuesForKey() {
    var map: RedBlackTreeMultiMap = [("k1", 1), ("k1", 2), ("k2", 3)]
    let removedCount = map.removeAll(forKey: "k1")
    XCTAssertEqual(removedCount, 2)
    XCTAssertFalse(map.contains(key: "k1"))
  }

  func testRemoveFirstAndLast() {
    var map: RedBlackTreeMultiMap = [("x", 10), ("y", 20)]
    let firstRemoved = map.removeFirst()
    XCTAssertEqual(firstRemoved.key, "x")
    let lastRemoved = map.removeLast()
    XCTAssertEqual(lastRemoved.key, "y")
    XCTAssertTrue(map.isEmpty)
  }

  func testKeysAndValues() {
    let map: RedBlackTreeMultiMap = [("a", 1), ("b", 2), ("a", 3)]
    #if COMPATIBLE_ATCODER_2025
      let keys = map.keys() + []
      let values = map.values() + []
    #else
      let keys = map.keys + []
      let values = map.values + []
    #endif
    XCTAssertEqual(keys, ["a", "a", "b"])
    XCTAssertEqual(values, [1, 3, 2])
  }

  // rawIndexに関するテストは将来追加予定、未対応
  func testRemoveAtRawIndex() {
    // 将来のために残す
    // var map: RedBlackTreeMultiMap = [("x", 10), ("y", 20)]
    // let index = map.firstIndex(of: "x")!
    // let raw = index.rawValue
    // let removed = map.remove(at: raw)
    // XCTAssertEqual(removed.key, "x")
  }
}
