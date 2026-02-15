import RedBlackTreeModule
import XCTest

extension RedBlackTreeMultiMapTests {

  func testRemoveValuesForKey_MultipleAndZeroHit() {
    var map: RedBlackTreeMultiMap = [("a", 1), ("a", 2), ("b", 3)]
    #if COMPATIBLE_ATCODER_2025
      XCTAssertEqual(map.removeAll(forKey: "a"), 2)
      XCTAssertEqual(map.count, 1)
      //        XCTAssertEqual(map["b"], 3)
      XCTAssertEqual(map.removeAll(forKey: "z"), 0)  // 存在しないキー
    #else
    XCTAssertEqual(map.eraseMulti("a"), 2)
    XCTAssertEqual(map.count, 1)
    //        XCTAssertEqual(map["b"], 3)
    XCTAssertEqual(map.eraseMulti("z"), 0)  // 存在しないキー
    #endif
  }

  func testRemoveFirstAndLast_NonEmpty() {
    var map: RedBlackTreeMultiMap = [("x", 100), ("y", 200)]
    let first = map.removeFirst()
    XCTAssertEqual(first.key, "x")
    let last = map.removeLast()
    XCTAssertEqual(last.key, "y")
    XCTAssertTrue(map.isEmpty)
  }

  func testRemoveSubrange() {
    var map: RedBlackTreeMultiMap = [("a", 1), ("b", 2), ("c", 3), ("d", 4)]
    let start = map.lowerBound("b")
    let end = map.lowerBound("d")
    #if COMPATIBLE_ATCODER_2025
      map.removeSubrange(start..<end)  // remove b and c
      XCTAssertEqual(map.keys() + [], ["a", "d"])
    #else
      map.erase(start..<end)  // remove b and c
      XCTAssertEqual(map.keys + [], ["a", "d"])
    #endif
  }

  #if COMPATIBLE_ATCODER_2025
    func testRemoveContentsOfRange() {
      var map: RedBlackTreeMultiMap = [("a", 1), ("b", 2), ("c", 3), ("d", 4)]
      map.remove(contentsOf: "b"..<"d")
      #if COMPATIBLE_ATCODER_2025
        XCTAssertEqual(map.keys() + [], ["a", "d"])
      #else
        XCTAssertEqual(map.keys + [], ["a", "d"])
      #endif

      map.remove(contentsOf: "a"..."d")
      XCTAssertTrue(map.isEmpty)
    }
  #endif

  func testRemoveAtIndex() {
    var map: RedBlackTreeMultiMap = [("a", 10), ("b", 20)]
    let index = map.firstIndex(of: "a")!
    let removed = map.remove(at: index)
    XCTAssertEqual(removed.key, "a")
    XCTAssertEqual(map.count, 1)
  }

  func testRemoveAll() {
    var map: RedBlackTreeMultiMap = [("a", 1), ("b", 2)]
    map.removeAll()
    XCTAssertTrue(map.isEmpty)
  }
}
