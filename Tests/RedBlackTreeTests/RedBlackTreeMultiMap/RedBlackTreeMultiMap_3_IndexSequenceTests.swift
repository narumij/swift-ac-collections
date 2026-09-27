import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiMapIndexRangeTests: RedBlackTreeTestCase {

  #if !COMPATIBLE_ATCODER_2025
    func testIsElementAndIsEndDistinguishElementFromEnd() {
      let multimap: RedBlackTreeMultiMap = [(0, "a"), (1, "b"), (1, "c"), (2, "d")]

      XCTAssertTrue(multimap.isElement(at: multimap.startIndex))
      XCTAssertFalse(multimap.isEnd(multimap.startIndex))
      XCTAssertFalse(multimap.isElement(at: multimap.endIndex))
      XCTAssertTrue(multimap.isEnd(multimap.endIndex))
    }

    func testIsEndRecognizesEmptyMultiMapEndIndex() {
      let multimap = RedBlackTreeMultiMap<Int, String>()

      XCTAssertFalse(multimap.isElement(at: multimap.endIndex))
      XCTAssertTrue(multimap.isEnd(multimap.endIndex))
    }

    func testIsElementAndIsEndRejectStaleIndex() {
      var multimap: RedBlackTreeMultiMap = [(0, "a"), (1, "b"), (1, "c"), (2, "d")]
      let index = multimap.firstIndex(of: 1)!

      multimap.remove(at: index)
      XCTAssertFalse(multimap.isElement(at: index))
      XCTAssertFalse(multimap.isEnd(index))
    }

    #if ALLOW_CROSS_TREE_INDEX
      func testIsElementAndIsEndResolveIndicesInCopiedTree() {
        let source: RedBlackTreeMultiMap = [(0, "a"), (1, "b"), (1, "c"), (2, "d")]
        let copy = source

        XCTAssertTrue(copy.isElement(at: source.firstIndex(of: 1)!))
        XCTAssertTrue(copy.isEnd(source.endIndex))
      }
    #endif
  #endif
}
