import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

extension DictionaryTests {
    func testSubsequence6() throws {
      let set: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
      let sub = set[set.startIndex..<set.endIndex]
      XCTAssertEqual(sub.map { $0.key }, [1, 2, 3, 4, 5])
    }
    func testSubsequence7() throws {
      var set: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
      let sub = set[set.startIndex..<set.endIndex]
      var a: [String] = []
      for (_, value) in sub {
        a.append(value)
      }
      XCTAssertEqual(a, ["a", "b", "c", "d", "e"])
      sub.forEach { key, value in
        set[key] = "?"
      }
      XCTAssertEqual(set.map { $0.value }, ["?", "?", "?", "?", "?"])
    }
    func testRangeSubscript() throws {
      let set: RedBlackTreeDictionary<Int, Int> = [1: 10, 2: 20, 3: 30, 4: 40, 6: 60, 7: 70]
      let l2 = set.lowerBound(2)
      let u2 = set.upperBound(4)
      XCTAssertEqual(
        set[l2..<u2].map { RedBlackTreePair($0) }, [2, 3, 4].map { .init(key: $0, value: $0 * 10) })
      XCTAssertEqual(
        set[l2...].map { RedBlackTreePair($0) },
        [2, 3, 4, 6, 7].map { .init(key: $0, value: $0 * 10) })
      XCTAssertEqual(
        set[u2...].map { RedBlackTreePair($0) }, [6, 7].map { .init(key: $0, value: $0 * 10) })
      XCTAssertEqual(
        set[..<u2].map { RedBlackTreePair($0) },
        [1, 2, 3, 4].map { .init(key: $0, value: $0 * 10) })
      XCTAssertEqual(
        set[...u2].map { RedBlackTreePair($0) },
        [1, 2, 3, 4, 6].map { .init(key: $0, value: $0 * 10) })
      XCTAssertEqual(
        set[..<set.endIndex].map { RedBlackTreePair($0) },
        [1, 2, 3, 4, 6, 7].map { .init(key: $0, value: $0 * 10) })
    }
}

