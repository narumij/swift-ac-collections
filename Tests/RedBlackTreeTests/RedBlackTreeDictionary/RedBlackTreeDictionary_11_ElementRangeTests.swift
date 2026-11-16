import RedBlackTreeCollections
import XCTest

#if !COMPATIBLE_ATCODER_2025
  final class RedBlackTreeDictionaryElementRangeTests: RedBlackTreeTestCase {

    func testElementRangeExposesItsBounds() {
      let dictionary: RedBlackTreeDictionary = [
        "a": 1, "b": 2, "c": 3, "d": 4, "e": 5,
      ]
      let elements = dictionary.elements(in: "b"..<"e")  // b,c,d

      XCTAssertEqual(elements.count, 3)
      XCTAssertEqual(elements.first?.key, "b")
      XCTAssertEqual(elements.last?.key, "d")
    }

    func testElementRangeSupportsBidirectionalIteration() {
      let dictionary: RedBlackTreeDictionary = [
        1: "one", 2: "two", 3: "three", 4: "four",
      ]
      let elements = dictionary.elements(in: 2...3)  // 2,3

      XCTAssertEqual(elements.map(\.key), [2, 3])
      XCTAssertEqual(elements.reversed().map(\.key), [3, 2])
    }
  }
#endif
