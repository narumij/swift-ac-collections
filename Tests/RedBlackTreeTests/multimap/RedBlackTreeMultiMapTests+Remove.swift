#if DEBUG
@testable import RedBlackTreeModule
#else
import RedBlackTreeModule
#endif

import XCTest

extension RedBlackTreeMultiMapTests {
    
    func testRemoveValuesForKey_MultipleAndZeroHit() {
        var map: RedBlackTreeMultiMap = [("a", 1), ("a", 2), ("b", 3)]
        XCTAssertEqual(map.removeValues(forKey: "a"), 2)
        XCTAssertEqual(map.count, 1)
//        XCTAssertEqual(map["b"], 3)
        XCTAssertEqual(map.removeValues(forKey: "z"), 0) // 存在しないキー
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
        map.removeSubrange(start..<end)  // remove b and c
        XCTAssertEqual(map.keys.sorted(), ["a", "d"])
    }

    func testRemoveContentsOfRange() {
        var map: RedBlackTreeMultiMap = [("a", 1), ("b", 2), ("c", 3), ("d", 4)]
        map.remove(contentsOf: "b"..<"d")
        XCTAssertEqual(map.keys.sorted(), ["a", "d"])
        
        map.remove(contentsOf: "a"..."d")
        XCTAssertTrue(map.isEmpty)
    }

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
