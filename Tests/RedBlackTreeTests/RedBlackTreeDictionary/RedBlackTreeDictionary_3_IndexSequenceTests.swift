import RedBlackTreeCollections
import XCTest

final class RedBlackTreeDictionaryIndexRangeTests: RedBlackTreeTestCase {

  #if !COMPATIBLE_ATCODER_2025
    func test_distance_isPositiveForwardAndNegativeBackward() {
      let dictionary: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c"]

      XCTAssertEqual(
        dictionary.distance(from: dictionary.startIndex, to: dictionary.endIndex),
        dictionary.count
      )
      XCTAssertEqual(
        dictionary.distance(from: dictionary.endIndex, to: dictionary.startIndex),
        -dictionary.count
      )
    }

    func testIsElementAndIsEndDistinguishElementFromEnd() {
      let dictionary: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c"]

      XCTAssertTrue(dictionary.isElement(at: dictionary.startIndex))
      XCTAssertFalse(dictionary.isEnd(dictionary.startIndex))
      XCTAssertFalse(dictionary.isElement(at: dictionary.endIndex))
      XCTAssertTrue(dictionary.isEnd(dictionary.endIndex))
    }

    func testIsEndRecognizesEmptyDictionaryEndIndex() {
      let dictionary = RedBlackTreeDictionary<Int, String>()

      XCTAssertFalse(dictionary.isElement(at: dictionary.endIndex))
      XCTAssertTrue(dictionary.isEnd(dictionary.endIndex))
    }

    func testIsElementAndIsEndRejectStaleIndex() {
      var dictionary: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c"]
      let index = dictionary.index(forKey: 1)!

      dictionary.remove(at: index)
      XCTAssertFalse(dictionary.isElement(at: index))
      XCTAssertFalse(dictionary.isEnd(index))
    }

    #if ALLOW_CROSS_TREE_INDEX
      func testIsElementAndIsEndResolveIndicesInCopiedTree() {
        let source: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c"]
        let copy = source

        XCTAssertTrue(copy.isElement(at: source.index(forKey: 1)!))
        XCTAssertTrue(copy.isEnd(source.endIndex))
      }
    #endif
  #endif
}
