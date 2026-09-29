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

  /// formIndex(after:)/(before:) がindex(after:)/(before:)と同じ順序で全要素を辿り、境界で正しく停止すること
  func testFormIndexAfterAndBeforeMatchIndexAfterAndBeforeTraversal() {
    var set = RedBlackTreeSet<Int>(0..<5)

    var forward: [Int] = []
    var i = set.startIndex
    while i != set.endIndex {
      forward.append(set[i])
      set.formIndex(after: &i)
    }
    XCTAssertEqual(forward, [0, 1, 2, 3, 4])
    XCTAssertEqual(i, set.endIndex)

    var backward: [Int] = []
    var j = set.endIndex
    while j != set.startIndex {
      set.formIndex(before: &j)
      backward.append(set[j])
    }
    XCTAssertEqual(backward, [4, 3, 2, 1, 0])
  }
}
