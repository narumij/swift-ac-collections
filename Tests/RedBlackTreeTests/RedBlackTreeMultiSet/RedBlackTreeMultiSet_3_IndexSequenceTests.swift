import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiSetIndexRangeTests: RedBlackTreeTestCase {

  #if !COMPATIBLE_ATCODER_2025
    func testIsElementAndIsEndDistinguishElementFromEnd() {
      let multiset: RedBlackTreeMultiSet = [0, 1, 1, 2]

      XCTAssertTrue(multiset.isElement(at: multiset.startIndex))
      XCTAssertFalse(multiset.isEnd(multiset.startIndex))
      XCTAssertFalse(multiset.isElement(at: multiset.endIndex))
      XCTAssertTrue(multiset.isEnd(multiset.endIndex))
    }

    func testIsEndRecognizesEmptyMultiSetEndIndex() {
      let multiset = RedBlackTreeMultiSet<Int>()

      XCTAssertFalse(multiset.isElement(at: multiset.endIndex))
      XCTAssertTrue(multiset.isEnd(multiset.endIndex))
    }

    func testIsElementAndIsEndRejectStaleIndex() {
      var multiset: RedBlackTreeMultiSet = [0, 1, 1, 2]
      let index = multiset.firstIndex(of: 1)!

      XCTAssertEqual(multiset.remove(at: index), 1)
      XCTAssertFalse(multiset.isElement(at: index))
      XCTAssertFalse(multiset.isEnd(index))
    }

    #if ALLOW_CROSS_TREE_INDEX
      func testIsElementAndIsEndResolveIndicesInCopiedTree() {
        let source: RedBlackTreeMultiSet = [0, 1, 1, 2]
        let copy = source

        XCTAssertTrue(copy.isElement(at: source.firstIndex(of: 1)!))
        XCTAssertTrue(copy.isEnd(source.endIndex))
      }
    #endif
  #endif
}
