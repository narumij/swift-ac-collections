import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class MultiMapBasicTest: XCTestCase {

  func testInsertAndBasicProperties() {
    var multiMap = RedBlackTreeMultiMap<String, Int>()
    XCTAssertTrue(multiMap.isEmpty)
    XCTAssertEqual(multiMap.count, 0)

    multiMap.insert(key: "apple", value: 1)
    multiMap.insert(key: "banana", value: 2)
    multiMap.insert(key: "apple", value: 3)

    XCTAssertFalse(multiMap.isEmpty)
    XCTAssertEqual(multiMap.count, 3)
    XCTAssertTrue(multiMap.contains(key: "apple"))
    XCTAssertTrue(multiMap.contains(key: "banana"))
    XCTAssertFalse(multiMap.contains(key: "cherry"))

    XCTAssertEqual(multiMap.count(forKey: "apple"), 2)
    XCTAssertEqual(multiMap.count(forKey: "banana"), 1)
    XCTAssertEqual(multiMap.count(forKey: "cherry"), 0)

    XCTAssertEqual(multiMap.values(forKey: "apple").sorted(), [1, 3])
  }

  func testRemovalOperations() {
    var multiMap = RedBlackTreeMultiMap<String, Int>(multiKeysWithValues: [
      ("apple", 1), ("banana", 2), ("apple", 3),
    ])

    XCTAssertEqual(multiMap.removeAll(forKey: "apple"), 2)
    XCTAssertFalse(multiMap.contains(key: "apple"))
    XCTAssertEqual(multiMap.count(forKey: "apple"), 0)

    if !multiMap.isEmpty {
      let removed = multiMap.removeFirst()
      XCTAssertEqual(removed.key, "banana")
      XCTAssertEqual(removed.value, 2)
    }

    multiMap.removeAll()
    XCTAssertTrue(multiMap.isEmpty)
  }

  func testBoundsAndIndexing() {
    let elements = [("a", 1), ("a", 2), ("b", 3), ("c", 4)]
    let multiMap = RedBlackTreeMultiMap(multiKeysWithValues: elements)

    let lb = multiMap.lowerBound("a")
    let ub = multiMap.upperBound("a")
    XCTAssertLessThan(lb, ub)
    XCTAssertEqual(multiMap.distance(from: lb, to: ub), 2)

    let lb2 = multiMap.lowerBound("z")
    XCTAssertEqual(lb2, multiMap.endIndex)
  }

  func testExpressibleByLiteralAndSequence() {
    let multiMap: RedBlackTreeMultiMap = [("x", 10), ("y", 20), ("x", 30)]
    XCTAssertEqual(multiMap.count, 3)
    XCTAssertEqual(Set(multiMap.keys()), ["x", "y"])
    XCTAssertEqual(multiMap.values(forKey: "x").sorted(), [10, 30])

    var collected: [String: [Int]] = [:]
    for kv in multiMap {
      collected[kv.key, default: []].append(kv.value)
    }
    XCTAssertEqual(collected["x"]?.sorted(), [10, 30])
    XCTAssertEqual(collected["y"], [20])
  }

  func testMinMax() {
    let multiMap: RedBlackTreeMultiMap = [("a", 1), ("b", 2), ("c", 3)]
    XCTAssertEqual(multiMap.min()?.key, "a")
    XCTAssertEqual(multiMap.max()?.key, "c")
  }

  func testDebugDescription() {
    let multiMap: RedBlackTreeMultiMap = [("a", 1), ("b", 2)]
    let desc = multiMap.description
    XCTAssertTrue(desc.contains("\"a\": 1"))
    XCTAssertTrue(desc.contains("\"b\": 2"))
  }

  func testRemoveContentsOfRange() {
    var multiMap: RedBlackTreeMultiMap = [("a", 1), ("b", 2), ("c", 3), ("d", 4)]
    multiMap.remove(contentsOf: "b"..."c")
    XCTAssertFalse(multiMap.contains(key: "b"))
    XCTAssertFalse(multiMap.contains(key: "c"))
    XCTAssertTrue(multiMap.contains(key: "a"))
    XCTAssertTrue(multiMap.contains(key: "d"))
  }

  func testPrint() {
    var multiMap = RedBlackTreeMultiMap<String, Int>()
    multiMap.insert(key: "apple", value: 5)
    multiMap.insert(key: "apple", value: 2)
    multiMap.insert(key: "banana", value: 3)
    print(multiMap)  // 例: [apple: 5, apple: 2, banana: 3]
  }
}
