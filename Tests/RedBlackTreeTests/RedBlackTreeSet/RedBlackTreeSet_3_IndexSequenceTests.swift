import RedBlackTreeCollections
import XCTest

final class RedBlackTreeSetIndexRangeTests: RedBlackTreeTestCase {

  #if !COMPATIBLE_ATCODER_2025
    func testIsElementAndIsEndDistinguishElementFromEnd() {
      let set: RedBlackTreeSet = [0, 1, 2]

      XCTAssertTrue(set.isElement(at: set.startIndex))
      XCTAssertFalse(set.isEnd(set.startIndex))
      XCTAssertFalse(set.isElement(at: set.endIndex))
      XCTAssertTrue(set.isEnd(set.endIndex))
    }

    func testIsEndRecognizesEmptySetEndIndex() {
      let set = RedBlackTreeSet<Int>()

      XCTAssertFalse(set.isElement(at: set.endIndex))
      XCTAssertTrue(set.isEnd(set.endIndex))
    }

    func testIsElementAndIsEndRejectStaleIndex() {
      var set: RedBlackTreeSet = [0, 1, 2]
      let index = set.find(1)

      XCTAssertEqual(set.remove(at: index), 1)
      XCTAssertFalse(set.isElement(at: index))
      XCTAssertFalse(set.isEnd(index))
    }

    #if ALLOW_CROSS_TREE_INDEX
      func testIsElementAndIsEndResolveIndicesInCopiedTree() {
        let source: RedBlackTreeSet = [0, 1, 2]
        let copy = source

        XCTAssertTrue(copy.isElement(at: source.find(1)))
        XCTAssertTrue(copy.isEnd(source.endIndex))
      }
    #endif
  #endif
}
