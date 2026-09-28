import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiMapIndexRangeTests: RedBlackTreeTestCase {

  #if !COMPATIBLE_ATCODER_2025
    func test_distanceCountsDuplicatePositionsInBothDirections() {
      let multimap: RedBlackTreeMultiMap = [(0, "a"), (1, "b"), (1, "c"), (2, "d")]

      XCTAssertEqual(
        multimap.distance(from: multimap.startIndex, to: multimap.endIndex),
        multimap.count
      )
      XCTAssertEqual(
        multimap.distance(from: multimap.endIndex, to: multimap.startIndex),
        -multimap.count
      )
    }

    func test_indexAndFormIndex_moveForwardAndBackwardSymmetrically() {
      let multimap: RedBlackTreeMultiMap<Int, Int> = [(1, 10), (2, 20), (3, 30), (4, 40), (5, 50)]

      var i = multimap.startIndex
      for _ in 0..<multimap.count {
        XCTAssertEqual(multimap.distance(from: i, to: multimap.index(after: i)), 1)
        i = multimap.index(after: i)
      }
      XCTAssertEqual(i, multimap.endIndex)

      for _ in 0..<multimap.count {
        XCTAssertEqual(multimap.distance(from: i, to: multimap.index(before: i)), -1)
        i = multimap.index(before: i)
      }
      XCTAssertEqual(i, multimap.startIndex)

      for _ in 0..<multimap.count {
        multimap.formIndex(after: &i)
      }
      XCTAssertEqual(i, multimap.endIndex)

      for _ in 0..<multimap.count {
        multimap.formIndex(before: &i)
      }
      XCTAssertEqual(i, multimap.startIndex)
    }

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
