import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiMapSearchTests: RedBlackTreeTestCase {

  func test_containsAndCount_describeKeyMultiplicity() {
    let map: RedBlackTreeMultiMap = [("a", 1), ("b", 2), ("a", 3)]

    XCTAssertTrue(map.contains(key: "a"))
    XCTAssertEqual(map.count(forKey: "a"), 2)
    XCTAssertEqual(map.count(forKey: "b"), 1)
    XCTAssertFalse(map.contains(key: "c"))
  }

  func test_lowerUpperAndEqualRange_spanEveryEntryForKey() {
    let map: RedBlackTreeMultiMap = [(1, "a"), (2, "b"), (2, "c"), (3, "d")]
    let lower = map.lowerBound(2)
    let upper = map.upperBound(2)

    XCTAssertEqual(map.distance(from: lower, to: upper), 2)
    XCTAssertEqual(map[lower..<upper].map(\.value).sorted(), ["b", "c"])
    #if !COMPATIBLE_ATCODER_2025
      XCTAssertEqual(map[map.equalRange(2)].map(\.value).sorted(), ["b", "c"])
    #endif
  }

  func test_firstIndex_findsFirstEntryForKey() {
    let map: RedBlackTreeMultiMap = [("a", 1), ("b", 2), ("a", 3)]

    let index = map.firstIndex(of: "a")

    XCTAssertEqual(index.map { map[$0].key }, "a")
    XCTAssertNil(map.firstIndex(of: "c"))
  }

  func test_firstLastMinAndMax_followKeyOrder() {
    let map: RedBlackTreeMultiMap = [("b", 1), ("a", 2), ("c", 3)]
    let empty = RedBlackTreeMultiMap<String, Int>()

    XCTAssertEqual(map.first?.key, "a")
    XCTAssertEqual(map.last?.key, "c")
    XCTAssertEqual(map.min()?.key, "a")
    XCTAssertEqual(map.max()?.key, "c")
    XCTAssertNil(empty.first)
    XCTAssertNil(empty.last)
  }

  #if !COMPATIBLE_ATCODER_2025
    func test_keySubscript_returnsEveryValueForKey() {
      let map: RedBlackTreeMultiMap = [("x", 10), ("x", 20), ("y", 30)]

      XCTAssertEqual(map["x"].sorted(), [10, 20])
      XCTAssertEqual(Array(map["y"]), [30])
      XCTAssertTrue(map["z"].isEmpty)
    }
  #endif
}

#if !COMPATIBLE_ATCODER_2025
  import RedBlackTreeCollections
  import XCTest

  final class RedBlackTreeMultiMapFindTests: RedBlackTreeTestCase {

    /// `find(_:)`は同値キーのうち先頭の位置を返し、無ければ`endIndex`を返すこと。
    func testFindReturnsFirstEquivalentKeyOrEndIndex() {
      let m = RedBlackTreeMultiMap<Int, String>(keysWithValues: [(1, "a"), (2, "b"), (2, "c"), (3, "d")])
      let i = m.find(2)
      XCTAssertEqual(m[i].key, 2)
      XCTAssertEqual(m[i].value, "b")
      XCTAssertEqual(m.find(9), m.endIndex)
    }
  }
#endif
